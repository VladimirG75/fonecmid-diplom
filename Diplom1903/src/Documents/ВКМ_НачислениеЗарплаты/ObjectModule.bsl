#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда
	
#Область ОбработчикиСобытий 

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)
	
	Ответственный = Пользователи.ТекущийПользователь();
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)  
	
	Если ОсновныеНачисления.Количество() > 0 Тогда 
		
		МинимальнаяДатаНачала = НачалоМесяца(Дата);
		МаксимальнаяДатаОкончания = КонецМесяца(Дата); 
		
		Для Каждого Строка Из ОсновныеНачисления Цикл 
			
			Если  МинимальнаяДатаНачала > Строка.ДатаНачала Тогда
				МинимальнаяДатаНачала = Строка.ДатаНачала;
			КонецЕсли; 
			
			Если МаксимальнаяДатаОкончания < КонецДня(Строка.ДатаОкончания) Тогда
				МаксимальнаяДатаОкончания = КонецДня(Строка.ДатаОкончания);
			КонецЕсли;
			
		КонецЦикла;	
		
		СформироватьДвижения(); 
		
	КонецЕсли;
	
	СформироватьСторноЗаписи();
	
	РассчитатьОклад(МинимальнаяДатаНачала,МаксимальнаяДатаОкончания);
	
	РассчитатьОтпуск(МинимальнаяДатаНачала,МаксимальнаяДатаОкончания);
	
	РассчитатьНДФЛ();
	
	СформироватьВзаиморасчетыССотрудниками();

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИфункции

Процедура СформироватьДвижения() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.Сотрудник КАК Сотрудник,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ВидРасчета КАК ВидРасчета,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаНачала КАК ПериодДействияНачало,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаОкончания КАК ПериодДействияОкончание,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ГрафикРаботы КАК ГрафикРаботы,
	               |	МАКСИМУМ(ВКМ_УсловияОплатыСотрудников.Период) КАК Период
	               |ПОМЕСТИТЬ ВТ_ДанныеПоОкладам
	               |ИЗ
	               |	Документ.ВКМ_НачислениеЗарплаты.ОсновныеНачисления КАК ВКМ_НачислениеЗарплатыОсновныеНачисления
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ВКМ_УсловияОплатыСотрудников КАК ВКМ_УсловияОплатыСотрудников
	               |		ПО ВКМ_НачислениеЗарплатыОсновныеНачисления.Сотрудник = ВКМ_УсловияОплатыСотрудников.Сотрудник
	               |			И ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаНачала >= ВКМ_УсловияОплатыСотрудников.Период
	               |ГДЕ
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.Ссылка = &Ссылка
	               |	И ВКМ_НачислениеЗарплатыОсновныеНачисления.ВидРасчета = &Оклад
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.Сотрудник,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ВидРасчета,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаНачала,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаОкончания,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ГрафикРаботы
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_ДанныеПоОкладам.Сотрудник КАК Сотрудник,
	               |	ВТ_ДанныеПоОкладам.ВидРасчета КАК ВидРасчета,
	               |	ВТ_ДанныеПоОкладам.ПериодДействияНачало КАК ПериодДействияНачало,
	               |	ВТ_ДанныеПоОкладам.ПериодДействияОкончание КАК ПериодДействияКонец,
	               |	ВТ_ДанныеПоОкладам.ГрафикРаботы КАК ГрафикРаботы,
	               |	ВКМ_УсловияОплатыСотрудников.Оклад КАК Показатель,
	               |	NULL КАК БазовыйПериодНачало,
	               |	NULL КАК БазовыйПериодКонец
	               |ИЗ
	               |	РегистрСведений.ВКМ_УсловияОплатыСотрудников КАК ВКМ_УсловияОплатыСотрудников
	               |		ПРАВОЕ СОЕДИНЕНИЕ ВТ_ДанныеПоОкладам КАК ВТ_ДанныеПоОкладам
	               |		ПО (ВТ_ДанныеПоОкладам.Сотрудник = ВКМ_УсловияОплатыСотрудников.Сотрудник)
	               |			И (ВТ_ДанныеПоОкладам.Период = ВКМ_УсловияОплатыСотрудников.Период)
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.Сотрудник,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ВидРасчета,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаНачала,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаОкончания,
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.ГрафикРаботы,
	               |	NULL,
	               |	НАЧАЛОПЕРИОДА(ДОБАВИТЬКДАТЕ(ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаНачала, МЕСЯЦ, -12), МЕСЯЦ),
	               |	КОНЕЦПЕРИОДА(ДОБАВИТЬКДАТЕ(ВКМ_НачислениеЗарплатыОсновныеНачисления.ДатаНачала, МЕСЯЦ, -1), МЕСЯЦ)
	               |ИЗ
	               |	Документ.ВКМ_НачислениеЗарплаты.ОсновныеНачисления КАК ВКМ_НачислениеЗарплатыОсновныеНачисления
	               |ГДЕ
	               |	ВКМ_НачислениеЗарплатыОсновныеНачисления.Ссылка = &Ссылка
	               |	И ВКМ_НачислениеЗарплатыОсновныеНачисления.ВидРасчета = &Отпуск";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Оклад", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад); 
	Запрос.УстановитьПараметр("Отпуск", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск); 
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	// Движения по регистру ВКМ_ОсновныеНачисления
	Пока Выборка.Следующий() Цикл 
		Движение = Движения.ВКМ_ОсновныеНачисления.Добавить();
		Движение.ПериодРегистрации = НачалоМесяца(Дата);
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
	КонецЦикла;
	
	// Движения по регистру ВКМ_ДополнительныеНачисления
   	Для Каждого Строка Из ДополнительныеНачисления Цикл
		Движение = Движения.ВКМ_ДополнительныеНачисления.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
       	Движение.ВидРасчета = Строка.ВидРасчета;
		Движение.Сотрудник = Строка.Сотрудник;
		Движение.Результат = Строка.СуммаНачисления;
	КонецЦикла;
		
	Движения.ВКМ_ОсновныеНачисления.Записать();
	Движения.ВКМ_ДополнительныеНачисления.Записать();
	
КонецПроцедуры 

Процедура СформироватьСторноЗаписи()
      
      СторноЗаписи = Движения.ВКМ_ОсновныеНачисления.ПолучитьДополнение();
      
      Если Не ЗначениеЗаполнено(СторноЗаписи) Тогда
    	  Возврат;
      КонецЕсли; 
      
	  Для Каждого Запись Из СторноЗаписи Цикл
		  
    	  // Движения по регистру ВКМ_ОсновныеНачисления
    	  Движение = Движения.ВКМ_ОсновныеНачисления.Добавить();
    	  ЗаполнитьЗначенияСвойств(Движение, Запись);
		  Движение.Сторно = Истина;
          Движение.ПериодРегистрации = Дата;
    	  Движение.ПериодДействияНачало = Запись.ПериодДействияНачалоСторно;
    	  Движение.ПериодДействияКонец = Запись.ПериодДействияКонецСторно;
    	      	  
      КонецЦикла;
      
	  Движения.ВКМ_ОсновныеНачисления.Записать();
	
КонецПроцедуры


Процедура РассчитатьОклад(МинимальнаяДатаНачала,МаксимальнаяДатаОкончания)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеПериодДействия, 0) / 8 КАК НормаДней,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия, 0) / 8 КАК Факт
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
	               |			Регистратор = &Ссылка
	               |				И ВидРасчета = &Оклад) КАК ВКМ_ОсновныеНачисленияДанныеГрафика"; 
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Оклад", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Оклад);
		
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		
		// Движения по регистру ВКМ_ОсновныеНачисления
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.НормаДней = Выборка.НормаДней; 
		Движение.Результат = ?(Выборка.НормаДней <> 0,
		Движение.Показатель * Выборка.Факт / Выборка.НормаДней, 0);
		Движение.ОтработаноДней = Выборка.Факт;
		
		Если Движение.Сторно Тогда
			Движение.Результат = - Движение.Результат;
			Движение.ОтработаноДней = - Движение.ОтработаноДней;
		КонецЕсли;

	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
		
   КонецПроцедуры

Процедура РассчитатьОтпуск(МинимальнаяДатаНачала,МаксимальнаяДатаОкончания)
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.РезультатБаза, 0) КАК БазаНачислений,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.ОтработаноДнейБаза, 0) КАК ОтработаноДнейБаза,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисленияДанныеГрафика.ЗначениеФактическийПериодДействия, 0) / 8 КАК ДнейОтпуска
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.БазаВКМ_ОсновныеНачисления(
	               |				&Измерения,
	               |				&Измерения,
	               |				,
	               |				ВидРасчета = &Отпуск
	               |					И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления
	               |		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияБазаВКМ_ОсновныеНачисления.НомерСтроки
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_ОсновныеНачисления.ДанныеГрафика(
	               |				ВидРасчета = &Отпуск
	               |					И Регистратор = &Ссылка) КАК ВКМ_ОсновныеНачисленияДанныеГрафика
	               |		ПО ВКМ_ОсновныеНачисления.НомерСтроки = ВКМ_ОсновныеНачисленияДанныеГрафика.НомерСтроки
	               |ГДЕ
	               |	ВКМ_ОсновныеНачисления.ВидРасчета = &Отпуск
	               |	И ВКМ_ОсновныеНачисления.Регистратор = &Ссылка"; 
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Отпуск", ПланыВидовРасчета.ВКМ_ОсновныеНачисления.Отпуск);
	
	Измерения = Новый Массив; 
	Измерения.Добавить("Сотрудник");
	Запрос.УстановитьПараметр("Измерения", Измерения);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	// Движения по регистру ВКМ_ОсновныеНачисления
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ОсновныеНачисления[Выборка.НомерСтроки -1];
		Движение.ДнейОтработаноПоБазе = Выборка.ОтработаноДнейБаза;
		Движение.Показатель = Выборка.БазаНачислений;
		Движение.Результат = ?(Выборка.ОтработаноДнейБаза <> 0,
		Выборка.ДнейОтпуска * Выборка.БазаНачислений / Выборка.ОтработаноДнейБаза, 0);
		ЗаполнитьЗначенияСвойств(Движение, Выборка);
		
		Если Движение.Сторно Тогда
			
			Движение.Результат = - Движение.Результат; 
			
		КонецЕсли;
		
	КонецЦикла;
	
	Движения.ВКМ_ОсновныеНачисления.Записать(, Истина);
	
КонецПроцедуры

Процедура РассчитатьНДФЛ() 
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
	               |	СУММА(ВКМ_ОсновныеНачисления.Результат) КАК Результат
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
	               |ГДЕ
	               |	ВКМ_ОсновныеНачисления.Регистратор.Ссылка = &Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВКМ_ОсновныеНачисления.Сотрудник
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	ВКМ_ДополнительныеНачисления.Сотрудник,
	               |	СУММА(ВКМ_ДополнительныеНачисления.Результат)
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
	               |ГДЕ
	               |	ВКМ_ДополнительныеНачисления.Регистратор.Ссылка = &Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВКМ_ДополнительныеНачисления.Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
		
	Выборка = Запрос.Выполнить().Выбрать(); 
	
	// Движения по регистру ВКМ_Удержания
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.ВидРасчета = ПланыВидовРасчета.ВКМ_Удержания.НДФЛ;
		Движение.НДФЛ = (Выборка.Результат * 13) / 100;
	КонецЦикла;	
	
	Движения.ВКМ_Удержания.Записать(); 
			
КонецПроцедуры

Процедура СформироватьВзаиморасчетыССотрудниками()
		
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ВКМ_ОсновныеНачисления.Сотрудник КАК Сотрудник,
	               |	ЕСТЬNULL(ВКМ_ОсновныеНачисления.Результат, 0) КАК Результат
	               |ПОМЕСТИТЬ ВТ_Начисления
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ОсновныеНачисления КАК ВКМ_ОсновныеНачисления
	               |ГДЕ
	               |	ВКМ_ОсновныеНачисления.Регистратор = &Ссылка
	               |
	               |ОБЪЕДИНИТЬ ВСЕ
	               |
	               |ВЫБРАТЬ
	               |	ВКМ_ДополнительныеНачисления.Сотрудник,
	               |	ЕСТЬNULL(ВКМ_ДополнительныеНачисления.Результат, 0)
	               |ИЗ
	               |	РегистрРасчета.ВКМ_ДополнительныеНачисления КАК ВКМ_ДополнительныеНачисления
	               |ГДЕ
	               |	ВКМ_ДополнительныеНачисления.Регистратор = &Ссылка
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_Начисления.Сотрудник КАК Сотрудник,
	               |	СУММА(ВТ_Начисления.Результат) КАК Результат
	               |ПОМЕСТИТЬ ВТ_ГРуппировка
	               |ИЗ
	               |	ВТ_Начисления КАК ВТ_Начисления
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВТ_Начисления.Сотрудник
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_ГРуппировка.Сотрудник КАК Сотрудник,
	               |	ВТ_ГРуппировка.Результат КАК Результат,
	               |	СУММА(ВКМ_Удержания.НДФЛ) КАК НДФЛ
	               |ИЗ
	               |	ВТ_ГРуппировка КАК ВТ_ГРуппировка
	               |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.ВКМ_Удержания КАК ВКМ_Удержания
	               |		ПО ВТ_ГРуппировка.Сотрудник = ВКМ_Удержания.Сотрудник
	               |ГДЕ
	               |	ВКМ_Удержания.Регистратор = &Ссылка
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	ВТ_ГРуппировка.Сотрудник,
	               |	ВТ_ГРуппировка.Результат";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	// Движения по регистру ВКМ_ВзаиморасчетыССотрудниками
	Пока Выборка.Следующий() Цикл
		Движение = Движения.ВКМ_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход;
		Движение.Период = Дата;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.Сумма = Выборка.Результат - Выборка.НДФЛ;
	КонецЦикла;	
	
	Движения.ВКМ_ВзаиморасчетыССотрудниками.Записать();	
			
КонецПроцедуры 

#КонецОбласти

#КонецЕсли