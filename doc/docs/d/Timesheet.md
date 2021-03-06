Документ предназначен для регистрации оплачиваемого сотруднику рабочего времени, включая банк времени.

В системе существует два способа учета рабочего времени:

1.  Табелирование
2.  Учет отклонений

Оба способа независимы, можно вести только учет отклонений или только табелирование. Допускается одновременное использование двух подходов.

Отдельно нужно упомянуть, что документ `Табель` и печатная форма (отчет) [Табель](/r/Timesheet) – это разные сущности в терминах реализованных в конфигурации подсистем учета заработной платы и кадров.

Табель – это форма для ввода информации, с бизнес-процессом утверждения времени, при необходимости.

Печатная форма [Табель](/r/Timesheet) – это отчет, который агрегирует введенную информацию и предоставляет её в удобном для анализа виде.

Для выбора способа учёта рабочего времени нужно зайти в **Настройки -> Приложения -> Сотрудники -> Табеля и Учёт отклонений.**

# Табелирование

Табелирование предпочтительно использовать для сотрудников, время работы которых напрямую определяет выставление счетов клиентам, либо когда в компании ведется строгий учет проектов и заложенных в них нормативов.

В одном периоде может существовать только один табель по одному сотруднику. Например, если для сотрудника задан месячный табель, то в каждом месяце не может быть более одного табеля по этому сотруднику.

Существует два способа ввода табеля. Первый – ввод отработанного времени непосредственно в табель. Второй – использование табеля совместно с документом [Запись времени](/d/TimeEntry). Второй вариант позволяет детально фиксировать время работ. Использование первого или второго способа зависит от характера работ сотрудника. Отдельной настройки, задающей эти правила нет. Любой сотрудник может использовать механизмы заполнения табеля как ему удобно, или как того требует компания. Способы могут комбинироваться.

В табель допускается вводить не только отработанное время, но и время проведенных отпусков, больничных.

# Учет отклонений

Данный метод используется при простой схеме учета рабочего времени. По этой схеме не требуется часовая или проектная детализация. Этот метод предполагает, что сотрудники работают по стандартному графику, установленному приемом на работу, а все отклонения вводятся отдельными документами.

Например, если сотрудник, по своему графику и без отклонений, отработал месяц, то в систему вообще не потребуется внесение дополнительной информации. Печать табеля (см. отчет [Табель](/r/Timesheet)), расчет заработной платы и другие механизмы системы будут работать в штатном режиме.

В случае, если сотрудник отсутствовал некоторый период времени, то для регистрации данного отклонения достаточно ввести один документ [Отклонение](/d/Deviation), который будет принят во внимание программой при расчете заработной платы.

При учете времени путем отклонений, аналогичный принцип действует и для других кадровых документов.