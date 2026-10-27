"""
Complete Integration Test Suite for Khetopedia Backend
Tests all end-to-end flows with real database, Redis (if enabled), and storage.
"""
import io
import uuid
import pytest
from httpx import AsyncClient, ASGITransport

from app.main import app
from app.core.config import settings


# ══════════════════════════════════════════════════════════════════════════════
# HELPERS
# ══════════════════════════════════════════════════════════════════════════════

def unique_email() -> str:
    """Generate unique test email."""
    return f"test.integration.{uuid.uuid4().hex[:8]}@khetopedia.test"


async def create_test_user(client: AsyncClient) -> tuple[str, str, dict]:
    """Create and login a test user. Returns (access_token, refresh_token, user_data)."""
    email = unique_email()
    password = "TestPassword123!"
    
    res = await client.post("/v1/auth/signup", json={
        "name": "Integration Test User",
        "email": email,
        "password": password,
        "phone": "+919800000000",
        "preferred_locale": "en",
    })
    assert res.status_code == 201, res.text
    data = res.json()
    return data["access_token"], data["refresh_token"], data["user"]


def auth_headers(token: str) -> dict:
    """Generate authorization headers."""
    return {"Authorization": f"Bearer {token}"}


def create_test_image(size_kb: int = 15) -> bytes:
    """Create a minimal valid JPEG for testing."""
    # JPEG magic bytes + padding
    return b"\xff\xd8\xff\xe0\x00\x10JFIF" + b"\x00" * (size_kb * 1024)


# ══════════════════════════════════════════════════════════════════════════════
# 1. END-TO-END AUTH FLOW
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_complete_auth_flow():
    """Test complete auth flow: register → login → logout → token refresh → blocklist."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        email = unique_email()
        password = "SecurePass123!"
        
        # 1. Register
        res = await client.post("/v1/auth/signup", json={
            "name": "Test Farmer",
            "email": email,
            "password": password,
            "phone": "+919876543210",
            "preferred_locale": "en",
        })
        assert res.status_code == 201
        signup_data = res.json()
        access_token = signup_data["access_token"]
        refresh_token = signup_data["refresh_token"]
        
        # Verify duplicate signup fails
        res = await client.post("/v1/auth/signup", json={
            "name": "Test Farmer",
            "email": email,
            "password": password,
            "phone": "+919876543210",
        })
        assert res.status_code == 409
        
        # 2. Login
        res = await client.post("/v1/auth/login", json={
            "email": email,
            "password": password,
        })
        assert res.status_code == 200
        login_data = res.json()
        assert "access_token" in login_data
        
        # Verify wrong password fails
        res = await client.post("/v1/auth/login", json={
            "email": email,
            "password": "WrongPassword!",
        })
        assert res.status_code == 401
        
        # 3. Access protected endpoint
        headers = auth_headers(access_token)
        res = await client.get("/v1/auth/me", headers=headers)
        assert res.status_code == 200
        assert res.json()["email"] == email
        
        # 4. Token refresh
        res = await client.post("/v1/auth/refresh", json={"refresh_token": refresh_token})
        assert res.status_code == 200
        new_tokens = res.json()
        new_access_token = new_tokens["access_token"]
        new_refresh_token = new_tokens["refresh_token"]
        
        # 5. Use new token
        res = await client.get("/v1/auth/me", headers=auth_headers(new_access_token))
        assert res.status_code == 200
        
        # 6. Logout (blocklist token if Redis enabled)
        res = await client.post("/v1/auth/logout", headers=auth_headers(new_access_token))
        assert res.status_code == 200
        
        # 7. Verify logged-out token is blocked (only if Redis is enabled)
        if settings.USE_REDIS:
            res = await client.get("/v1/auth/me", headers=auth_headers(new_access_token))
            assert res.status_code == 401  # Token should be blocklisted


# ══════════════════════════════════════════════════════════════════════════════
# 2. COMPLETE CROP SCANNER FLOW
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_complete_crop_scanner_flow():
    """Test: upload image → ML inference → save to DB → retrieve history."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Upload crop image for scanning
        image_data = create_test_image(20)
        files = {"file": ("wheat_leaf.jpg", io.BytesIO(image_data), "image/jpeg")}
        data = {"crop_hint": "wheat"}
        
        res = await client.post("/v1/crop-scans", headers=headers, data=data, files=files)
        assert res.status_code == 201, res.text
        scan_result = res.json()
        
        # 2. Verify ML inference results
        assert "id" in scan_result
        assert "crop_identified" in scan_result
        assert "disease_name" in scan_result
        assert "severity" in scan_result
        assert "confidence_score" in scan_result
        assert "recommended_treatment" in scan_result
        assert scan_result["crop_identified"] is not None
        
        scan_id = scan_result["id"]
        
        # 3. Retrieve specific scan
        res = await client.get(f"/v1/crop-scans/{scan_id}", headers=headers)
        assert res.status_code == 200
        retrieved_scan = res.json()
        assert retrieved_scan["id"] == scan_id
        assert "image_url" in retrieved_scan
        
        # 4. Retrieve scan history
        res = await client.get("/v1/crop-scans", headers=headers, params={"limit": 10})
        assert res.status_code == 200
        history = res.json()
        assert "scans" in history
        assert len(history["scans"]) >= 1
        assert any(s["id"] == scan_id for s in history["scans"])
        
        # 5. Test invalid file upload
        invalid_files = {"file": ("virus.exe", io.BytesIO(b"malicious"), "application/exe")}
        res = await client.post("/v1/crop-scans", headers=headers, files=invalid_files)
        assert res.status_code == 400


# ══════════════════════════════════════════════════════════════════════════════
# 3. COMPLETE SOIL ANALYSIS FLOW
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_complete_soil_analysis_flow():
    """Test: submit test with image → toxicity detection → retrieve results."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Create a field first
        res = await client.post("/v1/farms/fields", headers=headers, json={
            "name": "Test Soil Field",
            "crop_name": "Rice",
            "acreage": 3.5,
            "location_name": "North Plot",
        })
        assert res.status_code == 201
        field_id = res.json()["id"]
        
        # 2. Submit healthy soil test
        res = await client.post("/v1/soil/tests", headers=headers, json={
            "field_id": field_id,
            "ph": 6.8,
            "source": "laboratory",
            "ec_ds_m": 1.1,
            "moisture_percentage": 40.0,
            "nitrogen_kg_ha": 350.0,
            "phosphorus_kg_ha": 22.0,
            "potassium_kg_ha": 190.0,
            "organic_carbon_percentage": 1.2,
            "laboratory_name": "IARI Delhi",
        })
        assert res.status_code == 201, res.text
        test_result = res.json()
        
        # 3. Verify toxicity detection
        assert "soil_condition" in test_result
        assert "toxicity_level" in test_result
        assert "evaluation_summary" in test_result
        assert test_result["toxicity_level"] in ["Green", "Yellow", "Red"]
        assert test_result["soil_condition"] in ["Healthy", "Attention", "Critical"]
        
        test_id = test_result["id"]
        
        # 4. Submit critical toxicity test (high heavy metals)
        res = await client.post("/v1/soil/tests", headers=headers, json={
            "field_id": field_id,
            "ph": 6.5,
            "source": "laboratory",
            "lead_mg_kg": 120.0,  # Critical level
            "cadmium_mg_kg": 4.5,  # Critical level
            "arsenic_mg_kg": 25.0,  # Critical level
        })
        assert res.status_code == 201
        toxic_test = res.json()
        assert toxic_test["toxicity_level"] == "Red"
        assert toxic_test["soil_condition"] == "Critical"
        assert "Lead" in toxic_test["evaluation_summary"]
        
        # 5. Retrieve specific test
        res = await client.get(f"/v1/soil/tests/{test_id}", headers=headers)
        assert res.status_code == 200
        
        # 6. Get soil summary for field
        res = await client.get(f"/v1/soil/summary/{field_id}", headers=headers)
        assert res.status_code == 200
        summary = res.json()
        assert summary["field_id"] == field_id
        assert "npk_status" in summary
        assert "latest_ph" in summary
        
        # 7. List all tests
        res = await client.get("/v1/soil/tests", headers=headers)
        assert res.status_code == 200
        all_tests = res.json()
        assert len(all_tests) >= 2


# ══════════════════════════════════════════════════════════════════════════════
# 4. RECOMMENDATION ENGINE
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_recommendation_engine_flow():
    """Test: fetch recommendations based on field/soil/weather data."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Create field with health issues
        res = await client.post("/v1/farms/fields", headers=headers, json={
            "name": "Low Health Field",
            "crop_name": "Wheat",
            "acreage": 5.0,
            "health_score": 55,  # Low health to trigger recommendations
            "water_status": "Needs Irrigation",
        })
        assert res.status_code == 201
        field_id = res.json()["id"]
        
        # 2. Generate recommendations
        res = await client.post(f"/v1/recommendations/generate/{field_id}", headers=headers, json={
            "crop_stage": "Flowering",
        })
        assert res.status_code == 201, res.text
        recommendations = res.json()
        
        # 3. Verify recommendation structure
        assert isinstance(recommendations, list)
        assert len(recommendations) > 0
        
        for rec in recommendations:
            assert "id" in rec
            assert "category" in rec
            assert "title" in rec
            assert "description" in rec
            assert "priority" in rec
            assert rec["priority"] in ["high", "medium", "low"]
            assert rec["category"] in ["irrigation", "fertilizer", "pesticide", "disease_management", "general"]
        
        # 4. Get specific recommendation
        rec_id = recommendations[0]["id"]
        res = await client.get(f"/v1/recommendations/{rec_id}", headers=headers)
        assert res.status_code == 200
        specific_rec = res.json()
        assert specific_rec["id"] == rec_id
        
        # 5. List all recommendations
        res = await client.get("/v1/recommendations", headers=headers)
        assert res.status_code == 200
        all_recs = res.json()
        assert any(r["id"] == rec_id for r in all_recs)


# ══════════════════════════════════════════════════════════════════════════════
# 5. AI ASSISTANT CHAT
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_ai_assistant_flow():
    """Test: send chat message → receive LLM response → maintain context."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Send first message
        res = await client.post("/v1/ai/chat", headers=headers, json={
            "message": "What is the best fertilizer for wheat?",
            "preferred_language": "en",
        })
        assert res.status_code == 200, res.text
        chat_data = res.json()
        
        # 2. Verify response structure
        assert "conversation_id" in chat_data
        assert "reply" in chat_data
        assert "suggested_actions" in chat_data
        assert len(chat_data["reply"]) > 10  # Non-empty response
        assert isinstance(chat_data["suggested_actions"], list)
        
        conv_id = chat_data["conversation_id"]
        
        # 3. Send follow-up message in same conversation
        res = await client.post("/v1/ai/chat", headers=headers, json={
            "message": "When should I apply it?",
            "conversation_id": conv_id,
        })
        assert res.status_code == 200
        followup_data = res.json()
        assert followup_data["conversation_id"] == conv_id
        assert len(followup_data["reply"]) > 5
        
        # 4. Test Hindi language support
        res = await client.post("/v1/ai/chat", headers=headers, json={
            "message": "गेहूं की फसल के लिए कौन सा खाद अच्छा है?",
            "preferred_language": "hi",
        })
        assert res.status_code == 200
        hindi_data = res.json()
        assert len(hindi_data["reply"]) > 5
        
        # 5. List conversations
        res = await client.get("/v1/ai/conversations", headers=headers)
        assert res.status_code == 200
        conversations = res.json()
        assert any(c["id"] == conv_id for c in conversations)
        
        # 6. Get full conversation with messages
        res = await client.get(f"/v1/ai/conversations/{conv_id}", headers=headers)
        assert res.status_code == 200
        full_conv = res.json()
        assert full_conv["id"] == conv_id
        assert "messages" in full_conv
        assert len(full_conv["messages"]) >= 4  # 2 user + 2 assistant


# ══════════════════════════════════════════════════════════════════════════════
# 6. FIELDS AND FARMS CRUD
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_farms_and_fields_complete_crud():
    """Test complete CRUD operations for farms and fields."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Create farm
        res = await client.post("/v1/farms", headers=headers, json={
            "name": "Golden Harvest Farm",
            "location": "Amritsar, Punjab",
            "total_area_acres": 20.0,
            "soil_type": "Alluvial",
            "irrigation_source": "Canal + Tubewell",
        })
        assert res.status_code == 201
        farm = res.json()
        farm_id = farm["id"]
        assert farm["name"] == "Golden Harvest Farm"
        
        # 2. List farms
        res = await client.get("/v1/farms", headers=headers)
        assert res.status_code == 200
        farms = res.json()
        assert any(f["id"] == farm_id for f in farms)
        
        # 3. Get specific farm
        res = await client.get(f"/v1/farms/{farm_id}", headers=headers)
        assert res.status_code == 200
        assert res.json()["total_area_acres"] == 20.0
        
        # 4. Update farm
        res = await client.put(f"/v1/farms/{farm_id}", headers=headers, json={
            "notes": "Primary rice and wheat rotation area"
        })
        assert res.status_code == 200
        updated_farm = res.json()
        assert updated_farm["notes"] == "Primary rice and wheat rotation area"
        
        # 5. Create fields
        field_ids = []
        for i in range(3):
            res = await client.post("/v1/farms/fields", headers=headers, json={
                "name": f"Field {i+1}",
                "crop_name": ["Wheat", "Rice", "Sugarcane"][i],
                "acreage": 5.0 + i,
                "location_name": f"Plot {chr(65+i)}",
                "health_score": 75 + i * 5,
            })
            assert res.status_code == 201
            field_ids.append(res.json()["id"])
        
        # 6. List all fields
        res = await client.get("/v1/farms/fields/all", headers=headers)
        assert res.status_code == 200
        all_fields = res.json()
        assert len(all_fields) >= 3
        
        # 7. Get specific field
        res = await client.get(f"/v1/farms/fields/{field_ids[0]}", headers=headers)
        assert res.status_code == 200
        field = res.json()
        assert field["id"] == field_ids[0]
        
        # 8. Update field
        res = await client.put(f"/v1/farms/fields/{field_ids[1]}", headers=headers, json={
            "health_score": 95,
            "notes": "Recently treated for pests",
        })
        assert res.status_code == 200
        updated_field = res.json()
        assert updated_field["health_score"] == 95
        
        # 9. Delete field
        res = await client.delete(f"/v1/farms/fields/{field_ids[2]}", headers=headers)
        assert res.status_code == 200
        
        # Verify deletion
        res = await client.get(f"/v1/farms/fields/{field_ids[2]}", headers=headers)
        assert res.status_code == 404
        
        # 10. Delete farm
        res = await client.delete(f"/v1/farms/{farm_id}", headers=headers)
        assert res.status_code == 200
        
        # Verify farm deletion
        res = await client.get(f"/v1/farms/{farm_id}", headers=headers)
        assert res.status_code == 404


# ══════════════════════════════════════════════════════════════════════════════
# 7. DASHBOARD WITH WEATHER INTEGRATION
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_dashboard_with_weather():
    """Test dashboard summary with weather integration and caching."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Get dashboard summary
        res = await client.get("/v1/dashboard/summary", headers=headers)
        assert res.status_code == 200, res.text
        dashboard = res.json()
        
        # 2. Verify dashboard structure
        assert "stats" in dashboard
        assert "recent_fields" in dashboard
        assert "active_alerts" in dashboard
        
        stats = dashboard["stats"]
        assert any(s["label"] == "Total Fields" for s in stats)
        assert any(s["label"] == "Total Scans" for s in stats)
        
        # 3. Get weather data
        res = await client.get("/v1/weather", headers=headers, params={
            "location": "Ludhiana, Punjab"
        })
        assert res.status_code == 200
        weather = res.json()
        
        # 4. Verify weather structure
        assert "temperature_celsius" in weather
        assert "humidity_percentage" in weather
        assert "rain_probability_percentage" in weather
        assert "advisory" in weather
        assert "hourly_forecast" in weather
        assert len(weather["hourly_forecast"]) > 0
        
        # 5. Test weather caching (second request should be faster)
        res2 = await client.get("/v1/weather", headers=headers, params={
            "location": "Ludhiana, Punjab"
        })
        assert res2.status_code == 200
        weather2 = res2.json()
        assert weather2["temperature_celsius"] == weather["temperature_celsius"]
        
        # 6. Get dashboard alerts
        res = await client.get("/v1/dashboard/alerts", headers=headers)
        assert res.status_code == 200
        alerts_data = res.json()
        assert "alerts" in alerts_data
        assert "total" in alerts_data


# ══════════════════════════════════════════════════════════════════════════════
# 8. RATE LIMITING
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_rate_limiting():
    """Test rate limiting enforcement on protected endpoints."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # Make multiple rapid requests to a rate-limited endpoint
        # Note: Rate limits vary by endpoint; adjust based on actual limits
        success_count = 0
        rate_limited = False
        
        for i in range(100):  # Try many requests
            res = await client.get("/v1/dashboard/summary", headers=headers)
            if res.status_code == 200:
                success_count += 1
            elif res.status_code == 429:
                rate_limited = True
                assert "rate limit" in res.json()["detail"].lower()
                break
        
        # If Redis is enabled, rate limiting should work
        if settings.USE_REDIS:
            assert rate_limited, "Rate limiting should have been triggered"
        else:
            # Without Redis, rate limiting might not work
            print(f"Rate limiting test: {success_count} successful requests (Redis not enabled)")


# ══════════════════════════════════════════════════════════════════════════════
# 9. STORAGE SERVICE
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_storage_service():
    """Test storage service (S3 or filesystem based on config)."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # Upload image through crop scan (tests storage)
        image_data = create_test_image(25)
        files = {"file": ("test_storage.jpg", io.BytesIO(image_data), "image/jpeg")}
        
        res = await client.post("/v1/crop-scans", headers=headers, data={"crop_hint": "rice"}, files=files)
        assert res.status_code == 201
        scan = res.json()
        
        # Verify image URL is returned
        assert "image_url" in scan
        assert scan["image_url"] is not None
        assert len(scan["image_url"]) > 0
        
        # Storage type indication
        if settings.USE_S3:
            print("✓ S3 storage test passed")
        else:
            print("✓ Filesystem storage test passed")


# ══════════════════════════════════════════════════════════════════════════════
# 10. IOT SENSORS
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_iot_sensor_integration():
    """Test IoT sensor registration and data submission."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        device_uid = f"SENSOR-TEST-{uuid.uuid4().hex[:8].upper()}"
        
        # 1. Register sensor
        res = await client.post("/v1/sensors/register", headers=headers, json={
            "device_uid": device_uid,
            "model_name": "AgriSense Pro v3",
        })
        assert res.status_code == 201
        sensor = res.json()
        sensor_id = sensor["id"]
        
        # 2. Submit sensor readings (no auth needed, uses device_uid)
        res = await client.post("/v1/sensors/readings", json={
            "device_uid": device_uid,
            "soil_moisture_percentage": 38.5,
            "soil_temperature_celsius": 26.2,
            "ambient_humidity_percentage": 68.0,
            "soil_ph": 7.1,
        })
        assert res.status_code == 201
        reading = res.json()
        assert reading["soil_moisture_percentage"] == 38.5
        
        # 3. Submit critical reading (low moisture)
        res = await client.post("/v1/sensors/readings", json={
            "device_uid": device_uid,
            "soil_moisture_percentage": 12.0,  # Critical level
        })
        assert res.status_code == 201
        
        # 4. Get sensor reading history
        res = await client.get(f"/v1/sensors/{sensor_id}/readings", headers=headers, params={"limit": 20})
        assert res.status_code == 200
        readings = res.json()
        assert len(readings) >= 2
        
        # 5. List all sensors
        res = await client.get("/v1/sensors", headers=headers)
        assert res.status_code == 200
        sensors = res.json()
        assert any(s["id"] == sensor_id for s in sensors)


# ══════════════════════════════════════════════════════════════════════════════
# 11. PROFILE AND SETTINGS
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_profile_and_settings():
    """Test user profile and settings management."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, user_data = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Get profile
        res = await client.get("/v1/users/profile", headers=headers)
        assert res.status_code == 200
        profile = res.json()
        assert profile["user_email"] == user_data["email"]
        
        # 2. Update profile
        res = await client.put("/v1/users/profile", headers=headers, json={
            "name": "Updated Name",
            "village": "Khalipur",
            "district": "Hapur",
            "state": "Uttar Pradesh",
            "primary_crops": "Wheat, Rice",
            "farming_experience_years": 15,
        })
        assert res.status_code == 200
        updated = res.json()
        assert updated["user_name"] == "Updated Name"
        assert updated["district"] == "Hapur"
        
        # 3. Get settings
        res = await client.get("/v1/users/settings", headers=headers)
        assert res.status_code == 200
        settings_data = res.json()
        assert "theme_mode" in settings_data
        
        # 4. Update settings
        res = await client.put("/v1/users/settings", headers=headers, json={
            "theme_mode": "dark",
            "font_size": "large",
            "disease_alerts_enabled": True,
            "weather_alerts_enabled": False,
        })
        assert res.status_code == 200
        updated_settings = res.json()
        assert updated_settings["theme_mode"] == "dark"
        assert updated_settings["font_size"] == "large"


# ══════════════════════════════════════════════════════════════════════════════
# 12. ERROR HANDLING
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_error_handling():
    """Test error handling across the stack."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Test 404 on non-existent resource
        res = await client.get("/v1/farms/fields/99999999", headers=headers)
        assert res.status_code == 404
        
        # 2. Test 401 unauthorized
        res = await client.get("/v1/dashboard/summary")
        assert res.status_code == 401
        
        # 3. Test 400 invalid data
        res = await client.post("/v1/farms/fields", headers=headers, json={
            "name": "Test",
            "acreage": -10,  # Invalid negative acreage
        })
        assert res.status_code == 422  # Validation error
        
        # 4. Test invalid token
        bad_headers = {"Authorization": "Bearer invalid.token.here"}
        res = await client.get("/v1/dashboard/summary", headers=bad_headers)
        assert res.status_code == 401


# ══════════════════════════════════════════════════════════════════════════════
# 13. SECURITY VERIFICATION
# ══════════════════════════════════════════════════════════════════════════════

@pytest.mark.asyncio
async def test_security_features():
    """Test security features: JWT validation, image validation, etc."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        token, _, _ = await create_test_user(client)
        headers = auth_headers(token)
        
        # 1. Test password strength requirement
        res = await client.post("/v1/auth/signup", json={
            "name": "Weak Password User",
            "email": unique_email(),
            "password": "weak",  # Too weak
            "phone": "+919800000000",
        })
        assert res.status_code == 422  # Should fail validation
        
        # 2. Test invalid file extension
        bad_file = {"file": ("malware.exe", io.BytesIO(b"virus"), "application/exe")}
        res = await client.post("/v1/crop-scans", headers=headers, files=bad_file)
        assert res.status_code == 400
        
        # 3. Test oversized file (if size limit implemented)
        huge_file = {"file": ("huge.jpg", io.BytesIO(b"X" * 50_000_000), "image/jpeg")}  # 50MB
        res = await client.post("/v1/crop-scans", headers=headers, files=huge_file, timeout=10.0)
        # Should either reject or handle gracefully (not 500)
        assert res.status_code in [400, 413, 422, 201]
        
        # 4. Test SQL injection protection (should be handled by ORM)
        res = await client.get("/v1/farms/fields/'; DROP TABLE fields; --", headers=headers)
        assert res.status_code in [404, 422]  # Not 500


# ══════════════════════════════════════════════════════════════════════════════
# RUN ALL TESTS
# ══════════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
