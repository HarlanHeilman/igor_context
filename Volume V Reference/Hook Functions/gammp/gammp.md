# gammp

gammaNoise
V-289
Defined for x > 0, a  0 (upperTail = zero or absent) or a > 0 (upperTail = 0).
See Also
The gamma, gammp, and gammq functions.
gammaNoise 
gammaNoise(a [, b])
The gammaNoise function returns a pseudo-random value from the gamma distribution
whose mean is ab and variance is ab2. For backward compatibility you can omit the parameter b in which 
case its value is set to 1. When a1 gammaNoise reduces to expNoise.
The random number generator initializes using the system clock when Igor Pro starts. This almost guarantees 
that you will never repeat a sequence. For repeatable “random” numbers, use SetRandomSeed. The 
algorithm uses the Mersenne Twister random number generator.
References
Marsaglia, G., and W. W. Tsang, ACM, 26, 363-372, 2000.
See Also
The SetRandomSeed operation.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview.
gammln 
gammln(num [, accuracy])
The gammln function returns the natural log of the gamma function of num, where num > 0. If num is 
complex, it returns a complex result. Optionally, accuracy can be used to specify the desired fractional 
accuracy. If num is complex, it returns a complex result. In this case, accuracy is ignored.
Details
The accuracy parameter specifies the fractional accuracy that you desire. That is, if you set accuracy to 10-7, 
that means that you wish that the absolute value of (factual - freturned)/factual be less than 10-7.
For backward compatibility, if you don’t include accuracy, gammln uses older code that achieves an 
accuracy of about 2x10-10.
With accuracy, newer code is used that is both faster and more accurate. The output has fractional accuracy better 
than 1x10-15 except for values near zero, where the absolute accuracy (factual - freturned) is better than 2x10-16.
The speed of calculation depends only weakly on accuracy. Higher accuracy is significantly slower than 
lower accuracy only for num between 6 and about 10.
See Also
The gamma function.
gammp 
gammp(a, x [, accuracy])
The gammp function returns the regularized incomplete gamma function P(a,x), where a > 0, x  0. Optionally, 
accuracy can be used to specify the desired fractional accuracy. Same as gammaInc(a, x, 0)/gamma(a).
Details
The accuracy parameter specifies the fractional accuracy that you desire. That is, if you set accuracy to 10-7, 
that means that you wish that the absolute value of (factual - freturned)/factual be less than 10-7.
f (x) =
xa−1 exp −x
b
⎛
⎝⎜
⎞
⎠⎟
baΓ(a)
,
x > 0, a > 0, b > 0,
