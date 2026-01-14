# Determining a Function’s Target Data Folder

Chapter IV-7 — Programming Techniques
IV-171
Writing these procedures is greatly simplified by the fact that the names of the items in a run are fixed. For 
example, step 2 could be written as:
Function GraphOneRun()
// Graphs data run in the current data folder.
SVAR conditions
NVAR temperature
WAVE appliedVoltage, luminosity
Display luminosity vs appliedVoltage
String text
sprintf text, "Temperature: %g.\rExperimental conditions: %s.",
temperature, conditions
Textbox text
End
To create a graph, you would first set the current data folder to point to a run of data and then you would 
invoke the GraphOneRun function.
The Data Folder Tutorial experiment shows in detail how to accomplish the three steps listed above. Choose 
FileExample ExperimentsTutorialsData Folder Tutuorial.
Setting and Restoring the Current Data Folder
There are many reasons why you might want to save and restore the current data folder. In this example, 
we have a function that does a curve fit to a wave passed in as a parameter. The CurveFit operation creates 
two waves, W_coef and W_sigma, in the current data folder. If you use the /D option, it also creates a des-
tination wave in the current data folder. In this function, we make sure that the W_coef, W_sigma and des-
tination waves are all created in the same data folder as the source wave.
Function DoLineFit(w)
WAVE w
String saveDF = GetDataFolder(1)
SetDataFolder GetWavesDataFolder(w,1)
CurveFit line w /D
SetDataFolder saveDF
End
Many other operations create output waves in the current data folder. Depending on what your goal is, you 
may want to use the technique shown here to control where the output waves are created.
A function should always save and restore the current data folder unless it is designed explicitly to change 
the current data folder.
Determining a Function’s Target Data Folder
There are three common methods for determining the data folder that a function works on or in:
1.
Passing a wave in the target data folder as a parameter
2.
Having the function work on the current data folder
3.
Passing a DFREF parameter that points to the target data folder
For functions that operate on a specific wave, method 1 is appropriate.
For functions that operation on a large number of variables within a single data folder, methods 2 or 3 are 
appropriate. In method 2, the calling routine sets the data folder of interest as the current data folder. In 
method 3, the called function does this, and restores the original current data folder before it returns.
