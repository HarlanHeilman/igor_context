# expInt

ExperimentModified
V-212
Print "=== All data objects, human, headers, names only ==="
int flags = kHumanMask | kHeadersMask | kRecursiveMask
ExperimentInfo getLongNameUsage={*, 7, flags, kLongNamesLength}
// Printf "\r"
// Skip this because headers mode prints trailing blank line
End
See Also
ExperimentModified, IgorInfo, Long Object Names on page III-502
ExperimentModified
ExperimentModified [newModifiedState]
The ExperimentModified operation gets and optionally sets the modified (save) state of the current 
experiment.
Use this command to prevent Igor from asking you to save the current experiment after you have made 
changes you do not need to save or, conversely, to force Igor to ask about saving the experiment even 
though Igor would not normally do so. 
The variable V_flag is always set to the experiment-modified state that was in effect before the 
ExperimentModified command executed: 1 for modified, 0 for not modified.
Parameters
If newModifiedState is present, it sets the experiment-modified state as follows:
If newModifiedState is omitted, the state of experiment-modified state is not changed.
Details
Executing ExperimentModified 0 on the command line will not work because the command will be echoed 
to the history area, marking the experiment as modifed. Use the command in a function or macro that does 
not echo text to the history area.
Examples
The /Q flag is vital: it suppresses printing into the history area which would mark the experiment as 
modified again.
Menu "File"
"Mark Experiment Modified",/Q,ExperimentModified 1
// Enables "Save Experiment"
"Mark Experiment Saved",/Q,ExperimentModified 0
// Disables "Save Experiment"
End
See Also
SaveExperiment, ExperimentInfo, Menu Definition Syntax on page IV-126.
expInt 
expInt(n, x)
The expInt function returns the value of the exponential integral En(x):
See Also
ei, ExpIntegralE1
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
newModifiedState = 0:
Igor will not ask to save the experiment before quitting or opening another 
experiment, and the Save Experiment menu item will be disabled.
newModifiedState = 1:
Igor will ask to save the experiment before quitting or opening another 
experiment, and the Save Experiment menu item will be enabled.
En(x) = P
e−xt
t n dt
1
∞∫
(x > 0;n = 0, 1, 2…).
