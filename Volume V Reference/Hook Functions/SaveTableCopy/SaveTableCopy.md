# SaveTableCopy

SaveTableCopy
V-829
The low resolution PDF formats on Macintosh are probably not useful and are just placeholders for 
compatibility with old procedures.
See Also
The ImageSave operation for saving waves as PICTs and other image file formats. The LoadPICT operation.
See Chapter III-5, Exporting Graphics (Macintosh), or Chapter III-6, Exporting Graphics (Windows), for a 
description of the /E modes.
SaveTableCopy 
SaveTableCopy [flags][as fileNameStr]
The SaveTableCopy operation saves a copy of the data displayed in a table on disk. The saved file can be 
an Igor packed experiment file, a tab-delimited text file, or a comma-separated values text file.
When saving as text, by default the data format matches the format shown in the table. This causes 
trunctation if the underlying data has more precision than shown in the table. If you specify /F=1, 
SaveTableCopy uses as many digits as needed to represent the data with full precision.
The point column is never saved.
To save data as text with full precision, use the Save operation.
When saving 3D and 4D waves as text, only the visible layer is saved. To save the entirety of a 3D or 4D 
wave, use the Save operation.
Parameters
The file to be written is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
-7
TIFF file. Lossless but larger file than PNG; best for text, graph traces, and simple images with 
sharp edges. The default resolution is 72 dpi. You can specify the resolution with the /B or /RES 
flag. Cross-platform compatible.
-6
JPEG file. Lossy compression; best used for grayscale and color images with smooth tones. The 
/Q flag specifies compression quality and the /B or /RES flag sets the resolution. Cross-platform 
compatible. PNG is a better choice for scientific graphics.
-5
PNG (Portable Network Graphics) file. Lossless compression; best for text, graph traces, and 
simple images with sharp edges. The default resolution is 72 dpi. Specify the resolution with 
/B or /RES. Cross-platform compatible.
-4
High resolution bitmap PICT file. Default 
resolution is 288 dpi. Specify the resolution 
with /B or /RES.
Device-independent bitmap file (DIB). Default 
resolution is 4x screen resolution. Specify the 
resolution with /B or /RES.
-3
Encapsulated PostScript (EPS) file.
Use /S to suppress the screen preview if 
exporting to Latex.
Encapsulated PostScript (EPS) file.
Use /S to suppress the screen preview if 
exporting to Latex.
-2
Quartz PDF.
High-resolution Enhanced Metafile (EMF).
-1
Quartz PDF (was PostScript PICT).
Obsolete (was PostScript-enhanced metafile).
0
Quartz PDF (was PostScript PICT with 
QuickDraw text).
Obsolete (was PostScript-enhanced metafile).
1
Low resolution Quartz PDF at 1x normal size. High-resolution Enhanced Metafile (EMF).
2
Low resolution Quartz PDF at 2x normal size. High-resolution Enhanced Metafile (EMF).
4
Low resolution Quartz PDF at 4x normal size. High-resolution Enhanced Metafile (EMF).
8
Low resolution Quartz PDF at 8x normal size. High-resolution Enhanced Metafile (EMF).
/E Value
Macintosh File Format
Windows File Format

SaveTableCopy
V-830
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming the 
path.
Flags
/A=a
/F=f
/I
Presents a dialog from which you can specify file name and folder.
/M=termStr
Specifies the terminator character or characters to use at the end of each line of text. 
The default is /M="\r" on Macintosh and /M="\r\n" on Windows; it is used when 
/M is omitted. To use the Unix convention, just a linefeed, specify /M="\n".
/N=n
Specifies whether to use column names, titles, or dimension labels.
/O
Overwrites file if it exists already.
/P=pathName
Specifies the folder to store the file in. pathName is the name of an existing symbolic path.
/S=s
Saves all of the data in the table (s=0; default) or the selection only (s=1).
/S applies when saving text files and is ignored when saving packed experiment files.
/T=saveType
/W= winName
winName is the name of the table to be saved. If /W is omitted or if winName is "", the 
top table is saved.
/Z
Errors are not fatal and error dialogs are suppressed. See Details.
Appends data to the file rather than overwriting.
/A applies when saving text files and is ignored when saving packed experiment 
files.
If the file does not exist, a new file is created and /A has no effect.
a=0:
Does not append.
a=1:
Appends to the file with a blank line before the appended data.
a=2:
Appends to the file with no blank line before the appended data.
Controls the precision of saved numeric data.
The /F flag was added in Igor Pro 7.00
f=0:
Numeric data is written exactly as shown in the table. This may 
cause truncation. This is the default behavior if /F is omitted.
f=1:
Numeric data is written with as many digits as needed to represent 
the data with full precision.
n is a bitwise parameter with the bits defined as follows:
The default setting for n is 1. All other bits are reserved and must be zero.
Bit 0:
Include column names or titles. The column title is included if it is not 
empty. If it is empty, the column name is included.
Bit 1:
Include horizontal dimension labels if they are showing in the table.
Specifies the file format of the saved file.
saveType=0:
Packed experiment file.
saveType=1:
Tab-delimited text file.
saveType=2:
Comma-separated values text file.
saveType=3:
Space-delimited values text file.
saveType=4:
HDF5 packed experiment file (requires Igor Pro 9 or later). If 
fileNameStr is specified the file name extension must be ".h5xp".
