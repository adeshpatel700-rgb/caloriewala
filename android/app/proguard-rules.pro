# Add rules here to customize which files proguard keeps
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep Google Play Core
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep Hive classes
-keep class * extends hive.HiveObject
-keepclassmembers class * extends hive.HiveObject {
    <fields>;
}

# Keep model classes for JSON serialization
-keep class com.caloriewala.app.**.models.** { *; }
-keepclassmembers class com.caloriewala.app.**.models.** {
    <fields>;
    <methods>;
}

# Mobile Scanner
-keep class com.google.mlkit.vision.barcode.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
