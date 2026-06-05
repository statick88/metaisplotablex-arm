# Contributing to Metasploitable3 ARM64

## Gitflow Workflow

This project uses **Gitflow**. All work happens on feature branches off `develop`.

```
main          ← production-ready, tagged releases only
develop       ← integration branch
feature/*     ← new services, vulnerabilities, or features
release/*     ← release preparation (bump version, final tests)
hotfix/*      ← critical patches merged directly to main + develop
```

### Branch Naming

```
feature/add-<service-name>
feature/vuln-<cve-or-description>
fix/<short-description>
docs/<short-description>
hotfix/<short-description>
```

## Getting Started

```bash
git clone https://github.com/your-username/metasploitable3-arm.git
cd metasploitable3-arm
git checkout develop
git checkout -b feature/your-feature
```

## Making Changes

1. Branch off `develop`
2. Write tests first (TDD — see `tests/`)
3. Implement the change
4. Run tests locally: `pytest tests/ -v`
5. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
6. Open a PR targeting `develop`

## Conventional Commits

```
feat(ssh): add weak host key generation
fix(tomcat): correct manager app path
docs(readme): update Kali VM connection guide
chore(ci): add multi-arch build workflow
test(ftp): add anonymous login assertion
```

## Pull Request Checklist

- [ ] Branch targets `develop` (never `main` directly)
- [ ] Tests added or updated for the change
- [ ] `pytest tests/ -v` passes locally
- [ ] No secrets committed (check with `git diff --cached`)
- [ ] Conventional commit message format used
- [ ] `CHANGELOG.md` updated under `[Unreleased]`

## Security Contributions

For vulnerability reports in the lab infrastructure itself (not the intentional ones), see [SECURITY.md](SECURITY.md).

For adding new intentional vulnerabilities to the lab, open a `feature/vuln-*` branch and document:
- CVE reference or exploit name
- Port and service affected
- How to trigger it from Kali
- Update the service table in `README.md`
