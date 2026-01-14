# TickWavesFromAxis

ticks
V-1034
Parameters
tgID is thread group ID returned by ThreadGroupCreate, index is the desired thread of the group to set up 
to execute the specified ThreadSafe WorkerFunc.
Details
The worker function starts running immediately.
The worker function must be defined as ThreadSafe and must return a real or complex numeric result.
The worker function's return value can be obtained after the function finishes by calling 
ThreadReturnValue. Igor records the fact that a thread has terminated when you call ThreadGroupWait so 
you must call ThreadGroupWait before calling ThreadReturnValue.
The worker function can take variable and wave parameters. It can not take pass-by-reference parameters 
or data folder reference parameters.
Any waves you pass to the worker are accessible to both the main thread and to your preemptive thread. 
Such waves are marked as being in use by a thread and Igor will refuse to perform any manipulations that 
could change the size of the wave.
See Also
The ThreadGroupCreate and ThreadReturnValue functions; ThreadSafe Functions on page IV-106, and 
ThreadSafe Functions and Multitasking on page IV-329.
ticks 
ticks
The ticks function returns the number of ticks (approximately 1/60 second) elapsed since the operating 
system was initialized.
See Also
The StopMSTimer function.
TickWavesFromAxis
TickWavesFromAxis [ /W=graphName /DEST= {textWaveName, numericWaveName} /O 
/AUTO=mode ] axisName
The TickWavesFromAxis operation generates a pair of waves suitable for use as user tick waves (see User 
Ticks from Waves on page II-313). This allows you to programmatically determine the tick marks and tick 
labels that Igor would create for a given graph axis in auto mode.
TickWavesFromAxis was added in Igor Pro 8.00.
TickWavesFromAxis generates two waves: a two-column text wave containing tick labels and the names of 
tick types, and a numeric wave giving the positions of the ticks along the axis. By default, the information 
stored in the output waves reflects the automatically generated ticks based on the current axis settings but 
you can change this using the /AUTO flag.
By default the waves are given names derived from the graph window and axis name: 
<graphname>_<axisname>_labels and <graphname>_<axisname>_values. Use /DEST to give the waves custom 
names.
Parameters
axisName is the name of the axis for which the tick waves are generated. This will usually be left, bottom, 
right or top, but may be the name of a free axis.
