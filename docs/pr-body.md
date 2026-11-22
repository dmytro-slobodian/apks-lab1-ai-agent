## lab1/finish — AI-агент build-engineer (варіант 5: Java + Maven + JUnit)

Гілка `feature/lab1-java-agent` містить результат запуску агента `/init` поверх гілки `develop`
(у `develop` лише агент і інструкції).

### Що додано
- Java 17 Hello World: `App` (друкує `Hello, World!`), тестова функція `Calculator.add`
- Maven: `pom.xml`, вихід у `build/`, виконуваний `build/hello.jar`
- JUnit 5: `BasicAddition`, `NegativeAddition`, `OverflowThrows`, `GreetingText`, `MainPrintsGreeting`
- Скрипти складання `ci.sh` (Linux/macOS) і `ci.bat` (Windows)
- GitHub Actions `.github/workflows/ci.yml`: одна job, matrix `ubuntu-latest`, `windows-latest`, `macos-latest`
- `.gitignore`, `.gitattributes`

### Посилання
- Журнал AI: [docs/ai-log.md](../blob/feature/lab1-java-agent/docs/ai-log.md)
- Архітектура: [docs/architecture.md](../blob/feature/lab1-java-agent/docs/architecture.md)
- Інструкція: [docs/usage.md](../blob/feature/lab1-java-agent/docs/usage.md)
- Локальні перевірки: [docs/build-results.md](../blob/feature/lab1-java-agent/docs/build-results.md)
- GitHub Actions: див. вкладку **Checks** цього PR

### Перевірка
- [x] `./ci.sh` → `CI RESULT: PASS`, 5 тестів, 0 падінь
- [x] `bash .github/agent-tools/check.sh` → `RESULT: PASS`
- [x] `build/` ігнорується, секретів у репозиторії немає
- [ ] GitHub Actions: Linux, Windows, macOS — зелені
