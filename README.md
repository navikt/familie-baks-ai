# familie-baks-ai

Samlerepo for felles AI-konfigurasjon i Team BAKS.

## Konsept

Per nå så kan AI-config kun settes på repo-nivå eller personlig nivå. 
For å unngå unødvendig duplisering og vedlikehold putter vi all felles konfigurasjon her.
Med litt triksing tar vi det som ligger i dette repo og setter det personlig nivå.

Repoet støtter to verktøy: **Copilot CLI** og **OpenCode**. Se [copilot-vs-opencode.md](./copilot-vs-opencode.md) for detaljer.

Tanken bak er at vi har domene-spesifikk informasjon per repo med: `AGENTS.md`. 
Capabilities (agents/skills/instructions/commands) har vi i dette repo. Her må vi bare teste oss frem litt om hva som funker.

## Kom i gang

### Copilot CLI

```bash
./setup-copilot.sh
```

#### Hva setup-copilot.sh gjør

1. Sletter alle eksisterende `baks-*`-filer fra `~/.copilot` i undermappene `agents`, `skills` og `instructions`.
   Dette sikrer at filer som er fjernet fra repoet ikke blir hengende igjen.
2. Oppretter symlinker fra `~/.copilot/` til filene i dette repoet.

Kjør `setup-copilot.sh` én gang etter kloning, og etter at nye filer er lagt til i repoet:

Scriptet er idempotent.

### OpenCode

```bash
./setup-opencode.sh
```

#### Hva setup-opencode.sh gjør

Sjekker at `OPENCODE_CONFIG_DIR` er satt og peker på `.opencode/`-mappen i dette repoet.
Scriptet viser hva du må legge til i `~/.zshrc` hvis det mangler.

`OPENCODE_CONFIG_DIR` forteller OpenCode at den skal laste `AGENTS.md`, skills, agenter og kommandoer derfra.

Ingen re-kjøring nødvendig etter miljøvariabelen er satt — `git pull` er nok for å få nye endringer.

Scriptet er idempotent.

## Holde seg oppdatert

Anbefaler å legge til følgende alias i `~/.zshrc` og kjøre jevnlig eller ved endringer i dette repo.

```bash
alias baks-ai-sync="git -C /path/til/familie-baks-ai pull && /path/til/familie-baks-ai/setup-copilot.sh"
```

Bytt ut `/path/til/familie-baks-ai` med faktisk sti til der du har klonet repoet.

## Navnekonvensjon

All konfigurasjon i dette repoet skal ha prefiks `baks-`.
Prefikset gjør det tydelig hva som kommer fra teamet vs. deg selv, og er det `setup-copilot.sh` bruker for å rydde opp.

## TODO
- Støtte for at bruker kan ha sin egen `copilot-instructions.md` sidestilt med teamets.
- Oppsett MCP
- Nav-pilot
