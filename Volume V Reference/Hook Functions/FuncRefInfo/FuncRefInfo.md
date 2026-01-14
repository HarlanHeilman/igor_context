# FuncRefInfo

FUNCREF
V-278
By default the auto-trace and auto-residual waves are 50x50 or 25x25x25 or 15x15x15x15. Use /L=dimSize for 
other sizes. Make your own wave and use /D=waveName or /R=waveName if you want a wave that isn’t 
square. In this case, the wave dimensions must be the same as the dependent data wave.
Confidence bands are not available for multivariate fits.
Wave Subrange Details
Almost any wave you specify to FuncFitMD can be a subrange of a wave. The syntax for wave subranges 
is the same as for the Display command; see Subrange Display Syntax on page II-321 for details. Note that 
the dependent variable data (waveName) must be a multidimensional wave; this requires an extension of the 
subrange syntax to allow a multidimensional subrange. See Wave Subrange Details on page V-274 for a 
discussion of the use of subranges in curve fitting.
The backwards compatibility rules for CurveFit apply to FuncFitMD as well.
A subrange could be used to pick a plane from a 3D wave for fitting using a fit function taking two 
independent variables:
Make/N=(100,100,3) DepData
FuncFitMD fitfunc2D, myCoefs, DepData[][][0] …
See Also
The CurveFit operation for parameter details.
The best way to create a user-defined fitting function is using the Curve Fitting dialog. See Using the Curve 
Fitting Dialog on page III-181, especially the section Fitting to a User-Defined Function on page III-190.
For details on the form of a user-defined function, see User-Defined Fitting Functions on page III-250.
FUNCREF 
FUNCREF protoFunc func [= funcSpec]
Within a user function, FUNCREF is a reference that creates a local reference to a function or a variable 
containing a function reference.
When passing a function as an input parameter to a user function, the syntax is:
FUNCREF protoFunc func
In this FUNCREF reference, protoFunc is a function that specifies the format of the function that can be 
passed by the FUNCREF, and func is a function reference used as an input parameter.
When you declare a function reference variable within a user function, the syntax is:
FUNCREF protoFunc func = funcSpec
Here, the local FUNCREF variable, func, is assigned a funcSpec, which can be a literal function name, a $ 
string expression that evaluates at runtime, or another FUNCREF variable.
See Also
Function References on page IV-107 for an example and further usage details.
FuncRefInfo 
FuncRefInfo(funcRef)
The FuncRefInfo function returns information about a FUNCREF.
Parameters
funcRef is a function reference variable declared by a FUNCREF statement in a user-defined function.
Details
FuncRefInfo returns a semicolon-separated keyword/value string containing the following information:
See Also
Function References on page IV-107 and FUNCREF on page V-278.
