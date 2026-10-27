# ML Models Directory

This directory stores PyTorch model weights for crop disease detection.

## Development Mode (Default)

For development and testing, the ML service uses a **pre-trained ResNet50** model from torchvision. No model file download is required - the service automatically loads `torchvision.models.resnet50(weights=ResNet50_Weights.IMAGENET1K_V2)` and maps predictions to crop disease classes.

**Requirements:**
- PyTorch and torchvision installed (see `pyproject.toml`)
- No additional setup needed

**How it works:**
1. Service checks if custom model file exists at configured path
2. If not found, loads pre-trained ResNet50 as placeholder
3. Maps ImageNet classes to crop disease categories using heuristics
4. Returns predictions with confidence scores

## Production Mode (Custom Trained Model)

For production deployment with real crop disease classification:

### Model Specifications

**Input:**
- Image size: 224x224 RGB
- Normalization: ImageNet mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]
- Format: PyTorch tensor [batch_size, 3, 224, 224]

**Output:**
- 51 disease classes (see `disease_classes` list in `model_wrapper.py`)
- Logits (unnormalized scores) or probabilities via softmax
- Expected shape: [batch_size, 51]

**Model Format:**
- PyTorch state_dict saved with `torch.save(model.state_dict(), path)`
- File extension: `.pth`
- Compatible architectures: ResNet50, EfficientNet, Vision Transformer (ViT)

### Model Placement

1. **Download or train** your custom crop disease model
2. **Name the model file** using versioning convention:
   - Example: `crop_disease_resnet50_v1.pth`
   - Version in filename helps track model updates
3. **Place the file** in this directory (`backend/app/ml/models/`)
4. **Update configuration** in `.env` or `app/core/config.py`:
   ```
   ML_MODEL_PATH=app/ml/models/crop_disease_resnet50_v1.pth
   ML_MODEL_VERSION=v1
   ```

### Training Datasets

Recommended datasets for crop disease classification:

- **PlantVillage Dataset**: 54,000+ images, 38 crop-disease combinations
  - Link: [PlantVillage on Kaggle](https://www.kaggle.com/datasets/emmarex/plantdisease)
- **Custom Field Data**: Collect and label images from local farms
  - Ensures model generalizes to regional crop varieties and lighting conditions

### Git LFS Setup (For Models >100MB)

Large model files should use Git Large File Storage:

```bash
# Install Git LFS
git lfs install

# Track .pth files
git lfs track "*.pth"

# Commit .gitattributes
git add .gitattributes
git commit -m "Track PyTorch models with Git LFS"

# Add and commit model
git add crop_disease_resnet50_v1.pth
git commit -m "Add crop disease model v1"
```

### Model Versioning

When updating models:
1. Save new model with incremented version: `crop_disease_resnet50_v2.pth`
2. Update `ML_MODEL_VERSION=v2` in config
3. Keep old version for rollback capability
4. Test new model thoroughly before deploying to production

### Training Guide

Basic PyTorch training loop for crop disease classification:

```python
import torch
import torch.nn as nn
from torchvision import models, transforms
from torch.utils.data import DataLoader

# Load pre-trained ResNet50
model = models.resnet50(weights='IMAGENET1K_V2')
model.fc = nn.Linear(model.fc.in_features, 51)  # 51 disease classes

# Training transforms
train_transform = transforms.Compose([
    transforms.RandomResizedCrop(224),
    transforms.RandomHorizontalFlip(),
    transforms.ColorJitter(0.2, 0.2, 0.2),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

# Train model (simplified)
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
criterion = nn.CrossEntropyLoss()

# ... training loop ...

# Save trained model
torch.save(model.state_dict(), 'crop_disease_resnet50_v1.pth')
```

### Troubleshooting

**"Model file not found" warning:**
- Expected behavior in development mode
- Service falls back to pre-trained ResNet50 placeholder
- No action needed unless deploying to production

**"CUDA out of memory" error:**
- Set `ML_DEVICE=cpu` in config
- Reduce batch size: `ML_BATCH_SIZE=4` or `ML_BATCH_SIZE=1`

**Low prediction confidence:**
- Check image quality (blur, lighting, angle)
- Verify model was trained on similar crop varieties
- Consider fine-tuning with local field images

## Model Download Links

*For pre-trained crop disease models, add download links here once available.*

Example:
```bash
# Download model from cloud storage
wget https://your-storage.com/models/crop_disease_resnet50_v1.pth -O crop_disease_resnet50_v1.pth
```
