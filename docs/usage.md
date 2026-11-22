# Інструкція: запуск агента і проєкту

## 1. Що потрібно встановити
| Інструмент | Версія | Перевірка |
|---|---|---|
| Git | 2.30+ | `git --version` |
| JDK | 17 або новіша (Temurin, OpenJDK) | `java -version` |
| Maven | 3.9+ | `mvn -v` |
| VS Code | свіжа стабільна | — |
| Розширення GitHub Copilot + Copilot Chat | студентський план | у чаті немає повідомлення про відсутність плану |
| (Windows) Git Bash | іде разом з Git for Windows | для `check.sh` |

## 2. Відтворення гілки feature з гілки develop
```bash
git clone https://github.com/<user>/apks-lab1-ai-agent.git
cd apks-lab1-ai-agent
git switch develop
git switch -c feature/lab1-java-agent-run2     # нова гілка для запуску агента
code .
```
У VS Code:
1. Відкрити Copilot Chat (`Ctrl+Alt+I`).
2. У списку агентів обрати **build-engineer**.
3. Ввести:
   ```
   /init
   ```
4. Підтверджувати запуск терміналу, коли Copilot питає дозвіл (`./ci.sh`, `git status`, `check.sh`).
5. Дочекатися звіту `INIT REPORT ... RESULT: SUCCESS`.
6. Переглянути зміни (`Source Control` → кожен файл) і закомітити командами, які запропонує агент.

Порівняти результат з еталонною гілкою:
```bash
git diff --stat feature/lab1-java-agent -- . ':!docs'
```
Порожній або мінімальний diff означає, що агент відтворив результат.

## 3. Окремі команди агента
| Команда | Коли запускати |
|---|---|
| `/git-init` | перевірити репозиторій і `.gitignore` |
| `/create-project` | створити `App.java` і README-секцію |
| `/create-build` | створити `pom.xml`, тести, `ci.sh`, `ci.bat` і зібрати |
| `/create-actions` | створити `.github/workflows/ci.yml` |
| `/check` | перевірити все, нічого не змінюючи |
| `/init` | усе вище по черзі |

Повторний `/init` безпечний: усі кроки дадуть `SKIP`, `/check` — `RESULT: PASS`.

## 4. Локальна перевірка без Copilot
```bash
# Linux / macOS
./ci.sh
bash .github/agent-tools/check.sh

# Windows (cmd)
ci.bat
# Windows (Git Bash)
bash .github/agent-tools/check.sh
```
Очікувано: `CI RESULT: PASS`, потім `RESULT: PASS`.

## 5. Запуск зібраної програми
```bash
java -jar build/hello.jar      # будь-яка ОС
build/dist/hello               # Linux / macOS
build\dist\hello.bat           # Windows
```
Вивід: `Hello, World!`

Готові файли для кожної ОС також лежать в артефактах GitHub Actions: Actions → CI → потрібний запуск →
Artifacts → `hello-Linux` / `hello-Windows` / `hello-macOS`.

## 6. Демонстрація навмисно зламаної перевірки
```bash
# 1. ламаємо тест (лише у робочій копії, не комітимо)
sed -i.bak 's/assertEquals(5, Calculator.add(2, 3))/assertEquals(6, Calculator.add(2, 3))/' \
  src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java
bash .github/agent-tools/check.sh          # [FAIL] ci script failed ... expected: <6> but was: <5>
                                           # RESULT: FAIL, код виходу 1
# 2. повертаємо
mv src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java.bak src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java
bash .github/agent-tools/check.sh          # RESULT: PASS
```
Так само можна прибрати `macos-latest` з `ci.yml` — `check.sh` покаже `[FAIL] ci.yml: structure check failed`.

## 7. Git-процес
```bash
git push -u origin develop
git push -u origin feature/lab1-java-agent
gh pr create --base develop --head feature/lab1-java-agent --title "lab1/finish" --body-file docs/pr-body.md
```
Після перевірки PR і зелених job — злиття в `develop`, потім `develop` → `master`.
