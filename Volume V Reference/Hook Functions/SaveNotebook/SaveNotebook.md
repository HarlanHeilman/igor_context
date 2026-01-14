# SaveNotebook

SaveNotebook
V-823
String fileName
sprintf fileName, "%s.pxp", graphName
SaveGraphCopy/P=$pathName/W=$graphName as fileName
index += 1
while(1)
End
See Also
SaveTableCopy, SaveGizmoCopy, SaveData, Merging Experiments on page II-19
SaveNotebook 
SaveNotebook [flags] notebookName [as fileNameStr]
The SaveNotebook operation saves the named notebook.
Parameters
notebookName is either kwTopWin for the top notebook window, the name of a notebook window or a host-
child specification (an hcSpec) such as Panel0#nb0. See Subwindow Syntax on page III-92 for details on 
host-child specifications.
If notebookName is an host-child specification, /S must be used and saveType must be 3 or higher.
The file to be written is specified by fileNameStr and /P=pathName where pathName is the name of an Igor 
symbolic path. fileNameStr can be a full path to the file, in which case /P is not needed, a partial path relative 
to the folder associated with pathName, or the name of a file in the folder associated with pathName. If Igor 
can not determine the location of the file from fileNameStr and pathName, it displays a dialog allowing you 
to specify the file.
If you use a full or partial path for fileNameStr, see Path Separators on page III-451 for details on forming 
the path.
Flags
/ENCG=textEncoding
Specifies text encoding in which the notebook is to be saved.
This flag was added in Igor Pro 7.00.
This is relevant for plain text notebooks only and is ignored for formatted notebooks 
because they can contain multiple text encodings. See Plain Text File Text Encodings 
on page III-466 and Formatted Text Notebook File Text Encodings on page III-472 
for details.
If omitted, the file is saved in its original text encoding. Normally you should omit 
/ENCG. Use it only if you have some reason to change the file's text encoding.
Passing 0 for textEncoding acts as if /ENCG were omitted.
See Text Encoding Names and Codes on page III-490 for a list of accepted values for 
textEncoding.
This flag does not affect HTML export. Use /H instead.
/H={encodingName, writeParagraphProperties, writeCharacterProperties, PNGOrJPEG, quality, bitDepth}
Controls the creation of an HTML file.
encodingName specifies the HTML file text encoding. The recommended value is 
"UTF-8".

SaveNotebook
V-824
Details
Interactive (/I) means that Igor displays the Save, Save As, or Save a Copy dialog.
writeParagraphProperties determines what paragraph properties SaveNotebook will 
write to the HTML file. This is a bitwise parameter with the bits defined as follows:
Bit 0: Write paragraph alignment.
Bit 1: Write first indent.
Bit 2: Write minimum line spacing.
Bit 3: Write space-before and space-after paragraph.
All other bits are reserved for future use and should be set to zero.
writeCharacterProperties determines what character properties SaveNotebook will 
write to the HTML file. This is a bitwise parameter with the bits defined as follows:
Bit 0: Write font families.
Bit 1: Write font sizes.
Bit 2: Write font styles.
Bit 3: Write text colors.
Bit 4: Write text vertical offsets.
All other bits are reserved for future use and should be set to zero.
If you set bit 2, SaveNotebook exports only the bold, underline, and italic styles 
because other character styles are not supported by HTML.
PNGOrJPEG determines whether SaveNotebook will write picture files as PNG or 
JPEG:
0: PNG (default).
1: JPEG.
2: JPEG.
In Igor7 and later, there is no difference between PNGOrJPEG=1 and PNGOrJPEG=2.
See Details for more on HTML picture files.
quality specifies the degree of compression or image quality when writing pictures as 
JPEG files. Legal values are in the range 0.0 to 1.0.
In Igor7 or later, the quality used is 0.9 regardless of what you pass for this parameter.
bitDepth specifies the color depth when writing pictures as JPEG files. Legal values are 
legal: 1, 8, 16, 24, and 32.
In Igor7 or later, the bit depth used is 32 regardless of what you pass for this 
parameter.
/I
Saves interactively. A dialog is displayed.
/M=messageStr
Specifies prompt message used in save dialog.
/O
Overwrites existing file without asking permission.
/P=pathName
Specifies the folder to store the file in. pathName is the name of an existing symbolic path.
/S=saveType
Controls the type of save.
saveType=1:
Normal save (default).
saveType=2:
Save-as.
saveType=3:
Save-a-copy.
saveType=4:
Export as RTF (Rich Text Format).
saveType=5:
Export as HTML (Hypertext Markup Language).
saveType=6:
Export as plain text.
saveType=7:
Export as formatted notebook.
saveType=8:
Export as plain text with line breaks.
