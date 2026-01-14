# XWaveName

XWaveName
V-1118
<first row> and <last row> are 1-based row numbers. <first col> and <last col> are 1-based column numbers; 
1 refers to Column A. These refer to the defined rows and columns in the worksheet even if some or all cells 
are blank. If <last col> is zero, this means that there are no defined cells in the worksheet.
If infoMode is 3, XLLoadWave does not load the file but instead returns information about the first 
worksheet or the worksheet specified by /S via the string variable S_value. The format of the returned 
information is:
NAME:<worksheet name>;FIRST:<first cell>;LAST:<last cell>;
<first cell> and <last cell> are expressed in standard Excel notation (A1, B24, etc.). These refer to the defined 
rows and columns in the worksheet even if some or all cells are blank. If <last cell> is "@0", this means that 
there are no defined cells in the worksheet.
Use the StringByKey, NumberByKey functions to extract the information from S_value. If you use these 
functions, your code won't break if we later add a keyword/value pair to the returned information.
Examples
Old versions of Excel came with a number of sample files. One of them was called “Instrument Data”. The 
following procedure loads an area of this file, makes a table and then makes a graph of the loaded waves.
This example assumes that you have the "Instrument Data.xls" file and a symbolic path named Science that 
points to the folder containing the file.
Function InstrumentData()
// Load Instrument Data file from the Scientific Analysis folder
XLLoadWave/O/T/R=(C9,M27)/W=8/C=9/P=Science "Instrument Data.xls"
// Make graph.
Display M1, M2, M3 vs X_Time
Label bottom, "Time"; Label left, "Mass"
ModifyGraph dateInfo(bottom)={1,0,0}
End
See also Loading Excel Data Into a 2D Wave on page II-162.
XWaveName 
XWaveName(graphNameStr, traceNameStr)
The XWaveName function returns a string containing the name of the wave supplying the X coordinates 
for the named trace in the named graph window or subwindow.
Parameters
graphNameStr can be "" to refer to the top graph window.
When identifying a subwindow with graphNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
traceNameStr is the name of the trace in question.
Details
XWaveName returns an empty string ("") if the trace is not plotted versus an X wave.
For most uses, we recommend that you use XWaveRefFromTrace instead of WaveName. XWaveName 
returns a string containing the wave name only, with no data folder path qualifying it. Thus, you may get 
erroneous results if the X wave referred to in the graph has the same name as a different wave in the current 
data folder. Likewise, if the named wave resides in a folder that is not the current data folder, you will not 
be able to refer to the named wave.
graphNameStr and traceNameStr are strings, not names.
Examples
Display ywave vs xwave
// XY graph
Print XWaveName("","ywave")
// prints xwave
See also
Trace Names on page II-282, Programming With Trace Names on page IV-87.
