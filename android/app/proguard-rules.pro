# Flutter and plugin keep rules to prevent R8 from removing required classes
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class com.baseflow.** { *; }
-keep class dev.fluttercommunity.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
# Add more keep rules as needed for other plugins 