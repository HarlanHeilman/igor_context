# Extreme Points of a 1D Nonlinear Function

Chapter III-10 — Analysis of Functions
III-344
Here we discuss how the operation works, and give some examples. The discussion falls naturally into two 
sections:
•
Extrema of 1D nonlinear functions
•
Extrema of multidimensional nonlinear functions
A related problem is to find peaks or troughs in a curve defined by data points. In this case, you don’t have 
an analytical expression of the function. To do this with one dimensional data, use the FindPeak operation 
(see page V-247).
Extreme Points of a 1D Nonlinear Function
The Optimize operation finds local maxima or minima of functions. That is, if a function has some X value 
where the nearby Y values are all higher than at that X value, it is deemed to be a minimum. Finding the 
point where a functions value is lower or higher than any other point anywhere is a much more difficult 
problem that is not addressed by the Optimize operation.
You must write a user-defined function to define the function for which the extreme points are calculated. 
Igor will call your function with values of X in the process of searching for a root. The format of the function 
is as follows:
Function myFunc(w,x)
Wave w
Variable x
return f(x)
// an expression...
End
The wave w is a coefficient wave — it specifies constant coefficients that you may need to include in the func-
tion. It provides a convenient way to alter the coefficients so that you can find extreme points of members of 
a function family without having to edit your function code every time. Igor does not alter the values in w.
Although the coefficient wave must be present in the Function declaration, it does not have to be referenced 
in the function body. This may save computation time, arriving at the solution faster. You will have to create 
a dummy wave to list in the FindRoots command.
As an example we will find extreme points of the equation
y = a+b*sinc(c*(x-x0))
A suitable user-defined function might look like this:
Function mySinc(w, x)
Wave w
Variable x
return w[0]+w[1]*sinc(w[2]*(x-w[3]))
End
Enter this code into the Procedure window and then close the window.
Make a graph of the function:
Make/D/O SincCoefs={0, 1, 2, .5} // a sinc function offset by 0.5
Make/D/O SincWave
// a wave with 128 points
SetScale/I x -10,10,SincWave
// give it an X range of [-10, 10]
SincWave = mySinc(SincCoefs, x)
// fill it with function values
Display SincWave
// and make a graph of it
ModifyGraph minor(bottom)=1
// add minor ticks to the graph

Chapter III-10 — Analysis of Functions
III-345
Now we’re ready to find extreme points.
The algorithm for finding extreme points requires that the extreme points first be bracketed, that is, you 
need to know two X values that are on either side of the extreme point (that is, two points that have a lower 
or higher point between). Making a graph of the function as we did here is a good way to figure out brack-
eting values. For instance, inspection of the graph above shows that there is a minimum between x=1 and 
x=4. The Optimize command line to find a minimum in this range is
Optimize/L=1/H=4 mySinc, SincCoefs
The /L flag sets the lower bracket and the /H flag sets the upper bracket. Igor then finds the minimum 
between these values, and prints the results in the history:
Optimize probably found a minimum. Optimize stopped because
the Optimize operation found a minimum within the specified tolerance.
Current best solution: 2.7467
Function value at solution: -0.217234
 13 iterations, 14 function calls
V_minloc = 2.7467, V_min = -0.217234, V_OptNumIters = 13, V_OptNumFunctionCalls = 14
Igor reports to you both the X value that minimizes the function (in this case 2.7467) and the Y value at the 
minimum.
The bracketing values don’t necessarily have to bracket the solution. Igor first tries to find the desired extre-
mum between the bracketing values. If it fails, the bracketing interval is expanded searching for a suitable 
bracketing interval. If you don’t use /L and /H, Igor sets the bracketing interval to [0,1]. In the case of the 
mySinc function, that doesn’t include a minimum. Here is what happens in that case:
Optimize mySinc, SincCoefs
Optimize probably found a minimum. Optimize stopped because
the Optimize operation found a minimum within the specified tolerance.
Current best solution: 2.74671
Function value at solution: -0.217234
 16 iterations, 47 function calls
V_minloc = 2.74671, V_min = -0.217234, V_OptNumIters = 16, V_OptNumFunctionCalls = 47
Note that Igor found the same minimum that it found before.
The mySinc function makes it easy to find bracketing values because of the oscillatory nature of the func-
tion. Other functions may be more difficult if they contain just one extreme point, or if they have local 
extreme points but are unbounded elsewhere. Even in an easy case like mySinc, you can’t be sure which 
extreme point Igor will find, so it is always better to supply a good bracket if you possibly can.
You may wish to find maximum points instead of minima. Use the /A flag to specify this:
Optimize/A/L=0/H=2 mySinc, SincCoefs
Optimize probably found a maximum. Optimize stopped because
the Optimize operation found a maximum within the specified tolerance.
Current best solution: 0.499999
Function value at solution: 1
 16 iterations, 17 function calls
V_maxloc = 0.499999, V_max = 1, V_OptNumIters = 16, V_OptNumFunctionCalls = 17
1.0
0.8
0.6
0.4
0.2
0.0
-0.2
-10
-5
0
5
10
