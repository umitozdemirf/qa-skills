# QA Skills Repository

This repository is a reusable QA skill pack. The canonical skill sources live under `qa-skills-plugin/skills/<skill-name>/SKILL.md`.

## Available skills

- `api-test-generator`: Generate API test suites using native project test frameworks.
- `service-test-generator`: Generate multi-step service scenarios from OpenAPI/Swagger specs.
- `e2e-test-generator`: Generate Playwright-based browser and API E2E tests.
- `test-plan-generator`: Generate structured, risk-prioritized test plans.
- `risk-analyzer`: Analyze change risk, blast radius, and fragile areas.
- `test-coverage-analyzer`: Identify missing coverage and untested paths.
- `test-smell-detector`: Detect flaky patterns and maintainability problems in test suites.
- `input-validation-tester`: Generate boundary-value and edge-case validation data.
- `security-test-generator`: Generate OWASP-oriented security test cases.

## Trigger rules

- If a user names a skill directly, use that skill.
- If the task clearly matches one skill's description, use that skill.
- If a task spans multiple skills, prefer the minimal sequence that covers the request.
- Do not invent new skills when an existing one already fits.

## How to use a skill

1. Open the relevant `SKILL.md`.
2. Follow its deterministic execution flow in order.
3. Load only the reference files needed for the current task.
4. Treat `examples/`, `scripts/`, `test/`, and `assets/` as optional helpers; use them when present, but do not assume every skill has populated contents.
5. Keep outputs aligned with the target project's existing language, framework, and conventions.

## Repository notes

- `qa-skills-plugin/skills/api-test-generator/assets/templates/` contains starter API test templates.
- `scripts/validate_skills.py` validates skill metadata, local file references, and cross-skill links.
- `scripts/export_agent_commands.py` exports wrapper commands for Claude Code, Gemini CLI, and OpenCode into `integrations/`.
