import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.feitolabs.sorte_feita"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.feitolabs.sorte_feita"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // AdMob App ID: ID de teste publico por padrao; producao via -PADMOB_APP_ID=... ou ~/.gradle/gradle.properties.
        manifestPlaceholders["admobAppId"] = (project.findProperty("ADMOB_APP_ID") as String?) ?: "ca-app-pub-3940256099942544~3347511713"
    }

    buildTypes {
        release {
            // Assinatura de release via android/key.properties (fora do Git).
            // Sem ele, usa a chave debug apenas para testes locais.
            val keyProps = Properties()
            val keyFile = rootProject.file("key.properties")
            if (keyFile.exists()) {
                keyFile.inputStream().use { keyProps.load(it) }
                signingConfigs.create("release") {
                    keyAlias = keyProps.getProperty("keyAlias")
                    keyPassword = keyProps.getProperty("keyPassword")
                    storeFile = file(keyProps.getProperty("storeFile"))
                    storePassword = keyProps.getProperty("storePassword")
                }
                signingConfig = signingConfigs.getByName("release")
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
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
