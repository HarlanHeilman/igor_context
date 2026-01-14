# Open File Dialog File Filters

Chapter IV-6 — Interacting with the User
IV-149
The /F flag is used to control the file filter which determines what kinds of files the user can select. This is 
explained further under Open File Dialog File Filters.
Displaying a Multi-Selection Open File Dialog
You can display an Open File dialog to allow the user to choose multiple files to be used with subsequent 
commands. The multi-selection Open File dialog is displayed using an Open/D/R/MULT=1 command. The 
list of files selected is returned via S_fileName in the form of a carriage-return-delimited list of full paths.
Here is an example:
Function/S DoOpenMultiFileDialog()
Variable refNum
String message = "Select one or more files"
String outputPaths
String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"
fileFilters += "All Files:.*;"
Open /D /R /MULT=1 /F=fileFilters /M=message refNum
outputPaths = S_fileName
if (strlen(outputPaths) == 0)
Print "Cancelled"
else
Variable numFilesSelected = ItemsInList(outputPaths, "\r")
Variable i
for(i=0; i<numFilesSelected; i+=1)
String path = StringFromList(i, outputPaths, "\r")
Printf "%d: %s\r", i, path
endfor
endif
return outputPaths
// Will be empty if user canceled
End
Here the Open operation does not actually open a file but instead displays an Open File dialog. Because 
/MULT=1 was used, if the user chooses one or more files and clicks the Open button, the Open operation 
returns the list of full paths to files in the S_fileName output string variable. If the user cancels, Open sets 
S_fileName to "".
The list of full paths is delimited with a carriage return character, represented by "\r" in the example above. 
We use carriage return as the delimiter because the customary delimiter, semicolon, is a legal character in 
a Macintosh file name. 
The /M flag is used to set the prompt message. As of OS X 10.11, Apple no longer shows the prompt message 
in the Open File dialog. It continues to work on Windows.
The /F flag is used to control the file filter which determines what kinds of files the user can select. This is 
explained further under Open File Dialog File Filters.
Open File Dialog File Filters
The Open operation displays the open file dialog if you use the /D/R flags or if the file to be opened is not 
fully specified using the pathName and fileNameStr parameters. The Open File dialog includes a file filter 
menu that allows the user to choose the type of file to be opened. By default this menus contain "Plain Text 
Files" and "All Files". You can use the /T and /F flags to override the default filter behavior.
The /T flag uses obsolescent Macintosh file types or file name extensions consisting of a dot plus three char-
acters. The /F flag, added in Igor Pro 6.10, supports file name extensions only (not Macintosh file types) and 
extensions can be from one to 31 characters. Procedures written for Igor Pro 6.10 or later should use the /F
