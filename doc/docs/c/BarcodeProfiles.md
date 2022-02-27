﻿Этот справочник отвечает за настройки размеров и оформления печати этикеток со штрихкодами товаров. Каждый профиль задает макет одной этикетки и предполагает печать с использованием специального принтера этикеток, по одной этикетке на лист (в терминах принтера этикеток).

В состав настраиваемых параметров входит:

1. Угол поворота штрихкода. Например, в некоторых случаях печати больших этикеток, угол поворота имеет смысл установить в 90 градусов.
2. Размер шрифта цифр штрихкода.
3. Параметр `Description`, включая его положение и настройки оформления. Поле `Description` всегда включает в себя наименование товара, упаковку и номер партии (если применимо).
4. Положение и размер картинки со штрихкодом.

Профиль печати устанавливается в настройках пользователя. Список всех профилей доступен в меню `Справочники / Товары / Профили печати этикеток`.

# Настройка сканера

У каждого сканера может быть свой состав настроек сканирования. Программа не предъявляет особых требований к оборудованию, однако для корректного распознавания кодов при использовании различных устройств (ТСД, смартфон или ручной сканер), убедитесь, что сканер высылает контрольный символ.

Например, для сканера Honeywell Scan Pal EDA 60K это будет: `Настройки / Scan Settings / Internal Scanner / Default profile / Symbology Settings / EAN-13` флаги должны быть на `EAN-13` и `Send check digit`

# Проблемы при сканировании

При работе на мобильном устройстве, основной режим ввода товаров в документы - это сканирование штрихкода. В том случае, когда товар не может быть отсканирован (например испачкана или порвана этикетка, или товар не имеет этикетки вообще), его можно добавить вручную. Функция добавления товара в таблицу в ручном режиме, располагается в правом верхнем меню мобильного приложения:

![](/img/Screenshot_20200629-194922_1CEnterprise.jpg)

![](/img/Screenshot_20200629-194926_1CEnterprise.jpg)

Важно отметить, что в случае добавления товара, для которого в системе не задан штрихкод, он будет сгенерирован автоматически, при проведении документа (данная функция реализована для документов `Инвентаризация кладовщика` и `Поступление кладовщика`). 

---

См. также:

- [Инвентаризация кладовщика](/d/InventoryStockman)
- [Поступление кладовщика](/d/ReceiptStockman)
- [Отгрузка кладовщика](/d/ShipmentStockman)