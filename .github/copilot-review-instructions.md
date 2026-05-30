This repository contains only AI instruction files — no application code. Reviews should focus exclusively on the quality and clarity of those instructions.

## What to review

Only review files that are instructions to AI:
- `.github/copilot-instructions.md`
- `.github/instructions/**`
- `.github/agents/**`
- `.github/skills/**`

Do **not** review human-facing documentation such as `README.md`, `kjøreregler.md`, or any other Markdown file outside the paths above.

## Review criteria

Flag a comment **only** when you are confident there is a genuine clarity issue. When in doubt, do not comment.

Comment if an instruction:
- Is **ambiguous** — it can be interpreted in more than one way by an AI model
- Is **written in Norwegian** — all AI instructions must be in English so they are unambiguous across models
- **Contradicts** another instruction in the same file or a related file without explanation
- Uses **vague qualifiers** (e.g. "sometimes", "usually", "might") where a clear rule is needed

Do **not** comment on:
- Formatting, style, or whitespace
- Instructions that are clear but could theoretically be phrased differently
- Personal preferences or conventions that do not affect how an AI would interpret the instruction
