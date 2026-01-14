# References

Chapter III-10 — Analysis of Functions
III-349
References
The IntegrateODE operation is based on routines in Numerical Recipes, and are used by permission:
Press, W.H., B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling, Numerical Recipes in C, 2nd ed., 994 pp., 
Cambridge University Press, New York, 1992.
The Adams-Moulton and BDF methods are based on the CVODE package developed at Lawrence Liver-
more National Laboratory:
Cohen, Scott D., and Alan C. Hindmarsh, CVODE User Guide, LLNL Report UCRL-MA-118618, September 1994.
The CVODE package was derived in part from the VODE package. The parts used in Igor are described in 
this paper:
Brown, P.N., G. D. Byrne, and A. C. Hindmarsh, VODE, a Variable-Coefficient ODE Solver, SIAM J. Sci. Stat. 
Comput., 10, 1038-1051, 1989.
The Optimize operation uses Brent’s method for univariate functions. Numerical Recipes has an excellent dis-
cussion in section 10.2 of this method (but we didn’t use their code).
For multivariate functions Optimize uses code based on Dennis and Schnabel. To truly understand what 
Optimize does, read their book:
Dennis, J. E., Jr., and Robert B. Schnabel, Numerical Methods for Unconstrained Optimization and Nonlinear 
Methods, 378 pp., Society for Industrial and Applied Mathematics, Philadelphia, 1996.
The FindRoots operation uses the Jenkins-Traub algorithm for finding roots of polynomials:
Jenkins, M.A., “Algorithm 493, Zeros of a Real Polynomial”, ACM Transactions on Mathematical Software, 1, 
178-189, 1975..

Chapter III-10 — Analysis of Functions
III-350
