# Terminology

Chapter III-10 — Analysis of Functions
III-322
Plotting a User-Defined Function
In the preceding example we used the built-in sin function in the right-hand expression. We can also use a user-
defined function. Here is an example using a very simple function — the normal probability distribution func-
tion.
Function NormalProb(x)
Variable x
// the constant is 1/sqrt(2*pi) evaluated in double-precision
return 0.398942280401433*exp(-(0.5*x^2))
End
Make/N=100 wave0; SetScale/I x, 0, 3, wave0; wave0 = NormalProb(x)
Display wave0
Note that, although we are using the NormalProb function to fill a wave, the NormalProb function itself has 
nothing to do with waves. It merely takes an input and returns a single output. We could also test the Nor-
malProb function at a single point by executing
Print NormalProb(0)
This would print the output of the function in the history area.
It is the act of using the NormalProb function in a wave assignment statement that fills the wave with data 
values. As it executes the wave assignment, Igor calls the NormalProb function over and over again, 100 
times in this case, passing it a different parameter each time and storing the output from the NormalProb 
function in successive points of the destination wave.
For more information on Wave Assignments, see Waveform Arithmetic and Assignments on page II-74. 
You may also find it helpful to read Chapter IV-1, Working with Commands.
WaveMetrics provides a procedure package that provides a convenient user interface to graph mathematical 
expressions. To use it, choose AnalysisPackagesFunction Grapher. This displays a graph with controls to 
create and display a function. Click the Help button in the graph to learn how to use it.
Solving Differential Equations
Numerical solutions to initial-value problems involving ordinary differential equations can be calculated using 
the IntegrateODE operation (see page V-452). You provide a user-defined function that implements a system of 
differential equations. The solution to your differential equations are calculated by marching the solution 
forward or backward from the initial conditions in a series of steps or increments in the independent variable.
Terminology
Referring to the independent variable and the dependent variables is very cumbersome, so we refer to these 
as X and Y[i]. Of course, X may represent distance or time or anything else.
A system of differential equations will be written in terms of derivatives of the Y[i]s, or dy[i]/dx.
0.4
0.3
0.2
0.1
3.0
2.5
2.0
1.5
1.0
0.5
0.0
