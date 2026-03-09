---
description: Run the `test-plan-generator` QA workflow against the current task
argument-hint: [optional scope or task details]
---

Use the skill definition at @qa-skills-plugin/skills/test-plan-generator/SKILL.md.

Follow its deterministic execution flow exactly.
Load only the references you need from @qa-skills-plugin/skills/test-plan-generator/references/.
Treat `examples/`, `scripts/`, `test/`, and `assets/` as optional helpers when they exist.

Apply the skill to this request: $ARGUMENTS
If `$ARGUMENTS` is empty, infer the target from the current conversation and repository context.
