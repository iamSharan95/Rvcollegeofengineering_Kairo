# MapLibre / Mapbox keep rules
-keep class com.mapbox.** { *; }
-keep interface com.mapbox.** { *; }
-keep class org.maplibre.** { *; }
-keep interface org.maplibre.** { *; }
-dontwarn com.mapbox.**
-dontwarn org.maplibre.**

# OkHttp keep rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Firebase/GMS rules are usually handled by the plugin, but adding these for safety
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
