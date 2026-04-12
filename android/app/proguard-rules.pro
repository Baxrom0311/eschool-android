# Flutter Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Logic Specific to clean architecture (if any items are being stripped)
-keep class uz.ranchschool.parent_school_app.data.models.** { *; }

# standard obfuscation/shrinking rules
-dontobfuscate
-dontoptimize
-keepattributes Signature,Exceptions,*Annotation*
