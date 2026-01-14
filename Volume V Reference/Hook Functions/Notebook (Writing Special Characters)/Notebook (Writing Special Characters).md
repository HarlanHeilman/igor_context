# Notebook (Writing Special Characters)

Notebook (Writing Special Characters)
V-709
Notebook
(Writing Special Characters) 
Writing special character parameters
This section of Notebook relates to inserting special characters at the current selection in the notebook. To 
insert a notebook action, see NotebookAction.
The special characters are page break, short date, long date, abbreviated date and time. They act in some 
respects like a single character but have special properties. You can insert the special characters using the 
specialChar keyword.
The specialChar keyword is allowed for formatted text files only, not for plain text files.
Other special characters are allowed in headers and footers only and you can not insert them in a document 
using the specialChar keyword. These are window title, page number and total pages.
The special characters other than page break character are dynamic and update periodically.
The variable V_flag is set to 1 if the picture was written or to 0 otherwise, for example, 
if the user canceled from the Save File dialog.
The string variable S_name is set to the special character name of the picture that was 
saved or to "" if no picture was saved.
The string variable S_fileName is set to the full path of the file that was written or to 
"" if no picture was written.
specialChar={type, flags, optionsStr}
flags is reserved for future use. You should pass 0 for flags.
optionsStr is reserved for future use. You should pass "" for optionsStr.
specialUpdate=flags
Updates special characters in the notebook.
options is a bitwise parameter interpreted as follows:
All other bits are reserved and must be set to zero.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
If set, a Save File dialog is displayed even if the file is fully specified by 
pathName and filePath.
Bit 1:
If set, a file with the same name is overwritten if it exists. If cleared, a 
Save File dialog is displayed if the specified file already exists.
Bit 2:
If set then the leaf name specified by filePath is ignored and a name is 
automatically generated based on the picture name.
type is the special character type as follows:
1:
Page break.
2:
Short date.
3:
Long date.
4:
Abbreviated date.
5:
Time.
flags is interpreted bitwise:
If 1, updates regardless of whether updating is enabled or not.
All other bits are reserved and must be set to zero.
See Setting Bit Parameters on page IV-12 for details about bit settings.
Bit 0:
0 to update all special characters.
Bit 1:
1 to update special characters in the selected text.
