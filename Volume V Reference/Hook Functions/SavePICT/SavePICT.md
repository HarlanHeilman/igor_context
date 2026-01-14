# SavePICT

SavePICT
V-826
prefsFileName is the name of a preference file to be saved by SavePackagePreferences. It should include an 
extension, typically ".bin".
prefsStruct is the structure containing the data to be saved in the preference file on disk.
recordID is a unique positive integer that you assign to each record that you store in the preferences file. If 
you store more than one structure in the file, you would use distinct recordIDs to identify which structure 
you want to save. In the simple case you will store just one structure in the preference file and you can use 
0 (or any positive integer of your choice) as the recordID.
Flags
Details
SavePackagePreferences sets the following output variables:
Example
See the example under Saving Package Preferences in a Special-Format Binary File on page IV-252.
See Also
LoadPackagePreferences.
SavePICT 
SavePICT [flags] [as fileNameStr]
The SavePICT operation creates a picture file representing the top graph, table or layout. The picture file 
can be opened by many word processing, drawing, and page layout programs.
Parameters
The file to be written is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
/FLSH=flush
/KILL
Instead of saving prefsStruct under the specified record ID, that record is deleted 
from the package's preference if it exists. If it does not exist, nothing is done and no 
error is returned.
/P=pathName
Specifies the directory in which to save the file specified by prefsFileName.
pathName is the name of an existing symbolic path. See Symbolic Paths on page II-22 
for details.
/P=$<empty string variable> acts as if the /P flag were omitted.
V_flag
Set to 0 if preferences were successfully saved or to a nonzero error code if they were 
not saved. The latter case is unlikely and would indicate some kind of corruption such 
as if Igor's preferences directory were deleted.
V_structSize
Set to the size in bytes of prefsStruct. This may be useful in handling structure version 
changes.
Controls when the data is actually written to the preference file:
flush=0:
The data will be flushed to disk when the current experiment is 
saved, reverted or closed or when Igor quits. This is the default 
behavior used when /FLSH is omitted and is recommended for most 
purposes.
flush=1:
The data is flushed to disk immediately.

SavePICT
V-827
If you omit fileNameStr but include /P=pathName, SavePICT writes the file using a default file name. The 
default file name is the window name followed by an extension, such as “.png”, “.emf” or “.svg”, that 
depends on the graphic format being exported.
If you specify the file name as “Clipboard”, and do not specify a /P=pathName, Igor copies the picture to 
the Clipboard, rather than to a file. EPS is a file-only format and can not be stored in the clipboard.
If you specify the file name as “_string_” the output will be saved into a string variable named S_Value, 
which is used with the ListBox binary bitmap display mode.
If you use the special name _PictGallery_ with the /P flag, then the picture will be stored in Igor's picture 
gallery (see Pictures on page III-509) with the name you provide via fileNameStr. This feature was added in 
support of making movies using the /PICT flag with NewMovie.
Flags
/B=dpi
Controls image resolution in dots-per-inch (dpi). The legal values for dpi are n*72 
where n can be from 1 to 8. The actual image dpi is not used. Igor calculates n from 
your value of dpi and then multiplies n by your computer’s screen resolution. This is 
because bitmap images that are not an integer multiple of the screen resolution look 
quite bad.
Also see the /RES flag.
/C=c
/D=d
Obsolete in Igor Pro 7 or later.
/E=e
Sets graphics format used when exporting a graphic. See Details for formats. See also 
Chapter III-5, Exporting Graphics (Macintosh), or Chapter III-6, Exporting Graphics 
(Windows), for a description of these modes and when to use them.
/EF= e
/I
Specifies that /W coordinates are inches.
/M
Specifies that /W coordinates are centimeters.
/N=winSpec
/N is antiquated but still supported. Use /WIN instead.
/O
Overwrites file if it exists.
/P=pathName
Saves file into a folder specified by pathName, which is the name of an existing 
symbolic path.
/PGR=(firstPage, lastPage)
Controls which pages in a multi-page layout are saved.
firstPage and lastPage are one-based page numbers. All pages from firstPage to 
lastPage are saved if the file format supports it.
The special value 0 refers to the current page and -1 refers to the last page in the 
layout.
Currently only the PDF formats support saving multiple pages. Other file formats 
save only firstPage and ignore the value of lastPage.
/PGR was added in Igor Pro 7.00.
/PICT=pict
Saves specified named picture rather than the target window. Native format of the 
picture is used and all format flags are ignored.
Specifies color mode.
c=0:
Black and white.
c=1:
RGB color (default).
c=2:
CMYK color (EPS and native TIFF only).
Sets font embedding.
e=0:
No font embedding. Not honored in Igor Pro 7 or later.
e=1:
Embed nonstandard fonts.
e=2:
Embed all fonts.

SavePICT
V-828
Details
SavePICT sets the variable V_flag to 0 if the operation succeeds or to a nonzero error code if it fails.
If you specify a path using the /P=pathName flag, then Igor saves the file in the folder identified by the path. 
Note that pathName is the name of an Igor symbolic path, created via NewPath. It is not a file system path 
like “hd:Folder1:” or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details. Otherwise, with 
no path specified, Igor presents a standard save dialog to let you specify where the file is to be saved.
Graphics formats, specified via /E, are as follows:
/PLL=p
/Q=q
Sets quality factor (0.0 is lowest, 1.0 is highest). Default is dependent on individual 
format. Used only by lossy formats such as JPEG.
/R=resID
Obsolete in Igor Pro 7 or later.
/RES=dpi
Controls the resolution of image formats in dots-per-inch. Unlike the similar /B flag, the 
value for /RES is the actual output resolution and is useful when your publisher demands 
a specific resolution.
/S
Suppresses the preview that is normally included with an EPS file.
Obsolete in Igor Pro 7 or later.
/SNAP=s
Snapshot mode is available only for graphs and panels and only for bitmap export 
formats PNG, JPEG, and TIFF at screen resolution. When using /W to specify the size 
of a graph, the capture is sized to fit within the specified rectangle while maintaining 
the window aspect ratio. Coordinates used with /W are in pixels.
/T=t
Obsolete QuickTime export type. Not supported in Igor Pro 7 or later.
/TRAN[=1 or 0]
Makes white background areas transparent using an RGBA type PNG when used 
with native PNG export of graphs or page layouts.
/W=(left,top,right,bottom)
Specifies the size of the picture when exporting a graph. If /W is omitted, it uses the 
graph window size.
When exporting a page layout, specifies the part of the page to export. Only objects 
that fall completely within the specified area are exported. If /W is omitted, the area 
of the layout containing objects is exported.
When exporting a page layout in Igor Pro 7.00 or later, you can specify /W=(0,0,0,0) to 
use the full page size.
Coordinates for /W are in points unless /I or /M are specified before /W.
/WIN=winSpec
Saves the named window or subwindow. winSpec can be just a window name, or a 
window name following by a “#” character and the name of the subwindow, as in 
/WIN=Panel0#G0.
/Z
Errors are not fatal. V_flag is set to zero if no error, else nonzero if error.
/E Value
Macintosh File Format
Windows File Format
-9
SVG file.
SVG file.
-8
PDF file.
PDF file.
Specifies Postscript language level when used in conjunction with EPS export.
p=1:
For very old Postscript printers.
p=2:
For all other uses (default).
Saves a snapshot (screen dump) of a graph or panel window.
s=1:
Include all controls in capture.
s=2:
Capture only window data content.
