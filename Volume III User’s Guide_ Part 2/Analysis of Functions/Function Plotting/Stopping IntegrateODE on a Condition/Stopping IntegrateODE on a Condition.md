# Stopping IntegrateODE on a Condition

Chapter III-10 — Analysis of Functions
III-335
The calculation has been done for points 0-300. Note the comma in /R=[,300], which sets 300 as the end point, 
not the start point. Now you can restart at 300 and continue to the 400th point:
IntegrateODE/M=1/R=[300,400] Harmonic, HarmPW, HarmonicOsc
or finish the entire 500 points. Perhaps you need to start from an earlier point:
IntegrateODE/M=1/R=[350] Harmonic, HarmPW, HarmonicOsc
 
Stopping IntegrateODE on a Condition
Sometimes it is useful to be able to stop the calculation based on output values from the integration, rather 
than stopping when a certain value of the independent variable is reached. For instance, a common way to 
simulate a neuron firing is to solve the relevant system of equations until the output reaches a certain value. 
At that point, the solution should be stopped and the initial conditions reset to values appropriate to the 
triggered condition. Then the calculation can be re-started from that point.
The ability to stop and re-start the calculation is a general solution to the problem of discontinuities in the 
system you are solving. Integrate the system up to the point of the discontinuity, stop and re-start using a 
derivative function that reflects the system after the discontinuity.
There are two ways to stop the integration depending on the solution values.
The first way is to use the /STOP={stopWave, mode} flag, supplying a stopWave containing stopping condi-
tions. StopWave must have one column for each equation in your system. Each column can specify stopping 
10
5
0
-5
500
400
300
200
100
0
10
5
0
-5
500
400
300
200
100
0
10
5
0
-5
500
400
300
200
100
0
