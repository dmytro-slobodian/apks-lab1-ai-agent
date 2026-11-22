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
