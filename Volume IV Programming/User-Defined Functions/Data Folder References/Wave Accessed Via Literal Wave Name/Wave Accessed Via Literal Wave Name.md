# Wave Accessed Via Literal Wave Name

Chapter IV-3 — User-Defined Functions
IV-84
Notice that we create a wave reference immediately after making the wave. Once we do this, we can use 
the wave reference in all of the ways shown in the preceding section. We can not create the wave reference 
before making the wave because a wave reference must refer to an existing wave.
The following example demonstrates that $wName and the wave reference w can refer to a wave that is not 
in the current data folder.
NewDataFolder root:Folder1
Test("root:Folder1:wave0")
Wave Accessed Via String Calculated in Function
This technique is used when creating multiple waves in a function or when algorithmically selecting a wave 
or a set of waves to be processed.
Function Test(baseName, startIndex, endIndex)
String baseName
Variable startIndex, endIndex
Variable index = startIndex
do
String name = baseName + num2istr(index)
WAVE w = $name
Variable avg = mean(w)
Printf "Wave: %s; average: %g\r", NameOfWave(w), avg
index += 1
while (index <= endIndex)
End
Make/O/N=5 wave0=gnoise(1), wave1=gnoise(1), wave2=gnoise(1)
Test("wave", 0, 2)
We need to use this method because we want the function to operate on any number of waves. If the func-
tion were to operate on a small, fixed number of waves, we could use the wave parameter method.
As in the preceding section, we create the wave reference using $<string expression>.
Wave Accessed Via Literal Wave Name
In data acquisition or analysis projects, you often need to write procedures that deal with runs of identically-
structured data. Each run is stored in its own data folder and contains waves with the same names. In this 
kind of situation, you can write a set of functions that use literal wave names specific for your data structure.
Function CreateRatio()
WAVE dataA, dataB
Duplicate dataA, ratioAB
WAVE ratioAB
ratioAB = dataA / dataB
End
Make/O/N=5 dataA = 1 + p, dataB = 2 + p
CreateRatio()
The CreateRatio function assumes the structure and naming of the data. The function is hard-wired to this 
naming scheme and assumes that the current data folder contains the appropriate data.
We don’t need explicit wave reference variables because Make and Duplicate creat automatic wave refer-
ence for simple wave names, as explained under Automatic Creation of WAVE References on page IV-72.
