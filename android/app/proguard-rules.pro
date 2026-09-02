# Flutter's engine entry points are reached from native code, so R8 cannot see
# the references and would otherwise strip them.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# image_picker and file_picker resolve activity results reflectively.
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Play Core is referenced by the Flutter deferred-components loader even when
# deferred components are not used; without this, R8 warns and fails the build.
-dontwarn com.google.android.play.core.**
