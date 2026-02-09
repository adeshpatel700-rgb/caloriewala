# CalorieWala - Setup Instructions

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.2.0 or higher)
- Android Studio / VS Code
- Groq API Key ([Get it here](https://console.groq.com/keys))

### Installation Steps

1. **Clone/Download the project**
   ```bash
   cd caloriewala
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Copy `.env.example` to `.env`
   ```bash
   copy .env.example .env
   ```
   - Open `.env` and add your Groq API key:
   ```
   GROQ_API_KEY=your_actual_api_key_here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📱 App Features

### Core Functionality
- **📷 Photo Analysis**: Take or upload food photos for instant calorie estimation
- **✏️ Text Input**: Describe food in English or Hinglish (e.g., "2 roti aur dal")
- **🎯 AI-Powered**: Uses Groq's vision and text LLMs for accurate Indian food recognition
- **📊 Detailed Breakdown**: Get calories, protein, carbs, and fat information
- **💡 Health Insights**: Receive culturally appropriate health notes
- **🌓 Dark Mode**: Beautiful light and dark themes

### Indian Food Optimized
- Recognizes common Indian dishes (dal, roti, sabzi, rice, etc.)
- Understands Indian portion sizes (katori, piece, cup)
- Supports Hinglish input
- Culturally appropriate health recommendations

---

## 🏗️ Architecture

### Clean Architecture
```
lib/
├── core/              # Shared utilities, themes, configs
├── features/          # Feature modules
│   ├── home/
│   ├── analysis/
│   ├── history/
│   └── settings/
```

### State Management
- **Riverpod** for reactive state management
- Compile-time safety
- Easy testing and dependency injection

### Tech Stack
- Flutter 3.2+
- Riverpod for state management
- Dio for networking
- Hive for local storage
- Image Picker for camera/gallery
- Google Fonts for typography

---

## 🔑 API Configuration

### Groq API
- **Vision Model**: `llama-3.2-90b-vision-preview`
- **Text Model**: `llama-3.1-70b-versatile`
- **Free Tier**: Generous limits for testing
- **Get API Key**: https://console.groq.com/keys

### Environment Variables
All API configuration is in `.env`:
```env
GROQ_API_KEY=your_key_here
GROQ_BASE_URL=https://api.groq.com/openai/v1
VISION_MODEL=llama-3.2-90b-vision-preview
TEXT_MODEL=llama-3.1-70b-versatile
```

---

## 🛠️ Development

### Run in Debug Mode
```bash
flutter run
```

### Build Release APK
```bash
flutter build apk --release
```

### Run Tests
```bash
flutter test
```

### Code Generation (if needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📋 Permissions

### Android
The app requires the following permissions:
- **Camera**: To take food photos
- **Storage**: To select photos from gallery
- **Internet**: To communicate with Groq API

All permissions are requested at runtime with proper user prompts.

---

## ⚠️ Important Notes

### Medical Disclaimer
CalorieWala provides approximate nutritional estimates for informational purposes only. These estimates are not a substitute for professional medical or dietary advice. Always consult a healthcare provider for personalized dietary guidance.

### Data Privacy
- Images are sent to Groq API for analysis
- No images are stored on servers
- Meal history is stored locally on device
- No personal data is collected

### Free Tier Limits
- Currently set to 10 analyses per day
- Can be modified in `lib/core/config/app_config.dart`
- Premium features prepared for future monetization

---

## 🎨 Customization

### Change Daily Limit
Edit `lib/core/config/app_config.dart`:
```dart
static const int freeAnalysesPerDay = 10; // Change this
```

### Modify Theme Colors
Edit `lib/core/theme/app_colors.dart`

### Update Prompts
Edit prompts in `lib/features/analysis/data/datasources/groq_api_service.dart`

---

## 📦 Building for Production

### 1. Update Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

### 2. Generate Signing Key
```bash
keytool -genkey -v -keystore caloriewala-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias caloriewala
```

### 3. Create `android/key.properties`
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=caloriewala
storeFile=../caloriewala-release-key.jks
```

### 4. Build Release APK
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

---

## 🐛 Troubleshooting

### "GROQ_API_KEY not found"
- Ensure `.env` file exists in project root
- Check that API key is correctly set
- Restart the app after adding the key

### Camera Permission Denied
- Go to Settings → Apps → CalorieWala → Permissions
- Enable Camera and Storage permissions

### Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

### Image Analysis Fails
- Check internet connection
- Verify API key is valid
- Ensure image size is under 5MB

---

## 📞 Support

For issues or questions:
1. Check this README
2. Review error messages carefully
3. Ensure API key is configured correctly

---

## 🚀 Future Features

- [ ] Meal history with cloud sync
- [ ] Weekly nutrition reports
- [ ] Meal planning suggestions
- [ ] Barcode scanning
- [ ] Premium subscription
- [ ] Export nutrition data

---

## 📄 License

This project is for educational and personal use.

---

**Built with ❤️ for Indian food lovers**
