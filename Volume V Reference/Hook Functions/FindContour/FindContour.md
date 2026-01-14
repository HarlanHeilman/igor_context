# FindContour

FindContour
V-239
// Graph the unfiltered and filtered impulse time responses
Display/L=leftImpulse impulse as "IIR Filtered Impulse"
AppendToGraph/L=leftFiltered impulseFiltered
ModifyGraph axisEnab(leftImpulse)={0,0.45}, axisEnab(leftFiltered)={0.55,1}
ModifyGraph freePos=0, margin(left)=50
ModifyGraph mode(impulse)=1, rgb(impulseFiltered)=(0,0,65535)
SetAxis bottom -0.00005,0.001
Legend
// Listen to the sounds
PlaySound sound
// This has a very high frequency tone
PlaySound soundFiltered
// This doesn't
References
Embree, P.M., and B. Kimble, C Language Algorithms for Signal Processing, 456 pp., Prentice Hall, Englewood 
Cliffs, New Jersey, 1991.
Lynn, P.A., and W. Fuerst, Introductory Digital Signal Processing with Computer Applications, 479 pp., Prentice 
Hall, Englewood Cliffs, New Jersey, 1998.
Oppenheim, A.V., and R.W. Schafer, Digital Signal Processing, 585 pp., Prentice Hall, Englewood Cliffs, New 
Jersey, 1975.
Terrell, T.J., Introduction to Digital Filters, 2nd ed., 261 pp., John Wiley & Sons, New York, 1988.
See Also
Smoothing on page III-292; the FFT and FilterFIR operations.
FindContour
FindContour [flags] matrixWave, level
The FindContour operation creates an XY pair of waves representing the locus of the solution to 
matrixWave=level .
The FindContour operation was added in Igor Pro 7.00.
-300
-200
-100
0
dB
20
15
10
5
0
kHz
500
400
300
200
100
0
deg
120
80
40
0
dB
20
15
10
5
0
kHz
 impulseMag
 impulsePhase
 soundMag
 soundFilteredMag
1.0
0.8
0.6
0.4
0.2
0.0
1.0
0.8
0.6
0.4
0.2
0.0
ms
0.20
0.10
0.00
 impulse
 impulseFiltered
