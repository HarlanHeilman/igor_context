# Debugger

date2secs
V-145
date2secs 
date2secs(year, month, day)
The date2secs function returns the number of seconds from midnight on 1/1/1904 to the specified date.
The month and day parameters are one-based, so these series start at one.
Date2Secs is limited to the range -32768-01-01 to 32767-12-31. For dates outside that range, it returns NaN. 
It also returns NaN if the year is 0 because Igor uses the Gregorian calendar in which there is no year 0.
If year, month, and day are all -1 then date2secs returns the offset in seconds from the local time to the UTC 
(Universal Time Coordinate) time.
Examples
Print Secs2Date(date2secs(1993,3,15),1)
// Ides of March, 1993
Prints the following, depending on your system’s date settings, in the history area:
Monday, March 15, 1993
This next example sets the X scaling of a wave to 1 day per point, starting January 1, 1993:
Make/N=125 myData = 100 + gnoise(50)
SetScale/P x,date2secs(1993,1,1),24*60*60,"dat",myData
Display myData;ModifyGraph mode=5
See Also
For further discussion of how Igor represents dates, see Date/Time Waves on page II-85.
The Secs2Date, Secs2Time, and time functions.
DateTime 
DateTime
The DateTime function returns number of seconds from 1/1/1904 to current local date and time.
To get the UTC date and time, subtract Date2Secs(-1,-1,-1) from the value returned by DateTime.
Unlike most Igor functions, DateTime is used without parentheses.
Examples
Variable localNow = DateTime
See Also
The Secs2Date, Secs2Time and time functions.
dawson 
dawson(x)
The dawson function returns the value of the Dawson integral:
If x is real, dawson returns a real result. If x is complex, dawson returns a complex result.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 298 pp., Dover, New York, 1972.
The code used to implement the Dawson integral was written by Steven G. Johnson of MIT. See http://ab-
initio.mit.edu/Faddeva
Debugger 
Debugger
The Debugger operation breaks into the debugger if it is enabled.
See Also
The Debugger on page IV-212 and the DebuggerOptions operation.
F(x) = exp −x2
(
)
exp t 2
( )dt.
0
x∫
