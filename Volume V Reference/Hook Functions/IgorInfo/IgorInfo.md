# IgorInfo

IgorInfo
V-359
See Also
The FFT, DSPPeriodogram, and MatrixOp operations.
IgorInfo 
IgorInfo(selector)
The IgorInfo function returns information about the Igor application and the environment in which it is 
running.
Details
selector is a number from 0 to 13.
Selector = 0
If selector is 0, IgorInfo returns a collection of assorted information. The result string contains five kinds of 
information. Each group is prefaced by a keyword and a colon, and terminated with a semicolon.
Selector = 1
IgorInfo(1) returns the name of the current Igor experiment.
Use IgorInfo(12) to get the file name including the extension.
Keyword
Information Following Keyword For IgorInfo(0)
FREEMEM
The amount of free memory available to Igor.
PHYSMEM
The amount of total physical memory available to Igor. Added in Igor Pro 7.00.
USEDPHYSMEM
The amount of used physical memory used by Igor. Added in Igor Pro 7.00.
IGORKIND
IGORVERS
The version number of the Igor application. Also see IGORFILEVERSION returned 
by IgorInfo(3).
NSCREENS
Number of screens currently attached to the computer and used for the desktop.
SCREEN1
A description of the characteristics of screen 1.
The format of the SCREEN1 description is:
SCREEN1:DEPTH=bitsPerPixel,RECT=left,top,right,bottom;
left, top, right, and bottom are all in pixels.
If there are multiple screens, there will be additional SCREEN keywords, such as 
SCREEN2 and SCREEN3.
The type of Igor application:
“pro64” and “pro64 demo” are returned by the 64-bit of Igor Pro 7.00 or later.
The presence of “demo” indicates that Igor is running in demo mode, either 
because the user’s fully-functional demo period has expired or because the user 
chose to run in demo mode using the License dialog.
"pro":
Igor Pro 32-bit
"pro demo":
Igor Pro 32-bit in demo mode
"pro64":
Igor Pro 64-bit
"pro64 demo":
Igor Pro 64-bit in demo mode

IgorInfo
V-360
Selector = 2
IgorInfo(2) returns the name of the current platform: “Macintosh” or “Windows”.
Selector = 3
IgorInfo(3) returns a collection of more detailed information about the operating system, localization 
information, and the actual file version of the Igor executable. The keywords are OS, OSVERSION, 
LOCALE, and IGORFILEVERSION.
Selector = 4
IgorInfo(4) returns the name of the current processor architecture. Currently this is always “Intel”.
Selector = 5
IgorInfo(5) returns, as a string, the serial number of the program if it is registered or "_none_" if it isn't 
registered. Use str2num to store the result in a numeric variable. str2num returns NaN if the program isn't 
registered.
Selector = 6
IgorInfo(6) returns, as a string, the version of the Qt library under which Igor is running, for example 
“5.9.4”. This selector value was added in Igor Pro 7.00.
Selector = 7
IgorInfo(7) returns, as a string, the name of the current user. This selector value was added in Igor Pro 7.00.
Selector = 8
IgorInfo(8) returns, as a string, the group of the current user on Macintosh. On Windows, an empty string 
is always returned. This selector value was added in Igor Pro 8.00.
Selector = 9
IgorInfo(9) returns "admin" if Igor's process is being run as an administrator (Windows) or if the user that 
started Igor's process is an administrator (Macintosh). Otherwise it returns "". This selector value was added 
in Igor Pro 8.00.
Selector = 10
IgorInfo(10) returns a semicolon-separated list containing the names of activated XOPs. This selector value 
was added in Igor Pro 8.00.
Selector = 11
IgorInfo(11) returns a string specifying the type of the current experiment. This will be one of the following:
Keyword
Information Following Keyword For IgorInfo(3)
IGORFILEVERSION
The actual version number of the Igor application file.
On Macintosh, the version number is a floating point number with a possible 
suffix. Igor Pro 7.00, for example, returns “7.00”. Igor Pro 8.01 Beta 1 returns 
“8.01B01”.
On Windows, the version format is a period-separated list of four numbers. 
Igor Pro 7.02 returns “7.0.2.X” where X is a subminor revision number. A 
revision to Igor Pro 7.02 would be indicated in the last digit, such as “7.0.2.12”.
LOCALE
Country for which this version of Igor Pro is localized. “US” for most versions, 
“Japan” for the Japanese versions.
OS
On Macintosh, the OS value is “Macintosh OS X”.
On Windows, it is something like “Microsoft Windows 10 Home (21H1)”. The 
actual build number and format of the text will vary with the operating system 
and service pack.
OSVERSION
Operating system number.
On Macintosh, this is something like “10.13.1”.
On Windows, this is something like “10.0.19043.1466”.

IgorInfo
V-361
See Saving Experiments on page II-16 for a discussion of the various experiment file formats.
Selector = 12
IgorInfo(12) returns a string specifying the name of the current experiment file including the extension. If 
the experiment was never saved to a file, it returns "".
This selector value was added in Igor Pro 9.00.
Use IgorInfo(1) to get the file name without the extension.
Selector = 13
In Igor Pro 9.00 and later, IgorInfo(13) returns a collection of information about the autosave settings. See 
Autosave on page II-36 for background information.
This selector value was added in Igor Pro 9.00.
Selector = 14
IgorInfo(14) returns a collection of information about the HDF5 default compression settings. See HDF5 
Default Compression on page II-214 for background information.
This selector value was added in Igor Pro 9.00.
The keywords are as follows:
See Autosave on page II-36 for details.
Selector = 15
IgorInfo(15) returns a string specifying the default experiment file format.
This selector value was added in Igor Pro 9.00.
The returned value will be one of the following:
"Packed"
Current experiment file is a .pxp file
"HDF5 packed"
Current experiment file is a .h5xp file
"Unpacked"
Current experiment file is a .uxp file
""
Current experiment was never saved to a file
Keyword
Information Following Keyword For IgorInfo(3)
ENABLED
0: Autosave is disabled
1: Autosave is enabled
MODE
INTERVAL
The interval in minutes between autosaves if autosave is enabled.
OPTIONS
"Packed"
Default experiment file format is .pxp
"HDF5 packed"
Default experiment file format is .h5xp
"Unpacked"
Default experiment file format is .uxp
1:
Direct (saves to original files)
2:
Indirect (saves to .autosave files)
A bitwise value with each bit indicating if a given feature is off (bit is 0) or on 
(bit is 1):
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
Autosave entire experiment
Bit 1:
Autosave standalone procedure files
Bit 2:
Autosave standalone plain text notebooks
Bit 3:
Autosave standalone formatted text notebooks
