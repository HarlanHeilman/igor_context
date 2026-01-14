# Date/Time Formats

Chapter II-9 — Importing and Exporting Data
II-130
looks for the first non-blank value in each column and makes a determination based on the column’s con-
tent. In most cases, the auto-identify method works and there is no need for the other methods.
In the “treat all columns as numeric” method, Igor loads all columns into numeric waves. If some of the 
data is not numeric, you get NaNs in the output wave. For backward compatibility, this is the default 
method when you use the LoadWave/J operation from the command line or from an Igor procedure. To use 
the “auto-identify column type” method, you need to use LoadWave/J/K=0.
In the “treat all columns as text” method, Igor loads all columns into text waves. This method may have use 
in rare cases in which you want to do text-processing on a file by loading it into a text wave and then using 
Igor’s string manipulation capabilities to massage it.
For details on the /B method, see the section Specifying Characteristics of Individual Columns on page 
II-145.
Date/Time Formats
The Load Delimited Text routine can handle dates in many formats. A few “standard” formats are sup-
ported and in addition, you can specify a “custom” format (see Custom Date Formats on page II-130).
The standard date formats are:
To use the dd/mm/yy format instead of mm/dd/yy, you must set a tweak. See Delimited Text Tweaks on 
page II-136.
You can also use a dash or a dot as a separator instead of a slash.
Igor can also handle times in the following forms:
As of Igor Pro 6.23, Igor also accepts a colon instead of a dot before the fractional seconds.
The first three forms are time-of-day forms. The last one is the elapsed time. In an elapsed time, the hour is 
in the range 0 to 9999.
The year can be specified using two digits (99) or four digits (1999). If a two digit year is in the range 00 … 
39, Igor treats this as 2000 … 2039. If a two digit year is in the range 40 … 99, Igor treats this as 1940 … 1999.
The Load Delimited Text routine can also handle date/times which consist of one of these date formats, a 
single space or the letter T, and then one of the time formats. To load <date><space><time> as a date/time 
value, space must not be specified as a delimiter character.
Custom Date Formats
If your data file contains dates in a format other than the “standard” format, you can use Load Delimited 
Text to specify exactly what date format to use. You do this using the Delimited Text Tweaks dialog which 
you access through the Tweaks button in the Load Waves dialog. Choose Other from the Date Format pop-
up menu. This leads to the Date Format dialog.
mm/dd/yy
(month/day/year)
mm/yy
(month/year)
dd/mm/yy
(day/month/year)
[+][-]hh:mm:ss [AM PM]
(hours, minutes, seconds)
[+][-]hh:mm:ss.ff [AM PM]
(hours, minutes, seconds, fractions of seconds)
[+][-]hh:mm [AM PM]
(hours, minutes)
[+][-]hhhh:mm:ss.ff
(hours, minutes, seconds, fractions of seconds)
