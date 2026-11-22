# apks-lab1-ai-agent

Лабораторна робота №1 з дисципліни «Автоматизоване проектування комп'ютерних систем».
**Тема:** проєктування AI-агента для автоматизації розробки та CI/CD.

| | |
|---|---|
| Студент | Слободян Дмитро Ігорович |
| Група | КІ-405 |
| Варіант | 5 (№ 23 у списку групи) — Java, Maven, JUnit 5 |
| AI-інструмент | GitHub Copilot (VS Code, custom agent + prompt files + agent skills) |

## Що робить агент
Агент `build-engineer` за однією командою `/init` створює кросплатформний Java-застосунок Hello World,
систему складання Maven, юніт-тести JUnit 5 (зокрема `BasicAddition`), скрипти `ci.sh` / `ci.bat`
і GitHub Actions workflow для Windows, Linux і macOS, а потім перевіряє результат командою `/check`.

| Файли агента | Призначення |
|---|---|
| `.github/agents/build-engineer.agent.md` | manifest: роль, правила, заборони, критерії завершення |
| `.github/skills/*/SKILL.md` | 3 skills: project-scaffold, build-and-test, github-actions (+ шаблони) |
| `.github/prompts/*.prompt.md` | 6 commands: git-init, create-project, create-build, create-actions, check, init |
| `.github/agent-tools/check.sh` | скрипт перевірки для `/check` (лише читає) |
| `docs/architecture.md`, `docs/usage.md`, `docs/ai-log.md` | архітектура, інструкція, журнал роботи з AI |

## Запуск агента (коротко)
1. VS Code + розширення GitHub Copilot (студентський план), JDK 17+, Maven 3.9+, Git.
2. `git switch develop && git switch -c feature/lab1-java-agent`
3. Copilot Chat → обрати агента **build-engineer** → ввести `/init`.
4. Дочекатися `RESULT: SUCCESS`, переглянути зміни, закомітити.

Детально: [docs/usage.md](docs/usage.md). Архітектура: [docs/architecture.md](docs/architecture.md).

<!-- agent:project-section -->
## Проєкт Hello World (згенерований агентом)

| Параметр | Значення |
|---|---|
| Мова | Java 17 |
| Складання | Maven 3.9+ (`pom.xml`, вихідний каталог `build/`) |
| Тести | JUnit 5, обов'язковий тест `BasicAddition` |
| CI | GitHub Actions: ubuntu-latest, windows-latest, macos-latest |

### Структура
```
src/main/java/ua/lpnu/ki405/hello/App.java          # main(): друкує "Hello, World!"
src/main/java/ua/lpnu/ki405/hello/Calculator.java   # тестова функція add()
src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java  # BasicAddition, NegativeAddition, OverflowThrows
src/test/java/ua/lpnu/ki405/hello/AppTest.java      # GreetingText, MainPrintsGreeting
pom.xml   ci.sh   ci.bat   .github/workflows/ci.yml
```

### Складання і тести
Потрібні JDK 17+ і Maven 3.9+.

```bash
./ci.sh          # Linux / macOS
ci.bat           # Windows (cmd)
```
Скрипт виконує `mvn clean verify` (компіляція, тести, jar), перевіряє, що тест `BasicAddition` запустився,
складає виконувані файли в `build/dist/` і запускає `hello`.

### Запуск зібраної програми
```bash
java -jar build/hello.jar      # будь-яка ОС
build/dist/hello               # Linux / macOS
build\dist\hello.bat           # Windows
```
Очікуваний вивід: `Hello, World!`
<!-- /agent:project-section -->
