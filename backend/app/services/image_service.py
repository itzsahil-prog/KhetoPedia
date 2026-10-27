import os
from typing import List, Tuple, Optional
import magic
from fastapi import HTTPException, status
from app.services.storage_service import storage_service


class ImageService:
    """Image validation and upload orchestration."""

    # MIME type whitelist
    ALLOWED_TYPES = ["image/jpeg", "image/png", "image/webp"]

    # Size limits
    MIN_SIZE_BYTES = 5 * 1024  # 5 KB
    MAX_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB

    @staticmethod
    def validate_image(
        file_bytes: bytes, filename: str
    ) -> Tuple[bool, Optional[str], Optional[str]]:
        """
        Validate image file.

        Returns:
            (is_valid, mime_type, error_message)
        """
        # Check size
        file_size = len(file_bytes)
        if file_size < ImageService.MIN_SIZE_BYTES:
            return False, None, f"Image too small (minimum {ImageService.MIN_SIZE_BYTES // 1024}KB)"
        if file_size > ImageService.MAX_SIZE_BYTES:
            return False, None, f"Image too large (maximum {ImageService.MAX_SIZE_BYTES // (1024 * 1024)}MB)"

        # Detect MIME type using magic (not just extension)
        try:
            mime = magic.from_buffer(file_bytes, mime=True)
        except Exception as e:
            return False, None, f"Could not detect file type: {str(e)}"

        # Validate MIME type
        if mime not in ImageService.ALLOWED_TYPES:
            return False, mime, f"Invalid image type '{mime}'. Allowed: {', '.join(ImageService.ALLOWED_TYPES)}"

        return True, mime, None

    @staticmethod
    async def upload_image(
        file_bytes: bytes, filename: str, category: str, user_id: str
    ) -> str:
        """
        Validate and upload image.

        Args:
            file_bytes: Image file bytes
            filename: Original filename (for extension)
            category: Storage category (crops, soil, etc.)
            user_id: User ID for directory sharding

        Returns:
            URL or relative path to uploaded image

        Raises:
            HTTPException: If validation fails
        """
        # Validate
        is_valid, mime_type, error_msg = ImageService.validate_image(file_bytes, filename)
        if not is_valid:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=error_msg or "Invalid image"
            )

        # Extract extension
        extension = os.path.splitext(filename)[1].lower()
        if not extension:
            # Infer from MIME type
            ext_map = {
                "image/jpeg": ".jpg",
                "image/png": ".png",
                "image/webp": ".webp",
            }
            extension = ext_map.get(mime_type, ".jpg")

        # Upload via storage service
        try:
            url = await storage_service.upload(file_bytes, category, user_id, extension)
            return url
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Image upload failed: {str(e)}"
            )


image_service = ImageService()
