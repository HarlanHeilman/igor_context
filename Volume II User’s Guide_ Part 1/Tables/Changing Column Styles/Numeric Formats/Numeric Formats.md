# Numeric Formats

Chapter II-12 — Tables
II-255
Numeric Formats
Columns in tables display either text or numeric waves. For numeric waves, the column format determines 
how the data values in the wave are entered and displayed. The column format has no effect on data 
columns of text waves.
In addition to regular number formats, tables support date, time and date&time formats. The format is 
merely a way of displaying a number. Even dates and times are stored internally in Igor as numbers. You 
can enter a value in a numeric column of a table as a number, date, time or date&time if you set the format 
for the column appropriately.
The following table lists all of the numeric formats.
When you enter a number in a table, Igor expects either dot or comma as the decimal symbol, as determined 
by the Decimal Symbol setting in the Table Misc Settings dialog. The factory default is dot. This setting 
applies only to entering numbers in tables. To change it, choose TableTable Misc Settings. If it is set to Per 
System Setting and you change the system decimal symbol, you must restart Igor for the change to take 
effect.
For most numeric formats you can control the number of digits displayed. You can set this using the Modify 
Columns dialog or using the Digits submenu of the Table menu, table pop-up menu (gear icon), or table 
Numeric Format
Description
General
Displays numbers in a format appropriate to the number itself. Very large or small 
numbers are displayed in scientific notation. Other numbers are displayed in decimal 
form (e.g. 1234.567). The Digits setting controls the number of significant digits. 
Integers are displayed with no fractional digits.
Integer
Numbers are displayed as the nearest integer number. For example, 1234.567 is 
displayed as 1235.
Integer with 
comma
Numbers are displayed as the nearest integer number. In addition, commas are used to 
separate groups of three digits. For example, 1234.567 is displayed as 1,235.
Decimal
As many digits to the left of the decimal point as are required are used to display the 
number. The Digits setting controls the number of digits to the right of the decimal point. 
For example, if the number of digits is specified as two, 1234.567 is displayed as 1234.57.
Decimal with 
comma
Identical to the decimal format except that commas are used to separate groups of 
three digits to the left of the decimal point.
Scientific
Numbers are displayed in scientific notation. The Digits setting controls the number 
of digits to the right of the decimal point.
Date
Dates are displayed using the format set in the Table Date Format dialog.
See Date/Time Formats on page II-256.
Time
[+][-]hhhh:mm:ss[.ff] [AM/PM].
See Date/Time Formats on page II-256.
Date & Time
Date format plus space plus time format.
See Date/Time Formats on page II-256.
Octal
Numbers are displayed in octal (base 8) notation. Only integers are supported. The 
number of digits displayed depends on the wave data type and the Digits setting is 
ignored. See Octal Numeric Formats on page II-257 for details.
Hexadecimal
Numbers are displayed in hexadecimal (base 16) notation. Only integers are 
supported. The number of digits displayed depends on the wave data type and the 
Digits setting is ignored. See Hexadecimal Numeric Formats on page II-257 for details.
