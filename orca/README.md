# orca pack

A second Claude Code plugin that lives beside EGM in this fork. EGM covers the
design phase (draft a design, review it with fresh agents). This pack covers the
build phase and the habits around it. Nothing here modifies EGM's own files.

## What is in it

| Piece | Kind | What it does |
|---|---|---|
| `orca` | skill | Lead session splits work into task specs, runs builders in separate git worktrees, gates each merge on the task's check command. Plans from an approved EGM design when one exists. |
| `orca-builder`, `orca-reasoner`, `orca-reviewer` | agents | The workers the `orca` skill launches. |
| `grilling`, `grill-with-docs`, `domain-modeling` | skills | Interview the user about a plan; keep a glossary and decision records. |
| `session-handoff` | skill | Save and restore work in flight across sessions. |
| `ship-branch` | skill | Commit, push, PR, merge and clean up, only the steps the user names. |
| `ground` | command | Check a decision against real-world sources using parallel research agents. |
| `ground-subagent` | agent | One research angle for `ground`. |

## Install

Install EGM as its own README describes. Then add this pack from a local clone:

```bash
git clone -b pack https://github.com/glitch401/elephant-goldfish-model
claude plugin marketplace add ./elephant-goldfish-model/orca
claude plugin install orca@orca-pack
```

Skills and agents are namespaced: `/orca:orca`, `/orca:ground`, `orca:orca-builder`.

## How the two plugins meet

1. `/egm:egm-draft` then `/egm:egm-review` produce an approved design under `docs/designs/`.
2. `/orca:orca` reads that design. Task file ownership comes from its target-file
   list, and acceptance checks from its verification plan. Each task spec records
   the design sections it covers.
3. For risky or large diffs, `orca-reviewer` reads the covered design sections and
   reports where the code departs from them.

Small jobs skip step 1.

## Requirements and limits

- `orca` needs a git repository. It uses the `hc` CLI when `HC_TERMINAL_ID` is set
  and Claude Code background worktree sessions otherwise.
- The pack installs a Stop hook. It does nothing unless the working directory
  holds an `.orca-check` file, which only orca worker worktrees have.
- `session-handoff` and `ship-branch` record corrections in a `learned.md` file in
  their own skill folder. A plugin update replaces that folder, so those notes do
  not survive an update.

## Licences

The pack is Apache-2.0, like the rest of this repository. Three skills are derived
from MIT-licensed work; see [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md).
