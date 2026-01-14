# Destination Wave Parameters

Chapter IV-3 — User-Defined Functions
IV-85
Wave Accessed Via Wave Reference Function
A wave reference function is a built-in Igor function or user-defined function that returns a reference to a 
wave. Wave reference functions are typically used on the right-hand side of a WAVE statement. For exam-
ple:
WAVE w = WaveRefIndexedDFR(:,i)
// ith wave in current data folder
A common use for a wave reference function is to get access to waves displayed in a graph, using the Tra-
ceNameToWaveRef function. Here is an example.
Function PrintAverageOfDisplayedWaves()
String list, traceName
list = TraceNameList("",";",1)
// List of traces in top graph
Variable index = 0
do
traceName = StringFromList(index, list)
// Next trace name
if (strlen(traceName) == 0)
break
// No more traces
endif
WAVE w = TraceNameToWaveRef("", traceName)// Get wave ref
Variable avg = mean(w)
Printf "Wave: %s; average: %g\r", NameOfWave(w), avg
index += 1
while (1)
// loop till break above
End
Make/O/N=5 wave0=gnoise(1), wave1=gnoise(1), wave2=gnoise(1)
Display wave0, wave1, wave2
PrintAverageOfDisplayedWaves()
See Wave Reference Waves on page IV-77 for an example using WaveRefIndexed to return a list of all of 
the Y waves in a graph.
There are other built-in wave reference functions (see Wave Reference Functions on page IV-197), but 
WaveRefIndexed, WaveRefIndexedDFR and TraceNameToWaveRef are the most used.
See Wave Reference Function Results on page IV-76 for details on user-defined functions that return wave 
references.
Destination Wave Parameters
Many operations create waves. Examples are Make, Duplicate and Differentiate. Such operations take "des-
tination wave" parameters. A destination wave parameter can be:
The wave reference works only in a user-defined function. The other techniques work in functions, in 
macros and from the command line.
Using the first three techniques, the destination wave may or may not already exist. It is created if it does 
not exist and overwritten if it does exist.
A simple name
Differentiate fred /D=jack
A path
Differentiate fred /D=root:FolderA:jack
$ followed by a string expression
String str = "root:FolderA:jack"
Differentiate fred /D=$str
A wave reference to an existing wave
Wave w = jack
Differentiate fred /D=w
