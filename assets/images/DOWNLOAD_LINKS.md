# Crop Disease Image Dataset - Download Links

## 🎯 Recommended Datasets for Khetopedia

---

## 1. ⭐ **PRIMARY DATASET: PlantVillage (New Plant Diseases Dataset)**

**Best for your project!** 87,000+ images across 38 classes

### **Kaggle Download** (Recommended - Easiest)
🔗 **Direct Link:** https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset

**Dataset Details:**
- **Total Images:** 87,863 color images
- **Classes:** 38 different crop-disease combinations
- **Crops Covered:** 14 crop species
- **Resolution:** 256x256 pixels (RGB)
- **Format:** JPG
- **Size:** ~2.5 GB (compressed)
- **License:** Open source / Public domain

**Classes Included:**
1. Apple - Apple scab
2. Apple - Black rot
3. Apple - Cedar apple rust
4. Apple - Healthy
5. Blueberry - Healthy
6. Cherry (sour) - Powdery mildew
7. Cherry (sour) - Healthy
8. Corn (maize) - Cercospora leaf spot / Gray leaf spot
9. Corn (maize) - Common rust
10. Corn (maize) - Northern Leaf Blight
11. Corn (maize) - Healthy
12. Grape - Black rot
13. Grape - Esca (Black Measles)
14. Grape - Leaf blight (Isariopsis Leaf Spot)
15. Grape - Healthy
16. Orange - Haunglongbing (Citrus greening)
17. Peach - Bacterial spot
18. Peach - Healthy
19. Pepper (bell) - Bacterial spot
20. Pepper (bell) - Healthy
21. Potato - Early blight
22. Potato - Late blight
23. Potato - Healthy
24. Raspberry - Healthy
25. Soybean - Healthy
26. Squash - Powdery mildew
27. Strawberry - Leaf scorch
28. Strawberry - Healthy
29. Tomato - Bacterial spot
30. Tomato - Early blight
31. Tomato - Late blight
32. Tomato - Leaf Mold
33. Tomato - Septoria leaf spot
34. Tomato - Spider mites / Two-spotted spider mite
35. Tomato - Target Spot
36. Tomato - Tomato Yellow Leaf Curl Virus
37. Tomato - Tomato mosaic virus
38. Tomato - Healthy

**How to Download:**
1. Go to: https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset
2. Click "Download" button (requires free Kaggle account)
3. Extract the ZIP file
4. Folder structure will be:
   ```
   New Plant Diseases Dataset(Augmented)/
   ├── train/
   │   ├── Apple___Apple_scab/
   │   ├── Apple___Black_rot/
   │   ├── Tomato___Late_blight/
   │   └── ... (38 folders)
   └── valid/
       ├── Apple___Apple_scab/
       └── ... (38 folders)
   ```

---

## 2. ⭐ **ALTERNATIVE: Original PlantVillage Dataset (GitHub)**

🔗 **GitHub Repository:** https://github.com/spMohanty/PlantVillage-Dataset

**Dataset Details:**
- **Total Images:** 54,306 images
- **Crops:** 14 crop species
- **Diseases:** 26 diseases + healthy
- **Format:** JPG
- **Resolution:** Variable (high quality)
- **License:** CC0 (Public Domain)

**How to Download:**
1. Go to: https://github.com/spMohanty/PlantVillage-Dataset
2. Click "Code" → "Download ZIP"
3. Or clone: `git clone https://github.com/spMohanty/PlantVillage-Dataset.git`

**Note:** This is the original dataset. The Kaggle version (above) is augmented and pre-split into train/validation sets.

---

## 3. 🌾 **ADDITIONAL: PlantDoc Dataset**

Great for additional diversity and real-world conditions

🔗 **GitHub:** https://github.com/pratikkayal/PlantDoc-Dataset

**Dataset Details:**
- **Total Images:** 2,598 images
- **Classes:** 27 classes (13 plant species)
- **Unique:** Contains real-world field images (not lab-controlled)
- **Format:** JPG
- **License:** CC BY 4.0

**Crops Covered:**
- Apple, Bell Pepper, Cherry, Corn, Grape, Peach, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato

**How to Download:**
1. Visit: https://github.com/pratikkayal/PlantDoc-Dataset
2. Download from the releases section
3. Or use provided links in repository

---

## 4. 🇮🇳 **INDIA-SPECIFIC: ICAR Datasets**

For Indian crop varieties and conditions

### **Indian Institute of Technology (IIT) Mandi**
🔗 Research datasets available on request

### **ICAR-NIPHM (National Institute of Plant Health Management)**
🔗 Website: https://niphm.gov.in/
- Contact for research datasets
- May require institutional access

### **Krishi Vigyan Kendras (KVKs)**
🔗 Local agricultural colleges often have regional datasets
- Contact your nearest KVK
- May provide localized disease images

---

## 5. 📸 **Stock Photo Websites (For UI/Reference)**

### **Unsplash (Free)**
🔗 https://unsplash.com/s/photos/crop-disease
- High-quality photographs
- Free for commercial use
- Good for UI mockups and reference

**Search Terms:**
- "crop disease"
- "plant leaf disease"
- "agricultural pest"
- "farm disease"

### **Pexels (Free)**
🔗 https://www.pexels.com/search/plant%20disease/
- Free stock photos and videos
- Commercial use allowed

### **Pixabay (Free)**
🔗 https://pixabay.com/images/search/plant%20disease/
- Free images and videos
- No attribution required

---

## 📥 Download Instructions (Step by Step)

### **For Kaggle Dataset (Recommended):**

1. **Create Kaggle Account:**
   - Go to https://www.kaggle.com
   - Sign up (free)
   - Verify your email

2. **Download Dataset:**
   - Visit: https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset
   - Click "Download" (top right)
   - Save ZIP file (~2.5 GB)

3. **Extract Dataset:**
   ```bash
   # Windows
   Right-click ZIP → Extract All → Choose location
   
   # Linux/Mac
   unzip new-plant-diseases-dataset.zip
   ```

4. **Organize for Your Project:**
   ```
   f:\khetopedia\assets\images\diseases\
   ├── train\
   │   ├── bacterial_blight_rice\
   │   ├── late_blight_tomato\
   │   └── ... (copy relevant folders)
   └── valid\
       └── ... (copy relevant folders)
   ```

5. **Select Relevant Classes:**
   Focus on crops you're targeting:
   - Tomato (9 classes)
   - Potato (3 classes)
   - Corn (4 classes)
   - Pepper (2 classes)

---

## 🛠️ Alternative: Kaggle API Download (Advanced)

### **Install Kaggle API:**
```bash
pip install kaggle
```

### **Setup API Token:**
1. Go to https://www.kaggle.com/settings
2. Click "Create New API Token"
3. Download `kaggle.json`
4. Place in:
   - Windows: `C:\Users\<username>\.kaggle\kaggle.json`
   - Linux/Mac: `~/.kaggle/kaggle.json`

### **Download via Command:**
```bash
# Download New Plant Diseases Dataset
kaggle datasets download -d vipoooool/new-plant-diseases-dataset

# Unzip
unzip new-plant-diseases-dataset.zip -d ./plant_diseases
```

---

## 📊 Dataset Comparison

| Dataset | Images | Classes | Size | Best For |
|---------|--------|---------|------|----------|
| **PlantVillage (Kaggle)** | 87K+ | 38 | 2.5GB | ⭐ ML Training (Best) |
| **PlantVillage (GitHub)** | 54K | ~40 | 2.0GB | Research, Original Data |
| **PlantDoc** | 2.6K | 27 | 500MB | Real-world Testing |
| **Unsplash/Pexels** | Varies | N/A | N/A | UI Reference Only |

---

## ✅ Quick Start Recommendation

**For Khetopedia Project:**

1. **Download:** PlantVillage Kaggle Dataset (Link #1)
   - Easy download
   - Pre-split train/val
   - 87K images ready to use

2. **Focus on Relevant Classes:**
   - Tomato diseases (9 classes)
   - Potato diseases (3 classes)
   - Corn diseases (4 classes)
   - Pepper diseases (2 classes)
   - Total: ~18-20 classes relevant to your JSON data

3. **Skip Non-Essential:**
   - Apple, Cherry, Grape, Peach, Raspberry
   - Focus on Indian agricultural crops

4. **For UI Images:**
   - Use Unsplash/Pexels for hero images
   - Use Flaticon for icons

---

## 🎯 Prioritized Download Order

### **Priority 1 (Must Download Now):**
✅ PlantVillage Kaggle Dataset (87K images)
🔗 https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset

### **Priority 2 (Download if needed):**
- PlantDoc Dataset (for real-world testing)
- Unsplash images (for UI)

### **Priority 3 (Later):**
- Original PlantVillage (GitHub)
- Custom photography from local farms

---

## 📝 Usage Notes

**For ML Model Training:**
- Use train/ folder (80% of data)
- Use valid/ folder (20% for validation)
- Consider augmentation for better generalization

**For App Reference:**
- Select best quality images from dataset
- Create "example" folder with representative images
- Use in app tutorial: "Examples of diseases we can detect"

**Legal:**
- PlantVillage: CC0 Public Domain - ✅ Commercial use allowed
- PlantDoc: CC BY 4.0 - ✅ Commercial use with attribution
- Stock photos: Check individual licenses

---

## 🚀 Next Steps After Download

1. **Extract and organize** relevant disease classes
2. **Train ML model** using PyTorch (code already in your project)
3. **Test model** with validation images
4. **Select best images** for app UI reference
5. **Document** which dataset version you used

---

## 📞 Support Resources

**Kaggle Forum:**
- Dataset discussions and questions
- https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset/discussion

**GitHub Issues:**
- Original PlantVillage repository
- https://github.com/spMohanty/PlantVillage-Dataset/issues

**Research Paper:**
- Original PlantVillage paper
- "An open access repository of images on plant health" (2015)
- https://arxiv.org/abs/1511.08060

---

## ✨ Quick Action

**👉 START HERE:** https://www.kaggle.com/datasets/vipoooool/new-plant-diseases-dataset

1. Create Kaggle account (2 minutes)
2. Click Download (free, no credit card)
3. Extract ZIP file
4. Copy to your project
5. Start training! 🎉

---

**Last Updated:** October 27, 2026
**Dataset Status:** ✅ Available and Free
**Total Download Time:** ~10-30 minutes (depending on internet speed)

**Happy Dataset Collection! 🌱📸**
