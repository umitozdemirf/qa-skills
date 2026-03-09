---
description: Run the `api-test-generator` QA workflow against the current task
argument-hint: [optional scope or task details]
---

Use the skill definition at @qa-skills-plugin/skills/api-test-generator/SKILL.md.

Follow its deterministic execution flow exactly.
Load only the references you need from @qa-skills-plugin/skills/api-test-generator/references/.
Treat `examples/`, `scripts/`, `test/`, and `assets/` as optional helpers when they exist.

Apply the skill to this request: $ARGUMENTS
If `$ARGUMENTS` is empty, infer the target from the current conversation and repository context.
