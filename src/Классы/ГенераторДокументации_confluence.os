///////////////////////////////////////////////////////////////////////////////
//
// Служебный класс генерации документации в формате confluence
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать confluence

Перем Шаблоны;

Перем АнализироватьТолькоПотомковПодсистемы;

Перем ПодключениеConfluence;
Перем ПространствоConflunece;
Перем КорневаяСтраницаConflunece;

Перем СимволыЗамены;
Перем ОбновлятьИзмененныеСтраницы;

Перем АдресКорневойСтраницы;

///////////////////////////////////////////////////////////////////////////////
// ПРОГРАММНЫЙ ИНТЕРФЕЙС
///////////////////////////////////////////////////////////////////////////////

#Область ГенерацияДанных

// ДокументацияПоМодулю
//
// Параметры:
//   ДанныеМодуля - Структура - Описание модуля, структура содержащая массив описаний методов, см. ГенераторДокументации.ОписаниеМетода
//   Ошибки - Массив - Коллекция ошибок генерации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Строка - Текст документации по модулю, если пустая строка, публикация не выполняется
//
Функция ДокументацияПоМодулю(ДанныеМодуля, Ошибки) Экспорт
	
	ПомощникГенерацииДокументации.УстановитьПараметрыГенерации(Новый Структура("ЭкранироватьКавычки", Ложь));

	Строки = ПомощникГенерацииДокументации.СформироватьОписаниеМодуляПоШаблонам(ДанныеМодуля, Шаблоны, СимволыЗамены);
	
	Возврат СтрСоединить(Строки, " ");
	
КонецФункции

// ДокументацияКонстанты
//
// Параметры:
//   МассивКонстант - Массив - Массив структур описаний констант
//						Имя - Имя константы
//						Тип - Тип значения константы
//						Описание - Описание константы
//						Подсистема - Описание подсистем, которой принадлежит константа. см ГенераторДокументации.ПолучитьСтруктуруПодсистем
//   Ошибки - Массив - Коллекция ошибок генерации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Строка - Текст документации по модулю, если пустая строка, публикация не выполняется
//
Функция ДокументацияКонстанты(МассивКонстант, Ошибки) Экспорт
	
	ПомощникГенерацииДокументации.УстановитьПараметрыГенерации(Новый Структура("ЭкранироватьКавычки", Ложь));

	Строки = ПомощникГенерацииДокументации.СформироватьОписаниеКонстантПоШаблонам(МассивКонстант, Шаблоны, СимволыЗамены);
	
	Возврат СтрСоединить(Строки, " ");
	
КонецФункции

#КонецОбласти

#Область Публикация

// ОпубликоватьРаздел
//
// Параметры:
//   Раздел - СтрокаТаблицыЗначений - Описание публикуемого раздела
//				* Имя - Имя страницы/раздела
//				* Родитель - Родитель страницы, ссылку на строку этой же таблицы
//				* Содержимое - Содержимое страницы
//				* Идентификатор - Служебное поле, можно использовать при публикации
//   ОбъектыРаздела - СтрокаТаблицыЗначений - Массив описаний объектов раздела
//				* Имя - Имя объекта
//				* Родитель - Родитель страницы, ссылку на строку этой же таблицы
//				* Содержимое - Содержимое страницы
//				* Идентификатор - Служебное поле, можно использовать при публикации
//   ОшибкиПубликации - Массив - Коллекция ошибок публикации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Булево - Признак успешности
//
Функция ОпубликоватьРаздел(Раздел, ОбъектыРаздела, ОшибкиПубликации) Экспорт
	
	Если НЕ ПроверкаВозможностиПубликации(Раздел, ОшибкиПубликации) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Успешно = Истина;
	
	АдресРаздела = СоздатьРаздел(Раздел, ОшибкиПубликации);
		
	Для Каждого НоваяСтраница Из ОбъектыРаздела Цикл
		
		Попытка

			ИмяСтраницы = "Программный интерфейс: " + НоваяСтраница.Имя;

			АдресСтраницы = АдресПодчиненнойСтраницы(АдресРаздела, ИмяСтраницы);
			
			СоздатьОбновитьСтраницу(
				АдресСтраницы,
				СокрЛП(НоваяСтраница.Содержимое)
			);

			Сообщить("Создана/обновлена страница " + ИмяСтраницы);
			
		Исключение
			
			ОшибкиПубликации.Добавить("Ошибка создания страницы '" + ИмяСтраницы + "': " + ОписаниеОшибки());
			Успешно = Ложь;
			Прервать;
			
		КонецПопытки;
		
	КонецЦикла;
	
	Возврат Успешно;
	
КонецФункции

Функция ОпубликоватьФайлыКаталога(Каталог, Ошибки) Экспорт
	
	Если НЕ ПроверкаВозможностиПубликации(Неопределено, Ошибки) Тогда
		
		Возврат Ложь;
		
	КонецЕсли;

	Успешно = Истина;

	Для Каждого Файл Из НайтиФайлы(Каталог, "*", Ложь) Цикл
		
		Если Файл.ЭтоКаталог() Тогда
			
			АдресРаздела = АдресПодчиненнойСтраницы(АдресКорневойСтраницы, Файл.Имя);
			Успешно = Успешно И РекурсивнаяПубликацияФайловКаталога(АдресРаздела, Каталог, Ошибки);

		КонецЕсли;

	КонецЦикла;

	Возврат Успешно;

КонецФункции

#КонецОбласти

#Область Настройки

// Производит чтение настроек из конфигурационного файла и сохраняет их в свойствах объекта
//
// Параметры:
//	 НастройкиСтенда - Объект.НастройкиСтенда - Объект, содержащий информацию конфигурационного файла
//
// Возвращаемое значение:
//	Строка - описание возникших ошибок
Функция ПрочитатьНастройки(НастройкиСтенда) Экспорт
	
	ТекстОшибки = "";
	
	НастройкиConfluence = НастройкиСтенда.Настройка("AutodocGen\НастройкиConluence");
	Если ЗначениеЗаполнено(НастройкиConfluence) Тогда
		
		Попытка
			
			ПодключениеConfluence = confluence.ОписаниеПодключения(НастройкиConfluence["АдресСервера"], НастройкиConfluence["Пользователь"], НастройкиConfluence["Пароль"]);
			ПространствоConflunece = НастройкиConfluence["Пространство"];
			КорневаяСтраницаConflunece = НастройкиConfluence["КорневаяСтраница"];
			АнализироватьТолькоПотомковПодсистемы = Строка(НастройкиConfluence["АнализироватьТолькоПотомковПодсистемы"]);
			
			Если НЕ (ЗначениеЗаполнено(ПространствоConflunece) И ЗначениеЗаполнено(КорневаяСтраницаConflunece)) Тогда
				
				ВызватьИсключение "Некорректные настройки пространства и корневой страницы confluence";
				
			КонецЕсли;
			
			Шаблоны = ПомощникГенерацииДокументации.ЗагрузитьШаблоны(НастройкиConfluence["ПутьКШаблонам"], "Шаблоны_conluence.json");
			
		Исключение
			
			ТекстОшибки = "Ошибка установки соединения с сервером confluence: " + ОписаниеОшибки();
			
		КонецПопытки;
		
	Иначе
		
		ТекстОшибки = "Отсутствуют настройки подключения к confluence";
		
	КонецЕсли;
	
	Возврат ТекстОшибки;
	
КонецФункции

#КонецОбласти

#Область Служебные

Функция ПроверкаВозможностиПубликации(Раздел, ОшибкиПубликации)
	
	Если АдресКорневойСтраницы = Неопределено Тогда
		
		Идентификатор = Confluence.НайтиСтраницуПоИмени(ПодключениеConfluence, ПространствоConflunece, КорневаяСтраницаConflunece);
		
		АдресКорневойСтраницы = confluence.АдресСтраницы(ПространствоConflunece, КорневаяСтраницаConflunece, Идентификатор);
		
	КонецЕсли;
	
	Если ПустаяСтрока(АдресКорневойСтраницы.Идентификатор) Тогда
		
		ОшибкиПубликации.Добавить("В пространстве отсутствует корневая страница документации '" + КорневаяСтраницаConflunece + "'");
		Возврат Ложь;
		
	КонецЕсли;
	
	Если Раздел <> Неопределено И СоздатьРаздел(Раздел, ОшибкиПубликации) = Неопределено Тогда
		
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция СоздатьРаздел(Раздел, ОшибкиПубликации)
	
	Если Раздел = Неопределено Тогда
		
		Возврат АдресКорневойСтраницы;
		
	КонецЕсли;

	Если Раздел.Родитель <> Неопределено И НЕ ЗначениеЗаполнено(Раздел.Родитель.Идентификатор) Тогда

		ОшибкиПубликации.Добавить("Создание страницы подсистемы '" + Раздел.Имя + "' невозможно, т.к. не создана страница раздела");
		Возврат Неопределено;

	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Раздел.Идентификатор) Тогда
		
		Если Раздел.Родитель = Неопределено Тогда
			
			Раздел.Идентификатор = АдресПодчиненнойСтраницы(АдресКорневойСтраницы, Раздел.Имя);
			
		Иначе
			
			Раздел.Идентификатор = АдресПодчиненнойСтраницы(Раздел.Родитель.Идентификатор, Раздел.Имя);
			
		КонецЕсли;

		Попытка
			
			НайтиСоздатьРаздел(Раздел.Идентификатор, ОписаниеРаздела(Раздел), ОшибкиПубликации);
			
		Исключение
			
			ОшибкиПубликации.Добавить("Ошибка создания страницы '" + Раздел.Имя + "': " + ОписаниеОшибки());
			
			Возврат Неопределено;
			
		КонецПопытки;

	КонецЕсли;
			
	Возврат Раздел.Идентификатор;
	
КонецФункции

Функция НайтиСоздатьРаздел(АдресРаздела, Содержимое, Ошибки)

	Если НЕ ПустаяСтрока(АдресРаздела.Идентификатор) Тогда
		
		Возврат АдресРаздела.Идентификатор;
		
	КонецЕсли;
	
	АдресРаздела.Идентификатор = Confluence.НайтиСтраницуПоИмени(
												ПодключениеConfluence, 
												АдресРаздела.КодПространства, 
												АдресРаздела.ИмяСтраницы);
												
	Если НЕ ПустаяСтрока(АдресРаздела.Идентификатор) Тогда
		
		Возврат АдресРаздела.Идентификатор;
		
	КонецЕсли;
	
	Попытка
		
		Confluence.Создать(
			ПодключениеConfluence,
			АдресРаздела,
			Содержимое);

		Сообщить("Создан раздел " + АдресРаздела.ИмяСтраницы);
		
	Исключение
		
		Ошибки.Добавить("Ошибка создания страницы '" + АдресРаздела.ИмяСтраницы + "': " + ОписаниеОшибки());
		Возврат Неопределено;
		
	КонецПопытки;

	Возврат АдресРаздела.Идентификатор;

КонецФункции

Функция СоздатьОбновитьСтраницу(Знач Адрес, Знач Содержимое)
	
	Возврат Confluence.СоздатьИлиОбновить(
		ПодключениеConfluence,
		Адрес,
		Содержимое,
		ОбновлятьИзмененныеСтраницы);

КонецФункции

Функция АдресПодчиненнойСтраницы(АдресРодителя, ИмяСтраницы)

	АдресСтраницы = confluence.АдресСтраницы(АдресРодителя.КодПространства, ИмяСтраницы, , АдресРодителя.Идентификатор);
	
	Возврат АдресСтраницы;
	
КонецФункции

Функция ТекстФайла(ИмяФайла)
	
	Чтение = Новый ЧтениеТекста(ИмяФайла, КодировкаТекста.UTF8);
	Содержимое = Чтение.Прочитать();
	Чтение.Закрыть();

	Возврат Содержимое;
	
КонецФункции

Функция ОписаниеРаздела(Раздел)
	
	Если Раздел = Неопределено Тогда
		Описание = "";
	Иначе
		Описание = ПомощникГенерацииДокументации.ОбработатьСтроку(Раздел.Содержимое, СимволыЗамены);
	КонецЕсли;

	Если Раздел = Неопределено ИЛИ Раздел.Родитель = Неопределено Тогда
		Возврат СтрШаблон(Шаблоны.ШаблонСтраницыРаздела, Описание);
	Иначе
		Возврат СтрШаблон(Шаблоны.ШаблонСтраницыПодсистемы, Описание);
	КонецЕсли;
	
КонецФункции

Функция РекурсивнаяПубликацияФайловКаталога(АдресРодителя, Каталог, Ошибки)

	Для Каждого Файл Из НайтиФайлы(Каталог, "*", Ложь) Цикл
		
		Если Файл.ЭтоКаталог() Тогда
			
			АдресРаздела = АдресПодчиненнойСтраницы(АдресРодителя, Файл.Имя);
			
			НайтиСоздатьРаздел(АдресРаздела, ОписаниеРаздела(Неопределено), Ошибки);

			РекурсивнаяПубликацияФайловКаталога(АдресРаздела, Файл.ПолноеИмя, Ошибки);

		ИначеЕсли СтрСравнить(Файл.Расширение, ".html") = 0 Тогда

			АдресСтраницы = АдресПодчиненнойСтраницы(АдресРодителя, Файл.ИмяБезРасширения);
			СоздатьОбновитьСтраницу(АдресСтраницы, ТекстФайла(Файл.ПолноеИмя));

		ИначеЕсли СтрСравнить(Файл.Расширение, ".md") = 0 ИЛИ СтрСравнить(Файл.Расширение, ".markdown") = 0 Тогда
			
			АдресСтраницы = АдресПодчиненнойСтраницы(АдресРодителя, Файл.ИмяБезРасширения);
			
			Содержимое = ТекстФайла(Файл.ПолноеИмя);
			
			Содержимое = СтрЗаменить(Содержимое, "\", "\\");
			
			Содержимое = Новый Структура("Значение, Формат", Содержимое, "markdown");
			
			СоздатьОбновитьСтраницу(АдресСтраницы, Содержимое);
			
		Иначе
			
			Сообщить("Файл %1 пропущен, его публикация не поддерживается");

		КонецЕсли;
		
	КонецЦикла;

	Возврат Истина;

КонецФункции

#КонецОбласти

///////////////////////////////////////////////////////////////////

СимволыЗамены = Новый Соответствие;
СимволыЗамены.Вставить("\", "\\");
СимволыЗамены.Вставить("&", "&amp;");
СимволыЗамены.Вставить("<", "&lt;");
СимволыЗамены.Вставить(">", "&gt;");
СимволыЗамены.Вставить(Символ(8211), "&ndash;");
СимволыЗамены.Вставить(Символ(8212), "&mdash;");
// СимволыЗамены.Вставить(Символы.ПС, "\n");
// СимволыЗамены.Вставить(Символ(13), "\n");
СимволыЗамены.Вставить(Символы.Таб, "    ");

ОбновлятьИзмененныеСтраницы = Истина; // в параметры выносить не будем... пока

