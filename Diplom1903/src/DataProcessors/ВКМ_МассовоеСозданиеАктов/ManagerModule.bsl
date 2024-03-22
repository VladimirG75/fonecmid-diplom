#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

//Создание списка документов Реализации товаров и услуг за указанный период.
//@skip-check doc-comment-parameter-section
//@skip-check doc-comment-export-function-return-section
Функция СоздатьСписокНаСервере(Знач ДатаНачала, Знач ДатаОкончания) Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	ДоговорыКонтрагентов.Ссылка КАК Договор,
	               |	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	               |	ДоговорыКонтрагентов.Организация КАК Организация,
	               |	ДоговорыКонтрагентов.Представление КАК Представление
	               |ПОМЕСТИТЬ ВТ_ВсеДоговоры
	               |ИЗ
	               |	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	               |ГДЕ
	               |	ДоговорыКонтрагентов.ВидДоговора = &ВидДоговора
	               |	И ДоговорыКонтрагентов.ВКМ_ДатаОкончанияДействияДоговора >= &ДатаНачала
	               |	И ДоговорыКонтрагентов.ВКМ_ДатаНачалаДействияДоговора <= &ДатаОкончания
	               |	И НЕ ДоговорыКонтрагентов.ПометкаУдаления
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_ВсеДоговоры.Договор КАК Договор,
	               |	ВТ_ВсеДоговоры.Контрагент КАК Контрагент,
	               |	ВТ_ВсеДоговоры.Организация КАК Организация,
	               |	РеализацияТоваровУслуг.Ссылка КАК Реализация
	               |ПОМЕСТИТЬ ВТ_Реализация
	               |ИЗ
	               |	ВТ_ВсеДоговоры КАК ВТ_ВсеДоговоры
	               |		ЛЕВОЕ СОЕДИНЕНИЕ Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	               |		ПО ВТ_ВсеДоговоры.Договор = РеализацияТоваровУслуг.Договор
	               |			И ВТ_ВсеДоговоры.Контрагент = РеализацияТоваровУслуг.Контрагент
	               |			И ВТ_ВсеДоговоры.Организация = РеализацияТоваровУслуг.Организация
	               |ГДЕ
	               |	РеализацияТоваровУслуг.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания
	               |	И НЕ РеализацияТоваровУслуг.ПометкаУдаления
	               |;
	               |
	               |////////////////////////////////////////////////////////////////////////////////
	               |ВЫБРАТЬ
	               |	ВТ_ВсеДоговоры.Договор КАК Договор,
	               |	ВТ_ВсеДоговоры.Контрагент КАК Контрагент,
	               |	ВТ_ВсеДоговоры.Организация КАК Организация,
	               |	ВТ_ВсеДоговоры.Представление КАК ДоговорПредставление,
	               |	ЕСТЬNULL(ВТ_Реализация.Реализация, ЗНАЧЕНИЕ(Документ.РеализацияТоваровУслуг.ПустаяСсылка)) КАК РеализацияТоваровИУслуг,
	               |	ВТ_Реализация.Реализация.Представление КАК РеализацияПредставление
	               |ИЗ
	               |	ВТ_ВсеДоговоры КАК ВТ_ВсеДоговоры
	               |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_Реализация КАК ВТ_Реализация
	               |		ПО ВТ_ВсеДоговоры.Договор = ВТ_Реализация.Договор";
	
		
	Запрос.УстановитьПараметр("ВидДоговора", ПредопределенноеЗначение("Перечисление.ВидыДоговоровКонтрагентов.ВКМ_АбонентскоеОбслуживание"));
	Запрос.УстановитьПараметр("ДатаНачала", ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", ДатаОкончания);
			
	Выборка = Запрос.Выполнить().Выбрать();
	
	ТаблицаДоговоров = Новый ТаблицаЗначений;
	ТаблицаДоговоров.Колонки.Добавить("Договор", Новый ОписаниеТипов("СправочникСсылка.ДоговорыКонтрагентов"));
	ТаблицаДоговоров.Колонки.Добавить("Реализация", Новый ОписаниеТипов("ДокументСсылка.РеализацияТоваровУслуг"));
    		
	Пока Выборка.Следующий() Цикл
		Если Выборка.РеализацияТоваровИУслуг = Документы.РеализацияТоваровУслуг.ПустаяСсылка() Тогда 
			
			ДокументРеализации = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
			ДокументРеализации.Дата = КонецМесяца(ДатаОкончания); 
			ДокументРеализации.Ответственный = Пользователи.ТекущийПользователь(); 
			ДокументРеализации.Комментарий = "Документ создан автоматической обработкой Массовое создание актов.";
			ДокументРеализации.Заполнить(Выборка);
			
			ЗаполнитьЗначенияСвойств(ДокументРеализации, Выборка);
			
			ДокументРеализации.ВКМ_ВыполнитьАвтоЗаполнение();
			
			Если ДокументРеализации.ПроверитьЗаполнение() Тогда
				
				ДокументРеализации.Записать(РежимЗаписиДокумента.Проведение);
				
				СтрокаТабДоговоров = ТаблицаДоговоров.Добавить();
				СтрокаТабДоговоров.Договор = ДокументРеализации.Договор;
				СтрокаТабДоговоров.Реализация = ДокументРеализации.Ссылка;
			Иначе
				СтрокаТабДоговоров = ТаблицаДоговоров.Добавить();
				ЗаполнитьЗначенияСвойств(СтрокаТабДоговоров, Выборка);
			КонецЕсли;	
		КонецЕсли;
		
	КонецЦикла;	
	
	Возврат ОбщегоНазначения.ТаблицаЗначенийВМассив(ТаблицаДоговоров);

КонецФункции 

#КонецОбласти

#КонецЕсли 


  


  