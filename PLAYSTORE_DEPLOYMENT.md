# Play Store Deployment Guide for CalorieWala

## Prerequisites Checklist

### 1. App Information
- ✅ App Name: CalorieWala
- ✅ Package Name: com.caloriewala.app
- ✅ Version: 1.0.0 (Version Code: 1)
- ✅ Min SDK: 21 (Android 5.0)
- ✅ Target SDK: Latest

### 2. Required Assets
- ✅ App Icon (512x512 for Play Store)
- ⬜ Feature Graphic (1024x500)
- ⬜ Screenshots (at least 2, up to 8)
  - Phone: 16:9 or 9:16 aspect ratio
  - Recommended: 1080x1920 or 1920x1080
- ⬜ Privacy Policy URL (required for apps that request permissions)

### 3. App Signing
You need to create a keystore for signing your app.

#### Create Keystore (One-time setup):
```bash
keytool -genkey -v -keystore C:\Users\ADESH\caloriewala-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias caloriewala
```

**IMPORTANT**: 
- Save the keystore file safely - you cannot update your app without it!
- Remember the passwords you set
- Store backup in secure location

#### Create key.properties file:
Create file at: `android/key.properties`
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=caloriewala
storeFile=C:/Users/ADESH/caloriewala-key.jks
```

**Add to .gitignore**:
```
android/key.properties
*.jks
```

## Build Steps

### 1. Update Version (if needed)
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

### 2. Build App Bundle (Recommended)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### 3. Or Build APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Note**: Play Store prefers App Bundle (AAB) for better optimization.

## Play Store Console Setup

### 1. Create App
1. Go to [Google Play Console](https://play.google.com/console)
2. Click "Create app"
3. Fill in app details:
   - App name: CalorieWala
   - Default language: English (US) or Hindi
   - App or Game: App
   - Free or Paid: Free
   - Accept declarations

### 2. Store Listing
- **Short description** (80 chars):
  "AI-powered Indian food calorie tracker. Scan, analyze, and track your meals."

- **Full description** (4000 chars):
  ```
  CalorieWala - Your Smart Indian Food Calorie Tracker
  
  Track your nutrition effortlessly with AI-powered food recognition designed for Indian cuisine. Whether it's dal, roti, biryani, or samosas, CalorieWala helps you understand what you eat.
  
  ✨ KEY FEATURES:
  • 📸 Smart Food Recognition - Take a photo or describe your meal
  • 🔍 Barcode Scanner - Instant nutrition info for packaged foods
  • 🥗 Indian Food Database - Recognizes regional dishes
  • 📊 Macro Tracking - Calories, protein, carbs, and fats
  • 📈 Progress Dashboard - Weekly trends and daily stats
  • 🎯 Goal Setting - Set and track calorie goals
  • 🌙 Dark Mode - Easy on the eyes
  • 🔒 Offline Support - Works without internet
  
  🍛 PERFECT FOR:
  • Weight loss or muscle gain goals
  • Diabetes management
  • Fitness enthusiasts
  • Health-conscious individuals
  • Anyone tracking macros
  
  🇮🇳 INDIAN FOOD SUPPORT:
  Recognizes common Indian foods including:
  • North Indian: Roti, Paratha, Dal, Paneer dishes
  • South Indian: Dosa, Idli, Sambar, Vada
  • Street Food: Samosa, Pakora, Chaat
  • And much more!
  
  💡 HOW IT WORKS:
  1. Take a photo or scan barcode
  2. AI analyzes and estimates nutrition
  3. Review and save your meal
  4. Track your daily progress
  
  🔐 PRIVACY:
  • All data stored locally on your device
  • No account required
  • Your food data stays private
  
  Download CalorieWala today and start your healthy eating journey!
  ```

- **App icon**: Upload 512x512 PNG
- **Feature graphic**: Upload 1024x500 PNG/JPG
- **Screenshots**: Upload at least 2 phone screenshots
- **App category**: Health & Fitness
- **Contact email**: Your email
- **Privacy policy**: URL to your privacy policy

### 3. Content Rating
Complete questionnaire:
- App category: Health & Fitness
- Answer questions about violence, sexuality, etc. (all "No" for this app)
- Select appropriate rating

### 4. App Content
- Privacy Policy: Required (provide URL or in-app)
- Ads: Declare if app contains ads (No for now)
- App access: Full access (no restrictions)
- Content ratings: Complete questionnaire
- Target audience: Age 13+ recommended
- News app: No
- COVID-19 contact tracing/status: No
- Data safety: Fill form about data collection
  - Collects: Camera (photos), Device storage
  - Does NOT collect: Personal info, Location, Contacts
  - Data not shared with third parties
  - Data stored locally, user can delete

### 5. Store Presence
- Countries: Select India and other target countries
- Pricing: Free

### 6. Upload App
1. Go to "Release" → "Production"
2. Click "Create new release"
3. Upload the `.aab` file
4. Add release notes:
   ```
   Version 1.0.0
   • Initial release
   • AI-powered food recognition
   • Barcode scanner for packaged foods
   • Indian food database
   • Calorie and macro tracking
   • Dark mode support
   • Offline mode
   ```
5. Review and roll out

## Testing Before Release

### Internal Testing
1. Create internal testing track
2. Add your email as tester
3. Upload AAB and test thoroughly
4. Check on multiple devices/Android versions

### Closed Testing (Optional)
1. Invite beta testers
2. Collect feedback
3. Fix bugs
4. Update app

## Post-Launch Checklist
- [ ] Monitor crash reports in Play Console
- [ ] Respond to user reviews
- [ ] Track user acquisition metrics
- [ ] Plan updates based on feedback
- [ ] Set up Google Analytics (optional)

## Important Files to Keep Safe
1. `caloriewala-key.jks` - Keystore file (BACKUP!)
2. `android/key.properties` - Key information
3. Store passwords in secure password manager
4. Keep backup of signing keys

## Common Issues

### Issue: "App not signed"
Solution: Ensure key.properties is set up and keystore exists

### Issue: "Version conflict"
Solution: Increment version in pubspec.yaml

### Issue: "API key not configured"
Solution: Make sure Groq API key is in .env or use fallback

## Resources
- [Play Console](https://play.google.com/console)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Play Store Guidelines](https://play.google.com/about/developer-content-policy/)

---
**REMINDER**: Never commit keystore files or key.properties to Git!
