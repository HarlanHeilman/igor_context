# SavePackagePreferences

SavePackagePreferences
V-825
The save will be interactive under the following conditions:
•
You include the /I flag and the saveType is 2, 3, 4, 5, 6, 7 or 8.
•
saveType is 2, 3, 4, 5, 6, 7 or 8 and you do not specify the path or filename.
If the saveType is normal and the notebook has previously been saved to a file then the /I flag, the path and 
file name that you specify, if any, are ignored and the notebook is saved to its associated file without user 
intervention.
The full path to the saved file is stored in the string S_path. If the save was unsuccessful, S_path will be "".
If you use /P=pathName, note that it is the name of an Igor symbolic path, created via NewPath. It is not a 
file system path like “hd:Folder1:” or “C:\\Folder1\\”. See Symbolic Paths on page II-22 for details.
saveType=8 applies to formatted notebooks only. It exports the notebook as plain text with line breaks where 
text wraps in the formatted notebook. This feature was added in Igor Pro 8.00. Special characters such as 
pictures are skipped. If the notebook is plain text then saveType=8 acts like saveType=6.
Exporting as RTF
For background information on writing RTF files, see Import and Export Via Rich Text Format Files on 
page III-20.
Exporting as HTML
For background information on writing HTML files, see Exporting a Notebook as HTML on page III-21.
You can pass “UTF-8” or “UTF-2” for the encodingName parameter. In virtually all cases, you should use 
“UTF-8”.
When creating an HTML file, SaveNotebook can write pictures using the PNG or JPEG graphics formats. PNG 
is recommended because it is lossless.
See Also
Chapter III-1, Notebooks.
 Setting Bit Parameters on page IV-12 for further details about bit settings.
SavePackagePreferences 
SavePackagePreferences [/FLSH=flush /KILL /P=pathName] packageName, 
prefsFileName, recordID, prefsStruct
The SavePackagePreferences operation saves preference data in the specified structure so that it can be 
accessed later via the LoadPackagePreferences operation.
The structure can use fields of type char, uchar, int16, uint16, int32, uint32, int64, uint64, float and double 
as well as fixed-size arrays of these types and substructures with fields of these types.
The data is stored in memory and by default flushed to disk when the current experiment is saved or closed 
and when Igor quits.
If the /P flag is present then the location on disk of the preference file is determined by pathName and 
prefsFileName. However in the usual case the /P flag will be omitted and the preference file is located in a file 
named prefsFileName in a directory named packageName in the Packages directory in Igor’s preferences directory.
See Saving Package Preferences on page IV-251 for background information and examples.
Parameters
packageName is the name of your package of Igor procedures. It is limited to 31 bytes and must be a legal 
name for a directory on disk. This name must be very distinctive as this is the only thing preventing 
collisions between your package and someone else’s package.
Note:
The package preferences structure must not use fields of type Variable, String, WAVE, 
NVAR, SVAR or FUNCREF because these fields refer to data that may not exist when 
LoadPackagePreferences is called.
Note:
You must choose a very distinctive name for packageName as this is the only thing 
preventing collisions between your package and someone else’s package.
