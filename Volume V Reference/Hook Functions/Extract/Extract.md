# Extract

ExpIntegralE1
V-213
ExpIntegralE1
ExpIntegralE1(z)
The ExpIntegralE1(z) function returns the exponential integral of z.
If z is real, a real value is returned. If z is complex then a complex value is returned.
The ExpIntegralE1 function was added in Igor Pro 7.00.
Details
The exponential integral is defined by
References
Abramowitz, M., and I.A. Stegun, "Handbook of Mathematical Functions", Dover, New York, 1972. Chapter 
5.
See Also
expInt, CosIntegral, SinIntegral, hyperGPFQ
expNoise 
expNoise(b)
The expNoise function returns a pseudo-random value from an exponential distribution whose average 
and standard deviation are b and the probability distribution function is
.
The random number generator initializes using the system clock when Igor Pro starts. This almost 
guarantees that you will never repeat a sequence. For repeatable “random” numbers, use SetRandomSeed. 
The algorithm uses the Mersenne Twister random number generator.
See Also
The SetRandomSeed operation.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview.
ExportGizmo 
ExportGizmo [flags] keyword [=value]
The ExportGizmo operation is obsolete but is still partially supported for partial backward compatibility.
You can export Gizmo graphics using FileSave Graphics which generates a SavePICT command. The 
ExportGizmo operation is only partially supported. It can export to the clipboard or to an Igor wave and it 
can print but it can no longer export to a file. Use SavePICT instead.
Documentation for the ExportGizmo operation is available in the Igor online help files only. In Igor, 
execute:
DisplayHelpTopic "ExportGizmo"
Extract 
Extract [type flags][/INDX/O] srcWave, destWave, LogicalExpression
The Extract operation finds data in srcWave wherever LogicalExpression evaluates to TRUE and stores the 
matching data sequentially in destWave, which will be created if it does not already exist.
Parameters
srcWave is the name of a wave.
destWave is the name of a new or existing wave that will contain the result.
E1(z) =
e−t
t dt,
z
∞
∫
 arg(z) < π
(
).
f x

1
b--
x
b--
–




exp
=
