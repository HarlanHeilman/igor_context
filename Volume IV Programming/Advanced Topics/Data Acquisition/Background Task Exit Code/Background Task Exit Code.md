# Background Task Exit Code

Chapter IV-10 — Advanced Topics
IV-319
Chart Recorder Control Demos
Igor Pro Folder:Examples:Feature Demos:FIFO Chart Demo FM.pxp
Igor Pro Folder:Examples:Feature Demos:FIFO Chart Overhead.pxp
Igor Pro Folder:Examples:Feature Demos:Wave Review Chart Demo.pxp
Igor Pro Folder:Examples:Imaging:Image Strip FIFO Demo.pxp
Background Tasks
Background tasks allow procedures to run periodically "in the background" while you continue to interact 
normally with Igor. This is useful for data acquisition, simulations and other processes that run indefinitely, 
over long periods of time, or need to run at regular intervals. Using a background task allows you to con-
tinue to interact with Igor while your data acquisition or simulation runs.
Originally Igor supported just one unnamed background task controlled using the CtrlBackground oper-
ation (page V-118). New code should use the CtrlNamedBackground operation (page V-119) to create 
named background tasks instead, as shown in the following sections. You can run any number of named 
backgrounds tasks.
In addition to the documentation provided here, the Background Task Demo experiment provides sample 
code that is designed to be redeployed for other projects. We recommend reading this documentation first 
and then opening the demo by choosing FileExample ExperimentsProgrammingBackground Task 
Demo.
Background Task Example #1
You create and control background tasks using the CtrlNamedBackground operation. The main parame-
ters of CtrlNamedBackground are the background task name, the name of a procedure to be called period-
ically, and the period. Here is a simple example:
Function TestTask(s)
// This is the function that will be called periodically
STRUCT WMBackgroundStruct &s
Printf "Task %s called, ticks=%d\r", s.name, s.curRunTicks
return 0
// Continue background task
End
Function StartTestTask()
Variable numTicks = 2 * 60
// Run every two seconds (120 ticks)
CtrlNamedBackground Test, period=numTicks, proc=TestTask
CtrlNamedBackground Test, start
End
Function StopTestTask()
CtrlNamedBackground Test, stop
End
You start this background task by calling StartTestTask() from the command line or from another pro-
cedure. StartTestTask creates a background task named Test, sets the period which is specified in units of 
ticks (1 tick = 1/60th of a second), and specifies the user-defined function to be called periodically (TestTask 
in this example).
You stop the Test background task by calling StopTestTask().
As shown above, the background procedure takes a WMBackgroundStruct parameter. In most cases you 
won’t need to access it.
Background Task Exit Code
The background procedure (TestTask in the example above) returns an exit code to Igor. The code is one of 
the following values:
