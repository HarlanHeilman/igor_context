# MacroInfo

lorentzianNoise
V-523
Note that you can invert the last expression to determine the value of LP(w) for any significance level.
See Also
The FFT and DSPPeriodogram operations.
References
1. J.H. Horne and S.L. Baliunas, Astrophysical Journal, 302, 757-763, 1986.
2. N.R. Lomb, Astrophysics and Space Science, 39, 447-462, 1976.
3. W.H. Press, B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling, Numerical Recipes, 3rd ed., Section 13.8.
lorentzianNoise 
lorentzianNoise(a,b)
The function returns a pseudo-random value from a Lorentzian distribution
Here a is the center and b is the full line width at half maximum (FWHM).
See Also
SetRandomSeed, enoise, gnoise.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview.
LowerStr 
LowerStr(str)
The LowerStr function returns a string expression identical to str except that all upper-case ASCII characters 
are converted to lower-case.
See Also
The UpperStr function.
Macro 
Macro macroName([parameters]) [:macro type]
The Macro keyword introduces a macro. The macro will appear in the Macros menu unless the procedure 
file has an explicit Macros menu definition. See Chapter IV-4, Macros and Macro Syntax on page IV-118 for 
further information.
MacroInfo
MacroInfo(macroNameStr)
The MacroInfo function returns a keyword-value pair list of information about the macro specified by 
macroNameStr.
MacroInfo was added in Igor Pro 9.01.
In this section, "macro" includes all types of interpreted procedures, namely procedures introduced by the 
Macro, Proc and Window keywords.
Parameters
macroNameStr is a string expression containing the name of a macro.
If macroNameStr is "", MacroInfo returns information about the currently executing macro or "" if no macro 
is executing.
p = 1 1 exp LP(w)
[
]
{
}
Nind .
f (x) = 1

(b / 2)
(x  a)2 + (b / 2)2 .
