"""ML Service for crop disease detection with caching and batch processing."""
import asyncio
import hashlib
import logging
import time
from dataclasses import dataclass
from typing import Optional, List, Tuple
import torch

from app.core.config import settings
from app.services.cache_service import cache_service
from app.ml.model_wrapper import CropDiseaseModel
from app.ml.preprocessing import preprocess_image, preprocess_batch, validate_image_quality
from app.ml.disease_knowledge import get_treatment_recommendation, normalize_disease_name

logger = logging.getLogger(__name__)


@dataclass
class MLPredictionResult:
    """Structured ML prediction result."""
    crop_type: str
    crop_confidence: float
    disease_name: str
    disease_confidence: float
    severity: str
    symptoms_observed: str
    recommended_treatment: str
    preventive_measures: str
    alternative_diagnoses: List[Tuple[str, float]]
    model_version: str
    inference_time_ms: float
    is_uncertain: bool = False
    image_quality_score: float = 0.0


class MLServiceException(Exception):
    """Custom exception for ML service errors."""
    pass


class MLService:
    """Singleton ML service for crop disease detection."""
    
    _model: Optional[CropDiseaseModel] = None
    _model_lock: asyncio.Lock = asyncio.Lock()
    _warmup_done: bool = False

    @classmethod
    async def _ensure_model_loaded(cls) -> CropDiseaseModel:
        """
        Lazily load the model on first use (thread-safe).
        
        Returns:
            Loaded CropDiseaseModel instance
        
        Raises:
            MLServiceException: If model loading fails critically
        """
        if cls._model is not None:
            return cls._model

        async with cls._model_lock:
            # Double-check after acquiring lock
            if cls._model is not None:
                return cls._model

            try:
                logger.info("Loading ML model...")
                start_time = time.time()
                
                # Load model
                cls._model = CropDiseaseModel(
                    model_path=settings.ML_MODEL_PATH,
                    device=settings.ML_DEVICE
                )
                
                load_time = (time.time() - start_time) * 1000
                logger.info(f"Model loaded in {load_time:.2f}ms on device: {settings.ML_DEVICE}")
                
                # Warmup with dummy inference
                if not cls._warmup_done:
                    await cls._warmup_model()
                    cls._warmup_done = True
                
                return cls._model

            except Exception as e:
                logger.error(f"Failed to load ML model: {e}")
                raise MLServiceException(f"Model loading failed: {str(e)}")

    @classmethod
    async def _warmup_model(cls) -> None:
        """Warm up model with dummy inference to initialize JIT compilation."""
        try:
            logger.info("Warming up model...")
            start_time = time.time()
            
            # Create dummy tensor
            dummy_input = torch.randn(1, 3, 224, 224)
            cls._model.predict(dummy_input)
            
            warmup_time = (time.time() - start_time) * 1000
            logger.info(f"Model warmup completed in {warmup_time:.2f}ms")
        except Exception as e:
            logger.warning(f"Model warmup failed (non-critical): {e}")

    @staticmethod
    def _compute_image_hash(image_bytes: bytes) -> str:
        """
        Compute SHA256 hash of image for cache key.
        
        Args:
            image_bytes: Raw image bytes
        
        Returns:
            Hex string of SHA256 hash
        """
        return hashlib.sha256(image_bytes).hexdigest()

    @classmethod
    async def get_cached_prediction(cls, image_hash: str) -> Optional[MLPredictionResult]:
        """
        Retrieve cached prediction from Redis.
        
        Args:
            image_hash: SHA256 hash of image
        
        Returns:
            Cached MLPredictionResult or None if not found
        """
        try:
            cache_key = f"ml:prediction:{image_hash}"
            cached_data = await cache_service.get_json(cache_key)
            
            if cached_data:
                logger.debug(f"Cache hit for image hash: {image_hash[:16]}...")
                # Reconstruct MLPredictionResult from cached dict
                return MLPredictionResult(
                    crop_type=cached_data["crop_type"],
                    crop_confidence=cached_data["crop_confidence"],
                    disease_name=cached_data["disease_name"],
                    disease_confidence=cached_data["disease_confidence"],
                    severity=cached_data["severity"],
                    symptoms_observed=cached_data["symptoms_observed"],
                    recommended_treatment=cached_data["recommended_treatment"],
                    preventive_measures=cached_data["preventive_measures"],
                    alternative_diagnoses=cached_data["alternative_diagnoses"],
                    model_version=cached_data["model_version"],
                    inference_time_ms=cached_data["inference_time_ms"],
                    is_uncertain=cached_data.get("is_uncertain", False),
                    image_quality_score=cached_data.get("image_quality_score", 0.0),
                )
            
            logger.debug(f"Cache miss for image hash: {image_hash[:16]}...")
            return None
            
        except Exception as e:
            logger.warning(f"Cache retrieval failed: {e}")
            return None

    @classmethod
    async def cache_prediction(cls, image_hash: str, result: MLPredictionResult) -> bool:
        """
        Store prediction in Redis cache.
        
        Args:
            image_hash: SHA256 hash of image
            result: Prediction result to cache
        
        Returns:
            True if caching succeeded, False otherwise
        """
        try:
            cache_key = f"ml:prediction:{image_hash}"
            
            # Convert dataclass to dict for JSON serialization
            cache_data = {
                "crop_type": result.crop_type,
                "crop_confidence": result.crop_confidence,
                "disease_name": result.disease_name,
                "disease_confidence": result.disease_confidence,
                "severity": result.severity,
                "symptoms_observed": result.symptoms_observed,
                "recommended_treatment": result.recommended_treatment,
                "preventive_measures": result.preventive_measures,
                "alternative_diagnoses": result.alternative_diagnoses,
                "model_version": result.model_version,
                "inference_time_ms": result.inference_time_ms,
                "is_uncertain": result.is_uncertain,
                "image_quality_score": result.image_quality_score,
            }
            
            success = await cache_service.set_json(cache_key, cache_data, settings.ML_CACHE_TTL)
            if success:
                logger.debug(f"Cached prediction for image hash: {image_hash[:16]}...")
            return success
            
        except Exception as e:
            logger.warning(f"Cache storage failed: {e}")
            return False

    @classmethod
    async def predict_disease(
        cls,
        image_bytes: bytes,
        crop_hint: Optional[str] = None
    ) -> MLPredictionResult:
        """
        Predict crop disease from image.
        
        Args:
            image_bytes: Raw image bytes
            crop_hint: Optional crop type hint for better predictions
        
        Returns:
            MLPredictionResult with disease classification and recommendations
        
        Raises:
            MLServiceException: If prediction fails
        """
        start_time = time.time()
        
        try:
            # Compute image hash for caching
            image_hash = cls._compute_image_hash(image_bytes)
            
            # Check cache first
            cached_result = await cls.get_cached_prediction(image_hash)
            if cached_result:
                logger.info("Returning cached prediction")
                return cached_result
            
            # Validate image quality
            quality_score, quality_reason = validate_image_quality(image_bytes)
            logger.info(f"Image quality: {quality_score:.2f} - {quality_reason}")
            
            # Preprocess image
            try:
                image_tensor = preprocess_image(image_bytes)
            except ValueError as e:
                raise MLServiceException(f"Image preprocessing failed: {str(e)}")
            
            # Load model (lazy initialization)
            model = await cls._ensure_model_loaded()
            
            # Run inference
            predictions = model.predict(image_tensor)
            
            # Get top prediction
            top_disease, top_confidence = predictions[0]
            
            # Check confidence threshold
            is_uncertain = top_confidence < settings.ML_CONFIDENCE_THRESHOLD
            
            if is_uncertain:
                disease_name = "Uncertain - Multiple Possibilities"
                disease_confidence = top_confidence
                severity = "none"
                treatment_data = {
                    "symptoms": "Unable to confidently identify disease. Multiple possibilities detected.",
                    "treatment": "Please consult with agricultural extension officer or capture clearer images in good lighting.",
                    "prevention": "Ensure photos are sharp, well-lit, and focused on affected plant parts.",
                    "severity": "none",
                }
            else:
                disease_name = top_disease
                disease_confidence = top_confidence
                
                # Get treatment recommendations
                treatment_data = get_treatment_recommendation(disease_name, crop_hint or "")
                severity = treatment_data.get("severity", "moderate")
            
            # Extract crop type from disease name
            crop_type = "Unknown Crop"
            if "___" in top_disease:
                crop_parts = top_disease.split("___")
                crop_type = crop_parts[0].replace("_", " ").title()
            
            # Calculate inference time
            inference_time = (time.time() - start_time) * 1000
            
            # Build result
            result = MLPredictionResult(
                crop_type=crop_type,
                crop_confidence=min(top_confidence + 0.05, 0.99),  # Slightly boost crop confidence
                disease_name=disease_name,
                disease_confidence=disease_confidence,
                severity=severity,
                symptoms_observed=treatment_data.get("symptoms", ""),
                recommended_treatment=treatment_data.get("treatment", ""),
                preventive_measures=treatment_data.get("prevention", ""),
                alternative_diagnoses=predictions,  # Top-3 predictions
                model_version=settings.ML_MODEL_VERSION,
                inference_time_ms=inference_time,
                is_uncertain=is_uncertain,
                image_quality_score=quality_score,
            )
            
            # Cache the result
            await cls.cache_prediction(image_hash, result)
            
            logger.info(
                f"Prediction completed in {inference_time:.2f}ms: "
                f"{disease_name} ({disease_confidence:.2%})"
            )
            
            return result
            
        except MLServiceException:
            raise
        except Exception as e:
            logger.error(f"Prediction failed: {e}", exc_info=True)
            raise MLServiceException(f"Prediction failed: {str(e)}")

    @classmethod
    async def predict_batch(cls, images: List[bytes]) -> List[MLPredictionResult]:
        """
        Predict diseases for multiple images in batch.
        
        Args:
            images: List of raw image bytes
        
        Returns:
            List of MLPredictionResult, one per image
        
        Raises:
            MLServiceException: If batch prediction fails
        """
        try:
            # For now, process sequentially to reuse caching logic
            # TODO: Implement true batch processing for uncached images
            results = []
            for image_bytes in images:
                result = await cls.predict_disease(image_bytes)
                results.append(result)
            return results
            
        except Exception as e:
            logger.error(f"Batch prediction failed: {e}")
            raise MLServiceException(f"Batch prediction failed: {str(e)}")

    @classmethod
    async def get_model_status(cls) -> dict:
        """
        Get current model status for health checks.
        
        Returns:
            Dictionary with model status information
        """
        try:
            if cls._model is None:
                return {
                    "status": "not_loaded",
                    "model_version": settings.ML_MODEL_VERSION,
                    "device": settings.ML_DEVICE,
                    "classes_count": 0,
                    "is_placeholder": False,
                }
            
            return {
                "status": "ready",
                "model_version": settings.ML_MODEL_VERSION,
                "device": str(cls._model.device),
                "classes_count": len(cls._model.get_disease_classes()),
                "is_placeholder": cls._model.is_placeholder_mode(),
            }
            
        except Exception as e:
            logger.error(f"Failed to get model status: {e}")
            return {
                "status": "error",
                "error": str(e),
                "model_version": settings.ML_MODEL_VERSION,
                "device": settings.ML_DEVICE,
            }


# Singleton instance
ml_service = MLService()
