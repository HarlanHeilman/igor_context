# Open and Close Operations

Chapter IV-7 — Programming Techniques
IV-196
Writing to a Text File
You can generate output text files from Igor procedures or from the command line in formats acceptable to 
other programs. To do this, you need to use the Open and Close operations and the fprintf operation (page 
V-260) and the wfprintf operation (page V-1093).
The following commands illustrate how you could use these operations to create an output text file. Each 
operation is described in detail in following sections:
Function WriteFileDemo(pathName, fileName)
String pathName
// Name of Igor symbolic path (see Symbolic Paths)
String fileName
// File name, partial path or full path
Variable refNum
Open refNum as "A New File"
// Create and open file
fprintf refNum, "wave1\twave2\twave3\r"
// Write column headers
Wave wave1, wave2, wave3
wfprintf refNum, "" wave1, wave2, wave3
// Write wave data
Close refNum
// Close file
End
Open and Close Operations
You use the Open operation (page V-716) to open a file. For our purposes, the syntax of the Open operation is:
Open [/R/A/P=pathName/M=messageStr] variableName [as "filename"]
variableName is the name of a numeric variable. The Open operation puts a file reference number in that 
variable. You use the reference number to access the file after you’ve opened it.
A file specifications consists of a path (directions for finding a folder) and a file name. In the Open opera-
tion, you can specify the path in three ways:
Using a full path as the filename parameter:
Open refNum as “hd:Data:Run123.dat”
Or using a symbolic path name and a file name:
Open/P=DataPath refNum as “Run123.dat”
Or using a symbolic path name and a partial path including the file name:
Open/P=HDPath refNum as “:Data:Run123.dat”
A symbolic path is a short name that refers to a folder on disk. See Symbolic Paths on page II-22.
If you do not provide enough information to find the folder and file of interest, Igor displays a dialog which 
lets you select the file to open. If you supply sufficient information, Igor open the file without displaying 
the dialog.
To open an existing file for reading, use the /R flag. To append new data to an existing file, use the /A flag. 
If you omit both of these flags and if the file already exists, you overwrite any data that is in the file.
If you open a file for writing (you don’t use /R) then, if there exists a file with the specified name, Igor opens 
the file and overwrites the existing data in the file. If there is no file with the specified name, Igor creates a 
new file.
Warning: If you’re not careful you can inadvertently lose data using the Open operation by opening for 
writing without using the /A flag. To avoid this, use the /R (open for read) or /A (append) flags.
