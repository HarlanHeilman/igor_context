# WaveRefWaveToList

WaveRefsEqual
V-1081
Example
// DemoWaveRefIndexedDFR can be called like this:
//
DemoWaveRefIndexedDFR(root:, 0)
// Work on root
//
DemoWaveRefIndexedDFR(root:SubDataFolder, 0)
// Work on root:SubDataFolder
//
DemoWaveRefIndexedDFR(:, 0)
// Work on current data folder
Function DemoWaveRefIndexedDFR(dfr, recurse)
DFREF dfr
Variable recurse
Variable index = 0
do
Wave/Z w = WaveRefIndexedDFR(dfr, index)
if (!WaveExists(w))
break
endif
String path = GetWavesDataFolder(w, 2)
Print path
index += 1
while(1)
if (recurse)
Variable numChildDataFolders = CountObjectsDFR(dfr, 4)
Variable i
for(i=0; i<numChildDataFolders; i+=1)
String childDFName = GetIndexedObjNameDFR(dfr, 4, i)
DFREF childDFR = dfr:$childDFName
DemoWaveRefIndexedDFR(childDFR, 1)
endfor
endif
End
See Also
WaveRefIndexed, NameOfWave, GetWavesDataFolder
For a discussion of wave references, see Wave Reference Functions on page IV-197.
WaveRefsEqual
WaveRefsEqual(w1, w2)
The WaveRefsEqual function returns the truth the two wave references are the same.
See Also
Wave Reference Functions on page IV-197
WaveRefWaveToList
WaveRefWaveToList(waveRefWave, option)
The WaveRefWaveToList function returns a semicolon-separated string list containing data folder paths.
Each element of the returned string list is the full or partial path to the wave referenced by the 
corresponding element of waveRefWave. Entries in waveRefWave that are NULL or entries that correspond 
to free waves result in an empty list element.
The WaveRefWaveToList function was added in Igor Pro 7.00.
Parameters
waveRefWave is a wave reference wave each element of which contains a reference to an existing wave or 
NULL (0).
option determines if the returned path is a full path or a partial path relative to the current data folder:
Other values of option are reserved for the future.
option=0:
Full path.
option=1:
Partial path relative to the current data folder.
