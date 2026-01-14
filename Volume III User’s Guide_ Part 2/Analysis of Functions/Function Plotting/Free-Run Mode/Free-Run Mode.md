# Free-Run Mode

Chapter III-10 — Analysis of Functions
III-330
Free-Run Mode
Most of the examples shown so far use the Y wave’s X scaling to set the X values where a solution is desired. 
In the section A First-Order Equation on page III-325, examples are also shown in which the /X flag is used to 
specify the sequence of X values, either by setting X0 and deltaX or by supplying a wave filled with X values.
These methods have the advantage that you have complete control over the X values where the solution is 
reported to you. They also are completely deterministic — you know before running IntegrateODE exactly 
how many points will be calculated and how big your waves need to be.
They also have the potential drawback that you may force IntegrateODE to use smaller X increments than 
required. If your ODE system is expensive to calculate, this may exact a considerable cost in computation time.
IntegrateODE also offers a “free-run” mode in which the solution is allowed to proceed using whatever X 
increments are required to achieve the requested accuracy limit. This mode has two possible advantages — 
it will use the minimum number of solution steps required and it may also produce a higher density of 
points in areas where the solution changes rapidly (but watch out for stiff systems, see page III-331).
Free-run mode has the disadvantage that in certain cases the solution may require miniscule steps to tip toe 
through difficult terrain, inundating you with huge numbers of points that you don’t really need. You also 
don’t know ahead of time how many points will be required to cover a certain range in X.
To illustrate the use of free-run mode, we will return to the example used in the section A First-Order Equa-
tion on page III-325. (Make sure the FirstOrder function is compiled in the procedure window.) Because we 
don’t know how many points will be produced, we will make the waves large:
Make/D/O/N=1000 FreeRunY
// wave to receive results
FreeRunY = NaN
FreeRunY[0] = 10
// initial condition- y0=10
Free-run mode requires that you supply an X wave. Unlike the previous use of an X wave, in free-run mode 
the X wave is filled by IntegrateODE with the X values at which solution values have been calculated. Like 
the Y waves, you must provide an initial value in the first row of the X wave. As before, it must have the 
same number of rows as the Y waves:
Make/O/D/N=1000 FreeRunX
// same length as YY
FreeRunX = NaN
// prevent display of extra points
FreeRunX[0] = 0
// initial value of X
In free-run mode, only the points that are required are altered. Thus, if you have some preexisting wave 
contents, they will be seen on a graph. We prevent the resulting confusion by filling the X wave with NaN’s 
(Not a Number, or blanks). Igor graphs do not display points that have NaN values.
Make a graph:
Display FreeRunY vs FreeRunX
// make an XY graph
ModifyGraph mode=3, marker=19
// plot with dots to show the points
Make the parameter wave and set the value of the equation’s lone coefficient:
Make/D/O PP={0.05}
// set constant a to 0.05
10
5
0
-5
300
250
200
150
100
50
0
