# familie-baks-ai

Samlerepo for felles AI-konfigurasjon i Team BAKS.

## Konsept

Per nå så kan AI-config kun settes på repo-nivå eller personlig nivå. 
For å unngå unødvendig duplisering og vedlikehold putter vi all felles konfigurasjon her.
Dette blir løst med litt triksing med symlinking og scripting. 
I praksis så "putter" vi alle relevante filer i dette repo inn i  `~/.copilot/`-mappen.
Se diagram nederst for mer oversikt.

Personlige filer i `~/.copilot/` blir aldri overskrevet, med unntak av `copilot-instruction.md` (inntil videre).
Konfigurasjon på repo-nivå vil alltid ha prioritet over personlige konfigurasjon.

## Navnekonvensjon

All konfigurasjon i dette repoet skal ha prefiks `baks-`.
Prefikset gjør det tydelig hva som kommer fra teamet vs. deg selv, og er det setup.sh bruker for å rydde opp.

## Hva setup.sh gjør
1. Sletter alle eksisterende `baks-*`-filer fra `~/.copilot` i undermapper `agents`, `skills` og `instructions`. 
Dette sikrer at filer som er fjernet fra repoet ikke blir hengende igjen.
2. Oppretter symlinker fra `~/.copilot/` til filene i dette repoet.

Scriptet er idempotent.

## TODO
- Opprett alias for å synke nye endringer og rekjøre setup.
- Støtte for at bruker kan ha sin egen copilot-instructions.md sidestilt med teamets.
- Støtte for OpenCode. Sjekk nav-pilot sin konvertering.

## Diagram

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