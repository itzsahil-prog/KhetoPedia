import os
import uuid
from pathlib import Path
from typing import Optional, Tuple
import boto3
from botocore.exceptions import ClientError
from app.core.config import settings


class StorageService:
    """Abstract storage interface supporting S3 and filesystem backends."""

    def __init__(self):
        self.use_s3 = settings.USE_S3
        if self.use_s3:
            self.s3_client = boto3.client(
                "s3",
                endpoint_url=settings.S3_ENDPOINT_URL,
                aws_access_key_id=settings.S3_ACCESS_KEY_ID,
                aws_secret_access_key=settings.S3_SECRET_ACCESS_KEY,
                region_name=settings.S3_REGION,
            )
            self.bucket_name = settings.S3_BUCKET_NAME
            print(f"[Storage] Using S3 backend (bucket: {self.bucket_name})")
        else:
            self.upload_dir = Path("uploads")
            self.upload_dir.mkdir(exist_ok=True)
            print(f"[Storage] Using filesystem backend (dir: {self.upload_dir.absolute()})")

    def generate_file_path(self, category: str, user_id: str, extension: str) -> str:
        """Generate a unique file path with UUID-based randomization."""
        filename = f"{uuid.uuid4().hex}{extension}"
        # Use first 8 chars of user_id for directory sharding
        return f"{category}/{user_id[:8]}/{filename}"

    async def upload(
        self, file_bytes: bytes, category: str, user_id: str, extension: str
    ) -> str:
        """
        Upload file to storage backend.
        
        Returns:
            - S3 URL if USE_S3=true
            - Relative path if USE_S3=false
        """
        file_path = self.generate_file_path(category, user_id, extension)

        if self.use_s3:
            try:
                self.s3_client.put_object(
                    Bucket=self.bucket_name,
                    Key=file_path,
                    Body=file_bytes,
                    ContentType=self._get_content_type(extension),
                )
                # Generate S3 URL
                if settings.S3_ENDPOINT_URL:
                    # MinIO or custom endpoint
                    url = f"{settings.S3_ENDPOINT_URL}/{self.bucket_name}/{file_path}"
                else:
                    # AWS S3
                    url = f"https://{self.bucket_name}.s3.{settings.S3_REGION}.amazonaws.com/{file_path}"
                return url
            except ClientError as e:
                print(f"[Storage] S3 upload failed: {e}")
                raise Exception(f"Storage upload failed: {str(e)}")
        else:
            # Filesystem storage
            full_path = self.upload_dir / file_path
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_bytes(file_bytes)
            return f"/{file_path}"

    async def delete(self, file_path: str) -> bool:
        """Delete file from storage backend."""
        if self.use_s3:
            try:
                # Extract key from URL
                key = file_path.split(f"{self.bucket_name}/")[-1]
                self.s3_client.delete_object(Bucket=self.bucket_name, Key=key)
                return True
            except ClientError as e:
                print(f"[Storage] S3 delete failed: {e}")
                return False
        else:
            # Filesystem delete
            try:
                full_path = self.upload_dir / file_path.lstrip("/")
                if full_path.exists():
                    full_path.unlink()
                    return True
                return False
            except Exception as e:
                print(f"[Storage] Filesystem delete failed: {e}")
                return False

    def _get_content_type(self, extension: str) -> str:
        """Map file extension to MIME type."""
        content_types = {
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg",
            ".png": "image/png",
            ".webp": "image/webp",
            ".gif": "image/gif",
        }
        return content_types.get(extension.lower(), "application/octet-stream")


# Singleton instance
storage_service = StorageService()
