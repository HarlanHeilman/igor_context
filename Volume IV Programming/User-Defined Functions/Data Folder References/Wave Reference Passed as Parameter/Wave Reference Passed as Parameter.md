# Wave Reference Passed as Parameter

Chapter IV-3 — User-Defined Functions
IV-82
Function/DF MainRoutine()
DFREF dfr = Subroutine("MyDataFolder")
Display dfr:wave0, dfr:wave1
End
Data Folder Reference Waves
You can create waves that contain data folder references using the Make /DF flag. You can use a data folder 
reference wave as a list of data folders for further processing and in multithreaded wave assignment using 
the MultiThread keyword.
Data folder reference waves are recommended for advanced programmers only.
Note:
Data folder reference waves are saved only in packed experiment files. They are not saved in 
unpacked experiments and are not saved by the SaveData operation or the Data Browser's Save 
Copy button. In general, they are intended for temporary computation purposes only.
Make/DF without any assignment creates a wave containing null data folder references. Similarly, inserting 
points or redimensioning to a larger size initializes the new points to null. Deleting points or redimension-
ing to a smaller size deletes any free data folders if the wave contained the only reference to them.
To determine if a given wave is a type that stores data folder references, use the WaveType function with 
the optional selector = 1.
For an example using a data folder reference wave for multiprocessing, see Data Folder Reference Multi-
Thread Example on page IV-325.
Accessing Waves in Functions
To access a wave in a user-defined function, we need to create, one way or another, a wave reference. The 
section Accessing Global Variables and Waves on page IV-65 explained how to access a wave using a 
WAVE reference. This section introduces several additional techniques.
We can create the wave reference by:
•
Declaring a wave parameter
•
Using $<string expression>
•
Using a literal wave name
•
Using a wave reference function
Each of these techniques is illustrated in the following sections.
Each example shows a function and commands that call the function. The function itself illustrates how to 
deal with the wave within the function. The commands show how to pass enough information to the func-
tion so that it can access the wave. Other examples can be found in Writing Functions that Process Waves 
on page III-171.
Wave Reference Passed as Parameter
This is the simplest method. The function might be called from the command line or from another function.
Function Test(w)
WAVE w
// Wave reference passed as a parameter
w += 1
// Use in assignment statement
Print mean(w)
// Pass as function parameter
WaveStats w
// Pass as operation parameter
AnotherFunction(w)
// Pass as user function parameter
End
Make/O/N=5 wave0 = p
Test(wave0)
