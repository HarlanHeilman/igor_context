# Curve Fitting Using Commands

Chapter III-8 — Curve Fitting
III-263
This is a very simple example, intended to show only the most basic aspects of fitting with a structure fit 
function. An advanced programmer could add a control panel user interface, plus code to automatically 
calculate initial guesses and provide a default value of the x0 constant.
The WMFitInfoStruct Structure
In addition to the required structure members, you can include a WMFitInfoStruct structure member 
immediately after the required members. The WMFitInfoStruct structure, if present, will be filled in by 
FuncFit with information about the progress of fitting, and includes a member allowing you to stop fitting 
if your fit function detects a problem.
Adding a WMFitInfoStruct member to the structure in the example above:
Structure expFitStruct
Wave coefw
// Required coefficient wave.
Variable x
// Required X value input.
STRUCT WMFitInfoStruct fi
// Optional WMFitInfoStruct.
Variable x0
// Constant.
EndStructure
And the members of the WMFitInfoStruct:
The IterStarted and ParamPerturbed members may be useful in some obscure cases to short-cut 
lengthy computations. The DoingDestWave member may be useful in an all-at-once structure fit function.
Multivariate Structure Fit Functions
To fit multivariate functions (those having more than one dimension or independent variable) you simply 
use an array for the X member of the structure. For instance, for a basic 2D structure fit function:
Structure My2DFitStruct
Wave coefw
Variable x[2]
…
EndStructure
Or a 2D all-at-once structure fit function:
Structure My2DAllAtOnceFitStruct
Wave coefw
Wave yw
Wave xw[2]
…
EndStructure 
Curve Fitting Using Commands
A few curve fitting features are not completely supported by the Curve Fitting dialog, such as constraints 
involving combinations of fit coefficients, or user-defined fit functions involving more complex construc-
WMFitInfoStruct Structure Members
Member
Description
char IterStarted
Nonzero on the first call of an iteration.
char DoingDestWave
Nonzero when called to evaluate the autodestination wave.
char StopNow
Fit function sets this to nonzero to indicate that a problem has 
occurred and fitting should stop.
Int32 IterNumber
Number of iterations completed.
Int32 ParamPerturbed
Index of the fit coefficient being perturbed for the calculation of 
numerical derivatives. Set to -1 when evaluating a solution 
point with no perturbed coefficients.
