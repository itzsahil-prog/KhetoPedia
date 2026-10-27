# Khetopedia — Development Plan

> Generated against `docs/MASTER_SPEC.md` (§50 — Development Order).
> Last updated: 2026-10-06

---

## 1. Environment Snapshot

| Item | Value |
|---|---|
| Flutter SDK | 3.47.5 (stable) |
| Dart SDK | 3.13.4 |
| State management | `flutter_riverpod ^2.6.1` |
| Routing | `go_router ^12.1.3` |
| Networking | `dio ^5.7.0` |
| Secure storage | `flutter_secure_storage ^9.2.2` |
| Localization | Custom `AppLocalizations` (EN + HI) |
| Charts | `fl_chart ^1.0.0` |
| Backend | **None — no backend exists yet** |
| Tests | **None — no test files exist yet** |

---

## 2. Current Repository Structure

```
f:/R-Project/
├── lib/
│   ├── main.dart                     ✅ Complete — wires theme/locale/router
│   ├── app_router.dart               ⚠️  Legacy FlutterFlow stub — superseded
│   ├── index.dart                    ⚠️  Legacy FlutterFlow barrel — superseded
│   │
│   ├── core/
│   │   ├── localization/             ✅ AppLocalizations, EN + HI strings
│   │   ├── network/
│   │   │   ├── api_constants.dart    ✅ Versioned endpoint constants
│   │   │   ├── auth_interceptor.dart ✅ Token attach + 401 refresh logic
│   │   │   ├── dio_client.dart       ✅ DioClient factory + exception mapper
│   │   │   └── network_exception.dart✅ Sealed NetworkException hierarchy
│   │   ├── router/
│   │   │   └── app_router.dart       ✅ GoRouter with auth redirect guard
│   │   └── theme/
│   │       ├── app_colors.dart       ✅ Agricultural color palette
│   │       ├── app_text_styles.dart  ✅ Typography scale
│   │       └── app_theme.dart        ✅ Light + dark ThemeData
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── domain/               ✅ AuthUser, AuthTokens, AuthFailure
│   │   │   ├── data/                 ✅ AuthRepository (HTTP), TokenStorage
│   │   │   ├── application/          ✅ AuthNotifier, AuthState (sealed)
│   │   │   └── presentation/         ✅ Login, Signup, ForgotPassword, OTP screens
│   │   │
│   │   ├── home/
│   │   │   ├── domain/               ✅ DashboardSummary, AlertItem, FieldSummary, QuickStat
│   │   │   ├── data/                 ✅ DashboardRepository (HTTP stub)
│   │   │   ├── application/          ⚠️  DashboardNotifier — type-bound compile error (§5)
│   │   │   └── presentation/         🔴 Folder exists but has no widget files
│   │   │
│   │   ├── fields/                   🔴 Stub only — empty Scaffold
│   │   ├── scan/                     🔴 Stub only — empty Scaffold
│   │   ├── soil/                     🔴 Stub only — empty Scaffold
│   │   └── ai/                       🔴 Stub only — empty Scaffold
│   │
│   └── shared/
│       ├── layout/                   ✅ AppShell (StatefulShellRoute host), ResponsiveLayout
│       ├── providers/                ✅ ThemeProvider, LocaleProvider
│       └── widgets/                  ✅ AppButton, AppCard, AppTextField,
│                                         EmptyState, ErrorView, LoadingView
│
├── docs/
│   ├── MASTER_SPEC.md                ✅ Source of truth (51 sections)
│   └── DEVELOPMENT_PLAN.md           ✅ This file
│
└── [root]/*.dart                     ⚠️  ~40 legacy FlutterFlow component files
    (HomeDashboard.dart, CropScanner.dart, Authentication.dart, etc.)
    → NOT wired into the production app.
    → Visual reference only. Do NOT import or depend on them.
```

---

## 3. Stage-by-Stage Assessment

### Stage 1 — Flutter Foundation
**Spec:** Theme · Routing · Localization · Auth · Profile · Settings

| Component | Status | Notes |
|---|---|---|
| Theme system (light + dark) | ✅ Done | `AppTheme.light/dark`, agricultural palette |
| Typography scale | ✅ Done | `AppTextStyles` with Google Fonts |
| GoRouter with auth redirect guard | ✅ Done | Bridges Riverpod auth state to GoRouter |
| `StatefulShellRoute` shell + BottomNav | ✅ Done | 5 branches wired in `AppShell` |
| Localization (EN + HI) | ✅ Done | Custom `AppLocalizations`, no hardcoded strings |
| Auth domain + state machine | ✅ Done | Sealed `AuthState`, `AuthNotifier`, `AuthFailure` |
| Auth screens (Login, Signup, Forgot, OTP) | ✅ Done | Validators, form keys, proper error display |
| Secure token storage | ✅ Done | `flutter_secure_storage` via `TokenStorage` |
| Splash screen | 🔴 Missing | No startup/splash screen exists |
| Profile screen | 🔴 Missing | No `features/profile/` folder exists |
| Settings screen | 🔴 Missing | No `features/settings/` folder exists |

**Stage 1 completion: ~65%**
Blocker: Profile, Settings, and Splash are required before Stage 1 can be closed.

---

### Stage 2 — Backend
**Spec:** FastAPI · PostgreSQL · Auth · Users · Farms · Fields

| Component | Status | Notes |
|---|---|---|
| FastAPI project scaffold | 🔴 Missing | No `backend/` directory exists |
| PostgreSQL schema + Alembic migrations | 🔴 Missing | |
| Auth endpoints (register, login, refresh, logout) | 🔴 Missing | Flutter client is ready; backend is not |
| User/profile endpoints | 🔴 Missing | |
| Farm endpoints (CRUD) | 🔴 Missing | |
| Field endpoints (CRUD) | 🔴 Missing | |
| JWT + Argon2id password hashing | 🔴 Missing | |
| Redis (rate limiting, caching) | 🔴 Missing | |
| Object storage integration | 🔴 Missing | |

**Stage 2 completion: 0%**
Blocker: All stages from 3 onward require a working backend.

---

### Stage 3 — Dashboard
**Spec:** Weather · Field info · Health summary · Alerts

| Component | Status | Notes |
|---|---|---|
| Dashboard domain models | ✅ Done | `DashboardSummary`, `AlertItem`, `FieldSummary`, `QuickStat` |
| Dashboard HTTP repository | ✅ Done | Maps to `GET /api/v1/dashboard/summary` |
| `DashboardNotifier` (AsyncNotifier) | ⚠️  Broken | `type_argument_not_matching_bounds` — fix required |
| Dashboard UI widgets | 🔴 Missing | `home/presentation/widgets/` is empty |
| Home screen composition | 🔴 Missing | `home_screen.dart` is a stub |
| Weather card | 🔴 Missing | |
| Crop health card | 🔴 Missing | |
| Soil status card | 🔴 Missing | |
| Active alerts section | 🔴 Missing | |
| Quick actions bar | 🔴 Missing | |
| Pull-to-refresh | 🔴 Missing | |
| Backend: dashboard + weather API | 🔴 Missing | Depends on Stage 2 |

**Stage 3 completion: ~20%**
Blocker: Stage 2 backend + BUG-001 fix + UI widget implementation.

---

### Stage 4 — Crop AI
**Spec:** Upload · Quality check · Crop detection · Disease detection

| Component | Status | Notes |
|---|---|---|
| Camera/gallery permission handling | 🔴 Missing | `scan/` is an empty stub |
| Image quality pre-check (client-side) | 🔴 Missing | |
| Crop scanner UI | 🔴 Missing | |
| Disease detection result UI | 🔴 Missing | |
| ML inference API client | 🔴 Missing | |
| Python ML service (PyTorch/TensorFlow) | 🔴 Missing | No `ml/` directory |
| Async job polling/subscription | 🔴 Missing | |
| Model registry | 🔴 Missing | |

**Stage 4 completion: 0%**

---

### Stage 5 — Soil
**Spec:** Manual entry · Soil analysis · History · Toxicity

| Component | Status | Notes |
|---|---|---|
| Soil screen | 🔴 Missing | `soil/` is an empty stub |
| Manual soil data entry form | 🔴 Missing | |
| Soil measurement history chart | 🔴 Missing | |
| Toxicity alert display | 🔴 Missing | |
| Backend soil endpoints | 🔴 Missing | Depends on Stage 2 |

**Stage 5 completion: 0%**

---

### Stage 6 — Recommendations
**Spec:** Irrigation · Fertilizer · Crop health scoring · Alerts

| Component | Status | Notes |
|---|---|---|
| Irrigation recommendation engine | 🔴 Missing | |
| Fertilizer recommendation engine | 🔴 Missing | |
| Crop health scoring engine | 🔴 Missing | |
| Alert notification system | 🔴 Missing | |
| Flutter recommendation display | 🔴 Missing | |

**Stage 6 completion: 0%**

---

### Stage 7 — AI Assistant
**Spec:** Knowledge base · Retrieval · Field context · Safety

| Component | Status | Notes |
|---|---|---|
| AI assistant screen | 🔴 Missing | `ai/` is an empty stub |
| LLM integration (backend) | 🔴 Missing | |
| Field-context injection | 🔴 Missing | |
| Safety/grounding checks | 🔴 Missing | |
| Conversation persistence | 🔴 Missing | |

**Stage 7 completion: 0%**

---

### Stage 8 — IoT Sensors
**Spec:** Sensor registration · Readings · Real-time · History

| Component | Status | Notes |
|---|---|---|
| All IoT components | 🔴 Missing | |

**Stage 8 completion: 0%**

---

### Stage 9 — Security Hardening
**Spec:** Rate limits · File validation · Authorization · Audit logs

| Component | Status | Notes |
|---|---|---|
| No API keys in Flutter client | ✅ Done | `ApiConstants` holds paths only; zero credentials |
| Client-side input validation | ✅ Done | Auth forms validated; repo data validated |
| Secure token storage | ✅ Done | `flutter_secure_storage` |
| HTTPS-only networking configured | ✅ Configured | `DioClient`; backend must enforce |
| Backend rate limiting | 🔴 Missing | Depends on Stage 2 |
| Image upload validation (MIME, size) | 🔴 Missing | |
| Audit log table + entries | 🔴 Missing | |
| Security review | 🔴 Missing | |

**Stage 9 completion: ~15% (Flutter client side only)**

---

### Stage 10 — Production
**Spec:** CI/CD · Monitoring · Crash reporting · Optimization

**Stage 10 completion: 0%**

---

## 4. Current State Summary

### Solid Foundation — Keep and Build On
- `lib/core/` — Theme, localization, networking, routing: complete and production-quality.
- `lib/features/auth/` — All four layers (domain, data, application, presentation): production-quality.
- `lib/shared/` — Shell layout, base widget set, theme/locale providers: complete.
- `pubspec.yaml` — All dependencies resolved; no conflicts.

### Partially Complete — Fix Before Extending
- `DashboardNotifier` — type bound compile error; must be fixed (BUG-001) before home screen can be built.
- `home_screen.dart` — exists as a stub at the wrong path; proper presentation layer belongs in `features/home/presentation/`.

### Missing Flutter Modules — Build in Order
1. `features/profile/` — Stage 1
2. `features/settings/` — Stage 1
3. Splash screen — Stage 1
4. `features/home/presentation/` widgets — Stage 3
5. `features/fields/` — Stage 3/6
6. `features/scan/` — Stage 4
7. `features/soil/` — Stage 5
8. `features/ai/` — Stage 7

### Missing Backend — Build Entirely
- Python/FastAPI application under `backend/`
- PostgreSQL schema + Alembic migrations
- All API endpoint groups
- Python ML service under `ml/`
- Redis, object storage

### Missing Tests — Build in Parallel
- No test files exist anywhere in the project.

### Legacy Artifacts — Do Not Use
- `f:/R-Project/*.dart` — ~40 FlutterFlow-generated files at the project root. Not imported by the production app. Visual reference only; do not integrate.

---

## 5. Blocking Issues

### BUG-001 — DashboardNotifier Type Bound Error
**File:** `lib/features/home/application/dashboard_provider.dart`
**Error:** `type_argument_not_matching_bounds` on `AsyncNotifier<DashboardSummary>`
**Root cause:** `DashboardNotifier extends AsyncNotifier<DashboardSummary>` is registered with `AsyncNotifierProvider.autoDispose<DashboardNotifier, DashboardSummary>`. The autoDispose variant requires the notifier to extend `AutoDisposeAsyncNotifier`, not the base `AsyncNotifier`.
**Fix:** Change `extends AsyncNotifier<DashboardSummary>` to `extends AutoDisposeAsyncNotifier<DashboardSummary>`.
**Priority:** P0 — blocks all Stage 3 UI work.

---

## 6. Recommended Implementation Order

Follow the Stage order from MASTER_SPEC §50. Each item is a discrete, shippable unit.

### Phase A — Complete Stage 1 (Flutter Foundation)
1. **Fix BUG-001** — `DashboardNotifier` autoDispose type alignment.
2. **Splash screen** — Logo, tagline, auth-state check, then route to home or login.
3. **Profile feature** — `features/profile/` with full clean-arch layers. Placeholder HTTP calls; real backend wired in Phase B.
4. **Settings feature** — `features/settings/` with theme, language, notification toggles. Persist with `SharedPreferences`.
5. **Localization** — Add all missing keys for Profile and Settings screens.
6. **First tests** — Widget tests for Login, Signup, and Settings screens.

### Phase B — Stage 2 (Backend)
7. **FastAPI scaffold** — `backend/` directory, `pyproject.toml`, structure per MASTER_SPEC §25.
8. **Database schema** — Core tables (`users`, `profiles`, `farms`, `fields`) + Alembic migrations.
9. **Auth endpoints** — `POST /api/v1/auth/register`, `/login`, `/refresh`, `/logout` with Argon2id + JWT.
10. **User/profile endpoints** — `GET/PATCH /api/v1/users/me`.
11. **Farm + field endpoints** — CRUD with server-side ownership checks.
12. **Wire Flutter auth** — Point `DioClient` base URL at real backend; remove any stubs.

### Phase C — Stage 3 (Dashboard)
13. **Dashboard UI** — Implement `home/presentation/` widgets: weather card, crop health, soil status, alerts, quick actions.
14. **Dashboard API** — Real `GET /api/v1/dashboard/summary` backed by PostgreSQL.
15. **Weather integration** — Backend provider + caching + "Last updated" timestamp.
16. **Fields feature UI** — `features/fields/` with add/edit/list screens.

### Phase D — Stage 4 (Crop AI)
17. **Scan feature UI** — Camera guidance, image preview, confirm + submit flow.
18. **Client-side image quality check** — Blur + size pre-filter before upload.
19. **Python ML service** — `ml/` directory: image quality, crop detection, disease detection models.
20. **Async inference pipeline** — Job submission → polling → result display.

### Phase E — Stages 5–10
Proceed sequentially. Each stage depends on the previous.

21. Soil analysis (Stage 5)
22. Recommendations engine (Stage 6)
23. AI assistant (Stage 7)
24. IoT sensors (Stage 8)
25. Security hardening pass (Stage 9)
26. Production — CI/CD, crash reporting, monitoring (Stage 10)

---

## 7. Definition of Done Per Feature

Per MASTER_SPEC §51, a feature is complete only when all of the following are present:

- Flutter UI — Loading, Success, Empty, Error, Offline, Unauthorized states
- Backend API endpoint — authenticated, authorized, validated
- Database record — persisted via SQLAlchemy ORM
- Input validation — both client-side and server-side
- Security — no credentials in Flutter, HTTPS enforced, parameterized queries
- Tests — widget test + repository unit test + backend unit test
- Localization — no hardcoded user-visible strings
- Real data flow — no mocked or hardcoded values in the production path

---

## 8. Architecture Conventions

These patterns are established in the codebase and must be followed for every new feature:

| Concern | Pattern |
|---|---|
| State management | Riverpod `AutoDisposeAsyncNotifier` / `Notifier` / `Provider` |
| Feature structure | `domain/` → `data/` → `application/` → `presentation/` |
| Network results | Named record `({String? error, T? value})` |
| Exception handling | `NetworkException` sealed hierarchy via `DioClient.mapException()` |
| Secure storage | `TokenStorage` wrapping `flutter_secure_storage` |
| Routing | Named routes via `AppRoutes` + `AppPaths` constants |
| Localization | `AppLocalizations.of(context)` — never string literals |
| Auth guard | GoRouter redirect reading `authStateProvider` |
| Auto-dispose | Use `autoDispose` variants for all screen-scoped providers |

---

*This plan is a living document. Update section 3 statuses as each stage is completed.*
