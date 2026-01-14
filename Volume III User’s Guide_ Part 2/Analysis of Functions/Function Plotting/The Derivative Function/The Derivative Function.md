# The Derivative Function

Chapter III-10 — Analysis of Functions
III-324
IntegrateODE has two schemes for returning solution results to you: you can specify X values where you 
need solution values, or you can let the solution “free run”.
In the first mode, results are returned to you at values of x corresponding to the X scaling of your Y waves, 
or at X values that you provide via an X wave or by providing X0 and deltaX and letting Igor calculate the 
X values. The actual calculation may require X increments smaller than those you ask for. Igor returns 
results only at the X values you ask for.
In free-run mode, IntegrateODE returns solution values for every step taken by the integration algorithm. 
In some cases, this may give you extremely small steps. Free-run mode returns to you not only the Y[i] 
values from the solution, but also values of x[i]. Free-run mode can be useful in that, to some degree, it will 
return results closely spaced when the solution is changing rapidly and with larger spacing when the solu-
tion is changing slowly.
The Derivative Function
You must provide a user-defined function to calculate derivatives corresponding to the equations you want 
to solve. All equations are solved as systems of first-order equations. Higher-order equations must be trans-
formed to multiple first-order equations (an example is shown later).
The derivative function has this form:
Function D(pw, xx, yw, dydx)
Wave pw
// parameter wave (input)
Variable xx
// x value at which to calculate derivatives
Wave yw
// wave containing y[i] (input)
Wave dydx
// wave to receive dy[i]/dx (output)
dydx[0] = <expression for one derivative>
dydx[1] = <expression for next derivative>
<etc.>
return 0
End
Note the return statement at the end of the function. The function result should normally be 0. If it is 1, Inte-
grateODE will stop. If the return statement is omitted, the function returns NaN which IntegrateODE treats 
the same as 0. But it is best to explicitly return 0.
Because the function may produce a large number of outputs, the outputs are returned via a wave in the 
parameter list.
The parameter wave is simply a wave containing possible adjustable constants. Using a wave for these makes 
it convenient to change the constants and try a new integration. It also will make it more convenient to do a 
curve fit to a differential equation. You must create the parameter wave before invoking IntegrateODE. The 
contents of the parameter wave are of no concern to IntegrateODE and are not touched. In fact, you can change 
the contents of the parameter wave inside your function and those changes will be permanent.
Other inputs are the value of x at which the derivatives are to be evaluated, and a wave (yw in this example) 
containing current values of the y[i]’s. The value of X is determined when it calls your function, and the 
waves yw and dydx are both created and passed to your function when Igor needs new values for the deriv-
atives. Both the input Y wave and the output dydx wave have as many elements as the number of derivative 
equations in your system of ODEs.
