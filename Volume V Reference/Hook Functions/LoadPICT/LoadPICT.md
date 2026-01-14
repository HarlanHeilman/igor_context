# LoadPICT

LoadPICT
V-506
Details
LoadPackagePreferences sets the following output variables:
After calling LoadPackagePreferences if V_flag is nonzero or V_bytesRead is zero then you need to create 
default preferences as illustrated by the example referenced below.
V_bytesRead, in conjunction with the /MIS flag, makes it possible to check for and deal with old versions 
of a preferences structure as it loads the version field (typically the first field) of an older or newer version 
structure. However in most cases it is sufficient to omit the /MIS flag and treat incompatible preference data 
the same as missing preference data.
Example
See the example under Saving Package Preferences in a Special-Format Binary File on page IV-252.
See Also
SavePackagePreferences.
LoadPICT 
LoadPICT [flags] [fileNameStr][, pictName]
The LoadPICT operation loads a picture from a file or from the Clipboard into Igor. Once you have loaded 
a picture, you can append it to graphs and page layouts.
Parameters
The file to be loaded is specified by fileNameStr and /P=pathName where pathName is the name of an Igor symbolic 
path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative to the folder 
associated with pathName, or the name of a file in the folder associated with pathName. If Igor can not determine 
the location of the file from fileNameStr and pathName, it displays a dialog allowing you to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
If you want to force a dialog to select the file, omit the fileNameStr parameter.
If fileNameStr is “Clipboard” and /P=pathName is omitted, LoadPICT loads its data from the Clipboard 
rather than from a file.
pictName is the name that you want to give to the newly loaded picture. You can refer to the picture by its 
name to append it to graphs and page layouts. LoadPICT generates an error if the name conflicts with some 
other type of object (e.g., wave or variable) or if the name conflicts with a built-in name (e.g., the name of 
an operation or function).
If you omit pictName, LoadPICT automatically names the picture as explained in Details.
Flags
/P=pathName
Specifies the directory to look in for the file specified by prefsFileName.
pathName is the name of an existing symbolic path. See Symbolic Paths on page II-22 
for details.
/P=$<empty string variable> acts as if the /P flag were omitted.
V_flag
Set to 0 if no error occurred or to a nonzero error code.
If the preference file does not exist, V_flag is set to zero so you must use V_bytesRead 
to detect that case.
V_bytesRead
Set to the number of bytes read from the file. This will be zero if the preference file 
does not exist.
V_structSize
Set to the size in bytes of prefsStruct. This may be useful in handling structure version 
changes.
/M=promptStr
Specifies a prompt to use if LoadPICT needs to put up a dialog to find the file.

LoadPICT
V-507
Details
If the picture file is not fully specified then LoadPICT presents a dialog from which you can select the file. 
“Fully specified” means that LoadPICT can determine the name of the file (from the fileNameStr parameter) 
and the folder containing the file (from the flag /P=pathName flag or from the fileNameStr parameter). If you 
want to force a dialog, omit the fileNameStr parameter.
If you use /P=pathName, note that it is the name of an Igor symbolic path, created via NewPath. It is not a 
file system path like “hd:Folder1:” or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details.
If you omit pictName, LoadPICT automatically names the picture as follows:
If the picture was loaded from a file, LoadPICT uses the file name. If necessary, it makes it into a legal name 
by replacing illegal characters or shortening it.
Otherwise, LoadPICT uses a name of the form “PICT_n”.
If the resulting name is in conflict with an existing picture name, Igor puts up a name conflict resolution dialog.
LoadPICT sets the variable V_flag to 1 if the picture exists and fits in available memory or to 0 otherwise.
It also sets the string variable S_info to a semicolon-separated list of values:
/O
Overwrites an existing picture with the same name.
If /O is omitted and there is an existing picture with the same name, LoadPICT 
displays a dialog in which you can resolve the name conflict.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/Q
Quiet: suppresses the insertion of picture info into the history area.
/Z
Doesn’t load the picture, just checks for its existence.
Keyword
Information Following Keyword
NAME
Name of the loaded PICT, often “PICT_0”, etc.
SOURCE
“Data fork” or “Clipboard”.
RESOURCENAME
Obsolete - always “”.
RESOURCEID
Obsolete - always 0.
TYPE
One of the following types:
DIB
Encapsulated PostScript
Enhanced metafile
JPEG
PDF
PNG
SVG
TIFF
Windows bitmap
Windows metafile
Unknown type
BYTES
Amount of memory used by the picture.
WIDTH
Width of the picture in pixels.
