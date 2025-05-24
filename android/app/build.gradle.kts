import com.android.build.gradle.BaseExtension
import java.util.Properties

val localProperties = Properties().apply {
    load(rootProject.file("local.properties").inputStream())
}

val flutterRoot = localProperties.getProperty("flutter.sdk")
    ?: throw GradleException("Flutter SDK not found. Define location with flutter.sdk in local.properties")

plugins {
    id("com.android.application")
    kotlin("android")
    id("com.google.gms.google-services")
}

configure<BaseExtension> {
    compileSdkVersion(localProperties.getProperty("flutter.compileSdkVersion").toInt())
    ndkVersion = localProperties.getProperty("flutter.ndkVersion")

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.example.demo"
        minSdkVersion(localProperties.getProperty("flutter.minSdkVersion").toInt())
        targetSdkVersion(localProperties.getProperty("flutter.targetSdkVersion").toInt())
        versionCode = localProperties.getProperty("flutter.versionCode").toInt()
        versionName = localProperties.getProperty("flutter.versionName")
    }

    buildTypes {
        getByName("release") {
            // Configure proper release signing (remove debug signing)
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.3.1"))
    implementation("com.google.firebase:firebase-analytics")
}

tasks.register("copyFlutterAssets", Copy::class) {
    from("$flutterRoot/packages/flutter_tools/gradle/")
    into("build/flutter")
}