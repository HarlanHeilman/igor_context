# Loading Custom Date Formats

Chapter II-9 — Importing and Exporting Data
II-144
In this case, since we requested no suffix number, all of the generated wave names are Data and LoadWave 
displays a dialog in which you can enter unique names.
// nameOptions=4 means always include a sequential suffix number
/NAME={":filename:","",4}
// Bit 2 set
LoadWave generates wave names Data0, Data1, and Data2. If any of these waves exist and you include the 
/O (overwrite) flag, they are overwritten. If they exist and you omit /O, LoadWave displays a dialog in 
which you can enter unique names.
// nameOptions=20 means always include a unique suffix number
/NAME={":filename:","",20}
// 20 = 4 | 16 (bits 2 and 4 set)
LoadWave generates wave names like Data0, Data1, and Data2 where the suffix numbers are chosen to 
make the names unique. If you execute the same command on the same file a second time, LoadWave gen-
erates wave names Data3, Data4, and Data5.
Loading Multiple Waves Using the File Name and the Normal Name
In this section, we assume that we are loading a file named "Data.txt" and that we are loading three waves 
from the file. We further assume that the file contains the column names ColumnA, ColumnB, and 
ColumnC and that we include the /W flag to load the column names from the file.
// nameOptions=1 means include the normal name
/W /NAME={":filename:_","",1}
This generates wave names Data_ColumnA, Data_ColumnB, and Data_ColumnC. If any of these waves 
exist and you include the /O (overwrite) flag, they are overwritten. If they exist and you omit /O, LoadWave 
displays a dialog in which you can enter unique names.
// nameOptions=21 means always include the normal name and a unique suffix number
/W /NAME={":filename:_","",21}
// 21 = 1 | 4 | 16 (bits 0, 2 and 4 set)
LoadWave generates wave names Data_ColumnA0, Data_ColumnB0, and Data_ColumnC0 where the 
suffix numbers are chosen to make the wave names unique. If you execute the same command on the same 
file a second time, LoadWave generates wave names Data_ColumnA1, Data_ColumnB1, and Data_-
ColumnC1.
This technique could also be used with the /B flag instead of the /W flag to create wave names combining 
the file name and additional names explicitly specified by /B. See Setting Wave Names When Loading Data 
Files on page II-176 for a functional example.
Other LoadWave Features
This section discusses other issues that apply to loading text data files.
Loading Custom Date Formats
This section applies to loading delimited text (/J), fixed field text (/F) and general text (/G) files.
