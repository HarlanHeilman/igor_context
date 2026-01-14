# airyAD

airyA
V-24
Details
Only files and waves saved external to the current experiment are adopted. See References to Files and 
Folders on page II-24 for a discussion of such standalone files.
The number of objects actually adopted is returned in V_Flag.
To adopt just one wave, use:
AdoptFiles/WV=wave
To adopt just one notebook or procedure window use AdoptFiles/W=winTitleOrName.
Command Line and Macro Examples
// Using AdoptFiles from the command line or from a macro
AdoptFiles/I
// Show the Adopt All dialog.
AdoptFiles/A/WP
// Adopt everything that can be adopted.
AdoptFiles/DF/NB/UP/WP
// Adopt everything that can be adopted.
AdoptFiles/DF=root:subfolder
// Adopt any externally saved waves in root:subfolder.
AdoptFiles/W=$"Proc0.ipf"
// Adopt Proc0.ipf if it is saved externally.
AdoptFiles/WV=GetWavesDataFolder(wave0,2)
// Adopt wave0 if it is saved externally.
Function Examples
// Using AdoptFiles from a user-defined function - you must use Execute/P
Execute/P "AdoptFiles/A"
// Schedule adoption of all user files and waves
Execute/P "AdoptFiles/WV="+GetWavesDataFolder(w,2)
// Schedule adoption of wave w
See Also
Adopt All on page II-25, Adopting Notebook and Procedure Files on page II-25, Avoiding Shared Igor 
Binary Wave Files on page II-24, Operation Queue on page IV-278.
airyA 
airyA(x [, accuracy])
The airyA function returns the value of the Airy Ai(x) function:
where K is the modified Bessel function.
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The airyAD and airyB functions.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
airyAD 
airyAD(x [, accuracy])
The airyAD function returns the value of the derivative of the Airy function.
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The airyA function.
/WV=wave
Adopts only the specified wave.
Ai(x) = 1
π
x
3K1/3
2
3 x3/2
⎛
⎝⎜
⎞
⎠⎟,
