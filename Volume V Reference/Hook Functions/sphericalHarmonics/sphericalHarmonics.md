# sphericalHarmonics

sphericalBessYD
V-898
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The sphericalBessYD and sphericalBessJ functions.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
sphericalBessYD 
sphericalBessYD(n, x [, accuracy])
The sphericalBessYD function returns the derivative of the spherical Bessel function of the second kind and 
order n.
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The sphericalBessJ and sphericalBessY functions.
sphericalHarmonics 
sphericalHarmonics(L, M, q, f)
The sphericalHarmonics function returns the complex-valued spherical harmonics
where 
 is the associated Legendre function.
See Also
The legendreA function. The NumericalIntegrationDemo.pxp experiment.
Demos
Choose FileExample ExperimentsVisualizationSphericalHarmonicsDemo.
Choose FileExample ExperimentsAnalysisNumericalIntegrationDemo.
References
Arfken, G., Mathematical Methods for Physicists, Academic Press, New York, 1985.
y0(x) = −cos(x)
x
y1(x) = −cos(x)
x2
−sin(x)
x
y2(x) =
1
x −3
x3
⎛
⎝⎜
⎞
⎠⎟cos(x)−3
x2 sin(x).
YL
M 
( , )
1
–

M 2L
1
+
4
--------------- L
M
–

!
L
M
+

!
-------------------- PL
M

cos

eiM
=
YL
M θ,φ
(
) = (−1)M
2L +1
4π
(L −M )!
(L + M )!PL
M cos(θ)
(
)eiMφ,
PL
M

cos


PL
M cos(θ)
(
)
