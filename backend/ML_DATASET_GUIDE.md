# ML Dataset & Training Guide for Khetopedia

**Version:** 1.0  
**Last Updated:** October 2026  
**Python:** 3.11+  
**PyTorch:** 2.2+

---

## Table of Contents

1. [Overview](#overview)
2. [Datasets](#datasets)
3. [Setup Instructions](#setup-instructions)
4. [Class Mappings](#class-mappings)
5. [Training Guide](#training-guide)
6. [Evaluation Guide](#evaluation-guide)
7. [Model Deployment](#model-deployment)
8. [Preprocessing Details](#preprocessing-details)
9. [Windows-Specific Considerations](#windows-specific-considerations)
10. [Troubleshooting](#troubleshooting)
11. [Advanced Topics](#advanced-topics)
12. [API Integration](#api-integration)

---

## Overview

Khetopedia's ML pipeline uses deep learning for plant disease classification. This guide covers training custom models on the PlantVillage and PlantDoc datasets.

### Key Features

- **Transfer Learning**: Pre-trained ResNet-50 from ImageNet
- **Multiple Datasets**: PlantVillage (38 classes), PlantDoc (28 classes), or merged
- **Comprehensive Tools**: Preprocessing, training, evaluation scripts
- **Production-Ready**: Direct integration with FastAPI backend
- **Windows Compatible**: Full support for Windows paths and PowerShell

### Architecture

```
User Upload → FastAPI → ML Service → ResNet-50 Model → Disease Prediction → Treatment Lookup
                ↓                           ↓
            Redis Cache              Disease Knowledge Base
```

---

## Datasets

### PlantVillage Dataset

**Location:** `f:\khetopedia\assets\images\New Plant Diseases Dataset(Augmented)\New Plant Diseases Dataset(Augmented)\`

**Characteristics:**
- **Classes:** 38 disease categories
- **Samples:** ~1,920 images per class (augmented)
- **Split:** `train/` and `valid/` folders
- **Format:** JPG images, consistent quality
- **Naming:** `Crop___Disease_Name` (triple underscore separator)

**Crops Covered:**
- Apple (4 classes: Apple scab, Black rot, Cedar apple rust, Healthy)
- Blueberry (1 class: Healthy)
- Cherry (2 classes: Powdery mildew, Healthy)
- Corn/Maize (4 classes: Cercospora leaf spot, Common rust, Northern leaf blight, Healthy)
- Grape (4 classes: Black rot, Esca, Leaf blight, Healthy)
- Orange (1 class: Huanglongbing)
- Peach (2 classes: Bacterial spot, Healthy)
- Pepper (2 classes: Bacterial spot, Healthy)
- Potato (3 classes: Early blight, Late blight, Healthy)
- Raspberry (1 class: Healthy)
- Soybean (1 class: Healthy)
- Squash (1 class: Powdery mildew)
- Strawberry (2 classes: Leaf scorch, Healthy)
- Tomato (10 classes: Multiple diseases)

**Example Classes:**
```
Apple___Apple_scab
Apple___healthy
Tomato___Early_blight
Tomato___Late_blight
Corn_(maize)___Common_rust_
```

### PlantDoc Dataset

**Location:** `f:\khetopedia\assets\images\PlantDoc-Dataset-master\`

**Characteristics:**
- **Classes:** 28 disease categories
- **Samples:** ~79 images per class
- **Split:** `train/` and `test/` folders
- **Format:** JPG/PNG images, field conditions
- **Naming:** Space-separated names (e.g., `Tomato Early blight leaf`)

**Key Differences from PlantVillage:**
- Smaller dataset size (~79 vs ~1,920 images per class)
- Real-world field conditions (more challenging)
- Different naming convention (requires normalization)
- No separate validation set (only train/test)

**Comparison Table:**

| Feature | PlantVillage | PlantDoc |
|---------|-------------|----------|
| Classes | 38 | 28 |
| Images/Class | ~1,920 | ~79 |
| Total Images | ~73,000 | ~2,200 |
| Image Quality | High, controlled | Variable, field conditions |
| Splits | train/valid | train/test |
| Naming | `Crop___Disease` | `Crop Disease leaf` |

---

## Setup Instructions

### 1. Install Dependencies

```powershell
# Navigate to backend directory
cd f:\khetopedia\backend

# Install ML dependencies
pip install -r requirements-ml.txt

# For CUDA support (optional, for GPU training)
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu121
```

### 2. Verify Datasets

```powershell
# Check PlantVillage dataset
Test-Path "f:\khetopedia\assets\images\New Plant Diseases Dataset(Augmented)\New Plant Diseases Dataset(Augmented)\train"

# Check PlantDoc dataset
Test-Path "f:\khetopedia\assets\images\PlantDoc-Dataset-master\train"

# Count classes
(Get-ChildItem "f:\khetopedia\assets\images\New Plant Diseases Dataset(Augmented)\New Plant Diseases Dataset(Augmented)\train").Count
```

### 3. Generate Dataset Statistics

```powershell
# Analyze PlantVillage
python scripts\preprocess_datasets.py --dataset plantvillage --stats

# Analyze PlantDoc
python scripts\preprocess_datasets.py --dataset plantdoc --stats
```

### 4. Directory Structure

```
backend/
├── models/                          # Trained models
│   ├── class_mappings/              # Class name mappings
│   │   ├── plantvillage_classes.json
│   │   ├── plantdoc_classes.json
│   │   └── plantdoc_to_plantvillage.json
│   └── crop_disease_resnet50_v1.pth # Trained model
├── scripts/                         # Training scripts
│   ├── preprocess_datasets.py
│   ├── train_model.py
│   └── evaluate_model.py
├── data/processed/                  # Preprocessed data (gitignored)
├── runs/                            # TensorBoard logs (gitignored)
└── evaluation/                      # Evaluation results (gitignored)
```

---

## Class Mappings

### PlantVillage Classes (38)

See `backend/models/class_mappings/plantvillage_classes.json` for the complete list.

**Format:** `Crop___Disease_Name`

**Special Characters:**
- Triple underscore `___` separates crop from disease
- Parentheses for crop variants: `Corn_(maize)___`
- Underscores in disease names: `Cercospora_leaf_spot`

### PlantDoc to PlantVillage Mapping

PlantDoc uses different naming conventions. We provide a normalization mapping:

```json
{
  "Tomato Early blight leaf": "Tomato___Early_blight",
  "Apple Scab Leaf": "Apple___Apple_scab",
  "Bell_pepper leaf spot": "Pepper,_bell___Bacterial_spot"
}
```

Full mapping: `backend/models/class_mappings/plantdoc_to_plantvillage.json`

### Adding Custom Classes

To extend the model with custom disease classes:

1. Add images to dataset folder: `custom_dataset/train/Your_Class_Name/`
2. Follow PlantVillage naming: `Crop___Disease_Name`
3. Update class mapping JSON files
4. Retrain model with custom dataset

---

## Training Guide

### Quick Start

```powershell
# Train on PlantVillage (recommended for production)
python scripts\train_model.py --dataset plantvillage --epochs 30 --batch-size 32 --device cuda

# Train on CPU (slower, for testing)
python scripts\train_model.py --dataset plantvillage --epochs 3 --batch-size 16 --device cpu

# Train with custom settings
python scripts\train_model.py ^
    --dataset plantvillage ^
    --architecture resnet50 ^
    --epochs 50 ^
    --batch-size 64 ^
    --learning-rate 0.0001 ^
    --device cuda ^
    --mixed-precision ^
    --class-weights
```

### Training Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--dataset` | Required | Dataset: `plantvillage`, `plantdoc`, or `merged` |
| `--architecture` | `resnet50` | Model: `resnet50`, `resnet101`, `efficientnet_b0` |
| `--epochs` | 30 | Number of training epochs |
| `--batch-size` | 32 | Batch size (reduce for low memory) |
| `--learning-rate` | 0.001 | Initial learning rate |
| `--device` | `auto` | Device: `cpu`, `cuda`, or `auto` |
| `--pretrained` | True | Use ImageNet pretrained weights |
| `--augment` | True | Enable data augmentation |
| `--class-weights` | False | Use weighted loss for imbalanced data |
| `--mixed-precision` | False | Mixed precision (GPU only, faster) |
| `--early-stopping-patience` | 5 | Epochs to wait for improvement |

### Dataset Selection Guide

**Use PlantVillage when:**
- Training production model (large, balanced dataset)
- Need high accuracy (more training samples)
- Time is not a constraint (more data = longer training)

**Use PlantDoc when:**
- Quick prototyping (smaller, faster training)
- Testing model architecture changes
- Limited GPU memory available

**Use Merged when:**
- Maximum data diversity desired
- Need both lab and field conditions
- Willing to handle class imbalance

### Expected Training Times

| Configuration | PlantVillage | PlantDoc | Hardware |
|---------------|-------------|----------|----------|
| ResNet-50, CPU, batch=16 | ~24 hours | ~2 hours | Intel i7, 16GB RAM |
| ResNet-50, GPU, batch=32 | ~3 hours | ~20 min | NVIDIA RTX 3060, 12GB VRAM |
| ResNet-50, GPU, batch=64 | ~2 hours | ~15 min | NVIDIA RTX 4090, 24GB VRAM |

### Monitoring Training

**TensorBoard (recommended):**
```powershell
# Start TensorBoard
tensorboard --logdir f:\khetopedia\backend\runs

# Open browser to http://localhost:6006
```

**Console Output:**
```
Epoch 10/30 [Train]: 100%|████████| 2300/2300 [12:34<00:00, loss=0.1234, acc=95.67%]
Epoch 10/30 [Val]  : 100%|████████| 300/300 [01:23<00:00, loss=0.2456, acc=93.21%]

Epoch 10/30 Summary:
  Train Loss: 0.1234, Train Acc: 95.67%
  Val Loss: 0.2456, Val Acc: 93.21%
  Learning Rate: 0.000500
  ✓ New best model! Val Acc: 93.21%
```

### Hyperparameter Tuning

**Learning Rate:**
- Default: 0.001 (good starting point)
- Lower (0.0001): More stable, slower convergence
- Higher (0.01): Faster convergence, risk of instability

**Batch Size:**
- Larger batches: More stable gradients, requires more memory
- Smaller batches: More noise, better generalization, slower training
- Rule of thumb: Largest that fits in memory

**Architecture:**
- ResNet-50: Best balance (default)
- ResNet-101: More capacity, slower, better for large datasets
- EfficientNet-B0: Faster inference, slightly lower accuracy

### Common Training Issues

**Out of Memory (OOM):**
```powershell
# Reduce batch size
--batch-size 16

# Or use mixed precision (GPU only)
--mixed-precision
```

**Overfitting (val loss increases while train loss decreases):**
```powershell
# Enable early stopping (default: patience=5)
--early-stopping-patience 5

# Use data augmentation (enabled by default)
--augment
```

**Slow Convergence:**
```powershell
# Increase learning rate
--learning-rate 0.005

# Reduce early stopping patience
--early-stopping-patience 3
```

---

## Evaluation Guide

### Running Evaluation

```powershell
# Evaluate trained model
python scripts\evaluate_model.py ^
    --model-path f:\khetopedia\backend\models\crop_disease_resnet50_v1.pth ^
    --dataset plantvillage ^
    --confusion-matrix ^
    --per-class-metrics ^
    --benchmark-inference
```

### Evaluation Outputs

The evaluation script generates:

1. **evaluation_report.json** - Complete metrics in JSON format
2. **confusion_matrix.png** - Normalized confusion matrix heatmap
3. **per_class_metrics.png** - Bar charts for precision/recall/F1
4. **per_class_metrics.csv** - Per-class metrics in CSV format
5. **confidence_analysis.png** - Confidence distribution and threshold analysis

### Understanding Metrics

**Overall Accuracy:**
- Percentage of correct predictions
- Target: >90% for production

**Top-3 Accuracy:**
- Percentage where correct class is in top 3 predictions
- Important for UI showing multiple suggestions

**Precision:**
- Of all positive predictions, how many were correct
- High precision = few false positives

**Recall:**
- Of all actual positives, how many were found
- High recall = few false negatives

**F1 Score:**
- Harmonic mean of precision and recall
- Balanced metric for overall performance

### Interpreting Results

**Good Model:**
```json
{
  "overall_accuracy": 0.94,
  "top3_accuracy": 0.98,
  "precision_macro": 0.93,
  "recall_macro": 0.94,
  "f1_macro": 0.93
}
```

**Needs Improvement:**
```json
{
  "overall_accuracy": 0.75,
  "top3_accuracy": 0.88,
  "precision_macro": 0.72,
  "recall_macro": 0.74,
  "f1_macro": 0.71
}
```

### Analyzing Confusion Matrix

- **Diagonal:** Correct predictions (should be bright)
- **Off-diagonal:** Misclassifications (should be dark)
- **Row patterns:** Classes often confused with others

**Example:**
If "Tomato___Early_blight" often misclassified as "Tomato___Late_blight", consider:
- Adding more training data for these classes
- Using targeted augmentation
- Fine-tuning with field-specific images

### Inference Benchmarking

Target performance:
- **CPU:** <500ms per image
- **GPU:** <100ms per image

For production API:
- Include preprocessing time (~50ms)
- Account for batch processing
- Consider Redis caching hit rate

---

## Model Deployment

### 1. Save Trained Model

After training completes, two files are created:
- `crop_disease_resnet50_v1.pth` - Model weights
- `crop_disease_resnet50_v1_metadata.json` - Metadata

### 2. Update Backend Configuration

Edit `.env` file:

```bash
ML_MODEL_PATH=models/crop_disease_resnet50_v1.pth
ML_MODEL_VERSION=v1
ML_DEVICE=cuda  # or cpu
ML_CONFIDENCE_THRESHOLD=0.65
```

### 3. Verify Model Loading

```powershell
# Start backend
cd f:\khetopedia\backend
uvicorn app.main:app --reload

# Check ML health endpoint
curl http://localhost:8000/v1/ai/ml/health
```

Expected response:
```json
{
  "status": "operational",
  "model_loaded": true,
  "model_version": "v1",
  "device": "cuda",
  "num_classes": 38,
  "confidence_threshold": 0.65
}
```

### 4. Test Prediction

```powershell
# Upload test image
curl -X POST http://localhost:8000/v1/crop-scanner/scan ^
    -H "Authorization: Bearer YOUR_TOKEN" ^
    -F "file=@test_tomato_leaf.jpg"
```

### 5. Warm Up Cache

```powershell
# Preload model and warm up Redis cache
python -c "from app.services.ml_service import ml_service; import asyncio; asyncio.run(ml_service.warmup())"
```

### Model Versioning

When deploying new models:

1. **Keep old model:** Rename to `crop_disease_resnet50_v1_old.pth`
2. **Deploy new model:** `crop_disease_resnet50_v2.pth`
3. **Update config:** `ML_MODEL_VERSION=v2`
4. **Test thoroughly:** Use evaluation script first
5. **Monitor performance:** Track accuracy, inference time, user feedback

### Rollback Procedure

If new model has issues:

```powershell
# Stop backend
# Restore old model
cp models\crop_disease_resnet50_v1_old.pth models\crop_disease_resnet50_v1.pth

# Update .env
ML_MODEL_VERSION=v1

# Restart backend
uvicorn app.main:app --reload
```

---

## Preprocessing Details

### Image Preprocessing Pipeline

1. **Resize:** 256x256 pixels
2. **Center Crop:** 224x224 pixels (validation) or Random Crop (training)
3. **Normalization:** ImageNet mean/std
   - Mean: [0.485, 0.456, 0.406]
   - Std: [0.229, 0.224, 0.225]

### Data Augmentation (Training Only)

- **Random Resized Crop:** Scale 0.8-1.0
- **Random Horizontal Flip:** 50% probability
- **Random Vertical Flip:** 30% probability
- **Random Rotation:** ±15 degrees
- **Color Jitter:** Brightness/contrast/saturation ±20%

### Why ImageNet Normalization?

Transfer learning from ImageNet requires same normalization. Don't change these values unless training from scratch.

### Custom Preprocessing

To add custom augmentation:

1. Edit `train_model.py`
2. Modify `get_data_transforms()` function
3. Add transforms from torchvision or albumentations

Example:
```python
transforms.RandomAffine(degrees=0, translate=(0.1, 0.1)),
transforms.RandomPerspective(distortion_scale=0.2, p=0.5),
```

---

## Windows-Specific Considerations

### Path Handling

**Use raw strings or forward slashes:**
```python
# Good
path = Path(r"f:\khetopedia\backend\models")
path = Path("f:/khetopedia/backend/models")

# Bad
path = Path("f:\khetopedia\backend\models")  # Escape sequences
```

### PowerShell Command Line

**Multi-line commands use backtick or caret:**
```powershell
# PowerShell (backtick)
python scripts\train_model.py `
    --dataset plantvillage `
    --epochs 30

# CMD (caret)
python scripts\train_model.py ^
    --dataset plantvillage ^
    --epochs 30
```

### CUDA on Windows

**Check CUDA availability:**
```powershell
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

**Install CUDA toolkit:**
1. Download from NVIDIA website
2. Install PyTorch with CUDA: `pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cu121`

### File Paths with Spaces

PlantDoc has spaces in folder names. Python handles this automatically with pathlib:

```python
from pathlib import Path
path = Path("f:/khetopedia/assets/images/PlantDoc-Dataset-master/train/Tomato Early blight leaf")
# Works correctly!
```

---

## Troubleshooting

### Training Issues

**Problem:** CUDA out of memory
```
RuntimeError: CUDA out of memory. Tried to allocate X GB
```
**Solution:**
```powershell
# Reduce batch size
--batch-size 16  # or even 8

# Use mixed precision
--mixed-precision

# Use smaller architecture
--architecture efficientnet_b0
```

**Problem:** Model not learning (accuracy stuck)
```
Epoch 10: Train Acc: 15.2%, Val Acc: 14.8%
```
**Solution:**
```powershell
# Check learning rate (may be too low)
--learning-rate 0.01

# Disable class weights
# Remove --class-weights flag

# Verify dataset loaded correctly
python scripts\preprocess_datasets.py --dataset plantvillage --stats
```

**Problem:** Overfitting (train acc >> val acc)
```
Train Acc: 98%, Val Acc: 75%
```
**Solution:**
```powershell
# Ensure augmentation enabled
--augment

# Use early stopping
--early-stopping-patience 3

# Add weight decay (done by default)
```

### Evaluation Issues

**Problem:** Model file not found
```
ValueError: Model file not found: f:\khetopedia\backend\models\crop_disease_resnet50_v1.pth
```
**Solution:**
```powershell
# Check file exists
Test-Path "f:\khetopedia\backend\models\crop_disease_resnet50_v1.pth"

# List available models
Get-ChildItem f:\khetopedia\backend\models\*.pth
```

**Problem:** Class mismatch error
```
RuntimeError: size mismatch, expected 38, got 28
```
**Solution:**
Trained model has different number of classes than evaluation dataset. Train new model on correct dataset.

### Deployment Issues

**Problem:** ML service returns placeholder mode
```
"is_uncertain": true,
"disease_name": "Unable to determine (placeholder model)"
```
**Solution:**
```powershell
# Check model path in .env
cat .env | Select-String ML_MODEL_PATH

# Verify model file exists
Test-Path (Join-Path "f:\khetopedia\backend" $env:ML_MODEL_PATH)

# Check backend logs for loading errors
```

**Problem:** Slow inference (>1000ms per image)
```
"inference_time_ms": 2500
```
**Solution:**
- Use GPU: `ML_DEVICE=cuda` in .env
- Enable Redis caching (should be enabled by default)
- Use smaller model: EfficientNet-B0
- Consider batch inference for multiple images

---

## Advanced Topics

### Fine-Tuning on Custom Field Data

1. **Collect field images:** From your actual farm/region
2. **Organize dataset:**
```
custom_dataset/
├── train/
│   ├── Tomato___Early_blight/
│   ├── Tomato___Late_blight/
│   └── ...
└── test/
```
3. **Fine-tune existing model:**
```powershell
python scripts\train_model.py ^
    --dataset custom ^
    --dataset-path f:\khetopedia\custom_dataset ^
    --resume models\crop_disease_resnet50_v1_checkpoint_best.pth ^
    --learning-rate 0.0001 ^
    --epochs 10
```

### Ensemble Models

Train multiple models and average predictions:

```python
models = [
    load_model("resnet50_v1.pth"),
    load_model("resnet101_v1.pth"),
    load_model("efficientnet_v1.pth")
]

# Average probabilities
ensemble_probs = np.mean([model.predict(image) for model in models], axis=0)
```

### Model Quantization (Faster Inference)

```python
import torch
model = load_model("crop_disease_resnet50_v1.pth")

# Quantize to INT8 (4x smaller, 2-3x faster)
quantized_model = torch.quantization.quantize_dynamic(
    model, {torch.nn.Linear}, dtype=torch.qint8
)

torch.save(quantized_model.state_dict(), "crop_disease_resnet50_v1_quantized.pth")
```

### Transfer Learning from Custom Pretrained

If you have a pre-trained model on general plant images:

```python
# Load custom pretrained model
custom_pretrained = load_model("general_plant_model.pth")

# Replace final layer
custom_pretrained.fc = nn.Linear(custom_pretrained.fc.in_features, num_disease_classes)

# Fine-tune
train_model(custom_pretrained, dataset, epochs=20, lr=0.0001)
```

---

## API Integration

### ML Service Flow

```
1. User uploads image → FastAPI endpoint
2. Image validation (format, size, quality)
3. Image preprocessing (resize, normalize)
4. Check Redis cache (by image hash)
5. If cache miss → Run ML inference
6. Get disease prediction (top-3 classes)
7. Look up treatment recommendation
8. Save to Redis cache (7-day TTL)
9. Return prediction to user
```

### ML Service Configuration

`backend/app/core/config.py`:
```python
ML_MODEL_PATH: str = "app/ml/models/crop_disease_resnet50_v1.pth"
ML_MODEL_VERSION: str = "v1"
ML_DEVICE: str = "cpu"
ML_CONFIDENCE_THRESHOLD: float = 0.65
ML_BATCH_SIZE: int = 8
ML_CACHE_TTL: int = 604800  # 7 days
```

### Prediction Caching

- **Key:** SHA256 hash of image bytes
- **Value:** JSON with prediction results
- **TTL:** 7 days
- **Invalidation:** Automatic by Redis, or manual for model updates

**Clear cache after model update:**
```python
from app.services.cache_service import cache_service
await cache_service.clear_pattern("ml:predict:*")
```

### Confidence Thresholding

Default threshold: 0.65

- **Above threshold:** Return confident prediction
- **Below threshold:** Return "Unable to determine" with `is_uncertain=True`

Adjust in `.env`:
```bash
ML_CONFIDENCE_THRESHOLD=0.70  # More conservative
ML_CONFIDENCE_THRESHOLD=0.60  # More permissive
```

### Treatment Recommendations

Located in `backend/app/ml/disease_knowledge.py`:

```python
DISEASE_DATABASE = {
    "tomato_early_blight": {
        "symptoms": "...",
        "treatment": "...",
        "prevention": "...",
        "severity": "moderate"
    },
    # Add more as needed
}
```

To add custom treatment:
1. Edit `disease_knowledge.py`
2. Add entry with normalized disease name (lowercase, underscores)
3. Restart backend

---

## References

### Datasets

- **PlantVillage:** [GitHub - spMohanty/PlantVillage-Dataset](https://github.com/spMohanty/PlantVillage-Dataset)
- **PlantDoc:** [GitHub - pratikkayal/PlantDoc-Dataset](https://github.com/pratikkayal/PlantDoc-Dataset)

### Research Papers

- "Deep Residual Learning for Image Recognition" (ResNet) - He et al., 2015
- "ImageNet Classification with Deep Convolutional Neural Networks" (AlexNet) - Krizhevsky et al., 2012
- "Plant Disease Detection using Deep Learning" - Various recent papers

### PyTorch Documentation

- [PyTorch Official Docs](https://pytorch.org/docs/stable/index.html)
- [TorchVision Models](https://pytorch.org/vision/stable/models.html)
- [Transfer Learning Tutorial](https://pytorch.org/tutorials/beginner/transfer_learning_tutorial.html)

### Tools

- **TensorBoard:** [https://www.tensorflow.org/tensorboard](https://www.tensorflow.org/tensorboard)
- **scikit-learn Metrics:** [https://scikit-learn.org/stable/modules/model_evaluation.html](https://scikit-learn.org/stable/modules/model_evaluation.html)

---

## Support

For issues or questions:

1. Check this guide's Troubleshooting section
2. Review backend logs: `backend/logs/app.log`
3. Check TensorBoard for training issues
4. Verify dataset integrity with preprocessing script

**Common Commands:**

```powershell
# Quick test training (3 epochs, CPU)
python scripts\train_model.py --dataset plantvillage --epochs 3 --batch-size 16 --device cpu

# Full production training (GPU)
python scripts\train_model.py --dataset plantvillage --epochs 30 --batch-size 32 --device cuda --mixed-precision

# Evaluate model
python scripts\evaluate_model.py --model-path models\crop_disease_resnet50_v1.pth --dataset plantvillage

# Check dataset stats
python scripts\preprocess_datasets.py --dataset plantvillage --stats
```

---

**Document Version:** 1.0  
**Last Updated:** October 2026  
**Maintained by:** Khetopedia Development Team
