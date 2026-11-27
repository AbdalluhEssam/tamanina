import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingFile = rootProject.file("key.properties")
val releaseSigning = Properties()
if (signingFile.isFile) {
    signingFile.inputStream().use(releaseSigning::load)
}

android {
    namespace = "com.abdalluh.tamanina"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.abdalluh.tamanina"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (signingFile.isFile) {
        // Accepts storeFile or STORE_FILE style names.
        fun signingProperty(name: String): String {
            val upper = name.replace(Regex("([a-z])([A-Z])"), "$1_$2").uppercase()
            return requireNotNull(
                (releaseSigning.getProperty(name) ?: releaseSigning.getProperty(upper))
                    ?.takeIf { it.isNotBlank() }
            ) { "android/key.properties is missing $name." }
        }

        signingConfigs.create("release") {
            storeFile = rootProject.file(signingProperty("storeFile"))
            storePassword = signingProperty("storePassword")
            keyAlias = signingProperty("keyAlias")
            keyPassword = signingProperty("keyPassword")
        }
    }

    // Phones only: keeps the unused x86 native libraries out of the app.
    packaging {
        jniLibs {
            excludes += setOf("**/x86/**", "**/x86_64/**")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
            // The Flutter CLI expects symbols in its AAB. The compact Gradle
            // release keeps the stripped native libraries and omits that metadata.
            if (providers.environmentVariable("TAMANINA_COMPACT_BUNDLE").orNull == "1") {
                ndk.debugSymbolLevel = "NONE"
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
