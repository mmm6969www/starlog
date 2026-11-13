# StarLog

Журнал астрономічних спостережень для клубу аматорів-астрономів.
Навчальний проєкт до лабораторної роботи №5: шарувата архітектура за
Clean Architecture та командна робота в Git (гілки, pull request-и,
код-рев’ю, теги).

## Функціонал

- додати спостереження (назва об’єкта, нотатки, категорія);
- переглянути журнал (найновіші записи першими, з датою);
- підтвердити спостереження (лише один раз);
- сховище — JSON-файл або пам’ять, вибирається в appsettings.json.

## Архітектура

Стрілка означає «залежить від». Усі залежності спрямовані до Domain.

    Presentation ──► Application ──► Domain ◄── Infrastructure
    (bin, CLI)       (use cases)     (сутності, (JSON / InMemory
                                      інтерфейси) репозиторії)

| Шар | Каталог | Відповідальність |
| --- | --- | --- |
| Domain | lib/src/domain | сутність Observation, бізнес-правила, інтерфейс IObservationRepository |
| Application | lib/src/application | use cases; працюють лише через інтерфейс |
| Infrastructure | lib/src/infrastructure | JsonObservationRepository, InMemoryObservationRepository |
| Presentation | bin, lib/src/presentation | консольне меню, збирання залежностей (DI) |

## Структура проєкту

    bin/starlog.dart                                        точка входу, DI
    lib/src/domain/entities/observation.dart                сутність, бізнес-правила
    lib/src/domain/interfaces/observation_repository.dart   IObservationRepository
    lib/src/application/use_cases/                          Add / List / Verify
    lib/src/infrastructure/repositories/                    Json і InMemory
    lib/src/presentation/cli/cli_app.dart                   консольне меню
    test/                                                   тести
    appsettings.json                                        конфігурація

## Ключові фрагменти коду

Інтерфейс у Domain:

    abstract interface class IObservationRepository {
      Future<List<Observation>> getAll();
      Future<Observation?> getById(String id);
      Future<void> save(Observation observation);
    }

Use case отримує інтерфейс через конструктор і не знає про сховище:

    class AddObservationUseCase {
      final IObservationRepository _repository;
      AddObservationUseCase(this._repository);
      // ...
    }

Збирання залежностей у bin/starlog.dart:

    final IObservationRepository repository = switch (storage['type']) {
      'memory' => InMemoryObservationRepository(),
      _ => JsonObservationRepository(storage['dataFile'] as String),
    };

## Збірка і запуск

Потрібен Dart SDK 3.x. Запускайте з кореня репозиторію.

    git clone https://github.com/<login>/starlog.git
    cd starlog
    dart pub get
    dart analyze
    dart test
    dart run bin/starlog.dart

## Конфігурація

Файл appsettings.json: storage.type — json або memory;
storage.dataFile — шлях до файлу даних (data/observations.json,
каталог створюється автоматично).

## Git-процес

| Гілка | Призначення |
| --- | --- |
| main | стабільний код, лише релізи з тегами |
| develop | інтеграційна гілка |
| feature/* | по одній гілці на шар архітектури |
| docs/* | документація |

Коміти — за Conventional Commits зі scope шару, наприклад
feat(domain): ..., fix(infrastructure): ... Кожна feature-гілка
зливається в develop через pull request із код-рев’ю; develop
зливається в main лише для релізу з тегом.

## Змодельований конфлікт

Файл appsettings.json змінено одночасно в develop і в
feature/infrastructure-layer (рядок dataFile). Конфлікт розв’язано
вручну: залишено data/observations.json.

## Версії

v1.0.0 — перший стабільний реліз.

## Відповіді на контрольні запитання

1. У чому полягає принцип інверсії залежностей і як він реалізований у структурі проєкту?
Принцип інверсії залежностей (DIP) стверджує, що модулі високого рівня не повинні залежати від модулів низького рівня, а обидва мають залежати від абстракцій. У StarLog бізнес-логіка (use cases) не залежить від конкретного сховища даних. Абстракцію IObservationRepository оголошено в шарі Domain, use cases отримують її через конструктор, а JsonObservationRepository та InMemoryObservationRepository її реалізують. Напрямок залежності Infrastructure → Domain «інвертований» порівняно з наївною схемою, де логіка напряму викликала б роботу з файлом. Завдяки цьому сховище можна замінити, не змінюючи жодного use case.

2. Чому Domain-шар не повинен мати залежностей від Infrastructure чи Presentation?
Domain містить найстабільніші речі — сутності та бізнес-правила, які мають існувати незалежно від способу зберігання чи інтерфейсу. Якби Domain залежав від Infrastructure, зміна файлу на базу даних або UI змушувала б переписувати бізнес-логіку. Така залежність також ускладнила б тестування, бо для перевірки правил довелося б піднімати файли чи інтерфейс, і могла б створити циклічні залежності між шарами. У проєкті це перевіряється командою grep -rn "infrastructure\|presentation" lib/src/domain lib/src/application, яка нічого не виводить.

3. Яка різниця між git merge та git rebase, і коли доцільно використовувати кожен із них?
git merge поєднує історії двох гілок, створюючи окремий merge-коміт, тому історія зберігається такою, якою була, зі всіма розгалуженнями. git rebase «переносить» коміти поточної гілки на кінець іншої, переписуючи їхні хеші, і дає лінійну історію. Merge безпечний для спільних гілок (develop, main) і pull request-ів, тому саме ним ми зливали feature-гілки. Rebase доцільний для локальних, ще не опублікованих гілок, щоб підтягнути свіжі зміни з develop без зайвих merge-комітів. Не можна робити rebase гілок, якими вже користуються інші, бо це переписує спільну історію.

4. Опишіть послідовність дій при виникненні конфлікту злиття в Git.
Після git merge Git повідомляє CONFLICT, а git status показує файли в стані both modified. Потрібно відкрити такий файл і знайти маркери <<<<<<<, =======, >>>>>>>, між якими стоять версії обох гілок. Далі вручну залишають правильний варіант або поєднують обидва, прибираючи самі маркери. Після цього файл додають командою git add, а злиття завершують git commit (або git merge --continue). Перед git push варто перевірити збірку й тести; якщо заплутатися, git merge --abort скасує злиття.

5. Яку роль виконує гілка develop у порівнянні з main у обраній моделі гілкування (Git Flow)?
Гілка main містить стабільний, перевірений код і змінюється лише під час релізу, кожен реліз позначається тегом (v1.0.0). Гілка develop — інтеграційна: від неї створюються feature-гілки і в неї вони зливаються через pull request. Тут збирається поточний стан розробки, який ще може містити недоопрацьовані місця. Коли develop перевірено, його зливають у main. Так main завжди залишається готовим до використання.

6. Навіщо потрібен pull request, якщо можна одразу зробити git merge локально?
Pull request створює місце для код-рев’ю: інші бачать зміни, коментують рядки коду й просять правки до злиття. В описі PR фіксується, що і чому змінено, тому лишається історія рішень. До PR можна підключати автоматичні перевірки та вимоги схвалення для захищених гілок. Локальний git merge оминає все це, і зміни потрапляють у develop без перегляду й обговорення. У цій роботі завдяки PR ми отримали коментарі рев’ю та окремі коміти-правки.

7. Як конвенція Conventional Commits допомагає в супроводі проєкту?
Повідомлення має вигляд тип(область): опис, наприклад feat(domain): додати інтерфейс IObservationRepository. Тип (feat, fix, refactor, test, docs, chore) одразу показує характер зміни, а область — який шар зачеплено. Історію легко фільтрувати й читати, зокрема під час рев’ю. З таких повідомлень автоматично генерують changelog і визначають номер версії: feat піднімає мінорну версію, fix — патч. Тому конвенція економить час при супроводі.

8. Опишіть структуру каталогів вашого проєкту за шарами Clean Architecture. Поясніть, у якому шарі розміщено інтерфейс репозиторію, а в якому — його реалізацію, і чому саме так.
```bash
lib/src/domain/entities/observation.dart
lib/src/domain/interfaces/observation_repository.dart   <- інтерфейс
lib/src/application/use_cases/*.dart
lib/src/infrastructure/repositories/json_observation_repository.dart   <- реалізація
lib/src/presentation/cli/cli_app.dart
bin/starlog.dart
```
Інтерфейс IObservationRepository розміщено в Domain, бо саме внутрішнє ядро визначає, що йому потрібно від сховища: отримати список, знайти за id, зберегти. Реалізації (JsonObservationRepository, InMemoryObservationRepository) лежать в Infrastructure, бо вони залежать від деталей: файлової системи й формату JSON. Така розстановка спрямовує залежності від зовнішніх шарів до внутрішніх і дозволяє підмінити сховище, не чіпаючи Domain та Application.

9. Наведіть фрагмент коду точки входу вашого застосунку (Presentation-шар), де залежності збираються через Dependency Injection, і поясніть, як замінити спосіб зберігання даних без зміни use cases.
```dart
final IObservationRepository repository = switch (storage['type']) {
  'memory' => InMemoryObservationRepository(),
  _ => JsonObservationRepository(storage['dataFile'] as String),
};

final app = CliApp(
  title: config['appName'] as String,
  addObservation: AddObservationUseCase(repository),
  listObservations: ListObservationsUseCase(repository),
  verifyObservation: VerifyObservationUseCase(repository),
);
```
У bin/starlog.dart створюється конкретний репозиторій і передається в use cases через конструктор — це і є Dependency Injection. Щоб замінити сховище, достатньо змінити "type" в appsettings.json на memory або написати новий клас, що реалізує IObservationRepository (наприклад, для SQLite), і створити його в цьому місці. Use cases знають лише інтерфейс, тому їхній код лишається без змін.

10. Опишіть конфлікт злиття, який ви змоделювали в роботі: у якому файлі та між якими гілками він виник, як виглядали маркери конфлікту і яке рішення ви прийняли під час його розв’язання.
Конфлікт виник у файлі appsettings.json при git merge develop у гілці feature/infrastructure-layer: в обох гілках змінили один і той самий рядок dataFile. ПЕРЕВІРТЕ: підставте свої значення, якщо вони інші. Маркери виглядали так:
```json
<<<<<<< HEAD
    "dataFile": "data/observations.json"
=======
    "dataFile": "starlog-observations.json"
>>>>>>> develop
```
Прийнято рішення залишити data/observations.json, оскільки Infrastructure сама створює каталог data/, а каталог доданий до .gitignore. Нову назву застосунку appName, змінену лише в develop, Git об’єднав автоматично. Після видалення маркерів виконано git add appsettings.json та git commit -m "merge: розв’язано конфлікт конфігурації сховища даних".

## Висновки

У роботі застосунок StarLog розділено на чотири шари з напрямком залежностей до Domain, а доступ до даних прихований за інтерфейсом IObservationRepository, тому сховище замінюється без змін бізнес-логіки. Розробку виконано за Git Flow: feature-гілки на кожен шар, pull request-и з код-рев’ю та окремими комітами-правками, змодельований і розв’язаний конфлікт злиття, реліз у main із тегом v1.0.0. Практично закріплено Conventional Commits та навички командної роботи в GitHub.