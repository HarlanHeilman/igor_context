# CreateAliasShortcut

CountObjectsDFR
V-111
See Also
Chapter II-8, Data Folders, and the GetIndexedObjName function.
CountObjectsDFR 
CountObjectsDFR(dfr,objectType)
The CountObjectsDFR function returns the number of objects of the specified type in the data folder 
specified by the data folder reference dfr.
CountObjectsDFR is the same as CountObjects except the first parameter, dfr, is a data folder reference 
instead of a string containing a path.
Parameters
dfr is a data folder reference.
objectType is one of the following values:
See Also
Data Folders on page II-107, Data Folder References on page IV-78, Built-in DFREF Functions on page 
IV-81, GetIndexedObjNameDFR
cpowi 
cpowi(num, ipow)
This function is obsolete as the exponentiation operator ^ handles complex expressions with any 
combination of real, integer and complex arguments. See Operators on page IV-6. The cpowi function 
returns a complex number resulting from raising complex num to integer-valued power ipow. ipow can be 
positive or negative, but if it is not an integer cpowi returns (NaN, NaN).
CreateAliasShortcut 
CreateAliasShortcut [flags][targetFileDirStr] [as aliasFileStr]
The CreateAliasShortcut operation creates an alias (Macintosh) or shortcut (Windows) file on disk. The alias 
can point to either a file or a folder. The file or folder pointed to is called the “target” of the alias or shortcut.
Parameters
targetFileDirStr can be a full path to the file or folder to make an alias or shortcut for, a partial path relative to 
the folder associated with /P=pathName, or the name of a file or folder in the folder associated with pathName.
If Igor can not determine the location of the file or folder from targetFileDirStr and pathName, it displays a 
dialog allowing you to specify a target file. Use /D to select a folder as the alias target, instead.
aliasFileStr can be a full path to the created alias file, a partial path relative to the folder associated with 
pathName if specified, or the name of a file in the folder associated with pathName.
If Igor can not determine the location of the alias or shortcut file from aliasFileStr and pathName, it displays 
a File Save dialog allowing you to create the file.
If you use a full or partial path for either targetFileDirStr or aliasFileStr, see Path Separators on page III-451 
for details on forming the path.
Folder paths should not end with single path separators. See the MoveFolder Details section.
Flags
1
Waves
2
Numeric variables
3
String variables
4
Data folders
/D
Uses the Select Folder dialog rather than Open File dialog when targetFileDirStr is not 
fully specified.

CreateAliasShortcut
V-112
Variables
The CreateAliasShortcut operation returns information in the following variables:
Examples
Create a shortcut (Windows) to the current experiment, on the desktop:
String target= Igorinfo(1)+".pxp" // experiments are usually .pxp on Windows
CreateAliasShortcut/O/P=home target as "C:WINDOWS:Desktop:"+target
Create an alias (Macintosh) to the VDT XOP in the Igor Extensions folder:
String target= ":More Extensions:Data Acquisition:VDT"
CreateAliasShortcut/O/P=Igor target as ":Igor Extensions:VDT alias"
Create an alias to the “HD 2” disk. Put the alias on the desktop:
CreateAliasShortcut/D/O "HD 2" as "HD:Desktop Folder:Alias to HD 2"
See Also
Symbolic Paths on page II-22.
The Open, MoveFile, DeleteFile, and GetFileFolderInfo operations. The IgorInfo and ParseFilePath 
functions.
/I [=i]
/M=messageStr
Specifies the prompt message in the Open File or Select Folder dialog. If /S is not specified, 
then messageStr will be used for Open File (or Select Folder) and for Save File dialogs.
/O
Overwrites any existing file with the alias or shortcut file.
/P=pathName
Specifies the folder to look in for the file. pathName is the name of an existing symbolic 
path.
/S=saveMessageStr
Specifies the prompt message in the Save File dialog when creating the alias or shortcut 
file.
/Z[=z]
V_flag
S_fileName
Full path to the target file or folder. If an error occurred or if the user cancelled, it is an 
empty string.
S_path
Full path to the created alias or shortcut file. If an error occurred or if the user cancelled, 
it is an empty string.
Specifies the level of user interactivity.
/I=0:
Interactive only if one or targetFileDirStr or aliasFileStr is not specified 
or if the target file is missing. (Same as if /I was not specified.)
/I=1:
Interactive even if targetFileDirStr is fully specified and the target file 
exists.
/I=2:
Interactive even if targetFileDirStr is specified.
/I=3:
Interactive even if targetFileDirStr is specified and the target file 
exists. Same as /I only.
Prevents procedure execution from aborting the procedure tries to create an alias or 
shortuct for a file or folder that does not exist. Use /Z if you want to handle this case 
in your procedures rather than aborting execution.
/Z=0:
Same as no /Z.
/Z=1:
Creates an alias to a file or folder only if it exists. /Z alone has the same 
effect as /Z=1.
/Z=2:
Creates an alias to a file or folder only if it exists and displays a dialog 
if it does not exist.
Status output:
0
Created an alias or shortcut file.
1
User cancelled any of the Open File, Select Folder, or Save File dialogs.
Other:
An error occurred, such as the target file does not exist.
