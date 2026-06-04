---
name: testcontainers-colima
description: Use when running tests with Maven (mvn test, mvn verify, mvn package, mvn install) or other JVM tools on macOS with Colima/Docker Desktop. Automatically configures Testcontainers to connect to PostgreSQL containers through Colima's Docker socket.
---

# Testcontainers Colima Configuration

On macOS with Colima/Docker Desktop, Testcontainers needs special environment variables to connect to Docker containers from the host machine. This skill configures those automatically.

## Problem

Without proper configuration, integration tests using Testcontainers fail with:
```
java.net.SocketException: Operation not permitted
```

or:
```
Timed out waiting for Ryuk container to start
```

This happens because Testcontainers can't find the Docker socket or reach containers from the host.

## Maven Phases That Run Tests

These Maven phases all include test execution and require the environment variables below:

- `mvn test` - runs unit and integration tests
- `mvn package` - runs tests and builds a JAR
- `mvn verify` - runs tests including integration tests and verifies the package
- `mvn install` - runs all of the above and installs the artifact to the local Maven repository

## Solution

Set these environment variables before running any Maven command that includes tests:

```bash
export DOCKER_HOST=unix://${HOME}/.colima/default/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j | jq -r '.address')
```

Then run, for example:

```bash
mvn test -Dkotlin.compiler.daemon=false
mvn package -Dkotlin.compiler.daemon=false
mvn verify -Dkotlin.compiler.daemon=false
mvn install -Dkotlin.compiler.daemon=false
```

## Permanent Setup

Add these lines to `~/.zshrc` or `~/.bashrc` so the variables are set automatically in every new terminal session:

```bash
# Colima/Testcontainers configuration
export DOCKER_HOST=unix://${HOME}/.colima/default/docker.sock
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_HOST_OVERRIDE=$(colima ls -j | jq -r '.address' 2>/dev/null || echo "127.0.0.1")
```

## What Each Variable Does

- **DOCKER_HOST**: Points to Colima's Unix socket instead of the default Docker socket
- **TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE**: Ensures the Ryuk cleanup container uses the correct socket
- **TESTCONTAINERS_HOST_OVERRIDE**: Sets the correct IP address for container communication (retrieved from `colima ls -j`)

## Expected Output

```
BUILD SUCCESS
```

## Troubleshooting

If `colima ls -j` fails, the fallback value `127.0.0.1` is used, but this may not work. Check that Colima is running:

```bash
colima status
```

If Colima is not running, start it:

```bash
colima start
```

Then restart your terminal or source your shell config to pick up the environment variables.
