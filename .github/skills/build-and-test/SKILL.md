---
name: build-and-test
description: Налаштовує складання Maven і юніт-тести JUnit 5 для Java Hello World - pom.xml, тестова функція Calculator.add, тести BasicAddition та інші, скрипти ci.sh і ci.bat, що збирають hello.jar. Використовуй для команди /create-build.
---

# Skill: build-and-test

## Коли застосовувати
- Команда `/create-build` або крок 3 оркестратора `/init`.
- Після skill `project-scaffold` (має існувати `App.java`).

Skill розділено на три підкроки, їх можна виконати окремо:
1. **build-config** — `pom.xml`;
2. **test-function + unit-test** — `Calculator.java`, `CalculatorTest.java`, `AppTest.java`;
3. **build-scripts** — `ci.sh`, `ci.bat`.

## Входи
| Параметр | Значення |
|---|---|
| `package` | `ua.lpnu.ki405.hello` |
| Java | 17 (`maven.compiler.release`) |
| Шаблони | `templates/pom.xml`, `templates/Calculator.java`, `templates/CalculatorTest.java`, `templates/AppTest.java`, `templates/ci.sh`, `templates/ci.bat` |
| Інструменти на машині | JDK 17+, Maven 3.9+ (`java -version`, `mvn -v`) |

## Виходи
| Файл | Опис |
|---|---|
| `pom.xml` | Maven: JUnit 5.11.4, вихідний каталог `build/`, `finalName` = `hello`, `Main-Class` у manifest jar, `failIfNoTests=true` |
| `src/main/java/ua/lpnu/ki405/hello/Calculator.java` | тестова функція `add(int, int)` з контролем переповнення |
| `src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java` | `BasicAddition`, `NegativeAddition`, `OverflowThrows` |
| `src/test/java/ua/lpnu/ki405/hello/AppTest.java` | `GreetingText`, `MainPrintsGreeting` |
| `ci.sh` | Linux/macOS: `mvn clean verify` → перевірка звіту тестів → `build/dist/hello` → smoke-тест |
| `ci.bat` | Windows: те саме, лаунчер `build\dist\hello.bat` |
| `build/hello.jar`, `build/dist/*` | результат складання, НЕ комітиться |

## Кроки
1. Перевір `App.java`. Якщо немає — `ERROR`, порадь `/create-project`.
2. Для кожного файлу з «Виходів» (крім `build/`) застосуй правило CREATED / SKIP / CONFLICT
   з manifest агента. Вміст бери з шаблонів дослівно, версії плагінів не змінюй.
3. `ci.sh` збережи з LF і зроби виконуваним: `chmod +x ci.sh` та
   `git update-index --chmod=+x ci.sh` (якщо файл уже в індексі). `ci.bat` — CRLF
   (це забезпечує `.gitattributes`).
4. Запусти складання: `./ci.sh` (Linux/macOS) або `ci.bat` (Windows).
5. Перевір результат за розділом «Перевірка».

## Перевірка
```bash
./ci.sh                                              # має закінчитись рядком CI RESULT: PASS
grep -o 'testcase name="[^"]*"' build/surefire-reports/*.xml   # серед них BasicAddition
java -jar build/hello.jar                            # Hello, World!
git status --porcelain --ignored | grep build/       # "!! build/" = ігнорується
```
Успіх: код виходу 0, `Tests run: 5, Failures: 0, Errors: 0`, вивід програми `Hello, World!`.

## Помилки
| Ситуація | Що робити |
|---|---|
| `java` або `mvn` не знайдено | зупинитись, показати як встановити JDK 17 і Maven; не змінювати pom |
| Не компілюється | показати перші помилки `javac`, виправити код за шаблоном, не вимикати перевірки |
| Тест падає | показати назву тесту, очікуване і фактичне значення; **заборонено** `-DskipTests`, `@Disabled`, видалення тесту |
| `Tests run: 0` | `failIfNoTests` зупинить збірку: перевір пакет і назви тестових класів (`*Test.java`) |
| Немає доступу до Maven Central | повідомити про мережу/проксі; не підміняти залежності вручну |

## Приклад
**Вхід:** `/create-build` після `/create-project`.

**Очікуваний результат:**
```
CREATED pom.xml
CREATED src/main/java/ua/lpnu/ki405/hello/Calculator.java
CREATED src/test/java/ua/lpnu/ki405/hello/CalculatorTest.java
CREATED src/test/java/ua/lpnu/ki405/hello/AppTest.java
CREATED ci.sh (+x)
CREATED ci.bat
RUN ./ci.sh ... Tests run: 5, Failures: 0 ... hello says: Hello, World! ... CI RESULT: PASS
```
**Перевірки:** звіт `TEST-ua.lpnu.ki405.hello.CalculatorTest.xml` містить `BasicAddition`; є `build/hello.jar`.

**Типовий сценарій помилки:** у `CalculatorTest` очікування змінено на `assertEquals(6, Calculator.add(2, 3))`.
`mvn verify` падає з `expected: <6> but was: <5>`, `ci.sh` виводить `ERROR` і код 1, `/check` — `RESULT: FAIL`.
Агент показує причину і пропонує виправити тест, а не пропускати його.
