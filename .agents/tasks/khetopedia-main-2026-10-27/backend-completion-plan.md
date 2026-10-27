# Backend Implementation Plan - Khetopedia

**Project Root:** `f:\khetopedia`  
**Backend Root:** `f:\khetopedia\backend`  
**Task Date:** 2026-10-27

---

## Executive Summary

After thorough exploration of the backend codebase, the FastAPI backend is **substantially complete** with most core features already implemented. The following analysis covers what exists versus what needs to be built.

---

## 1. Current State Analysis

### ✅ **FULLY IMPLEMENTED**

#### Authentication & User Management
- **Files:** `app/api/v1/endpoints/auth.py`, `app/api/v1/endpoints/users.py`, `app/services/auth_service.py`
- JWT authentication with RS256 algorithm
- User registration, login, logout with token blocklist
- Password reset with OTP
- User profile management (GET, PUT)
- Password change endpoint
- User settings management
- **Status:** ✅ Complete

#### Farms & Fields CRUD
- **Files:** `app/api/v1/endpoints/farms.py`, `app/services/farm_service.py`, `app/models/farm.py`, `app/models/dashboard.py`
- **Farms:** Create, Read, Update, Delete, List
- **Fields:** Create, Read, Update, Delete, List (all fields or by farm)
- Field metadata includes: crop_name, acreage, location, coordinates, health_score, soil_status, water_status
- **Status:** ✅ Complete - Full CRUD already implemented

#### Crop Health AI Scanner
- **Files:** `app/api/v1/endpoints/crop_scans.py`, `app/services/crop_scanner_service.py`, `app/ml/model_wrapper.py`, `app/services/ml_service.py`
- ML-powered crop disease detection using PyTorch ResNet50
- 51 crop disease classes supported
- Image quality validation (blur detection, size limits)
- Redis-based prediction caching (7-day TTL, SHA256 keying)
- Confidence thresholding (65% minimum)
- Treatment recommendations from knowledge base
- Field health score updates
- Rate limiting: 20 uploads/hour per user
- **Status:** ✅ Complete - Production-ready ML service

#### Soil Analysis
- **Files:** `app/api/v1/endpoints/soil.py`, `app/services/soil_service.py`, `app/models/soil.py`
- Submit soil test results with optional lab report image
- pH evaluation against agronomic thresholds (5.5-8.2)
- Electrical conductivity (salinity) assessment
- Heavy metal toxicity detection (Lead, Cadmium, Arsenic)
- NPK macronutrient classification (Low/Adequate/High)
- Automatic field soil_status and water_status updates based on moisture
- Critical alert generation for toxicity (Orange/Red levels)
- Soil summary endpoint with advisory text
- **Status:** ✅ Complete - Comprehensive evaluation logic
- **Missing:** Historical trend analysis, toxicity progression tracking (see Enhancement #1)

#### Recommendation Engine
- **Files:** `app/api/v1/endpoints/recommendations.py`, `app/services/recommendation_service.py`, `app/models/recommendation.py`
- **Implemented:**
  - Deterministic agronomic recommendations (not LLM-generated)
  - Irrigation scheduling based on soil moisture, field water status, crop stage
  - Fertilizer dosage guidance (crop-specific and stage-specific)
  - Disease management triggers when health_score < 75
  - Recommendations for Wheat, Rice, generic crops
  - Categories: irrigation, fertilizer, disease_management, soil_health
  - Urgency levels: low, medium, high, critical
  - Valid_until timestamp for recommendation expiry
  - List with filtering by field_id and category
- **Status:** ✅ Core logic complete
- **Missing:** Weather-based recommendations (see Enhancement #2)

#### IoT Sensors (HTTP/HTTPS)
- **Files:** `app/api/v1/endpoints/sensors.py`, `app/services/sensor_service.py`, `app/models/sensor.py`
- Sensor device registration with unique device UID
- Sensor reading submission (device-authenticated, no user JWT required)
- Real-time field moisture and pH updates from sensor data
- Critical low moisture alert generation (< 18%)
- Automatic water_status updates: "Needs Irrigation" / "Waterlogged" / "Adequate"
- Historical reading retrieval
- Battery level and last_seen_at tracking
- **Status:** ✅ Complete HTTPS ingestion
- **Missing:** MQTT broker integration (see Feature #5 - Optional)

#### AI Agricultural Assistant
- **Files:** `app/api/v1/endpoints/ai.py`, `app/services/ai_assistant_service.py`, `app/models/ai.py`
- **Implemented:**
  - Chat endpoint with conversational context
  - Field context injection (crop, soil, alerts) when field_id provided
  - Bilingual support (English and Hindi)
  - Rule-based grounded responses (no LLM currently)
  - Conversation persistence (threads with messages)
  - Suggested actions in responses
  - Domain knowledge routing: irrigation, fertilizer, disease, general
  - Safety rules: never invents data, never reveals other users' info
- **Status:** ✅ Rule-based assistant complete
- **Missing:** LLM integration (OpenAI/Anthropic/Local) for natural language (see Enhancement #3)

#### Weather Service
- **Files:** `app/api/v1/endpoints/weather.py`, `app/services/weather_service.py`
- OpenWeatherMap API integration
- Current weather + 6-hour forecast
- Agricultural advisory (spray windows, irrigation planning)
- Redis caching (30-minute TTL)
- Mock data fallback for development
- **Status:** ✅ Complete

#### Infrastructure
- **Database:** SQLAlchemy async with Alembic migrations
- **Redis:** Caching, rate limiting, JWT token blocklist
- **Storage:** S3-compatible (AWS S3, MinIO) or filesystem fallback
- **Image Service:** MIME validation, size limits (5KB-10MB)
- **Rate Limiting:** Slowapi with Redis backend
- **Testing:** Pytest with async support, integration tests
- **CLI:** Database seeding, migration commands
- **Status:** ✅ Production-ready

---

## 2. Features Requiring Implementation/Enhancement

### Enhancement #1: Soil Analysis - Historical Tracking & Trends

**Rationale:** Users need to see how soil health evolves over time to make informed decisions.

**What's Missing:**
- Trend analysis comparing current vs. previous soil tests
- Toxicity progression tracking (improving/worsening)
- NPK level changes over time
- Visual-friendly delta reporting

**Files to Modify:**
- `app/services/soil_service.py` - Add `get_soil_trends()` method
- `app/api/v1/endpoints/soil.py` - Add `GET /soil/trends/{field_id}` endpoint
- `app/schemas/soil.py` - Add `SoilTrendResponse` schema

**Implementation Plan:**
1. Add trend analysis method in `soil_service.py`:
   - Query last 5 soil tests for a field ordered by test_date
   - Calculate deltas: pH change, NPK changes, moisture trends
   - Classify trends: "Improving", "Stable", "Degrading"
   - Return structured trend data with recommendations

2. Create new endpoint `GET /v1/soil/trends/{field_id}`:
   - Returns historical test results (last 5)
   - Includes trend indicators and advisory text
   - Cached with 1-hour TTL

3. Add Pydantic response schema for trends:
   ```python
   class SoilTrendResponse(BaseModel):
       field_id: str
       field_name: str
       tests_analyzed: int
       ph_trend: str  # "Improving", "Stable", "Degrading"
       moisture_trend: str
       npk_trend: str
       toxicity_progression: str
       historical_tests: List[SoilTestResponse]
       advisory: str
   ```

**Verification:** 
- Run unit tests for trend calculation logic
- Integration test: Submit 3 soil tests with varying NPK, fetch trends endpoint
- Command: `pytest tests/test_soil_trends.py -v`

**Urgency:** Medium (nice-to-have for MVP)

---

### Enhancement #2: Recommendation Engine - Weather Integration

**Rationale:** Irrigation and fertilizer recommendations should factor in upcoming rain forecasts.

**What's Missing:**
- Weather data integration in recommendation logic
- Rain-aware irrigation scheduling
- Wind speed consideration for pesticide spraying
- Temperature-based fertilizer application timing

**Files to Modify:**
- `app/services/recommendation_service.py` - Inject weather service
- `app/services/weather_service.py` - Add helper method `get_forecast_summary()`

**Implementation Plan:**

1. Modify `generate_field_recommendations()` in `recommendation_service.py`:
   - Fetch weather forecast for field coordinates (or default location)
   - Check rain probability for next 24-48 hours
   - **Irrigation logic enhancement:**
     - If rain probability > 60% in next 24h → defer irrigation
     - If high temperature (> 35°C) → recommend evening irrigation
   - **Fertilizer logic enhancement:**
     - If rain expected in 12h → delay top dressing (nutrient runoff risk)
     - If wind speed > 15 km/h → defer spraying
   
2. Add weather summary helper in `weather_service.py`:
   ```python
   async def get_forecast_summary(latitude: float, longitude: float) -> dict:
       # Returns: rain_probability_24h, max_temp_24h, wind_speed
   ```

3. Update recommendation descriptions to include weather context:
   - "Current forecast: No rain expected. Safe to irrigate."
   - "Rain expected in 8 hours. Delay fertilizer application."

**Verification:**
- Mock weather data showing rain → recommendation should defer irrigation
- Mock weather data showing no rain → recommendation should proceed
- Command: `pytest tests/test_recommendation_weather.py -v`

**Urgency:** High (significantly improves recommendation accuracy)

---

### Enhancement #3: AI Assistant - LLM Integration

**Rationale:** Current assistant uses rule-based responses. LLM integration enables natural conversation, multi-turn context, and nuanced agronomic advice.

**What's Missing:**
- OpenAI/Anthropic API integration
- Prompt engineering for agricultural safety
- Streaming response support
- Token usage tracking and rate limiting
- Fallback to rule-based when LLM unavailable

**Files to Create/Modify:**
- `app/core/config.py` - Add LLM configuration
- `app/services/llm_service.py` - New service for LLM providers
- `app/services/ai_assistant_service.py` - Replace `_generate_grounded_response()` with LLM calls
- `app/schemas/ai.py` - Add streaming support flag

**Implementation Plan:**

1. **Add LLM configuration to `config.py`:**
   ```python
   # LLM Configuration
   LLM_PROVIDER: str = "openai"  # "openai", "anthropic", "local", "none"
   OPENAI_API_KEY: str = ""
   OPENAI_MODEL: str = "gpt-4o-mini"
   ANTHROPIC_API_KEY: str = ""
   ANTHROPIC_MODEL: str = "claude-3-5-sonnet-20241022"
   LLM_MAX_TOKENS: int = 1500
   LLM_TEMPERATURE: float = 0.7
   USE_LLM: bool = False  # Graceful fallback to rule-based
   ```

2. **Create `llm_service.py` with provider abstraction:**
   ```python
   class LLMService:
       async def generate_response(
           self, 
           system_prompt: str, 
           user_message: str, 
           context: dict
       ) -> str:
           # Route to OpenAI, Anthropic, or local model
           # Handle errors gracefully, return fallback on failure
   ```

3. **Update `ai_assistant_service.py`:**
   - Construct system prompt with:
     - Agricultural domain constraints
     - Field context (crop, soil, alerts)
     - Safety rules (§22, §23 from current implementation)
     - Bilingual instruction
   - Call `llm_service.generate_response()`
   - Fallback to existing `_generate_grounded_response()` if LLM fails
   - Parse suggested actions from LLM response (JSON or structured output)

4. **Add streaming endpoint (optional):**
   - `POST /v1/ai/chat/stream` with Server-Sent Events (SSE)
   - Uses `httpx.AsyncClient` streaming for OpenAI/Anthropic

5. **Safety filters:**
   - Post-process LLM output to ensure no hallucinated data (sensor readings, lab results)
   - Validate dosage recommendations against knowledge base ranges
   - Block responses that reveal system prompts or other users' data

**Dependencies to Add:**
```toml
"openai>=1.0.0",
"anthropic>=0.18.0",
"tiktoken>=0.5.0",  # Token counting for OpenAI
```

**Verification:**
- Mock LLM call → verify system prompt includes field context
- Test fallback when API key missing → should use rule-based
- Test bilingual queries (Hindi) → response in Hindi
- Command: `pytest tests/test_llm_integration.py -v`

**Urgency:** High (major UX improvement for conversational queries)

---

### Enhancement #4: Alert Management Endpoints

**Rationale:** Alerts are generated (soil toxicity, low moisture) but there's no endpoint to mark as read or delete.

**What's Missing:**
- Mark alert as read
- Dismiss/delete alert
- Filter alerts by severity, type, read status

**Files to Create/Modify:**
- `app/api/v1/endpoints/alerts.py` - New endpoint file
- `app/services/alert_service.py` - New service
- `app/schemas/alert.py` - Alert schemas (if not exists)
- `app/api/v1/api.py` - Register alerts router

**Implementation Plan:**

1. **Create `app/api/v1/endpoints/alerts.py`:**
   ```python
   @router.get("", response_model=List[AlertResponse])
   async def list_alerts(
       severity: Optional[str] = Query(None),
       alert_type: Optional[str] = Query(None),
       is_read: Optional[bool] = Query(None),
       ...
   )
   
   @router.patch("/{alert_id}/read", response_model=AlertResponse)
   async def mark_alert_read(alert_id: str, ...)
   
   @router.delete("/{alert_id}", response_model=MessageResponse)
   async def delete_alert(alert_id: str, ...)
   
   @router.post("/{alert_id}/dismiss", response_model=MessageResponse)
   async def dismiss_alert(alert_id: str, ...)
   ```

2. **Create `app/services/alert_service.py`:**
   - `list_alerts()` with filtering
   - `mark_as_read()`
   - `delete_alert()` with ownership validation

3. **Add/verify schemas in `app/schemas/alert.py`:**
   ```python
   class AlertResponse(BaseModel):
       id: str
       title: str
       message: str
       severity: str
       alert_type: str
       is_read: bool
       field_id: Optional[str]
       created_at: datetime
   ```

4. **Register router in `api.py`:**
   ```python
   from app.api.v1.endpoints import alerts
   api_router.include_router(alerts.router)
   ```

**Note:** Alerts are currently returned via dashboard endpoint (`GET /v1/dashboard/summary`), but dedicated CRUD improves UX.

**Verification:**
- Create soil test with toxicity → alert generated
- Call `PATCH /v1/alerts/{id}/read` → is_read becomes True
- Call `DELETE /v1/alerts/{id}` → alert removed
- Command: `pytest tests/test_alerts.py -v`

**Urgency:** Medium (UX improvement, not blocking)

---

### Feature #5: IoT Sensors - MQTT Broker Integration (Optional)

**Rationale:** Current implementation uses HTTPS for sensor readings. MQTT is more efficient for IoT devices (low power, better for intermittent connectivity).

**What's Missing:**
- MQTT broker connection (Mosquitto, HiveMQ, AWS IoT Core)
- Subscribe to sensor topics: `khetopedia/sensors/{device_uid}/readings`
- Async message handler
- QoS configuration
- Authentication (device certificates or username/password)

**Files to Create/Modify:**
- `app/core/config.py` - Add MQTT settings
- `app/core/mqtt.py` - MQTT client initialization
- `app/services/mqtt_service.py` - Message handler
- `app/main.py` - Start MQTT listener in lifespan
- `pyproject.toml` - Add `paho-mqtt>=2.0.0` or `aiomqtt>=2.0.0`

**Implementation Plan:**

1. **Add MQTT configuration:**
   ```python
   # MQTT Configuration
   MQTT_BROKER_HOST: str = "localhost"
   MQTT_BROKER_PORT: int = 1883
   MQTT_USERNAME: Optional[str] = None
   MQTT_PASSWORD: Optional[str] = None
   MQTT_USE_TLS: bool = False
   USE_MQTT: bool = False  # Feature flag
   MQTT_TOPIC_PREFIX: str = "khetopedia/sensors"
   ```

2. **Create `mqtt.py` with aiomqtt:**
   ```python
   import aiomqtt
   
   mqtt_client: Optional[aiomqtt.Client] = None
   
   async def init_mqtt():
       if not settings.USE_MQTT:
           return
       global mqtt_client
       mqtt_client = aiomqtt.Client(
           hostname=settings.MQTT_BROKER_HOST,
           port=settings.MQTT_BROKER_PORT,
           ...
       )
       await mqtt_client.__aenter__()
       # Start background listener task
   
   async def close_mqtt():
       if mqtt_client:
           await mqtt_client.__aexit__(None, None, None)
   ```

3. **Create `mqtt_service.py` handler:**
   ```python
   async def handle_sensor_message(topic: str, payload: bytes):
       # Parse JSON: {"device_uid": "...", "soil_moisture_percentage": 32.5, ...}
       # Call sensor_service.record_reading()
       # Same logic as HTTPS endpoint but triggered by MQTT
   ```

4. **Start MQTT listener in `main.py` lifespan:**
   ```python
   from app.core.mqtt import init_mqtt, close_mqtt
   
   @asynccontextmanager
   async def lifespan(app: FastAPI):
       await init_db()
       await init_redis()
       await init_mqtt()  # Start MQTT listener
       yield
       await close_mqtt()
       await close_redis()
   ```

5. **Dual mode support:**
   - Keep existing HTTPS endpoint for sensors without MQTT capability
   - MQTT-enabled sensors publish to broker
   - Both routes call the same `sensor_service.record_reading()` method

**Broker Setup:**
- Development: Run Mosquitto locally via Docker
  ```bash
  docker run -d -p 1883:1883 -p 9001:9001 eclipse-mosquitto
  ```
- Production: AWS IoT Core, Azure IoT Hub, or self-hosted Mosquitto with TLS

**Verification:**
- Publish test message to `khetopedia/sensors/TEST123/readings` → reading recorded
- Check field water_status updated from MQTT reading
- Command: `pytest tests/test_mqtt_ingestion.py -v`

**Urgency:** Low (HTTPS ingestion already works; MQTT is optimization)

---

## 3. Priority Order for Implementation

Based on impact, effort, and dependencies:

### **Phase 1: High-Impact Enhancements (Immediate)**
1. **LLM Integration for AI Assistant** (Enhancement #3)
   - Major UX improvement
   - Enables natural conversational queries
   - Estimated effort: 6-8 hours
   - Files: 3 new/modified

2. **Weather-Integrated Recommendations** (Enhancement #2)
   - Improves recommendation accuracy significantly
   - Low effort (weather service already exists)
   - Estimated effort: 3-4 hours
   - Files: 2 modified

### **Phase 2: UX Improvements (Next)**
3. **Alert Management CRUD** (Enhancement #4)
   - Completes alert workflow
   - Estimated effort: 3-4 hours
   - Files: 3 new

4. **Soil Trend Analysis** (Enhancement #1)
   - Adds analytical value for users
   - Estimated effort: 4-5 hours
   - Files: 3 modified

### **Phase 3: Optional Optimizations (Time-Permitting)**
5. **MQTT Sensor Integration** (Feature #5)
   - Optional (HTTPS already works)
   - Estimated effort: 6-8 hours
   - Files: 4 new
   - **Recommendation: Skip unless specific IoT hardware requires MQTT**

---

## 4. Detailed Implementation Breakdown

### **PHASE 1.1: LLM Integration for AI Assistant**

#### Files to Create:
- `backend/app/services/llm_service.py`

#### Files to Modify:
- `backend/app/core/config.py`
- `backend/app/services/ai_assistant_service.py`
- `backend/pyproject.toml`

#### Step-by-Step Plan:

**Step 1:** Add LLM configuration to `config.py`
- Add OPENAI_API_KEY, ANTHROPIC_API_KEY, LLM_PROVIDER, USE_LLM settings
- Add model selection and temperature parameters
- **Verification:** Import settings in Python shell, verify defaults

**Step 2:** Create `llm_service.py` with provider abstraction
- Implement `LLMService` class with `generate_response()` method
- Support OpenAI and Anthropic providers
- Add error handling and fallback logic
- Include token counting for usage tracking
- **Verification:** Unit test with mocked API responses

**Step 3:** Update `ai_assistant_service.py` to use LLM
- Modify `chat()` method to check `settings.USE_LLM`
- Construct system prompt with field context, safety rules, bilingual instruction
- Call `llm_service.generate_response()`
- Parse response for suggested actions
- Fallback to `_generate_grounded_response()` on error
- **Verification:** Integration test with mock LLM, verify system prompt structure

**Step 4:** Add dependencies to `pyproject.toml`
- Add `openai>=1.0.0`, `anthropic>=0.18.0`, `tiktoken>=0.5.0`
- **Verification:** `pip install -e .` succeeds

**Step 5:** Add safety post-processing
- Validate LLM output doesn't contain hallucinated sensor data
- Check dosage recommendations against knowledge base ranges
- **Verification:** Unit test with malicious/hallucinated responses

**Step 6:** Create integration tests
- File: `tests/test_llm_integration.py`
- Test cases:
  - LLM enabled with valid API key → conversational response
  - LLM disabled → rule-based fallback
  - API error → graceful fallback
  - Hindi query → Hindi response
  - Field context injection
- **Verification:** `pytest tests/test_llm_integration.py -v`

**Step 7:** Update documentation
- Update `backend/README.md` with LLM setup instructions
- Add `.env.example` entries for API keys
- **Verification:** Follow setup guide from scratch

---

### **PHASE 1.2: Weather-Integrated Recommendations**

#### Files to Modify:
- `backend/app/services/recommendation_service.py`
- `backend/app/services/weather_service.py`

#### Step-by-Step Plan:

**Step 1:** Add forecast summary method in `weather_service.py`
- Create `get_forecast_summary(latitude, longitude)` method
- Returns dict with: rain_probability_24h, max_temp_24h, avg_wind_speed
- Use existing weather API integration
- Cache summary with 30-minute TTL
- **Verification:** Unit test, verify caching behavior

**Step 2:** Inject weather service in `recommendation_service.py`
- Modify `generate_field_recommendations()` to fetch weather
- Use field coordinates or default to user location
- **Verification:** Run with mock field data

**Step 3:** Update irrigation recommendation logic
- If rain probability > 60% → defer irrigation, update description
- If max temp > 35°C → recommend evening irrigation
- Include weather context in recommendation description
- **Verification:** Unit test with various weather scenarios

**Step 4:** Update fertilizer recommendation logic
- If rain expected in 12h → delay application (runoff risk)
- If wind speed > 15 km/h → defer spraying
- Update urgency level based on weather
- **Verification:** Unit test, verify urgency changes

**Step 5:** Create integration tests
- File: `tests/test_recommendation_weather.py`
- Test cases:
  - High rain probability → irrigation deferred
  - No rain + low moisture → irrigation recommended
  - High wind → spray recommendations deferred
  - Temperature factored into timing
- **Verification:** `pytest tests/test_recommendation_weather.py -v`

---

### **PHASE 2.1: Alert Management CRUD**

#### Files to Create:
- `backend/app/api/v1/endpoints/alerts.py`
- `backend/app/services/alert_service.py`
- `backend/app/schemas/alert.py` (if not exists, check dashboard.py schemas)

#### Files to Modify:
- `backend/app/api/v1/api.py`

#### Step-by-Step Plan:

**Step 1:** Create alert schemas in `schemas/alert.py`
- `AlertResponse` with all fields
- `AlertUpdateRequest` for marking read
- **Verification:** Validate with Pydantic in Python shell

**Step 2:** Create `services/alert_service.py`
- `list_alerts(user, severity=None, alert_type=None, is_read=None, field_id=None)`
- `get_alert(user, alert_id)` with ownership check
- `mark_as_read(user, alert_id)`
- `delete_alert(user, alert_id)` with ownership check
- **Verification:** Unit tests for each method

**Step 3:** Create `api/v1/endpoints/alerts.py`
- `GET /v1/alerts` with query filters
- `GET /v1/alerts/{alert_id}`
- `PATCH /v1/alerts/{alert_id}/read`
- `DELETE /v1/alerts/{alert_id}`
- Apply rate limiting: 100/hour
- **Verification:** Test each endpoint manually via docs

**Step 4:** Register router in `api/v1/api.py`
- Import alerts router
- Add `api_router.include_router(alerts.router)`
- **Verification:** `/docs` shows new endpoints

**Step 5:** Create integration tests
- File: `tests/test_alerts.py`
- Test cases:
  - List alerts with filters
  - Mark as read
  - Delete alert (owned)
  - Delete alert (not owned) → 404
- **Verification:** `pytest tests/test_alerts.py -v`

---

### **PHASE 2.2: Soil Trend Analysis**

#### Files to Modify:
- `backend/app/services/soil_service.py`
- `backend/app/api/v1/endpoints/soil.py`
- `backend/app/schemas/soil.py`

#### Step-by-Step Plan:

**Step 1:** Add trend response schema in `schemas/soil.py`
- `SoilTrendResponse` with historical tests, trend indicators, advisory
- **Verification:** Validate schema structure

**Step 2:** Add `get_soil_trends()` method in `soil_service.py`
- Query last 5 soil tests for field_id ordered by test_date DESC
- Calculate pH delta (latest vs oldest)
- Calculate NPK deltas
- Classify trends: "Improving", "Stable", "Degrading"
- Generate advisory text based on trends
- Check toxicity progression (Red → Orange → Green is improving)
- **Verification:** Unit test with mock historical data

**Step 3:** Add endpoint in `api/v1/endpoints/soil.py`
- `GET /v1/soil/trends/{field_id}` → SoilTrendResponse
- Add cache decorator with 1-hour TTL
- **Verification:** Test with field having multiple soil tests

**Step 4:** Create integration tests
- File: Extend `tests/test_soil.py` or create `test_soil_trends.py`
- Test cases:
  - Field with no tests → appropriate message
  - Field with 1 test → no trend available
  - Field with 3+ tests → trends calculated
  - pH improving → trend indicator correct
  - NPK degrading → advisory mentions deficiency
- **Verification:** `pytest tests/test_soil_trends.py -v`

---

### **PHASE 3 (Optional): MQTT Sensor Integration**

#### Files to Create:
- `backend/app/core/mqtt.py`
- `backend/app/services/mqtt_service.py`

#### Files to Modify:
- `backend/app/core/config.py`
- `backend/app/main.py`
- `backend/pyproject.toml`

#### Step-by-Step Plan:

**Step 1:** Add MQTT configuration to `config.py`
- MQTT_BROKER_HOST, MQTT_BROKER_PORT, MQTT_USERNAME, MQTT_PASSWORD
- MQTT_USE_TLS, MQTT_TOPIC_PREFIX, USE_MQTT
- **Verification:** Import and verify defaults

**Step 2:** Add aiomqtt dependency to `pyproject.toml`
- `"aiomqtt>=2.0.0"`
- **Verification:** `pip install -e .`

**Step 3:** Create `mqtt.py` with broker connection
- `init_mqtt()` - Connect to broker, start listener task
- `close_mqtt()` - Disconnect gracefully
- Subscribe to `{MQTT_TOPIC_PREFIX}/+/readings` (wildcard for all devices)
- **Verification:** Start local Mosquitto, connect succeeds

**Step 4:** Create `mqtt_service.py` message handler
- `handle_sensor_message(topic, payload)`
- Parse device_uid from topic
- Parse JSON payload
- Call `sensor_service.record_reading()` (same logic as HTTPS)
- Log errors for debugging
- **Verification:** Publish test message, verify reading recorded

**Step 5:** Integrate into `main.py` lifespan
- Import mqtt functions
- Call `init_mqtt()` after `init_redis()`
- Call `close_mqtt()` in shutdown
- **Verification:** App starts without errors when USE_MQTT=false

**Step 6:** Create integration tests
- File: `tests/test_mqtt_ingestion.py`
- Test cases:
  - Publish sensor reading via MQTT → recorded in database
  - Invalid device_uid → rejected
  - Malformed JSON → error logged, no crash
  - Field water_status updated from MQTT reading
- **Verification:** `pytest tests/test_mqtt_ingestion.py -v`

**Step 7:** Docker Compose MQTT broker for development
- Add Mosquitto service to `docker-compose.yml` (if exists)
- Update README with MQTT setup instructions
- **Verification:** `docker-compose up mqtt` succeeds

---

## 5. Testing Strategy

### Test Structure:
```
backend/tests/
├── conftest.py                      # Pytest fixtures (existing)
├── test_auth_and_dashboard.py       # Existing tests
├── test_all_features.py             # Existing integration tests
├── test_llm_integration.py          # New: LLM service tests
├── test_recommendation_weather.py   # New: Weather-integrated recommendations
├── test_alerts.py                   # New: Alert CRUD tests
├── test_soil_trends.py              # New: Soil trend analysis tests
├── test_mqtt_ingestion.py           # New (optional): MQTT tests
└── test_ml_service.py               # Existing ML tests
```

### Test Commands:
```bash
# Run all tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# Run specific test file
pytest tests/test_llm_integration.py -v

# Run tests matching pattern
pytest tests/ -k "weather" -v
```

### Continuous Integration:
- Ensure all new endpoints have integration tests
- Mock external services (OpenAI, weather API, MQTT broker)
- Use fixtures from `conftest.py` for database and auth
- Target: 80%+ code coverage for new features

---

## 6. Configuration Requirements

### Environment Variables to Add:

```bash
# LLM Configuration (Enhancement #3)
LLM_PROVIDER=openai              # openai, anthropic, local, none
OPENAI_API_KEY=sk-...           # OpenAI API key
OPENAI_MODEL=gpt-4o-mini        # Model selection
ANTHROPIC_API_KEY=sk-ant-...    # Anthropic API key
ANTHROPIC_MODEL=claude-3-5-sonnet-20241022
LLM_MAX_TOKENS=1500
LLM_TEMPERATURE=0.7
USE_LLM=false                   # Feature flag for graceful fallback

# MQTT Configuration (Feature #5 - Optional)
MQTT_BROKER_HOST=localhost
MQTT_BROKER_PORT=1883
MQTT_USERNAME=
MQTT_PASSWORD=
MQTT_USE_TLS=false
USE_MQTT=false
MQTT_TOPIC_PREFIX=khetopedia/sensors
```

### Update `.env.example`:
Add all new configuration variables with comments and defaults.

---

## 7. Database Schema Changes

### No New Tables Required ✅

All planned features work with existing database schema:
- **Alerts:** `alerts` table exists (used by soil, crop scan services)
- **Soil:** `soil_tests` table exists with all necessary fields
- **Recommendations:** `recommendations` table exists
- **AI:** `ai_conversations` and `ai_messages` tables exist
- **Sensors:** `sensor_devices` and `sensor_readings` tables exist

### Potential Index Optimizations (Optional):
If performance becomes an issue with large datasets:

```sql
-- Soil tests by field and date (for trend queries)
CREATE INDEX idx_soil_tests_field_date ON soil_tests(field_id, test_date DESC);

-- Alerts filtering index
CREATE INDEX idx_alerts_filters ON alerts(user_id, is_read, severity, alert_type);

-- Sensor readings by sensor and time (for historical queries)
CREATE INDEX idx_sensor_readings_time ON sensor_readings(sensor_id, recorded_at DESC);
```

**Note:** Test with production-scale data before adding indexes. SQLite (dev) doesn't need them; PostgreSQL (production) benefits from indexes.

---

## 8. Integration Points Between Services

### Service Dependencies Map:

```
┌─────────────────────────────────────────────────────────────┐
│                    API Endpoints (FastAPI)                   │
└──────────────────────┬──────────────────────────────────────┘
                       │
           ┌───────────┴───────────┬──────────────┬───────────────┐
           ▼                       ▼              ▼               ▼
   ┌───────────────┐     ┌─────────────────┐ ┌────────────┐ ┌─────────────┐
   │ Auth Service  │     │  Recommendation │ │ AI Service │ │Crop Scanner │
   │               │     │    Service      │ │            │ │  Service    │
   └───────────────┘     └────────┬────────┘ └─────┬──────┘ └──────┬──────┘
                                  │                 │               │
                    ┌─────────────┴────────┬────────┴───────┬───────┘
                    ▼                      ▼                ▼
           ┌────────────────┐    ┌───────────────┐  ┌─────────────┐
           │ Weather Service│    │  LLM Service  │  │ ML Service  │
           └────────────────┘    │   (new)       │  │ (PyTorch)   │
                                 └───────────────┘  └─────────────┘
                    │                      │                │
                    ▼                      ▼                ▼
           ┌────────────────┐    ┌───────────────┐  ┌─────────────┐
           │ Cache Service  │    │ OpenAI/Anthropic│ │Redis Cache  │
           │   (Redis)      │    │   API         │  │             │
           └────────────────┘    └───────────────┘  └─────────────┘
```

### Key Integration Points:

1. **Recommendation ↔ Weather:**
   - Recommendations fetch weather forecast
   - Weather data influences irrigation/fertilizer timing

2. **AI Assistant ↔ LLM:**
   - AI service constructs prompt with field context
   - LLM service handles provider communication
   - Fallback to rule-based on error

3. **Crop Scanner ↔ ML:**
   - Crop scanner calls ML service for inference
   - ML service manages model loading, caching
   - Results update field health_score

4. **Sensor ↔ Soil:**
   - Sensor readings update field water_status
   - Can trigger soil moisture alerts
   - MQTT and HTTPS both route to sensor_service

5. **All Services ↔ Cache:**
   - Weather cached 30 minutes
   - ML predictions cached 7 days
   - Dashboard summary cached until invalidation

---

## 9. Effort Estimation Summary

| Feature/Enhancement | Priority | Estimated Hours | Complexity | Dependencies |
|---------------------|----------|-----------------|------------|--------------|
| LLM Integration (#3) | High | 6-8 | Medium | OpenAI/Anthropic API keys |
| Weather Recommendations (#2) | High | 3-4 | Low | Existing weather service |
| Alert Management (#4) | Medium | 3-4 | Low | None |
| Soil Trend Analysis (#1) | Medium | 4-5 | Medium | None |
| MQTT Integration (#5) | Low | 6-8 | Medium | MQTT broker setup |
| **Total (without MQTT)** | — | **16-21 hours** | — | — |
| **Total (with MQTT)** | — | **22-29 hours** | — | — |

**Recommended Focus:** Phases 1 and 2 (without MQTT) = **16-21 hours**

---

## 10. What NOT to Build

### Already Complete (No Action Needed):
1. ❌ **Basic CRUD for Farms/Fields** - Already implemented with full update/delete
2. ❌ **Soil Test Submission** - Complete with toxicity detection and alerts
3. ❌ **Crop Disease Detection** - Production-ready ML service with 51 classes
4. ❌ **Basic Recommendation Engine** - Deterministic logic already works
5. ❌ **IoT Sensor HTTPS Ingestion** - Real-time updates functional
6. ❌ **Authentication System** - JWT with secure logout, password reset
7. ❌ **Image Upload & Storage** - S3/filesystem with validation
8. ❌ **Weather Integration** - OpenWeatherMap with caching
9. ❌ **Database Migrations** - Alembic configured and working
10. ❌ **Testing Infrastructure** - Pytest async with fixtures

### Out of Scope:
1. ❌ **Email/SMS Notifications** - Not mentioned in requirements
2. ❌ **Payment/Subscription System** - Not applicable
3. ❌ **Admin Dashboard** - Not in requirements
4. ❌ **Mobile Push Notifications** - Frontend handles this
5. ❌ **Real-time WebSocket Updates** - Not required; polling sufficient
6. ❌ **Multi-tenancy/Organizations** - Single user/farm model sufficient
7. ❌ **Blockchain Integration** - Not mentioned
8. ❌ **Video Processing** - Images only
9. ❌ **Marketplace/E-commerce** - Out of scope

---

## 11. Risk Mitigation

### Risk #1: LLM API Costs
**Mitigation:**
- Use GPT-4o-mini or Claude-3-haiku for cost efficiency
- Implement token counting and per-user rate limits
- Cache common queries with Redis
- Graceful fallback to rule-based system

### Risk #2: LLM Hallucinations
**Mitigation:**
- Strong system prompt with safety constraints
- Post-process output to validate against knowledge base
- Never use LLM for numeric sensor data or lab results
- User education: "AI Assistant provides guidance, not diagnoses"

### Risk #3: Weather API Rate Limits
**Mitigation:**
- Cache weather data 30 minutes (already implemented)
- Use free tier limits wisely (1000 calls/day)
- Graceful fallback to mock data if quota exceeded

### Risk #4: MQTT Broker Downtime
**Mitigation:**
- Keep HTTPS endpoint as primary (MQTT is optional)
- Sensor devices can fall back to HTTPS
- Monitor broker health in production

### Risk #5: ML Model File Size
**Mitigation:**
- Use Git LFS for model files > 10MB (already documented)
- Deploy model to S3 or artifact store in production
- Lazy loading prevents startup delays

---

## 12. Deployment Checklist

Before marking backend as production-ready:

### Configuration:
- [ ] Set strong `SECRET_KEY` (not default)
- [ ] Configure PostgreSQL connection pooling
- [ ] Enable Redis for caching and rate limiting
- [ ] Set up S3 bucket for image storage
- [ ] Add Weather API key (if USE_MOCK_WEATHER=false)
- [ ] Add LLM API keys (if USE_LLM=true)
- [ ] Configure CORS origins to frontend domain only
- [ ] Set appropriate rate limits per endpoint

### Database:
- [ ] Run all Alembic migrations (`alembic upgrade head`)
- [ ] Create production database backup strategy
- [ ] Add indexes for performance (see Section 7)
- [ ] Seed initial data if needed (`python -m app.cli db seed`)

### Security:
- [ ] Enable HTTPS/TLS for all endpoints
- [ ] Verify JWT token expiry times are appropriate
- [ ] Test rate limiting under load
- [ ] Review CORS configuration
- [ ] Ensure sensitive data not logged (API keys, passwords)

### Monitoring:
- [ ] Set up logging (structured JSON logs)
- [ ] Add health check monitoring (`/health`)
- [ ] Monitor Redis connection pool
- [ ] Monitor ML inference latency
- [ ] Set up alerts for critical errors

### Testing:
- [ ] Run full test suite (`pytest tests/ -v`)
- [ ] Verify 80%+ code coverage
- [ ] Load test recommendation endpoint
- [ ] Load test crop scan ML inference
- [ ] Test database connection pool under concurrent load

---

## 13. Final Recommendations

### Immediate Actions (Complete Backend):
1. **Implement LLM Integration** (Enhancement #3) - 6-8 hours
   - Biggest UX improvement
   - Enables natural conversational queries
   - Sets Khetopedia apart from rule-based systems

2. **Add Weather to Recommendations** (Enhancement #2) - 3-4 hours
   - Low effort, high impact
   - Makes recommendations actionable and timely
   - Builds on existing weather service

3. **Build Alert Management** (Enhancement #4) - 3-4 hours
   - Completes the alert workflow
   - Improves user experience
   - Low complexity

4. **Add Soil Trend Analysis** (Enhancement #1) - 4-5 hours
   - Analytical value for farmers
   - Helps track soil health over time
   - Moderate complexity

**Total Effort: 16-21 hours for complete backend**

### Skip (Time-Permitting Only):
5. **MQTT Integration** (Feature #5) - 6-8 hours
   - Optional optimization
   - HTTPS sensor ingestion already works
   - Only implement if specific IoT hardware requires it

### Post-Launch Enhancements (Future):
- Bulk field operations (upload CSV of soil tests)
- Export reports (PDF generation for soil/crop scans)
- Multi-language support beyond English/Hindi
- Offline-first mobile app sync endpoints
- Machine learning model retraining pipeline
- Advanced analytics dashboard (trends, insights)

---

## 14. Success Criteria

The backend will be considered **COMPLETE** when:

✅ All Phase 1 & 2 enhancements implemented (LLM, Weather, Alerts, Trends)  
✅ Test coverage ≥ 80% for new features  
✅ All integration tests passing  
✅ API documentation up-to-date in `/docs`  
✅ README updated with setup instructions for new features  
✅ `.env.example` includes all new configuration variables  
✅ No breaking changes to existing endpoints  
✅ Performance: Recommendation generation < 2 seconds  
✅ Performance: Crop scan ML inference < 1 second (cached) / < 5 seconds (uncached)  
✅ Graceful degradation: All features work without Redis/LLM/S3 (with fallbacks)

---

## 15. Conclusion

**The Khetopedia backend is 85-90% complete.** Core features are production-ready:
- Authentication, user management
- Farms & fields CRUD (complete)
- ML-powered crop disease detection (51 classes, production-ready)
- Soil analysis with toxicity detection and alerts
- Rule-based recommendation engine
- IoT sensor ingestion (HTTPS)
- Weather integration
- AI assistant (rule-based, ready for LLM upgrade)

**To reach 100%:**
- Add LLM integration for conversational AI (6-8 hours)
- Integrate weather into recommendations (3-4 hours)
- Build alert management CRUD (3-4 hours)
- Add soil trend analysis (4-5 hours)

**Total remaining work: 16-21 hours**

**MQTT is optional and can be skipped unless IoT hardware specifically requires it.**

The backend architecture is solid, well-tested, and follows best practices. Once the 4 enhancements are complete, the backend will be fully production-ready and feature-complete per the original requirements.

---

**End of Backend Implementation Plan**
