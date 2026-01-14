# Constraint Matrix and Vector

Chapter III-8 — Curve Fitting
III-230
The output from a curve fit with constraints includes these lines reporting on the fact that constraints were 
used, and that the constraint was active in the solution:
 --Curve fit with constraints--
Active Constraint: Desired: K1+K3<5 Achieved: K1+K3=5
In most cases you will see a message similar to this one. If you have conflicting constraints, it is likely that 
one or more constraints will be violated. In that case, you will get a report of that fact. The following com-
mands add two more constraints to the example. The new constraints require values for the individual 
amplitudes that sum to a number greater than 5, while still requiring that the sum be less than 5 (so these 
are “infeasible constraints”):
Make/O/T CTextWave={"K1 + K3 < 5", "K1 > 3.3", "K3 > 2.2"}
CurveFit dblExp expData /D/R/C=CTextWave
In most cases, you would have added the new constraints by editing the constraint wave 
in a table.
The curve fit report shows that all three constraints were violated to achieve a solution:
--Curve fit with constraints--
Constraint VIOLATED:
Desired:
K1>3.3
Achieved:
K1=3.06604
Constraint VIOLATED:
Desired:
K3>2.2
Achieved:
K3=1.93381
Constraint Matrix and Vector
When you do a constrained fit, it parses the constraint expressions and builds a matrix and a vector that 
describe the constraints.
Each constraint expression is parsed to form a simple expression like 
, where the Ki’s 
are the fit coefficients, and the Ci’s and D are constants. The constraints can be expressed as the matrix oper-
5
4
3
2
1
40
30
20
10
0
0.10
-0.10
Standard Curve Fit
5
4
3
2
1
40
30
20
10
0
-0.2
0.0
0.2
Curve Fit with Constraints
C0K0
C1K1

D

+
+
