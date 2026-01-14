# ODE Outputs

Chapter III-10 — Analysis of Functions
III-323
ODE Inputs
You provide to IntegrateODE a function to calculate the derivatives or right-hand-sides of your system of 
differential equations.
You also provide one output wave for each equation in the system to receive the solution. The solution 
waves will have a row for each output point you want.
You specify the independent variable either by setting the X scaling of the output waves, by specifying x0 
and deltax using the /X={x0,deltax} flag, or by providing an explicit X wave using the /X=xWave flag.
For a system of four equations (fourth-order system), if you provide an X wave to specify where you want 
values, you might have this situation:
Instead of multiple 1D output waves, you can provide a single 2D output wave:
Igor calculates a solution value for each element of the Y (output) waves.
Before executing IntegrateODE, you must load the initial conditions (the initial Y[i] values) into the first row 
of the Y waves. Igor then calculates the solution starting from those values. The first solution value is stored 
in the second element of the Y waves.
If you use the /R flag with IntegrateODE to start the integration at a point other than the beginning of the Y 
wave, the initial conditions must be in the first row specified by the /R flag. See Stopping and Restarting 
IntegrateODE on page III-334.
ODE Outputs
The algorithms Igor uses to integrate your ODE systems use adaptive step-size control. That is, the algorithms 
advance the solution by the largest increment in X that result in errors at least as small as you require. If the 
solution is changing rapidly, or the solution has some other difficulty, the step sizes may get very small.
X wave, four Y waves (A, B, C, and D).
First row contains initial conditions.
Subsequent rows receive solution values.
X wave specifies where to report solutions.
In free-run mode, X wave receives X values for solution rows.
