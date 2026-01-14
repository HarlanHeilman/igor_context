# Setting Wave Names When Loading Data Files

Chapter II-9 — Importing and Exporting Data
II-176
Setting Wave Names When Loading Data Files
In this section we show how to programmatically set the names of waves loaded from a delimited text file. 
For background information, see LoadWave Generation of Wave Names on page II-142.
We assume that the file contains three columns of numbers with no column labels and we want to create 
waves named Stimulus, CellA, and CellB. We use the LoadWave /B flag to set the wave names.
Function/S GetColumnInfoStr1()
String columnInfoStr = ""
columnInfoStr += "N='Stimulus';"
columnInfoStr += "N='CellA';"
columnInfoStr += "N='CellB';"
return columnInfoStr
End
Function LoadAndSetNames1(pathName, fileName)
String pathName
// Name of symbolic path or "" to get dialog
String fileName
// Name of file or "" to get dialog
String columnInfoStr = GetColumnInfoStr1()
LoadWave/J/O/P=$pathName/B=columnInfoStr fileName
if (V_Flag == 0)
return -1
// Failure
endif
return 0
// Success
End
Next we include the name of the file being loaded, minus the file name extension, in the wave names. Given 
a file named "Data.txt", this creates waves named Data_Stimulus, Data_CellA, and Data_CellB.
Function/S GetColumnInfoStr2(String baseName)
String columnInfoStr = ""
columnInfoStr += "N='" + baseName + "_" + "Stimulus';"
columnInfoStr += "N='" + baseName + "_" + "CellA';"
columnInfoStr += "N='" + baseName + "_" + "CellB';"
return columnInfoStr
End
Function LoadAndSetNames2(pathName, fileName)
String pathName
// Name of symbolic path
String fileName
// Name of file
// This version does requires that you provide the actual symbolic path
// and file name.
if (strlen(pathName)==0 || strlen(fileName)==0)
return -1
// Failure
endif
String fileNameMinusExtension = ParseFilePath(3, fileName, ":", 0, 0)
String baseName = CleanupName(fileNameMinusExtension, 0)
String columnInfoStr = GetColumnInfoStr2(baseName)
LoadWave/J/A/O/P=$pathName/B=columnInfoStr fileName
if (V_Flag == 0)
return -1
// Failure
endif
return 0
// Success
End
