# date

dateToJulian
V-144
DataFolderRefStatus returns a bitwise result with bit 0 indicating if the reference is valid and bit 1 
indicating if the reference data folder is free. Therefore the returned values are:
A data folder reference is invalid if it was never assigned a value or if it is assigned an invalid value. For 
example:
DFREF dfr
// dfr is invalid
DFREF dfr = root:
// dfr is valid
DFREF dfr = root:NonExistentDataFolder
// dfr is invalid
DFREF dfr = root:ExistingDataFolder
// dfr is valid
KillDataFolder dfr
// dfr is invalid
You should use DataFolderRefStatus to test any DFREF variables that might not be valid, such as after 
assigning a reference when you are not sure that the referenced data folder exists. For historical reasons, if 
you use an invalid DFREF variable it will often act like root.
See Also
Data Folders on page II-107, Data Folder References on page IV-78, Built-in DFREF Functions on page 
IV-81.
dateToJulian 
dateToJulian(year, month, day)
The dateToJulian function returns the Julian day number for the specified date. The Julian day starts at noon. 
Use negative number for BC years and positive numbers for AD years. To exclude any ambiguity, there is no 
year zero in this calendar. For general orientation, Julian day 2450000 corresponds to October 9, 1995.
See Also
The JulianToDate function.
For more information about the Julian calendar see: 
<http://www.tondering.dk/claus/calendar.html>.
date 
date()
The date function returns a string containing the current date.
Formatting of dates depends on your operating system and on your preferences entered in the Date & Time 
control panel (Macintosh) or the Regional Settings control panel (Windows).
Examples
Print date()
// Prints Mon, Mar 15, 1993
See Also
The Secs2Date, Secs2Time, and time functions.
0:
The data folder reference is invalid.
1:
The data folder reference refers to a regular global data folder.
3:
The data folder reference refers to a free data folder.
