"""PyTorch model wrapper for crop disease classification."""
import os
import logging
from typing import List, Tuple, Optional
import torch
import torch.nn as nn
from torchvision import models
from torchvision.models import ResNet50_Weights

logger = logging.getLogger(__name__)


# 51 crop disease classes (PlantVillage-style taxonomy)
DISEASE_CLASSES = [
    "Apple___Apple_scab",
    "Apple___Black_rot",
    "Apple___Cedar_apple_rust",
    "Apple___Healthy",
    "Blueberry___Healthy",
    "Cherry_(including_sour)___Powdery_mildew",
    "Cherry_(including_sour)___Healthy",
    "Corn_(maize)___Cercospora_leaf_spot_Gray_leaf_spot",
    "Corn_(maize)___Common_rust_",
    "Corn_(maize)___Northern_Leaf_Blight",
    "Corn_(maize)___Healthy",
    "Grape___Black_rot",
    "Grape___Esca_(Black_Measles)",
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)",
    "Grape___Healthy",
    "Orange___Haunglongbing_(Citrus_greening)",
    "Peach___Bacterial_spot",
    "Peach___Healthy",
    "Pepper,_bell___Bacterial_spot",
    "Pepper,_bell___Healthy",
    "Potato___Early_blight",
    "Potato___Late_blight",
    "Potato___Healthy",
    "Raspberry___Healthy",
    "Rice___Bacterial_Leaf_Blight",
    "Rice___Brown_Spot",
    "Rice___Leaf_Blast",
    "Rice___Healthy",
    "Soybean___Healthy",
    "Squash___Powdery_mildew",
    "Strawberry___Leaf_scorch",
    "Strawberry___Healthy",
    "Tomato___Bacterial_spot",
    "Tomato___Early_blight",
    "Tomato___Late_blight",
    "Tomato___Leaf_Mold",
    "Tomato___Septoria_leaf_spot",
    "Tomato___Spider_mites_Two-spotted_spider_mite",
    "Tomato___Target_Spot",
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "Tomato___Tomato_mosaic_virus",
    "Tomato___Healthy",
    "Wheat___Brown_Rust",
    "Wheat___Yellow_Rust",
    "Wheat___Healthy",
    "Cotton___Leaf_Curl_Virus",
    "Cotton___Healthy",
    "Sugarcane___Red_Rot",
    "Sugarcane___Healthy",
    "Mango___Anthracnose",
    "Mango___Healthy",
]


class CropDiseaseModel:
    """Wrapper for crop disease classification model."""

    def __init__(self, model_path: str, device: str = "cpu"):
        """
        Initialize the model.

        Args:
            model_path: Path to model weights file (.pth)
            device: Device to run inference on ("cpu" or "cuda")
        """
        self.model_path = model_path
        self.device = torch.device(device if torch.cuda.is_available() else "cpu")
        self.num_classes = len(DISEASE_CLASSES)
        self.model: Optional[nn.Module] = None
        self._is_placeholder = False

        self._load_model()

    def _load_model(self) -> None:
        """Load the PyTorch model from file or use pre-trained placeholder."""
        try:
            # Try loading custom trained model
            if os.path.exists(self.model_path):
                logger.info(f"Loading custom model from {self.model_path}")
                model = models.resnet50(weights=None)
                model.fc = nn.Linear(model.fc.in_features, self.num_classes)
                state_dict = torch.load(self.model_path, map_location=self.device)
                model.load_state_dict(state_dict)
                model.eval()
                self.model = model.to(self.device)
                logger.info(f"Custom model loaded successfully on {self.device}")
            else:
                # Use pre-trained ResNet50 as placeholder
                logger.warning(
                    f"Model file not found at {self.model_path}. "
                    "Using pre-trained ResNet50 placeholder for development."
                )
                model = models.resnet50(weights=ResNet50_Weights.IMAGENET1K_V2)
                # Replace final layer to match our disease classes
                model.fc = nn.Linear(model.fc.in_features, self.num_classes)
                model.eval()
                self.model = model.to(self.device)
                self._is_placeholder = True
                logger.info(f"Placeholder model loaded on {self.device}")

        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            # Fallback to basic ResNet50
            logger.info("Loading fallback ResNet50 model")
            model = models.resnet50(weights=ResNet50_Weights.IMAGENET1K_V2)
            model.fc = nn.Linear(model.fc.in_features, self.num_classes)
            model.eval()
            self.model = model.to(self.device)
            self._is_placeholder = True

    def predict(self, image_tensor: torch.Tensor) -> List[Tuple[str, float]]:
        """
        Run inference on a single image.

        Args:
            image_tensor: Preprocessed image tensor [1, 3, 224, 224]

        Returns:
            List of (disease_name, confidence) tuples, sorted by confidence (top 3)
        """
        if self.model is None:
            raise RuntimeError("Model not loaded")

        try:
            with torch.no_grad():
                image_tensor = image_tensor.to(self.device)
                outputs = self.model(image_tensor)
                probabilities = torch.nn.functional.softmax(outputs, dim=1)
                top_probs, top_indices = torch.topk(probabilities, k=min(3, self.num_classes))

                results = []
                for prob, idx in zip(top_probs[0], top_indices[0]):
                    disease_name = DISEASE_CLASSES[idx.item()]
                    confidence = prob.item()
                    results.append((disease_name, confidence))

                # If using placeholder model, slightly reduce confidence
                if self._is_placeholder:
                    results = [(name, conf * 0.85) for name, conf in results]

                return results

        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            raise

    def predict_batch(self, image_tensors: List[torch.Tensor]) -> List[List[Tuple[str, float]]]:
        """
        Run batch inference on multiple images.

        Args:
            image_tensors: List of preprocessed image tensors

        Returns:
            List of prediction results, one per image
        """
        if self.model is None:
            raise RuntimeError("Model not loaded")

        try:
            # Stack tensors into batch
            batch = torch.stack(image_tensors).to(self.device)

            with torch.no_grad():
                outputs = self.model(batch)
                probabilities = torch.nn.functional.softmax(outputs, dim=1)

                results = []
                for probs in probabilities:
                    top_probs, top_indices = torch.topk(probs, k=min(3, self.num_classes))
                    predictions = []
                    for prob, idx in zip(top_probs, top_indices):
                        disease_name = DISEASE_CLASSES[idx.item()]
                        confidence = prob.item()
                        if self._is_placeholder:
                            confidence *= 0.85
                        predictions.append((disease_name, confidence))
                    results.append(predictions)

                return results

        except Exception as e:
            logger.error(f"Batch prediction failed: {e}")
            raise

    def get_disease_classes(self) -> List[str]:
        """Return list of supported disease class names."""
        return DISEASE_CLASSES.copy()

    def is_placeholder_mode(self) -> bool:
        """Return whether model is running in placeholder mode."""
        return self._is_placeholder
