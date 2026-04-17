plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.synapse.twospace"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Application ID for TwoSpace messenger
        applicationId = "com.synapse.twospace"
        // Minimum SDK version increased from 21 to 24 for better library support
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Vector drawable support for older devices
        vectorDrawables.useSupportLibrary = true
        
        // Core library desugaring to support Java 8+ features on older Android versions
        // Required by flutter_local_notifications and other modern dependencies
        multiDexEnabled = true

        externalNativeBuild {
            cmake {
                cppFlags("")
            }
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            // Disable code shrinking/minification temporarily to avoid R8 missing
            // classes issues caused by transitive dependencies. This keeps the
            // release build simpler while we fix dependency proguard rules.
            isMinifyEnabled = false
            isShrinkResources = false
            // Keep proguard rules file available for future use
            proguardFiles("${project.rootDir}/proguard-rules.pro")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
        }
    }

    // Packaging options: avoid failures when multiple input AARs/JARs include
    // the same META-INF entries (happens with some dependency bundles). We
    // prefer the first occurrence for harmless metadata files.
    packagingOptions {
        resources {
            excludes += "META-INF/DEPENDENCIES"
            excludes += "META-INF/LICENSE"
            excludes += "META-INF/LICENSE.txt"
            excludes += "META-INF/NOTICE"
            excludes += "META-INF/NOTICE.txt"
            pickFirsts += "META-INF/com/android/build/gradle/app-metadata.properties"
        }
    }
}

dependencies {
    // Required for core library desugaring support on minSdk < 30
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
