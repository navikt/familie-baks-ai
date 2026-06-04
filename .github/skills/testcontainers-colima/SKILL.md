---
name: testcontainers-colima
description: Bruk når du kjører tester med Maven (mvn test, mvn verify, mvn package, mvn install) eller andre JVM-verktøy på macOS med Colima/Docker Desktop. Konfigurerer automatisk Testcontainers til å koble til PostgreSQL-containere via Colimas Docker-socket.
license: MIT
metadata:
  domain: testing
  tags: testcontainers colima docker maven
---

# Testcontainers Colima-konfigurasjon

På macOS med Colima/Docker Desktop trenger Testcontainers spesielle miljøvariabler for å koble til Docker-containere fra vertsmaskinen. Denne skillen konfigurerer disse automatisk.

## Problem

Uten riktig konfigurasjon feiler integrasjonstester som bruker Testcontainers med:

```
java.net.SocketException: Operation not permitted
```

eller:

```
Timed out waiting for Ryuk container to start
```

Dette skjer fordi Testcontainers ikke finner Docker-socketen eller ikke når containerne fra verten.

## Maven-faser som kjører tester

Disse Maven-fasene inkluderer testekjøring og krever miljøvariablene nedenfor:

- `mvn test` — kjører enhets- og integrasjonstester
- `mvn package` — kjører tester og bygger en JAR
- `mvn verify` — kjører tester inkludert integrasjonstester og verifiserer pakken
- `mvn install` — kjører alt det ovennevnte og installerer artefakten til lokalt Maven-repository

## Løsning

Sett disse miljøvariablene før du kjører en Maven-kommando som inkluderer tester:

```bash
export DOCKER_HOST=unix://${HOME}/.colima/default/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j | jq -r '.address')
```

Kjør deretter, for eksempel:

```bash
mvn test -Dkotlin.compiler.daemon=false
mvn package -Dkotlin.compiler.daemon=false
mvn verify -Dkotlin.compiler.daemon=false
mvn install -Dkotlin.compiler.daemon=false
```

## Permanent oppsett

Legg til disse linjene i `~/.zshrc` eller `~/.bashrc` slik at variablene settes automatisk i hver ny terminalsesjon:

```bash
# Colima/Testcontainers-konfigurasjon
export DOCKER_HOST=unix://${HOME}/.colima/default/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j | jq -r '.address' 2>/dev/null || echo "127.0.0.1")
```

## Hva hver variabel gjør

- **DOCKER_HOST**: Peker til Colimas Unix-socket i stedet for standard Docker-socket
- **TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE**: Sikrer at Ryuk-oppryddingscontaineren bruker riktig socket
- **TESTCONTAINERS_HOST_OVERRIDE**: Setter riktig IP-adresse for containerkommunikasjon (hentes fra `colima ls -j`)

## Forventet resultat

```
BUILD SUCCESS
```

## Feilsøking

Hvis `colima ls -j` feiler, brukes fallback-verdien `127.0.0.1`, men dette fungerer kanskje ikke. Sjekk at Colima kjører:

```bash
colima status
```

Hvis Colima ikke kjører, start den:

```bash
colima start
```

Start deretter terminalen på nytt eller source shell-konfigurasjonen din for å hente inn miljøvariablene.
