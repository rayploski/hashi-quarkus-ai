# hashi-quarkus-ai Project

This project is a simple AI app that can be packaged and deployed to the clouds with HashiCorp tooling. This application
demonstrates an AI-infused chatbot application using Quarkus, LangChain4j, Infinispan, and multiple LLMs on
various cloud service providers.

## Prerequisites

- Java 21 or later
- Apache Maven 3.9.6 or later
- Podman or Docker (Podman recommended)
- Granite available using Podman Desktop (AI studio) or InstructLab

*IMPORTANT:* Update the LLM URL in the `application.properties` to match your Granite LLM URL.

## Running the Demo

To run the demo, navigate to the `4-rag` directory and run `mvn quarkus:dev`.

```
> mvn quarkus:dev
```

The UI is available at `http://localhost:8080`.

## Running the application in dev mode

You can run your application in dev mode that enables live coding using:
```shell script
./mvnw compile quarkus:dev
```

> **_NOTE:_**  Quarkus now ships with a Dev UI, which is available in dev mode only at http://localhost:8080/q/dev/.

## Packaging and running the application

The application can be packaged using:
```shell script
./mvnw package
```
It produces the `quarkus-run.jar` file in the `target/quarkus-app/` directory.
Be aware that it’s not an _über-jar_ as the dependencies are copied into the `target/quarkus-app/lib/` directory.

The application is now runnable using `java -jar target/quarkus-app/quarkus-run.jar`.

If you want to build an _über-jar_, execute the following command:
```shell script
./mvnw package -Dquarkus.package.type=uber-jar
```

The application, packaged as an _über-jar_, is now runnable using `java -jar target/*-runner.jar`.

## Creating a native executable

You can create a native executable using: 
```shell script
./mvnw package -Pnative
```

Or, if you don't have GraalVM installed, you can run the native executable build in a container using: 
```shell script
./mvnw package -Pnative -Dquarkus.native.container-build=true
```

If you would like to use Packer, try the following commands:
```shell script
packer init src/main/packer/native-micro.pkr.hcl
packer build -var-file=src/main/packer/variables.pkrvars.hcl src/main/packer/native-micro.pkr.hcl
```

You can then execute your native executable with: `./target/hashi-quarkus-1.0.0-SNAPSHOT-runner`

If you want to learn more about building native executables, please consult https://quarkus.io/guides/maven-tooling.


If you want to learn more check out:
- HashiCorp: https://developer.hashicorp.com
- Quarkus: https://quarkus.io/ .
- LangChain4J: https://docs.langchain4j.dev/
- InstructLab: https://instructlab.ai/
