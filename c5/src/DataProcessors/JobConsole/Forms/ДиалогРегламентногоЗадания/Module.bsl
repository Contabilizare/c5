&НаКлиенте
Перем Расписание;

&НаКлиенте
Процедура ОК(Команда)
	Если ЗаписатьРегламентноеЗадание(Расписание) Тогда
		Закрыть(РегламентноеЗаданиеИД);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ИзменитьРасписаниеНажатие ( Элемент )
	
	#if ( not MobileClient ) then
		dialog = new ScheduledJobDialog ( Расписание );
		dialog.Show ( new NotifyDescription ( "selectSchedule", ThisObject, ) );	
	#endif
	
КонецПроцедуры

&AtClient
Procedure selectSchedule ( Result, Params ) export
	
	if ( Result = undefined ) then
		return;
	endif; 
	Расписание = Result;
	Элементы.НадписьРасписание.Заголовок = "Выполнять: " + Строка ( Расписание );
	
EndProcedure

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Для Каждого Метаданное из Метаданные.РегламентныеЗадания Цикл
		Элементы.МетаданныеВыбор.СписокВыбора.Добавить(Метаданное.Имя, Метаданное.Представление());
	КонецЦикла;
	
	//Попытка
	//	Пользователи = ПользователиИнформационнойБазы.ПолучитьПользователей();
	//Исключение
	//	Сообщить("Ошибка при получении списка пользователей информационной базы: " + ОписаниеОшибки());
	//	Пользователи = Неопределено;
	//КонецПопытки;
	//
	//Если Пользователи <> Неопределено Тогда
	//	
	//	Для Каждого Пользователь из Пользователи Цикл
	//		Элементы.ПользователиВыбор.СписокВыбора.Добавить(Пользователь.Имя, Пользователь.ПолноеИмя);
	//	КонецЦикла;
	//
	//КонецЕсли;

	мВозможностьИзменятьМетаданные = Истина;
	
	РегламентноеЗаданиеИД = Параметры.ИдентификаторЗадания;
	РегламентноеЗадание = Обработки.JobConsole.Создать().ПолучитьОбъектРегламентногоЗадания(РегламентноеЗаданиеИД);
	Если РегламентноеЗадание <> Неопределено Тогда
		
		МетаданныеВыбор = РегламентноеЗадание.Метаданные.Имя;
		
		мВозможностьИзменятьМетаданные = Ложь;
		Наименование = РегламентноеЗадание.Наименование;
		Ключ = РегламентноеЗадание.Ключ;
		Использование = РегламентноеЗадание.Использование;
		ПользователиВыбор = РегламентноеЗадание.ИмяПользователя;
		КоличествоПовторовПриАварийномЗавершении = РегламентноеЗадание.КоличествоПовторовПриАварийномЗавершении;
		ИнтервалПовтораПриАварийномЗавершении = РегламентноеЗадание.ИнтервалПовтораПриАварийномЗавершении;
		
		Расписание = РегламентноеЗадание.Расписание;
	Иначе
		Расписание = Новый РасписаниеРегламентногоЗадания;
	КонецЕсли;
	
	Элементы.МетаданныеВыбор.Доступность = мВозможностьИзменятьМетаданные;
	Элементы.НадписьРасписание.Заголовок = "Выполнять: " + Строка(Расписание);

КонецПроцедуры

&НаСервере
Функция ЗаписатьРегламентноеЗадание(Расписание)
	Попытка
		
		Если МетаданныеВыбор = Неопределено ИЛИ МетаданныеВыбор = "" Тогда
			ВызватьИсключение("Не выбраны метаданные регламентного задания.");
		КонецЕсли;
		
		РегламентноеЗадание = Обработки.JobConsole.Создать().ПолучитьОбъектРегламентногоЗадания(РегламентноеЗаданиеИД);
		
		Если РегламентноеЗадание = Неопределено Тогда
			РегламентноеЗадание = РегламентныеЗадания.СоздатьРегламентноеЗадание(МетаданныеВыбор);
			РегламентноеЗаданиеИД = РегламентноеЗадание.УникальныйИдентификатор;
		КонецЕсли;
		
		РегламентноеЗадание.Наименование = Наименование;
		РегламентноеЗадание.Ключ = Ключ;
		РегламентноеЗадание.Использование = Использование;
		РегламентноеЗадание.ИмяПользователя = ПользователиВыбор;
		РегламентноеЗадание.КоличествоПовторовПриАварийномЗавершении = КоличествоПовторовПриАварийномЗавершении;
		РегламентноеЗадание.ИнтервалПовтораПриАварийномЗавершении = ИнтервалПовтораПриАварийномЗавершении;
		РегламентноеЗадание.Расписание = Расписание;
		
		РегламентноеЗадание.Записать();
	Исключение	
		
		Сообщить("Ошибка: " + ОписаниеОшибки(), СтатусСообщения.Внимание);
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
КонецФункции

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Расписание = ПолучитьРасписаниеРегламентногоЗадания(РегламентноеЗаданиеИД);
КонецПроцедуры

&НаСервере
Функция ПолучитьРасписаниеРегламентногоЗадания(УникальныйНомерЗадания) Экспорт
	ОбъектЗадания = Обработки.JobConsole.Создать().ПолучитьОбъектРегламентногоЗадания(УникальныйНомерЗадания);
	Если ОбъектЗадания = Неопределено Тогда
		Возврат Новый РасписаниеРегламентногоЗадания;
	КонецЕсли;
	
	Возврат ОбъектЗадания.Расписание;
КонецФункции