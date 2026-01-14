# CreateDataObjectName

CreateBrowser
V-113
CreateBrowser
CreateBrowser [/M] [keyword = value [, keyword = value …]]
The CreateBrowser operation creates a data browser window.
Documentation for the CreateBrowser operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "CreateBrowser"
CreateDataObjectName
CreateDataObjectName(dfr, nameInStr, objectType, suffixNum, options)
The CreateDataObjectName function returns a name suitable for use for a new object of the type specified 
by objectType. It can replace a combination of CleanupName and UniqueName.
CreateDataObjectName was added in Igor Pro 9.00 or later.
Parameters
dfr is a data folder reference for the data folder in which the objects are to be created. Pass : for the current 
data folder.
nameInStr must contain an unquoted (i.e., no single quotes for liberal names) name, such as you might 
receive from the user through a dialog or control panel.
objectType is one of the following:
suffixNum is a value used in generating a series of names from a base name when allowing overwriting. For 
other uses, pass 0 for suffixNum. See Generating a Series of Names from a Base Name below.
options is a bitwise parameter with the bits defined as follows:
1:
Wave
3:
Numeric variable
4:
String variable
11:
Data folder
Bit 0:
Be liberal.
If cleared, CreateDataObjectName always returns a standard object name. If set, it returns a 
liberal object name if nameInStr is liberal. See Object Names on page III-501 for a discussion 
of standard and liberal object names.
If objectType is 3 (numeric variable) or 4 (string variable), the output name will not be 
liberal, even if this bit is set as Igor allows only wave and data folder names to be liberal.
Bit 1:
Allow overwrite.
If cleared, CreateDataObjectName returns a name that is unique in the namespace of the 
type of object specified by objectType. If set, CreateDataObjectName returns a name that 
may be in use in that namespace.
Waves, numeric variables and string variables are in the same namespace and so must have 
unique names within a given data folder. Data folders are in their own namespace and so 
their names can be the same as the names of waves, numeric variables and string variables.
Bit 2:
Input name is a base name.
If cleared, nameInStr is taken to be a proposed object name that CreateDataObjectName 
cleans up (i.e., makes legal). If the name is in use and allow overwrite is not specified, 
CreateDataObjectName makes the name unique by appending one or more digits.
If set, nameInStr is taken to be a proposed base name for a series of objects and the output 
name always has at least one digit appended. CreateDataObjectName cleans the name up 
and then appends one or more digits. If allow overwrite is not specified, the appended digits 
are chosen to return a unique name. If allow overwrite is specified, the appended digits 
represent suffixNum whether there is an existing object with the resulting name or not.
