# LombPeriodogram

logNormalNoise
V-521
logNormalNoise 
logNormalNoise(m,s)
The logNormalNoise function returns a pseudo-random value from the lognormal distribution function 
whose probability distribution function is
with a mean 
and variance 
.
The random number generator initializes using the system clock when Igor Pro starts. This almost 
guarantees that you will never repeat a sequence. For repeatable “random” numbers, use SetRandomSeed. 
The algorithm uses the Mersenne Twister random number generator.
See Also
The SetRandomSeed operation.
Noise Functions on page III-390.
Chapter III-12, Statistics for a function and operation overview.
LombPeriodogram
LombPeriodogram [flags] srcTimeWave, srcAmpWave [, srcFreqWave ]
The LombPeriodogram is used in spectral analysis of signal amplitudes specified by srcAmpWave which are 
sampled at possibly random sampling times given by srcTimeWave. The only assumption about the 
sampling times is that they are ordered from small to large time values. The periodogram is calculated for 
either a set of frequencies specified by srcFreqWave (slow method) or by the flags /FR and /NF (fast method). 
Unless you specify otherwise, the results of the operation are stored by default in W_LombPeriodogram 
and W_LombProb in the current data folder.
Flags
/DESP=datafolderAndName
Saves the computed P-values in a wave specified by datafolderAndName. The 
destination wave will be created or overwritten if it already exists. dataFolderAndName 
can include a full or partial path with the wave name.
Creates by default a wave reference for the destination wave in a user function. See 
Automatic Creation of WAVE References on page IV-72 for details.
If this flag is not specified, the operation saves the P-values in the wave W_LombProb 
in the current data folder.
/DEST=datafolderAndName
Saves the computed periodogram in a wave specified by datafolderAndName. The 
destination wave will be created or overwritten if it already exists. datafolderAndName 
can include a full or partial path with the wave name 
(/DEST=root:bar:destWave).
Creates by default a wave reference for the destination wave in a user function. See 
Automatic Creation of WAVE References on page IV-72 for details.
If this wave is not specified the operation saves the resulting periodogram in the wave 
W_LombPeriodogram in the current data folder.
f (x,m,s) =
1
xs 2π
exp −ln(x) −m
[
]
2
2s2
⎧
⎨⎪
⎩⎪
⎫
⎬⎪
⎭⎪
,
exp m + 1
2 s2



 ,
exp 2m+ s2
(
) exp(s2) −1
⎡⎣
⎤⎦

LombPeriodogram
V-522
Details
The LombPeriodogram (sometimes referred to as "Lomb-Scargle" periodogram) is useful in detection of 
periodicities in data. The main advantage of this approach over Fourier analysis is that the data are not 
required to be sampled at equal intervals. For an input consisting of N points this benefit comes at a cost of 
an O(N^2) computations which becomes prohibitive for large data sets. The operation provides the option 
of computing the periodogram at equally spaced (output) frequencies using /FR and /NF or at completely 
arbitrary set of frequencies specified by srcFreqWave. It turns out that when you use equally spaced output 
frequencies the calculation is more efficient because certain parts of the calculation can be factored.
The Lomb periodogram is given by
Here yi is the ith point in srcAmpWave, ti is the corresponding point in srcTimeWave,
and
In the absence of a Nyquist limit, the number of independent frequencies that you can compute can be 
estimated using:
This expression was given by Horne and Baliunas derived from least square fitting. Nind is used to 
compute the P-values as:
/FR=fRes
Use /FR to specify the frequency resolution of the output. This flag is used together 
with /NF to specify the range of frequencies for which the periodogram is computed. 
Note that fRes is also the lowest frequency in the output.
/NF=numFreq
Use /NF to specify the number of frequencies at which the periodogram is computed. 
The range of frequencies of the periodogram is then [fRes, (numFreq-1)*fRes].
/Q
Quiet mode; suppresses printing results in the history area.
/Z
Do not report any errors.
LP() =
1
2 2
yi  y
(
)cos  ti  
(
)

 
i=0
N 1




 
2
cos2  ti  
(
)

 
i=0
N 1

+
yi  y
(
)sin  ti  
(
)

 
i=0
N 1




 
2
sin2  ti  
(
)

 
i=0
N 1













y = 1
N
yi
i=0
N 1

,
tan(2) =
sin(2ti )
i=0
N 1

cos(2ti )
i=0
N 1

.
p = 1 1 exp LP(w)
[
]
{
}
Nind .
Nind = 6.362 +1.193N + 0.00098N 2.
