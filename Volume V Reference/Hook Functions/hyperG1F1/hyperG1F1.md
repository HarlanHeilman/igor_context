# hyperG1F1

hyperG0F1
V-353
The Histogram operation is not multidimensional aware. See Analysis on Multidimensional Waves on 
page II-95 for details. In fact, the Histogram operation can be usefully applied to multidimensional waves, 
such as those that represent images. The /R flag will not work as expected, however.
Examples
// Create histogram of two sets of data.
Make/N=1000 data1=gnoise(1), data2=gnoise(1)
Make/N=1 histResult
// Sets bins, does histogram.
Histogram/B={-5,1,10} data1, histResult
Display histResult; ModifyGraph mode=5
// Accumulates into existing bins.
Histogram/A data2, histResult
See Also
Histograms on page III-125, ImageHistogram, JointHistogram, TextHistogram
References
Sturges, H.A., The choice of a class-interval, J. Amer. Statist. Assoc., 21, 65-66, 1926.
Scott, D., On optimal and data-based histograms, Biometrika, 66, 605-610, 1979.
hyperG0F1 
hyperG0F1(b, z)
The hyperG0F1 function returns the confluent hypergeometric limit function
where 
 is the Pochhammer symbol
The series evaluation may be computationally intensive. You can abort the computation by pressing the 
User Abort Key Combinations.
See Also
The hyperG1F1, hyperG2F1, and hyperGPFQ functions.
References
The PFQ algorithm was developed by Warren F. Perger, Atul Bhalla, and Mark Nardin.
hyperG1F1 
hyperG1F1(a, b, z)
The hyperG1F1 function returns the confluent hypergeometric function 
where 
 is the Pochhammer symbol
The series evaluation may be computationally intensive. You can abort the computation by pressing the 
User Abort Key Combinations.
0 F1(b;z) =
zi
i!(b)i
,
i=0
∞
∑
(b)i
(b)i = b(b+1)...(b+ i −1).
1F1(a,b,z) =
(a)nzn
(b)nn!,
n=0
∞
∑
a
n
(a)n = a(a +1)…(a + n −1).
