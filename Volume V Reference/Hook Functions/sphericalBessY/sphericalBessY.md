# sphericalBessY

sphericalBessJ
V-897
where <user> is the name of the current user and “X” is the major version number..
Example
For an example using SpecialDirPath, see Saving Package Preferences on page IV-251.
sphericalBessJ 
sphericalBessJ(n, x [, accuracy])
The sphericalBessJ function returns the spherical Bessel function of the first kind and order n.
For example:
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The sphericalBessJD and sphericalBessY functions.
References
Abramowitz, M., and I.A. Stegun, Handbook of Mathematical Functions, 446 pp., Dover, New York, 1972.
sphericalBessJD 
sphericalBessJD(n, x [, accuracy])
The sphericalBessJD function returns the derivative of the spherical Bessel function of the first kind and 
order n.
Details
See the bessI function for details on accuracy and speed of execution.
See Also
The sphericalBessJ and sphericalBessY functions.
sphericalBessY 
sphericalBessY(n, x [, accuracy])
The sphericalBessY function returns the spherical Bessel function of the second kind and order n.
Windows
C:Documents and Settings:<user>:Application Data:WaveMetrics:Igor Pro X:Packages:
jn(x) =
π
2x Jn+1/2(x).
j0(x) = sin(x)
x
j1(x) = sin(x)
x2
−cos(x)
x
j2(x) =
3
x3 −1
x
⎛
⎝⎜
⎞
⎠⎟sin(x)−3
x2 cos(x).
yn(x) =
π
2xYn+1/2(x).
