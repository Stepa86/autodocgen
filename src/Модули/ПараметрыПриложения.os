///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором служебных параметров приложения
//
// При создании нового приложения обязательно внести изменение
// в ф-ии ИмяПродукта, указав имя вашего приложения.
//
// При выпуске новой версии обязательно изменить ее значение
// в ф-ии ВерсияПродукта
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// СВОЙСТВА ПРОДУКТА

// ИмяПродукта
//	Возвращает имя продукта
//
// Возвращаемое значение:
//   Строка   - Значение имени продукта
//
Функция ИмяПродукта() Экспорт

	Возврат "AutodocGen";

КонецФункции // ИмяПродукта

// КраткоеОписаниеПродукта
//	Возвращает краткое описание продукта
//
// Возвращаемое значение:
//   Строка   - Значение описания продукта
//
Функция КраткоеОписаниеПродукта() Экспорт

	Возврат "Генерация документации по исходному коду 1С";

КонецФункции // ИмяПродукта

// ВерсияПродукта
//	Возвращает текущую версию продукта
//
// Возвращаемое значение:
//   Строка   - Значение текущей версии продукта
//
Функция ВерсияПродукта() Экспорт

	Возврат "1.2.2";

КонецФункции // ВерсияПродукта

///////////////////////////////////////////////////////////////////////////////
// ЛОГИРОВАНИЕ

//	Форматирование логов
//   См. описание метода "УстановитьРаскладку" библиотеки logos
//
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт

	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);

КонецФункции

// ИмяЛогаСистемы
//	Возвращает идентификатор лога приложения
//
// Возвращаемое значение:
//   Строка   - Значение идентификатора лога приложения
//
Функция ИмяЛогаСистемы() Экспорт

	Возврат "oscript.app." + ИмяПродукта();

КонецФункции // ИмяЛогаСистемы
