# Wave Reference Waves

Chapter IV-3 — User-Defined Functions
IV-77
Wave Reference Waves
You can create waves that contain wave references using the Make /WAVE flag. You can use a wave refer-
ence wave as a list of waves for further processing and in multithreaded wave assignment using the Mul-
tiThread keyword.
Wave reference waves are recommended for advanced programmers only.
Note:
Wave reference waves are saved only in packed experiment files. They are not saved in unpacked 
experiments and are not saved by the SaveData operation or the Data Browser's Save Copy 
button. In general, they are intended for temporary computation purposes only.
Here is an example:
Make/O wave0, wave1, wave2
// Make some waves
Make/O/WAVE wr
// Make a wave reference wave
wr[0]=wave0; wr[1]=wave1; wr[2]=wave2
// Assign values
The wave reference wave wr could now be used, for example, to pass a list of waves to a function that per-
forms display or analysis operations.
Make/WAVE without any assignment creates a wave containing null wave references. Similarly, inserting 
points or redimensioning to a larger size initializes the new points to null. Deleting points or redimension-
ing to a smaller size deletes any free waves if the deleted points contained the only reference to them.
To determine if a given wave is a type that stores wave references, use the WaveType function with the 
optional selector = 1.
In the next example, a subroutine supplies a list of references to waves to be graphed by the main routine. 
A wave reference wave is used to store the list of wave references.
Function MainRoutine()
Make/O/WAVE/N=5 wr
// Will contain references to other waves
wr= Subroutine(p)
// Fill w with references
WAVE w= wr[0]
// Get reference to first wave
Display w
// and display in a graph
Variable i
for(i=1;i<5;i+=1)
WAVE w= wr[i]
// Get reference to next wave
AppendToGraph w
// and append to graph
endfor
End
Function/WAVE Subroutine(i)
Variable i
String name = "wave"+num2str(i)
// Create a wave with a computed name and also a wave reference to it
Make/O $name/WAVE=w = sin(x/(8+i))
return w
// Return the wave reference to the calling routine
End
As another example, here is a function that returns a wave reference wave containing references to all of the 
Y waves in a graph:
Function/WAVE GetListOfYWavesInGraph(graphName)
String graphName
// Must contain the name of a graph
// If graphName is not valid, return NULL wave
