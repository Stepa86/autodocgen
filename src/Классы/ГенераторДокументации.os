Перем КаталогПубликацииДокументации;
Перем АнализироватьТолькоПотомковПодсистемы;

Перем ГенераторСодержимого;
Перем СозданныеОбъекты;
Перем СоздаваемыеРазделы;

// Генератор документации - формирует данные для формирования документации
// Управляет потоком генерации
// Генераторы содержимого - шаблонизаторы, формируют тексты документации на основании подготовленных данных

#Область ПрограммныйИнтерфейс

// Сгенерировать
// Генерирует структуру документации и проверяет на валидность в процессе генерации
//
// Параметры:
//	НастройкиГенератора - Структура - набор параметров, собранных в результате разбора конфигурации
//		* Парсер
//		* ОписаниеКонфигурации
//		* Модули
//		* ПодсистемыКонфигурации
//		* НастройкиАнализаИзменений
//
// Возвращаемое значение:
//	Структура - описание структуры сформированной документации
//		* Ошибки - строка - обязательное поле, содержащее описание полученных ошибок
Функция Сгенерировать(НастройкиГенератора) Экспорт

	// Сначала документация формируются локально, таким образом достигается целостность документации.
	// Если во время формирования одного из блоков документации возникла ошибка вся операция прерывается
	// Предварительно сформированные данные держаться в памяти

	Результат = ПодготовитьДанныеПубликации(НастройкиГенератора, Ложь);

	Возврат Результат;

КонецФункции

// СгенерироватьПоФайлу
// Генерирует документацию по модулю
//
// Параметры:
//	НастройкиГенератора - Структура - набор параметров, собранных в результате разбора конфигурации
//		* ОписаниеМодуля
//		* НастройкиАнализаИзменений
//
// Возвращаемое значение:
//	Структура - описание структуры сформированной документации
//		* Ошибки - строка - обязательное поле, содержащее описание полученных ошибок
Функция СгенерироватьПоФайлу(НастройкиГенератора) Экспорт

	Результат = СтруктураРезультатГенерации();

	Модуль = НастройкиГенератора.ОписаниеМодуля;

	Раздел = СоздаваемыеРазделы.Добавить();
	Раздел.Имя = "autodoc";

	Если НЕ ПроверитьМодуль(Модуль, Результат.Ошибки, Ложь) Тогда

		Возврат Результат;
		
	КонецЕсли;
	
	ДанныеМодуля = ДанныеМодуля(Модуль, Результат.Ошибки);

	Если Результат.Ошибки.Количество() Тогда

		Возврат Результат;

	ИначеЕсли ДанныеМодуля <> Неопределено Тогда

		Содержимое = ДокументацияПоМодулю(ДанныеМодуля, Результат.Ошибки);

		Если НЕ ПустаяСтрока(Содержимое) Тогда

			СтрокаОписания = Результат.СозданныеОбъекты.Добавить();
			СтрокаОписания.Содержимое = Содержимое;
			СтрокаОписания.Имя = ЧтениеОписанийБазовый.ПолноеИмяОбъекта(Модуль, Ложь);
			СтрокаОписания.Родитель = Раздел;
			СтрокаОписания.Тип = "Модуль";

		КонецЕсли;

	КонецЕсли;

	Результат.Успешно = Результат.Ошибки.Количество() = 0;

	Возврат Результат;

КонецФункции

// ПроверитьИсходники
//	Выполняет проверку описаний исходных файлов
// Параметры:
//	НастройкиГенератора - Структура - набор параметров, собранных в результате разбора конфигурации
//		* Парсер
//		* ОписаниеКонфигурации
//		* Модули
//		* ПодсистемыКонфигурации
//		* НастройкиАнализаИзменений
//
//  Возвращаемое значение:
//		Строка - описание полученных ошибок
//
Функция ПроверитьИсходники(НастройкиГенератора) Экспорт
	
	Результат = СтруктураРезультатГенерации();
	
	Модули = НастройкиГенератора.Парсер.ОписаниеКонфигурации().Модули;

	// Формирование данных для генерации доки по модулям
	Для Каждого Модуль Из Модули Цикл

		Если НЕ ОбрабатываемФайл(НастройкиГенератора, Модуль.ПутьКФайлу, Модуль) Тогда

			Продолжить;
	
		КонецЕсли;
	
		НастройкиГенератора.Парсер.ПрочитатьСодержимоеМодуля(Модуль);
		
		ПроверитьМодуль(Модуль, Результат.Ошибки);
		
		ДанныеМодуля(Модуль, Результат.Ошибки);
	
	КонецЦикла;

	// Формирование доки по константам
	Константы = ДанныеКонстант(НастройкиГенератора, Результат.Ошибки);
	
	Возврат СтрСоединить(Результат.Ошибки, Символы.ПС);
	
КонецФункции

// ПроверитьИсходники
//	Выполняет проверку описания модуля
// Параметры:
//	НастройкиГенератора - Структура - набор параметров, собранных в результате разбора конфигурации
//		* ОписаниеМодуля
//		* НастройкиАнализаИзменений
//
//  Возвращаемое значение:
//		Строка - описание полученных ошибок
//
Функция ПроверитьФайл(НастройкиГенератора) Экспорт

	Результат = СтруктураРезультатГенерации();
	
	Модуль = НастройкиГенератора.ОписаниеМодуля;
	
	ПроверитьМодуль(Модуль, Результат.Ошибки, Ложь);
	
	ДанныеМодуля(Модуль, Результат.Ошибки);

	Возврат СтрСоединить(Результат.Ошибки, Символы.ПС);
	
КонецФункции

#КонецОбласти

#Область ГенерацияДанных

Функция ДанныеМодуля(Модуль, Ошибки)

	Данные = Новый Структура("Методы, Имя", Новый Массив, ЧтениеОписанийБазовый.ПолноеИмяОбъекта(Модуль, Ложь));

	Для Каждого Блок Из Модуль.НаборБлоков Цикл

		Если Блок.ТипБлока <> ТипыБлоковМодуля.ЗаголовокПроцедуры
			И Блок.ТипБлока <> ТипыБлоковМодуля.ЗаголовокФункции Тогда

			Продолжить;

		КонецЕсли;

		ОписаниеМетода = ОписаниеМетода(Блок);

		ОшибкиМетода = ПроверитьМетод(ОписаниеМетода);

		Если ПустаяСтрока(ОшибкиМетода) Тогда

			Данные.Методы.Добавить(ОписаниеМетода);

		Иначе

			Ошибки.Добавить(Модуль.ПутьКФайлу + ": " + ОшибкиМетода);

		КонецЕсли;

	КонецЦикла;

	Возврат Данные;

КонецФункции

Функция ДанныеКонстант(НастройкиГенератора, Ошибки)

	Константы = Новый Массив;

	Для Каждого Константа Из НастройкиГенератора.Парсер.ОписаниеКонфигурации().НайтиОбъектыПоТипу("Константы") Цикл

		ЧтениеКонфигурации.ПрочитатьОписание(Константа);

		ОписаниеКонстанты = Новый Структура("Имя, Тип, Описание, Подсистема");

		ОписаниеКонстанты.Имя = Константа.Описание.Наименование;
		ОписаниеКонстанты.Тип = Константа.Описание.Тип;
		ОписаниеКонстанты.Описание = Константа.Описание.Пояснение;

		Подсистема = ПолучитьСтруктуруПодсистем(Константа.Подсистемы);

		ОписаниеКонстанты.Подсистема = Подсистема;

		Константы.Добавить(ОписаниеКонстанты);

		Если ПустаяСтрока(ОписаниеКонстанты.Описание) Тогда

			Ошибки.Добавить(ОписаниеКонстанты.Имя + ": Описание константы не заполнено.");

		КонецЕсли;

		Если ПустаяСтрока(ОписаниеКонстанты.Подсистема) Тогда

			Ошибки.Добавить(ОписаниеКонстанты.Имя + ": Константа не включена ни в одну подсистему.");

		КонецЕсли;

	КонецЦикла;

	Возврат Константы;

КонецФункции

#КонецОбласти //ГенерацияДанных

#Область Шаблонизатор

// ДокументацияПоМодулю
//
// Параметры:
//   ДанныеМодуля - Структура - Описание модуля, структура содержащая массив описаний методов, см. ГенераторДокументации.ОписаниеМетода
//   Ошибки - Массив - Коллекция ошибок генерации документации, сюда помещаем информацию о возникших ошибках
//
//  Возвращаемое значение:
//   Строка - Текст документации по модулю, если пустая строка, публикация не выполняется
//
Функция ДокументацияПоМодулю(ДанныеМодуля, Ошибки)

	Содержимое = ГенераторСодержимого.ДокументацияПоМодулю(ДанныеМодуля, Ошибки);

	Возврат Содержимое;

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
Функция ДокументацияКонстанты(ОписаниеКонстант, Ошибки)

	Содержимое = ГенераторСодержимого.ДокументацияКонстанты(ОписаниеКонстант, Ошибки);

	Возврат Содержимое;

КонецФункции

#КонецОбласти // Шаблонизатор

#Область Публикация

// Опубликовать
//
// Параметры:
//   РезультатГенерации - Структура - Результат функции Сгенерировать
//
//  Возвращаемое значение:
//   Структура - Результат публикации
//			* ОшибкиПубликации - Массив - коллекция возникших ошибок
//
Функция Опубликовать(РезультатГенерации) Экспорт

	Ошибки = Новый Массив;

	Успешно = Истина;

	Для Каждого Раздел Из РезультатГенерации.СоздаваемыеРазделы Цикл

		ОбъектыРаздела = РезультатГенерации.СозданныеОбъекты.НайтиСтроки(Новый Структура("Родитель", Раздел));

		Если Успешно И НЕ ГенераторСодержимого.ОпубликоватьРаздел(Раздел, ОбъектыРаздела, Ошибки) Тогда

			Прервать;

		КонецЕсли;

	КонецЦикла;

	Если Успешно Тогда

		ОбъектыРаздела = РезультатГенерации.СозданныеОбъекты.НайтиСтроки(Новый Структура("Родитель", Неопределено));

		ГенераторСодержимого.ОпубликоватьРаздел(Неопределено, ОбъектыРаздела, Ошибки);

	КонецЕсли;

	Возврат Новый Структура("ОшибкиПубликации", Ошибки);

КонецФункции

Функция ПроверитьОпубликованнуюДокументацию(НастройкиГенератора) Экспорт
	
	Результат = ПодготовитьДанныеПубликации(НастройкиГенератора, Истина);
	
	Если НЕ Результат.Успешно Тогда
		
		Возврат Результат;
		
	КонецЕсли;

	СоздаваемыеРазделы 	= Результат.СоздаваемыеРазделы;
	СоздаваемыеСтраницы = Результат.СозданныеОбъекты;
	
	ПрефиксИмени = ГенераторСодержимого.ПрефиксИмени("Модуль");
	
	Для каждого Строка Из СоздаваемыеСтраницы Цикл
		
		Строка.Имя = ПрефиксИмени + Строка.Имя;
		
	КонецЦикла;

	СтраницыКорень = ГенераторСодержимого.ПолучитьСтруктуруОпубликованныхСтраниц(Неопределено);

	УдаляемыеСтраницы = Новый Массив();
	
	Результат.Вставить("УдаляемыеСтраницы", УдаляемыеСтраницы);

	Результат.Вставить("Сообщения", Новый Массив());
	
	Для Каждого ИмеющийсяРаздел Из СтраницыКорень Цикл
		
		Если ИмеющийсяРаздел.Наименование = "Константы" Тогда
			
			Продолжить;

		КонецЕсли;
		
		НайденныйРаздел = СоздаваемыеРазделы.Найти(ИмеющийсяРаздел.Наименование, "Имя");
		
		Если НайденныйРаздел = Неопределено Тогда

			Результат.Сообщения.Добавить("Нужно удалить раздел " + ИмеющийсяРаздел.Представление + " и все подчиненные");
			
			УдаляемыеСтраницы.Добавить(ИмеющийсяРаздел);
			
		Иначе
			
			СтраницыРаздела = ГенераторСодержимого.ПолучитьСтруктуруОпубликованныхСтраниц(ИмеющийсяРаздел.Идентификатор);
			
			Для Каждого ИмеющаясяПодсистема Из СтраницыРаздела Цикл

				УдалитьПодсистему = Ложь;
				СтруктураПоиска = Новый Структура("Родитель, Имя", НайденныйРаздел, ИмеющаясяПодсистема.Наименование);
				НайденныеПодсистемыРаздела = СоздаваемыеРазделы.НайтиСтроки(СтруктураПоиска);
				ДочерниеСтраницыПодсистемы = Неопределено;

				Если НайденныеПодсистемыРаздела.Количество() <> 1 Тогда

					ДочерниеСтраницыПодсистемы = ГенераторСодержимого.ПолучитьСтруктуруОпубликованныхСтраниц(ИмеющаясяПодсистема.Идентификатор);

					УдалитьПодсистему = Истина;
					Для Каждого ИмеющаясяСтраница Из ДочерниеСтраницыПодсистемы Цикл
						
						// TODO: Проверка наименования работает только для confluence
						//		 При расширении на другие форматы необходимо доработать
						Если НЕ ЭтоПрограммноСформированнаяСтраница(ИмеющаясяСтраница.Наименование) Тогда

							УдалитьПодсистему = Ложь;
							Прервать;

						КонецЕсли;

					КонецЦикла;

					Если УдалитьПодсистему Тогда

						Результат.Сообщения.Добавить("Нужно удалить подсистему " + ИмеющаясяПодсистема.Представление + " и все подчиненные");
						УдаляемыеСтраницы.Добавить(ИмеющаясяПодсистема);
						Продолжить;

					КонецЕсли;
					
				КонецЕсли;

				Если ДочерниеСтраницыПодсистемы = Неопределено Тогда
				
					ДочерниеСтраницыПодсистемы = ГенераторСодержимого.ПолучитьСтруктуруОпубликованныхСтраниц(ИмеющаясяПодсистема.Идентификатор);
					
				КонецЕсли;
				
				Если НайденныеПодсистемыРаздела.Количество() Тогда
					Подсистема = НайденныеПодсистемыРаздела[0];
				Иначе
					Подсистема = Неопределено;
				КонецЕсли;

				Для Каждого ИмеющаясяСтраница Из ДочерниеСтраницыПодсистемы Цикл
					
					Если Подсистема <> Неопределено Тогда
						
						СтруктураПоиска = Новый Структура("Родитель, Имя", Подсистема, ИмеющаясяСтраница.Наименование);
						НайденныеСтраницыПодсистемы = СоздаваемыеСтраницы.НайтиСтроки(СтруктураПоиска);
						
					Иначе
					
						НайденныеСтраницыПодсистемы = Новый Массив;
						
					КонецЕсли;
						
					Если НайденныеСтраницыПодсистемы.Количество() <> 1 Тогда

						Если ЭтоПрограммноСформированнаяСтраница(ИмеющаясяСтраница.Наименование) Тогда

							Результат.Сообщения.Добавить("Нужно удалить страницу " + ИмеющаясяСтраница.Представление);
						
							УдаляемыеСтраницы.Добавить(ИмеющаясяСтраница);

						КонецЕсли;

					КонецЕсли;

				КонецЦикла;

			КонецЦикла;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Результат.Успешно = Результат.Ошибки.Количество() = 0;

	Возврат Результат;

КонецФункции

#КонецОбласти

#Область Служебные

Функция ЭтоПрограммноСформированнаяСтраница(ИмяСтарицы)
	
	ТипыСтраниц = СтрРазделить("Модуль,Руководство", ",");

	Для Каждого Тип Из ТипыСтраниц Цикл
		
		ПрефиксИмени = ГенераторСодержимого.ПрефиксИмени(Тип);
		
		Если НЕ ПустаяСтрока(ПрефиксИмени) И СтрНачинаетсяС(ИмяСтарицы, ПрефиксИмени) Тогда
			
			Возврат Истина;
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

Функция ПодготовитьДанныеПубликации(НастройкиГенератора, ТолькоСтруктура)

	Результат = СтруктураРезультатГенерации();

	// Формирование данных для генерации доки по модулям
	Для Каждого Модуль Из НастройкиГенератора.Парсер.ОписаниеКонфигурации().Модули Цикл
		
		Если НЕ ОбрабатываемФайл(НастройкиГенератора, Модуль.ПутьКФайлу, Модуль) Тогда

			Продолжить;
	
		КонецЕсли;
	
		Если ТолькоСтруктура Тогда
			
			СтрокаОписания = Результат.СозданныеОбъекты.Добавить();
			СтрокаОписания.Имя = ЧтениеОписанийБазовый.ПолноеИмяОбъекта(Модуль, Ложь);
			СтрокаОписания.Родитель = Раздел(Модуль, "");
			СтрокаОписания.Тип = "Модуль";

		Иначе

			Если Модуль.Содержимое = Неопределено Тогда

				НастройкиГенератора.Парсер.ПрочитатьСодержимоеМодуля(Модуль);
		
			КонецЕсли;
		
			Если НЕ ОбработатьМодуль(Модуль, НастройкиГенератора, Результат) Тогда

				Возврат Результат;
				
			КонецЕсли;
			
		КонецЕсли;

	КонецЦикла;
	
	// Формирование доки по константам
	СтрокаОписания = СозданныеОбъекты.Добавить();

	Если НЕ ТолькоСтруктура Тогда
		Константы = ДанныеКонстант(НастройкиГенератора, Результат.Ошибки);
		СтрокаОписания.Содержимое = ДокументацияКонстанты(Константы, Результат.Ошибки);
	КонецЕсли;
	
	СтрокаОписания.Имя = "Константы";
	СтрокаОписания.Родитель = Неопределено;
	СтрокаОписания.Тип = "Константа";

	Результат.Успешно = Результат.Ошибки.Количество() = 0;

	Возврат Результат;
КонецФункции

Функция ОбработатьМодуль(Модуль, НастройкиГенератора, Результат)

	Если НЕ ПроверитьМодуль(Модуль, Результат.Ошибки) Тогда

		Возврат Ложь;

	КонецЕсли;

	ДанныеМодуля = ДанныеМодуля(Модуль, Результат.Ошибки);

	Если Результат.Ошибки.Количество() Тогда

		Возврат Ложь;

	ИначеЕсли ДанныеМодуля <> Неопределено Тогда

		ТекстОшибки = Неопределено;

		Раздел = Раздел(Модуль, ТекстОшибки);

		Если НЕ ПустаяСтрока(ТекстОшибки) Тогда

			Результат.Ошибки.Добавить(Модуль.ПутьКФайлу + ": " + ТекстОшибки);
			Возврат Ложь;

		КонецЕсли;

		Содержимое = ДокументацияПоМодулю(ДанныеМодуля, Результат.Ошибки);

		Если НЕ ПустаяСтрока(Содержимое) Тогда

			СтрокаОписания = Результат.СозданныеОбъекты.Добавить();
			СтрокаОписания.Содержимое = Содержимое;
			СтрокаОписания.Имя = ЧтениеОписанийБазовый.ПолноеИмяОбъекта(Модуль, Ложь);
			СтрокаОписания.Родитель = Раздел;
			СтрокаОписания.Тип = "Модуль";

		КонецЕсли;

	КонецЕсли;

	Возврат Истина;

КонецФункции

Функция СтруктураРезультатГенерации()

	СозданныеОбъекты = Новый ТаблицаЗначений;
	СозданныеОбъекты.Колонки.Добавить("Имя"); 			// Имя страницы/раздела
	СозданныеОбъекты.Колонки.Добавить("Тип"); 			// Тип источника документации
	СозданныеОбъекты.Колонки.Добавить("Родитель"); 		// Родитель страницы, ссылку на строку этой же таблицы
	СозданныеОбъекты.Колонки.Добавить("Содержимое"); 	// Содержимое страницы
	СозданныеОбъекты.Колонки.Добавить("Идентификатор"); // Служебное поле, можно использовать при публикации

	СоздаваемыеРазделы = СозданныеОбъекты.Скопировать();

	Ошибки = Новый Массив();

	Результат = Новый Структура;
	Результат.Вставить("СозданныеОбъекты", СозданныеОбъекты);
	Результат.Вставить("СоздаваемыеРазделы", СоздаваемыеРазделы);
	Результат.Вставить("Ошибки", Новый Массив());
	Результат.Вставить("СодержимоеСтраницыКонстант", "");
	Результат.Вставить("Успешно", Ложь);

	Возврат Результат;

КонецФункции

Функция ПроверитьМодуль(Модуль, Ошибки, ЭтоМодульКонфигурации = Истина) Экспорт

	Если ЭтоМодульКонфигурации И НЕ ПроверитьПодсистемыМодуля(Модуль, Ошибки) Тогда

		Возврат Ложь;

	КонецЕсли;

	ТекстОшибки = ПроверитьРазделыМодуля(Модуль);

	Если НЕ ПустаяСтрока(ТекстОшибки) Тогда

		Ошибки.Добавить(Модуль.ПутьКФайлу + ": " + ТекстОшибки);
		Возврат Ложь;

	КонецЕсли;

	Возврат Истина;

КонецФункции

Функция ПроверитьПодсистемыМодуля(Модуль, Ошибки)

	Если Модуль.Родитель.Подсистемы = Неопределено Тогда

		Ошибки.Добавить(Модуль.ПутьКФайлу + ": не включен в состав подсистем");
		Возврат Ложь;

	КонецЕсли;

	СтруктураПодсистем = ПолучитьСтруктуруПодсистем(Модуль.Родитель.Подсистемы);

	Если ПустаяСтрока(СтруктураПодсистем.ИмяРаздела) Тогда

		Ошибки.Добавить(Модуль.ПутьКФайлу + ": ошибочная структура подсистем");
		Возврат Ложь;
		
	КонецЕсли;

	Возврат Истина;
		
КонецФункции

Функция ПроверитьРазделыМодуля(Модуль)

	Разделы = ОбязательныеРазделыМодуля(Модуль);

	Ошибки = Новый Массив();

	Если Модуль.НаборБлоков.Количество()
		И Модуль.ОписаниеМодуля.Разделы.Количество() <> Разделы.Количество() Тогда

		// TODO: Проверить, когда указаны не корректные имена разделов, но количество совпадает
		Для Каждого ТекРаздел Из Разделы Цикл

			Если Модуль.ОписаниеМодуля.Разделы.Найти(ТекРаздел) = Неопределено Тогда

				Ошибки.Добавить(" - отсутствует раздел " + ТекРаздел);

			КонецЕсли;

		КонецЦикла;

		Если Ошибки.Количество() Тогда

			ТекстОшибок = "В структуре модуля неполный состав разделов: " + СтрСоединить(Ошибки);

		Иначе

			ТекстОшибок = "В структуре модуля присутсвуют дубли разделов";

		КонецЕсли;

	КонецЕсли;

	Возврат "";

КонецФункции

Функция ПроверитьМетод(ОписаниеМетода)

	Если ПустаяСтрока(ОписаниеМетода.ИмяРаздела) Тогда

		Возврат СтрШаблон("Метод '%1' находится вне раздела", ОписаниеМетода.ИмяМетода);

	КонецЕсли;

	ОжидаемЭкспортныйМетод = ОписаниеМетода.ИмяРаздела = ТипыОбласти.РазделПрограммныйИнтерфейс
							 ИЛИ ОписаниеМетода.ИмяРаздела = ТипыОбласти.РазделСлужебныйПрограммныйИнтерфейс;

	Если НЕ ОписаниеМетода.Экспортный И ОжидаемЭкспортныйМетод Тогда

		Возврат СтрШаблон("В разделе %1 находится неэкспортный метод '%2'", ОписаниеМетода.ИмяРаздела, ОписаниеМетода.ИмяМетода);

	КонецЕсли;

	Если ОписаниеМетода.Экспортный И НЕ ОжидаемЭкспортныйМетод Тогда

		Возврат СтрШаблон("В разделе %1 находится экспортный метод '%2'", ОписаниеМетода.ИмяРаздела, ОписаниеМетода.ИмяМетода);

	КонецЕсли;

	Если ОписаниеМетода.ИмяРаздела = ТипыОбласти.РазделПрограммныйИнтерфейс Тогда

		Возврат ПроверитьОписаниеМетодаAPI(ОписаниеМетода);

	Иначе

		Возврат Неопределено;

	КонецЕсли;

КонецФункции

Функция ПроверитьОписаниеМетодаAPI(ОписаниеМетода)

	Ошибки = Новый Массив();

	Если НЕ ЗначениеЗаполнено(ОписаниеМетода.Описание) Тогда

		Ошибки.Добавить(СтрШаблон("У метода '%1' не заполнено описание", ОписаниеМетода.ИмяМетода));

	КонецЕсли;

	Если ОписаниеМетода.ПараметрыМетода.Количество() Тогда

		Ит = 0;

		Для Каждого Параметр Из ОписаниеМетода.ПараметрыМетода Цикл

			Ит = Ит + 1;

			Если НЕ ЗначениеЗаполнено(Параметр.ОписаниеПараметра) Тогда

				Ошибки.Добавить(СтрШаблон("У метода '%1' не заполнено описание параметра №%2 (%3)", ОписаниеМетода.ИмяМетода, Ит, Параметр.Имя));

			КонецЕсли;

		КонецЦикла;

	КонецЕсли;

	Если ОписаниеМетода.ТипБлока = ТипыБлоковМодуля.ЗаголовокФункции Тогда

		Если НЕ ЗначениеЗаполнено(ОписаниеМетода.ОписаниеВозвращаемогоЗначения) Тогда

			Ошибки.Добавить(СтрШаблон("У метода '%1' не заполнено описание возвращаемого значения", ОписаниеМетода.ИмяМетода));

		КонецЕсли;

	КонецЕсли;

	Возврат СтрСоединить(Ошибки, Символы.ПС);

КонецФункции

Функция ОписаниеМетода(Блок)

	Описание = Новый Структура;
	Описание.Вставить("ТипБлока", Блок.ТипБлока);
	Описание.Вставить("ИмяРаздела", Блок.ОписаниеБлока.ИмяРаздела);
	Описание.Вставить("ИмяОбласти", Блок.ОписаниеБлока.ИмяОбласти);
	Описание.Вставить("Экспортный", Блок.ОписаниеБлока.Экспортный);
	Описание.Вставить("ИмяМетода", Блок.ОписаниеБлока.ИмяМетода);
	Описание.Вставить("Описание", Блок.ОписаниеБлока.Назначение);
	Описание.Вставить("ПараметрыМетода", Блок.ОписаниеБлока.ПараметрыМетода);
	Описание.Вставить("ОписаниеВозвращаемогоЗначения", Блок.ОписаниеБлока.ОписаниеВозвращаемогоЗначения);
	Описание.Вставить("ТипВозвращаемогоЗначения", Блок.ОписаниеБлока.ТипВозвращаемогоЗначения);
	Описание.Вставить("Примеры", Блок.ОписаниеБлока.Примеры);

	Возврат Описание;

КонецФункции

Функция ОбязательныеРазделыМодуля(Модуль)

	НужныеРазделы = Новый Массив();

	Если Модуль.ТипМодуля = ТипыМодуля.ОбщийМодуль Тогда

		НужныеРазделы = ТипыОбласти.РазделыОбщегоМодуля;

	ИначеЕсли Модуль.ТипМодуля = ТипыМодуля.МодульМенеджера Тогда

		НужныеРазделы = ТипыОбласти.РазделыМодуляМенеджера;

	КонецЕсли;

	Возврат НужныеРазделы;

КонецФункции

Функция Раздел(Модуль, ТекстОшибки)

	СтруктураПодсистем = ПолучитьСтруктуруПодсистем(Модуль.Родитель.Подсистемы);
	Если ПустаяСтрока(СтруктураПодсистем.ИмяРаздела) Тогда

		ТекстОшибки = "Ошибочная структура подсистем";
		Возврат Неопределено;

	КонецЕсли;

	Раздел = СоздаваемыеРазделы.Найти(СтруктураПодсистем.ИмяРаздела, "Имя");
	Если Раздел = Неопределено Тогда

		Раздел = СоздаваемыеРазделы.Добавить();
		Раздел.Имя = СтруктураПодсистем.ИмяРаздела;
		Раздел.Содержимое = СтруктураПодсистем.ОписаниеРаздела;

	КонецЕсли;

	ИмяПодсистемы = "Подсистема " + СтруктураПодсистем.ИмяПодсистемы;
	Если СтруктураПодсистем.ИмяПодсистемы = "Общего назначения" Тогда

		ИмяПодсистемы = ИмяПодсистемы + " (" + НРег(СтруктураПодсистем.ИмяРаздела) + ")";

	КонецЕсли;

	Подсистема = СоздаваемыеРазделы.Найти(ИмяПодсистемы, "Имя");

	Если Подсистема = Неопределено Тогда

		Подсистема = СоздаваемыеРазделы.Добавить();
		Подсистема.Имя = ИмяПодсистемы;
		Подсистема.Содержимое = СтруктураПодсистем.ОписаниеПодсистемы;
		Подсистема.Родитель = Раздел;

	КонецЕсли;

	Возврат Подсистема;

КонецФункции

Функция ОбрабатываемФайл(НастройкиГенератора, ИмяФайла, Модуль)

	Если Модуль.ТипМодуля <> ТипыМодуля.ОбщийМодуль
		И Модуль.ТипМодуля <> ТипыМодуля.МодульМенеджера Тогда

		// Реализован анализ только для общих модулей и модулей менеджеров
		// остальные пропускаем
		Возврат Ложь;

	КонецЕсли;

	Если Модуль.Родитель <> Неопределено И Модуль.Родитель.Тип = "Constant" Тогда

		// Для констант не поддерживается
		Возврат Ложь;

	КонецЕсли;

	Возврат НЕ НастройкиГенератора.НастройкиАнализаИзменений.Анализировать
		ИЛИ НастройкиГенератора.НастройкиАнализаИзменений.ИзмененныеФайлы.Найти(НРег(ИмяФайла)) <> Неопределено;

КонецФункции

Функция ПолучитьСтруктуруПодсистем(Подсистемы)

	ИскомаяПодсистема = Неопределено;

	Для Каждого Подсистема Из Подсистемы Цикл

		Если Подсистема.Визуальная Тогда

			Продолжить;

		КонецЕсли;

		Если НЕ ПустаяСтрока(АнализироватьТолькоПотомковПодсистемы) И Не СтрНачинаетсяС(Подсистема.Имя, АнализироватьТолькоПотомковПодсистемы) Тогда

			Продолжить;

		КонецЕсли;

		Имена = СтрРазделить(Подсистема.Представление, "/");
		Если Имена.Количество() <> 3 Тогда

			Продолжить;

		КонецЕсли;

		ИскомаяПодсистема = Подсистема;
		Прервать;

	КонецЦикла;

	СтруктураПодсистем = Новый Структура("ИмяРаздела, ИмяПодсистемы, ОписаниеРаздела, ОписаниеПодсистемы", "", "", "", "");
	Если ИскомаяПодсистема <> Неопределено Тогда

		СтруктураПодсистем.ИмяРаздела = ИскомаяПодсистема.Родитель.ПредставлениеКратко;
		СтруктураПодсистем.ИмяПодсистемы = ИскомаяПодсистема.ПредставлениеКратко;
		СтруктураПодсистем.ОписаниеРаздела = ИскомаяПодсистема.Родитель.ПодсистемаОписание;
		СтруктураПодсистем.ОписаниеПодсистемы = ИскомаяПодсистема.ПодсистемаОписание;

	КонецЕсли;

	Возврат СтруктураПодсистем;

КонецФункции

#КонецОбласти

Процедура ПриСозданииОбъекта(Шаблонизатор)

	ГенераторСодержимого = Шаблонизатор;

	Попытка
		
		АнализироватьТолькоПотомковПодсистемы = ГенераторСодержимого.АнализироватьТолькоПотомковПодсистемы;
		
	Исключение
		
		// Реакция на ошибку не нужна
		
	КонецПопытки;

КонецПроцедуры