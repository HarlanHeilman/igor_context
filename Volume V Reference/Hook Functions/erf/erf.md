# erf

erf
V-197
If you use the selectors for wave data, wave scaling, dimension units, dimension labels or dimension sizes, 
EqualWaves will return zero if the waves have unequal dimension sizes. The other selectors do not require 
equal dimension sizes.
Details
If you are testing for equality of wave data and if the tolerance is specified, it must be a positive number. The 
function returns 1 for equality if the data satisfies:
If tolerance is not specified, it defaults to 10-8.
If tolerance is set to zero and selector is set to 1 then the data in the two waves undergo a binary comparison 
(byte-by-byte).
If tolerance is non-zero then the presence of NaNs at a given point in both waves does not contribute to the 
sum shown in the equation above when both waves contain NaNs at the same point. A NaN entry that is 
present in only one of the waves is sufficient to flag inequality. Similarly, INF entries are excluded from the 
tolerance calculation when they appear in both waves at the same position and have the same signs.
If you are comparing wave data (selector =1) and both waves contain zero points, the function returns 1.
The EqualWaves() function comparison of all text fields is case-sensitive.
See Also
The MatrixOp operation equal keyword.
erf 
erf(num [, accuracy])
The erf function returns the error function of num.
selector
Field Compared
1
Wave data
2
Wave data type
4
Wave scaling
8
Data units
16
Dimension units
32
Dimension labels
64
Wave note
128
Wave lock state
256
Data full scale
512
Dimension sizes
waveA[i]−waveB[i]
(
)
2
i∑
< tolerance.
erf (x) = 2
π
e−t2 dt.
0
x
∫
