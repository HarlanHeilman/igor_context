# erfcw

erfc
V-198
Optionally, accuracy can be used to specify the desired fractional accuracy.
In complex expressions the error function is
where
is the confluent hypergeometric function of the first kind HyperG1F1. In this case the accuracy parameter 
is ignored.
Details
The accuracy parameter specifies the fractional accuracy that you desire. That is, if you set accuracy to 10-7, 
that means that you wish that the absolute value of (factual - freturned)/factual be less than 10-7.
For backwards compatibility, in the absence of accuracy an alternate calculation method is used that 
achieves fractional accuracy better than about 2x10-7.
If accuracy is present, erf can achieve fractional accuracy better than 8x10-16 for num as small as 10-3. For 
smaller num fractional accuracy is better than 5x10-15.
Higher accuracy takes somewhat longer to calculate. With accuracy set to 10-16 erfc takes about 50% more 
time than with accuracy set to 10-7.
See Also
The erfc, erfcw, dawson, inverseErf, and inverseErfc functions.
erfc 
erfc(num [, accuracy])
The erfc function returns the complementary error function of num (erfc(x) = 1 - erf(x)). Optionally, accuracy 
can be used to specify the desired fractional accuracy.
In complex expressions the complementary error function is
 where 
is the confluent hypergeometric function of the first kind HyperG1F1. In this case the accuracy parameter 
is ignored.
Details
The accuracy parameter specifies the fractional accuracy that you desire. That is, if you set accuracy to 10-7, 
that means that you wish that the absolute value of (factual - freturned)/factual be less than 10-7.
For backwards compatibility, in the absence of accuracy an alternate calculation method is used that 
achieves fractional accuracy better than 2x10-7.
If accuracy is present, erfc can achieve fractional accuracy better than 2x10-16 for num up to 1. From num = 1 
to 10 fractional accuracy is better than 2x10-15.
Higher accuracy takes somewhat longer to calculate. With accuracy set to 10-16 erfc takes about 50% more 
time than with accuracy set to 10-7.
See Also
erf, erfcw, erfcx, inverseErfc, dawson
erfcw
erfcw(z)
The erfcw is a complex form of the error function defined by
erf (z) = 2z
π
1F1
1
2; 3
2;−z2
⎛
⎝⎜
⎞
⎠⎟,
1F1
1
2; 3
2;−z2
⎛
⎝⎜
⎞
⎠⎟
erfc z
1
erfc z
–
1
2z

------ F
1 1
1
2-- 3
2--
z2
–,
( ,
)
–
=
=
F
1 1
1
2-- 3
2--
z2
–,
( ,
)
