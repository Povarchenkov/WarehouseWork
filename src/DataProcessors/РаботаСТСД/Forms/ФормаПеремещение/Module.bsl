#Область ОписаниеПеременных

&НаКлиенте
Перем НомерУстройства, СоединениеИПараметры;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	Для Каждого ТекСтрока Из ТекущийОбъект.ТоварыОтбор Цикл
		ТекСтрока.КоличествоОтобрано = 0;		
	КонецЦикла;
	Для Каждого ТекСтрока Из ТекущийОбъект.ТоварыРазмещение Цикл
		ТекСтрока.КоличествоРазмещено = 0;		
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	Если ИмяСобытия = "СканШтрихкода"
		И (НомерУстройства = Источник ИЛИ Источник = ЭтаФорма)
		И ВводДоступен() Тогда
		
		ШтрихкодПоиск = Параметр;
		ОбработатьШтрихкод(Параметр); //процедура для обработки ШК
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если КомпонентыДляСчитыванияШтрихкодов <> Неопределено Тогда
		КомпонентыДляСчитыванияШтрихкодов.Подключить(НомерУстройства);
	КонецЕсли;
	
	НастройкиСоединения = ПолучитьНастройкиСоединения();
	СоединениеИПараметры = ОбменДаннымиКлиентСервер.ПолучитьСоединениеИПараметры(НастройкиСоединения);
	
	УправлениеФормой();
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии(ЗавершениеРаботы)
	Если КомпонентыДляСчитыванияШтрихкодов <> Неопределено Тогда
		КомпонентыДляСчитыванияШтрихкодов.Отключить(НомерУстройства);
	КонецЕсли;
	СоединениеИПараметры = Неопределено;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	КэшированныеЗначения = Новый Структура;
	КэшированныеЗначения.Вставить("Штрихкоды", Новый Соответствие);
	КэшированныеЗначения.Вставить("ЯчейкиНоменклатуры", Новый Соответствие);
	КэшированныеЗначения.Вставить("ТекущийЭтап", "");
	КэшированныеЗначения.Вставить("ПоказатьДетали", Ложь);
	КэшированныеЗначения.Вставить("МожноЗакрыть", Ложь);
	
	Объект.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОтборовРазмещенийТоваров.ВРаботе");
	
	ПерезаполнитьКоличествоШтук();
	
	ЗаполнитьЯчейкиОтбора();
	
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.ГруппаТоварыОтбор;
	ТекущийЭтап = "ОтобранныеТовары";	
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, ЗавершениеРаботы, ТекстПредупреждения, СтандартнаяОбработка)
	Отказ = НЕ КэшированныеЗначения.МожноЗакрыть;		
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	Если ПараметрыЗаписи.Свойство("ВременнаяЗапись")
		И ПараметрыЗаписи.ВременнаяЗапись Тогда
		
		Возврат;
	КонецЕсли;
	
	Если НЕ КэшированныеЗначения.МожноЗакрыть Тогда
		ОписаниеОповещения = Новый ОписаниеОповещения("ВопросПередЗаписьюЗавершение", ЭтаФорма);
		ПоказатьВопрос(ОписаниеОповещения, "Закончить размещение?", РежимДиалогаВопрос.ДаНет, 20, КодВозвратаДиалога.Нет);
		Отказ = Истина;	
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ПараметрыЗаписи.Свойство("ВременнаяЗапись")
		И ПараметрыЗаписи.ВременнаяЗапись Тогда
		
		Возврат;
	КонецЕсли;	
	
	ТаблицаПроверки = Новый ТаблицаЗначений;
	ТаблицаПроверки.Колонки.Добавить("Номенклатура");
	ТаблицаПроверки.Колонки.Добавить("Упаковка");
	ТаблицаПроверки.Колонки.Добавить("Количество");
	ТаблицаПроверки.Колонки.Добавить("КоличествоВыполнено");
	
	ЕстьОшибки = Ложь;
	СтрокаОшибки = "";
	
	Для Каждого СтрТабл из ТекущийОбъект.ТоварыРазмещение Цикл
		
		// Добавить запись в таблицу проверки.
		НоваяСтрока = ТаблицаПроверки.Добавить();
		
		ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрТабл);
		НоваяСтрока.Количество = СтрТабл.Количество;
		НоваяСтрока.КоличествоВыполнено = СтрТабл.КоличествоРазмещено;
		
		Разница = СтрТабл.Количество - СтрТабл.КоличествоРазмещено;
		Если Разница <> 0 Тогда
			СтрокаОшибки = СтрокаОшибки + "
				|Для " + СтрТабл.Номенклатура + " размещено " + ?(Разница > 0, "больше", "меньше") + ", чем нужно.";
			
			ЕстьОшибки = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	Для Каждого СтрТабл из ТекущийОбъект.ТоварыОтбор Цикл
		
		// Добавить запись в таблицу проверки.
		НоваяСтрока = ТаблицаПроверки.Добавить();
		
		ЗаполнитьЗначенияСвойств(НоваяСтрока,СтрТабл);
		НоваяСтрока.Количество = -СтрТабл.Количество;
		НоваяСтрока.КоличествоВыполнено = -СтрТабл.КоличествоОтобрано;
		
		Разница = СтрТабл.Количество - СтрТабл.КоличествоОтобрано;
		Если Разница <> 0 Тогда
			СтрокаОшибки = СтрокаОшибки + "
				|Для " + СтрТабл.Номенклатура + " отобрано " + ?(Разница > 0, "больше", "меньше") + ", чем нужно.";
			
			ЕстьОшибки = Истина;
		КонецЕсли;
		
	КонецЦикла;
	
	ТаблицаПроверки.Свернуть("Номенклатура, Упаковка", "Количество, КоличествоВыполнено");
	
	Для Каждого ТекСтрока Из ТаблицаПроверки Цикл
		Если ТекСтрока.КоличествоВыполнено <> 0 Тогда
			СтрокаОшибки = СтрокаОшибки + "
				|Для " + ТекСтрока.Номенклатура + " размещено " + ?(ТекСтрока.КоличествоВыполнено > 0, "больше", "меньше") + " чем отобрано.";
			
			ЕстьОшибки = Истина;
		КонецЕсли;
	КонецЦикла;
	
	Если ЕстьОшибки Тогда
		ТекущийОбъект.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОтборовРазмещенийТоваров.ВыполненоСОшибками");
	Иначе
		ТекущийОбъект.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОтборовРазмещенийТоваров.ВыполненоБезОшибок");
	КонецЕсли;		
	ТекущийОбъект.Комментарий = "Загрузка из ТСД!" + Символы.ПС + Символы.ВК + ТекущийОбъект.Комментарий + СтрокаОшибки;
	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Если ПараметрыЗаписи.Свойство("ВременнаяЗапись")
		И ПараметрыЗаписи.ВременнаяЗапись Тогда
		
		Возврат;
	КонецЕсли;
	
	АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/task";
	
	СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "PUT", СтруктураДокумента(Объект.Ссылка));
	
	Если СтруктураОтвета <> Неопределено И СтруктураОтвета.error Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтруктураОтвета.message;
		Сообщение.Сообщить();
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ОбработатьШтрихкод(Штрихкод)
	
	Если НЕ ЗначениеЗаполнено(Штрихкод) Тогда
		Возврат;	
	КонецЕсли;
	
	ДанныеШтрихкода = ПолучитьДанныеШтрихкодаСервер(Штрихкод, КэшированныеЗначения);
	
	Если ДанныеШтрихкода = Неопределено Тогда 
		ДанныеШтрихкода = ПолучитьДанныеПоШтрихкодуССервера(Штрихкод, КэшированныеЗначения);
	КонецЕсли;
	
	ТипЗнчДанныеШтрихкода = ТипЗнч(ДанныеШтрихкода);
	
	Если ТекущийЭтап = "ОтобранныеТовары" Тогда
		ОтобратьНоменклатуруВОтборе(ДанныеШтрихкода);
		Возврат;
	КонецЕсли;
	
	Если ТипЗнчДанныеШтрихкода = Тип("Структура") Тогда
	
		Номенклатура = ДанныеШтрихкода.Номенклатура;
		Упаковка = ДанныеШтрихкода.Упаковка;

		Если ПредыдущаяНоменклатура <> Номенклатура Тогда
		
			КоличествоРазмещено = 0;
			Ячейка = ПредопределенноеЗначение("Справочник.Ячейки.ПустаяСсылка");
			
			УстановитьЯчейкиРазмещения(Номенклатура);
			ТекущийЭтап = "СканЯчейки";
			
		Иначе
			
			Если ЗначениеЗаполнено(Номенклатура) И ЗначениеЗаполнено(Ячейка) Тогда
			
				ИзменитьКоличество(1);
				Возврат;
			
			КонецЕсли; 
		
		КонецЕсли;
			
	ИначеЕсли ТипЗнчДанныеШтрихкода = Тип("СправочникСсылка.Ячейки") Тогда
	
		Ячейка = ДанныеШтрихкода;
		
	Иначе 
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Штрихкод не найден!";
		Сообщение.Сообщить();
		
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Номенклатура)
		И ЗначениеЗаполнено(Ячейка) Тогда
		
		ТекущийЭтап = "ВводКоличества";
		СинхронизироватьДанныеСТаблицей(Истина);
		
	КонецЕсли;
	
	ПредыдущаяНоменклатура = Номенклатура;
	
	УправлениеФормой();
	
КонецПроцедуры

&НаКлиенте
Процедура КоличествоПриИзменении(Элемент)
	СинхронизироватьДанныеСТаблицей();
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПоказатьДетали(Команда)
	КэшированныеЗначения.ПоказатьДетали = НЕ КэшированныеЗначения.ПоказатьДетали;
	
	Элементы.ПоказатьДетали.Заголовок = ?(КэшированныеЗначения.ПоказатьДетали, "Скрыть детали", "Показать детали");
	
	УправлениеФормой();
КонецПроцедуры

&НаКлиенте
Процедура СброситьНоменклатуру(Команда)
	Номенклатура = Неопределено;
	ПредыдущаяНоменклатура = Неопределено;
	Ячейка = Неопределено;
	КоличествоРазмещено = 0;
	ТекущийЭтап = "ВыборТовара";
	
	УправлениеФормой();
КонецПроцедуры

&НаКлиенте
Процедура СброситьОтбор(Команда)
	ОтобратьНоменклатуруВОтборе(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура НачатьРазмещение(Команда)
	АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/task?taskID=" + СокрЛП(Объект.Ссылка.УникальныйИдентификатор());
	
	Объект.Статус = ПредопределенноеЗначение("Перечисление.СтатусыОтборовРазмещенийТоваров.СФ_Размещается");
	
	СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "PATCH", СтруктураИзменениеСтатуса(Объект.Статус));
	
	Если СтруктураОтвета <> Неопределено И СтруктураОтвета.error Тогда
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = СтруктураОтвета.message;
		Сообщение.Сообщить();
	КонецЕсли;
	
	ТекущийЭтап = "ВыборТовара";
	Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.ГруппаТоварыРазмещение;
	УправлениеФормой();
	
	ВсеТоварыОтобраны();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ШтрихкодПриИзменении(Элемент)
	ПодключитьОбработчикОжидания("ОбработатьШтрихкодПриИзменении", 0.1, Истина);
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьШтрихкодПриИзменении()
	ОбработатьШтрихкод(ШтрихкодПоиск);
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьКоличество(Разница)
	
	Если КоличествоРазмещено + Разница >= 0 Тогда
		
		КоличествоРазмещено = КоличествоРазмещено + Разница;
		
	КонецЕсли;
	
	СинхронизироватьДанныеСТаблицей();
	
КонецПроцедуры

&НаКлиенте
Процедура СинхронизироватьДанныеСТаблицей(ИзТаблицы = Ложь)
	Если Не ЗначениеЗаполнено(Номенклатура) Или Не ЗначениеЗаполнено(Ячейка) Тогда
		Возврат;
	КонецЕсли; 
	
	НайденнаяСтрока = Неопределено;	
	Для каждого СтрокаТаблицы Из Объект.ТоварыРазмещение Цикл	
		Если СтрокаТаблицы.Номенклатура = Номенклатура
			И СтрокаТаблицы.Ячейка = Ячейка Тогда
		
			НайденнаяСтрока = СтрокаТаблицы;
			Прервать;		
		КонецЕсли;	
	КонецЦикла;
	
	Если НайденнаяСтрока = Неопределено Тогда		
		Если Не ИзТаблицы И КоличествоРазмещено = 0 Тогда 
			Возврат;
		КонецЕсли;		
		НайденнаяСтрока = Объект.ТоварыРазмещение.Добавить();
		НайденнаяСтрока.Номенклатура = Номенклатура;
		НайденнаяСтрока.Упаковка = Упаковка;
		НайденнаяСтрока.Ячейка = Ячейка;		
	КонецЕсли;
	
	Если ИзТаблицы Тогда		
		КоличествоРазмещено = НайденнаяСтрока.КоличествоРазмещено;
		Количество = НайденнаяСтрока.Количество;
	Иначе		
		НайденнаяСтрока.КоличествоРазмещено = КоличествоРазмещено;
		Записать(Новый Структура("ВременнаяЗапись", Истина));
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеШтрихкодаСервер(Штрихкод, КэшированныеЗначения)
	
	РегистрыСведений.Сканирования.ЗарегистрироватьВводШтрихкода(Штрихкод);

	ДанныеШтрихкода = КэшированныеЗначения.Штрихкоды.Получить(Штрихкод);
	
	Если ДанныеШтрихкода = Неопределено Тогда 
		ДанныеШтрихкода = Штрихкодирование.ПолучитьДанныеПоШтрихкоду(Штрихкод, КэшированныеЗначения);
	КонецЕсли;
	
	Возврат ДанныеШтрихкода;
	
КонецФункции

&НаКлиенте
Функция ПолучитьДанныеПоШтрихкодуССервера(ШтрихкодаСтрока, КэшированныеЗначения)
	
	АдресРесурсаСПараметрами = СоединениеИПараметры.Параметры.АдресРесурса + "/infoOnBarcode?barcode=" + СокрЛП(ШтрихкодаСтрока);
	
	СтруктураОтвета = ОбменДаннымиКлиентСервер.ПолучитьОтвет(СоединениеИПараметры, АдресРесурсаСПараметрами, "GET");
	
	Если СтруктураОтвета = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Если СтруктураОтвета.error Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Ошибка в запросе: " + СтруктураОтвета.text;
		Сообщение.Сообщить();
	
		Возврат Неопределено;
		
	ИначеЕсли СтруктураОтвета.data = Неопределено 
		Или НЕ СтруктураОтвета.Свойство("type")
		Или СтруктураОтвета.type <> "Номенклатура" Тогда
	
		Возврат Неопределено;
		
	КонецЕсли;
	
	Номенклатура = ПолучитьСоздатьОбновитьСсылкуСервер(СтруктураОтвета.data.Номенклатура, "Номенклатура");
	Упаковка = ПолучитьСоздатьОбновитьСсылкуСервер(СтруктураОтвета.data.Упаковка, "Упаковки");
	
	ДанныеШтрихкода = Новый Структура("Штрихкод, Номенклатура, Упаковка", ШтрихкодаСтрока, Номенклатура, Упаковка);
	
	Если КэшированныеЗначения <> Неопределено И ЗначениеЗаполнено(ДанныеШтрихкода) Тогда
		КэшированныеЗначения.Штрихкоды.Вставить(ШтрихкодаСтрока, ДанныеШтрихкода);
	КонецЕсли;
	
	Возврат ДанныеШтрихкода;
	
КонецФункции

&НаСервереБезКонтекста
Функция ПолучитьСоздатьОбновитьСсылкуСервер(Данные, ИмяМенеджера)

	Возврат ОбменДаннымиСервер.ПолучитьСоздатьОбновитьСсылку(Данные, ИмяМенеджера);

КонецФункции

&НаСервере
Функция ПолучитьНастройкиСоединения()
	Возврат ОбменДаннымиСервер.ПолучитьНастройкиСоединения();	
КонецФункции

&НаКлиенте
Процедура УправлениеФормой()
	
	Элементы.ТоварыРазмещение.Видимость = КэшированныеЗначения.ПоказатьДетали;
		
	Если ТекущийЭтап = КэшированныеЗначения.ТекущийЭтап Тогда
		Возврат;
	КонецЕсли;
	
	Если ТекущийЭтап = "ОтобранныеТовары" Тогда
		СтрокаПодсказка = "Проверьте товары";
	ИначеЕсли ТекущийЭтап = "ВыборТовара" Тогда
		СтрокаПодсказка = "Отсканируйте штрихкод товара";
		Элементы.ГруппаОдиночная.Видимость = Ложь;
		Элементы.СброситьНоменклатуру.Видимость = Ложь;
	ИначеЕсли ТекущийЭтап = "СканЯчейки" Тогда
		СтрокаПодсказка = "Отсканируйте штрихкод ячейки";
		Элементы.ГруппаОдиночная.Видимость = Истина;
		Элементы.КоличествоРазмещено.Видимость = Ложь;
		Элементы.СброситьНоменклатуру.Видимость = Ложь;
	ИначеЕсли ТекущийЭтап = "ВводКоличества" Тогда
		СтрокаПодсказка = "Укажите количество товара";
		Элементы.ГруппаОдиночная.Видимость = Истина;
 		Элементы.КоличествоРазмещено.Видимость = Истина;
		Элементы.СброситьНоменклатуру.Видимость = Истина;
	Иначе 
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Этап """ + ТекущийЭтап + """ не обрабатывается";
		Сообщение.Сообщить();	
	КонецЕсли;
	
	КэшированныеЗначения.ТекущийЭтап = ТекущийЭтап;
	
КонецПроцедуры

&НаКлиенте
Процедура ОтобратьНоменклатуруВОтборе(СтруктураОтбора)
	Если ТипЗнч(СтруктураОтбора) = Тип("Структура") Тогда
		ОтборСтрок = Новый Структура("Номенклатура");
		ЗаполнитьЗначенияСвойств(ОтборСтрок, СтруктураОтбора);
		ОтборСтрок = Новый ФиксированнаяСтруктура(ОтборСтрок);
	Иначе 	
		ОтборСтрок = Неопределено;
	КонецЕсли;	
	
	Элементы.ТоварыОтбор.ОтборСтрок = ОтборСтрок;
КонецПроцедуры

&НаСервере
Функция СтруктураИзменениеСтатуса(Статус)
	Возврат ОбменДаннымиСервер.ЗаписатьJSONВСтроку(Новый Структура("Статус", Статус));			
КонецФункции

&НаКлиенте
Процедура УстановитьЯчейкиРазмещения(Номенклатура)
	
	ЯчейкиРазмещения = "";
	
	Для Каждого ТекСтрока Из Объект.ТоварыРазмещение Цикл
		
		НаименованиеЯчейки = Строка(ТекСтрока.Ячейка);
		
		Если ТекСтрока.Номенклатура = Номенклатура
			И Не СтрНайти(ЯчейкиРазмещения, НаименованиеЯчейки) Тогда
			ЯчейкиРазмещения = ЯчейкиРазмещения + ?(ЯчейкиРазмещения = "", "", ", ") + НаименованиеЯчейки;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция СтруктураДокумента(Документ)
	Возврат ОбменДаннымиСервер.ЗаписатьJSONВСтроку(Документ);			
КонецФункции

&НаСервере
Процедура ПерезаполнитьКоличествоШтук()
	КоличествоШтук = 0;
	Для Каждого ТекСтрока Из Объект.ТоварыОтбор Цикл 
		ТекСтрока.КоличествоШтук = ТекСтрока.Количество * ?(ТекСтрока.Упаковка.Знаменатель = 0, 1, ТекСтрока.Упаковка.Числитель/ТекСтрока.Упаковка.Знаменатель);	
		КоличествоШтук = КоличествоШтук + ТекСтрока.КоличествоШтук;	
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ВсеТоварыОтобраны()
	Для Каждого ТекСтрока Из Объект.ТоварыОтбор Цикл
		ТекСтрока.КоличествоОтобрано = ТекСтрока.Количество;
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ВопросПередЗаписьюЗавершение(Ответ, ДопПарметры) Экспорт
	Если Ответ = КодВозвратаДиалога.Да Тогда
		КэшированныеЗначения.МожноЗакрыть = Истина;
		Записать();
		Закрыть();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьЯчейкиОтбора()
	ТЗУпаковки = Объект.ТоварыОтбор.Выгрузить(, "Ячейка");
	ТЗУпаковки.Свернуть("Ячейка");
	ЯчейкиОтбора.ЗагрузитьЗначения(ТЗУпаковки.ВыгрузитьКолонку("Ячейка"));
КонецПроцедуры

&НаКлиенте
Процедура ЯчейкаПриИзменении(Элемент)
	Если ЗначениеЗаполнено(Ячейка) Тогда
		ТекущийЭтап = "ВводКоличества";
		СинхронизироватьДанныеСТаблицей(Истина);
	Иначе
		ТекущийЭтап = "СканЯчейки";
	КонецЕсли;
	УправлениеФормой();
КонецПроцедуры
	
#КонецОбласти
