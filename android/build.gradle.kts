import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ─── Build Directory Management ──────────────────────────────────────────────
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // Set subproject build directories
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // REMOVED: evaluationDependsOn(":app") 
    // This often causes the "already evaluated" error by forcing an unnatural build order.
}

// ─── Clean Task ──────────────────────────────────────────────────────────────
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ─── Interswitch SDK Namespace Fix ───────────────────────────────────────────
// Instead of afterEvaluate, we use plugins.withType to catch the library 
// as soon as it's ready, avoiding the evaluation lock.
subprojects {
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        if (project.name == "isw_mobile_sdk") {
            // Use configure on the extension directly
            extensions.configure<LibraryExtension> {
                if (namespace == null) {
                    namespace = "com.interswitchgroup.isw_mobile_sdk"
                }
            }
        }
    }
}