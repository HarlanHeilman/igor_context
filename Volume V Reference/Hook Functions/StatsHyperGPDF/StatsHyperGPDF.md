# StatsHyperGPDF

StatsHyperGCDF
V-935
where 
and >0.
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsGEVCDF, StatsEValuePDF, StatsEValueCDF, StatsInvEValueCDF
StatsHyperGCDF 
StatsHyperGCDF(x, m, n, k)
The StatsHyperGCDF function returns the hypergeometric cumulative distribution function, which is the 
probability of getting x marked items when drawing (without replacement) k items out of a population of 
m items when n out of the m are marked.
Details
The hypergeometric distribution is
 
where 
 is the binomial function. All parameters must be positive integers and must have m>n and x<k; 
otherwise it returns NaN.
References
Klotz, J.H., Computational Approach to Statistics.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsHyperGPDF.
StatsHyperGPDF 
StatsHyperGPDF(x, m, n, k)
The StatsHyperGPDF function returns the hypergeometric probability distribution function, which is the 
probability of getting x marked items when drawing without replacement k items out of a population of m 
items where n out of the m are marked.
Details
The hypergeometric distribution is
f (x,μ,σ,ξ) = 1
σ 1+ ξ x −μ
σ
⎛
⎝⎜
⎞
⎠⎟
⎡
⎣⎢
⎤
⎦⎥
(−1/ξ)−1
exp −1+ ξ
x −μ
σ
⎛
⎝⎜
⎞
⎠⎟
−1/ξ
⎡
⎣
⎢
⎢
⎤
⎦
⎥
⎥
⎧
⎨⎪
⎩⎪
⎫
⎬⎪
⎭⎪
,
1+ ξ x −μ
σ
⎛
⎝⎜
⎞
⎠⎟> 0,
F(x;m,n,k) =
n
L



 
m  L
k  L



 
m
k



 
L=0
x

,
a
b


