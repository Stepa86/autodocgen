Перем ПараметрыГенерации;

Функция ЗагрузитьШаблоны(ПутьКШаблонам, ШаблоныПоУмолчанию) Экспорт

	Если НЕ ЗначениеЗаполнено(ПутьКШаблонам) Тогда

		ПутьКШаблонам = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "additional", ШаблоныПоУмолчанию);

	КонецЕсли;

	Текст = Новый ТекстовыйДокумент;
	Текст.Прочитать(ПутьКШаблонам, "UTF-8");
	СодержимоеШаблона = Текст.ПолучитьТекст();
	ПарсерJSON = Новый ПарсерJSON;
	ПредШаблоны = ПарсерJSON.ПрочитатьJSON(СодержимоеШаблона);
	Шаблоны = Новый Структура;
	Для Каждого Элемент Из ПредШаблоны Цикл

		Шаблоны.Вставить(Элемент.Ключ, СтрЗаменить(Элемент.Значение, """", "\"""));

	КонецЦикла;

	Возврат Шаблоны;

КонецФункции

Функция СоздатьКаталогРаздела(Знач БазовыйКаталог, Знач Раздел) Экспорт

	ЧастиПути = Новый Массив;

	Пока Раздел <> Неопределено Цикл
		ЧастиПути.Добавить(Раздел.Имя);
		Раздел = Раздел.Родитель;
	КонецЦикла;

	Каталог = БазовыйКаталог;

	Для Инд = 1 По ЧастиПути.Количество() Цикл

		Каталог = ОбъединитьПути(Каталог, ЧастиПути[ЧастиПути.Количество() - Инд]);
		СоздатьКаталог(Каталог);

	КонецЦикла;

	Возврат Каталог;

КонецФункции

Функция ПроверкаВозможностиПубликацииВКаталог(БазовыйКаталог, Раздел, ОшибкиПубликации) Экспорт

	Каталог = Новый Файл(БазовыйКаталог);

	Если НЕ Каталог.Существует() ИЛИ НЕ Каталог.ЭтоКаталог() Тогда

		ОшибкиПубликации.Добавить("Отсутствует каталог размещения автодокументации: '" + Каталог.ПолноеИмя + "'");
		Возврат Ложь;

	КонецЕсли;

	Попытка

		СоздатьКаталогРаздела(БазовыйКаталог, Раздел);

	Исключение

		ОшибкиПубликации.Добавить("Ошибка создания каталога '" + Раздел.Имя + "': " + ОписаниеОшибки());
		Возврат Ложь;

	КонецПопытки;

	Возврат Истина;

КонецФункции

Функция СобратьИерархиюПоПодсистемам(ОбъектыПодсистем) Экспорт

	Иерархия = Новый Соответствие;

	Для Каждого Объект Из ОбъектыПодсистем Цикл

		Если Объект.Подсистема = Неопределено ИЛИ ПустаяСтрока(Объект.Подсистема.ИмяРаздела) Тогда

			Сообщить(СтрШаблон("Объект %1 не включен в подсистемы", Объект.Имя));
			Продолжить;

		КонецЕсли;

		ДанныеПодсистемы = Объект.Подсистема;

		Раздел = ДанныеПодсистемы.ИмяРаздела;
		Подсистема = ДанныеПодсистемы.ИмяПодсистемы;

		ДанныеРаздела = Иерархия[Раздел];

		Если ДанныеРаздела = Неопределено Тогда

			ДанныеРаздела = Новый Соответствие;
			Иерархия[Раздел] = ДанныеРаздела;

		КонецЕсли;

		ДанныеПодсистемы = ДанныеРаздела[Подсистема];
		Если ДанныеПодсистемы = Неопределено Тогда

			ДанныеПодсистемы = Новый Массив;
			ДанныеРаздела[Подсистема] = ДанныеПодсистемы;

		КонецЕсли;

		ДанныеПодсистемы.Добавить(Объект);

	КонецЦикла;

	Возврат Иерархия;

КонецФункции

Функция СформироватьОписаниеМодуляПоШаблонам(ДанныеМодуля, Шаблоны, СимволыЗамены) Экспорт

	ЧастиТекста = Новый Массив;
	ТекущаяОбласть = "";
	ОбластьОткрыта = Ложь;

	Для Каждого ОписаниеМетода Из ДанныеМодуля.Методы Цикл

		Если ОписаниеМетода.ИмяРаздела <> ТипыОбласти.РазделПрограммныйИнтерфейс Тогда

			Продолжить;

		КонецЕсли;

		Если ТекущаяОбласть <> ОписаниеМетода.ИмяОбласти И ОбластьОткрыта Тогда

			ЧастиТекста.Добавить(Шаблоны.ШаблонСплиттерКонец);
			ОбластьОткрыта = Ложь;
			ТекущаяОбласть = "";

		КонецЕсли;

		Если ЗначениеЗаполнено(ОписаниеМетода.ИмяОбласти) И НЕ ОбластьОткрыта Тогда

			ОбластьОткрыта = Истина;
			ТекущаяОбласть = ОписаниеМетода.ИмяОбласти;
			ЧастиТекста.Добавить(СтрШаблон(Шаблоны.ШаблонСплиттерНачало, ОписаниеМетода.ИмяОбласти));

		КонецЕсли;

		ЧастиТекста.Добавить(СтрШаблон(Шаблоны.ШаблонЗаголовок, ОписаниеМетода.ИмяМетода));

		ЧастиТекста.Добавить(СтрШаблон(Шаблоны.ШаблонОписание, ОбработатьСтроку(ОписаниеМетода.Описание, СимволыЗамены)));

		Если ОписаниеМетода.ПараметрыМетода.Количество() Тогда

			ЧастиТекста.Добавить(Шаблоны.ШаблонШапкаТЧ);

			Ит = 0;
			Для Каждого Параметр Из ОписаниеМетода.ПараметрыМетода Цикл

				Ит = Ит + 1;
				ЧастиТекста.Добавить(СтрШаблон(Шаблоны.ШаблонСтрокаТЧ,
					Ит,
					Параметр.Имя,
					?(ЗначениеЗаполнено(Параметр.ЗначениеПоУмолчанию), "Нет", "Да"),
					Параметр.ТипПараметра,
					ОбработатьСтроку(Параметр.ОписаниеПараметра, СимволыЗамены)));

			КонецЦикла;

			ЧастиТекста.Добавить(Шаблоны.ШаблонПодвалТЧ);

		КонецЕсли;

		Если ОписаниеМетода.ТипБлока = ТипыБлоковМодуля.ЗаголовокФункции Тогда

			ЧастиТекста.Добавить(СтрШаблон(Шаблоны.ШаблонВозврат,
				ОписаниеМетода.ТипВозвращаемогоЗначения,
				ОбработатьСтроку(ОписаниеМетода.ОписаниеВозвращаемогоЗначения, СимволыЗамены)));

		КонецЕсли;

		Для Каждого Пример Из ОписаниеМетода.Примеры Цикл

			ЧастиТекста.Добавить(СтрШаблон(Шаблоны.ШаблонПример, ОбработатьСтроку(Пример, СимволыЗамены, Истина)));

		КонецЦикла;

	КонецЦикла;

	Если ОбластьОткрыта Тогда

		ЧастиТекста.Добавить(Шаблоны.ШаблонСплиттерКонец);

	КонецЕсли;

	Возврат ЧастиТекста;

КонецФункции

Функция СформироватьОписаниеКонстантПоШаблонам(МассивКонстант, Шаблоны, СимволыЗамены) Экспорт

	СтрокиОписания = Новый Массив;

	Иерархия = СобратьИерархиюПоПодсистемам(МассивКонстант);

	Для Каждого ДанныеРаздела Из Иерархия Цикл

		СтрокиОписания.Добавить(СтрШаблон(Шаблоны.ШаблонСплиттерНачало, ДанныеРаздела.Ключ));

		Для Каждого ДанныеПодсистемы Из ДанныеРаздела.Значение Цикл

			СтрокиОписания.Добавить(СтрШаблон(Шаблоны.ШаблонЗаголовокДляКонстант, ДанныеПодсистемы.Ключ));
			СтрокиОписания.Добавить(Шаблоны.ШаблонШапкаТЧДляКонстант);

			Для Каждого Константа Из ДанныеПодсистемы.Значение Цикл

				СтрокиОписания.Добавить(СтрШаблон(Шаблоны.ШаблонСтрокаТЧДляКонстант,
											Константа.Имя,
											Константа.Тип,
											ОбработатьСтроку(Константа.Описание, СимволыЗамены)));

			КонецЦикла;

			СтрокиОписания.Добавить(Шаблоны.ШаблонПодвалТЧ);

		КонецЦикла;

		СтрокиОписания.Добавить(Шаблоны.ШаблонСплиттерКонец);

	КонецЦикла;

	Возврат СтрокиОписания;

КонецФункции

Функция ОбработатьСтроку(Знач ВходнаяСтрока, СимволыЗамены, ДляCDATA = Ложь)

	Если ПараметрыГенерации.ЭкранироватьКавычки Тогда

		Если ДляCDATA Тогда

			СимволыЗамены.Вставить("""", "\""");

		Иначе

			СимволыЗамены.Вставить("""", "&quot;");

		КонецЕсли;

	КонецЕсли;

	Для Каждого СимволЗамены Из СимволыЗамены Цикл

		ВходнаяСтрока = СтрЗаменить(ВходнаяСтрока, СимволЗамены.Ключ, СимволЗамены.Значение);

	КонецЦикла;

	Возврат ВходнаяСтрока;

КонецФункции

Процедура УстановитьПараметрыГенерации(НовыеПараметрыГенерации) Экспорт
	
	ПараметрыГенерации = Новый Структура("ЭкранироватьКавычки", Истина);
	
	Для каждого Элемент Из НовыеПараметрыГенерации Цикл
		
		ПараметрыГенерации.Вставить(Элемент.Ключ, Элемент.Значение);
		
	КонецЦикла;

КонецПроцедуры

УстановитьПараметрыГенерации(Новый Структура);
