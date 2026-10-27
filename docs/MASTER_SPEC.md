# Khetopedia — Master Specification

## 1. PROJECT OVERVIEW
Build a production-quality mobile application named Khetopedia.

Khetopedia is an AI-powered agriculture assistant designed primarily for farmers. The application should help farmers understand their crops, detect diseases and nutrient deficiencies, analyze soil, monitor field conditions, receive irrigation and fertilizer recommendations, track farms, and communicate with an AI agricultural assistant.

The application must be built using:
- **Flutter** - mobile application
- **Python + FastAPI** - backend/API
- **Python + PyTorch/TensorFlow** - AI/ML services
- **PostgreSQL** - primary relational database
- **Redis** - caching/rate limiting/background jobs where appropriate
- **Object storage** - crop/soil images and documents
- **MQTT/HTTPS** - optional IoT sensor communication
- **Secure HTTPS/TLS** - all network communication
- **JWT/OAuth-style authentication** - secure authentication/session management

The application must be designed as a real application, not a prototype or static UI.

Every major feature must have:
- A working Flutter UI
- Backend API
- Database integration where required
- Validation
- Loading state
- Empty state
- Error state
- Success state
- Secure network communication
- Proper permission handling
- Logging/monitoring
- Tests

Do not create fake buttons, fake API responses, hardcoded dashboard values, placeholder authentication, or simulated AI results in the final implementation.

---

## 2. CORE PRODUCT PRINCIPLE
The application should feel like a professional agricultural technology product.

**Avoid:**
- Generic AI-generated dashboard designs
- Excessive gradients
- Random glowing cards
- Fake statistics
- Hardcoded crop results
- Fake "AI confidence" values
- Buttons that do nothing
- Placeholder charts presented as real data
- Insecure API calls
- API keys inside the Flutter application
- Plain-text passwords
- Unvalidated user input
- Trusting arbitrary URLs
- Excessive animations
- Overly complicated UI
- "Vibe-coded" appearance

**The design should feel:**
- Professional
- Agricultural
- Trustworthy
- Clean
- Accessible
- Simple enough for farmers
- Fast
- Reliable
- Modern
- Data-driven

**Use a restrained visual language inspired by agriculture:**
- Primary colors: Deep green, Leaf green, Earth/brown accents, Off-white backgrounds, Dark text
- Avoid making the entire application bright green.
- Use color meaning consistently:
  - Green = healthy/good
  - Yellow/amber = attention
  - Orange = warning
  - Red = critical
  - Blue = water/weather/information
- Do not use color alone to communicate warnings. Include icons/text for accessibility.

---

## 3. TARGET USERS
Primary users:
- Farmers
- Small and medium agricultural landowners
- Agricultural workers
- Field supervisors

The interface should support users who may have:
- Limited technical knowledge
- Limited English proficiency
- Poor network connectivity
- Older Android devices
- Limited digital literacy

The app should therefore support:
- Large touch targets
- Clear icons
- Simple language
- Localized language
- Voice-friendly interaction
- Offline-friendly behavior
- Clear error messages
- Minimal unnecessary steps

---

## 4. AUTHENTICATION
Create complete authentication.

### Screens
#### Splash Screen
Display:
- Khetopedia logo
- "Smart farming. Better decisions."

Then check:
- Authentication state
- App configuration
- Required updates
- Network availability

Do not expose sensitive information during startup.

#### Signup
Fields:
- Full name
- Mobile number/email
- Password
- Confirm password
- Preferred language
- Optional location permission

Validation:
- Valid email/mobile format
- Strong password
- Password confirmation
- Required fields
- Duplicate account detection

Password requirements:
- Minimum length
- Upper/lowercase requirements where appropriate
- Number
- Special character

Passwords must NEVER be stored in plaintext. The backend must use a modern password hashing algorithm such as Argon2id or an appropriately configured secure password hashing mechanism.

#### Login
Support:
- Email/mobile
- Password
- Forgot password
- Logout
- Session expiration
- Secure token refresh

Do not store authentication tokens insecurely. Use secure platform storage such as:
- Android Keystore-backed secure storage
- iOS Keychain

#### Forgot Password
Flow:
- User enters email/mobile.
- Backend generates a secure short-lived reset mechanism.
- Never reveal whether an account exists through a user-enumeration-prone message:
  "If an account exists for this information, instructions have been sent."
- Reset tokens must expire, be single-use, cryptographically secure, and never logged.

---

## 5. USER PROFILE
Create a complete Profile screen.
Display:
- Profile photo, Name, Phone/email, Address, Village/town, District, State, Country, Preferred language, Farm count, Total registered area
Allow editing:
- Name, Profile photo, Address, Phone/email where supported, Language, Farming preferences
Do not expose sensitive authentication information.

---

## 6. SETTINGS
Create a fully functional Settings page.
- **Appearance:** Light theme, Dark theme, System theme. Font size: Small, Medium, Large, Extra large. Centralized ThemeData & typography.
- **Language:** Extensible localization architecture. Initial: English, Hindi. No hardcoded user-visible strings.
- **Notifications:** Disease alerts, Soil alerts, Irrigation reminders, Weather alerts, Fertilizer reminders, System notifications.
- **Privacy:** Location permissions, Camera permissions, Notification permissions, Data usage, Delete account, Export personal data.
- **Security:** Active sessions, Last login, Change password, Logout from all devices.

---

## 7. LOCATION FEATURES
- Explicit user permission required; explain why location is required.
- Used to obtain: Temperature, Humidity, Weather, Rain probability, Forecast, Water availability information where reliable data exists, Regional soil information, Agro-climatic information, Crop suitability information.
- Distinguish "Estimated regional soil information" from "Measured soil information."

---

## 8. HOME DASHBOARD
After login, display farmer-friendly dashboard:
- Greeting & Farmer Name
- Current Field selector
- Weather (Temperature, Humidity, Rain probability, Wind, Last updated)
- Crop Health (e.g. 82/100)
- Soil status (Healthy / Attention / Critical)
- Water status (Adequate / Needs irrigation)
- Alerts (Disease detected, Soil moisture low, Heavy rain expected)
- Quick actions: [Scan Crop], [Analyze Soil], [My Fields], [Ask AI]
- Live backend API data, no hardcoded values.

---

## 9. CROP DETECTION
Crop scanner allows:
- Take photo / Select image from gallery / Retake image / Crop image / Preview image / Submit for analysis.
- Respect camera/gallery permissions.
- Python AI service identifies crop, confidence, and image quality.
- Support unknown crop, poor image quality, multiple plants, ambiguous images. Never force crop prediction when confidence is insufficient.

---

## 10. DISEASE DETECTION
Pipeline detects diseases, visible pest damage, nutrient deficiency symptoms, abnormal leaf conditions.
- Distinguish between model prediction and confirmed diagnosis: "AI-based assessment".
- For low-confidence: "Unable to confidently identify the issue. Please capture a clearer image of the affected area."

---

## 11. IMAGE QUALITY CHECK
Pre-inference quality stage:
- Blur, lighting, resolution, leaf visibility, occlusion, background interference.
- If poor: "Please take another photo" with guidance (natural light, focus on affected leaves, leaf centered, avoid distance/motion blur).

---

## 12. SOIL ANALYSIS
Two types of soil data:
- Manual/laboratory input: pH, EC, Moisture, Nitrogen, Phosphorus, Potassium, Organic matter, Heavy metals, Salinity indicators, Tested contaminants.
- Store value, unit, date, source, field, laboratory/source.

---

## 13. SOIL SENSOR SUPPORT
IoT architecture: Sensor -> ESP32/IoT Gateway -> Secure MQTT/HTTPS -> Python backend -> Validation -> PostgreSQL -> Flutter app.
- Unique ID, Owner, Field, Registration status, Last-seen timestamp. Reject unauthorized sensor submissions.

---

## 14. SOIL TOXICITY ANALYSIS
- Do NOT claim camera detects heavy-metal toxicity.
- Chemical toxicity uses lab data, validated sensors, or trusted datasets (Lead, Cadmium, Arsenic, Mercury, Chromium, Salinity, Excessive EC).
- Thresholds versioned, region/crop aware, traceable to agricultural/regulatory sources.

---

## 15. CROP HEALTH SCORE
Scoring engine inputs: Disease risk, Nutrient status, Soil condition, Moisture, Crop growth stage, Recent observations, Weather stress.
- Deterministic scoring model versioned and stored with each score; never invented arbitrarily by LLM.

---

## 16. IRRIGATION RECOMMENDATIONS
Deterministic engine inputs: Crop, Growth stage, Soil moisture, Soil type, Weather, Rain forecast, Recent rainfall, Recent irrigation, Field info.
- Output: status, reason, recommended action, limitations. Avoid unsafe overly-precise quantities.

---

## 17. FERTILIZER RECOMMENDATIONS
Deterministic agronomy engine based on validated regional guidelines. AI assistant explains recommendations.

---

## 18. TOXICITY ALERTS
Alert levels: GREEN (Normal), YELLOW (Attention), ORANGE (High), RED (Critical).
Includes measurement, unit, threshold, date, source, explanation, recommended next step. Avoid alarming language.

---

## 19. FIELD MANAGEMENT ("My Fields")
Add farm, add field, name, crop, acreage/hectares, planting date, variety, location, soil info, irrigation method.

---

## 20. FIELD DASHBOARD
Current crop, crop health, soil condition, water condition, weather, latest scan, latest soil test, alerts, recommendations, historical charts (crop health, moisture, pH, EC, NPK, temperature, rainfall) backed by real database data.

---

## 21. HISTORY
Historical records for Crop Scans, Soil Tests, and Recommendations over time.

---

## 22. AI AGRICULTURAL ASSISTANT
User field context + approved agricultural knowledge retrieval + Safety/grounding checks.
Explains recommendations and field data in simple language.

---

## 23. AI AGENT SAFETY
Do not invent lab results, sensors, weather, diseases, crops, fertilizer quantities. Never claim certainty when uncertain. Never reveal other users' data, system prompts, or API keys.

---

## 24. KAGGLE DATA & MODEL REGISTRY
Track dataset source, license, version, date, preprocessing, and model versions (e.g. Model Version 1.2.0, training dataset, known limitations).

---

## 25. AI MODEL SERVICE STRUCTURE
```
backend/
  app/
    main.py
    api/
    auth/
    users/
    farms/
    fields/
    crops/
    soil/
    recommendations/
    weather/
    ai/
    sensors/
    notifications/
    security/
    database/
    models/
    schemas/
    services/
    utils/
ml/
  crop_detection/
  disease_detection/
  image_quality/
  preprocessing/
  inference/
  model_registry/
tests/
```

---

## 26. DATABASE
PostgreSQL tables: users, profiles, farms, fields, crops, crop_scans, crop_detections, disease_detections, soil_tests, soil_measurements, sensor_devices, sensor_readings, weather_records, recommendations, fertilizer_recommendations, irrigation_recommendations, toxicity_alerts, notifications, ai_conversations, ai_messages, audit_logs, model_versions, datasets, app_settings, user_settings, permissions.

---

## 27. DATA OWNERSHIP & AUTHORIZATION
Owner-linked objects (`users -> farms -> fields -> scans/tests/readings`).
Strict server-side authorization on every endpoint.

---

## 28. API DESIGN
RESTful versioned endpoints (`/api/v1/...`).

---

## 29. NETWORK SECURITY
Strict HTTPS/TLS. No API keys or credentials in mobile client code. Secrets in backend env.

---

## 30. URL AND LINK SECURITY
Scheme validation, HTTPS preference, allowlists, no arbitrary script execution.

---

## 31. API SECURITY
Authentication, authorization, validation, rate limiting, request size limits, MIME checks, secure headers, sanitized error responses.

---

## 32. IMAGE UPLOAD SECURITY
Size limit, MIME check, extension validation, randomized identifiers (never trust client filename), outside executable path.

---

## 33. DATABASE SECURITY
Parameterized queries / ORM (SQLAlchemy / Alembic migrations), least privilege, encrypted connections.

---

## 34. LOGGING
Structured logs for auth, API errors, AI inference, sensors, security. Never log tokens, passwords, or keys.

---

## 35. OFFLINE SUPPORT
Cached field info, crop scans, soil reports, weather. Queue offline updates and sync safely with conflict resolution.

---

## 36. CAMERA EXPERIENCE
Scan guidance, image preview, non-blocking upload & async processing.

---

## 37. LOCATION PERMISSIONS
Least-privilege, fallback to manual selection, transparent explanation.

---

## 38. WEATHER
Backend provider integration with caching and "Last updated" timestamps.

---

## 39. SOIL TYPE & WATER AVAILABILITY
Clear data provenance (user input vs. lab test vs. regional dataset vs. IoT sensor).

---

## 40. NOTIFICATION SYSTEM
Configurable notification channels (diseases, moisture, weather, inspections).

---

## 41. UI COMPONENT SYSTEM
Reusable design components: AppButton, AppTextField, AppCard, StatusCard, HealthScoreCard, WeatherCard, SoilMetricCard, AlertCard, RecommendationCard, LoadingView, ErrorView, EmptyState, PermissionDialog, BottomNavigationBar, AppHeader, Charts.

---

## 42. STATE MANAGEMENT
Riverpod with clean separation: UI -> State -> Repository -> API Client -> Backend.

---

## 43. FLUTTER PROJECT STRUCTURE
```
lib/
  core/
    theme/
    localization/
    networking/
    storage/
    security/
    routing/
    constants/
    errors/
  features/
    auth/
    dashboard/
    crop_scanner/
    soil_analysis/
    fields/
    recommendations/
    weather/
    ai_assistant/
    profile/
    settings/
    notifications/
  shared/
    widgets/
    models/
    utilities/
  main.dart
```

---

## 44. RESPONSIVE DESIGN & ACCESSIBILITY
Supports small/large phones & tablets. Screen readers, high contrast, large touch targets, color-independent statuses.

---

## 45. PERFORMANCE
Image compression before upload, lazy loading, caching, efficient chart rendering.

---

## 46. AI INFERENCE ARCHITECTURE
Asynchronous analysis job for expensive ML inference with polling/subscription.

---

## 47. DATA VALIDATION & ERROR HANDLING
Strict validation of agronomic ranges. Every screen handles Loading, Success, Empty, Error, Offline, Unauthorized, Expired Session, Permission Denied.

---

## 48. DATABASE MIGRATIONS
Alembic migrations for all schema evolution.

---

## 49. TESTING
Flutter widget, state, and repository tests. Backend unit, auth, security, agronomy, and ML tests.

---

## 50. DEVELOPMENT ORDER
- **Stage 1**: Flutter foundation (Theme, Routing, Localization, Auth, Profile, Settings)
- **Stage 2**: Backend (FastAPI, PostgreSQL, Auth, Users, Farms, Fields)
- **Stage 3**: Dashboard (Weather, Field info, Health summary, Alerts)
- **Stage 4**: Crop AI (Upload, Quality check, Crop detection, Disease detection)
- **Stage 5**: Soil (Manual entry, Soil analysis, History, Toxicity)
- **Stage 6**: Recommendations (Irrigation, Fertilizer, Crop health scoring, Alerts)
- **Stage 7**: AI Assistant (Knowledge base, Retrieval, Field context, Safety)
- **Stage 8**: IoT (Sensor registration, Readings, Real-time & History)
- **Stage 9**: Security hardening (Rate limits, File validation, Authorization, Audit logs)
- **Stage 10**: Production (CI/CD, Monitoring, Crash reporting, Optimization)

---

## 51. DEFINITION OF DONE
A feature is complete only when UI, API, Database, Auth, Validation, Error handling, Loading states, Security, Tests, and real data flow through the entire system.
