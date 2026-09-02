# Project-Specific Rules

<!-- Repo-specific agent instructions. The rollout script never touches this file. -->

<!-- ── Migrated from CLAUDE.md ── -->

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 6. Testing Policy & Test-Driven Development (TDD)
- **Unit & Widget Tests**: Coverage thresholds are enforced and mandatory for all new logic and components.
- **Ratcheting**: Thresholds must never be lowered; they should only go up as coverage improves.
- **TDD Workflow**: Always follow the Red-Green-Refactor cycle:
  1. **Red**: Write a unit or widget test defining the expected behavior or reproducing a bug *before* modifying code. Verify that the test fails as expected.
  2. **Green**: Write the minimal production code necessary to make the test pass.
  3. **Refactor**: Clean up implementation code while ensuring all tests stay green.
- **New Code**: All new features and bug fixes must ship with matching unit and widget tests.
---
