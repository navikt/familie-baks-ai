# Copilot vs. OpenCode — konfigurasjon og forskjeller

Oversikt over hvordan Copilot CLI og OpenCode laster konfigurasjon, hva som skjer når du jobber i et annet repo (f.eks. `familie-ba-sak`), og de viktigste funksjonelle forskjellene.

## Konfigurasjonsprioritering

Begge verktøyene laster konfigurasjon fra flere steder, men med **motsatt prioritet** for globalt vs. prosjekt.

### Copilot — prosjekt har høyest prioritet

Instruksjoner leses i denne rekkefølgen (sist vinner):

1. `~/.copilot/copilot-instructions.md` — global (symlinket fra dette repoet)
2. `~/.copilot/instructions/**/*.instructions.md` — global (symlinket)
3. `.github/copilot-instructions.md` — prosjekt
4. `.github/instructions/**/*.instructions.md` — prosjekt

**Prosjektets `.github/`-konfigurasjon overstyrer alltid det globale.**

### OpenCode — team-config har høyest prioritet

Konfigurasjon leses i denne rekkefølgen (sist vinner):

1. `~/.config/opencode/opencode.json` — global brukerconfig
2. `opencode.json` i prosjektet — prosjektconfig
3. `.opencode/` i prosjektet — agenter, skills, kommandoer
4. `OPENCODE_CONFIG_DIR` (peker på dette repoet) — **overstyrer prosjektet**

**Team-konfigurasjonen fra dette repoet har høyere prioritet enn prosjektets `.opencode/`.**

Dette er den viktigste forskjellen: i Copilot er det prosjektet som vinner; i OpenCode er det team-configen.
Vi burde derfor tilstrebe å ha et oppsett som gir minst mulig konflikt mellom repo og team-config.

---

## Hvordan dette repoet lastes inn

### Copilot — via symlinker (`setup-copilot.sh`)

`setup-copilot.sh` symlinker filer fra dette repoet inn i `~/.copilot/`. Når du åpner Copilot i et annet repo leses deretter prosjektets `.github/` på toppen.

```mermaid
graph TD
    subgraph baksai["familie-baks-ai/"]
        BAKS_AGENT[baks.agent.md]
        BAKS_SKILL[baks.skill.md]
        BAKS_INSTR[baks.instructions.md]
        BAKS_COPILOT_INSTR[copilot-instructions.md]
    end

    subgraph copilot["~/.copilot/"]
        USER_AGENT[user.agent.md]
        USER_SKILL[user.skill]
        USER_INSTR[user.instructions.md]
        COPILOT_INSTR[copilot-instructions.md]
        BAKS_AGENT_SYM[baks.agent.md 🔗]
        BAKS_SKILL_SYM[baks.skill.md 🔗]
        BAKS_INSTR_SYM[baks.instructions.md 🔗]
    end

    subgraph basak["familie-ba-sak/"]
        subgraph repo_local["Repo (Pri 1)"]
            REPO_AGENT[repo.agent.md]
            REPO_SKILL[repo.skill.md]
            REPO_INSTR[repo.instructions.md]
            REPO_AGENTSMD[AGENTS.md]
        end
        subgraph user_loaded["Bruker (Pri 2)"]
            LOADED_USER_AGENT[user.agent.md]
            LOADED_USER_SKILL[user.skill.md]
            LOADED_USER_INSTR[user.instructions.md]
            LOADED_COPILOT_INSTR[copilot-instructions.md]
            LOADED_BAKS_AGENT[baks.agent.md]
            LOADED_BAKS_SKILL[baks.skill.md]
            LOADED_BAKS_INSTR[baks.instructions.md]
        end
    end

    BAKS_AGENT -. symlink .-> BAKS_AGENT_SYM
    BAKS_SKILL -. symlink .-> BAKS_SKILL_SYM
    BAKS_INSTR -. symlink .-> BAKS_INSTR_SYM
    BAKS_COPILOT_INSTR -. symlink .-> COPILOT_INSTR

    USER_AGENT --> LOADED_USER_AGENT
    USER_SKILL --> LOADED_USER_SKILL
    USER_INSTR --> LOADED_USER_INSTR
    COPILOT_INSTR --> LOADED_COPILOT_INSTR
    BAKS_AGENT_SYM --> LOADED_BAKS_AGENT
    BAKS_SKILL_SYM --> LOADED_BAKS_SKILL
    BAKS_INSTR_SYM --> LOADED_BAKS_INSTR
```

### OpenCode — via `OPENCODE_CONFIG_DIR`

Sett én gang i `~/.zshrc`. OpenCode laster mappen direkte — ingen symlinker, ingen setup-script.

```bash
export OPENCODE_CONFIG_DIR=/path/til/familie-baks-ai/.opencode
```

```mermaid
graph TD
    subgraph baksai["familie-baks-ai/.opencode/"]
        BAKS_AGENT[baks.agent.md]
        BAKS_SKILL[baks.skill.md]
        BAKS_INSTR[AGENTS.md]
    end

    subgraph global["~/.config/opencode/"]
        USER_AGENT[user.agent.md]
        USER_SKILL[user.skill.md]
        USER_CFG[opencode.json]
    end

    subgraph basak["familie-ba-sak/"]
        subgraph baks_loaded["Team / BAKS (Pri 1)"]
            LOADED_BAKS_AGENT[baks.agent.md]
            LOADED_BAKS_SKILL[baks.skill.md]
            LOADED_BAKS_INSTR[AGENTS.md]
        end
        subgraph repo_local["Repo (Pri 2)"]
            REPO_AGENT[repo.agent.md]
            REPO_SKILL[repo.skill.md]
            REPO_AGENTSMD[AGENTS.md]
            REPO_OC[.opencode/]
        end
        subgraph user_loaded["Bruker (Pri 3)"]
            LOADED_USER_AGENT[user.agent.md]
            LOADED_USER_SKILL[user.skill.md]
            LOADED_USER_CFG[opencode.json]
        end
    end

    BAKS_AGENT -. OPENCODE_CONFIG_DIR .-> LOADED_BAKS_AGENT
    BAKS_SKILL -. OPENCODE_CONFIG_DIR .-> LOADED_BAKS_SKILL
    BAKS_INSTR -. OPENCODE_CONFIG_DIR .-> LOADED_BAKS_INSTR

    USER_AGENT --> LOADED_USER_AGENT
    USER_SKILL --> LOADED_USER_SKILL
    USER_CFG --> LOADED_USER_CFG
```

---

## Funksjonelle forskjeller

| Funksjon                     | Copilot                                | OpenCode                         |
|------------------------------|----------------------------------------|----------------------------------|
| Instructions                 | ✅ Flere filer med `applyTo`-filtrering | ❌ Én `AGENTS.md` — alltid global |
| Skills                       | ✅                                      | ✅                                |
| Agents                       | ✅                                      | ✅                                |
| `/command`                   | ❌                                      | ✅ `.opencode/commands/`          |
| Plugins                      | ❌                                      | ✅ `.opencode/plugins/`           |
| Oppsett for delt team-config | Symlinker via `setup-copilot.sh`       | `OPENCODE_CONFIG_DIR` i `.zshrc` |
| Team-config vs. prosjekt     | Prosjekt vinner                        | Team-config vinner               |

Under er en oversikt over de mest merkbare forskjellene på syntaks på capability-type. 
Det er mange fler, men blir for mye å liste opp.

### Agents

| Felt          | Copilot                                       | OpenCode                                            |
|---------------|-----------------------------------------------|-----------------------------------------------------|
| `model`       | Leservennlig navn (`Claude Sonnet 4.5`)       | `provider/model-id` (`anthropic/claude-sonnet-4-5`) |
| `tools`       | Liste med aliaser (`read`, `edit`, `execute`) | Se `permissions`                                    |
| `permissions` | Se `tools`                                    | `allow`/`ask`/`deny` per verktøygruppe              |


### Skills

Formatet er tilnærmet identisk. En skill-fil med kun `name` og `description` fungerer i begge.

### Instructions

Copilot støtter instruksjonsfiler som aktiveres for bestemte filer via `applyTo`:

```markdown
---
applyTo: "**/*.kt"
---
Bruk alltid Kotlin-konvensjoner...
```

OpenCode har ingen tilsvarende mekanisme — `AGENTS.md` lastes alltid i sin helhet, som fjerner muligheten for granularitet.

### Commands

OpenCode støtter egendefinerte prompts som kan kjøres med `/`-prefiks i TUI. F.eks `/test`:

```markdown
---
description: Kjør tester og forklar feil
---
Kjør testene og forklar eventuelle feil i klartekst.
```

Copilot har ikke tilsvarende støtte. Den har `/prompt`, men kan kun defineres i repo, ikke globalt.
