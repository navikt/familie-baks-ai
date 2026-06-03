---
name: maven-kotlin-build
description: Bruk når du kjører Maven-bygg (mvn) i dette prosjektet. Kotlin compiler daemon feiler med "cannot connect to registry: Operation not permitted" i dette miljøet. Legg alltid til -Dkotlin.compiler.daemon=false i alle mvn-kommandoer.
license: MIT
metadata:
  domain: build
  tags: maven kotlin build
---

# Maven Kotlin Build

Når du kjører en hvilken som helst `mvn`-kommando i dette prosjektet, inkluder alltid `-Dkotlin.compiler.daemon=false`.

Kotlin compiler daemon klarer ikke å starte i dette miljøet på grunn av RMI-registerrettighetsrestriksjoner (`Operation not permitted`), så kompilatoren må kjøre in-process i stedet.

## Eksempler

```
mvn clean install -Dkotlin.compiler.daemon=false
mvn clean package -Dkotlin.compiler.daemon=false
mvn test -Dkotlin.compiler.daemon=false
mvn compile -Dkotlin.compiler.daemon=false
```

Bruk dette flagget for **alle** `mvn`-kjøringer, inkludert de som bare kjører en del av livssyklusen.
