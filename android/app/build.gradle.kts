// ============================================================
//  SONIQ — android/app/build.gradle.kts (Kotlin DSL)
// ============================================================

import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 🎯 Load key.properties from the android/ directory or project root
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// ── android{} block ──────────────────────────────────────────
android {
    namespace  = "com.soniq.music"
    compileSdk = 36
    ndkVersion = "28.2.13676358" // 🎯 FIXED: Updated to NDK 28.2+ to enforce 16KB memory page alignment

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.lambda17.soniq"
        minSdk        = 24
        targetSdk     = 36
        versionCode   = flutter.versionCode
        versionName   = flutter.versionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    signingConfigs {
        getByName("debug") {
            storeFile     = file("${System.getProperty("user.home")}/.android/debug.keystore")
            storePassword = "android"
            keyAlias      = "androiddebugkey"
            keyPassword   = "android"
        }
        
        create("release") {
            val envPath = System.getenv("KEYSTORE_PATH")
            val localPath = keystoreProperties["storeFile"]?.toString()
            
            // Evaluates multiple potential paths and verifies file existence before assignment
            val candidateFile = when {
                !envPath.isNullOrEmpty() && file(envPath).exists() -> file(envPath)
                !localPath.isNullOrEmpty() && file(localPath).exists() -> file(localPath)
                file("/Users/balaji.v/upload-keystore.jks").exists() -> file("/Users/balaji.v/upload-keystore.jks")
                else -> null
            }

            // Only bind the configuration variables if a valid keystore is located
            if (candidateFile != null) {
                storeFile = candidateFile
                storePassword = System.getenv("KEYSTORE_PASSWORD") 
                    ?: keystoreProperties["storePassword"]?.toString() ?: ""
                keyAlias = System.getenv("KEY_ALIAS") ?: System.getenv("ALIAS") 
                    ?: keystoreProperties["keyAlias"]?.toString() ?: ""
                keyPassword = System.getenv("KEY_PASSWORD") 
                    ?: keystoreProperties["keyPassword"]?.toString() ?: ""
            }
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
            manifestPlaceholders["crashlyticsEnabled"] = "false"
            applicationIdSuffix = ".debug"
            versionNameSuffix   = "-debug"
        }

        getByName("release") {
            val releaseConf = signingConfigs.getByName("release")
            val debugConf = signingConfigs.getByName("debug")
            
            // 🎯 FIXED: Cascade fallback for CI environments. 
            // 1. Try Release Key. 2. Try Debug Key. 3. Build Unsigned.
            signingConfig = when {
                releaseConf.storeFile?.exists() == true -> releaseConf
                debugConf.storeFile?.exists() == true -> debugConf
                else -> null 
            }
            
            manifestPlaceholders["crashlyticsEnabled"] = "true"
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        buildConfig = true
    }

    lint {
        checkReleaseBuilds = true
        abortOnError       = false
        checkDependencies  = true
    }

    packaging {
        resources {
            excludes += listOf(
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "/META-INF/{AL2.0,LGPL2.1}"
            )
        }
        jniLibs {
            useLegacyPackaging = false 
        }
    }
}

// ── Kotlin compiler options ──────────────────────────────────
kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}

// ── Dependencies ─────────────────────────────────────────────
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.media:media:1.7.0")

    // Locked to strictly 16KB-ready binary
    implementation("com.google.mlkit:language-id:17.0.6")

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}

flutter {
    source = "../.."
}