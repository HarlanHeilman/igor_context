# StatsTriangularPDF

StatsTopDownCDF
V-980
StatsTopDownCDF 
StatsTopDownCDF(r, N)
The StatsTopDownCDF function returns the cumulative distribution function for the top-down correlation 
coefficient. It is computationally intensive because it must evaluate many permutations [O((n!)2)]. It exactly 
calculates the distribution for 3 N 7; outside this range it uses Monte-Carlo estimation for 8 N 50 and 
asymptotic Normal approximation for N>50. The Monte-Carlo estimate uses 1e6 random permutations 
fitted with two 9-order polynomials for the range [-1,0] and [0,1]. The results are within 0.2% of exact values 
where known.
References
Iman, R.L., and W.J. Conover, A measure of top-down correlation, Technometrics, 29, 351-357, 1987.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsRankCorrelationTest and 
StatsInvTopDownCDF functions.
StatsTriangularCDF 
StatsTriangularCDF(x, a, b, c)
The StatsTriangularCDF function returns the triangular cumulative distribution function
where a<c<b.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsTriangularPDF and 
StatsInvTriangularCDF functions.
StatsTriangularPDF 
StatsTriangularPDF(x, a, b, c)
The StatsTriangularPDF function returns the triangular probability distribution function
where a<c<b.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsTriangularCDF and 
StatsInvTriangularCDF functions.
F(x;a,b,c) =
0
x ≤a
(x −a)2
(b−a)(c −a)
a < x ≤c
1−
(b−x)2
(b−a)(b−c)
c < x < b
1
x ≥b
⎧
⎨
⎪
⎪
⎪⎪
⎩
⎪
⎪
⎪
⎪
f (x;a,b,c) =
2(x −a)
(b−a)(c −a)
a ≤x < c
2(b−x)
(b−a)(b−c)
c < x ≤b
0
Otherwise
⎧
⎨
⎪
⎪
⎪⎪
⎩
⎪
⎪
⎪
⎪
