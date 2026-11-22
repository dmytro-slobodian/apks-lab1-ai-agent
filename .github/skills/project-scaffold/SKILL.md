---
name: project-scaffold
description: Створює мінімальний Java Hello World проєкт - структуру каталогів, App.java, секцію README, .gitignore і .gitattributes. Використовуй для команди /create-project або коли в репозиторії ще немає вихідного коду.
---

# Skill: project-scaffold

## Коли застосовувати
- Команда `/create-project` або крок 2 оркестратора `/init`.
- У репозиторії ще немає `src/main/java/.../App.java`.
- Повторний запуск дозволено: skill нічого не перезаписує.

## Входи
| Параметр | Значення за замовчуванням | Звідки |
|---|---|---|
| `language` | `java` | варіант 5 у manifest агента |
| `project_name` | `hello` | manifest агента |
| `package` | `ua.lpnu.ki405.hello` | manifest агента |
| Шаблони | `templates/App.java`, `templates/README-project-section.md`, `templates/gitignore.template`, `templates/gitattributes.template` | каталог цього skill |

Якщо `language` не `java` — зупинись з помилкою: цей skill підтримує лише варіант 5.

## Виходи
| Файл | Дія |
|---|---|
| `src/main/java/ua/lpnu/ki405/hello/App.java` | створити з `templates/App.java` |
| `src/test/java/ua/lpnu/ki405/hello/` | створити порожній каталог для тестів (тести додає skill build-and-test) |
| `README.md` | якщо файлу немає — створити із заголовком `# <project_name>` і секцією; якщо є — дописати в кінець секцію з `templates/README-project-section.md`, лише якщо маркера `<!-- agent:project-section -->` ще немає |
| `.gitignore` | дописати лише ті рядки з `templates/gitignore.template`, яких ще немає |
| `.gitattributes` | дописати лише ті рядки з `templates/gitattributes.template`, яких ще немає |

## Кроки
1. Перевір, що поточний каталог — корінь Git-репозиторію: `git rev-parse --show-toplevel`.
2. Для кожного файлу з таблиці «Виходи»:
   - файл відсутній → створи з шаблону, виведи `CREATED <файл>`;
   - файл існує і збігається з шаблоном → `SKIP <файл>`;
   - файл існує і відрізняється → нічого не змінюй, виведи `CONFLICT <файл>` і покажи різницю студенту.
3. Вміст `App.java` копіюй з шаблону дослівно. Не змінюй текст `Hello, World!`: його перевіряють тест і скрипти.
4. Для `.gitignore` і `.gitattributes` порівнюй рядки після обрізання пробілів, коментарі теж не дублюй.

## Перевірка
```bash
test -f src/main/java/ua/lpnu/ki405/hello/App.java && echo "App.java OK"
grep -q 'Hello, World!' src/main/java/ua/lpnu/ki405/hello/App.java && echo "greeting OK"
grep -c '<!-- agent:project-section -->' README.md     # має бути 1
grep -qx 'build/' .gitignore && echo ".gitignore OK"
git check-ignore -q build/ && echo "build/ ignored"
```
Команда запуску проєкту (після `/create-build`): `java -jar build/hello.jar`.

## Помилки
| Ситуація | Що робити |
|---|---|
| Не Git-репозиторій | зупинитись, порадити `/git-init` |
| `App.java` існує, але інший | `CONFLICT`, не перезаписувати, показати diff |
| README містить маркер двічі | не додавати третій, повідомити студента про дублікат |
| Немає прав на запис | `ERROR`, показати шлях і помилку ОС |

## Приклад
**Вхід:** `/create-project` у репозиторії гілки `develop` (є лише файли агента і `README.md` з ПІП).

**Очікуваний результат:**
```
CREATED src/main/java/ua/lpnu/ki405/hello/App.java
CREATED src/test/java/ua/lpnu/ki405/hello/
UPDATED README.md (+ project section)
SKIP    .gitignore (all lines present)
SKIP    .gitattributes (all lines present)
```
**Перевірки:** усі команди з розділу «Перевірка» виводять `OK`, маркер у README рівно один.

**Типовий сценарій помилки:** студент змінив текст привітання вручну на `Hello World`.
Skill виводить `CONFLICT src/main/java/ua/lpnu/ki405/hello/App.java`, нічого не перезаписує і пояснює,
що тест `MainPrintsGreeting` і smoke-тест у `ci.sh` очікують рівно `Hello, World!`.
