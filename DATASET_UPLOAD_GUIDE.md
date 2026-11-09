# KhetoPedia Dataset Upload Guide

This guide explains how to upload the plant disease image datasets to cloud storage and share them with your project users.

## 📊 Dataset Information

Your project contains two major datasets:

1. **New Plant Diseases Dataset (Augmented)**
   - Location: `assets/images/New Plant Diseases Dataset(Augmented)/`
   - Size: ~3.5 GB
   - Files: ~87,000 images
   - Contains: Training and validation images of various plant diseases

2. **PlantDoc Dataset**
   - Location: `assets/images/PlantDoc-Dataset-master/`
   - Size: ~1.1 GB  
   - Files: ~2,500+ images
   - Contains: Test and training images for plant disease classification

**Total Size: ~4.6 GB with 272,881 files**

---

## 🔧 Recommended Upload Options

### Option 1: Google Drive (Easiest)

**Steps:**

1. **Compress the datasets locally:**
   ```powershell
   # Navigate to your project
   cd f:\khetopedia\assets\images
   
   # Create ZIP files (this will take 10-15 minutes)
   Compress-Archive -Path "New Plant Diseases Dataset(Augmented)" -DestinationPath "plant_diseases_augmented.zip"
   Compress-Archive -Path "PlantDoc-Dataset-master" -DestinationPath "plantdoc_dataset.zip"
   ```

2. **Upload to Google Drive:**
   - Go to https://drive.google.com
   - Create a new folder called "KhetoPedia-Datasets"
   - Upload both ZIP files
   - Right-click each file → Share → Change to "Anyone with the link"
   - Copy the shareable links

3. **Get direct download links:**
   - For each file, copy the link
   - Convert to direct download format:
   ```
   Original: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
   Direct: https://drive.google.com/uc?export=download&id=FILE_ID
   ```

---

### Option 2: Kaggle Datasets (Best for ML Projects)

**Why Kaggle?**
- ✅ Designed for ML datasets
- ✅ Version control built-in
- ✅ Fast downloads for data scientists
- ✅ Free and unlimited storage for public datasets
- ✅ Discoverable by the ML community

**Steps:**

1. **Install Kaggle CLI:**
   ```powershell
   pip install kaggle
   ```

2. **Get API credentials:**
   - Go to https://www.kaggle.com/settings
   - Scroll to "API" section
   - Click "Create New Token"
   - Save `kaggle.json` to `C:\Users\sahil\.kaggle\`

3. **Create dataset metadata:**
   Create a file `dataset-metadata.json`:
   ```json
   {
     "title": "KhetoPedia Plant Disease Datasets",
     "id": "itzsahil-prog/khetopedia-plant-diseases",
     "licenses": [{"name": "CC0-1.0"}]
   }
   ```

4. **Upload to Kaggle:**
   ```powershell
   cd f:\khetopedia\assets\images
   kaggle datasets create -p . -m dataset-metadata.json
   ```

5. **Share the dataset URL:**
   ```
   https://www.kaggle.com/datasets/itzsahil-prog/khetopedia-plant-diseases
   ```

---

### Option 3: Hugging Face (Modern ML Platform)

**Steps:**

1. **Create account:** https://huggingface.co/join

2. **Create a new dataset:**
   - Go to https://huggingface.co/new-dataset
   - Name: `khetopedia-plant-diseases`
   - License: Choose appropriate license
   - Make it Public

3. **Install Hugging Face CLI:**
   ```powershell
   pip install huggingface_hub
   ```

4. **Upload:**
   ```powershell
   huggingface-cli login
   # Follow prompts
   
   huggingface-cli upload itzsahil-prog/khetopedia-plant-diseases f:\khetopedia\assets\images
   ```

---

### Option 4: OneDrive/Dropbox

**OneDrive Steps:**
1. Upload the compressed ZIP files to OneDrive
2. Right-click → Share → Copy link
3. Modify link for direct download

**Dropbox Steps:**
1. Upload ZIP files to Dropbox
2. Create shared link
3. Change `?dl=0` to `?dl=1` in the URL for direct download

---

## 📝 After Upload - Update Project Documentation

Once uploaded, you need to:

1. **Update `assets/DATASET_GUIDE.md`** with download instructions
2. **Update `README.md`** with dataset information
3. **Update `backend/ML_DATASET_GUIDE.md`** with setup steps
4. **Commit and push the updated documentation**

---

## 🚀 For Users: How to Download Datasets

After you upload, users will:

1. Clone the GitHub repository:
   ```bash
   git clone https://github.com/itzsahil-prog/KhetoPedia.git
   cd KhetoPedia
   ```

2. Download datasets from your shared link

3. Extract to the correct location:
   ```bash
   # Extract to assets/images/
   unzip plant_diseases_augmented.zip -d assets/images/
   unzip plantdoc_dataset.zip -d assets/images/
   ```

4. Verify structure:
   ```
   assets/
   └── images/
       ├── New Plant Diseases Dataset(Augmented)/
       └── PlantDoc-Dataset-master/
   ```

---

## 💡 Pro Tips

- **Use Kaggle** if you want ML community engagement
- **Use Google Drive** for simplicity
- **Use Hugging Face** for modern ML projects
- Always include checksums (MD5/SHA256) to verify downloads
- Consider splitting very large datasets into parts (< 2GB each)

---

## 📧 Need Help?

If you run into issues:
1. Check file size limits for your chosen platform
2. Ensure stable internet connection for uploads
3. Consider uploading during off-peak hours
4. Use compression to reduce upload time

---

**Next Step:** Choose your platform and follow the steps above! I'll help you update the documentation once you have the download links.
