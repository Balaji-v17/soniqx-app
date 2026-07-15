// ============================================================
//  SONIQ — android/app/build.gradle.kts  (Kotlin DSL)
//  AGP 8.11.1 | Kotlin 2.2.20 | compileSdk 36 | NDK 28.2.x
// ============================================================

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ── android{} block ──────────────────────────────────────────
// NOTE: kotlin{} is NOT nested inside android{} — it is a
// separate top-level block below. Nesting it here causes
// cascading "Unexpected symbol" parse errors in Kotlin DSL.
android {
    namespace  = "com.soniq.music"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.soniq.music"
        minSdk        = 24
        // targetSdk lives here in defaultConfig{}, NOT at the
        // top level of android{}. Top-level targetSdk is not a
        // valid property in AGP 8.x Kotlin DSL.
        targetSdk     = 35
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
        // Uncomment before Play Store submission:
        // create("release") {
        //     val props = java.util.Properties()
        //     file("../../key.properties").inputStream().use { props.load(it) }
        //     keyAlias      = props["keyAlias"] as String
        //     keyPassword   = props["keyPassword"] as String
        //     storeFile     = file(props["storeFile"] as String)
        //     storePassword = props["storePassword"] as String
        // }
    }

    buildTypes {
        debug {
            signingConfig = signingConfigs.getByName("debug")
            manifestPlaceholders["crashlyticsEnabled"] = "false"
            applicationIdSuffix = ".debug"
            versionNameSuffix   = "-debug"
        }
        release {
            // Change to getByName("release") before Play Store
            signingConfig = signingConfigs.getByName("debug")
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
                "/META-INF/{AL2.0,LGPL2.1}",
            )
        }
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

// ── Kotlin compiler options (TOP LEVEL — outside android{}) ──
// kotlinOptions{} is deprecated in Kotlin 2.x.
// kotlin{} must be a top-level block, not nested inside android{}.
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

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.2.1")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")
}

flutter {
    source = "../.."
}