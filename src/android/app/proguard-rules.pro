# Keep MainActivity and QuickPhraseManager
-keep class com.doubao.bridge.MainActivity { *; }
-keep class com.doubao.bridge.QuickPhraseManager { *; }

# Optimization settings
-optimizationpasses 5
-allowaccessmodification

# Remove logs in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
