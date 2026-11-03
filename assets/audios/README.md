# Khetopedia - Audio Assets

This directory contains audio assets for the Khetopedia agricultural application.

## Directory Structure

```
audios/
├── notifications/      # Notification sounds
├── voice_guides/      # Voice instructions and tutorials
├── feedback/          # UI feedback sounds
└── alerts/           # Alert and warning sounds
```

## Required Audio Assets

### 1. Notification Sounds

**Purpose:** Alert users about important events

**Required Sounds:**
- New recommendation available
- Disease detected
- Soil test complete
- Weather alert
- Irrigation reminder
- Fertilizer application reminder

**Specifications:**
- Format: MP3 or AAC
- Duration: 1-3 seconds
- Bitrate: 128 kbps
- Volume: Normalized to -14 LUFS
- Sample Rate: 44.1 kHz

**Naming Convention:**
```
notification_type.mp3
Examples:
- notification_disease_detected.mp3
- notification_weather_alert.mp3
- notification_recommendation.mp3
```

### 2. Voice Guidance (Hindi + English)

**Purpose:** Audio instructions for users with low literacy

**Required Voice Guides:**

#### English Voice Guides:
1. **Welcome Message:** "Welcome to Khetopedia, your smart farming companion"
2. **Camera Instructions:** "Point your camera at the affected leaf and tap capture"
3. **Disease Detection:** "Analyzing image... Disease detected: Late Blight"
4. **Soil Test Instructions:** "Enter your soil test values. Start with pH level"
5. **Weather Alerts:** "Heavy rain expected tomorrow. Postpone pesticide application"
6. **Irrigation Reminder:** "Time to irrigate your wheat field"
7. **Success Messages:** "Field added successfully", "Scan complete", "Recommendation saved"

#### Hindi Voice Guides (Same content in Hindi):
1. **Welcome:** "खेतोपीडिया में आपका स्वागत है"
2. **Camera:** "प्रभावित पत्ती पर कैमरा लगाएं और फोटो खींचें"
3. **Disease:** "जांच हो रही है... बीमारी पाई गई: लेट ब्लाइट"
4. **Soil:** "अपनी मिट्टी परीक्षण मान दर्ज करें। पीएच स्तर से शुरू करें"
5. **Weather:** "कल भारी बारिश की संभावना। कीटनाशक छिड़काव स्थगित करें"
6. **Irrigation:** "अपने गेहूं के खेत में सिंचाई का समय"
7. **Success:** "खेत सफलतापूर्वक जोड़ा गया"

**Specifications:**
- Format: MP3
- Bitrate: 64 kbps (voice optimized)
- Duration: 3-10 seconds per clip
- Voice: Clear, professional, neutral accent
- Speed: Moderate (not too fast for comprehension)

**Recording Guidelines:**
- Use professional voice talent or text-to-speech AI
- Record in quiet environment
- Remove background noise
- Apply light compression
- Normalize volume levels

### 3. UI Feedback Sounds

**Purpose:** Provide audio feedback for user actions

**Required Sounds:**
- Button tap/click (light, pleasant)
- Success action (positive chime)
- Error/warning (attention sound, not harsh)
- Navigation whoosh (subtle)
- Image capture shutter
- Data loading (subtle progress indicator)
- Pull-to-refresh (soft sound)

**Specifications:**
- Format: MP3
- Duration: 0.2-0.5 seconds
- Bitrate: 96 kbps
- Volume: Subtle, not intrusive

**Naming Convention:**
```
feedback_action.mp3
Examples:
- feedback_button_tap.mp3
- feedback_success.mp3
- feedback_error.mp3
- feedback_camera_shutter.mp3
```

### 4. Alert Sounds

**Purpose:** Critical warnings that need immediate attention

**Alert Types:**
- Critical disease detected (urgent but not alarming)
- Severe weather warning (attention-grabbing)
- Soil toxicity detected (important)
- Pest infestation alert (urgent)
- System error (informative)

**Specifications:**
- Format: MP3
- Duration: 1-2 seconds
- Bitrate: 128 kbps
- Design: Attention-grabbing but not startling
- Volume: Louder than feedback sounds but not harsh

**Naming Convention:**
```
alert_type_severity.mp3
Examples:
- alert_disease_critical.mp3
- alert_weather_severe.mp3
- alert_toxicity_high.mp3
```

### 5. Tutorial Voice Narration

**Purpose:** Step-by-step audio tutorials

**Tutorial Topics:**
1. **First Time Setup** (60 seconds)
   - Welcome and registration
   - Adding first field
   - Profile setup

2. **Crop Scanner Tutorial** (45 seconds)
   - How to take clear photos
   - Understanding results
   - Viewing recommendations

3. **Soil Analysis Tutorial** (40 seconds)
   - Entering test values
   - Understanding toxicity alerts
   - Viewing trends

4. **Weather Integration** (30 seconds)
   - Reading weather forecast
   - Understanding advisories
   - Planning field activities

5. **AI Assistant Guide** (30 seconds)
   - How to ask questions
   - Getting recommendations
   - Understanding responses

**Specifications:**
- Format: MP3
- Bitrate: 96 kbps
- Clear pronunciation
- Pausable and skippable
- Background music (optional, very subtle)

### 6. Ambient Sounds (Optional)

**Purpose:** Background ambience for relaxing UI

**Sounds:**
- Light rain (for weather screens)
- Birds chirping (morning theme)
- Wind rustling (field ambience)
- Water flowing (irrigation context)

**Specifications:**
- Format: MP3
- Loopable (seamless loop)
- Duration: 10-30 seconds
- Very low volume (background only)
- Bitrate: 64 kbps

## Audio Implementation in Flutter

### Playing Notification Sounds

```dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  
  Future<void> playNotification(String type) async {
    await _player.play(
      AssetSource('audios/notifications/notification_$type.mp3'),
      volume: 0.7,
    );
  }
  
  Future<void> playFeedback(String action) async {
    await _player.play(
      AssetSource('audios/feedback/feedback_$action.mp3'),
      volume: 0.5,
    );
  }
}
```

### Text-to-Speech (Alternative to Pre-recorded)

```dart
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _tts = FlutterTts();
  
  Future<void> speak(String text, String language) async {
    await _tts.setLanguage(language); // 'en-IN' or 'hi-IN'
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(0.8);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }
}
```

## Audio File Sizes

**Estimated sizes per format:**
- Short feedback sound (0.5s): ~5-10 KB
- Notification sound (2s): ~30-50 KB
- Voice guide (5s): ~60-100 KB
- Tutorial narration (60s): ~1-2 MB
- Ambient loop (30s): ~500 KB - 1 MB

**Total estimated size:** 10-50 MB (depends on number of audio files)

## Audio Quality Guidelines

### Recording Quality
- **Environment:** Quiet, sound-treated room
- **Microphone:** Professional or high-quality USB microphone
- **Format:** Record in WAV (44.1 kHz, 16-bit)
- **Post-processing:** 
  - Noise reduction
  - Normalization
  - Light compression
  - Convert to MP3 for distribution

### Volume Levels
- **Notifications:** -14 LUFS
- **Feedback:** -18 LUFS  
- **Voice guides:** -16 LUFS
- **Alerts:** -12 LUFS (louder for attention)
- **Ambient:** -22 LUFS (very quiet background)

## Accessibility Considerations

1. **Provide Text Alternatives:**
   - All audio must have text equivalents
   - Subtitles for voice narration
   - Visual alerts alongside audio alerts

2. **User Control:**
   - Settings to enable/disable sounds
   - Volume control
   - Option to repeat voice guidance

3. **Localization:**
   - Multiple language versions
   - Consider regional accents for Hindi/English

## Sourcing Audio Assets

### Free Resources
- **Sound Effects:** Freesound.org, Zapsplat.com
- **Background Music:** Free Music Archive, YouTube Audio Library
- **Voice Recording:** Hire freelance voice artists on Fiverr, Upwork

### Text-to-Speech Services
- Google Cloud Text-to-Speech (supports Hindi)
- Amazon Polly
- Microsoft Azure TTS
- ElevenLabs (AI voice generation)

### Commercial Libraries
- Epidemic Sound
- AudioJungle
- Pond5

## Audio Asset Checklist

- [ ] Notification sounds (6 sounds × 2 languages = 12 files)
- [ ] UI feedback sounds (7 sounds = 7 files)
- [ ] Alert sounds (5 sounds = 5 files)
- [ ] Voice guides (7 guides × 2 languages = 14 files)
- [ ] Tutorial narrations (5 tutorials × 2 languages = 10 files)
- [ ] Ambient sounds (4 sounds, optional)
- [ ] Total: ~48 audio files

## Testing Audio

### Testing Checklist
- [ ] Test on multiple devices (Android, iOS)
- [ ] Test in noisy environment
- [ ] Test with headphones and speakers
- [ ] Verify looping works for ambient sounds
- [ ] Check volume levels are consistent
- [ ] Test TTS fallback if audio fails
- [ ] Verify accessibility features

## Flutter Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  audioplayers: ^5.2.0  # For playing audio files
  flutter_tts: ^3.8.3   # For text-to-speech fallback
  just_audio: ^0.9.36   # Alternative audio player

flutter:
  assets:
    - assets/audios/notifications/
    - assets/audios/feedback/
    - assets/audios/voice_guides/
    - assets/audios/alerts/
```

## License and Copyright

- Ensure all audio has appropriate usage rights
- Credit creators if required by license
- Prefer Creative Commons or royalty-free content
- Keep license documentation for all assets

---

**Note:** This directory currently contains placeholder markers. Add actual audio assets and update the above implementation before production deployment.

**Pro Tip:** For MVP, use Flutter TTS for voice guidance to avoid recording costs. Add pre-recorded audio in later versions for better quality and user experience.
