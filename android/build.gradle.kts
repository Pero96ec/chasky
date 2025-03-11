// Agregar configuración para Android Gradle Plugin (AGP)
buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal() // Agrega este repositorio para resolver plugins
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.1") // Mantén la última versión compatible
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
