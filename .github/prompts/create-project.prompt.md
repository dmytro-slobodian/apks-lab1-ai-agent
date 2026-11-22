---
name: create-project
description: Викликає skill project-scaffold і створює початковий Java Hello World проєкт (App.java, секція README, .gitignore).
agent: build-engineer
tools: ['read', 'edit', 'search', 'execute']
---

# /create-project

Використай skill [project-scaffold](../skills/project-scaffold/SKILL.md) з параметрами
`language=java`, `project_name=hello`, `package=ua.lpnu.ki405.hello`.

## Передумови
- `/git-init` виконано (є `.gitignore` з `build/`).
- Поточна гілка не `master`.

## Дії
1. Прочитай SKILL.md і шаблони в `.github/skills/project-scaffold/templates/`.
2. Створи файли з розділу «Виходи» skill за правилом CREATED / SKIP / CONFLICT.
3. Не створюй `pom.xml`, тести і workflow — це інші команди.

## Очікувані файли
- `src/main/java/ua/lpnu/ki405/hello/App.java`
- каталог `src/test/java/ua/lpnu/ki405/hello/`
- `README.md` з одним маркером `<!-- agent:project-section -->`
- `.gitignore`, `.gitattributes` (без дублікатів)

## Перевірка
Виконай команди з розділу «Перевірка» skill project-scaffold і виведи результат кожної.

## Помилки
- Немає `.gitignore` → `ERROR create-project: run /git-init first`.
- `CONFLICT` на будь-якому файлі → зупинитись, показати diff, чекати рішення студента.

Підсумок: `CREATE-PROJECT: OK` або `CREATE-PROJECT: ERROR <причина>`.
