# Архітектура AI-агента build-engineer

## 1. Яку проблему вирішує агент
Створення навіть простого кросплатформного проєкту — це багато дрібних кроків, у яких легко помилитися:
структура каталогів, `.gitignore`, система складання, тести, скрипти для різних ОС, CI-workflow і їх
перевірка. Агент робить ці кроки **завжди однаково і в правильному порядку**, не перезаписує вже
створене і не оголошує успіх, доки перевірки не пройшли.

Конкретно для варіанта 5 агент створює:
- застосунок Java 17 `hello`, який друкує `Hello, World!`;
- складання Maven у каталог `build/` з виконуваним `build/hello.jar`;
- юніт-тести JUnit 5, серед них обов'язковий `BasicAddition`;
- скрипти `ci.sh` (Linux/macOS) і `ci.bat` (Windows);
- GitHub Actions `ci.yml` з matrix `ubuntu-latest`, `windows-latest`, `macos-latest`.

## 2. Компоненти

```
                 ┌──────────────────────────────────────────┐
  студент ──/init──▶  build-engineer.agent.md  (manifest)   │
                 │  роль, межі, заборони, критерії успіху    │
                 └───────────────┬──────────────────────────┘
                                 │ виконує
                 ┌───────────────▼──────────────────────────┐
                 │  init.prompt.md  (orchestrator)           │
                 └─┬─────────┬──────────┬──────────┬───────┬─┘
                   1         2          3          4       5
             /git-init /create-project /create-build /create-actions /check
                   │         │          │          │       │
                   │   ┌─────▼────┐ ┌───▼──────┐ ┌─▼─────┐ │
                   │   │ project- │ │ build-   │ │github-│ │
                   │   │ scaffold │ │ and-test │ │actions│ │
                   │   │  skill   │ │  skill   │ │ skill │ │
                   │   └─────┬────┘ └───┬──────┘ └─┬─────┘ │
                   ▼         ▼          ▼          ▼       ▼
             .gitignore   App.java    pom.xml     ci.yml   agent-tools/check.sh
             .gitattributes README    tests, ci.sh/.bat     (лише читає)
```

| Компонент | Файл | Роль |
|---|---|---|
| Agent manifest | `.github/agents/build-engineer.agent.md` | роль, параметри варіанта, дозволені файли, заборонені дії, обробка помилок, критерії завершення |
| Skill project-scaffold | `.github/skills/project-scaffold/SKILL.md` + `templates/` | структура, `App.java`, README-секція, `.gitignore`, `.gitattributes` |
| Skill build-and-test | `.github/skills/build-and-test/SKILL.md` + `templates/` | `pom.xml`, `Calculator`, тести, `ci.sh`, `ci.bat` |
| Skill github-actions | `.github/skills/github-actions/SKILL.md` + `templates/` | `.github/workflows/ci.yml` |
| Command git-init | `.github/prompts/git-init.prompt.md` | перевірка репозиторію, `.gitignore`, `git status` |
| Command create-project | `.github/prompts/create-project.prompt.md` | викликає project-scaffold |
| Command create-build | `.github/prompts/create-build.prompt.md` | викликає build-and-test і запускає складання |
| Command create-actions | `.github/prompts/create-actions.prompt.md` | викликає github-actions |
| Command check | `.github/prompts/check.prompt.md` | запускає `check.sh`, нічого не змінює (без інструмента `edit`) |
| Orchestrator init | `.github/prompts/init.prompt.md` | кроки 1–5 по черзі, зупинка на помилці, фінальний звіт |
| Verifier | `.github/agent-tools/check.sh` | 7 груп детермінованих перевірок, код виходу 0/1 |

## 3. Відповідність формату GitHub Copilot у VS Code
Методичка пропонує структуру `.github/agents`, `.github/prompts`, `.github/skills`. Copilot у VS Code
підтримує саме ці каталоги, тому назви збережено:

| Роль у методичці | Формат Copilot | Як викликається |
|---|---|---|
| agent manifest | custom agent `*.agent.md` у `.github/agents/` (frontmatter `name`, `description`, `tools`) | вибір агента `build-engineer` у списку агентів Copilot Chat |
| command | prompt file `*.prompt.md` у `.github/prompts/` (frontmatter `agent: build-engineer`, `tools`) | `/назва` у чаті, наприклад `/init` |
| skill | Agent Skill: каталог з `SKILL.md` (frontmatter `name`, `description`) у `.github/skills/` | агент підвантажує skill, на який посилається command |
| orchestrator | prompt file `init.prompt.md` | `/init` |

Відмінності від рекомендованої структури:
- Замість `CMakeLists.txt` (варіант 1) — `pom.xml`, бо варіант 5 використовує Maven.
- Каталог складання Maven перенесено з `target/` у `build/` (`<directory>` у `pom.xml`), щоб виконати вимогу
  «каталог build/ не потрапляє під Git».
- Додано `.github/agent-tools/check.sh` — детермінований скрипт для `/check`, щоб результат перевірки не
  залежав від того, як модель «прочитає» файли.
- Додано `templates/` у кожному skill — точні шаблони файлів. Завдяки цьому повторний запуск агента дає
  той самий результат, що й у гілці `feature/...`.

## 4. Дані між етапами
| Етап | Отримує | Передає далі |
|---|---|---|
| 1 git-init | робочу копію Git | `.gitignore` з `build/`, `.gitattributes`, назву гілки |
| 2 create-project | `.gitignore`, параметри з manifest (`java`, `hello`, `ua.lpnu.ki405.hello`) | `App.java`, каталог тестів, README |
| 3 create-build | `App.java`, пакет | `pom.xml`, тести, `ci.sh`, `ci.bat`, `build/hello.jar`, звіти surefire |
| 4 create-actions | `ci.sh`, `ci.bat` | `.github/workflows/ci.yml` |
| 5 check | усі файли | `RESULT: PASS/FAIL`, `build/check.log` |

Кожен крок закінчується рядком статусу (`GIT-INIT: OK`, `CREATE-BUILD: ERROR ...` тощо). Оркестратор
читає цей рядок і вирішує, чи переходити далі.

## 5. Обробка помилок оркестратором
1. Передумови `/init`: гілка `feature/...`, є `git`, JDK 17+, Maven 3.9+. Якщо ні — зупинка до будь-яких змін.
2. Після кожного кроку: статус `OK`/`SKIP` → далі; `ERROR`/`CONFLICT` → `INIT: STOPPED at step N`, причина,
   останні рядки логу, жодних наступних кроків.
3. `RESULT: SUCCESS` можливий лише після `/check` з `RESULT: PASS`.
4. Заборонено «лікувати» помилку послабленням перевірок: `-DskipTests`, `@Disabled`, видалення тесту,
   `continue-on-error`, прибирання ОС з matrix.
5. Ідемпотентність: файл, що вже збігається з шаблоном, → `SKIP`; файл, що відрізняється, → `CONFLICT`
   без перезапису; `.gitignore`/`.gitattributes` доповнюються без дублікатів; секція README має маркер.

## 6. Безпека
- Агент не комітить і не пушить сам, лише пропонує команди.
- Заборонені: видалення файлів поза `build/`, `git push --force`, `git reset --hard`, `git clean`,
  зміна захисту гілок і секретів.
- Workflow має `permissions: contents: read` і не використовує секретів.
- `check.sh` шукає в індексі Git токени GitHub/AWS і приватні ключі, а також build-файли.

## 7. Обмеження
- Агент розрахований лише на варіант 5 (Java/Maven/JUnit). Для іншої мови потрібні нові шаблони.
- Результат роботи моделі не детермінований, тому точність забезпечують шаблони і `check.sh`,
  а не лише текст інструкцій.
- Prompt files працюють у локальних сесіях Copilot Chat у VS Code; в інших клієнтах команди треба
  передати як звичайний текст запиту.
- Для складання потрібен доступ до Maven Central.
