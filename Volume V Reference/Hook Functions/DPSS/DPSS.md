# DPSS

DoWindow/S
V-171
DoWindow/S 
DoWindow /N/S=styleMacroName windowName
DoWindow /R/S=styleMacroName windowName
The DoWindow/S operation creates a new “style macro” for the named window, using the specified style 
macro name. Does not create or replace the window macro for the specified window.
Flags
Details
The /R or /N flag must appear before the /S flag.
If the /S flag is present, the DoWindow operations does not create or replace the window macro for the 
specified window.
The /R and /N flags do nothing when executed while a macro or function is running. This is necessary because 
changing procedures while they are executing causes unpredictable and undesirable results.
DoXOPIdle 
DoXOPIdle
The DoXOPIdle operation sends an IDLE event to all open XOPs. This operation is very specialized. 
Generally, only the author of an XOP will need to use this operation.
Details
Some XOPs (External OPeration code modules) require IDLE events to perform certain tasks.
Igor does not automatically send IDLE events to XOPs while an Igor program is running. You can call 
DoXOPIdle from a user-defined program to force Igor to send the event.
DPSS
DPSS [flags] numPoints, numWindows
The DPSS operation generates Slepian's Discrete Prolate Spheroidal Sequences.
The DPSS operation was added in Igor Pro 7.00.
Flags
/N/S=styleMacroName
Creates a new style macro with the given name based on the named window.
/R/S=styleMacroName
Creates or replaces the style macro with the given name based on the named 
window.
/DEST=destWave
Saves the DPSS in a wave specified by destWave. The destination wave is overwritten 
if it exists.
Creates a wave reference for the destination wave in a user function. See Automatic 
Creation of WAVE References on page IV-72 for details.
If you omit /DEST the operation saves the result in the wave M_DPSS in the current 
data folder.
/EV=evWave
Saves the first numWindows eigenvalues in a wave specified by evWave. The 
eigenvalues are computed for a symmetric tridiagonal matrix. They are real, positive 
and close to 1. They can be used to estimate bias in multitaper calculations.
/FREE
Creates output waves as free waves.
/FREE is permitted in user-defined functions only, not from the command line or in 
macros.
If you use /FREE then destWave, evWave and sumsWave must be simple names, not 
paths.
See Free Waves on page IV-91 for details on free waves.
