///////////////////////////////////////////////////////////////////////////////)
//
// Служебный модуль с методами общего назначения для приложения
//
///////////////////////////////////////////////////////////////////////////////

#Использовать tempfiles
#Использовать 1commands
#Использовать bsl-parser

Процедура ПроверитьПараметрыКоманды(ПараметрыКоманды) Экспорт
	
	Ошибки = Новый Массив();

	Если ПараметрыКоманды.Свойство("КаталогИсходныхФайлов") Тогда
		
		ПроверкаСуществующийКаталог(ПараметрыКоманды.КаталогИсходныхФайлов, Ошибки, "исходных файлов");
		
	КонецЕсли;
	
	Если ПараметрыКоманды.Свойство("КаталогКонфигурации") Тогда
		
		ПроверкаСуществующийКаталог(ПараметрыКоманды.КаталогКонфигурации, Ошибки, "конфигурации");
		
	КонецЕсли;
	
	Если ПараметрыКоманды.Свойство("ИсходныйФайл") Тогда
		
		ПроверкаСуществующийФайл(ПараметрыКоманды.ИсходныйФайл, Ошибки, ".bsl", "модуля");
		
	КонецЕсли;	
	
	ОбработатьМассивОшибок(Ошибки, "Не корректные входные параметры");
	
КонецПроцедуры

Процедура ОбработатьМассивОшибок(Ошибки, Сообщение)

	Если Ошибки.Количество() Тогда
		
		Лог = МенеджерПриложения.ПолучитьЛог();
		Лог.Ошибка(Сообщение);
		Лог.Ошибка(СтрСоединить(Ошибки, Символы.ПС));

		ЗавершитьРаботу(1);
		
	КонецЕсли;

КонецПроцедуры

Функция ПроверкаСуществующийКаталог(Путь, Ошибки, Пояснение)

	Если НЕ ЗначениеЗаполнено(Путь) Тогда
			
		Ошибки.Добавить("Не указан каталог" + Пояснение);
		Возврат Ложь;
		
	КонецЕсли;
	
	Файл = Новый Файл(Путь);

	Если Не Файл.Существует() Тогда

		Ошибки.Добавить(СтрШаблон("Каталог %1 '%2' не существует", Пояснение, Путь));
		Возврат Ложь;
		
	ИначеЕсли НЕ Файл.ЭтоКаталог() Тогда

		Ошибки.Добавить(СтрШаблон("Путь к каталогу %1 является файлом '%2'", Пояснение, Путь));
		Возврат Ложь;
		
	Иначе
		
		Возврат Истина;

	КонецЕсли;

КонецФункции

Функция ПроверкаСуществующийФайл(Путь, Ошибки, Расширение, Пояснение)

	Если НЕ ЗначениеЗаполнено(Путь) Тогда
			
		Ошибки.Добавить("Не указан файл" + Пояснение);
		Возврат Ложь;
		
	КонецЕсли;
	
	Файл = Новый Файл(Путь);

	Если Не Файл.Существует() Тогда

		Ошибки.Добавить(СтрШаблон("Файл %1 '%2' не существует", Пояснение, Путь));
		Возврат Ложь;
		
	ИначеЕсли Файл.ЭтоКаталог() Тогда

		Ошибки.Добавить(СтрШаблон("Путь к файлу %1 является каталогом '%2'", Пояснение, Путь));
		Возврат Ложь;
		
	ИначеЕсли СтрСравнить(Файл.Расширение, Расширение) <> 0 Тогда

		Ошибки.Добавить(СтрШаблон("Файл %1 имеет не корректно расширение '%2'", Пояснение, Путь));
		Возврат Ложь;
		
	Иначе
		
		Возврат Истина;

	КонецЕсли;

КонецФункции

Процедура ДополнитьПараметры(ПараметрыКоманды) Экспорт

	РаботаСКаталогом = ПараметрыКоманды.Свойство("КаталогИсходныхФайлов");
	
	Если РаботаСКаталогом И НЕ ПараметрыКоманды.Свойство("КаталогКонфигурации") Тогда
		
		Если ПараметрыКоманды.ФорматEDT Тогда
			КаталогКонфигурации = ОбъединитьПути(ПараметрыКоманды.КаталогИсходныхФайлов, "configuration", "src");
		Иначе
			КаталогКонфигурации = ОбъединитьПути(ПараметрыКоманды.КаталогИсходныхФайлов, "src", "configuration");
		КонецЕсли;
		
		ПараметрыКоманды.Вставить("КаталогКонфигурации", КаталогКонфигурации);

		Ошибки = Новый Массив();
		ПроверкаСуществующийКаталог(КаталогКонфигурации, Ошибки, "конфигурации");
		ОбработатьМассивОшибок(Ошибки, "Не корректные входные параметры");

	КонецЕсли;
	
	Если РаботаСКаталогом Тогда
		КаталогНастроек = ПараметрыКоманды.КаталогИсходныхФайлов;
	Иначе
		Файл = Новый Файл(ПараметрыКоманды.ИсходныйФайл);
		КаталогНастроек = Файл.Путь;
	КонецЕсли;

	НастройкиСтенда = ПрочитатьНастройкиСтенда(КаталогНастроек, ПараметрыКоманды.ФайлНастроек);
	НастройкиАнализаИзменений = ПрочитатьНастройкиАнализаИзменений(
		НастройкиСтенда, 
		КаталогНастроек, 
		ПараметрыКоманды.Свойство("РежимGit") И ПараметрыКоманды.РежимGit);

	ПараметрыКоманды.Вставить("НастройкиСтенда", НастройкиСтенда);
	ПараметрыКоманды.Вставить("НастройкиАнализаИзменений", НастройкиАнализаИзменений);

КонецПроцедуры

Функция ПрочитатьНастройкиСтенда(КаталогИсходныхФайлов, АдресКонфигурационногоФайла = Неопределено) Экспорт

	Если НЕ ЗначениеЗаполнено(АдресКонфигурационногоФайла) Тогда

		АдресКонфигурационногоФайла = КаталогИсходныхФайлов;

	КонецЕсли;

	НастройкиСтенда = Новый НастройкиСтенда();
	НастройкиСтенда.Инициализация(АдресКонфигурационногоФайла);

	Если НастройкиСтенда.ЭтоНовый() Тогда

		МенеджерПриложения.ПолучитьЛог().Ошибка("Конфигурационный файл не обнаружен в каталоге '%1'", КаталогИсходныхФайлов);
		ЗавершитьРаботу(1);
		Возврат Неопределено;

	КонецЕсли;

	Возврат НастройкиСтенда;

КонецФункции

Функция ПрочитатьНастройкиАнализаИзменений(НастройкиСтенда, КаталогИсходныхФайлов, Анализировать = Неопределено) Экспорт

	НастройкиАнализаИзменений = Новый Структура();
	НастройкиАнализаИзменений.Вставить("Анализировать", Анализировать);
	Если НастройкиАнализаИзменений.Анализировать = Неопределено Тогда

		НастройкиАнализаИзменений.Анализировать = Ложь;

	КонецЕсли;

	Если НЕ НастройкиАнализаИзменений.Анализировать Тогда

		Возврат НастройкиАнализаИзменений;

	КонецЕсли;

	ПоследняяВерсия = НастройкиСтенда.Настройка("AutodocGen\ПоследнийОбработанныйКоммит");
	Если НЕ ЗначениеЗаполнено(ПоследняяВерсия) Тогда

		ПоследняяВерсия = "";

	КонецЕсли;

	ФайлЛог = ВременныеФайлы.НовоеИмяФайла("log");
	КомандаGit = Новый КомандныйФайл();
	КомандаGit.ДобавитьКоманду(СтрШаблон("cd /d ""%1""", КаталогИсходныхФайлов));
	КомандаGit.ДобавитьКоманду("git pull origin");
	КомандаGit.ДобавитьКоманду(СтрШаблон(
				"git log %1 --pretty=short --name-only --no-merges --all -- *CommonModule/*/Module.txt* *CommonModules/*/Module.bsl* *Ext/ManagerModule.bsl* > ""%2"" ",
					?(Не ПустаяСтрока(ПоследняяВерсия), ПоследняяВерсия + "..HEAD", "--after='2001-01-01'"),
					ФайлЛог));

	КодВозврата = КомандаGit.Исполнить();
	ВыводКоманды = КомандаGit.ПолучитьВывод();

	Если КодВозврата <> 0 Тогда

		ТекстОшибки = СтрШаблон("Ошибка получения изменений: код ошибки %1%2Вывод%3", КодВозврата, Символы.ПС, ВыводКоманды);
		МенеджерПриложения.ПолучитьЛог().Ошибка(ТекстОшибки);
		ЗавершитьРаботу(1);
		Возврат Неопределено;

	КонецЕсли;

	СоставЛога = РазобратьФайлЛога(ФайлЛог, КаталогИсходныхФайлов);

	НастройкиАнализаИзменений.Вставить("ИзмененныеФайлы", СоставЛога.ИзмененныеФайлы);
	НастройкиАнализаИзменений.Вставить("ИдентификаторКоммита", СоставЛога.ИдентификаторКоммита);

	Возврат НастройкиАнализаИзменений;

КонецФункции

Функция ПолучитьГенераторДокументации(НастройкиСтенда, Формат = Неопределено) Экспорт

	Если НЕ ЗначениеЗаполнено(Формат) Тогда

		Формат = "confluence";

	КонецЕсли;

	Попытка

		ГенераторДокументации = Новый ("ГенераторДокументации_" + Формат);

	Исключение

		ТекстОшибки = СтрШаблон("Ошибка создания объект генератора документации в формате '%1': %2", Формат, ОписаниеОшибки());
		МенеджерПриложения.ПолучитьЛог().Ошибка(ТекстОшибки);
		ЗавершитьРаботу(1);

		Возврат Неопределено;

	КонецПопытки;

	ТекстОшибки = ГенераторДокументации.ПрочитатьНастройки(НастройкиСтенда);
	Если Не ПустаяСтрока(ТекстОшибки) Тогда

		ТекстОшибки = СтрШаблон("Ошибка чтения настроек генератора документации в формате '%1': %2", Формат, ТекстОшибки);
		МенеджерПриложения.ПолучитьЛог().Ошибка(ТекстОшибки);
		ЗавершитьРаботу(1);
		Возврат Неопределено;

	КонецЕсли;

	Возврат ГенераторДокументации;

КонецФункции

Функция ПолучитьПарсерКонфигурации(Знач ПарсерКонфигурации = Неопределено) Экспорт

	Если ПарсерКонфигурации = Неопределено Тогда

		ПарсерКонфигурации = Новый РазборСтруктурыКонфигурации1С;

	КонецЕсли;

	Возврат ПарсерКонфигурации;

КонецФункции

///////////////////////////////////////////////////////////////////////////////

Функция РазобратьФайлЛога(ИмяФайла, КаталогРепозитория)

	Файл = Новый ТекстовыйДокумент;
	Файл.Прочитать(ИмяФайла, "UTF-8");
	КолСтрок = Файл.КоличествоСтрок();

	ИдентификаторКоммита = "";
	ИзмененныеФайлы = Новый Массив;

	Для Ит = 1 По КолСтрок Цикл

		СтрокаМодуля = Файл.ПолучитьСтроку(Ит);
		Если СтрНачинаетсяС(СтрокаМодуля, "commit") Тогда

			Если ПустаяСтрока(ИдентификаторКоммита) Тогда

				ИдентификаторКоммита = СокрЛП(Сред(СтрокаМодуля, СтрДлина("commit") + 1));

			КонецЕсли;

			Продолжить;

		Иначе

			Попытка

				ФайлМодуля = Новый Файл(ОбъединитьПути(КаталогРепозитория, СтрокаМодуля));

				Если ФайлМодуля.Существует() И НЕ ФайлМодуля.ЭтоКаталог() Тогда

					ИзмененныеФайлы.Добавить(НРег(ФайлМодуля.ПолноеИмя));

				КонецЕсли;

			Исключение

				// это мусорные строки

			КонецПопытки;

		КонецЕсли;

	КонецЦикла;

	Возврат Новый Структура("ИзмененныеФайлы, ИдентификаторКоммита", ИзмененныеФайлы, ИдентификаторКоммита);

КонецФункции

Функция ПолноеИмяФайла(ИмяФайла) Экспорт

	Файл = Новый Файл(ИмяФайла);
	Возврат Файл.ПолноеИмя;

КонецФункции


Процедура ЗаписатьФайл(ИмяФайла, Содержимое) Экспорт

	Запись = Новый ЗаписьТекста(ИмяФайла, КодировкаТекста.UTF8);
	Запись.Записать(Содержимое);
	Запись.Закрыть();

КонецПроцедуры

Функция ОписаниеМодуля(ИмяФайла) Экспорт

	Модуль = Новый Структура(СтрСоединить(СтруктурыОписаний.РеквизитыМодуляКонфигурации(), ", "));
	Модуль.ПутьКФайлу = ИмяФайла;
	Модуль.ТипМодуля = ТипыМодуля.ТипМодуляПоИмениФайла(Модуль.ПутьКФайлу);
	Модуль.Родитель = Новый Структура(СтрСоединить(СтруктурыОписаний.РеквизитыОписанияОбъектовКонфигурации(), ", "));
	Модуль.Родитель.Наименование = "Модуль";
	
	СодержимоеМодуля = ЧтениеМодулей.ПрочитатьМодуль(Модуль.ПутьКФайлу, Модуль);
	
	Модуль.Вставить("Содержимое", СодержимоеМодуля.Содержимое);
	Модуль.Вставить("НаборБлоков", СодержимоеМодуля.БлокиМодуля);
	
	Возврат Модуль;
	
КонецФункции