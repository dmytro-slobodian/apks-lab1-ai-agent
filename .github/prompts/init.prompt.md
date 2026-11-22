---
name: init
description: Оркестратор. Послідовно запускає /git-init, /create-project, /create-build, /create-actions і /check, зупиняється на першій помилці і завершується звітом.
agent: build-engineer
tools: ['read', 'edit', 'search', 'execute', 'todo']
---

# /init — оркестратор

Виконай повний сценарій створення проєкту. Кожен крок — це окрема command; виконуй її інструкції
повністю, як ніби студент запустив її сам. Веди список кроків через інструмент todo.

## Передумови
1. Корінь Git-репозиторію відкрито у VS Code, Copilot працює в режимі агента `build-engineer`.
2. Поточна гілка — `feature/...` (не `master` і не `develop`). Якщо ні — зупинись і запропонуй
   `git switch -c feature/lab1-java-agent`.
3. `java -version` ≥ 17, `mvn -v` ≥ 3.9, `git --version` — інакше `ERROR init: toolchain`.

## Дії
| Крок | Command | Вхід від попереднього кроку | Умова переходу далі |
|---|---|---|---|
| 1 | [/git-init](git-init.prompt.md) | — | `GIT-INIT: OK`, `build/` ігнорується |
| 2 | [/create-project](create-project.prompt.md) | `.gitignore` | `CREATE-PROJECT: OK`, є `App.java` |
| 3 | [/create-build](create-build.prompt.md) | `App.java` | `CREATE-BUILD: OK`, `CI RESULT: PASS` |
| 4 | [/create-actions](create-actions.prompt.md) | `ci.sh`, `ci.bat` | `CREATE-ACTIONS: OK`, YAML валідний |
| 5 | [/check](check.prompt.md) | усі файли | `RESULT: PASS` |

Правила оркестрації:
- Кроки виконуються **строго по черзі**. Наступний починається лише після успіху попереднього.
- При `ERROR` або `CONFLICT` зупинись, виведи `INIT: STOPPED at step N (<command>)`, причину і останні рядки логу.
  Не переходь до наступних кроків і не вважай роботу виконаною.
- Повторний запуск `/init` безпечний: кроки, де все вже створено, дають `SKIP`, файли не перезаписуються,
  рядки і секції не дублюються.
- Не виконуй `git commit` і `git push` — у кінці лише запропонуй команди комітів.

## Очікувані файли
Після успішного `/init`:
```
.gitignore  .gitattributes  README.md  pom.xml  ci.sh  ci.bat
src/main/java/ua/lpnu/ki405/hello/{App,Calculator}.java
src/test/java/ua/lpnu/ki405/hello/{CalculatorTest,AppTest}.java
.github/workflows/ci.yml
```

## Перевірка
Фінальний звіт у форматі:
```
INIT REPORT
  1 git-init        OK
  2 create-project  OK | SKIP
  3 create-build    OK   (Tests run: 5, Failures: 0)
  4 create-actions  OK | SKIP
  5 check           PASS (N passed, 0 failed)
RESULT: SUCCESS
```
`RESULT: SUCCESS` дозволено лише якщо крок 5 дав `RESULT: PASS`.

## Помилки
- Будь-який крок з `ERROR` → `RESULT: FAILED`, номер кроку і причина.
- `/check` дав `RESULT: FAIL` → `RESULT: FAILED`, список `[FAIL]` і яка command його виправляє.

Наприкінці запропонуй студенту команди комітів (окремо: проєкт, складання і тести, CI):
```bash
git add .gitignore .gitattributes README.md src/main
git commit -m "feat: scaffold Java Hello World (project-scaffold)"
git add pom.xml ci.sh ci.bat src/test
git commit -m "build: Maven + JUnit 5 tests and ci scripts (build-and-test)"
git add .github/workflows/ci.yml
git commit -m "ci: GitHub Actions matrix for Windows, Linux, macOS (github-actions)"
```
