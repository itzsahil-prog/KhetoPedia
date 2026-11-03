"""
Pytest configuration and fixtures for Khetopedia backend tests.
"""
import pytest
from app.core.database import init_db


@pytest.fixture(autouse=True)
async def setup_database():
    """Ensure database tables are initialized before tests execute."""
    await init_db()
