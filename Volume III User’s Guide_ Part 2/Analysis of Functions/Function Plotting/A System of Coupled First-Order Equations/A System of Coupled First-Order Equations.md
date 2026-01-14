# A System of Coupled First-Order Equations

Chapter III-10 — Analysis of Functions
III-327
Note that throughout these examples the initial value of YY has remained at 10.
A System of Coupled First-Order Equations
While many interesting systems are described by simple (possibly nonlinear) first-order equations, more 
interesting behavior results from systems of coupled equations.
The next example comes from chemical kinetics. Suppose you mix two substances A and B together in a 
solution and they react to form intermediate phase C. Over time C transforms into final product D:
Here, k1, k2, and k3 are rate constants for the reactions. The concentrations of the substances might be given 
by the following coupled differential equations:
To solve these equations, first we need a derivative function:
Function ChemKinetic(pw, tt, yw, dydt)
Wave pw
// pw[0] = k1, pw[1] = k2, pw[2] = k3
Variable tt
// time value at which to calculate derivatives
Wave yw
// yw[0]-yw[3] containing concentrations of A,B,C,D
Wave dydt
// wave to receive dA/dt, dB/dt etc. (output)
dydt[0] = -pw[0]*yw[0]*yw[1] + pw[1]*yw[2]
dydt[1] = dydt[0] // first two equations are the same
dydt[2] = pw[0]*yw[0]*yw[1] - pw[1]*yw[2] - pw[2]*yw[2]
dydt[3] = pw[2]*yw[2]
return 0
End
We think that it is easiest to keep track of the results using a single multicolumn Y wave. These commands make 
a four-column Y wave and use dimension labels to keep track of which column corresponds to which substance:
Make/D/O/N=(100,4) ChemKin
SetScale/P x 0,10,ChemKin
// calculate concentrations every 10 s
SetDimLabel 1,0,A,ChemKin
// set dimension labels to substance names
SetDimLabel 1,1,B,ChemKin
// this can be done in a table if you make
SetDimLabel 1,2,C,ChemKin
// the table using edit ChemKin.ld
SetDimLabel 1,3,D,ChemKin
ChemKin[0][%A] = 1
// initial conditions: concentration of A
ChemKin[0][%B] = 1
// and B is 1, C and D is 0
ChemKin[0][%C] = 0
// note indexing using dimension labels
ChemKin[0][%D] = 0
Make/D/O KK={0.002,0.0001,0.004}
// rate constants
10
8
6
4
2
0
140
120
100
80
60
40
20
 
  
 
  
 





   


    


  
