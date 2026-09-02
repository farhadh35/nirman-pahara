import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing details live outside the repository, so a contributor with no
// release key can still build and run. What must never happen is a release
// build that is quietly debug-signed: the Gradle output looks identical either
// way, Flutter filters warnings out of it anyway, and the place you find out is
// the Play upload dialog.
//
// So the fallback is refused rather than announced. Building a release without
// the key requires saying so:
//
//   flutter build apk --release -PallowDebugSigning=true
//
// The check covers the store file as well as key.properties, because the .jks
// lives outside the repository and is the one file in this project with no
// second copy anywhere.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val allowDebugSigning = project.hasProperty("allowDebugSigning")

val releaseKeyProblem: String? = if (!keystorePropertiesFile.exists()) {
    "android/key.properties does not exist"
} else {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    val storeName = keystoreProperties["storeFile"] as String?
    when {
        storeName == null -> "android/key.properties does not name a storeFile"
        !project.file(storeName).exists() ->
            "the keystore '$storeName' named by android/key.properties is missing"
        else -> null
    }
}
val hasReleaseKey = releaseKeyProblem == null

gradle.taskGraph.whenReady {
    val releasing = allTasks.any {
        it.name.contains("Release") && (
            it.name.startsWith("assemble") || it.name.startsWith("bundle")
        )
    }
    if (releasing && !hasReleaseKey && !allowDebugSigning) {
        throw GradleException(
            "Refusing to build a debug-signed release: $releaseKeyProblem.\n" +
            "Such a build cannot be uploaded to Play, and nothing in the " +
            "output would tell you that.\n" +
            "Restore the keystore, or pass -PallowDebugSigning=true to build " +
            "an unuploadable one on purpose."
        )
    }
}

android {
    namespace = "bd.nirmanpahara.nirman_pahara"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "bd.nirmanpahara.nirman_pahara"
        // Raised from the Flutter default: geolocator and the photo pipeline
        // both need a modern baseline, and it still covers the overwhelming
        // majority of handsets in Bangladesh.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
