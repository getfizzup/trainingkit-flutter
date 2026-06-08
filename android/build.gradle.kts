import java.util.Properties

group = "com.fysiki.trainingkit_flutter"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "2.3.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

// Credentials and configuration are read from the host app's
// `android/local.properties`, Gradle properties, or environment variables.
val localProperties =
    Properties().apply {
        val file = rootProject.file("local.properties")
        if (file.exists()) {
            file.inputStream().use { load(it) }
        }
    }

val githubUser: String? =
    localProperties.getProperty("GithubUser")
        ?: (findProperty("GithubUser") as String?)
        ?: System.getenv("GITHUB_USERNAME")

val githubToken: String? =
    localProperties.getProperty("GithubToken")
        ?: (findProperty("GithubToken") as String?)
        ?: System.getenv("GITHUB_TOKEN")

val chromecastReceiverApplicationId: String =
    (
        localProperties.getProperty("chromecastReceiverApplicationId")
            ?: (findProperty("chromecastReceiverApplicationId") as String?)
            ?: System.getenv("CHROMECAST_RECEIVER_APPLICATION_ID")
            ?: ""
    ).trim()

repositories {
    google()
    mavenCentral()
    maven {
        url = uri("https://maven.pkg.github.com/getfizzup/trainingkit-android-sdk")
        credentials {
            username = githubUser
            password = githubToken
        }
    }
}

android {
    namespace = "com.fysiki.trainingkit_flutter"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
        buildConfigField(
            "String",
            "CHROMECAST_RECEIVER_APPLICATION_ID",
            "\"$chromecastReceiverApplicationId\"",
        )
    }

    buildFeatures {
        buildConfig = true
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    implementation("com.fysiki:trainingkit:v32.1")
    implementation("com.google.android.gms:play-services-cast-framework:21.4.0")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.activity:activity-ktx:1.11.0")
    implementation("androidx.core:core-ktx:1.17.0")
    implementation("com.google.code.gson:gson:2.11.0")
}
