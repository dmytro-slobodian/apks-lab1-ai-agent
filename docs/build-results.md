# Результати перевірок

## 1. Локальне складання і тести (`./ci.sh`)
Середовище перевірки: Linux x86_64 (Ubuntu 24.04), OpenJDK 21.0.13, Maven 3.9.11.

```
==> 2/5 Configure, compile, unit tests, package (mvn clean verify)
[INFO] Tests run: 3, Failures: 0, Errors: 0, Skipped: 0 - in ua.lpnu.ki405.hello.CalculatorTest
[INFO] Tests run: 2, Failures: 0, Errors: 0, Skipped: 0 - in ua.lpnu.ki405.hello.AppTest
[INFO] Tests run: 5, Failures: 0, Errors: 0, Skipped: 0
[INFO] Building jar: .../build/hello.jar
[INFO] BUILD SUCCESS

==> 3/5 Test results
ua.lpnu.ki405.hello.AppTest: tests=2 failures=0
ua.lpnu.ki405.hello.CalculatorTest: tests=3 failures=0

==> 5/5 Smoke test
hello says: Hello, World!
CI RESULT: PASS
```

| Тест | Клас | Результат |
|---|---|---|
| BasicAddition | CalculatorTest | PASS |
| NegativeAddition | CalculatorTest | PASS |
| OverflowThrows | CalculatorTest | PASS |
| GreetingText | AppTest | PASS |
| MainPrintsGreeting | AppTest | PASS |

`git status --porcelain --ignored` після складання: `!! build/` — каталог ігнорується.

## 2. Команда `/check` (`bash .github/agent-tools/check.sh`)
```
SUMMARY: 44 passed, 0 failed, 0 warnings
RESULT: PASS
```

Навмисно зламана перевірка (тест очікує 6 замість 5):
```
[FAIL] ci script failed (code 1). Reason from build/check.log:
       [ERROR] BasicAddition  Time elapsed: 0.038 s  <<< FAILURE!
       org.opentest4j.AssertionFailedError: expected: <6> but was: <5>
       [ERROR] Tests run: 5, Failures: 1, Errors: 0, Skipped: 0
SUMMARY: 42 passed, 1 failed, 0 warnings
RESULT: FAIL
```

Навмисно зламаний workflow (з matrix прибрано macOS):
```
ci.yml problem: AssertionError("matrix: ['ubuntu-latest', 'windows-latest']")
[FAIL] ci.yml: structure check failed (see message above)
```

## 3. Лінтери
| Інструмент | Файли | Результат |
|---|---|---|
| shellcheck 0.9.0 | `ci.sh`, `.github/agent-tools/check.sh` | 0 зауважень |
| actionlint 1.7.12 | `.github/workflows/ci.yml` | 0 зауважень |

## 4. GitHub Actions
| ОС | Job | Результат | Артефакт |
|---|---|---|---|
| ubuntu-latest | build-and-test (ubuntu-latest) | _вписати після запуску_ | hello-Linux |
| windows-latest | build-and-test (windows-latest) | _вписати після запуску_ | hello-Windows |
| macos-latest | build-and-test (macos-latest) | _вписати після запуску_ | hello-macOS |

Посилання на запуск: _вписати_
