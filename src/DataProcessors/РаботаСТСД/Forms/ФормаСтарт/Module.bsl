#Область ОписаниеПеременных

&НаКлиенте
Перем СоединениеИПараметры;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	СоединениеИПараметры = Неопределено;
	
	ЗавершитьРаботуСистемы(Ложь, Ложь);
КонецПроцедуры 

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Попытка
		ТекущийПользователь = ПараметрыСеанса.ТекущийПользователь;
	Исключение
	КонецПопытки;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	НастройкиСоединения = ПолучитьНастройкиСоединения();
	СоединениеИПараметры = ОбменДаннымиКлиентСервер.ПолучитьСоединениеИПараметры(НастройкиСоединения);
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура Остатки(Команда)
	ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаОстатки",, ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура Размещение(Команда)
	ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаОстатки",, ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура РегистрацияТовараВЯчейках(Команда)
	ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаРегистрацияТовараВЯчейках",, ЭтаФорма);
КонецПроцедуры

&НаКлиенте
Процедура Перемещение(Команда)
	
	Если НЕ ЗначениеЗаполнено(ТекущийПользователь) Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не определен пользователь!";
		Сообщение.Сообщить();		
		Возврат;
	КонецЕсли;
	
	АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/task?userID=" + СокрЛП(ТекущийПользователь.УникальныйИдентификатор());
	СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "GET");
	
	Если СтруктураОтвета = Неопределено Тогда
		Возврат;	
	КонецЕсли;
	
	Если СтруктураОтвета.error Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Ошибка: " + СтруктураОтвета.text;
		Сообщение.Сообщить();
	
		Возврат;		
	КонецЕсли;
	
	ДокументСсылка = ПолучитьДокументОтборРазмещение(СтруктураОтвета.task);
	
	Если ЗначениеЗаполнено(ДокументСсылка) Тогда
		АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/task?taskID=" + СокрЛП(ДокументСсылка.УникальныйИдентификатор());
		
		НовыйСтатусСтрока = СтруктураИзменениеСтатуса(ПредопределенноеЗначение("Перечисление.СтатусыОтборовРазмещенийТоваров.ВРаботе"));
		СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "PATCH", НовыйСтатусСтрока);
		
		Если СтруктураОтвета <> Неопределено И СтруктураОтвета.error Тогда
			Сообщение = Новый СообщениеПользователю;
			Сообщение.Текст = СтруктураОтвета.message;
			Сообщение.Сообщить();
		КонецЕсли;
		
		ПараметрыФормы = Новый Структура("Ключ", ДокументСсылка);
	    ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаПеремещение", ПараметрыФормы, ЭтаФорма);
	Иначе 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не удалось получить задачу!";
		Сообщение.Сообщить();
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ПроверкаТоваровВЯчейке(Команда)
	ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаПроверкиТоваровВЯчейки",, ЭтаФорма);
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ПолучитьНастройкиСоединения()
	Возврат ОбменДаннымиСервер.ПолучитьНастройкиСоединения();	
КонецФункции

&НаСервере
Функция ПолучитьДокументОтборРазмещение(Данные)
	ОбменДаннымиСервер.Синхронизировать();
	Возврат ОбменДаннымиСервер.ПолучитьСоздатьОбновитьОтборРазмещение(Данные, Истина);	
КонецФункции

&НаКлиенте
Процедура ПеремещениеПоДокументу(Команда)
	ПараметрыФормы = Новый Структура("Ключ", Документ);
	ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаПеремещение", ПараметрыФормы, ЭтаФорма);
КонецПроцедуры

&НаСервере
Функция СтруктураИзменениеСтатуса(Статус)
	Возврат ОбменДаннымиСервер.ЗаписатьJSONВСтроку(Новый Структура("Статус", Статус));			
КонецФункции

&НаКлиенте
Процедура УстановкаЯчеекаДляТовара(Команда)
	ОткрытьФорму("Обработка.РаботаСТСД.Форма.ФормаУстановкиЯчейкиДляТовара",, ЭтаФорма);
КонецПроцедуры

#КонецОбласти
