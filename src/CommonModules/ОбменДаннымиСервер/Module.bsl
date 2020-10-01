
#Область ПрограммныйИнтерфейс

Процедура Синхронизировать() Экспорт
	ПараметрыСоединения = ПолучитьНастройкиСоединения();	
	СоединениеИПараметры = ОбменДаннымиКлиентСервер.ПолучитьСоединениеИПараметры(ПараметрыСоединения);
	
	ПродолжатьСинхронизацию = Истина;
	Пока ПродолжатьСинхронизацию Цикл
		// загружаем пока объетов для загрузки меньше чем в итерации
		ПродолжатьСинхронизацию = ЗагрузитьДанные(СоединениеИПараметры, 1000);
		ПродолжатьСинхронизацию = ВыгрузитьДанные(СоединениеИПараметры) И ПродолжатьСинхронизацию;
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьНастройкиСоединения() Экспорт 
	ПараметрыСоединения = Константы.ПараметрыСоединения.Получить().Получить();
	Если ПараметрыСоединения = Неопределено Тогда
		ВызватьИсключение "Не указаны параметры соединения!";	
	КонецЕсли;
	
	Возврат ПараметрыСоединения;
КонецФункции

Функция ПолучитьСоздатьОбновитьСсылку(Данные, ИмяМенеджера, Обновлять = Истина) Экспорт
		
	ДанныеСсылки = ?(Данные.Свойство("Ссылка"), Данные.Ссылка, Данные);
	
	ИДССылки = Новый УникальныйИдентификатор(ДанныеСсылки.ID);
	
	Менеджер = Справочники[ИмяМенеджера];
	
	СсылкаНаСправочник = Менеджер.ПолучитьСсылку(ИДССылки);
	Если НЕ ЗначениеЗаполнено(СсылкаНаСправочник) Тогда
		Возврат СсылкаНаСправочник;		
	КонецЕсли;
	
	ОбъектСправочника = СсылкаНаСправочник.ПолучитьОбъект();
	Если ОбъектСправочника <> Неопределено Тогда
		Если НЕ Обновлять Тогда
			Возврат СсылкаНаСправочник;
		КонецЕсли;	
	Иначе 
		ОбъектСправочника = Менеджер.СоздатьЭлемент();
		ОбъектСправочника.УстановитьСсылкуНового(СсылкаНаСправочник);
	КонецЕсли;
	
	ОбъектСправочника.Наименование = ДанныеСсылки.Наименование;
	ЗаполнитьСвойства(ОбъектСправочника, Данные);	
	
	ОбъектСправочника.ОбменДанными.Загрузка = Истина;
	ОбъектСправочника.Записать();
	
	Возврат ОбъектСправочника.Ссылка; 
КонецФункции

Функция ПолучитьСоздатьОбновитьОтборРазмещение(Данные, Обновлять = Истина) Экспорт
	
	Менеджер = Документы.ОтборРазмещение;
	
	СсылкаНаДокумент = Менеджер.ПолучитьСсылку(Новый УникальныйИдентификатор(Данные.ID));
	Если НЕ ЗначениеЗаполнено(СсылкаНаДокумент) Тогда
		Возврат СсылкаНаДокумент;		
	КонецЕсли;
	
	ОбъектДокумент = СсылкаНаДокумент.ПолучитьОбъект();
	Если ОбъектДокумент <> Неопределено Тогда
		Если НЕ Обновлять Тогда
			Возврат СсылкаНаДокумент;
		КонецЕсли;	
	Иначе 
		ОбъектДокумент = Менеджер.СоздатьДокумент();
		ОбъектДокумент.УстановитьСсылкуНового(СсылкаНаДокумент);
	КонецЕсли;
	
	ОбъектДокумент.Дата = Данные.Дата;
	
	Если Данные.Свойство("Номер") Тогда
		 ОбъектДокумент.Номер = Данные.Номер;
	КонецЕсли;
	
	ЗаполнитьСвойства(ОбъектДокумент, Данные);	
	
	ОбъектДокумент.ТоварыОтбор.Очистить();
	Для Каждого ТекСтрока Из Данные.ТоварыОтбор Цикл
		НоваяСтрока = ОбъектДокумент.ТоварыОтбор.Добавить();
		НоваяСтрока.Номенклатура = ПолучитьСоздатьОбновитьСсылку(ТекСтрока.Номенклатура, "Номенклатура");
		НоваяСтрока.Упаковка = ПолучитьСоздатьОбновитьСсылку(ТекСтрока.Упаковка, "Упаковки");
		НоваяСтрока.Ячейка = ПолучитьСоздатьОбновитьСсылку(ТекСтрока.Ячейка, "Ячейки");
		НоваяСтрока.Количество = ТекСтрока.Количество;
		//НоваяСтрока.КоличествоОтобрано = ТекСтрока.КоличествоОтобрано;
	КонецЦикла;
	ОбъектДокумент.ТоварыРазмещение.Очистить();
	Для Каждого ТекСтрока Из Данные.ТоварыРазмещение Цикл
		НоваяСтрока = ОбъектДокумент.ТоварыРазмещение.Добавить();
		НоваяСтрока.Номенклатура = ПолучитьСоздатьОбновитьСсылку(ТекСтрока.Номенклатура, "Номенклатура");
		НоваяСтрока.Упаковка = ПолучитьСоздатьОбновитьСсылку(ТекСтрока.Упаковка, "Упаковки");
		НоваяСтрока.Ячейка = ПолучитьСоздатьОбновитьСсылку(ТекСтрока.Ячейка, "Ячейки");
		НоваяСтрока.Количество = ТекСтрока.Количество;
		НоваяСтрока.КоличествоРазмещено = 0;
	КонецЦикла;
	
	ОбъектДокумент.ОбменДанными.Загрузка = Истина;
	ОбъектДокумент.Записать();
	
	Возврат ОбъектДокумент.Ссылка;
КонецФункции

Функция ЗаписатьJSONВСтроку(Значение) Экспорт
	
	ЗаписьJSON = Новый ЗаписьJSON;
	ЗаписьJSON.УстановитьСтроку(Новый ПараметрыЗаписиJSON()); 
	
	ЗаписатьJSON(ЗаписьJSON, Значение,, "ПреобразоватьЗначенияДляJSON", ОбменДаннымиСервер);
	
	Результат = ЗаписьJSON.Закрыть();	
	Возврат Результат;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

Функция ПреобразоватьЗначенияДляJSON(Свойство, Значение, ДопПараметры, Отказ) Экспорт
	
	// для справочников выгружем ИД и наименование
	Если ТипЗнч(Значение) = Тип("ДокументСсылка.ОтборРазмещение") Тогда
		Результат = Новый Структура("Дата, ВидОперации, Исполнитель, Ответственный, Комментарий, ЗонаОтгрузки, ЗонаПриемки, Склад, Статус");
		ЗаполнитьЗначенияСвойств(Результат, Значение);
		Результат.Вставить("ID", Значение.УникальныйИдентификатор());
		
		Результат.Дата = Значение.Дата;
		
		Результат.Вставить("ТоварыОтбор", Новый Массив);
		Для Каждого ТекСтрока Из Значение.ТоварыОтбор Цикл
			СтруктураСтрока = Новый Структура("Номенклатура, Упаковка, Ячейка, Количество, КоличествоОтобрано");
			ЗаполнитьЗначенияСвойств(СтруктураСтрока, ТекСтрока);
			Результат.ТоварыОтбор.Добавить(СтруктураСтрока);
		КонецЦикла;
		
		Результат.Вставить("ТоварыРазмещение", Новый Массив);
		Для Каждого ТекСтрока Из Значение.ТоварыРазмещение Цикл
			СтруктураСтрока = Новый Структура("Номенклатура, Упаковка, Ячейка, Количество, КоличествоРазмещено");
			ЗаполнитьЗначенияСвойств(СтруктураСтрока, ТекСтрока);
			Результат.ТоварыРазмещение.Добавить(СтруктураСтрока);
		КонецЦикла;
		
	ИначеЕсли Справочники.ТипВсеСсылки().СодержитТип(ТипЗнч(Значение)) Тогда
		Результат = Новый Структура;
		Результат.Вставить("ID", Значение.УникальныйИдентификатор());
		Результат.Вставить("Наименование", "" + Значение);
	ИначеЕсли Перечисления.ТипВсеСсылки().СодержитТип(ТипЗнч(Значение)) Тогда
		Если ЗначениеЗаполнено(Значение) Тогда
			МетаданныеПеречисления = Значение.Метаданные();
			ИндексЗначения = Перечисления[МетаданныеПеречисления.Имя].Индекс(Значение);
			Результат = МетаданныеПеречисления.ЗначенияПеречисления[ИндексЗначения].Имя;
		Иначе
			Результат = "";	
		КонецЕсли;
	ИначеЕсли ТипЗнч(Значение) = Тип("РегистрСведенийНаборЗаписей.РазмещениеНоменклатурыПоСкладскимЯчейкам") Тогда
		Результат = Новый Массив;
		Для Каждого ТекЗапись Из Значение Цикл
			ТекПозиция = Новый Структура("Номенклатура, Склад, Ячейка, ОсновнаяЯчейка");
			ЗаполнитьЗначенияСвойств(ТекПозиция, ТекЗапись);
			Результат.Добавить(ТекПозиция);
		КонецЦикла;
	Иначе
		Результат = "" + Значение;	
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ЗагрузитьДанные(СоединениеИПараметры, ОбъектовВИтерации)
	
	ЭтотУзел = ПланыОбмена.HTTPОбменСРабочейБазой.ЭтотУзел();
	
	ВсегоОбъектов = 0;
		
	СтрокаПараметров = "?code=%1&quantity=%2";
	
	СтрокаПараметров = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаПараметров, ЭтотУзел.Код, Формат(ОбъектовВИтерации, "ЧГ=")); 
	АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/sync" + СтрокаПараметров;  
	
	СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "GET");
	
	Если СтруктураОтвета = Неопределено Тогда
		Возврат Ложь;	
	КонецЕсли;
	
	Если СтруктураОтвета.error Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Ошибка в запросе: " + СтруктураОтвета.text;
		Сообщение.Сообщить();
		
		Возврат Ложь;		
	КонецЕсли;
		
	ПозицииСсылок = Неопределено;
	Если СтруктураОтвета.data.Свойство("Номенклатура", ПозицииСсылок) Тогда
		Для Каждого ТекПозиция Из ПозицииСсылок Цикл 
			ПолучитьСоздатьОбновитьСсылку(ТекПозиция, "Номенклатура");
			ВсегоОбъектов = ВсегоОбъектов + 1;
		КонецЦикла;
	КонецЕсли;	
	
	ПозицииСсылок = Неопределено;
	Если СтруктураОтвета.data.Свойство("Упаковки", ПозицииСсылок) Тогда
		Для Каждого ТекПозиция Из ПозицииСсылок Цикл 
			ПолучитьСоздатьОбновитьСсылку(ТекПозиция, "Упаковки");		
			ВсегоОбъектов = ВсегоОбъектов + 1;
		КонецЦикла;
	КонецЕсли;	
	
	ПозицииСсылок = Неопределено;
	Если СтруктураОтвета.data.Свойство("Ячейки", ПозицииСсылок) Тогда
		Для Каждого ТекПозиция Из ПозицииСсылок Цикл 
			ПолучитьСоздатьОбновитьСсылку(ТекПозиция, "Ячейки");		
			ВсегоОбъектов = ВсегоОбъектов + 1;		
		КонецЦикла;
	КонецЕсли;	
	
	ПозицииСсылок = Неопределено;
	Если СтруктураОтвета.data.Свойство("Пользователи", ПозицииСсылок) Тогда
		Для Каждого ТекПозиция Из ПозицииСсылок Цикл 
			ПолучитьСоздатьОбновитьСсылку(ТекПозиция, "Пользователи");		
			ВсегоОбъектов = ВсегоОбъектов + 1;		
		КонецЦикла;
	КонецЕсли;
	
	Штрихкоды = Неопределено;
	Если СтруктураОтвета.data.Свойство("Штрихкоды", Штрихкоды) Тогда
		Для Каждого ТекПозиция Из Штрихкоды Цикл 
			ОбновитьШтрихкоды(ТекПозиция);		
			ВсегоОбъектов = ВсегоОбъектов + 1;		
		КонецЦикла;
	КонецЕсли;
		
	НастройкиУзла = Неопределено;
	СтруктураОтвета.Свойство("Узел", НастройкиУзла);
	Если НастройкиУзла <> Неопределено Тогда
		УзелУТ = ПланыОбмена.HTTPОбменСРабочейБазой.НайтиПоКоду(НастройкиУзла.Код);
		
		Если ЗначениеЗаполнено(УзелУТ) Тогда
			УзелУТОбъект = УзелУТ.ПолучитьОбъект();
			УзелУТОбъект.НомерПринятого = НастройкиУзла.НомерОтправленного;
			УзелУТОбъект.Записать();
		КонецЕсли;
	КонецЕсли;
	
	Возврат ВсегоОбъектов >= ОбъектовВИтерации;
КонецФункции

Функция ВыгрузитьДанные(СоединениеИПараметры)
		
	УзелУТ = ПланыОбмена.HTTPОбменСРабочейБазой.НайтиПоКоду("УТ");
	ЭтотУзел = ПланыОбмена.HTTPОбменСРабочейБазой.ЭтотУзел();
	
	//ВыборкаИзменений = ПланыОбмена.ВыбратьИзменения(УзелУТ, УзелУТ.НомерОтправленного + 1); 
	
	СтрокаПараметров = "?code=%1";
	
	СтрокаПараметров = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(СтрокаПараметров, ЭтотУзел.Код); 
	АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/sync" + СтрокаПараметров;  
	
	СтруктураЗапроса = Новый Структура;
	
	// отборы размещения
	Выборка = ПланыОбмена.ВыбратьИзменения(УзелУТ, УзелУТ.НомерОтправленного + 1, Метаданные.Документы.ОтборРазмещение);
	
	СтруктураЗапроса.Вставить("ОтборыРазмещения", Новый Массив);
	Пока Выборка.Следующий() Цикл
		Данные = Выборка.Получить();
		СтруктураЗапроса.ОтборыРазмещения.Добавить(Данные.Ссылка);		
	КонецЦикла;
	
	// РазмещениеНоменклатурыПоСкладскимЯчейкам
	ВыборкаРазмещения = ПланыОбмена.ВыбратьИзменения(УзелУТ, УзелУТ.НомерОтправленного + 1, Метаданные.РегистрыСведений.РазмещениеНоменклатурыПоСкладскимЯчейкам);
	
	СтруктураЗапроса.Вставить("РазмещениеНоменклатурыПоСкладскимЯчейкам", Новый Массив);
	
	Пока ВыборкаРазмещения.Следующий() Цикл
		Данные = Выборка.Получить();
		СтруктураЗапроса.РазмещениеНоменклатурыПоСкладскимЯчейкам.Добавить(Данные.Ссылка);		
	КонецЦикла;
	
	СтруктураЗапроса.Вставить("Узел", Новый Структура("Код, НомерОтправленного, НомерПринятого", ЭтотУзел.Код, УзелУТ.НомерОтправленного, УзелУТ.НомерПринятого));
	
	УзелОбъект = УзелУТ.ПолучитьОбъект();
	УзелОбъект.НомерОтправленного = УзелОбъект.НомерОтправленного + 1;
	УзелОбъект.Записать();
	
	ТелоЗапроса = ЗаписатьJSONВСтроку(СтруктураЗапроса);
		
	СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "POST", ТелоЗапроса);
	Если СтруктураОтвета = Неопределено Тогда
		Возврат Ложь;	
	КонецЕсли;
		
	НастройкиУзла = Неопределено;
	СтруктураОтвета.Свойство("Узел", НастройкиУзла);
	Если НастройкиУзла <> Неопределено Тогда
		ПланыОбмена.УдалитьРегистрациюИзменений(УзелУТ, НастройкиУзла.НомерПринятого);
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

Процедура ЗаполнитьСвойства(ОбъектСправочника, Данные)
	
	ТипСтрока = Тип("Строка");
	ТипЧисло = Тип("Число"); 
	ТипБулево = Тип("Булево"); 
	ТипДата = Тип("Дата"); 
	
	МетаданныеОбъекта = ОбъектСправочника.Метаданные();
	
	Если Данные.Свойство("Владелец")
		И МетаданныеОбъекта.Владельцы.Количество() <> 0 Тогда
		ИмяВладельца = ОбъектСправочника.Владелец.Метаданные().Имя;
		ОбъектСправочника.Владелец = ПолучитьСоздатьОбновитьСсылку(Данные.Владелец, ИмяВладельца, Ложь);
	КонецЕсли;
	
	Реквизиты = МетаданныеОбъекта.Реквизиты;
	Для Каждого ТекРеквизит Из Реквизиты Цикл
		ДанныеРеквизита = Неопределено;
		Если НЕ Данные.Свойство(ТекРеквизит.Имя, ДанныеРеквизита) Тогда
			Продолжить;	
		КонецЕсли;
		
		ТипыРеквизита = ТекРеквизит.Тип;
		Если ТипыРеквизита.СодержитТип(ТипСтрока)
			ИЛИ ТипыРеквизита.СодержитТип(ТипЧисло)
			ИЛИ ТипыРеквизита.СодержитТип(ТипДата)
			ИЛИ ТипыРеквизита.СодержитТип(ТипБулево) Тогда
			ОбъектСправочника[ТекРеквизит.Имя] = ДанныеРеквизита;
		Иначе
			Попытка
				МетаданныеЗначенияРеквизита = ОбъектСправочника[ТекРеквизит.Имя].Метаданные();
				Если Метаданные.Перечисления.Содержит(МетаданныеЗначенияРеквизита) Тогда
					ОбъектСправочника[ТекРеквизит.Имя] = Перечисления[МетаданныеЗначенияРеквизита.Имя][ДанныеРеквизита];
				ИначеЕсли Метаданные.Справочники.Содержит(МетаданныеЗначенияРеквизита) Тогда
					ОбъектСправочника[ТекРеквизит.Имя] = ПолучитьСоздатьОбновитьСсылку(ДанныеРеквизита, МетаданныеЗначенияРеквизита.Имя, Ложь);
				Иначе 
					ОбъектСправочника[ТекРеквизит.Имя] = ДанныеРеквизита;
				КонецЕсли;
			Исключение
				//ЗаписьЖурналаРегистрации("Синхронизация.ЧтениеДанных",, МетаданныеОбъекта,, ОписаниеОшибки());
				Продолжить;
			КонецПопытки;	
		КонецЕсли;		
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбновитьШтрихкоды(Данные, Обновлять = Истина)
	МенЗаписи = РегистрыСведений.ШтрихкодыНоменклатуры.СоздатьМенеджерЗаписи();
	МенЗаписи.Штрихкод = Данные.Штрихкод;
	
	Если Данные.ПометкаУдаления Тогда
		МенЗаписи.Удалить();
	Иначе 
		МенЗаписи.Номенклатура = ПолучитьСоздатьОбновитьСсылку(Данные.Номенклатура, "Номенклатура", Ложь);
		МенЗаписи.Упаковка = ПолучитьСоздатьОбновитьСсылку(Данные.Упаковка, "Упаковки", Ложь);		
		МенЗаписи.Записать(Истина);	
	КонецЕсли;	
КонецПроцедуры

#КонецОбласти