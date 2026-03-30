import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

// ─── 🚀 LOAD .ENV FROM FLUTTER ROOT ──────────────────────────────────────────
val envProperties = Properties()
// We use "../../.env" because this file is in android/app/
// and .env is in the main project root.
val envFile = project.rootProject.file("../.env") 
if (envFile.exists()) {
    envFile.inputStream().use { envProperties.load(it) }
} else {
    logger.warn("⚠️ .env file not found at ${envFile.absolutePath}")
}

val mapsApiKey = envProperties.getProperty("GOOGLE_MAPS_API_KEY") ?: ""

android {
    namespace = "com.example.nextstop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.nextstop"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject the API key into the Manifest
        manifestPlaceholders["MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}