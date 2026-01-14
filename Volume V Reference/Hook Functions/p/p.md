# p

Override
V-731
If you searched for a minimum: 
If you searched for a maximum: 
Variables for all functions: 
Waves for a multivariate function: 
See Also
Finding Minima and Maxima of Functions on page III-343 for further details and examples.
References
The Optimize operation uses Brent’s method for univariate functions. Numerical Recipes has an excellent 
discussion (see section 10.2) of this method (but we didn’t use their code):
Press, William H., Saul A. Teukolsky, William T. Vetterling, and Brian P. Flannery, Numerical Recipes in C, 
2nd ed., 994 pp., Cambridge University Press, New York, 1992.
For multivariate functions Optimize uses code based on Dennis and Schnabel. To truly understand what 
Optimize does, read their book:
Dennis, J. E., Jr., and Robert B. Schnabel, Numerical Methods for Unconstrained Optimization and Nonlinear 
Methods, 378 pp., Society for Industrial and Applied Mathematics, Philadelphia, 1996.
Override 
Override constant objectName = newVal
Override strconstant objectName = newVal
Override Function funcName()
The Override keyword redefines a constant, strconstant, or user function. The objectName or funcName must 
be the same as the name of the original object or function that is being redefined. The override must be 
defined before the target object appears in the compile sequence.
See Also
Function Overrides on page IV-106 and Constants on page IV-51 for further details.
p 
p
The p function returns the row number of the current row of the destination wave when used in a wave 
assignment statement. The row number is the same as the point number for a 1D wave.
5:
Maximum step size was exceeded in five consecutive iterations. This may 
mean that the maximum step size is too small, or that the function is 
unbounded in the search direction (that is, goes to -inf if you are 
searching for a minimum), or that the function approaches the solution 
asymptotically (function is bounded but doesn’t have a well-defined 
extreme point).
6:
Same as V_flag = 791.
V_min
Function value (Y) at the minimum.
V_max
Function value (Y) at the maximum.
V_OptNumIters
Number of iterations taken before Optimize terminated.
V_OptNumFunctionCalls
Number of times your function was called before Optimize terminated.
W_extremum
Solution if you didn’t use /X=<xWave>. Otherwise the solution is returned in your X wave.
W_OptGradient
Estimated gradient of your function at the solution.
