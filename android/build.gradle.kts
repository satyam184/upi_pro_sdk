plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.android")
}

group = "com.upipro.upi_pro_sdk"
version = "1.0-SNAPSHOT"

android {
    namespace = "com.upipro.upi_pro_sdk"
    compileSdk = 35

    defaultConfig {
        minSdk = 21
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.13.1")
}
