---
name: create-build
description: Викликає skill build-and-test - створює pom.xml, тестову функцію Calculator.add, юніт-тести (BasicAddition) і скрипти ci.sh / ci.bat, потім запускає складання.
agent: build-engineer
tools: ['read', 'edit', 'search', 'execute']
---

# /create-build

Використай skill [build-and-test](../skills/build-and-test/SKILL.md).

## Передумови
- Існує `src/main/java/ua/lpnu/ki405/hello/App.java` (інакше спочатку `/create-project`).
- `java -version` показує 17 або новішу, `mvn -v` — Maven 3.9+.

## Дії
1. Підкрок build-config: `pom.xml` з шаблону.
2. Підкрок test-function + unit-test: `Calculator.java`, `CalculatorTest.java`, `AppTest.java`.
3. Підкрок build-scripts: `ci.sh` (LF, `+x`), `ci.bat` (CRLF).
4. Запусти `./ci.sh` (Linux/macOS) або `ci.bat` (Windows) і покажи останні 15 рядків виводу.

## Очікувані файли
- `pom.xml`, `ci.sh`, `ci.bat`
- `src/main/java/ua/lpnu/ki405/hello/Calculator.java`
- `src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java`, `AppTest.java`
- після запуску (не комітиться): `build/hello.jar`, `build/dist/hello` або `build/dist/hello.bat`, `build/surefire-reports/`

## Перевірка
```bash
./ci.sh | tail -n 15          # ... CI RESULT: PASS
java -jar build/hello.jar      # Hello, World!
git status --porcelain --ignored | grep build/   # !! build/
```

## Помилки
- `java`/`mvn` не знайдено → `ERROR create-build: toolchain missing`, інструкція встановлення.
- Збірка або тест упали → `ERROR create-build: <назва тесту/помилка компіляції>`, показати лог.
  Не пропускати тести і не послаблювати перевірки.

Підсумок: `CREATE-BUILD: OK` або `CREATE-BUILD: ERROR <причина>`.
