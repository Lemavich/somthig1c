﻿Процедура ОбработкаЗаполнения(ДанныеЗаполнения, СтандартнаяОбработка)
	
	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаписьКлиента") Тогда
		Автор = ДанныеЗаполнения.Автор;
		Клиент = ДанныеЗаполнения.Клиент;
		Комментарий = ДанныеЗаполнения.Комментарий;
		Сотрудник = ДанныеЗаполнения.Сотрудник;
		ДокументОснование = ДанныеЗаполнения.Ссылка;
		Для Каждого ТекСтрокаУслуги Из ДанныеЗаполнения.Услуги Цикл
			НоваяСтрока = Услуги.Добавить();
			НоваяСтрока.Номенклатура = ТекСтрокаУслуги.Номенклатура;
			НоваяСтрока.Сумма = ТекСтрокаУслуги.Сумма;
		КонецЦикла;       
	КонецЕсли;
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

 
	Движения.Продажи.Записывать = Истина;  
	Движения.ЗаказыКлиентов.Записывать = Истина; 
	Движения.ТоварыНаСкладах.Записывать = Истина;
	Движения.УчетЗатрат.Записывать = Истина;
	Движения.Хозрасчетный.Записывать = Истина;
	
	Движения.ТоварыНаСкладах.Записать();
	Движения.Продажи.Записать();
	Движения.УчетЗатрат.Записать();	
	          
	Блокировка = Новый БлокировкаДанных;
	ЭлементБлокировки = Блокировка.Добавить("РегистрНакопления.ТоварыНаСкладах");
	ЭлементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
	ЭлементБлокировки.ИсточникДанных = Товары;
	ЭлементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура","Номенклатура");
	ЭлементБлокировки.УстановитьЗначение("Склад", Склад);
	Блокировка.Заблокировать();
		                   
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	Запрос.Текст ="ВЫБРАТЬ
	              |	РеализацияТоваровИУслугТовары.Номенклатура КАК Номенклатура,
	              |	РеализацияТоваровИУслуг.Склад КАК Склад,
	              |	СУММА(РеализацияТоваровИУслугТовары.Количество) КАК Количество,
	              |	СУММА(РеализацияТоваровИУслугТовары.Сумма) КАК Сумма
	              |ПОМЕСТИТЬ ВТ_Товары
	              |ИЗ
	              |	Документ.РеализацияТоваровИУслуг КАК РеализацияТоваровИУслуг
	              |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровИУслуг.Товары КАК РеализацияТоваровИУслугТовары
	              |		ПО РеализацияТоваровИУслуг.Ссылка = РеализацияТоваровИУслугТовары.Ссылка
	              |ГДЕ
	              |	РеализацияТоваровИУслугТовары.Ссылка = &Ссылка
	              |
	              |СГРУППИРОВАТЬ ПО
	              |	РеализацияТоваровИУслугТовары.Номенклатура,
	              |	РеализацияТоваровИУслуг.Склад
	              |
	              |ОБЪЕДИНИТЬ ВСЕ
	              |
	              |ВЫБРАТЬ
	              |	РеализацияТоваровИУслугУслуги.Номенклатура,
	              |	NULL,
	              |	NULL,
	              |	СУММА(РеализацияТоваровИУслугУслуги.Сумма)
	              |ИЗ
	              |	Документ.РеализацияТоваровИУслуг.Услуги КАК РеализацияТоваровИУслугУслуги
	              |ГДЕ
	              |	РеализацияТоваровИУслугУслуги.Ссылка = &Ссылка
	              |
	              |СГРУППИРОВАТЬ ПО
	              |	РеализацияТоваровИУслугУслуги.Номенклатура
	              |
	              |ИНДЕКСИРОВАТЬ ПО
	              |	Номенклатура,
	              |	Склад
	              |;
	              |
	              |////////////////////////////////////////////////////////////////////////////////
	              |ВЫБРАТЬ
	              |	ВТ_Товары.Номенклатура КАК Номенклатура,
	              |	ВЫБОР
	              |		КОГДА ВТ_Товары.Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга)
	              |			ТОГДА ЛОЖЬ
	              |		ИНАЧЕ ИСТИНА
	              |	КОНЕЦ КАК ЭтоТовар,
	              |	ВТ_Товары.Номенклатура.Представление КАК НоменклатураПредставление,
	              |	ВТ_Товары.Количество КАК КоличествоВДокументе,
	              |	ВТ_Товары.Сумма КАК СуммаВДокументе,
	              |	ВТ_Товары.Склад КАК Склад,
	              |	ТоварыНаСкладахОстатки.СрокГодности КАК СрокГодности,
	              |	ЕСТЬNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
	              |	ЕСТЬNULL(ТоварыНаСкладахОстатки.СуммаОстаток, 0) КАК СуммаОстаток,
	              |	ВТ_Товары.Номенклатура.СтатьяЗатрат КАК СтатьяЗатрат,
	              |	ВТ_Товары.Номенклатура.СчетБухгалтерскогоУчета КАК СчетБухгалтерскогоУчета
	              |ИЗ
	              |	ВТ_Товары КАК ВТ_Товары
	              |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
	              |				&МоментВремени,
	              |				(Номенклатура, Склад) В
	              |					(ВЫБРАТЬ
	              |						ВТ_Товары.Номенклатура,
	              |						ВТ_Товары.Склад
	              |					ИЗ
	              |						ВТ_Товары КАК ВТ_Товары)) КАК ТоварыНаСкладахОстатки
	              |		ПО ВТ_Товары.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
	              |			И ВТ_Товары.Склад = ТоварыНаСкладахОстатки.Склад
	              |
	              |УПОРЯДОЧИТЬ ПО
	              |	СрокГодности
	              |ИТОГИ
	              |	МАКСИМУМ(КоличествоВДокументе),
	              |	МАКСИМУМ(СуммаВДокументе),
	              |	СУММА(КоличествоОстаток)
	              |ПО
	              |	Номенклатура";
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("МоментВремени", Новый Граница(МоментВремени()));


	ВыборкаНоменклатура = 
	Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаНоменклатура.Следующий() Цикл //1
		Если ВыборкаНоменклатура.ЭтоТовар Тогда //2

	        СтоимостьОбщая = 0; //3

	        Превышение = ВыборкаНоменклатура.КоличествоВДокументе - ВыборкаНоменклатура.КоличествоОстаток; //4
	        Если Превышение > 0 И Константы.ЗапретПроведенияПриОтрицательныхОстатках.Получить() Тогда //5
	            Сообщение = Новый СообщениеПользователю;
	            Сообщение.Текст = СтрШаблон("Превышение остатка по номенклатуре ""%1""  в количестве ""%2""", 
				ВыборкаНоменклатура.НоменклатураПредставление, Превышение);
	            Сообщение.Сообщить();
	            Отказ = Истина;
			ИначеЕсли Превышение > 0 И Константы.ЗапретПроведенияПриОтрицательныхОстатках.Получить()=Ложь Тогда 
				Сообщение = Новый СообщениеПользователю;
	            Сообщение.Текст = СтрШаблон("Образовались отрицательные остатки по номенклатуре ""%1""  в количестве ""%2""", 
				ВыборкаНоменклатура.НоменклатураПредставление, Превышение);
	            Сообщение.Сообщить();
	        КонецЕсли;

	        Если Отказ Тогда //6
	            Продолжить;
	        КонецЕсли;
			
	        ОсталосьСписать = ВыборкаНоменклатура.КоличествоВДокументе; //7
			ВыборкаДетальные = ВыборкаНоменклатура.Выбрать();
			
			
			Для Счётчик = 0 По ВыборкаДетальные.Количество()-1 Цикл
				ВыборкаДетальные.Следующий();
				Если ОсталосьСписать <= 0 Тогда
					Прервать;
				КонецЕсли;
				Если Константы.ЗапретПроведенияПриОтрицательныхОстатках.Получить()=Ложь Тогда
					Если Счётчик = ВыборкаДетальные.Количество()-1 Тогда
						Списываем = Мин (ВыборкаДетальные.КоличествоОстаток, ОсталосьСписать);
			            Движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
			            Движение.Период = Дата;
						ЗаполнитьЗначенияСвойств(Движение, ВыборкаДетальные, "Номенклатура, Склад, СрокГодности",);
						Движение.Количество = Списываем;
			            Если Списываем = ВыборкаДетальные.КоличествоОстаток Тогда //9
			                Движение.Сумма = ВыборкаДетальные.СуммаОстаток;
			            Иначе
			                Движение.Сумма = Списываем / ВыборкаДетальные.КоличествоОстаток * ВыборкаДетальные.СуммаОстаток;
						КонецЕсли;
						Если (ОсталосьСписать-Списываем) > 0 Тогда
	                        ОсталосьСписать = ОсталосьСписать - Списываем; //10
				            Движение = Движения.ТоварыНаСкладах.ДобавитьРасход(); 
				            Движение.Период = Дата;
							ЗаполнитьЗначенияСвойств(Движение, ВыборкаДетальные, "Номенклатура, Склад",);
							Движение.Количество = ОсталосьСписать;
			                Движение.Сумма = ОсталосьСписать / ВыборкаДетальные.КоличествоОстаток * ВыборкаДетальные.СуммаОстаток;
						КонецЕсли;
						
					Иначе
						Списываем = Мин (ВыборкаДетальные.КоличествоОстаток, ОсталосьСписать);
						Движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
						Движение.Период = Дата;
						ЗаполнитьЗначенияСвойств(Движение, ВыборкаДетальные, "Номенклатура, Склад, СрокГодности",);
						Движение.Количество = Списываем;
						Если Списываем = ВыборкаДетальные.КоличествоОстаток Тогда //9
							Движение.Сумма = ВыборкаДетальные.СуммаОстаток;
						Иначе
							Движение.Сумма = Списываем / ВыборкаДетальные.КоличествоОстаток * ВыборкаДетальные.СуммаОстаток;
						КонецЕсли;	
						ОсталосьСписать = ОсталосьСписать - Списываем; //10
			            СтоимостьОбщая = СтоимостьОбщая + Движение.Сумма;

						
					КонецЕсли;	
					
				Иначе

		            Списываем = Мин (ВыборкаДетальные.КоличествоОстаток, ОсталосьСписать);
		            Движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
		            Движение.Период = Дата;
					ЗаполнитьЗначенияСвойств(Движение, ВыборкаДетальные, "Номенклатура, Склад, СрокГодности",);
		            Движение.Количество = Списываем;
		            Если Списываем = ВыборкаДетальные.КоличествоОстаток Тогда //9
		                Движение.Сумма = ВыборкаДетальные.СуммаОстаток;
		            Иначе
		                Движение.Сумма = Списываем / ВыборкаДетальные.КоличествоОстаток * ВыборкаДетальные.СуммаОстаток;
		            КонецЕсли;

		            ОсталосьСписать = ОсталосьСписать - Списываем; //10
		            СтоимостьОбщая = СтоимостьОбщая + Движение.Сумма;  
				КонецЕсли;
				
				
				//Проводка по списанию товаров и материалов Дт90 Кт10/41
				Движение = Движения.Хозрасчетный.Добавить();
				Движение.СчетДт = ПланыСчетов.Хозрасчетный.Продажи;
				Движение.СчетКт = ВыборкаНоменклатура.СчетБухгалтерскогоУчета;
				Движение.СубконтоКт[ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.Номенклатура] = ВыборкаДетальные.Номенклатура; 
				Движение.Период    = Дата;    
				Движение.Сумма = СтоимостьОбщая;
				Движение.Содержание    = "Списана себестоимость товарно-материальных ценностей";
			КонецЦикла;


	        Движение = Движения.УчетЗатрат.Добавить(); //11
	        Движение.Период = Дата;
	        Движение.СтатьяЗатрат = ВыборкаНоменклатура.СтатьяЗатрат;
	        Движение.Сумма = СтоимостьОбщая;

	    КонецЕсли;

	    Движение = Движения.Продажи.Добавить(); //13
	    Движение.Период = Дата;
	    Движение.Номенклатура = ВыборкаНоменклатура.Номенклатура;
	    Движение.Сотрудник = Сотрудник;
	    Движение.Клиент = Клиент;
	    Движение.Сумма = ВыборкаНоменклатура.СуммаВДокументе;

	КонецЦикла;
		


	Если 	 ЗначениеЗаполнено(ДокументОснование) Тогда
		// регистр ЗаказыКлиентов Расход
		Движение = Движения.ЗаказыКлиентов.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Клиент = Клиент;
		Движение.ЗаписьКлиента = Ссылка.ДокументОснование;
		Движение.Сумма = Услуги.Итог("Сумма"); 
	КонецЕсли;

	//Проводка по отражению выручки Дт62 Кт90
	Движение = Движения.Хозрасчетный.Добавить();
	Движение.СчетДт = ПланыСчетов.Хозрасчетный.РасчетыСПокупателями;
	Движение.СчетКт = ПланыСчетов.Хозрасчетный.Продажи;
	БухгалтерскийУчет.ЗаполнитьСубконтоПоСчету(Движение.СчетДт, Движение.СубконтоДт, Клиент);
	Движение.Период = Дата;
	Движение.Сумма = СуммаДокумента;
	Движение.Содержание = "Отражена выручка от реализации товаров и услуг";		
	
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	Если НЕ ЗначениеЗаполнено(Автор) Тогда
		Автор = ПараметрыСеанса.ТекущийПользователь;
	КонецЕсли;
	СуммаДокумента = Услуги.Итог("Сумма") + Товары.Итог("Сумма");   
	
	Если ЗначениеЗаполнено(Ссылка)
	И ПризнакОплаты <> Перечисления.ОплатаДокумента.ПолностьюОплачен Тогда
	    СтруктураОплаты = Документы.РеализацияТоваровИУслуг.ПроверитьОплатуДокумента(Ссылка);
	    ПризнакОплаты = СтруктураОплаты.ПризнакОплаты;
	КонецЕсли;
КонецПроцедуры

