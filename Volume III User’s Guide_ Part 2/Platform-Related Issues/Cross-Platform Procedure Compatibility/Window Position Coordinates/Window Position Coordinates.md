# Window Position Coordinates

Chapter III-15 — Platform-Related Issues
III-455
Print "Unknown OS"
#endif
#endif
End
File Paths
As described under Path Separators on page III-451, Igor accepts paths with either colons or backslashes 
on either platform.
The use of backslashes is complicated by the fact that Igor uses the backslash character as an escape character 
in literal strings. This is also described in detail under Path Separators on page III-451. The simplest solution 
to this problem is to use a colon to separate path elements, even when you are running on Windows.
If you are writing procedures that need to extract sections of file paths or otherwise manipulate file paths, 
the ParseFilePath function on page V-733 may come in handy.
Igor supports paths up to 2000 bytes but operating system limits may apply. See File Names and Paths on 
page II-21 for details.
File Types and Extensions
On Mac OS 9, all files had a file type property. This property is a four letter code that is stored with the file 
by the Macintosh file system. For example, plain text files have the file type TEXT. Igor binary wave files 
have the file type IGBW. The file type property controlled the icon displayed for the file and which pro-
grams could open the file.
The file type property is no longer used on Macintosh. On Mac OS X, as well as on Windows, the file type 
is indicated by the file name extension.
For backward compatibility, some Igor operations and functions, such as IndexedFile, still accept Macin-
tosh file types. New code should use extensions instead.
Points Versus Pixels
A pixel is the area taken up by the smallest displayable dot on an output device such as a display screen or 
a printer. The physical width and height of a pixel depend on the device.
In Igor, most measurements of length are in terms of points. A point is roughly 1/72 of an inch. 72 points 
make up 1 “logical inch”. Because of hardware differences and system software adjustments, the actual size 
of a logical inch varies from screen to screen and system to system.
Window Position Coordinates
With one exception, Igor stores and interprets window position coordinates in units of points. For example 
the command
Display/W=(5, 42, 405, 242)
specifies the left, top, right, and bottom coordinates of the window in points relative to a reference point 
which is, roughly speaking, the top/left corner of the menu bar. Other Igor operations that use window 
position coordinates in points include Edit, Layout, NewNotebook, NewGizmo and MoveWindow.
The exception is the control panel window when running on a standard resolution screen. This is explained 
under Control Panel Resolution on Windows on page III-456.
Most users do not need to worry about the exact meaning of these coordinates. However, for the benefit of 
programmers, here is a discussion of how Igor interprets them.
On Macintosh, the reference point, (0, 0), is the top/left corner of the menu bar on the main screen. On Win-
dows, the reference point is 20 points above the bottom/left corner of the main Igor menu bar. This differ-
ence is designed so that a particular set of coordinates will produce approximately the same effect on both 
platforms, so that experiments and procedures can be transported from one platform to another.
