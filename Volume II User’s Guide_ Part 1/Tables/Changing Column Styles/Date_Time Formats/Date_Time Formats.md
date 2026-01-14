# Date/Time Formats

Chapter II-12 — Tables
II-256
contextual menu. The meaning of the number that you choose from the Digits submenu depends on the 
numeric format.
The Digits setting has no effect on columns displayed using the integer, octal and hexadecimal formats and 
also has no effect on columns displaying text waves. It affects time and date/time formats only if the display 
of fractional seconds is enabled.
With the General format, you can choose to display trailing zeros or not.
With the time format, Igor accepts and displays times from -9999:59:59 to +9999:59:59. This is the supported 
range of elapsed times. If you are entering a time-of-day rather than an elapsed time, you should restrict 
yourself to the range 00:00:00 to 23:59:59.
With the Time and Date&Time formats, you can choose to display fractional seconds. Most people dealing 
with time data use whole numbers of seconds. Therefore, by default, a table does not show fractional sec-
onds. If you want to see fractional seconds in a table, you must choose Show Fractional Seconds from the 
TableFormat menu. Once you do this, the TableDigits menu controls the number of digits that appear 
in the fractional part of the time.
If you always want to see fractional seconds, use the Capture Table Prefs dialog to capture columns whose 
Show Fractional Seconds setting is on. This applies to tables created after you capture the preference.
When displaying fractional seconds, Igor always displays trailing zeros and the Show Trailing Zeros menu 
item in the TableFormat menu has no effect.
When choosing a format, remember that single precision floating point data stores about 7 decimal digits 
and double-precision floating point data stores about 16 decimal digits. If you want to inspect your data 
down to the last decimal place, you need to select a format with enough digits.
The format does not affect the precision of data that you export via the clipboard from a table to another 
application. See Exporting Data from Tables on page II-252.
Date/Time Formats
As described under Date Values on page II-245, the way you enter dates in tables and the way Igor displays 
them is controlled by the Table Date Format dialog which you invoke through the Table menu. This dialog 
sets a global preference that determines the date format for all tables. By factory default, the table date 
format is controlled by the system Regional Settings control panel.
If you set the column format to time, then Igor displays time in elapsed time format. You can enter elapsed 
times from -9999:59:59 to +9999:59:59. You can precede an elapsed time with a minus sign to enter a negative 
elapsed time. You can also enter a fractional seconds value, for example 31:35:20.19. To view fractional sec-
onds, choose Show Fractional Seconds from the Format submenu of the Table menu.
Numeric Format
You Specify
General
Number of displayed digits
Decimal (0.0...0)
Number of digits after the decimal point
Decimal with comma (0.0...0)
Number of digits after the decimal point
Time and Date&Time
Number of digits after the decimal point when displaying 
fractional seconds
Scientific (0.0...0E+00)
Number of digits after the decimal point
Octal
Total number of octal digits to display.
Hexadecimal
Total number of hexadecimal digits to display.
