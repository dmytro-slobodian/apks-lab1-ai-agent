---
name: create-actions
description: Викликає skill github-actions і створює .github/workflows/ci.yml з matrix Windows, Linux, macOS, який запускає лише ci.sh / ci.bat.
agent: build-engineer
tools: ['read', 'edit', 'search', 'execute']
---

# /create-actions

Використай skill [github-actions](../skills/github-actions/SKILL.md).

## Передумови
- Існують `ci.sh` і `ci.bat` (інакше спочатку `/create-build`).

## Дії
1. Створи `.github/workflows/ci.yml` із шаблону skill за правилом CREATED / SKIP / CONFLICT.
2. Перевір YAML і структуру workflow.
3. Нічого не пуш: лише підкажи команди `git add`/`git commit`/`git push` для студента.

## Очікувані файли
- `.github/workflows/ci.yml`

## Перевірка
```bash
bash .github/agent-tools/check.sh --no-build    # розділ "5. GitHub Actions workflow" без FAIL
```

## Помилки
- Немає `ci.sh`/`ci.bat` → `ERROR create-actions: run /create-build first`.
- YAML невалідний → `ERROR create-actions: invalid YAML at line N`.
- У workflow знайдено секрет або прямий виклик `mvn` → `ERROR`, виправити за шаблоном.

Підсумок: `CREATE-ACTIONS: OK` або `CREATE-ACTIONS: ERROR <причина>`.
