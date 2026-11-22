---
name: git-init
description: Перевіряє Git-репозиторій, створює або доповнює .gitignore і .gitattributes, показує стан Git. Нічого не комітить і не пушить.
agent: build-engineer
tools: ['read', 'edit', 'search', 'execute']
---

# /git-init

## Передумови
- Встановлено `git` (`git --version`).
- Чат відкрито в корені робочої копії репозиторію.

## Дії
1. Виконай `git rev-parse --is-inside-work-tree`.
   - Якщо це не репозиторій — **не** запускай `git init` сам. Запитай студента; лише після згоди виконай `git init -b master`.
2. Виведи поточну гілку `git branch --show-current` і віддалені репозиторії `git remote -v`.
   Якщо поточна гілка `master` — попередь, що генерацію треба робити в `feature/...`, і запропонуй команду
   `git switch -c feature/lab1-java-agent` (виконай лише після згоди).
3. Створи або доповни `.gitignore` рядками з
   [gitignore.template](../skills/project-scaffold/templates/gitignore.template),
   а `.gitattributes` — рядками з [gitattributes.template](../skills/project-scaffold/templates/gitattributes.template).
   Додавай лише відсутні рядки, нічого не видаляй і не переставляй.
4. Перевір, що в індексі немає вже закомічених build-файлів:
   `git ls-files | grep -E '(^|/)(build|target)/|\.class$|\.jar$'`. Якщо є — лише повідомити і запропонувати
   `git rm -r --cached <шлях>` (без видалення з диска), не виконувати самостійно.
5. Виведи `git status --short --branch`.

## Очікувані файли
- `.gitignore` (містить `build/`, `target/`, `*.jar`, `.env`)
- `.gitattributes` (містить `*.sh text eol=lf`, `*.bat text eol=crlf`)

## Перевірка
```bash
git check-ignore -q build/ && echo "build/ ignored"
grep -c -x 'build/' .gitignore        # 1, а не 2 після повторного запуску
git status --short --branch
```

## Помилки
- `ERROR git-init: not a git repository` — запитати дозвіл на `git init -b master`.
- `ERROR git-init: git not found` — порадити встановити Git і перезапустити VS Code.
- Знайдено закомічені build-файли — `WARN`, команда для `git rm --cached`, рішення за студентом.

Підсумок виводь у форматі: `GIT-INIT: OK` або `GIT-INIT: ERROR <причина>`.
