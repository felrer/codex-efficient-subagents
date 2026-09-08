---
name: project-bootstrap
description: "Create or align project documentation entry points, configurable work locations with scripted brief/plan creation, and selective project playbook routing. Use when explicitly bootstrapping or normalizing a project; reuse common playbooks with project-specific adaptations when in scope. Do not generate application scaffolding, detailed designs, or task plans."
---

# Project Bootstrap

Create or align the minimum documentation structure that helps users review work and agents find applicable project guidance. Infer project facts from evidence; do not assume a stack or workflow.

Use [the copy-ready template](assets/project-template/) as the canonical tree:
- `AGENTS.md` and `docs/README.md`.
- `docs/architecture/README.md`, `docs/maps/README.md`, and `docs/ops/README.md`.
- `docs/playbooks/README.md` and `docs/work/README.md`.

## Copy Or Align

Inspect existing project instructions, all seven target paths, and their parent paths before writing. If no target exists and all parents are absent or directories, copy the template tree preserving relative paths. Otherwise preserve existing content and add only missing files or routing information. Do not bulk-overwrite, move existing documents, or replace conflicting structures without the required scope decision.

Use English for templates and new routing guidance; preserve existing prose and tone. Reuse existing category owners through links. Preserve architecture organization by independently evolving target and architectural concern, and its exclusion of implementation plans. Use `maps` and `ops` in new structures.

Routers must have meaningful purposes and link only existing documents. Keep commands, runtime state, and detailed contracts in their owners. Do not fabricate content to fill categories.

## Work Documents

For new projects, configure exactly one `Work directory: docs/work` bullet under `## Work Artifacts` in `docs/README.md`. This setting is the location authority: relative paths are project-root-relative, and absolute external paths are allowed. Markdown links are navigation and are resolved relative to their containing document.

Create the work README during bootstrap but no tasks or example categories. It owns category meanings and usage rules, not a task/document index. Each classified folder such as `AA-08-title/` represents one work session for a specific target and contains numbered briefs; categories can advance independently to `AB-01`.

Use [the work utility](../planning/scripts/work_artifacts.py) for deterministic creation, reuse, resolution, and configured location changes. Read [its compact usage contract](../planning/references/task-artifacts.md) only when invoking it. Do not reproduce allocation logic in the skill or manually calculate paths.

When a new project requests a different work location, place the work README there and configure that location, updating navigation links accordingly. The default template can be staged before configuration; leave no competing unused default work README. For an existing project, the utility's configure operation changes the setting and work-README navigation links only; it does not move task history. Preserve existing destinations and legacy conventions unless changing them is authorized. Clarify whether moving existing files is in scope separately from changing where new work goes.

## Project Playbooks

The playbook router gives short applicability descriptions so agents select only matching guidance by work type. Read linked ops sections only when the chosen work needs them; do not preload every playbook or its references. Root instructions should route to it, not inline every playbook. Applicable guidance covers how work is performed, verified, and finished; exact supported commands remain in `ops/` or established owners and are linked.

Bootstrap creates the router, not fabricated detailed playbooks. Import playbooks only when the user supplies or selects a source and includes importing in scope. Select only relevant sources, copy them into the project, and adapt them to verified project constraints and operational links. Record source, source revision or date, and meaningful local adaptations. Project copies are locally maintained; do not automatically overwrite them from common sources or write project-specific changes back upstream.

Improve common sources only within an authorized editing task, extracting reusable lessons without carrying project-specific assumptions. If a source is unavailable, report that limitation and complete independent bootstrap work.

## Verification And Completion

Check that all seven entry points exist or route through agreed existing equivalents, links resolve, configured destinations agree, and empty-registration notices match reality. Verify that numbered-brief session rules are consistent and that playbooks route to operational owners without duplicating commands.

Do not create application code, runtime configuration, detailed architecture, code maps, operational procedures, task artifacts, or placeholder files just to complete bootstrap. Use applicable existing documentation checks; do not add a validator solely for bootstrap.

Report changed entry points, preserved conventions, any imported playbooks and adaptations, validation results, and unresolved decisions.
