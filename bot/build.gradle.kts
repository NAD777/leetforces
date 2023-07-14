plugins {
    java
    checkstyle
    id("org.springframework.boot") version "3.0.6"
    id("io.spring.dependency-management") version "1.1.0"
}

group = "org.nad777"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_17

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter")
    implementation("org.springframework.boot:spring-boot-starter-web")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-configuration-processor")
    implementation("org.springframework:spring-context-indexer:6.0.6")
    implementation("org.springframework:spring-webflux:6.0.6")
    implementation("com.github.pengrad:java-telegram-bot-api:6.6.0")
    implementation("io.micrometer:micrometer-registry-prometheus:1.11.0")
    implementation("io.micrometer:micrometer-tracing-bridge-brave:1.1.0")

    compileOnly("org.projectlombok:lombok:1.18.26")

    developmentOnly("org.springframework.boot:spring-boot-devtools")

    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")
    annotationProcessor("org.projectlombok:lombok:1.18.26")

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation("org.mockito:mockito-core:5.2.0")
    testImplementation("junit:junit:4.13.2")

    checkstyle("com.puppycrawl.tools:checkstyle:10.10.0")
}

checkstyle {
    configFile = rootProject.file("checkstyle.xml")
}

tasks.withType<Test> {
    useJUnitPlatform()
}
