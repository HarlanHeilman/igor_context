# KillWaves Operation Examples

Chapter II-5 — Waves
II-71
•
You no longer need a wave that you created for temporary use in an Igor procedure.
The Kill Waves dialog provides an interface to the KillWaves operation. To use it, choose Kill Waves from 
the Data menu.
Igor will not let you kill waves that are used in graphs, tables or user-defined functions so they do not 
appear in the list.
Note:
Igor can not tell if a wave is referenced from a macro. Thus, Igor will let you kill a wave that is 
referenced from a macro but not used in any other way. The most common case of this is when 
you close a graph and save it as a recreation macro. Waves that were used in the graph are now 
used only in the macro and Igor will let you kill them. If you execute the graph recreation macro, 
it will be unable to recreate the graph.
KillWaves can delete the Igor binary wave file from which a wave was loaded, called the “source file”. This 
is normally not necessary because the wave you are killing either has never been saved to disk or was saved 
as part of a packed experiment file and therefore was not loaded from a standalone file.
The “Kill all waves not in use” option is intended for those situations where you have created an Igor exper-
iment that contains procedures which load, graph and process a batch of waves. After you have processed 
one batch of waves, you can kill all graphs and tables and then kill all waves in the experiment in prepara-
tion for loading the next batch. This affects only those waves in the current data folder; waves in any other 
data folders will not be killed.
KillWaves Operation Examples
Here are some simple examples using KillWaves.
// Kills all target windows and all waves.
// Does not kill nontarget windows (procedure and help windows).
Function KillEverything()
String windowName
do
windowName = WinName(0, 1+2+4+16+64)// Get next target window
if (CmpStr(windowName, "") == 0) // If name is ""
break
// we are done so break loop
endif
KillWindow $windowName
// Kill this target window
while (1)
KillWaves/A
// Kill all waves
End
// This illustrates killing a wave used temporarily in a procedure
Function Median(w)
// Returns median value of wave w
Wave w
Variable result
Duplicate/O w, temp
// Make a clone of wave
Sort temp, temp
// Sort clone
result = temp[numpnts(temp)/2]
KillWaves temp
// Kill clone
return result
End
For more examples, see the “Kill Waves” procedure file in the “WaveMetrics Procedures” folder.
