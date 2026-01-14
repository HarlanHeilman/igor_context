# csch

Cross
V-115
Cross
Cross [/DEST=destWave /FREE /T /Z] vectorA, vectorB [, vectorC]
The Cross operation computes the cross products vectorA x vectorB and vectorA x (vectorB x vectorC). Each 
vector is a 1D real wave containing 3 rows. Stores the result in the wave W_Cross in the current data folder.
Flags
csc 
csc(angle)
The csc function returns the cosecant of angle which is in radians. 
In complex expressions, angle is complex, and csc(angle) returns a complex value.
See Also
sin, cos, tan, sec, cot
csch
csch(x)
The csch function returns the hyperbolic cosecant of x. 
In complex expressions, x is complex, and csch(x) returns a complex value.
See Also
cosh, tanh, coth, sech
/DEST=destWave
Stores the cross product in the wave specified by destWave.
The destination wave is overwritten if it exists.
The destination wave must be different from the input waves.
The operation creates a wave reference for the destination wave if called in a user-
defined function. See Automatic Creation of WAVE References on page IV-72 
for details.
If you omit /DEST, the operation stores the result in the wave W_Cross in the 
current data folder.
Requires Igor7 or later.
/FREE
When used with /DEST, the destination wave is created as a free wave. See Free 
Waves on page IV-91 for details on free waves.
/FREE is allowed in user-defined functions only.
Requires Igor7 or later.
/T
Stores output in a row instead of a column in W_Cross.
/Z
Generates no errors for any unsuitable inputs.
csc(x) =
1
sin(x).
csch(x) =
1
sinh(x) =
2
ex −e−x .
