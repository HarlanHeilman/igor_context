# FuncFitMD

FuncFitMD
V-276
For more details, and for examples of sums of fit functions in use, Fitting Sums of Fit Functions on page III-244.
See Also
The CurveFit operation for parameter details. See also FuncFitMD for user-defined multivariate fits to data 
in a multidimensional wave.
The best way to create a user-defined fitting function is using the Curve Fitting dialog. See Using the Curve 
Fitting Dialog on page III-181, especially the section Fitting to a User-Defined Function on page III-190.
For details on the form of a user-defined function, see User-Defined Fitting Functions on page III-250.
FuncFitMD 
FuncFitMD [flags] fitFuncName, cwaveName, waveName [flag parameters]
The FuncFitMD operation performs a curve fit to the specified multivariate user defined fitFuncSpec. 
FuncFitMD handles gridded data sets in multidimensional waves. Most parameters and flags are the same 
as for the CurveFit and FuncFit operations; differences are noted below.
cwaveName is a 1D wave containing the fitting coefficients, and functionName is the user-defined fitting 
function, which has 2 to 4 independent variables.
FuncFitMD operation parameters are grouped in the following categories: flags, parameters (fitFuncName, 
cwaveName, waveName), and flag parameters. The sections below correspond to these categories. Note that 
flags must precede the fitFuncName and flag parameters must follow waveName.
CONST={constants}
Sets the values of constants in the fitting function. So far, only two built-in 
functions take constants: exp_XOffset and dblexp_XOffset. They each take just 
one constant (the X offset), so you will have a “list” of one number inside the 
braces.
EPSW=epsilonWave
Specifies a wave holding epsilon values. Use only with a user-defined fitting 
function to set the differencing interval used to calculate numerical estimates of 
derivatives of the fitting function.
STRC=structureInstance Specifies an instance of the structure to FuncFit when using a structure fit 
function. structureInstance is an instance that was initialized by a user-defined 
function that invokes FuncFit. This keyword (and structure fitting functions) can 
be used only when calling FuncFit from within a user-defined function. See 
Structure Fit Functions on page III-261 for more details.

FuncFitMD
V-277
Flags
Parameters
Flag Parameters
These flag parameters must follow waveName.
Details
Auto-residual (/R with no wave specified) and auto-trace (/D with no wave specified) for functions having two 
independent variables are plotted in a separate graph window if waveName is plotted as a contour or image in 
the top graph. An attempt is made to plot the model values and residuals in the same way as the input data.
/L=dimSize
Sets the dimension size of the wave created by the auto-trace feature, that is, /D 
without destination wave. The wave fit_waveName will be a multidimensional wave 
of the same dimensionality as waveName that has dimSize elements in each dimension. 
That is, if you are fitting to a matrix wave, fit_waveName will be a square matrix that 
has dimensions dimSize XdimSize. Beware: dimSize =100 requires 100 million points for 
a 4-dimensional wave!
fitFuncName
User-defined function to fit to, which must be a function taking 2 to 4 independent 
variables.
cwaveName
1D wave containing the fitting coefficients.
waveName
The wave containing the dependent variable data to be fit to the specified function. 
For functions of just one independent variable, the dependent variable data is often 
referred to as "Y data". You can fit to a subrange of the wave by supplying 
(startX,endX) or [startP,endP] for each dimension after the wave name. See Wave 
Subrange Details below for more information on subranges of waves in curve fitting. 
/E=ewaveName
A wave containing the epsilon values for each parameter. Must be the same length as 
the coefficient wave.
/T=twaveName
Like /X except for the T independent variable. This is a 1D wave having as many 
elements as waveName has chunks.
/X=xwaveName
The X independent variable values for the data to fit come from xwaveName instead of 
from the X scaling of waveName. This is a 1D wave having as many elements as 
waveName has rows.
/Y=ywaveName
Like /X except for the Y independent variable. This is a 1D wave having as many 
elements as waveName has columns.
/Z=ywaveName
Like /X except for the Z independent variable. This is a 1D wave having as many 
elements as waveName has layers.
/NWOK
Allowed in user-defined functions only. When present, certain waves may be set to 
null wave references. Passing a null wave reference to FuncFitMD is normally treated 
as an error. By using /NWOK, you are telling FuncFitMD that a null wave reference 
is not an error but rather signifies that the corresponding flag should be ignored. This 
makes it easier to write function code that calls FuncFitMD with optional waves.
The waves affected are the X wave or waves (/X), the Y spacing wave (/Y), the Z 
spacking wave (/Z) the T spacing wave (/T), weight wave (/W), epsilon wave (/E) and 
mask wave (/M). The destination wave (/D=wave) and residual wave (/R=wave) are 
also affected, but the situation is more complicated because of the dual use of /D and 
/R to mean "do autodestination" and "do autoresidual". See /AR and /AD.
If you don't need the choice, it is better not to include this flag, as it disables useful 
error messages when a mistake or run-time situation causes a wave to be missing 
unexpectedly.
Note: To work properly this flag must be the last one in the command.
