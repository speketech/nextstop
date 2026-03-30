// 1. Imports
import com.android.build.gradle.LibraryExtension
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

// 2. Repositories block
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// 3. Build directory management
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 4. Evaluation dependency
subprojects {
    project.evaluationDependsOn(":app")
}

// 5. Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// 6. Project-wide Configuration
subprojects {
    // We use a helper function to avoid "project already evaluated" errors
    fun configureProject() {
        // Fix for isw_mobile_sdk (AGP 8.x Compatibility)
        if (project.name == "isw_mobile_sdk") {
            extensions.findByType<LibraryExtension>()?.apply {
                if (namespace == null) {
                    namespace = "com.interswitchgroup.isw_mobile_sdk"
                }
            }
        }

        // Force Java 17 for all Android modules
        if (project.hasProperty("android")) {
            val extension = project.extensions.getByName("android")
            if (extension is com.android.build.gradle.BaseExtension) {
                extension.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }

        // Force Kotlin JVM Target 17
        project.tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }

    if (state.executed) {
        configureProject()
    } else {
        afterEvaluate {
            configureProject()
        }
    }
}
