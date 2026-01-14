# StatsPowerCDF

StatsPoissonCDF
V-966
Examples
Function AllPermutations(num)
Variable num
Variable i,nf=factorial(num)
Make/O/N=(num) wave0=p+1,waveA,waveB=p
Print wave0
for(i=0;i<nf;i+=1)
waveA=wave0
if(statsPermute(waveA,waveB,1)==0)
break
endif
print waveA
endfor
end
Executing AllPermutations(3) prints:
 wave0[0]= {1,2,3}
 waveA[0]= {1,3,2}
 waveA[0]= {2,1,3}
 waveA[0]= {2,3,1}
 waveA[0]= {3,1,2}
 waveA[0]= {3,2,1}
See Also
Chapter III-12, Statistics for a function and operation overview.
StatsPoissonCDF 
StatsPoissonCDF(x, )
The StatsPoissonCDF function returns the Poisson cumulative distribution function
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsPoissonPDF and 
StatsInvPoissonCDF functions.
StatsPoissonPDF 
StatsPoissonPDF(x, )
The StatsPoissonPDF function returns the Poisson probability distribution function
where  is the shape parameter.
See Also
Chapter III-12, Statistics for a function and operation overview; the StatsPoissonCDF and 
StatsInvPoissonCDF functions.
StatsPowerCDF 
StatsPowerCDF(x, b, c)
The StatsPowerCDF function returns the Power Function cumulative distribution function
where the scale parameter b and the shape parameter c satisfy b,c > 0 and b x 0.
F(x;) =
exp 
(
)i
i!
i=0
x

,
x = 0,1,2...
f (x;) = exp 
(
) x
x!
,
x = 0,1,2...
F(x;b,c) =
x
b




c
