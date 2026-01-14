# LambertW

laguerreA
V-475
laguerreA 
laguerreA(n, k, x)
The laguerreA function returns the associated Laguerre polynomial of degree n (positive integer), index k 
(non-negative integer) and argument x. The associated Laguerre polynomials are defined by
where 
 is the Laguerre polynomial.
See Also
The laguerre and laguerreGauss functions.
References
Arfken, G., Mathematical Methods for Physicists, Academic Press, New York, 1985.
laguerreGauss 
laguerreGauss(p, m, r)
The laguerreGauss function returns the normalized product of the associated Laguerre polynomials and a 
Gaussian. This function is typically encountered in solutions to physical problems where it represents the radial 
solution with an additional factor exp(i*m*) which is not included in this case. The LaguerreGauss is given by
See Also
The laguerre, laguerreA, and hermiteGauss functions.
LambertW
LambertW(z, branch)
The LambertW function returns the complex value of Lambert's W function for complex z and integer index 
branch. The function can be defined through its inverse,
Since w is multivalued, the branch parameter is used to differentiate between solutions for the equation.
The LambertW function was added in Igor Pro 7.00.
Details
IGOR's LambertW uses complex input and output. You can use LambertW in real expressions but you must 
make sure that you are not calling the function in a range where its imaginary part is non-zero.
The average accuracy of the function defined by cabs(z-w*exp(w)) in the region |real(z)|<10, |imag(z)|<10 
is 5e-14. In general the accuracy decreases with increasing |branch| and with increasing distance from the 
origin in the z-plane.
IGOR uses a hybrid algorithm to compute the function which requires longer computation times in the 
presence of numerical instabilities.
References
R.M. Corless, G.H. Gonnet, D.E.G. Hare, D.J. Jeffrey and D.E. Knuth, "On Lambert W Function", Advances 
in Computational Mathematics 5: 329­359
Ln
k (x) = (−1)k d k
dxk Ln+k(x)
[
],
Ln+k(x)
U pm(r) =
2p!
π(m + p)! r 2
(
)
m
Lp
m 2r2
(
)exp −r2
(
).
z = wew .
