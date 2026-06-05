## Description

<!-- What does this PR do? 1-3 bullet points -->

- 

## Linked Issue

Closes #

## Type of Change

- [ ] New vulnerable service
- [ ] Bug fix (unintended breakage)
- [ ] Documentation
- [ ] CI/CD improvement
- [ ] Refactor / chore

## Test Plan

- [ ] `pytest tests/ -v` passes
- [ ] Container starts without errors: `docker compose up -d`
- [ ] New service reachable from host: `nc -z localhost <port>`
- [ ] CHANGELOG.md updated under `[Unreleased]`

## Security Checklist

- [ ] No real credentials or secrets committed
- [ ] New intentional vulnerability documented in README service table
- [ ] Ethical use warning preserved
