# WaveList

WaveList
V-1075
WaveList 
WaveList(matchStr, separatorStr, optionsStr [, dfr ])
The WaveList function returns a string containing a list of wave names selected from the current data folder 
or the data folder specified by dfr based on matchStr and optionsStr parameters. The dfr parameter requires 
Igor Pro 9.00 or later.
See Details for information on listing waves in graphs, and for references to newer, data folder-aware 
functions.
Details
For a wave name to appear in the output string, it must match matchStr and also must fit the requirements 
of optionsStr and it must be in the current data folder. separatorStr is appended to each wave name as the 
output string is generated.
The name of each wave is compared to matchStr, which is some combination of normal characters and the 
asterisk wildcard character that matches anything.
For example:
matchStr may begin with the ! character to return items that do not match the rest of matchStr. For example:
The ! character is considered to be a normal character if it appears anywhere else, but there is no practical 
use for it except as the first character of matchStr.
optionsStr is used to further qualify the wave.
Use "" to accept all waves in the current data folder that are permitted by matchStr.
Set optionsStr to one or more of the following comma-separated keyword-value pairs:
"*"
Matches all wave names in current data folder.
"xyz"
Matches wave name xyz only, if xyz is in the current data folder.
"*xyz"
Matches wave names which end with xyz and are in the current data folder.
"xyz*"
Matches wave names which begin with xyz and are in the current data folder.
"*xyz*"
Matches wave names which contain xyz and are in the current data folder.
"abc*xyz"
Matches wave names which begin with abc and end with xyz and are in the current data 
folder.
"!*xyz"
Matches wave names which do not end with xyz.
optionsStr
Selection Criteria
"BYTE:0" or "BYTE:1" Waves that are not 8-bit integer (if 0) or only waves that are 8-bit integer (if 1).
"CMPLX:0" or 
"CMPLX:1"
Waves that are not complex (if 0) or only waves that are complex (if 1).
"DIMS:numberOfDims" All waves in current data folder that have numberOfDims dimensions. This is the 
number of dimensions reported by WaveDims.
Use "DIMS:0" for all waves having no points (numpnts(w)==0).
Use "DIMS:1" for graph traces (or one of the X, Y, and Z waves of a contour plot).
Use "DIMS:2" for false color and indexed color images (see Indexed Color 
Details on page II-400).
Use "DIMS:3" for direct color images (see Direct Color Details on page II-401).
"DF:0" or "DF:1"
Consider waves that are not data folder reference waves (if 0) or only waves that 
are data folder reference waves (if 1). You can create waves that contain data 
folder references using the Make /DF flag.

WaveList
V-1076
You can specify more than one option by separating the options with a comma. See the Examples.
There are several functions that are more useful for listing waves in graphs and tables.
WaveList with WIN:windowName gives only the names of the waves in the graph or table and does not 
include the data folder for each wave. If you need to know what data folder the waves are in, use 
WaveRefIndexed to get the wave itself and then if needed use GetWavesDataFolder to get the path.
When identifying a subwindow with WIN:windowName, see Subwindow Syntax on page III-92 for details 
on forming the window hierarchy.
"DP:0" or "DP:1"
Waves that are not double precision floating point (if 0) or only waves that are 
double precision floating point (if 1).
"INT64:0" or 
"INT64:1"
Consider waves that are not 64-bit integer (if 0) or only waves that are 64-bit 
integer (if 1). 64-bit integer waves are supported in Igor7 and later.
"INTEGER:0" or 
"INTEGER:1"
Waves that are not 32-bit integer (if 0) or only waves that are 32-bit integer (if 1).
"MAXCHUNKS:max"
Waves having no more than max chunks.
"MAXCOLS:max"
Waves having no more than max columns.
"MAXLAYERS:max"
Waves having no more than max layers.
"MAXROWS:max"
Waves having no more than max rows.
"MINCHUNKS:min"
Waves having at least min chunks.
"MINCOLS:min"
Waves having at least min columns.
"MINLAYERS:min"
Waves having at least min layers.
"MINROWS:min"
Waves having at least min rows.
"SP:0" or "SP:1"
Waves that are not single precision floating point (if 0) or only waves that are 
single precision floating point (if 1).
"TEXT:0" or "TEXT:1" Waves that are not text (if 0) or only waves that are text (if 1).
"UNSIGNED:0" or 
"UNSIGNED:1"
Waves that are not unsigned integer (if 0) or only waves that are unsigned 
integer (if 1).
"WAVE:0" or "WAVE:1" Consider waves that do not contain wave references (if 0) or only waves that 
contain wave references (if 1). You can create waves that contain wave 
references using the Make /WAVE flag.
"WIN:"
All waves in the current or specified data folder that are displayed in the top 
graph or table. The WIN option is not threadsafe.
"WIN:windowName"
All waves in the current or specified data folder that are displayed in the named 
table or graph window or subwindow. The WIN option is not threadsafe.
"WORD:0" or "WORD:1" Waves that are not 16-bit integer (if 0) or only waves that are 16-bit integer (if 1).
Note:
Even when optionsStr is used to list waves used in a graph or table, the waves must be in 
the current data folder.
Note:
In addition to waves displayed as normal graph traces, WaveList will list matrix waves 
used with AppendImage or NewImage and the X, Y, and Z waves used with 
AppendXYZContour.
Note:
Individual contour traces are not listed because they have no corresponding waves. See 
Contour Traces on page II-370.
optionsStr
Selection Criteria
