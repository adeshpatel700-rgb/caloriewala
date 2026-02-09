# Build Troubleshooting Guide

## Current Build Issue

The release build is failing with Gradle errors. Here are the steps to resolve:

### Quick Fix: Run in Debug Mode First

Instead of building a release APK immediately, test the app in debug mode:

```bash
# Connect your Android device or start an emulator
flutter run
```

This will:
- Skip the release build complexity
- Let you test all features
- Verify the app works correctly

### For Release Build

If you need a release APK, follow these steps:

#### 1. Ensure API Key is Set

Edit `.env` and add your Groq API key:
```
GROQ_API_KEY=gsk_your_actual_key_here
```

#### 2. Try Debug APK First

```bash
flutter build apk --debug
```

This creates an installable APK without release signing.

#### 3. For Signed Release APK

You'll need to set up signing:

**a. Generate a keystore:**
```bash
keytool -genkey -v -keystore caloriewala-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias caloriewala
```

**b. Create `android/key.properties`:**
```properties
storePassword=your_password
keyPassword=your_password  
keyAlias=caloriewala
storeFile=../caloriewala-release-key.jks
```

**c. Update `android/app/build.gradle.kts`:**

Add before `android {`:
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Update `buildTypes`:
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}

signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

**d. Build:**
```bash
flutter build apk --release
```

### Alternative: Use App Bundle

For Play Store, use AAB instead:
```bash
flutter build appbundle --release
```

## Common Issues

### "JAVA_HOME not set"
- Flutter usually handles this automatically
- If you see this error when running `gradlew` directly, use `flutter build` instead

### "minSdkVersion error"
- Already fixed in build.gradle.kts
- Uses `minSdk = 21` directly

### "API key not found"
- Make sure `.env` file exists
- Check that `GROQ_API_KEY` is set
- Restart the app after changing `.env`

## Testing Checklist

Before building release:

- [ ] Add Groq API key to `.env`
- [ ] Test in debug mode: `flutter run`
- [ ] Verify camera permissions work
- [ ] Test image analysis
- [ ] Test text input
- [ ] Check error handling (no internet, etc.)

## Recommended Workflow

1. **Development**: Use `flutter run` for testing
2. **Testing APK**: Use `flutter build apk --debug`
3. **Release APK**: Set up signing, then `flutter build apk --release`
4. **Play Store**: Use `flutter build appbundle --release`

## Need Help?

If build issues persist:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Try `flutter run` first
4. Check that Android SDK is properly installed
5. Verify `flutter doctor` shows no issues
