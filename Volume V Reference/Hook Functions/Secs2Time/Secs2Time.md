# Secs2Time

Secs2Date
V-833
In complex expressions, x is complex, and sech(x) returns a complex value.
See Also
cosh, tanh, coth, csch
Secs2Date 
Secs2Date(seconds, format [, sep])
The Secs2Date function returns a string containing a date.
With format values 0, 1, and 2, the formatting of dates depends on operating system settings entered in the 
Language & Region control panel (Macintosh) or the Region control panel (Windows). These date formats do not 
work with dates before 0001-01-01 in which case Date2Secs returns an empty string.
If format is -1, the format is independent of operating system settings. The fixed-length format is “day /month 
/year (dayOfWeekNum)”, where dayOfWeekNum is 1 for Sunday, 2 for Monday… and 7 for Saturday.
If format is -2, the format is YYYY-MM-DD.
The optional sep parameter affects format -2 only. If sep is omitted, the separator character is "-". Otherwise, 
sep specifies the separator character.
Parameters
seconds is the number of seconds from 1/1/1904 to the date to be returned.
seconds is limited to the range -1094110934400 (-32768-01-01) to 973973807999 (32768-12-31). For seconds 
outside that range, Secs2Date returns an empty string.
format is a number between -2 and 2 which specifies how the date is to be constructed.
Examples
Print Secs2Date(DateTime,-2)
// 1993-03-14
Print Secs2Date(DateTime,-2,"/")
// 1993/03/14
Print Secs2Date(DateTime,-1)
// 15/03/1993 (2)
Print Secs2Date(DateTime,0)
// 3/15/93 (depends on system settings)
Print Secs2Date(DateTime,1)
// Monday, March 15, 1993 (depends on system settings)
Print Secs2Date(DateTime,2)
// Mon, Mar 15, 1993 (depends on system settings)
See Also
For further discussion of how Igor represents dates, see Date/Time Waves on page II-85.
The date, date2secs and DateTime functions.
Secs2Time 
Secs2Time(seconds, format, [fracDigits])
The Secs2Time function returns a string containing a time.
Parameters
seconds is the number of seconds from 1/1/1904 to the time to be returned.
format is a number between 0 and 5 that specifies how the time is to be constructed. It is interpreted as follows:
“Normal” formats (0 and 1) follow the preferred formatting of the short time format as set in the 
International control panel (Macintosh) or in the Regional and Language Options control panel (Windows).
“Military” means that the hour is a number from 0 to 23. Hours greater than 23 are wrapped.
0:
Normal time, no seconds.
1:
Normal time, with seconds.
2:
Military time, no seconds.
3:
Military time, with seconds and optional fractional seconds.
4:
Elapsed time, no seconds.
5:
Elapsed time, with seconds and optional fractional seconds.
