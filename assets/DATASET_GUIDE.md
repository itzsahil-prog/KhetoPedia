# Khetopedia Dataset and Assets Guide

Complete guide for populating all asset directories with appropriate datasets for your agricultural AI application.

## Quick Start Checklist

### Essential Assets (MVP - Start Here)

**Priority 1 (Must Have):**
- [ ] 6 JSON data files (irrigation, diseases, soil, crops, fertilizer, weather) ✅ **DONE**
- [ ] ML training dataset: 1000+ crop disease images
- [ ] 20 app UI images (logos, icons, placeholders)
- [ ] 5 tutorial videos (30-60 seconds each)
- [ ] 10 notification sounds (3-5 seconds each)
- [ ] 5 essential PDF guides (rice, wheat, tomato, IPM, user manual)
- [ ] 10 Rive animations (onboarding, loaders, success)

**Priority 2 (Should Have):**
- [ ] 500+ additional disease images
- [ ] 5 crop cultivation videos (5-8 minutes each)
- [ ] 20 voice guidance clips (English + Hindi)
- [ ] 10 additional PDF guides
- [ ] 10 additional Rive animations

**Priority 3 (Nice to Have):**
- [ ] 5 technique demonstration videos
- [ ] Ambient audio sounds
- [ ] Advanced Rive animations
- [ ] Market reports and research PDFs

## Directory Overview

```
assets/
├── images/              # Photos, icons, illustrations
├── audios/              # Sounds, voice guidance, notifications
├── videos/              # Tutorials, demonstrations, guides
├── jsons/              # ✅ Data files (COMPLETED)
├── pdfs/               # Educational documents, guides
└── rive_animations/    # Interactive vector animations
```

## 1. JSON Data Files ✅ COMPLETED

**Status:** All 6 essential JSON files created and ready to use!

### Created Files:
1. ✅ `irrigation_schedules.json` - Complete irrigation schedules for 4 crops
2. ✅ `crop_diseases_data.json` - 5 diseases with symptoms and treatments
3. ✅ `soil_parameters.json` - pH, EC, NPK parameters and heavy metal toxicity
4. ✅ `fertilizer_recommendations.json` - 6 fertilizer products with application guidelines
5. ✅ `crop_varieties.json` - 5 major crops with varieties and requirements
6. ✅ `weather_advisory.json` - Weather-based farming advisories

### Next Steps:
1. Import JSON files into your backend database
2. Create API endpoints to serve this data
3. Display in Flutter app with proper parsing

**Example Usage:**
```dart
// Load JSON in Flutter
import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadDiseaseData() async {
  final String response = await rootBundle.loadString('assets/jsons/crop_diseases_data.json');
  return json.decode(response);
}
```

## 2. Images

### Critical Image Datasets

**A. Crop Disease Dataset (FOR ML TRAINING)**

**Requirement:** 5,000-10,000 labeled images

**Recommended Source:** PlantVillage Dataset
- **Download:** https://www.kaggle.com/datasets/abdallahalidev/plantvillage-dataset
- **Classes:** 38 plant disease classes
- **Images:** 54,000+ labeled images
- **Format:** JPEG
- **License:** Open source

**Alternative Sources:**
- PlantDoc Dataset: https://github.com/pratikkayal/PlantDoc-Dataset
- Crop Disease Dataset (ICAR): Contact agricultural universities
- Custom photography: Partner with local farms

**Organization:**
```
images/diseases/
├── bacterial_blight_rice/
│   ├── image_001.jpg
│   ├── image_002.jpg
│   └── ...
├── late_blight_tomato/
├── leaf_curl_tomato/
├── leaf_spot_tomato/
└── powdery_mildew_cucumber/
```

**B. App UI Images (20-30 images)**

**Needed:**
1. **Logo** (5 versions):
   - `logo_1024.png` - App store
   - `logo_512.png` - High res
   - `logo_256.png` - Medium
   - `logo_128.png` - Icons
   - `logo_48.png` - Notification

2. **Icons** (15 icons):
   - Weather icons (8): sunny, cloudy, rainy, stormy, foggy, windy, hot, cold
   - Feature icons (7): crop, soil, weather, AI, field, scan, recommendation

3. **Illustrations** (5):
   - Empty states (no data, no internet, error)
   - Success illustrations
   - Onboarding illustrations

4. **Splash Screen** (1):
   - `splash_background.png` - 1080x1920

**Free Resources:**
- Icons: Flaticon.com, Icons8.com, Material Icons
- Illustrations: unDraw.co, DrawKit.com, Humaaans.com
- Custom design: Hire on Fiverr ($10-50)

**C. Crop Reference Images (50-100 images)**

**Needed:**
- Healthy crops at different growth stages
- Common pests close-ups
- Soil types reference
- Farm equipment

**Sources:**
- Free stock: Unsplash.com, Pexels.com, Pixabay.com
- Agricultural websites: FAO, ICAR
- Custom photography

### Image Optimization

Before adding to project:
```bash
# Using ImageMagick
mogrify -resize 1024x1024 -quality 85 *.jpg

# Using TinyPNG API
# https://tinypng.com/developers

# Batch optimization
for file in *.jpg; do
  convert "$file" -quality 85 "optimized_$file"
done
```

## 3. Audio Files

### Essential Audio Assets (10-20 files)

**A. Notification Sounds (6 sounds)**

**Quick Solution:** Use system notification sounds or free libraries
- **Freesound.org:** Search "notification bell", "success chime"
- **Zapsplat.com:** Free sound effects
- **NotificationSounds.com:** Royalty-free notifications

**Needed:**
1. `notification_disease_detected.mp3` - Attention sound
2. `notification_weather_alert.mp3` - Warning tone
3. `notification_recommendation.mp3` - Soft chime
4. `notification_reminder.mp3` - Gentle bell
5. `notification_success.mp3` - Positive chime
6. `notification_error.mp3` - Subtle error tone

**B. UI Feedback Sounds (5 sounds)**

1. `feedback_button_tap.mp3` - Subtle click
2. `feedback_success.mp3` - Success chime
3. `feedback_error.mp3` - Error sound
4. `feedback_camera_shutter.mp3` - Shutter sound
5. `feedback_whoosh.mp3` - Transition sound

**C. Voice Guidance (Optional for MVP)**

**Alternative:** Use Flutter Text-to-Speech
```dart
import 'package:flutter_tts/flutter_tts.dart';

FlutterTts tts = FlutterTts();
await tts.setLanguage("en-IN");
await tts.speak("Point your camera at the affected leaf");
```

**If recording:**
- Hire voice artist on Fiverr ($20-50 for 10 clips)
- Use AI voice generation (ElevenLabs, Google Cloud TTS)

## 4. Video Files

### Essential Tutorial Videos (5 videos for MVP)

**Option 1: Screen Recording (Fastest)**
- Record app usage with screen recorder
- Add voiceover with OBS Studio or Camtasia
- Edit with DaVinci Resolve (free) or Adobe Premiere

**Option 2: Outsource** ($500-1500 for 5 videos)
- Hire on Upwork, Fiverr
- Provide script and app mockups
- Review and approve before payment

**Option 3: Use Existing Content**
- YouTube videos (get permission)
- Government agriculture videos
- Educational institution content

**Must-Have Videos:**
1. **App Introduction** (30s): Welcome and key features
2. **Crop Scanner Tutorial** (45s): How to scan leaves
3. **Soil Analysis Tutorial** (40s): Entering test results
4. **Weather Integration** (30s): Understanding forecasts
5. **AI Assistant Guide** (30s): Asking questions

**Format:**
- Resolution: 1080x1920 (portrait for mobile)
- Codec: H.264
- Size: <20MB per video
- Subtitles: Embedded or SRT file

**Tools:**
- Screen recording: OBS Studio (free), Camtasia
- Video editing: DaVinci Resolve (free), Adobe Premiere
- Compression: HandBrake (free)

## 5. PDF Documents

### Essential PDFs (5 guides for MVP)

**Quick Solution: Download Government Publications**

**Free Sources:**
1. **ICAR (Indian Council of Agricultural Research)**
   - Website: https://icar.org.in/
   - Publications: Extension bulletins, crop guides
   - Format: PDF, freely available

2. **State Agriculture Departments**
   - Search: "[State] agriculture department publications"
   - Example: Punjab Agriculture, Maharashtra Agriculture

3. **FAO (Food and Agriculture Organization)**
   - Website: http://www.fao.org/
   - Publications: Freely available PDFs

4. **International Research Centers**
   - IRRI (Rice): http://www.irri.org/
   - CIMMYT (Wheat/Maize): https://www.cimmyt.org/

**Must-Have PDFs:**
1. **Rice Cultivation Guide** - Download from ICAR or IRRI
2. **Wheat Cultivation Guide** - Download from CIMMYT or state dept
3. **Tomato Growing Guide** - Find on agriculture department site
4. **IPM Guide** - Download from FAO or ICAR
5. **Khetopedia User Manual** - Create using Word/Google Docs → Export PDF

**Creating User Manual:**
- Use template from Canva (free)
- Include screenshots from app
- Write in simple language
- Export as PDF (File → Download → PDF)

## 6. Rive Animations

### Essential Rive Animations (10 animations for MVP)

**Option 1: Create Simple Animations**
1. Go to https://rive.app (free account)
2. Use built-in tools to create basic animations
3. Follow beginner tutorials: https://rive.app/learn
4. Export as `.riv` file

**Option 2: Use Community Files**
1. Browse Rive Community: https://rive.app/community
2. Find agricultural/nature themes
3. Remix and customize
4. Download and use (check license)

**Option 3: Hire Animator** ($50-200 per animation)
- Rive Community has freelancers
- Upwork, Fiverr (search "Rive animation")

**Must-Have Animations:**
1. **Splash Screen** - Animated logo
2. **Onboarding** (3) - Feature showcases
3. **Loader** (2) - Default and scan processing
4. **Success** - Checkmark animation
5. **Empty States** (3) - No scans, no fields, no recommendations

**Start Simple:**
- Use loading spinner from Rive community
- Create simple fade/scale transitions
- Add complex animations in later versions

## Budget Estimation

### DIY Approach (Minimal Cost)

| Asset Type | Source | Cost |
|------------|--------|------|
| JSON Data | Created ✅ | $0 |
| ML Images | PlantVillage (Kaggle) | $0 |
| UI Images | Flaticon, unDraw | $0 |
| Audio | Freesound, Flutter TTS | $0 |
| Videos | Screen recording + OBS | $0 |
| PDFs | Government publications | $0 |
| Rive | Community files + DIY | $0 |
| **Total** | | **$0** |

### Professional Approach (Recommended)

| Asset Type | Source | Cost |
|------------|--------|------|
| JSON Data | Created ✅ | $0 |
| ML Images | Kaggle + Custom photos | $200 |
| UI Images | Custom design (Fiverr) | $50 |
| Audio | Voice artist + sound library | $100 |
| Videos | Outsource 5 videos | $500 |
| PDFs | Government + custom | $0 |
| Rive | Hire animator (10 animations) | $500 |
| **Total** | | **$1,350** |

### Enterprise Approach (Production Quality)

| Asset Type | Source | Cost |
|------------|--------|------|
| JSON Data | Created ✅ | $0 |
| ML Images | Custom dataset (5000 images) | $2,000 |
| UI Images | Professional designer | $500 |
| Audio | Professional VO + music | $500 |
| Videos | Video production company | $5,000 |
| PDFs | Professional writer + design | $1,000 |
| Rive | Professional animator | $2,000 |
| **Total** | | **$11,000** |

## Implementation Timeline

### Week 1: Core Data (DONE ✅)
- [x] Create JSON files
- [ ] Download PlantVillage dataset
- [ ] Create app logo and icons

### Week 2: Media Assets
- [ ] Record/source 5 tutorial videos
- [ ] Create/download 10 audio files
- [ ] Design/download 5 Rive animations

### Week 3: Documentation
- [ ] Download 5 PDF guides
- [ ] Create user manual
- [ ] Organize all assets

### Week 4: Integration & Testing
- [ ] Add assets to Flutter project
- [ ] Test loading and performance
- [ ] Optimize file sizes

## Flutter Integration Checklist

### Update `pubspec.yaml`

```yaml
flutter:
  assets:
    # JSON
    - assets/jsons/
    
    # Images
    - assets/images/logos/
    - assets/images/icons/
    - assets/images/illustrations/
    - assets/images/crops/
    - assets/images/diseases/
    
    # Audio
    - assets/audios/notifications/
    - assets/audios/feedback/
    - assets/audios/voice_guides/
    
    # Video
    - assets/videos/tutorials/
    - assets/videos/crop_guides/
    
    # PDF
    - assets/pdfs/guides/
    - assets/pdfs/tutorials/
    
    # Rive
    - assets/rive_animations/onboarding/
    - assets/rive_animations/loading/
    - assets/rive_animations/success/

dependencies:
  # For JSON
  # Built-in dart:convert
  
  # For images
  cached_network_image: ^3.3.0
  
  # For audio
  audioplayers: ^5.2.0
  flutter_tts: ^3.8.3
  
  # For video
  video_player: ^2.8.1
  
  # For PDF
  flutter_pdfview: ^1.3.2
  
  # For Rive
  rive: ^0.13.0
```

## Asset Management Best Practices

1. **Version Control:**
   - Use Git LFS for large files
   - Keep source files separate from optimized assets

2. **CDN for Large Files:**
   - Upload videos/PDFs to CDN (AWS S3, Cloudflare)
   - Reference URLs in app, don't bundle large files

3. **Lazy Loading:**
   - Load assets only when needed
   - Cache after first load

4. **Localization:**
   - Separate assets by language (en, hi)
   - Use directory structure: `assets/pdfs/en/`, `assets/pdfs/hi/`

5. **Testing:**
   - Test on low-end Android devices
   - Check file sizes and loading times
   - Verify all assets load correctly

## Troubleshooting

### Common Issues

**1. Asset Not Found**
- Check path in `pubspec.yaml`
- Run `flutter pub get`
- Clean and rebuild: `flutter clean && flutter pub get`

**2. Large App Size**
- Compress images (TinyPNG)
- Use WebP format
- Move large files to CDN

**3. Slow Loading**
- Implement caching
- Use thumbnails for lists
- Lazy load assets

**4. Memory Issues**
- Dispose unused resources
- Use `RepaintBoundary` for heavy widgets
- Optimize image resolution

## Next Steps

1. **Start with Priority 1 assets** (MVP essentials)
2. **Test each asset type** as you add it
3. **Optimize file sizes** before final deployment
4. **Document** what you've added and where it came from
5. **Get feedback** from test users on asset quality

---

## Support Resources

**Design:**
- Figma Community: https://www.figma.com/community
- Canva Templates: https://www.canva.com

**Stock Assets:**
- Images: Unsplash, Pexels, Pixabay
- Audio: Freesound, Zapsplat
- Video: Pexels Videos, Pixabay Videos

**Learning:**
- Flutter Assets Guide: https://docs.flutter.dev/ui/assets-and-images
- Rive Learn: https://rive.app/learn
- Video Editing: YouTube tutorials

---

**You now have a complete roadmap for populating all asset directories!** Start with JSON (done ✅), then move to images and videos. Build incrementally and test frequently. 🚀
