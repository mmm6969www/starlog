# StarLog

Журнал астрономічних спостережень для клубу аматорів-астрономів.
Навчальний проєкт (ЛР №5): шарувата архітектура за Clean Architecture
та командна робота в Git.

## Функціонал

- додати спостереження (назва об’єкта, нотатки, категорія);
- переглянути журнал;
- підтвердити спостереження (лише один раз);
- сховище — JSON-файл або пам’ять, вибирається в appsettings.json.

## Архітектура

Стрілка означає «залежить від». Усі залежності спрямовані до Domain.

    Presentation ──► Application ──► Domain ◄── Infrastructure
    (bin, CLI)       (use cases)     (сутності, (JSON / InMemory
                                      інтерфейси) репозиторії)

bin/starlog.dart (Presentation) створює конкретний репозиторій
з Infrastructure і передає його в use cases через конструктор (DI).

| Шар | Каталог | Відповідальність |
| --- | --- | --- |
| Domain | lib/src/domain | сутність Observation, бізнес-правила, інтерфейс IObservationRepository |
| Application | lib/src/application | use cases; працюють лише через інтерфейс |
| Infrastructure | lib/src/infrastructure | JsonObservationRepository, InMemoryObservationRepository |
| Presentation | bin, lib/src/presentation | консольний інтерфейс, збирання залежностей (DI) |

## Збірка і запуск

Потрібен Dart SDK 3.x. Запускайте з кореня репозиторію.

    git clone https://github.com/<login>/starlog.git
    cd starlog
    dart pub get
    dart analyze
    dart test
    dart run bin/starlog.dart

## Конфігурація

Файл appsettings.json: storage.type — json або memory,
storage.dataFile — шлях до JSON-файлу з даними.

## Гілки та коміти

- main — стабільний код, лише релізи з тегами;
- develop — інтеграційна гілка;
- feature/* — по одній гілці на шар архітектури;
- docs/* — документація.

Комміти за Conventional Commits: feat, fix, refactor, test, docs, chore.

## Версії

v1.0.0 — перший стабільний реліз.