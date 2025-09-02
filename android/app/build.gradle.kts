plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ar_bracelet"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        // ✅ Kotlin DSL style
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true   // ✅ note the "is" prefix
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.ar_bracelet"
        minSdk = 21
        targetSdk = 34
        versionCode = flutter.versionCode    // ✅ Kotlin DSL way
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.24")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // ✅ latest
}
