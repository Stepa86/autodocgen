//////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды
//
///////////////////////////////////////////////////////////////////////////////

Процедура ОписаниеКоманды(КомандаПриложения) Экспорт

	КомандаПриложения.Аргумент("PATH", "",
						"Каталог исходных файлов конфигурации 1С.
						|При использовании опции -g (--git) нужно передавать каталог репозитория")
						.Обязательный(Истина);

	КомандаПриложения.Опция("format f", "confluence",
						"Формат генерации документации. Поддерживается confluence, html, json, markdown")
						.ТПеречисление()
						.Перечисление("confluence", "confluence", "Документация в формате confluence")
						.Перечисление("html", "html", "Документация в формате html")
						.Перечисление("json", "JSON", "Документация в формате JSON")
						.Перечисление("markdown", "Markdown", "Документация в формате Markdown");

	КомандаПриложения.Опция("config c", "",
						"Путь к конфигурационному файлу. По умолчанию ищет в каталоге исходных файлов");

	КомандаПриложения.Опция("git g", Ложь,
						"Включает режим обработки изменений репозитория git");

	КомандаПриложения.Опция("errno e", Ложь,
						"Выполняет генерацию даже при наличии ошибок");

						КомандаПриложения.Опция("edt", Ложь,
						"Исходники хранятся в формате EDT");

	КомандаПриложения.Опция("push-manual", ,
						"Каталог ""ручной"" документации");

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт

	ПараметрыКоманды = ПолучитьСтруктуруПараметров(КомандаПриложения);

	ТекстОшибки = "";
	Успешно = ВыполнитьГенерациюДокументации(ПараметрыКоманды, ТекстОшибки);

	Если НЕ Успешно Тогда

		МенеджерПриложения.ПолучитьЛог().Ошибка(ТекстОшибки);
		ЗавершитьРаботу(1);

	КонецЕсли;

КонецПроцедуры

// Возвращает имя команды приложения
Функция ИмяКоманды() Экспорт

	Возврат "generate";

КонецФункции // ИмяКоманды

// Возвращает описание исполняемой команды
Функция КраткоеОписаниеКоманды() Экспорт

	Возврат "Выполняет генерацию документации на основании исходных файлов";

КонецФункции // ОписаниеКоманды

#Область Служебные

Функция ПолучитьСтруктуруПараметров(Знач КомандаПриложения)

	ПараметрыКоманды = Новый Структура;
	ПараметрыКоманды.Вставить("КаталогИсходныхФайлов", КомандаПриложения.ЗначениеАргумента("PATH"));
	ПараметрыКоманды.Вставить("Формат", КомандаПриложения.ЗначениеОпции("format"));
	ПараметрыКоманды.Вставить("ФорматEDT", КомандаПриложения.ЗначениеОпции("edt"));
	ПараметрыКоманды.Вставить("РежимGit", КомандаПриложения.ЗначениеОпции("git"));
	ПараметрыКоманды.Вставить("ГенерацияПриНаличииОшибок", КомандаПриложения.ЗначениеОпции("errno"));
	ПараметрыКоманды.Вставить("ФайлНастроек", КомандаПриложения.ЗначениеОпции("config"));
	ПараметрыКоманды.Вставить("КаталогДополнительнойДокументации", КомандаПриложения.ЗначениеОпции("push-manual"));

	Возврат ПараметрыКоманды;

КонецФункции

Функция ВыполнитьГенерациюДокументации(ПараметрыКоманды, ТекстОшибки)

	ОбщегоНазначения.ПроверитьПараметрыКоманды(ПараметрыКоманды);
	
	ОбщегоНазначения.ДополнитьПараметры(ПараметрыКоманды);

	КаталогИсходныхФайлов 		= ПараметрыКоманды.КаталогИсходныхФайлов;
	НастройкиСтенда 			= ПараметрыКоманды.НастройкиСтенда;
	НастройкиАнализаИзменений 	= ПараметрыКоманды.НастройкиАнализаИзменений;

	ТекущийКаталогИсходныхФайлов = ОбщегоНазначения.ПолноеИмяФайла(ПараметрыКоманды.КаталогКонфигурации);

	Конфигурация = РазборКонфигураций.ЗагрузитьКонфигурацию(ТекущийКаталогИсходныхФайлов);
	Конфигурация.ЗаполнитьПодсистемыОбъектовКонфигурации();
	Конфигурация.НайтиМодули();

	НастройкиГенератора = Новый Структура;

	НастройкиГенератора.Вставить("Парсер", Конфигурация);
	НастройкиГенератора.Вставить("НастройкиАнализаИзменений", НастройкиАнализаИзменений);
	НастройкиГенератора.Вставить("КаталогРуководства", ПараметрыКоманды.КаталогДополнительнойДокументации);

	ГенераторСодержимого = ОбщегоНазначения.ПолучитьГенераторДокументации(
		ПараметрыКоманды.НастройкиСтенда, 
		ПараметрыКоманды.Формат);
		
	ГенераторДокументации = Новый ГенераторДокументации(ГенераторСодержимого);

	РезультатГенерации = ГенераторДокументации.Сгенерировать(НастройкиГенератора);

	ЕстьОшибкиГенерации = НЕ РезультатГенерации.Успешно;

	ОшибкиГенерации = СтрСоединить(РезультатГенерации.Ошибки, Символы.ПС);
	ОшибкиПубликации = "";

	Если ПараметрыКоманды.ГенерацияПриНаличииОшибок ИЛИ НЕ ЕстьОшибкиГенерации Тогда

		РезультатПубликации = ГенераторДокументации.Опубликовать(РезультатГенерации);
		ОшибкиПубликации = СтрСоединить(РезультатПубликации.ОшибкиПубликации, Символы.ПС);

	КонецЕсли;

	Если ЕстьОшибкиГенерации Тогда
		ТекстОшибки = "Генерация документации завершилась ошибкой: " + ОшибкиГенерации;
	КонецЕсли;

	Если НЕ ПустаяСтрока(ОшибкиПубликации) Тогда
		ТекстОшибки = ТекстОшибки + Символы.ПС + "Публикация документации завершилась ошибкой: " + ОшибкиПубликации;
	КонецЕсли;

	Возврат ПустаяСтрока(ТекстОшибки);

КонецФункции

#КонецОбласти
