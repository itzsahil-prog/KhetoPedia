# Implementation Plan: ML Service for Crop Disease Detection

## Project Context

**Project Type:** Python FastAPI backend with async SQLAlchemy ORM  
**Language:** Python 3.11+  
**Build System:** pip with pyproject.toml dependencies  
**Test Framework:** pytest with pytest-asyncio  
**Database:** SQLAlchemy async (PostgreSQL/SQLite)  
**Storage:** S3-compatible (boto3) or filesystem fallback  
**Current State:** Backend has placeholder ML logic in `crop_scanner_service.py` using hardcoded diagnostic dictionaries

### Key Project Patterns Discovered

1. **Service Architecture:** Singleton service classes with static methods (e.g., `storage_service`, `image_service`, `crop_scanner_service`)
2. **Async Everywhere:** All database and I/O operations use `async`/`await`
3. **Configuration:** Centralized in `app/core/config.py` with Pydantic Settings from `.env`
4. **Error Handling:** HTTPException with status codes and descriptive error messages
5. **Storage Abstraction:** Storage service switches between S3 and filesystem based on `USE_S3` config
6. **Image Validation:** MIME type checking with python-magic, size limits (5KB - 10MB)
7. **Test Pattern:** Pytest async tests in `tests/` directory, using in-memory SQLite, independent test users
8. **Models & Schemas:** SQLAlchemy models in `app/models/`, Pydantic schemas in `app/schemas/`

### Verification Commands

- **Install Dependencies:** `pip install -e .` (installs from pyproject.toml)
- **Run All Tests:** `pytest tests/ -v`
- **Run Specific Test:** `pytest tests/test_all_features.py::test_crop_scan_upload -v`
- **Start Server:** `uvicorn app.main:app --reload`

### Environment Constraints

- No GPU assumed (CPU inference is default)
- Storage uses either S3 or local filesystem (`uploads/` directory)
- Redis is optional (`USE_REDIS=false` by default)
- No ML dependencies currently installed

---

## Architecture Decisions

### 1. **ML Framework Choice: PyTorch**

**Decision:** Use PyTorch with torchvision for the ML implementation.

**Rationale:** 
- PyTorch has excellent model zoo (torchvision.models) with pre-trained models
- Strong ecosystem for image classification (ResNet, EfficientNet, Vision Transformers)
- Easy CPU/GPU switching with `.to(device)`
- Better Python integration than TensorFlow for FastAPI async patterns
- Lighter weight than TensorFlow for deployment

### 2. **Model Strategy: Pre-trained + Placeholder Fine-tuning**

**Decision:** Start with a pre-trained ResNet50 classifier and create a mapping layer to disease classes. Include infrastructure for custom model loading.

**Rationale:**
- Real crop disease models require specialized datasets (PlantVillage, custom labeled data)
- Pre-trained ImageNet models provide feature extraction capability
- Placeholder implementation allows testing full pipeline while waiting for domain-specific models
- Architecture supports dropping in fine-tuned models later without code changes

### 3. **Model Loading: Singleton with Lazy Initialization**

**Decision:** Load model once at first inference request (lazy loading), store in module-level singleton.

**Rationale:**
- FastAPI lifespan loads database/Redis, but model loading can be heavy
- Lazy loading prevents startup delays if ML service isn't immediately needed
- Singleton ensures model loaded once per worker process (memory efficient)
- Thread-safe with async lock for concurrent first requests

### 4. **Image Preprocessing: Torchvision Transforms**

**Decision:** Standard ImageNet normalization pipeline (resize → 224x224, normalize with ImageNet mean/std).

**Rationale:**
- Matches training preprocessing for pre-trained models
- torchvision.transforms provides battle-tested implementations
- PIL/Pillow already in use via python-magic dependency chain

### 5. **Prediction Caching Strategy**

**Decision:** Cache predictions by image content hash (SHA256) in Redis (if available) with 7-day TTL, or skip caching if Redis disabled.

**Rationale:**
- Identical images (re-uploads) get instant responses
- SHA256 prevents cache poisoning from filename-based keys
- 7-day TTL balances cache hit rate with model updates
- Graceful degradation without Redis matches project pattern

### 6. **Batch Processing Support**

**Decision:** Add batch inference method that processes multiple images in single forward pass with configurable batch size.

**Rationale:**
- Enables future bulk upload features
- More efficient GPU utilization (when available)
- Current single-image API calls batch size of 1
- Infrastructure ready for future scaling

### 7. **Model Versioning & Storage**

**Decision:** Store models in `backend/app/ml/models/` directory with version numbers in filenames (e.g., `crop_disease_v1.pth`). Add `MODEL_VERSION` config variable.

**Rationale:**
- Simple filesystem-based versioning for single-server deployment
- Easy rollback by changing config
- No S3 needed for models (not user-generated content)
- Git LFS or external download for large models (documented in code)

### 8. **Disease Classification Output Structure**

**Decision:** Return top-K predictions (K=3) with confidence scores, map to treatment recommendations via lookup table.

**Rationale:**
- Top-K allows showing alternative diagnoses to farmers
- Confidence thresholding enables "uncertain" responses
- Lookup table separates ML predictions from agronomic recommendations
- Maintains existing CropScan schema structure

---

## Implementation Plan

### Phase 1: ML Infrastructure Setup

- [ ] **1. Add ML dependencies to pyproject.toml**
      - Add: `torch>=2.2.0`, `torchvision>=0.17.0`, `pillow>=10.2.0`, `numpy>=1.26.0`
      - These are CPU-only versions (smaller download, no CUDA required)
      - Files: `backend/pyproject.toml`
      - Verify: Run `pip install -e .` and confirm torch imports: `python -c "import torch; print(torch.__version__)"`

- [ ] **2. Create ML directory structure**
      - Create: `backend/app/ml/` (main ML module directory)
      - Create: `backend/app/ml/__init__.py` (empty init file)
      - Create: `backend/app/ml/models/` (directory for model weights)
      - Create: `backend/app/ml/models/.gitkeep` (track empty directory)
      - Create: `backend/app/ml/models/README.md` (documentation for model download/placement)
      - Files: New directories and files under `backend/app/ml/`
      - Verify: `ls backend/app/ml/` shows `__init__.py`, `models/` directory

- [ ] **3. Add ML configuration to settings**
      - Add to `app/core/config.py` Settings class:
        - `ML_MODEL_PATH: str = "app/ml/models/crop_disease_resnet50_v1.pth"`
        - `ML_MODEL_VERSION: str = "v1"`
        - `ML_DEVICE: str = "cpu"` (or "cuda" if GPU available)
        - `ML_CONFIDENCE_THRESHOLD: float = 0.65` (minimum confidence for positive diagnosis)
        - `ML_BATCH_SIZE: int = 8` (for batch inference)
        - `ML_CACHE_TTL: int = 604800` (7 days in seconds for prediction caching)
      - Files: `backend/app/core/config.py`
      - Verify: Run `python -c "from app.core.config import settings; print(settings.ML_MODEL_PATH)"` and confirm output

### Phase 2: Core ML Service Implementation

- [ ] **4. Create model wrapper class (backend/app/ml/model_wrapper.py)**
      - Implement `CropDiseaseModel` class with:
        - `__init__(model_path, device)` - loads PyTorch model or initializes pre-trained ResNet50
        - `_load_model()` - loads state_dict if custom model exists, else torchvision.models.resnet50(pretrained=True)
        - `predict(image_tensor: torch.Tensor) -> List[Tuple[str, float]]` - forward pass, returns top-3 (disease_name, confidence)
        - `predict_batch(image_tensors: List[torch.Tensor]) -> List[List[Tuple[str, float]]]` - batch inference
        - `get_disease_classes()` - returns list of supported disease names
      - Include disease class mapping dictionary (51 classes from PlantVillage-style taxonomy)
      - Handle model loading errors gracefully (log warning, use placeholder mode)
      - Files: `backend/app/ml/model_wrapper.py`
      - Verify: Run `python -c "from app.ml.model_wrapper import CropDiseaseModel; m = CropDiseaseModel('dummy.pth', 'cpu'); print(m.get_disease_classes()[:5])"` (should work even without model file)

- [ ] **5. Create image preprocessing utilities (backend/app/ml/preprocessing.py)**
      - Implement functions:
        - `preprocess_image(image_bytes: bytes) -> torch.Tensor` - PIL load → RGB → resize(224, 224) → ToTensor → Normalize (ImageNet stats)
        - `preprocess_batch(image_bytes_list: List[bytes]) -> torch.Tensor` - batch version, stacks tensors
        - `validate_image_quality(image_bytes: bytes) -> Tuple[float, str]` - blur detection with Laplacian variance, returns (quality_score, reason)
      - Use PIL.Image for loading, torchvision.transforms for augmentation
      - Handle corrupt image errors (return None or raise custom exception)
      - Files: `backend/app/ml/preprocessing.py`
      - Verify: Create test script `test_preprocess.py` that loads a sample JPEG and confirms tensor shape is `[1, 3, 224, 224]`, then run `python test_preprocess.py`

- [ ] **6. Create ML service class (backend/app/services/ml_service.py)**
      - Implement `MLService` singleton with:
        - `_model: Optional[CropDiseaseModel] = None` (class variable for lazy-loaded model)
        - `_model_lock: asyncio.Lock` (thread-safe lazy initialization)
        - `async def _ensure_model_loaded()` - lazy load model on first use with lock
        - `async def predict_disease(image_bytes: bytes, crop_hint: Optional[str] = None) -> MLPredictionResult` - main inference method
        - `async def predict_batch(images: List[bytes]) -> List[MLPredictionResult]` - batch inference
        - `async def get_cached_prediction(image_hash: str) -> Optional[MLPredictionResult]` - Redis cache lookup
        - `async def cache_prediction(image_hash: str, result: MLPredictionResult)` - Redis cache storage
        - `_compute_image_hash(image_bytes: bytes) -> str` - SHA256 hash for cache key
      - Return structured `MLPredictionResult` (dataclass or Pydantic model) with:
        - `crop_type: str`, `crop_confidence: float`
        - `disease_name: str`, `disease_confidence: float`, `severity: str`
        - `alternative_diagnoses: List[Tuple[str, float]]` (top-3 predictions)
        - `model_version: str`, `inference_time_ms: float`
      - Integrate with `cache_service` for Redis caching (graceful fallback if Redis unavailable)
      - Log inference timing and model version for monitoring
      - Files: `backend/app/services/ml_service.py`
      - Verify: Write unit test `tests/test_ml_service.py` with mock image that calls `predict_disease` and asserts result structure, run `pytest tests/test_ml_service.py -v`

- [ ] **7. Create disease knowledge base (backend/app/ml/disease_knowledge.py)**
      - Port `AGRI_DIAGNOSES` dictionary from `crop_scanner_service.py` to this module
      - Add function `get_treatment_recommendation(disease_name: str, crop_type: str) -> Dict[str, str]` 
      - Returns: `{symptoms, treatment, prevention, severity}` for given disease
      - Handle unknown diseases (return generic advice)
      - Expand to 20+ common diseases (wheat rust, rice blast, tomato blight, potato late blight, etc.)
      - Files: `backend/app/ml/disease_knowledge.py`
      - Verify: Run `python -c "from app.ml.disease_knowledge import get_treatment_recommendation; print(get_treatment_recommendation('Tomato___Late_blight', 'tomato')['treatment'][:50])"` and confirm output

### Phase 3: Integration with Existing Services

- [ ] **8. Refactor crop_scanner_service to use ml_service**
      - Modify `crop_scanner_service.analyze_crop_image()` to:
        - Call `ml_service.predict_disease(file_bytes, crop_hint)` instead of using hardcoded logic
        - Map `MLPredictionResult` to existing `CropScan` model fields
        - Preserve existing image validation and storage logic (don't duplicate)
        - Use `disease_knowledge.get_treatment_recommendation()` for agronomic advice
        - Keep field health score update and alert generation logic unchanged
        - Handle ML service errors gracefully (log error, return "unable to analyze" response instead of 500)
      - Remove or comment out old `AGRI_DIAGNOSES` dictionary (now in `disease_knowledge.py`)
      - Files: `backend/app/services/crop_scanner_service.py`
      - Verify: Run existing test `pytest tests/test_all_features.py::test_crop_scan_upload -v` and confirm it still passes with ML service integration

- [ ] **9. Add ML service health check endpoint**
      - Create new endpoint in `backend/app/api/v1/endpoints/ai.py` (or create new `ml.py` router):
        - `GET /v1/ml/health` - returns model status, version, device (CPU/GPU), classes supported
        - Response schema: `{status: "ready"|"loading"|"error", model_version: str, device: str, classes_count: int, error: Optional[str]}`
      - No authentication required (system health check)
      - Files: `backend/app/api/v1/endpoints/ai.py` (add to existing AI router)
      - Verify: Start server with `uvicorn app.main:app --reload`, curl `http://localhost:8000/v1/ml/health` and confirm JSON response

### Phase 4: Performance Monitoring & Error Handling

- [ ] **10. Add structured logging for ML operations**
      - Create `backend/app/ml/logging_utils.py` with functions:
        - `log_inference(duration_ms: float, model_version: str, confidence: float, disease: str)` - logs each prediction
        - `log_model_load(success: bool, duration_ms: float, model_path: str, error: Optional[str])` - logs model initialization
        - `log_cache_hit(image_hash: str)` / `log_cache_miss(image_hash: str)` - cache performance tracking
      - Use Python standard logging, format as JSON for production log aggregation
      - Include timestamps, user_id (if available), image_hash
      - Files: `backend/app/ml/logging_utils.py`
      - Verify: Run inference test and grep logs for JSON entries: `pytest tests/test_ml_service.py -v -s | grep "inference"`

- [ ] **11. Implement ML service error handling & fallback**
      - Add error handling in `ml_service.py` for:
        - Model file not found → log warning, use placeholder mode (return low-confidence "model unavailable" response)
        - CUDA out of memory → fallback to CPU automatically
        - Corrupt image → return structured error with actionable message
        - Inference timeout (>10 seconds) → cancel and return timeout error
      - Add `MLServiceException` custom exception class for ML-specific errors
      - Update `crop_scanner_service` to catch `MLServiceException` and convert to HTTPException
      - Files: `backend/app/services/ml_service.py`, `backend/app/services/crop_scanner_service.py`
      - Verify: Write test case with corrupt image bytes and assert error message structure: `pytest tests/test_ml_service.py::test_corrupt_image_handling -v`

- [ ] **12. Add prediction confidence thresholding logic**
      - In `ml_service.predict_disease()`, after getting model predictions:
        - If top prediction confidence < `ML_CONFIDENCE_THRESHOLD` (0.65), set disease_name to "Uncertain - Multiple Possibilities"
        - Include all top-3 predictions in `alternative_diagnoses` field
        - Set severity to "none" for uncertain predictions
      - Update treatment recommendation to handle uncertain case (suggest expert consultation)
      - Files: `backend/app/services/ml_service.py`
      - Verify: Create test with low-confidence mock predictions and assert "Uncertain" disease name returned

### Phase 5: Testing & Documentation

- [ ] **13. Write comprehensive ML service unit tests (tests/test_ml_service.py)**
      - Test cases:
        - `test_model_lazy_loading()` - verify model loads on first predict call, not at import
        - `test_predict_disease_structure()` - assert MLPredictionResult has all required fields
        - `test_predict_with_cache()` - verify cache hit returns same result without model call
        - `test_batch_inference()` - test batch prediction with 3 images
        - `test_invalid_image_handling()` - corrupt bytes raise appropriate error
        - `test_low_confidence_thresholding()` - predictions below threshold marked as uncertain
        - `test_cpu_fallback()` - if GPU fails, falls back to CPU
        - `test_model_not_found_fallback()` - service works with placeholder when model missing
      - Use pytest fixtures for mock images (minimal valid JPEG bytes)
      - Mock torch model forward pass to control predictions (use `unittest.mock.patch`)
      - Files: `backend/tests/test_ml_service.py`
      - Verify: Run full test suite: `pytest tests/test_ml_service.py -v --cov=app.services.ml_service --cov=app.ml`

- [ ] **14. Write integration test for end-to-end crop scan with ML**
      - Add test to `tests/test_all_features.py`:
        - `test_crop_scan_with_ml_prediction()` - uploads image, verifies ML service called, checks response structure
        - Assert `crop_identified`, `disease_name`, `disease_confidence`, `recommended_treatment` populated
        - Verify alternative diagnoses included in response (extend schema if needed)
      - Mock or use real pre-trained model (if test environment has torch installed)
      - Files: `backend/tests/test_all_features.py`
      - Verify: Run `pytest tests/test_all_features.py::test_crop_scan_with_ml_prediction -v`

- [ ] **15. Update README.md with ML service documentation**
      - Add new section: "## ML Service - Crop Disease Detection"
      - Document:
        - Model architecture (ResNet50 baseline, custom model support)
        - Supported diseases (list 20+ classes)
        - Configuration variables (MODEL_PATH, DEVICE, CONFIDENCE_THRESHOLD, etc.)
        - Model file setup instructions (download link, placement in `app/ml/models/`)
        - Cache behavior (Redis-based, 7-day TTL)
        - Performance expectations (inference time: ~200-500ms CPU, ~50-100ms GPU)
        - Error handling and fallback behavior
      - Add troubleshooting section for common ML issues:
        - "Model not found" → download instructions
        - "Slow inference" → GPU setup guide
        - "Low confidence predictions" → image quality tips
      - Files: `backend/README.md`
      - Verify: Read the README section and confirm all steps are actionable

- [ ] **16. Create model download/training guide (backend/app/ml/models/README.md)**
      - Document:
        - **For Development:** Instructions to use placeholder pre-trained ResNet50 (no download needed, uses torchvision)
        - **For Production:** Instructions to download/train custom crop disease model
          - Expected model format: PyTorch state_dict (.pth file)
          - Input: 224x224 RGB images, normalized with ImageNet stats
          - Output: Logits for 51 disease classes (list class names in order)
        - Model versioning convention: `crop_disease_resnet50_v1.pth`, `crop_disease_resnet50_v2.pth`
        - Git LFS setup for models >100MB
        - Links to training datasets (PlantVillage, custom datasets)
      - Files: `backend/app/ml/models/README.md`
      - Verify: Read the README and confirm a developer can set up either mode

### Phase 6: Performance Optimization & Monitoring

- [ ] **17. Add performance metrics collection**
      - In `ml_service.py`, track metrics:
        - Inference time (p50, p95, p99 latencies)
        - Cache hit rate (hits / total predictions)
        - Confidence distribution (histogram of prediction confidences)
        - Error rate (failed predictions / total attempts)
      - Store metrics in Redis sorted sets (if available) or in-memory with periodic log dumps
      - Add endpoint `GET /v1/ml/metrics` (admin only) to retrieve metrics
      - Files: `backend/app/services/ml_service.py`, `backend/app/api/v1/endpoints/ai.py`
      - Verify: Make 10 prediction requests, then curl `/v1/ml/metrics` and confirm stats returned

- [ ] **18. Optimize batch processing for future scaling**
      - Implement request batching in `ml_service.py`:
        - Single requests wait up to 50ms for more requests to arrive
        - Batch together into single forward pass (up to `ML_BATCH_SIZE`)
        - Return individual results to each awaiting caller
      - Use asyncio.Queue for request accumulation
      - Add config: `ML_BATCH_WAIT_MS: int = 50` (0 to disable batching)
      - Files: `backend/app/services/ml_service.py`, `backend/app/core/config.py`
      - Verify: Load test with 10 concurrent requests using pytest-asyncio and assert all return results within 2 seconds

- [ ] **19. Add model warmup on first request**
      - In `ml_service._ensure_model_loaded()`:
        - After loading model, run dummy inference (random tensor) to warm up JIT compilation
        - Log warmup time separately from first real inference
      - Prevents first user request from being slow
      - Files: `backend/app/services/ml_service.py`
      - Verify: Start fresh server, make first prediction request, check logs show "Model warmup completed in Xms" before first inference

- [ ] **20. Document production deployment considerations**
      - Add section to README.md: "## ML Service Production Deployment"
      - Cover:
        - GPU setup (CUDA drivers, torch GPU version installation)
        - Model file deployment (S3 download on startup, or bake into Docker image)
        - Memory requirements (estimate: 500MB for ResNet50, 2GB for larger models)
        - Horizontal scaling (model loaded per worker, Redis cache shared across instances)
        - Model update strategy (blue-green deployment, canary testing)
      - Include Docker Compose example with GPU support
      - Files: `backend/README.md`
      - Verify: Review deployment section for completeness and clarity

---

## Summary

This plan implements a production-ready ML service for crop disease detection with:

- ✅ PyTorch-based inference with pre-trained model support
- ✅ Image preprocessing pipeline (resize, normalize, quality checks)
- ✅ Disease classification with confidence scores and top-K alternatives
- ✅ Integration with existing crop_scanner_service and storage infrastructure
- ✅ Redis-based prediction caching (7-day TTL, SHA256 keying)
- ✅ Batch processing capability for future scaling
- ✅ Comprehensive error handling and graceful fallbacks
- ✅ Performance monitoring (latency, cache hit rate, confidence distribution)
- ✅ Lazy model loading (singleton pattern, async-safe)
- ✅ CPU/GPU device abstraction
- ✅ Model versioning and management infrastructure
- ✅ Full test coverage (unit + integration tests)
- ✅ Production deployment documentation

**Implementation Order:** Sequential (Phase 1 → Phase 6), as each phase builds on the previous. Estimated 20 steps total, each independently verifiable.

**Key Files Created:**
- `backend/app/ml/model_wrapper.py` (model loading & inference)
- `backend/app/ml/preprocessing.py` (image preprocessing)
- `backend/app/ml/disease_knowledge.py` (agronomic knowledge base)
- `backend/app/services/ml_service.py` (main service orchestration)
- `backend/app/ml/logging_utils.py` (structured logging)
- `backend/tests/test_ml_service.py` (unit tests)

**Key Files Modified:**
- `backend/pyproject.toml` (add torch dependencies)
- `backend/app/core/config.py` (add ML settings)
- `backend/app/services/crop_scanner_service.py` (integrate ML service)
- `backend/app/api/v1/endpoints/ai.py` (add health & metrics endpoints)
- `backend/tests/test_all_features.py` (add integration test)
- `backend/README.md` (document ML service)
