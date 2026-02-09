# Play Store Submission Checklist

## ✅ Pre-Submission Requirements

### App Information
- [ ] App Name: CalorieWala
- [ ] Package Name: com.caloriewala.app
- [ ] Category: Health & Fitness
- [ ] Target Audience: 18+ (health/nutrition content)
- [ ] Content Rating: Everyone

### Required Assets

#### App Icon
- [ ] 512x512 PNG (high-res icon)
- [ ] Transparent background or solid color
- [ ] No text or complex details

#### Screenshots (Minimum 2, Recommended 6-8)
- [ ] 1080x1920 or 1440x2560 (portrait)
- [ ] Show key features:
  - [ ] Home screen
  - [ ] Camera/Photo selection
  - [ ] Food review screen
  - [ ] Results with nutrition breakdown
  - [ ] Dark mode variant

#### Feature Graphic
- [ ] 1024x500 PNG
- [ ] Promotional banner for Play Store listing

### Store Listing

#### Short Description (80 characters max)
```
AI-powered calorie estimator for Indian food. Photo or text input.
```

#### Full Description (4000 characters max)
```
CalorieWala - Your AI Food Nutrition Companion

Instantly estimate calories and nutrition for Indian food using AI-powered analysis. Simply take a photo or describe your meal!

🎯 KEY FEATURES:
• Photo Analysis: Take or upload food photos for instant calorie estimation
• Text Input: Describe food in English or Hinglish (e.g., "2 roti aur dal")
• AI-Powered: Advanced vision and language models for accurate recognition
• Detailed Breakdown: Get calories, protein, carbs, and fat information
• Health Insights: Receive culturally appropriate health recommendations
• Dark Mode: Beautiful light and dark themes

🍛 INDIAN FOOD OPTIMIZED:
• Recognizes common Indian dishes (dal, roti, sabzi, rice, curries, etc.)
• Understands Indian portion sizes (katori, piece, cup)
• Supports Hinglish input for convenience
• Culturally appropriate nutritional guidance

📊 NUTRITION TRACKING:
• Total calorie count
• Macronutrient breakdown (Protein, Carbs, Fat)
• Percentage-based macro distribution
• Health notes tailored for Indian cuisine

⚠️ IMPORTANT DISCLAIMER:
CalorieWala provides approximate nutritional estimates for informational purposes only. These estimates are not a substitute for professional medical or dietary advice. Actual values may vary based on ingredients, cooking methods, and portion sizes. Please consult a healthcare provider or registered dietitian for personalized dietary guidance.

🔒 PRIVACY:
• Images processed securely via API
• No images stored on servers
• Meal history stored locally on your device
• No personal data collection

Perfect for:
✓ Health-conscious individuals
✓ Fitness enthusiasts
✓ People managing their diet
✓ Anyone curious about food nutrition

Download CalorieWala today and make informed food choices!
```

### Privacy Policy
- [ ] Create privacy policy document
- [ ] Host on accessible URL (GitHub Pages, website, etc.)
- [ ] Include in app settings
- [ ] Add link to Play Store listing

### Required Policies

#### Data Safety Section
- [ ] Data collection: None (or specify what's collected)
- [ ] Data sharing: With Groq API for analysis
- [ ] Data security: Encrypted in transit
- [ ] Data deletion: Automatic (images not stored)

#### Permissions Justification
- [ ] Camera: "To capture food photos for analysis"
- [ ] Storage: "To select food photos from gallery"
- [ ] Internet: "To communicate with AI service for nutrition estimation"

---

## 🔐 App Security

### Code Obfuscation
- [ ] Enable ProGuard/R8 for release builds
- [ ] Test obfuscated build thoroughly

### API Key Security
- [ ] Never commit `.env` to version control
- [ ] Add `.env` to `.gitignore`
- [ ] Document API key setup in README

---

## 📱 Testing Requirements

### Device Testing
- [ ] Test on Android 5.0 (API 21) minimum
- [ ] Test on Android 14 (API 34) target
- [ ] Test on different screen sizes
- [ ] Test on low-end devices

### Feature Testing
- [ ] Camera permission flow
- [ ] Gallery permission flow
- [ ] Image analysis accuracy
- [ ] Text input functionality
- [ ] Error handling (no internet, API errors)
- [ ] Dark mode switching
- [ ] App lifecycle (background/foreground)

### Performance Testing
- [ ] App startup time < 3 seconds
- [ ] Image analysis < 15 seconds
- [ ] No memory leaks
- [ ] Smooth 60 FPS animations

---

## 🚀 Build Configuration

### Release Build
```bash
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### App Bundle (Recommended)
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Signing Configuration
- [ ] Generate release keystore
- [ ] Configure `android/key.properties`
- [ ] Update `android/app/build.gradle.kts` with signing config
- [ ] Test signed build

---

## 📋 Content Rating Questionnaire

### Violence
- [ ] No violent content

### Sexual Content
- [ ] No sexual content

### Profanity
- [ ] No profanity

### Controlled Substances
- [ ] No references to drugs/alcohol

### Health/Medical
- [x] Contains health/nutrition information
- [x] Includes medical disclaimer
- [x] Not providing medical diagnosis

---

## 🎯 Target Countries

### Initial Launch
- [ ] India (primary market)
- [ ] United States
- [ ] United Kingdom
- [ ] Canada
- [ ] Australia

### Language Support
- [ ] English (primary)
- [ ] Hindi (future update)

---

## 💰 Monetization

### Current Version
- [ ] Free with usage limits (10 analyses/day)
- [ ] No ads
- [ ] No in-app purchases (yet)

### Future Plans
- [ ] Premium subscription structure prepared
- [ ] In-app purchase integration points ready

---

## 📊 Analytics & Monitoring

### Crash Reporting
- [ ] Set up Firebase Crashlytics (optional)
- [ ] Test crash reporting

### Analytics
- [ ] Set up Firebase Analytics (optional)
- [ ] Track key events (analysis, errors)

---

## ✅ Final Checks

### Before Submission
- [ ] All features working correctly
- [ ] No debug code or logs in release
- [ ] All assets optimized (images, icons)
- [ ] README updated with latest info
- [ ] Version number incremented
- [ ] Changelog prepared

### Play Console Setup
- [ ] Developer account created ($25 one-time fee)
- [ ] Payment profile set up
- [ ] Tax information submitted
- [ ] App created in Play Console

### Submission
- [ ] Upload APK/AAB
- [ ] Complete store listing
- [ ] Add screenshots and graphics
- [ ] Set pricing (Free)
- [ ] Select countries
- [ ] Submit for review

---

## 📝 Post-Launch

### Monitoring
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Track download numbers
- [ ] Monitor API usage

### Updates
- [ ] Plan feature updates
- [ ] Fix reported bugs
- [ ] Improve based on feedback

---

## 🔗 Useful Links

- [Play Console](https://play.google.com/console)
- [Android App Bundle Guide](https://developer.android.com/guide/app-bundle)
- [Play Store Listing Guidelines](https://support.google.com/googleplay/android-developer/answer/9859455)
- [Content Rating Guide](https://support.google.com/googleplay/android-developer/answer/9859655)

---

**Estimated Review Time**: 1-7 days after submission
