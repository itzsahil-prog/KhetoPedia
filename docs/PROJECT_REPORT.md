# Khetopedia — Complete Project Report
**Generated:** October 13, 2026  
**Project:** Khetopedia — AI-Powered Agriculture Assistant  
**Platform:** Flutter (Mobile) + Python FastAPI (Backend)  
**Report scope:** What was done, how it was done, what tech was used and why, what was cleaned up, and what remains to build

---

## 1. What Is This Project?

**Khetopedia** is a production-grade mobile application for farmers. It helps them:
- Scan crops for disease and nutrient deficiency using AI/camera
- Analyze soil health (manual lab entry + IoT sensors)
- Get irrigation and fertilizer recommendations
- Monitor field conditions and weather
- Chat with an AI agricultural assistant
- Manage multiple farms and fields

Target users are farmers — including those with limited digital literacy, older Android devices, and poor connectivity — so the design is simple, clear, and fast.

The project is defined by a 51-section **Master Specification** (`docs/MASTER_SPEC.md`) covering every feature, security rule, UI guideline, database schema, and definition of done.

---

## 2. Tech Stack — What We Use and Why

### Flutter (Mobile App)
| Technology | Version | Why |
|---|---|---|
| **Flutter** | SDK ≥3.13 / Dart 3.13.4 | Cross-platform iOS + Android from one codebase |
| **flutter_riverpod** | ^2.6.1 | Reactive state management — safer than setState, cleaner than BLoC |
| **go_router** | ^12.1.3 | Declarative routing with auth redirect guards, named routes, shell routing |
| **dio** | ^5.7.0 | HTTP client with interceptors for auth token injection and refresh |
| **flutter_secure_storage** | ^9.2.2 | Stores JWT tokens in Android Keystore / iOS Keychain — never plain SharedPreferences |
| **google_fonts** | ^6.2.1 | Typography — Inter font family throughout |
| **fl_chart** | ^1.0.0 | Soil/weather/health history charts |
| **flutter_animate** | ^4.5.0 | Subtle, purposeful animations |
| **flutter_svg** | ^2.1.0 | Scalable icons and illustrations |
| **go_router** | ^12.1.3 | Routing |
| **intl** | ^0.20.3 | Localization (English + Hindi) |
| **cached_network_image** | ^3.4.1 | Efficient image loading with caching |
| **shared_preferences** | ^2.3.0 | Theme/locale preference persistence |
| **sqflite** | ^2.3.3 | Local SQLite for offline caching |

### Python Backend (FastAPI)
| Technology | Version | Why |
|---|---|---|
| **FastAPI** | ≥0.115.0 | Async Python API framework — automatic docs, Pydantic validation |
| **SQLAlchemy** (async) | ≥2.0.36 | ORM with async support — parameterized queries prevent SQL injection |
| **asyncpg** | ≥0.30.0 | Async PostgreSQL driver (production) |
| **aiosqlite** | ≥0.20.0 | Async SQLite driver (development/testing) |
| **Argon2-cffi** | ≥23.1.0 | Password hashing — Argon2id is the current gold standard |
| **PyJWT** | ≥2.9.0 | JWT generation and validation with cryptographic signing |
| **Pydantic** | ≥2.9.0 | Schema validation for all request/response bodies |
| **uvicorn** | ≥0.32.0 | ASGI server to run FastAPI |
| **httpx** | ≥0.27.2 | Async HTTP client for external API calls (weather, etc.) |
| **pytest + pytest-asyncio** | ≥8.3.0 | Async-capable test framework |

### Planned (Not Yet Implemented)
- **PostgreSQL** — Production database (currently SQLite for dev)
- **Redis** — Rate limiting, token blocklist, caching
- **PyTorch / TensorFlow** — ML inference for crop/disease detection
- **Object storage (S3-compatible)** — Crop and soil images
- **MQTT** — IoT sensor data ingestion

---

## 3. Flutter Project Architecture

```
lib/
├── main.dart                    ← App entry point, wires theme/locale/router
├── app_router.dart              ← Compatibility re-export shim
├── index.dart                   ← Legacy barrel (all exports commented out)
│
├── core/                        ← Framework-level, feature-agnostic
│   ├── localization/            ← AppLocalizations — EN + HI, no hardcoded strings
│   ├── network/
│   │   ├── api_constants.dart   ← Base URL, timeout constants
│   │   ├── auth_interceptor.dart← Attaches JWT to every request, handles 401 refresh
│   │   ├── dio_client.dart      ← DioClient factory + exception mapper
│   │   └── network_exception.dart ← Sealed exception hierarchy (Timeout/Connection/Server/Unknown)
│   ├── router/
│   │   └── app_router.dart      ← GoRouter with auth redirect guard (reads authStateProvider)
│   └── theme/
│       ├── app_colors.dart      ← Agricultural palette (deep green, earth brown, off-white)
│       ├── app_text_styles.dart ← Typography scale
│       └── app_theme.dart       ← Light + dark ThemeData
│
├── features/                    ← One folder per business feature
│   ├── auth/                    ← Complete (Login, Signup, ForgotPassword, OTP)
│   │   ├── domain/              ← AuthUser, AuthTokens, AuthFailure value objects
│   │   ├── data/                ← AuthRepository (HTTP), TokenStorage (secure)
│   │   ├── application/         ← AuthNotifier (state machine), authStateProvider
│   │   └── presentation/        ← 4 screens with form validation
│   ├── home/                    ← Partial — domain + data done, UI stub
│   ├── fields/                  ← Stub only
│   ├── scan/                    ← Stub only
│   ├── soil/                    ← Stub only
│   └── ai/                      ← Stub only
│
├── shared/                      ← Reusable across all features
│   ├── layout/                  ← AppShell (StatefulShellRoute host), ResponsiveLayout
│   ├── providers/               ← themeProvider, localeProvider
│   └── widgets/                 ← AppButton, AppCard, AppTextField, EmptyState, ErrorView, LoadingView
│
├── components/                  ← 30 reusable UI component pairs (widget + model)
│   └── [30 subdirectories]      ← Each has *_widget.dart + *_model.dart
│
├── screens/                     ← 9 screen implementations
│   └── [9 subdirectories]       ← Each has *_widget.dart + *_model.dart
│
└── flutter_flow/                ← FlutterFlow compatibility shims
    ├── flutter_flow_theme.dart
    ├── flutter_flow_util.dart
    ├── flutter_flow_widgets.dart
    ├── flutter_flow_charts.dart
    └── flutter_flow_icon_button.dart
```

**Every feature follows the same 4-layer clean architecture:**
```
domain/     ← Pure Dart models, no Flutter, no HTTP
data/       ← Repository implementations, API calls, local storage
application/← Riverpod Notifiers (state machines), business logic
presentation/← Flutter widgets, screens, only reads state — never writes data directly
```

---

## 4. Backend Architecture

```
backend/
├── app/
│   ├── main.py                  ← FastAPI app factory, CORS, middleware
│   ├── core/
│   │   ├── config.py            ← Settings via pydantic-settings (env vars)
│   │   ├── database.py          ← Async SQLAlchemy engine + session factory
│   │   └── security.py          ← JWT creation/validation, Argon2id hashing
│   ├── api/
│   │   └── v1/
│   │       ├── api.py           ← Router assembly
│   │       └── endpoints/       ← 10 endpoint modules (see below)
│   ├── models/                  ← SQLAlchemy ORM models (9 models)
│   ├── schemas/                 ← Pydantic request/response schemas (12 schema files)
│   └── services/                ← Business logic layer (9 service files)
└── tests/
    ├── conftest.py              ← Pytest fixtures, test database setup
    ├── test_auth_and_dashboard.py
    └── test_all_features.py
```

### Backend API Endpoints (10 modules, all under `/api/v1/`)
| Module | Endpoints |
|---|---|
| `auth.py` | POST /register, /login, /refresh, /logout |
| `users.py` | GET/PATCH /users/me, profile management |
| `farms.py` | CRUD /farms — owner-scoped |
| `sensors.py` | Sensor registration, readings |
| `crop_scans.py` | Upload + async scan submission |
| `soil.py` | Soil test entries, measurements |
| `recommendations.py` | Irrigation + fertilizer recommendations |
| `weather.py` | Current weather, forecast |
| `dashboard.py` | Summary endpoint for home screen |
| `ai.py` | AI assistant conversation |

---

## 5. Components — What Was Built (30 Components)

Each component lives in `lib/components/<name>/` and has two files:
- `*_widget.dart` — The Flutter widget
- `*_model.dart` — The state/controller model

| Component | Purpose |
|---|---|
| `action_step` | Step-by-step guidance card |
| `advice_banner` | Inline advisory banner |
| `alert_item` | Alert row (disease / moisture / weather) |
| `auth_tab` | Login/Signup tab switcher |
| `bottom_nav` | Main bottom navigation bar |
| `bottom_nav_child` / `bottom_nav_child2` | Nav bar item variants |
| `button` | Reusable app button with variants |
| `chat_bubble_ai` / `chat_bubble_user` | AI chat message bubbles |
| `farm_stat_card` | Farm statistics display card |
| `feature_item` | Feature list row item |
| `field_card` | Field summary card |
| `guidance_step` | Guided scanning instruction step |
| `metric_badge` | Small inline metric pill |
| `metric_card` / `metric_card2` | Dashboard metric display cards |
| `nav_item` | Individual bottom nav item |
| `profile_option` | Settings/profile option row |
| `quick_action` | Quick-action button (Scan, Soil, Fields, AI) |
| `quick_suggestion` | AI suggestion chip |
| `recommendation_item` | Recommendation list row |
| `scan_corner` | Camera scan overlay corner |
| `severity_indicator` | Color-coded severity badge |
| `social_btn` | OAuth/social login button |
| `switch_component` | Toggle switch component |
| `tab_group` / `tab_item` | Horizontal tab group |
| `text_field` | Form text field with variants |
| `toxicity_item` | Toxicity reading row |

---

## 6. Screens — What Was Built (9 Screens)

Each screen in `lib/screens/<name>/` corresponds to a major app section:

| Screen | Spec Section | Status |
|---|---|---|
| `splash_onboarding` | §4 Splash | UI components built |
| `authentication` | §4 Auth | Full flow — Login, Signup, ForgotPassword, OTP |
| `home_dashboard` | §8 Dashboard | Domain + data done; UI being built |
| `crop_scanner` | §9/10 Crop AI | Components built; ML pipeline pending |
| `analysis_results` | §10/15 Results | Result display components built |
| `my_fields` | §19/20 Fields | Field card components built |
| `soil_toxicity_lab` | §12/14 Soil | Toxicity display components built |
| `irrigation_fertilizer_advice` | §16/17 Recommendations | Advice display built |
| `ai_agri_assistant` | §22 AI Assistant | Chat bubbles built |

---

## 7. What Was Cleaned Up Today — The Duplicate Files

### What Was Found
The project root (`f:\R-Project\`) contained **41 loose files** — 40 `.dart` files and 1 `.zip` — that were left over from the original FlutterFlow design tool export. Examples:
- `TextField.dart`, `Button.dart`, `CropScanner.dart`, `HomeDashboard.dart`, `Authentication.dart` … (40 total)
- `.dart_tool.zip`

### Why They Were Duplicates / Unwanted
These files were the **original FlutterFlow-generated prototypes**. They had several problems:

1. **Not imported anywhere** — A search of all 144 `.dart` files in `lib/` confirmed zero imports of these root-level files.
2. **Old FlutterFlow code style** — Used old patterns like `widget!.value` (null-bang on widget properties), `import '/flutter_flow/...'` (absolute path style), and `import 'package:provider/provider.dart'` — patterns not used in the production codebase.
3. **Replaced by cleaner versions** — Every one had a proper counterpart already in `lib/components/` or `lib/screens/` with correct imports, clean patterns, and proper architecture.
4. **Comparison example** — `TextField.dart` (root): 350+ lines with deeply nested conditional chains for border radius values. `lib/components/text_field/text_field_widget.dart` (kept): 180 lines, clean helper getters, readable conditionals, correct null safety.
5. **`.dart_tool.zip`** — A stale archive of the `.dart_tool/` directory; the live directory was already present.

### What Was Deleted (41 files)
```
ActionStep.dart           AdviceBanner.dart         AIAgriAssitant.dart
AlertItem.dart            AnalysisResults.dart      Authentication.dart
AuthTab.dart              BottomNav.dart            BottomNavChild.dart
BottomNavChild2.dart      Button.dart               ChatBubbleAI.dart
ChatBubbleUser.dart       CropScanner.dart          FarmStatCard.dart
FeatureItem.dart          FieldCard.dart            GuidanceStep.dart
HomeDashboard.dart        IrrigationFertilizerAdvice.dart  metricbadge.dart
MetricCard.dart           MetricCard2.dart          MyFields.dart
NavItem.dart              ProfileOption.dart        QuickAction.dart
QuickSuggestion.dart      RecommendationItem.dart   ScanCorner.dart
SeverityIndicator.dart    SocialBtn.dart            SoilToxicityLab.dart
SplashOnBoarding.dart     SwitchComponent.dart      TabGroup.dart
TabItem.dart              TextField.dart            ToxicityItem.dart
UserProfileSetting.Dart   .dart_tool.zip
```

### What Was Kept
Everything inside `lib/` — all 144 production `.dart` files — was confirmed clean and retained.

---

## 8. Current Completion Status by Stage

Based on `docs/DEVELOPMENT_PLAN.md` and the 10-stage plan in `docs/MASTER_SPEC.md §50`:

| Stage | Description | Status | % Done |
|---|---|---|---|
| **Stage 1** | Flutter Foundation (Theme, Routing, Localization, Auth) | 🟡 In Progress | ~65% |
| **Stage 2** | Backend (FastAPI, DB, Auth API, Users, Farms, Fields) | 🟡 In Progress | ~40% |
| **Stage 3** | Dashboard (Weather, Field info, Health, Alerts) | 🟡 Partial | ~20% |
| **Stage 4** | Crop AI (Upload, Quality check, Detection) | 🔴 Not started | 0% |
| **Stage 5** | Soil (Manual entry, Analysis, History, Toxicity) | 🔴 Not started | 0% |
| **Stage 6** | Recommendations (Irrigation, Fertilizer, Scoring) | 🔴 Not started | 0% |
| **Stage 7** | AI Assistant (Knowledge base, Retrieval, Safety) | 🔴 Not started | 0% |
| **Stage 8** | IoT Sensors (Registration, Readings, Real-time) | 🔴 Not started | 0% |
| **Stage 9** | Security Hardening (Rate limits, Audit, Validation) | 🟡 Partial | ~15% |
| **Stage 10** | Production (CI/CD, Monitoring, Crash reporting) | 🔴 Not started | 0% |

---

## 9. What Is Done — Detailed Breakdown

### ✅ Flutter Core (Complete)
- **Theme system** — Light + dark `ThemeData`, agricultural color palette (deep green `#1B5E20`, earth brown `#5D4037`, off-white backgrounds), Inter typography, color-meaning conventions (green=good, amber=attention, red=critical)
- **GoRouter** — Named routes, `StatefulShellRoute` with 5 shell branches (Home, Scan, Fields, Soil, AI), auth redirect guard reads Riverpod state and routes unauthenticated users to login
- **Localization** — Custom `AppLocalizations` with English and Hindi, no hardcoded user-visible strings anywhere
- **Networking** — `DioClient` with `AuthInterceptor` (auto-attaches JWT, handles 401 → refresh → retry), sealed `NetworkException` hierarchy, all timeouts configured
- **Secure storage** — `TokenStorage` wrapping `flutter_secure_storage` (Android Keystore / iOS Keychain)

### ✅ Authentication Feature (Complete — Flutter side)
- Login screen with email/password validation
- Signup screen with name, email, phone, password, confirm password, language preference
- Forgot password screen (user-enumeration-safe messaging)
- OTP/verify screen for password reset
- `AuthState` sealed class: `Loading` → `Unauthenticated` → `Authenticated` / `Error`
- `AuthNotifier` state machine managing login/logout/refresh
- `AuthRepository` making real HTTP calls to backend auth endpoints
- `TokenStorage` persisting access + refresh tokens securely

### ✅ Shared Widget Library (Complete)
- `AppButton` — primary, secondary, outline, danger variants
- `AppTextField` — with label, helper, error, leading/trailing icon
- `AppCard` — base card container
- `EmptyState` — icon + message + optional action button
- `ErrorView` — error message + retry button
- `LoadingView` — centered loading indicator
- `AppShell` — `StatefulShellRoute` host with bottom navigation
- `ResponsiveLayout` — adapts to phone vs tablet

### ✅ Backend Scaffold (Partial — structure complete)
- FastAPI app with CORS, middleware, versioned routing
- Async SQLAlchemy with both PostgreSQL (production) and SQLite (development) drivers
- Argon2id password hashing (never bcrypt-MD5, never plain)
- JWT auth with access + refresh token model
- 10 API endpoint modules covering all feature areas
- 9 SQLAlchemy ORM models
- 12 Pydantic schema files for request/response validation
- 9 service files with business logic
- 2 test files with async test setup

---

## 10. What Is NOT Done — What Remains to Build

### Stage 1 Blockers (Complete Flutter Foundation)
1. **Splash screen** — Logo, tagline, auth-state check on startup
2. **Profile feature** — `lib/features/profile/` — display and edit user profile
3. **Settings feature** — `lib/features/settings/` — theme toggle, language, notifications, privacy
4. **Fix BUG-001** — `DashboardNotifier` must extend `AutoDisposeAsyncNotifier` not `AsyncNotifier` (type bound compile error blocking Stage 3)

### Stage 2 (Backend — Partially Built, Needs Completion)
5. **Database migrations** — Alembic setup, initial migration, all tables from MASTER_SPEC §26
6. **PostgreSQL connection** — Switch from SQLite dev DB to real PostgreSQL
7. **Auth endpoints fully tested** — Register, login, refresh, logout end-to-end
8. **Farm + field CRUD** — All endpoints with server-side ownership checks
9. **Redis** — Rate limiting, token blocklist for logout
10. **Object storage** — For crop and soil images (S3-compatible)

### Stage 3 (Dashboard UI)
11. **Home screen widgets** — Weather card, crop health card, soil status card, alerts list, quick actions
12. **Dashboard API** — Real backend data flowing to `GET /api/v1/dashboard/summary`
13. **Weather integration** — External weather API, backend caching, "Last updated" timestamps
14. **Fields list screen** — List all farms/fields with add/edit

### Stage 4 (Crop AI)
15. **Camera + gallery permission flow**
16. **Image capture UI** — Guidance overlay, preview, retake, submit
17. **Client-side image quality pre-check** — Blur detection before upload
18. **Python ML service** — `ml/` directory with crop detection + disease detection models
19. **Async inference pipeline** — Job submission → polling → result display on Flutter
20. **Model registry** — Version tracking for deployed models

### Stage 5 (Soil)
21. **Soil data entry form** — pH, EC, moisture, NPK, heavy metals, etc.
22. **Soil history charts** — `fl_chart` time-series for pH, EC, NPK over time
23. **Toxicity alert display** — Color-coded thresholds (GREEN/YELLOW/ORANGE/RED)
24. **Backend soil endpoints** — Fully connected to database

### Stage 6 (Recommendations)
25. **Irrigation recommendation engine** — Deterministic model (crop + stage + soil moisture + weather)
26. **Fertilizer recommendation engine** — Based on validated regional agronomic guidelines
27. **Crop health scoring** — Versioned scoring model stored with each score
28. **Recommendation display** — Flutter UI for all recommendation types

### Stage 7 (AI Assistant)
29. **LLM integration** — Backend LLM API (OpenAI / local model) with safety guardrails
30. **Field context injection** — Inject user's field data into AI context
31. **Knowledge retrieval** — Approved agricultural knowledge base
32. **Conversation persistence** — Store/retrieve chat history per user
33. **AI chat screen** — Flutter chat UI fully wired to backend

### Stage 8 (IoT Sensors)
34. **Sensor registration** — Register ESP32/IoT device per field
35. **MQTT ingestion** — Secure sensor data ingestion pipeline
36. **Real-time readings** — Live sensor data display in Flutter
37. **Sensor history charts** — Time-series soil sensor readings

### Stage 9 (Security Hardening)
38. **Backend rate limiting** — Per-endpoint rate limits via Redis
39. **Image upload validation** — MIME check, size limit, randomized storage IDs
40. **Audit logs** — Log all auth events, data changes, AI queries
41. **Security review** — Pen-test checklist pass

### Stage 10 (Production)
42. **CI/CD pipeline** — GitHub Actions or equivalent
43. **Crash reporting** — Sentry or Firebase Crashlytics
44. **Performance monitoring** — APM for backend, Flutter performance overlay in staging
45. **Production PostgreSQL** — Managed database, connection pooling
46. **Tests** — Widget tests, state tests, repository tests, backend unit + integration tests

---

## 11. How Many Screens / Slides — Full Map

The app has **14 distinct screens** as defined in the spec:

| # | Screen | Route | Feature Stage |
|---|---|---|---|
| 1 | Splash | `/` (startup) | Stage 1 |
| 2 | Login | `/login` | Stage 1 ✅ |
| 3 | Signup | `/signup` | Stage 1 ✅ |
| 4 | Forgot Password | `/forgot-password` | Stage 1 ✅ |
| 5 | Verify OTP | `/verify-otp` | Stage 1 ✅ |
| 6 | Home Dashboard | `/home` | Stage 3 |
| 7 | Crop Scanner | `/scan` | Stage 4 |
| 8 | Analysis Results | `/scan/results` | Stage 4 |
| 9 | My Fields | `/fields` | Stage 3 |
| 10 | Field Detail | `/fields/:id` | Stage 3 |
| 11 | Soil Toxicity Lab | `/soil` | Stage 5 |
| 12 | Irrigation & Fertilizer Advice | `/recommendations` | Stage 6 |
| 13 | AI Agri Assistant | `/ai` | Stage 7 |
| 14 | Profile + Settings | `/profile`, `/settings` | Stage 1 |

---

## 12. Architecture Decisions — Why We Did It This Way

| Decision | Choice | Reason |
|---|---|---|
| State management | Riverpod | Type-safe, testable, no BuildContext required for state reads, compiles away with tree shaking |
| Routing | go_router | Declarative, deep-link ready, `StatefulShellRoute` for bottom nav with branch state preservation |
| Auth tokens | `flutter_secure_storage` | Hardware-backed on Android (Keystore), Keychain on iOS — never SharedPreferences |
| Password hashing | Argon2id | Current OWASP recommendation; memory-hard, resistant to GPU attacks |
| JWT | Access + refresh pair | Short-lived access (15min), long-lived refresh (7 days), refresh auto-retried by interceptor |
| HTTP client | Dio + interceptors | Middleware pattern for auth, logging, and error mapping in one place |
| Clean architecture layers | domain/data/application/presentation | Each layer testable independently; UI never touches HTTP directly |
| Colors | Agricultural palette | Green=health, amber=attention, red=critical — consistent with real farm management software |
| No hardcoded strings | `AppLocalizations` | EN + HI supported from day 1; adding new languages requires only one new file |
| SQLite for dev | aiosqlite | Zero-setup local development without needing a running PostgreSQL instance |
| asyncio throughout backend | FastAPI + asyncpg | Handle concurrent requests without blocking threads; critical for image upload + ML job queuing |

---

## 13. Summary

**What we did:** Built the complete Flutter foundation (theme, routing, localization, auth, shared widgets, network layer) and a backend scaffold with FastAPI, SQLAlchemy, Argon2id auth, and 10 API endpoint modules. Also cleaned up 41 leftover FlutterFlow prototype files from the project root that were never imported into the real app.

**What we're building:** A production-grade AI agriculture app with crop disease detection, soil analysis, IoT sensor integration, an AI assistant, and real-time farm management — all backed by real database data with no fake values.

**What's left:** The core shell is solid. The next priorities are fixing BUG-001 (Riverpod type error), building the splash + profile + settings screens to close Stage 1, completing the backend database/auth layer, then building the Dashboard UI in Stage 3. Stages 4–10 (Crop AI, Soil, Recommendations, AI Assistant, IoT, Security, Production) follow in sequence.

**Total files today:** 144 `.dart` files in `lib/`, 10 backend endpoint modules, 9 models, 9 services, 2 test files.  
**Cleaned up:** 41 duplicate/legacy files deleted from project root.
