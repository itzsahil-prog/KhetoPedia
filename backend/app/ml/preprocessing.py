"""Image preprocessing utilities for crop disease detection."""
import io
import logging
from typing import Tuple, List, Optional
import torch
from PIL import Image
import numpy as np
from torchvision import transforms

logger = logging.getLogger(__name__)

# ImageNet normalization statistics
IMAGENET_MEAN = [0.485, 0.456, 0.406]
IMAGENET_STD = [0.229, 0.224, 0.225]

# Standard preprocessing pipeline
preprocess_transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=IMAGENET_MEAN, std=IMAGENET_STD),
])


def preprocess_image(image_bytes: bytes) -> torch.Tensor:
    """
    Preprocess image bytes for model inference.

    Args:
        image_bytes: Raw image bytes (JPEG, PNG, etc.)

    Returns:
        Preprocessed image tensor [1, 3, 224, 224]

    Raises:
        ValueError: If image cannot be loaded or processed
    """
    try:
        # Load image from bytes
        image = Image.open(io.BytesIO(image_bytes))

        # Convert to RGB (handles grayscale and RGBA)
        if image.mode != "RGB":
            image = image.convert("RGB")

        # Apply preprocessing transforms
        tensor = preprocess_transform(image)

        # Add batch dimension
        tensor = tensor.unsqueeze(0)

        return tensor

    except Exception as e:
        logger.error(f"Image preprocessing failed: {e}")
        raise ValueError(f"Failed to preprocess image: {str(e)}")


def preprocess_batch(image_bytes_list: List[bytes]) -> torch.Tensor:
    """
    Preprocess multiple images into a batch.

    Args:
        image_bytes_list: List of raw image bytes

    Returns:
        Batched tensor [batch_size, 3, 224, 224]

    Raises:
        ValueError: If any image cannot be processed
    """
    try:
        tensors = []
        for image_bytes in image_bytes_list:
            # Process each image (returns [1, 3, 224, 224])
            tensor = preprocess_image(image_bytes)
            # Remove batch dimension for stacking
            tensors.append(tensor.squeeze(0))

        # Stack into batch
        batch_tensor = torch.stack(tensors)
        return batch_tensor

    except Exception as e:
        logger.error(f"Batch preprocessing failed: {e}")
        raise ValueError(f"Failed to preprocess batch: {str(e)}")


def validate_image_quality(image_bytes: bytes) -> Tuple[float, str]:
    """
    Validate image quality using blur detection.

    Uses Laplacian variance to detect blur. Higher values indicate sharper images.

    Args:
        image_bytes: Raw image bytes

    Returns:
        Tuple of (quality_score, reason)
        - quality_score: 0.0-1.0, higher is better
        - reason: Description of quality assessment

    Raises:
        ValueError: If image cannot be loaded
    """
    try:
        # Load image
        image = Image.open(io.BytesIO(image_bytes))

        # Convert to grayscale for blur detection
        if image.mode != "L":
            image = image.convert("L")

        # Convert to numpy array
        img_array = np.array(image)

        # Calculate Laplacian variance (blur detection)
        # Using simple convolution approximation
        laplacian = np.array([[0, 1, 0], [1, -4, 1], [0, 1, 0]])

        # Calculate variance of Laplacian
        from scipy import ndimage
        try:
            laplacian_result = ndimage.convolve(img_array.astype(float), laplacian)
            variance = laplacian_result.var()
        except ImportError:
            # Fallback if scipy not available - use simple edge detection
            variance = np.var(np.diff(img_array, axis=0)) + np.var(np.diff(img_array, axis=1))

        # Normalize variance to quality score (0-1)
        # Typical sharp images have variance > 100, blurry images < 50
        if variance < 30:
            quality_score = 0.3
            reason = "Image is very blurry. Please capture a sharper photo."
        elif variance < 50:
            quality_score = 0.5
            reason = "Image quality is poor. Consider capturing in better lighting."
        elif variance < 100:
            quality_score = 0.7
            reason = "Image quality is acceptable."
        else:
            quality_score = 0.9
            reason = "Image quality is good."

        logger.debug(f"Image quality: variance={variance:.2f}, score={quality_score:.2f}")
        return quality_score, reason

    except Exception as e:
        logger.warning(f"Quality validation failed: {e}")
        # Return neutral quality score if validation fails
        return 0.75, "Quality validation unavailable"


def check_image_dimensions(image_bytes: bytes) -> Tuple[int, int]:
    """
    Check original image dimensions.

    Args:
        image_bytes: Raw image bytes

    Returns:
        Tuple of (width, height)
    """
    try:
        image = Image.open(io.BytesIO(image_bytes))
        return image.size
    except Exception as e:
        logger.error(f"Failed to read image dimensions: {e}")
        raise ValueError(f"Invalid image: {str(e)}")
