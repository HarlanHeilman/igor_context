# Format of a Basic Fitting Function

Chapter III-8 — Curve Fitting
III-251
User-Defined Fitting Function Formats
You can use three formats for user-defined fitting functions: the Basic format discussed above, the All-At-
Once format, and Structure Fit Functions, which use a structure as the only input parameter. Additionally, 
Structure Fit Functions come in basic and all-at-once variants. Each of these formats address particular sit-
uations.
The basic format (see Format of a Basic Fitting Function on page III-251) was the original format. It returns 
just one model value at a time.
The all-at-once format (see All-At-Once Fitting Functions on page III-256) addresses problems in which the 
operations involved, such as convolution, integration, or FFT, naturally calculate all the model values at 
once. Because of reduced function-call overhead, it is somewhat faster than the basic format for large data 
sets.
The structure-based format (see Structure Fit Functions on page III-261) uses a structure as the only func-
tion parameter, allowing arbitrary information to be transmitted to the function during fitting. This makes 
it very flexible, but also makes it necessary that FuncFit be called from a user-defined function.
Format of a Basic Fitting Function
A basic user-defined fitting function has the following form:
Function F(w, x) : FitFunc
WAVE w; Variable x
<body of function>
<return statement>
End
You can choose a more descriptive name for your function.
The function must have exactly two parameters in the univariate case shown above. The first parameter is the 
coefficients wave, conventionally called w. The second parameter is the independent variable, conventionally 
called x. If your function has this form, it will be recognized as a curve fitting function and will allow you to 
use it with the FuncFit operation.
The FitFunc keyword marks the function as being intended for curve fitting. Functions with the FitFunc 
keyword that have the correct format are included in the Function menu in the Curve Fitting dialog.
Basic Fit Function
All-At-Once Function
Structure Function
Can be selected, created, and edited 
within the Curve Fitting dialog.
Can be selected, but not created or 
edited, within the Curve Fitting 
dialog.
Cannot be used from the Curve 
Fitting dialog.
With appropriate comments, 
mnemonic coefficient names.
No mnemonic coefficient names.
Must be used with FuncFit called 
from a user-defined function.
Straight-forward programming: 
one X value, one return value.
Programming requires a good 
understanding of wave 
assignment; there are some issues 
that can be difficult to avoid.
Hardest to program: requires 
both an understanding of 
structures and writing a driver 
function that calls FuncFit.
Not an efficient way to write a fit 
function that uses convolution, 
integration, FFT, or any operation 
that uses all the data values in a 
single operation.
Most efficient for problems 
involving operations like 
convolution, integration, or FFT. 
Often much faster than the Basic 
format, even for problems that 
don’t require it.
Very flexible: any arbitrary 
information can be transmitted to 
the fit function. More information 
about the fit progress transmitted 
via the structure.
See Format of a Basic Fitting 
Function on page III-251.
See All-At-Once Fitting 
Functions on page III-256.
See Structure Fit Functions on 
page III-261.
