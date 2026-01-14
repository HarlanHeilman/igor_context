# Conditionals

Chapter III-8 — Curve Fitting
III-252
The FitFunc keyword is not required. The FuncFit operation will allow any function that has a wave and a 
variable as the parameters. In the Curve Fitting dialog you can choose Show Old-Style Functions from the 
Function menu to display a function that lacks the FitFunc keyword, but you may also see functions that 
just happen to match the correct format but aren’t fitting functions.
Note that the function does not know anything about curve fitting. All it knows is how to compute a return 
value from its input parameters. The function is called during a curve fit when it needs the value for a 
certain X and a certain set of fit coefficients.
Here is an example of a user-defined function to fit a log function. This might be useful since log is not one 
of the functions provided as a built-in fit function.
Function LogFit(w,x) : FitFunc
WAVE w
Variable x
return w[0]+w[1]*log(x)
End
In this example, two fit coefficients are used. Note that the first is in the zero element of the coefficient wave. 
You cannot leave out an index of the coefficient wave. Igor uses the size of your coefficient wave to deter-
mine how many coefficients need to be fit. Consequently an unused element of the wave results in a singu-
lar matrix error.
Intermediate Results for Very Long Expressions
The body of the function is usually fairly simple but can be arbitrarily complex. If necessary, you can use 
local variables to build up the result, piece-by-piece. You can also call other functions or operations and use 
loops and conditionals.
If your function has many terms, you might find it convenient to use a local variable to store intermediate 
results rather than trying to put the entire function on one line. For example, instead of:
return w[0] + w[1]*x + w[2]*x^2
you could write:
Variable val
// local variable to accumulate result value
val = w[0]
val += w[1]*x
val += w[2]*x^2
return val
We often get fitting functions from our customers that use extremely long expressions derived by Mathe-
matica. These expressions are hard to read and understand, and highly resistant to debugging and modifi-
cation. It is well worth some effort to break them down using assignments to intermediate results.
Conditionals
Flow control statements including if statements are allowed in fit functions. You could use this to fit a 
piece-wise function, or to control the return value in the case of a singularity in the function.
Here is an example of a function that fits two lines to different sections of the data. It uses one of the param-
eters to decide where to switch from one line to the other:
Function PieceWiseLineFit(w,x) : FitFunc
WAVE w
Variable x
Variable result
if (x < w[4])
result = w[0]+w[1]*x
else
result = w[2]+w[3]*x
