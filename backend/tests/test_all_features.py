"""
Integration tests for: Users/Profile, Farms, Fields, Soil, Crop Scans,
Recommendations, AI Assistant, Sensors, and Weather endpoints.
Each test creates a fresh user so tests are fully independent and repeatable.
"""
import io
import uuid
import pytest
from httpx import AsyncClient, ASGITransport

from app.main import app


# ── Helpers ───────────────────────────────────────────────────────────────────

def unique_email() -> str:
    return f"test.farmer.{uuid.uuid4().hex[:8]}@example.com"


async def register_and_login(client: AsyncClient) -> tuple[str, str]:
    """Register a fresh user and return (access_token, email)."""
    email = unique_email()
    res = await client.post("/v1/auth/signup", json={
        "name": "Test Farmer",
        "email": email,
        "password": "TestPass123!",
        "phone": "+919800000001",
        "preferred_locale": "en",
    })
    assert res.status_code == 201, res.text
    return res.json()["access_token"], email


def auth_headers(token: str) -> dict:
    return {"Authorization": f"Bearer {token}"}


# ── Profile & Settings ────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_profile_get_and_update():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, email = await register_and_login(client)
        h = auth_headers(token)

        # GET profile
        res = await client.get("/v1/users/profile", headers=h)
        assert res.status_code == 200, res.text
        data = res.json()
        assert data["user_email"] == email
        assert "farm_count" in data

        # UPDATE profile
        res = await client.put("/v1/users/profile", headers=h, json={
            "name": "Ramesh Kumar Updated",
            "village": "Khalipur",
            "district": "Hapur",
            "state": "Uttar Pradesh",
            "primary_crops": "Wheat, Sugarcane",
            "farming_experience_years": 12,
        })
        assert res.status_code == 200, res.text
        updated = res.json()
        assert updated["user_name"] == "Ramesh Kumar Updated"
        assert updated["district"] == "Hapur"


@pytest.mark.asyncio
async def test_change_password():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, email = await register_and_login(client)
        h = auth_headers(token)

        # Wrong current password → 400
        res = await client.put("/v1/users/change-password", headers=h, json={
            "current_password": "WrongPassword!",
            "new_password": "NewPassword456!",
        })
        assert res.status_code == 400

        # Correct current password → 200
        res = await client.put("/v1/users/change-password", headers=h, json={
            "current_password": "TestPass123!",
            "new_password": "NewPassword456!",
        })
        assert res.status_code == 200

        # Login with new password
        res = await client.post("/v1/auth/login", json={"email": email, "password": "NewPassword456!"})
        assert res.status_code == 200


@pytest.mark.asyncio
async def test_user_settings():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        res = await client.get("/v1/users/settings", headers=h)
        assert res.status_code == 200
        assert "theme_mode" in res.json()

        res = await client.put("/v1/users/settings", headers=h, json={
            "theme_mode": "dark",
            "font_size": "large",
            "disease_alerts_enabled": False,
        })
        assert res.status_code == 200
        data = res.json()
        assert data["theme_mode"] == "dark"
        assert data["font_size"] == "large"
        assert data["disease_alerts_enabled"] is False


# ── Farms & Fields ────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_farm_and_field_crud():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        # Create farm
        res = await client.post("/v1/farms", headers=h, json={
            "name": "Green Valley Farm",
            "location": "Panipat, Haryana",
            "total_area_acres": 12.5,
            "soil_type": "Clay Loam",
            "irrigation_source": "Borewell",
        })
        assert res.status_code == 201, res.text
        farm = res.json()
        farm_id = farm["id"]
        assert farm["name"] == "Green Valley Farm"

        # List farms
        res = await client.get("/v1/farms", headers=h)
        assert res.status_code == 200
        assert any(f["id"] == farm_id for f in res.json())

        # Get farm
        res = await client.get(f"/v1/farms/{farm_id}", headers=h)
        assert res.status_code == 200
        assert res.json()["total_area_acres"] == 12.5

        # Update farm
        res = await client.put(f"/v1/farms/{farm_id}", headers=h, json={"notes": "Primary wheat plot"})
        assert res.status_code == 200
        assert res.json()["notes"] == "Primary wheat plot"

        # Create field
        res = await client.post("/v1/farms/fields", headers=h, json={
            "name": "North Plot A",
            "crop_name": "Wheat (PBW 343)",
            "acreage": 3.0,
            "location_name": "Sector 7",
            "health_score": 82,
        })
        assert res.status_code == 201, res.text
        field = res.json()
        field_id = field["id"]

        # List all fields
        res = await client.get("/v1/farms/fields/all", headers=h)
        assert res.status_code == 200
        assert any(f["id"] == field_id for f in res.json())

        # Get field
        res = await client.get(f"/v1/farms/fields/{field_id}", headers=h)
        assert res.status_code == 200

        # Update field
        res = await client.put(f"/v1/farms/fields/{field_id}", headers=h, json={"health_score": 90})
        assert res.status_code == 200
        assert res.json()["health_score"] == 90

        # Delete field
        res = await client.delete(f"/v1/farms/fields/{field_id}", headers=h)
        assert res.status_code == 200

        # Delete farm
        res = await client.delete(f"/v1/farms/{farm_id}", headers=h)
        assert res.status_code == 200

        # Verify farm gone
        res = await client.get(f"/v1/farms/{farm_id}", headers=h)
        assert res.status_code == 404


# ── Soil Analysis ─────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_soil_test_healthy():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        res = await client.post("/v1/soil/tests", headers=h, json={
            "ph": 6.8,
            "source": "laboratory",
            "ec_ds_m": 1.2,
            "moisture_percentage": 42.0,
            "nitrogen_kg_ha": 350.0,
            "phosphorus_kg_ha": 20.0,
            "potassium_kg_ha": 180.0,
            "laboratory_name": "IARI Soil Lab",
        })
        assert res.status_code == 201, res.text
        data = res.json()
        assert data["soil_condition"] == "Healthy"
        assert data["toxicity_level"] == "Green"
        assert "evaluation_summary" in data

        test_id = data["id"]

        # Get specific test
        res = await client.get(f"/v1/soil/tests/{test_id}", headers=h)
        assert res.status_code == 200


@pytest.mark.asyncio
async def test_soil_test_critical_toxicity():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        # Critically high lead
        res = await client.post("/v1/soil/tests", headers=h, json={
            "ph": 6.5,
            "source": "laboratory",
            "lead_mg_kg": 150.0,  # > 100 mg/kg threshold → RED
            "cadmium_mg_kg": 0.5,
        })
        assert res.status_code == 201
        data = res.json()
        assert data["toxicity_level"] == "Red"
        assert data["soil_condition"] == "Critical"
        assert "150" in data["evaluation_summary"]


@pytest.mark.asyncio
async def test_soil_test_acid_soil():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        res = await client.post("/v1/soil/tests", headers=h, json={
            "ph": 4.8,
            "source": "manual",
        })
        assert res.status_code == 201
        data = res.json()
        assert data["soil_condition"] == "Attention"
        assert "4.8" in data["evaluation_summary"]


@pytest.mark.asyncio
async def test_soil_summary():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        # Create a field first
        res = await client.post("/v1/farms/fields", headers=h, json={
            "name": "Test Field", "crop_name": "Rice", "acreage": 2.0
        })
        field_id = res.json()["id"]

        # Submit soil test for field
        await client.post("/v1/soil/tests", headers=h, json={
            "ph": 7.0, "source": "manual", "field_id": field_id,
            "nitrogen_kg_ha": 200.0, "phosphorus_kg_ha": 18.0, "potassium_kg_ha": 150.0,
        })

        # Get summary
        res = await client.get(f"/v1/soil/summary/{field_id}", headers=h)
        assert res.status_code == 200
        data = res.json()
        assert data["field_id"] == field_id
        assert "npk_status" in data
        assert "Nitrogen (N)" in data["npk_status"]


# ── Crop AI Scanner ───────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_crop_scan_upload():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        # Create a minimal valid JPEG payload (~15KB of zeros — enough to pass size check)
        fake_image = b"\xff\xd8\xff\xe0" + b"\x00" * 15000  # JPEG magic + padding
        files = {"file": ("wheat_leaf.jpg", io.BytesIO(fake_image), "image/jpeg")}

        res = await client.post("/v1/crop-scans", headers=h, data={"crop_hint": "wheat"}, files=files)
        assert res.status_code == 201, res.text
        data = res.json()
        assert "crop_identified" in data
        assert "disease_name" in data
        assert "severity" in data
        assert "recommended_treatment" in data

        scan_id = data["id"]

        # Get specific scan
        res = await client.get(f"/v1/crop-scans/{scan_id}", headers=h)
        assert res.status_code == 200

        # List scans
        res = await client.get("/v1/crop-scans", headers=h)
        assert res.status_code == 200
        assert any(s["id"] == scan_id for s in res.json()["scans"])


@pytest.mark.asyncio
async def test_crop_scan_invalid_extension():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        files = {"file": ("virus.exe", io.BytesIO(b"malicious" * 2000), "application/octet-stream")}
        res = await client.post("/v1/crop-scans", headers=h, files=files)
        assert res.status_code == 400


# ── Recommendations ───────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_generate_recommendations():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        # Create a field with low health score to trigger disease management recommendation
        res = await client.post("/v1/farms/fields", headers=h, json={
            "name": "Wheat Plot", "crop_name": "Wheat", "acreage": 4.0,
            "health_score": 65, "water_status": "Needs Irrigation",
        })
        field_id = res.json()["id"]

        res = await client.post(f"/v1/recommendations/generate/{field_id}", headers=h, json={
            "crop_stage": "Tillering",
        })
        assert res.status_code == 201, res.text
        recs = res.json()
        assert len(recs) >= 2
        categories = {r["category"] for r in recs}
        assert "irrigation" in categories
        assert "fertilizer" in categories

        rec_id = recs[0]["id"]

        # Get specific recommendation
        res = await client.get(f"/v1/recommendations/{rec_id}", headers=h)
        assert res.status_code == 200

        # List all
        res = await client.get("/v1/recommendations", headers=h)
        assert res.status_code == 200
        assert any(r["id"] == rec_id for r in res.json())


# ── AI Assistant ──────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_ai_chat():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        # General query
        res = await client.post("/v1/ai/chat", headers=h, json={
            "message": "What fertilizer should I use for wheat?",
            "preferred_language": "en",
        })
        assert res.status_code == 200, res.text
        data = res.json()
        assert "conversation_id" in data
        assert len(data["reply"]) > 10
        assert isinstance(data["suggested_actions"], list)

        conv_id = data["conversation_id"]

        # Follow-up in same conversation
        res = await client.post("/v1/ai/chat", headers=h, json={
            "message": "When should I irrigate?",
            "conversation_id": conv_id,
        })
        assert res.status_code == 200
        assert res.json()["conversation_id"] == conv_id

        # List conversations
        res = await client.get("/v1/ai/conversations", headers=h)
        assert res.status_code == 200
        convs = res.json()
        assert any(c["id"] == conv_id for c in convs)

        # Get full conversation with messages
        res = await client.get(f"/v1/ai/conversations/{conv_id}", headers=h)
        assert res.status_code == 200
        conv_data = res.json()
        assert len(conv_data["messages"]) >= 2  # user + assistant × 2 rounds


@pytest.mark.asyncio
async def test_ai_chat_hindi():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        res = await client.post("/v1/ai/chat", headers=h, json={
            "message": "सिंचाई कब करनी चाहिए?",
            "preferred_language": "hi",
        })
        assert res.status_code == 200
        reply = res.json()["reply"]
        assert len(reply) > 5  # Non-empty Hindi response


# ── IoT Sensors ───────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_sensor_registration_and_readings():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        device_uid = f"SENSOR-{uuid.uuid4().hex[:8].upper()}"

        # Register sensor
        res = await client.post("/v1/sensors/register", headers=h, json={
            "device_uid": device_uid,
            "model_name": "AgriSense ESP32 v2",
        })
        assert res.status_code == 201, res.text
        sensor_id = res.json()["id"]

        # Duplicate registration → 409
        res = await client.post("/v1/sensors/register", headers=h, json={"device_uid": device_uid})
        assert res.status_code == 409

        # List sensors
        res = await client.get("/v1/sensors", headers=h)
        assert res.status_code == 200
        assert any(s["id"] == sensor_id for s in res.json())

        # Submit reading (no user auth needed — device UID is identifier)
        res = await client.post("/v1/sensors/readings", json={
            "device_uid": device_uid,
            "soil_moisture_percentage": 35.5,
            "soil_temperature_celsius": 28.3,
            "ambient_humidity_percentage": 62.0,
            "soil_ph": 6.9,
        })
        assert res.status_code == 201, res.text
        reading = res.json()
        assert reading["soil_moisture_percentage"] == 35.5

        # Submit another reading with critically low moisture
        res = await client.post("/v1/sensors/readings", json={
            "device_uid": device_uid,
            "soil_moisture_percentage": 15.0,  # < 18.0 → should generate alert
        })
        assert res.status_code == 201

        # Get reading history
        res = await client.get(f"/v1/sensors/{sensor_id}/readings", headers=h, params={"limit": 10})
        assert res.status_code == 200
        assert len(res.json()) >= 2

        # Unauthorized device → 401
        res = await client.post("/v1/sensors/readings", json={
            "device_uid": "FAKE-SENSOR-00000000",
            "soil_moisture_percentage": 50.0,
        })
        assert res.status_code == 401


# ── Weather ───────────────────────────────────────────────────────────────────

@pytest.mark.asyncio
async def test_weather_endpoint():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _ = await register_and_login(client)
        h = auth_headers(token)

        res = await client.get("/v1/weather", headers=h, params={"location": "Ludhiana, Punjab"})
        assert res.status_code == 200, res.text
        data = res.json()
        assert "temperature_celsius" in data
        assert "humidity_percentage" in data
        assert "rain_probability_percentage" in data
        assert "advisory" in data
        assert "hourly_forecast" in data
        assert len(data["hourly_forecast"]) > 0
