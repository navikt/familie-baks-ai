# cplt

Sandbox som hindrer AI-agenter i å gjøre skade ([navikt/cplt](https://github.com/navikt/cplt)).

## Hvorfor

AI-agenter kjører kode på maskinen din. Hvis noe går galt kan de lese hemmeligheter, pushe til main eller sende koden din ut av huset. cplt stopper dette på OS-nivå — uten Docker eller VM.

## Kom i gang

```bash
brew install navikt/tap/cplt
cplt doctor               # sjekk at alt er i orden
```

## Starte cplt

Github Copilot CLI:
```bash
cplt
```

OpenCode:
```bash
cplt --agent opencode
```

## Environment-variabler

For å gi eksplisitt tilgang til en environment-variabel, for eksempel `GITHUB_TOKEN`:
```bash
cplt --pass-env GITHUB_TOKEN
```

## Oppsett av team-konfigurasjon

Kjør `cplt init` i prosjektmappen for å la cplt oppdage hvilken teknologi du bruker (f.eks. Java, Docker) og foreslå relevante tillatelser.

For å generere en policy og skrive den til disk:
```bash
cplt init --write
```

Eksempel på generert konfig for et Maven/Kotlin/Docker-prosjekt der du vil tillate tester med Maven og Docker/Testcontainers:

```toml

[propose]
allow_docker = true
allow_jvm_attach = true
allow_localhost_any = true

[propose.allow]
ports = [5432, 8000]
```

Du kan legge til en team-policy i repoet. Den gjelder da for alle som jobber der. For å godkjenne policyen (filen må være sjekket inn i repoet):
```
cplt trust accept --all
```

Alternativt kan du starte cplt med ønskede tillatelser. For å tillate Docker:
```
cplt --allow-docker
```

### Prosjekt med Maven

Maven-prosjekter trenger:
- `allow_jvm_attach`
- `allow_docker` hvis du bruker Testcontainers
- `allow_localhost_any` for å koble til testdatabaser som kjører i Docker

## Personlig konfigurasjon

Hvis du trenger å gi cplt tilgang til filer eller mapper på maskinen din, for eksempel `~/.m2` eller Maven hvis den ikke oppdages automatisk, bruker du den personlige konfigfilen:

```bash
cplt init --global # generer ~/.config/cplt/config.toml
```

Eksempel for Java/Maven-prosjekter:
```toml
[allow]
 read = [
     "~/.m2",
     "~/.m2/settings.xml",
     "~/.docker/config.json",
     "~/.opencode",
     "~/.github"
 ]
```

## Anbefalte globale innstillinger

Se også: https://ki-utvikling.nav.no/nyheter/cplt-gh-guard-git-guard

For å unngå at du pusher eller commiter kode generert av en AI-agent:

```bash
cplt config set gh_guard.enabled true 
cplt config set git_guard.enabled true
```

Hvis du vil tillate commit til feature branches:
```bash
cplt config set git_guard.protect_default_branch_only true
```


## Erfaringern og tips
- Kjør mvn compile utenfor cplt for å få alle avhengigheter lastet ned og cachet i `~/.m2`. Da vil cplt kunne kjøre mvn test uten å trenge tilgang til `~/.m2`-mappen.

- Kjøring av tester med Maven kan fungere dårlig hvis kotlin kompileres gjennom daemon. For å fikse dette er det en skill som skrur av kompilering med daemon for alle mvn-kommandoer. Se maven-kotlin-build

- Testcontainers med colima kan være trøblete. Det er lagd en skill for å hjelpe med dette. Se docker-testcontainers-colima.
