﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	СтруктураУчетнаяПолитика = РегистрыСведений.УчетнаяПолитика.ПолучитьПоследнее(Дата);
	Если СтруктураУчетнаяПолитика.УчетнаяПолитика = Перечисления.ВидыУчетнойПолитики.FEFO Тогда
		ОтражатьСрокиГодности = Истина;
	Иначе
		ОтражатьСрокиГодности = Ложь;
	КонецЕсли; 
	
	Движения.ТоварыНаСкладах.Записывать = Истина;
	Движения.Хозрасчетный.Записывать = Истина;

	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("Ссылка", Ссылка);	
		
	Запрос.Текст="ВЫБРАТЬ
	             |	ПоступлениеТоваровТовары.Номенклатура КАК Номенклатура,
	             |	СУММА(ПоступлениеТоваровТовары.Количество) КАК Количество,
	             |	ПоступлениеТоваровТовары.Цена КАК Цена,
	             |	СУММА(ПоступлениеТоваровТовары.Сумма) КАК Сумма,
	             |	ПоступлениеТоваровТовары.СрокГодности КАК СрокГодности,
	             |	ПоступлениеТоваровТовары.Номенклатура.СчетБухгалтерскогоУчета КАК СчетБухгалтерскогоУчета
	             |ИЗ
	             |	Документ.ПоступлениеТоваров.Товары КАК ПоступлениеТоваровТовары
	             |ГДЕ
	             |	ПоступлениеТоваровТовары.Ссылка = &Ссылка
	             |
	             |СГРУППИРОВАТЬ ПО
	             |	ПоступлениеТоваровТовары.Номенклатура,
	             |	ПоступлениеТоваровТовары.Цена,
	             |	ПоступлениеТоваровТовары.СрокГодности,
	             |	ПоступлениеТоваровТовары.Номенклатура.СчетБухгалтерскогоУчета";
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ТоварыНаСкладах.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Номенклатура = Выборка.Номенклатура;
		Движение.Склад = Склад;
		Движение.Количество = Выборка.Количество;
        Если ОтражатьСрокиГодности Тогда
			Движение.СрокГодности= Выборка.СрокГодности;
		КонецЕсли;                                      
		Движение.Сумма = Выборка.Сумма; 
		
		Движение = Движения.Хозрасчетный.Добавить();
		Движение.СчетДт = Выборка.СчетБухгалтерскогоУчета;
		Движение.СчетКт = ПланыСчетов.Хозрасчетный.РасчетыСПоставщиками;
		Движение.Период = Дата;
		Движение.Сумма = Выборка.Сумма;
		Движение.СубконтоДт[ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура] = Выборка.Номенклатура;
		Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Контрагенты] = Поставщик;		
	КонецЦикла;
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если НЕ ЗначениеЗаполнено(Автор) Тогда
		Автор = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	СуммаДокумента = Товары.Итог("Сумма");
КонецПроцедуры
