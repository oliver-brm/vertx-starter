import com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar
import org.gradle.api.tasks.testing.logging.TestLogEvent.*
<#if language == "kotlin">
<#if vertxVersion?starts_with("5.")>
import org.jetbrains.kotlin.gradle.dsl.jvm.JvmTargetValidationMode.IGNORE
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
import org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile
<#else>
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile
</#if>
</#if>

plugins {
<#if language == "kotlin">
<#if vertxVersion?starts_with("5.")>
  kotlin ("jvm") version "2.0.0"
<#else>
  kotlin ("jvm") version "1.7.21"
</#if>
<#elseif language == "scala">
  scala
<#else>
  java
</#if>
  application
  id("com.github.johnrengelman.shadow") version "7.1.2"
}

group = "${groupId}"
version = "1.0.0-SNAPSHOT"

repositories {
<#if vertxVersion?ends_with("-SNAPSHOT")>
  maven {
    url = uri("https://s01.oss.sonatype.org/content/repositories/snapshots")
    mavenContent {
      snapshotsOnly()
    }
  }
</#if>
  mavenCentral()
}

val vertxVersion = "${vertxVersion}"
val junitJupiterVersion = "5.9.1"

val mainVerticleName = "${packageName}.MainVerticle"
<#if vertxVersion?starts_with("5.")>
val launcherClassName = "io.vertx.launcher.application.VertxApplication"
<#else>
val launcherClassName = "io.vertx.core.Launcher"
</#if>

val watchForChange = "src/**/*"
<#noparse>
val doOnChange = "${projectDir}/gradlew classes"
</#noparse>

application {
  mainClass.set(launcherClassName)
}

dependencies {
  implementation(platform("io.vertx:vertx-stack-depchain:$vertxVersion"))
<#if !vertxDependencies?has_content>
  implementation("io.vertx:vertx-core")
</#if>
<#if vertxVersion?starts_with("5.")>
  implementation("io.vertx:vertx-launcher-application")
</#if>
<#list vertxDependencies as dependency>
  implementation("io.vertx:${dependency}")
</#list>
<#if language == "kotlin" && vertxVersion?starts_with("4.")>
  implementation(kotlin("stdlib-jdk8"))
<#elseif language == "scala">
  implementation("org.scala-lang:scala3-library_3:3.5.2")
  implementation("io.vertx:vertx-lang-scala_3:${vertxVersion}")
</#if>
<#if hasPgClient>
  implementation("com.ongres.scram:client:2.1")
</#if>
<#if language == "scala">
  testImplementation("io.vertx:vertx-lang-scala-test_3:${vertxVersion}")
  testImplementation("org.scalatest:scalatest_3:3.2.19")
  testRuntimeOnly("org.scalatestplus:junit-5-11_3:3.2.19.0")
<#elseif hasVertxJUnit5>
  testImplementation("io.vertx:vertx-junit5")
  testImplementation("org.junit.jupiter:junit-jupiter:$junitJupiterVersion")
<#elseif hasVertxUnit>
  testImplementation("io.vertx:vertx-unit")
  testImplementation("junit:junit:4.13.2")
</#if>
}

<#if language == "kotlin">
val compileKotlin: KotlinCompile by tasks
<#if vertxVersion?starts_with("5.")>
compileKotlin.kotlinOptions.jvmTarget = "${jdkVersion?switch('11', '11', '17' '17', '21' '21', '17')}"

tasks.withType<KotlinJvmCompile>().configureEach {
  jvmTargetValidationMode.set(IGNORE)
}
<#else>
compileKotlin.kotlinOptions.jvmTarget = "${jdkVersion?switch('11', '11', '17' '17', '17')}"
</#if>
<#else>
java {
  sourceCompatibility = JavaVersion.VERSION_${jdkVersion?replace(".", "_")}
  targetCompatibility = JavaVersion.VERSION_${jdkVersion?replace(".", "_")}
}
</#if>

tasks.withType<ShadowJar> {
  archiveClassifier.set("fat")
  manifest {
    attributes(mapOf("Main-Verticle" to mainVerticleName))
  }
  mergeServiceFiles()
}

tasks.withType<Test> {
<#if language == "scala">
  useJUnitPlatform()
<#elseif hasVertxJUnit5>
  useJUnitPlatform()
<#elseif hasVertxUnit>
  useJUnit()
</#if>
  testLogging {
    events = setOf(PASSED, SKIPPED, FAILED)
  }
}

tasks.withType<JavaExec> {
<#if vertxVersion?starts_with("5.")>
  args = listOf(mainVerticleName)
<#else>
  args = listOf("run", mainVerticleName, "--redeploy=$watchForChange", "--launcher-class=$launcherClassName", "--on-redeploy=$doOnChange")
</#if>
}
