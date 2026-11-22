---
name: github-actions
description: Створює .github/workflows/ci.yml - одна job з matrix ubuntu-latest, windows-latest, macos-latest, яка робить checkout, налаштовує JDK і запускає лише ci.sh або ci.bat, а потім зберігає hello як артефакт. Використовуй для команди /create-actions.
---

# Skill: github-actions

## Коли застосовувати
- Команда `/create-actions` або крок 4 оркестратора `/init`.
- Після skill `build-and-test`: мають існувати `ci.sh` і `ci.bat`.

## Входи
| Параметр | Значення |
|---|---|
| Гілки | `develop`, `master` (push і pull_request) + ручний запуск `workflow_dispatch` |
| ОС | `ubuntu-latest`, `windows-latest`, `macos-latest` |
| JDK | Temurin 17 через `actions/setup-java@v4` з кешем Maven |
| Скрипти | `./ci.sh` (bash) і `call ci.bat` (cmd) |
| Шаблон | `templates/ci.yml` |

## Виходи
| Файл | Опис |
|---|---|
| `.github/workflows/ci.yml` | workflow `CI`, job `build-and-test (<os>)` |
| Артефакти запуску | `hello-Linux`, `hello-Windows`, `hello-macOS` (`build/dist/`), `test-reports-<OS>` |

## Правила
1. **Логіка складання лише у скриптах.** У `ci.yml` дозволені кроки: checkout, setup-java,
   запуск `./ci.sh` / `call ci.bat`, upload-artifact. Жодних `mvn ...` прямо у workflow.
2. Одна job, одна matrix, `fail-fast: false` — щоб було видно результат для кожної ОС окремо.
3. `permissions: contents: read`. Жодних секретів, токенів, `${{ secrets.* }}`.
4. Не додавати `continue-on-error`, `|| true` до кроку складання.

## Кроки
1. Перевір, що є `ci.sh` і `ci.bat`. Якщо ні — `ERROR`, порадь `/create-build`.
2. Застосуй правило CREATED / SKIP / CONFLICT до `.github/workflows/ci.yml` з шаблоном `templates/ci.yml`.
3. Перевір YAML (розділ «Перевірка»).
4. Підкажи студенту, що реальний запуск буде після push у `develop`/`master` або при PR у ці гілки.

## Перевірка
```bash
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml')); print('YAML OK')"
grep -E 'ubuntu-latest|windows-latest|macos-latest' .github/workflows/ci.yml
grep -E '^\s+run:' .github/workflows/ci.yml       # лише ./ci.sh і call ci.bat
bash .github/agent-tools/check.sh --no-build      # розділ 5 має бути PASS
```
Після push: вкладка **Actions** → workflow **CI** → три зелені job, у кожній є артефакт `hello-<OS>`.

## Помилки
| Ситуація | Що робити |
|---|---|
| Невалідний YAML (табуляції, відступи) | показати рядок помилки, виправити за шаблоном |
| `./ci.sh: Permission denied` на Linux/macOS | `git update-index --chmod=+x ci.sh`, закомітити |
| `ci.bat` не запускається / дивні символи | перевірити `.gitattributes` (`*.bat text eol=crlf`) |
| Job падає лише на одній ОС | відкрити лог цієї job, виправляти скрипт для цієї ОС, а не вимикати її з matrix |

## Приклад
**Вхід:** `/create-actions` після `/create-build`.

**Очікуваний результат:**
```
CREATED .github/workflows/ci.yml
YAML OK; matrix = [ubuntu-latest, windows-latest, macos-latest]; run steps = [./ci.sh, call ci.bat]
```
**Перевірки:** `check.sh --no-build`, розділ 5 — усі пункти PASS.

**Типовий сценарій помилки:** у workflow додали крок `run: mvn test`.
`check.sh` виводить `[FAIL] ci.yml: structure check failed` з повідомленням `run steps: [...]`,
бо правило 1 вимагає запускати лише скрипти. Агент прибирає крок і пояснює, що тести вже запускає `ci.sh`.
