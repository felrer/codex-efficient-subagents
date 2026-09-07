## Evidence and Tool Output (All Agents)

- Identify the question and owning paths or symbols before reading. If ownership is unknown, locate it first, then read the smallest complete relevant sections and direct dependencies. Complete mandatory instruction reads.
- Parallelize independent operations when useful. Keep output focused on decision-relevant evidence; do not return whole files, broad diffs, or raw logs when precise references suffice. If output is truncated, retrieve the missing evidence with narrower reads.
- Reuse sufficient prior evidence. Revisit it when inputs change, coverage is insufficient, conflicting evidence appears, or integration creates a new risk.
- Retain verbose logs in task-specific files when needed. Report validation scope, outcome, actual exit code when available, and relevant log paths. On failure, include the first causal error and enough context to diagnose it. Do not hide uncertainty to meet a length target.

## Delegation and Integration (Parent Only)

These rules authorize the parent to delegate suitable independent work. They do not authorize children to delegate.

- Delegate bounded, independent work when parallel progress or isolation materially helps. Handle single lookups and small edits directly when delegation would cost more than completion. A concurrency limit is a ceiling, not a quota.
- Use `luna_explorer` for read-only evidence retrieval within named boundaries, and `sol_executor` for settled implementation and validation. Keep requirements, architecture, shared interfaces, authority, and final acceptance with the parent.
- Resolve shared contracts and exclusive write ownership before dispatch. Do not parallelize tasks that depend on an unresolved decision. Tell workers they share the workspace and must preserve existing and concurrent work.
- Use this handoff contract: Objective (one outcome), Scope (read boundary and owned files), Constraints (agreed behavior, interfaces and authority limits), References (exact paths or symbols), Done when (observable completion criteria), Return format (the selected role's fields). Pass decisions and references rather than full conversations or copied documents.
- For a materially different independent objective, use a fresh child with the minimum necessary history when the tool supports it. Reuse the same child for corrections and validation of its objective; send only the delta. Do not split coupled unfinished work merely to refresh context.
- Dispatch already-decided independent tasks together. Send dependent instructions only after the required result arrives.
- Avoid routine polling and acknowledgement-only exchanges. Batch nonurgent updates. Report blockers, ownership conflicts, or contract changes affecting other work immediately.
- Reuse adequate child evidence without repeating its investigation. Review the combined result and run additional checks only for uncovered requirements or distinct integration risks.
- Maintain a compact current-state record when it helps continuation: decisions, ownership, completed evidence, next action, and unresolved items. Do not accumulate conversation diaries or duplicate logs.
