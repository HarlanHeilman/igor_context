# WaveName

WaveModCount
V-1079
WaveModCount
WaveModCount(wave)
The WaveModCount function returns a value that can be used to tell if a global wave has been changed 
between one call to WaveModCount and another.
WaveModCount was added in Igor Pro 8.00.
The exact value returned by WaveModCount has no significance. The only use for it is to compare the 
values returned by two calls to WaveModCount. If they are the different, the wave was changed in the 
interim.
The wave mod count for free and thread-local waves is undefined, so WaveModCount should only be used 
with global waves in the data hierarchy of the main thread.
A wave's mod count changes when the wave's data or properties, such as scaling, note, and dimensionality, 
are set. The mod count changes even if the new data or property values are the same as the old. For example, 
executing:
wave1 += 0
causes the mod count to change even though the data itself was not actually changed.
Examples
Make/O wave1 = 5
Variable waveModCount1, waveModCount2
waveModCount1 = WaveModCount(wave1);
wave1 += 1
// Modify wave1
waveModCount2 = WaveModCount(wave1);
if (waveModCount2 != waveModCount1)
Print "Wave has changed"
endif
See Also
WaveInfo, ModDate
WaveName 
WaveName(winNameStr, index, type)
The WaveName function returns a string containing the name of the indexth wave of the specified type in 
the named window or subwindow.
Parameters
winNameStr can be "" to refer to the top graph or table.
When identifying a subwindow with winNameStr, see Subwindow Syntax on page III-92 for details on 
forming the window hierarchy.
Details
WaveName works on waves displayed in a graph, in a table or on the list of waves in the current data folder. 
If the window is a table, WaveName returns the column name (e.g., “wave0.d”), rather than the name of 
the wave itself (e.g., “wave0”).
For most uses, we recommend that you use WaveRefIndexed or WaveRefIndexedDFR instead of 
WaveName. WaveName returns a string containing the wave name only, with no data folder path 
qualifying it. Thus, you may get erroneous results if the wave referred to in the graph has the same name 
as a different wave in the current data folder. Likewise, if the named wave resides in a data folder that is 
not the current data folder, you will not be able to refer to the named wave. Use WaveRefIndexedDFR 
instead.
winNameStr is a string expression containing the name of a graph or table or an empty string (""). If the 
string is empty and type is 4 then WaveName works on the list of all waves in the current data folder. If the 
string is empty and the type parameter is not 4 then WaveName works on the top graph or table.
index starts from zero.
type is a number from 1 to 4. When type is 4 and winNameStr is "", WaveName works on the list of all waves 
in the current data folder.
For graph windows, type is 1 for y waves, 2 for x waves, 3 for either y or x waves.
