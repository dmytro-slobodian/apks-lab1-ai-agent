# Журнал взаємодії з AI

Журнал складається з двох частин:
- **Частина A** — проєктування агента (manifest, skills, commands, шаблони, скрипт перевірки) у чаті з AI-асистентом Claude.
- **Частина B** — запуск агента `build-engineer` у GitHub Copilot (VS Code) на гілці `develop` для відтворення гілки `feature`.
  Заповнюється під час власного запуску `/init`.

Секрети, токени і паролі AI не передавались.

---

## Частина A. Проєктування агента

| # | Запит до AI (коротко) | Важлива відповідь / результат | Рішення студента |
|---|---|---|---|
| A1 | Надано методичку ЛР1 (task1_1.pdf), попрошено виконати лабораторну для варіанта за номером у списку (№ 23) | Визначено варіант: 6 варіантів, 23 → 5 (по колу) = Java + Maven + JUnit. Запропоновано формат Copilot у VS Code: `.github/agents/*.agent.md`, `.github/prompts/*.prompt.md`, `.github/skills/*/SKILL.md` | прийнято |
| A2 | Які поля підтримують custom agent і prompt files? | Перевірено документацію VS Code: агент — `name`, `description`, `tools` (`read`, `edit`, `search`, `execute`, `todo`); prompt file — `agent: build-engineer`, `tools`, виклик через `/назва` | прийнято |
| A3 | Як зробити, щоб повторний запуск агента давав той самий результат? | Покласти точні шаблони файлів у `templates/` кожного skill, а в manifest — правило CREATED / SKIP / CONFLICT | прийнято |
| A4 | Як виконати вимогу «build/ не під Git», якщо Maven пише в `target/`? | Перенести каталог складання: `<directory>${project.basedir}/build</directory>` у `pom.xml` | прийнято |
| A5 | Вимога: `ci.yml` лише запускає скрипти | Уся логіка в `ci.sh`/`ci.bat` (`mvn clean verify`, перевірка звіту `BasicAddition`, лаунчери, smoke-тест). У workflow лише checkout, setup-java, `./ci.sh` / `call ci.bat`, upload-artifact | прийнято |
| A6 | Як зробити `/check` надійним і таким, що нічого не змінює? | Окремий скрипт `.github/agent-tools/check.sh` (7 груп перевірок, код 0/1); у `check.prompt.md` прибрано інструмент `edit` | прийнято |
| A7 | Перевірити все локально | Збірка, 5 тестів, `hello`, `check.sh` → `RESULT: PASS` (44/0). Лінтери: `shellcheck` 0 зауважень, `actionlint` 0 зауважень | прийнято |

### Помилки та їх виправлення (частина A)

**E1. Maven не міг завантажити плагіни.**
- Симптом: `Could not transfer artifact ... from/to central: repo.maven.apache.org: Name or service not known`,
  а після налаштування проксі — `status code: 403 Forbidden`.
- Причина: у пісочниці AI немає доступу до Maven Central (обмеження мережі середовища, не помилка проєкту).
- Рішення: для **локальної** перевірки використано пакети Maven з репозиторію Ubuntu (`/usr/share/maven-repo`) і
  перевизначення версій через `MVN_ARGS="-s <settings> -Djunit.version=5.10.1 ..."`. Тому версії плагінів у
  `pom.xml` винесено у `<properties>`. У GitHub Actions і на машині студента використовуються версії з `pom.xml`
  (JUnit 5.11.4, surefire 3.5.2) з Maven Central, без жодних змін.

**E2. `check.sh` не працював би на macOS.**
- Симптом: у перевірці порядку команд використовувався `grep -oE '...\b'`; `\b` — розширення GNU grep, BSD grep
  на macOS його не гарантує.
- Рішення: шаблон без `\b`. Також у скриптах не використовуються `sed -i` без суфікса і bash 4+.

**E3. При падінні тесту `/check` не показував, який тест упав.**
- Симптом (навмисно зламаний тест `assertEquals(6, Calculator.add(2, 3))`): виводились лише останні 20 рядків Maven
  (`BUILD FAILURE`, посилання на довідку), без назви тесту.
- Рішення: `check.sh` тепер виводить рядки `<<< FAILURE`, `expected: ... but was: ...` і підсумок `Tests run`.
  Результат після виправлення:
  ```
  [FAIL] ci script failed (code 1). Reason from build/check.log:
         [ERROR] BasicAddition  Time elapsed: 0.038 s  <<< FAILURE!
         org.opentest4j.AssertionFailedError: expected: <6> but was: <5>
         [ERROR] Tests run: 5, Failures: 1, Errors: 0, Skipped: 0
  RESULT: FAIL
  ```

**E4. Невдала перевірка `ci.yml` давала Python traceback.**
- Симптом: коли з matrix прибрали `macos-latest`, `check.sh` виводив `Traceback (most recent call last) ... AssertionError`.
- Рішення: перевірка обгорнута в `try/except`, виводиться одне зрозуміле повідомлення:
  `ci.yml problem: AssertionError("matrix: ['ubuntu-latest', 'windows-latest']")`.

**E5. Синтаксична помилка під час редагування `check.sh`.**
- Симптом: AI при правці вставив непарну лапку (`"... build/check.log'`), `shellcheck` вивів `SC1078`, `SC1046`.
- Рішення: лапку виправлено, `shellcheck -S warning` — 0 зауважень. Висновок: зміни, зроблені AI, обов'язково
  проганяти через лінтер, а не лише перечитувати.

**E6. Потенційне падіння `ci.sh` через SIGPIPE.**
- Симптом (знайдено під час перегляду коду, до запуску в CI): `java -version 2>&1 | head -n 1` при
  `set -o pipefail` може завершитись кодом 141, якщо `head` закриє канал раніше, ніж `java` допише вивід.
  Тоді `set -e` зупинив би збірку без реальної помилки.
- Рішення: `sed -n '1p'` замість `head -n 1` (sed дочитує вхід до кінця).

### Перевірені рішення
- `failIfNoTests=true` у surefire: збірка з нулем тестів вважається помилкою.
- `Math.addExact` у `Calculator.add` + тест `OverflowThrows`: переповнення не проходить мовчки.
- `.gitattributes`: `*.sh eol=lf`, `*.bat eol=crlf` — щоб скрипти працювали після checkout на будь-якій ОС.
- `fail-fast: false` у matrix: видно результат кожної ОС окремо.

---

## Частина B. Запуск агента в GitHub Copilot

Заповнити під час запуску (`git switch develop && git switch -c feature/lab1-java-agent-run2`, Copilot Chat →
агент **build-engineer** → `/init`). Скріншоти — у звіт.

| # | Запит у Copilot | Що відповів / зробив Copilot | Помилка? | Рішення |
|---|---|---|---|---|
| B1 | `/init` | | | |
| B2 | | | | |
| B3 | `/check` | | | |
| B4 | повторний `/init` (перевірка, що нічого не зламано) | | | |

Порівняння з еталонною гілкою:
```bash
git diff --stat feature/lab1-java-agent -- . ':!docs'
```
Результат: …
