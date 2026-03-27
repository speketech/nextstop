allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

subprojects {
    afterEvaluate {
        if (project.name == "isw_mobile_sdk") {
            val extension = project.extensions.getByName("android")
            if (extension is com.android.build.gradle.LibraryExtension) {
                if (extension.namespace == null) {
                    extension.namespace = "com.interswitchgroup.isw_mobile_sdk"
                }
            }
        }
    }
}
