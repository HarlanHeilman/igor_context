# Exporting Data

Chapter II-9 — Importing and Exporting Data
II-177
Finally we include the name of the file being loaded, minus the file name extension, in the wave names 
using the LoadWave /NAME flag which requires Igor Pro 9.00 or later. Given a file named "Data.txt", this 
creates waves named Data_Stimulus, Data_CellA, and Data_CellB, the same as the preceding example.
Function/S GetColumnInfoStr3()
String columnInfoStr = ""
columnInfoStr += "N='Stimulus';"
columnInfoStr += "N='CellA';"
columnInfoStr += "N='CellB';"
return columnInfoStr
End
Function LoadAndSetNames3(pathName, fileName)
String pathName
// Name of symbolic path or "" to get dialog
String fileName
// Name of file or "" to get dialog
String columnInfoStr = GetColumnInfoStr3()
LoadWave/J/A/O/P=$pathName/B=columnInfoStr/NAME={":filename:_","",1} 
fileName
if (V_Flag == 0)
return -1
// Failure
endif
return 0
// Success
End
See Using the File Name in Wave Names on page II-142 for details on the /NAME flag.            
Exporting Data
Igor automatically saves the waves in the current experiment on disk when you save the experiment. Many 
Igor users load data from files into Igor and then make and print graphs or layouts. This is the end of the 
process. They have no need to explicitly save waves.
You can save waves in an Igor packed experiment file for archiving using the SaveData operation or using 
the Save Copy button in the Data Browser. The data in the packed experiment can then be reloaded into 
Igor using the LoadData operation or the Load Expt button in Data Browser. Or you can load the file as an 
experiment using FileOpen Experiment. See the SaveData operation on page V-815 for details.
The main reason for saving a wave separate from its experiment is to export data from Igor to another pro-
gram. To explicitly save waves to disk, you would use Igor’s Save operation.
You can access all of the built-in routines via the Save Waves submenu of the Data menu.
The following table lists the available data saving routines in Igor and their salient features.
File type
Description
Delimited text
Used for archiving results or for exporting to another program.
Row Format: <data><delimiter><data><terminator>*
Contains one block of data with any number of rows and columns. A row of column 
labels is optional.
Columns may be equal or unequal in length.
Can export 1D or 2D waves.
See Saving Waves in a Delimited Text File on page II-178.
