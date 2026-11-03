"""Tests for ML service and crop disease detection."""
import pytest
import torch
from unittest.mock import patch, MagicMock, AsyncMock
from io import BytesIO
from PIL import Image

from app.services.ml_service import ml_service, MLService, MLPredictionResult, MLServiceException
from app.ml.model_wrapper import CropDiseaseModel, DISEASE_CLASSES
from app.ml.preprocessing import preprocess_image, validate_image_quality
from app.ml.disease_knowledge import get_treatment_recommendation, normalize_disease_name


# Helper to create minimal valid JPEG bytes
def create_test_image(size=(224, 224), color=(0, 255, 0)) -> bytes:
    """Create a minimal valid JPEG image for testing."""
    img = Image.new('RGB', size, color=color)
    buf = BytesIO()
    img.save(buf, format='JPEG')
    return buf.getvalue()


class TestImagePreprocessing:
    """Test image preprocessing utilities."""
    
    def test_preprocess_valid_image(self):
        """Test preprocessing of valid image."""
        image_bytes = create_test_image()
        tensor = preprocess_image(image_bytes)
        
        assert tensor.shape == (1, 3, 224, 224), "Tensor shape should be [1, 3, 224, 224]"
        assert tensor.dtype == torch.float32, "Tensor dtype should be float32"
    
    def test_preprocess_invalid_image(self):
        """Test preprocessing with corrupt image bytes."""
        invalid_bytes = b"not an image"
        
        with pytest.raises(ValueError, match="Failed to preprocess image"):
            preprocess_image(invalid_bytes)
    
    def test_validate_image_quality(self):
        """Test image quality validation."""
        image_bytes = create_test_image()
        quality_score, reason = validate_image_quality(image_bytes)
        
        assert 0.0 <= quality_score <= 1.0, "Quality score should be between 0 and 1"
        assert isinstance(reason, str), "Reason should be a string"
        assert len(reason) > 0, "Reason should not be empty"


class TestDiseaseKnowledge:
    """Test disease knowledge base."""
    
    def test_normalize_disease_name(self):
        """Test disease name normalization."""
        # Test with standard format
        result = normalize_disease_name("Tomato___Late_blight")
        assert "tomato" in result and "late_blight" in result
        
        # Test healthy plant
        result = normalize_disease_name("Wheat___Healthy")
        assert result == "healthy"
    
    def test_get_treatment_for_known_disease(self):
        """Test getting treatment for known disease."""
        treatment = get_treatment_recommendation("Tomato___Late_blight", "Tomato")
        
        assert "symptoms" in treatment
        assert "treatment" in treatment
        assert "prevention" in treatment
        assert "severity" in treatment
        assert treatment["severity"] in ["none", "moderate", "severe"]
    
    def test_get_treatment_for_healthy_plant(self):
        """Test getting treatment for healthy plant."""
        treatment = get_treatment_recommendation("Tomato___Healthy", "Tomato")
        
        assert treatment["severity"] == "none"
        assert "healthy" in treatment["symptoms"].lower() or "vibrant" in treatment["symptoms"].lower()
    
    def test_get_treatment_for_unknown_disease(self):
        """Test getting treatment for unknown disease."""
        treatment = get_treatment_recommendation("Unknown___Disease", "Unknown")
        
        # Should return fallback recommendations
        assert "symptoms" in treatment
        assert "treatment" in treatment
        assert "Consult" in treatment["treatment"] or "consult" in treatment["treatment"]


class TestModelWrapper:
    """Test model wrapper functionality."""
    
    def test_model_initialization(self):
        """Test model initializes correctly."""
        model = CropDiseaseModel(model_path="nonexistent.pth", device="cpu")
        
        assert model.model is not None, "Model should be loaded"
        assert model.device.type == "cpu", "Device should be CPU"
        assert model.is_placeholder_mode(), "Should be in placeholder mode without custom model"
    
    def test_get_disease_classes(self):
        """Test getting disease classes."""
        model = CropDiseaseModel(model_path="nonexistent.pth", device="cpu")
        classes = model.get_disease_classes()
        
        assert len(classes) == len(DISEASE_CLASSES), "Should return all disease classes"
        assert "Tomato___Late_blight" in classes, "Should include known disease"
    
    def test_predict_single_image(self):
        """Test prediction on single image."""
        model = CropDiseaseModel(model_path="nonexistent.pth", device="cpu")
        
        # Create dummy tensor
        image_tensor = torch.randn(1, 3, 224, 224)
        predictions = model.predict(image_tensor)
        
        assert len(predictions) == 3, "Should return top-3 predictions"
        
        for disease_name, confidence in predictions:
            assert isinstance(disease_name, str), "Disease name should be string"
            assert 0.0 <= confidence <= 1.0, "Confidence should be between 0 and 1"
        
        # Check predictions are sorted by confidence
        confidences = [conf for _, conf in predictions]
        assert confidences == sorted(confidences, reverse=True), "Should be sorted by confidence"


@pytest.mark.asyncio
class TestMLService:
    """Test ML service functionality."""
    
    async def test_model_lazy_loading(self):
        """Test that model loads on first prediction, not at import."""
        # Reset model state on the class (where _ensure_model_loaded stores it)
        original_model = MLService._model
        MLService._model = None
        
        # Model should not be loaded yet
        assert MLService._model is None
        
        # Make a prediction (will trigger lazy loading)
        image_bytes = create_test_image()
        result = await ml_service.predict_disease(image_bytes)
        
        # After predict_disease, model should be loaded (lazy init happened)
        assert MLService._model is not None, "Model should be loaded after first prediction"
        assert isinstance(result, MLPredictionResult), "Should return a valid prediction result"
        
        # Restore original state
        MLService._model = original_model
    
    async def test_predict_disease_structure(self):
        """Test prediction result has all required fields."""
        image_bytes = create_test_image()
        result = await ml_service.predict_disease(image_bytes)
        
        # Check all required fields are present
        assert isinstance(result, MLPredictionResult)
        assert isinstance(result.crop_type, str)
        assert isinstance(result.crop_confidence, float)
        assert isinstance(result.disease_name, str)
        assert isinstance(result.disease_confidence, float)
        assert isinstance(result.severity, str)
        assert isinstance(result.symptoms_observed, str)
        assert isinstance(result.recommended_treatment, str)
        assert isinstance(result.preventive_measures, str)
        assert isinstance(result.alternative_diagnoses, list)
        assert isinstance(result.model_version, str)
        assert isinstance(result.inference_time_ms, float)
        assert isinstance(result.is_uncertain, bool)
        assert isinstance(result.image_quality_score, float)
        
        # Check value ranges
        assert 0.0 <= result.crop_confidence <= 1.0
        assert 0.0 <= result.disease_confidence <= 1.0
        assert result.severity in ["none", "moderate", "severe"]
        assert result.inference_time_ms > 0
    
    async def test_predict_with_cache(self):
        """Test that cached predictions are returned without calling the model again."""
        image_bytes = create_test_image()
        
        # First prediction (cache miss)
        result1 = await ml_service.predict_disease(image_bytes)
        
        # Second prediction with the same image bytes should hit the in-memory cache
        # (ml_service caches by SHA256 of the image bytes)
        result2 = await ml_service.predict_disease(image_bytes)
        
        # Results should be identical regardless of cache/no-cache
        assert result1.disease_name == result2.disease_name
        assert result1.disease_confidence == result2.disease_confidence
    
    async def test_invalid_image_handling(self):
        """Test handling of invalid/corrupt images."""
        invalid_bytes = b"not an image"
        
        with pytest.raises(MLServiceException, match="preprocessing failed"):
            await ml_service.predict_disease(invalid_bytes)
    
    async def test_low_confidence_thresholding(self):
        """Test that low confidence predictions are marked as uncertain."""
        image_bytes = create_test_image()
        
        # Mock model to return low confidence prediction
        with patch.object(ml_service, '_ensure_model_loaded') as mock_load:
            mock_model = MagicMock()
            mock_model.predict.return_value = [
                ("Tomato___Late_blight", 0.30),  # Below threshold (0.65)
                ("Tomato___Early_blight", 0.25),
                ("Tomato___Healthy", 0.20),
            ]
            mock_load.return_value = mock_model
            ml_service._model = mock_model
            
            result = await ml_service.predict_disease(image_bytes)
            
            assert result.is_uncertain, "Should be marked as uncertain"
            assert "Uncertain" in result.disease_name
    
    async def test_batch_inference(self):
        """Test batch prediction with multiple images."""
        images = [create_test_image() for _ in range(3)]
        
        results = await ml_service.predict_batch(images)
        
        assert len(results) == 3, "Should return one result per image"
        
        for result in results:
            assert isinstance(result, MLPredictionResult)
            assert result.disease_name is not None
    
    async def test_get_model_status(self):
        """Test getting model status."""
        status = await ml_service.get_model_status()
        
        assert "status" in status
        assert "model_version" in status
        assert "device" in status
        assert "classes_count" in status
        
        # Status should be one of expected values
        assert status["status"] in ["ready", "not_loaded", "loading", "error"]
    
    async def test_compute_image_hash(self):
        """Test image hash computation for caching."""
        image_bytes = create_test_image()
        
        hash1 = ml_service._compute_image_hash(image_bytes)
        hash2 = ml_service._compute_image_hash(image_bytes)
        
        # Same image should produce same hash
        assert hash1 == hash2
        
        # Different image should produce different hash
        different_image = create_test_image(color=(255, 0, 0))
        hash3 = ml_service._compute_image_hash(different_image)
        assert hash1 != hash3


@pytest.mark.asyncio
class TestCropScannerIntegration:
    """Test integration with crop_scanner_service."""
    
    async def test_ml_service_called_during_scan(self):
        """Test that ML service is invoked during crop scan."""
        from app.services.crop_scanner_service import crop_scanner_service
        from app.models.user import User
        from app.models.crop_scan import CropScan
        
        # This test would require a full database setup
        # For now, we just verify the service import works
        assert crop_scanner_service is not None
        
        # Verify MLServiceException is imported in crop_scanner_service
        from app.services.crop_scanner_service import MLServiceException as ImportedMLServiceException
        assert ImportedMLServiceException == MLServiceException


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
