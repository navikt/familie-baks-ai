---
name: maven-kotlin-build
description: 'Use when running Maven builds (mvn) in this project. The Kotlin compiler daemon fails with "cannot connect to registry: Operation not permitted" in this environment. Always add -Dkotlin.compiler.daemon=false to all mvn commands.'
---

# Maven Kotlin Build

When running any `mvn` command in this project, always include `-Dkotlin.compiler.daemon=false`.

The Kotlin compiler daemon fails to start in this environment due to RMI registry permission restrictions (`Operation not permitted`), so the compiler must run in-process instead.

## Examples

```
mvn clean install -Dkotlin.compiler.daemon=false
mvn clean package -Dkotlin.compiler.daemon=false
mvn test -Dkotlin.compiler.daemon=false
mvn compile -Dkotlin.compiler.daemon=false
```

Apply this flag to **all** `mvn` invocations, including those that only run a subset of the lifecycle.
