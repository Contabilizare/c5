
&НаКлиенте
Процедура ОК(Команда)
	ВыполнитьФоновоеЗадание();
КонецПроцедуры

&НаСервере
Процедура ВыполнитьФоновоеЗадание()
	Попытка	
	    ФоновыеЗадания.Выполнить(ИмяМетода,, Ключ, Наименование);
	Исключение	
		Сообщить(ОписаниеОшибки(), СтатусСообщения.Внимание);
	КонецПопытки;
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗаданиеИД = Параметры.ИдентификаторЗадания;
	ФоновоеЗадание = Обработки.JobConsole.Создать().ПолучитьОбъектФоновогоЗадания(ЗаданиеИД);
	Если ФоновоеЗадание <> Неопределено Тогда
		ИмяМетода = ФоновоеЗадание.ИмяМетода;
		Наименование = ФоновоеЗадание.Наименование;
		Ключ = ФоновоеЗадание.Ключ;
	Иначе
		//Ключ = Новый УникальныйИдентификатор;
	КонецЕсли;
КонецПроцедуры
