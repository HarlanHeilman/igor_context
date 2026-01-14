# Displaying a Save File Dialog

Chapter IV-6 — Interacting with the User
IV-150
flag in most cases but can use /T or both /T and /F. Procedures that must run with Igor Pro 6.0x and earlier 
must use the /T flag.
Using the /T=typeStr flag, you specify acceptable Macintosh-style file types represented by four-character 
codes (e.g., "TEXT") or acceptable three-character file name extensions (e.g., ".txt"). The pattern "????" means 
"any type of file" and is represented by "All Files" in the filter menu.
typeStr may contain multiple file types or extensions (e.g., "TEXTEPSF????" or ".txt.eps????"). Each file type 
or extension must be exactly four characters in length. Consequently the /T flag can accommodate only 
three-character file name extensions. Each file type or extension creates one entry in the Open File dialog 
filter menu.
If you use the /T flag, the Open operation automatically adds a filter for All Files ("????") if you do not add 
one explicitly.
Igor maps Macintosh file types to extensions. For example, if you specify /T="TEXT", you can open files with 
the extension ".txt" as well as any file whose Macintosh file type property is 'TEXT'. Igor does similar map-
pings for other extensions. See File Types and Extensions on page III-455 for details.
Using the /F=fileFilterStr flag, you specify a filter menu string plus acceptable file name extensions for each 
filter. fileFilterStr specifies one or more filters in a semicolon-separated list. For example, this specifies three 
filters:
String fileFilters = "Data Files (*.txt,*.dat,*.csv):.txt,.dat,.csv;"
fileFilters += "HTML Files (*.htm,*.html):.htm,.html;"
fileFilters += "All Files:.*;"
Open /F=fileFilters . . .
Each file filter consists of a filter menu string (e.g., "Data Files") followed by a colon, followed by one or 
more file name extensions (e.g., ".txt,.dat,.csv") followed by a semicolon. The syntax is rigid - no extra char-
acters are allowed and the semicolons shown above are required. In this example the filter menu would 
contain "Data Files" and would accept any file with a ".txt", ".dat", or ".csv" extension. ".*" creates a filter that 
accepts any file.
If you use the /F flag, it is up to you to add a filter for All Files as shown above. It is recommended that you 
do this.
Displaying a Save File Dialog
You can display a Save File dialog to allow the user to choose a file to be created or overwritten by a subse-
quent command. For example, the user can choose a file which you will then create or overwrite via a Save 
command. The Save File dialog is displayed using an Open/D command. Here is an example:
Function/S DoSaveFileDialog()
Variable refNum
String message = "Save a file"
String outputPath
String fileFilters = "Data Files (*.txt):.txt;"
fileFilters += "All Files:.*;"
Open /D /F=fileFilters /M=message refNum
outputPath = S_fileName
return outputPath
// Will be empty if user canceled
End
Here the Open operation does not actually open a file but instead displays a Save File dialog. If the user 
chooses a file and clicks the Save button, the Open operation returns the full path to the file in the S_file-
Name output string variable. If the user cancels, Open sets S_fileName to "".
