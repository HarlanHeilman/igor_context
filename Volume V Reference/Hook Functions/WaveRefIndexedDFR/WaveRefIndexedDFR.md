# WaveRefIndexedDFR

WaveRefIndexed
V-1080
For table windows, type is 1 for data columns, 2 for index or dimension label columns, 3 for either data or 
index or dimension label columns.
WaveName returns an empty string ("") if there is no wave matching the parameters.
Examples
WaveName("",0,4)
// Returns name first wave current data folder.
WaveName("",0,1)
// Returns name of first Y wave in the top graph.
WaveName("Graph0",1,2)
// Returns name of second X wave in Graph0.
WaveName("Table0",1,3)
// Returns name of second column in Table0.
WaveRefIndexed 
WaveRefIndexed(winNameStr, index, type)
The WaveRefIndexed function returns a wave reference to the indexth wave of the specified type in the 
named window or subwindow.
To iterate through the waves in a data folder, use WaveRefIndexedDFR instead of WaveRefIndexed.
Parameters
winNameStr can be "" to refer to the top graph or table window or the current data folder.
When identifying a subwindow with winNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
WaveRefIndexed is analogous to WaveName but works better with data folders. We recommend that you 
use it instead of WaveName.
winNameStr is a string expression containing the name of a graph or table or an empty string (""). If the 
string is empty and type is 4 then WaveRefIndexed works on Igor’s list of all waves in the current data 
folder. If the string is empty and the type parameter is not 4 then WaveRefIndexed works on the top graph 
or table.
index starts from zero.
type is a number from 1 to 4. When type is 4 and winNameStr is "", WaveRefIndexed works on the list of all 
waves in the current data folder.
For graph windows, type is 1 for y waves, 2 for x waves, 3 for either y or x waves.
For table windows, type is 1 for data columns, 2 for index or dimension label columns, 3 for either data or 
index or dimension label columns.
WaveRefIndexed returns a null reference (see WaveExists) if there is no wave matching the parameters.
Examples
WaveRefIndexed("",0,1)
// Returns first Y wave in the top graph.
WaveRefIndexed("Graph0",1,2)
// Returns second X wave in Graph0.
WaveRefIndexed("Table0",1,3)
// wave in second column in Table0.
See Also
WaveRefIndexedDFR, NameOfWave, GetWavesDataFolder
For a discussion of wave references, see Wave Reference Functions on page IV-197.
WaveRefIndexedDFR
WaveRefIndexedDFR(dfr, index)
The WaveRefIndexedDFR function returns a wave reference to the indexth wave in the specified data folder.
Parameters
dfr is a data folder reference.
index is the zero-based index of the wave you want to access.
Details
WaveRefIndexedDFR returns a null reference (see WaveExists) if there is no wave corresponding to index 
in the specified data folder.
