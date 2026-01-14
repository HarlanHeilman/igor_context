# StatsDIPTest

StatsDExpCDF
V-926
StatsDExpCDF 
StatsDExpCDF(x, m, s)
The StatsDExpCDF function returns the double-exponential cumulative distribution function
for >0. It returns NaN when =0.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsDExpPDF and StatsInvDExpCDF.
StatsDExpPDF 
StatsDExpPdf(x, m, s)
The StatsDExpPdf function returns the double-exponential probability distribution function
where  is the location parameter and >0 is the scale parameter. Use =0 and =1 for the standard form of 
the double exponential distribution. It returns NaN when =0.
See Also
Chapter III-12, Statistics for a function and operation overview; StatsDExpCDF and StatsInvDExpCDF.
StatsDIPTest 
StatsDIPTest [/Z] srcWave
The StatsDIPTest operation performs Hartigan test for unimodality.
Flags
Details
The input to the operation srcWave is any real numeric wave. Outputs are: V_Value contains the dip 
statistic; V_min is the lower end of the modal interval; and V_max is the higher end of the modal interval. 
Percentage points or critical values for the dip statistic can be obtained from simulations using an identical 
sample size as in this example:
Function getCriticalValue(sampleSize,alpha)
Variable sampleSize,alpha
Make/O/N=(sampleSize) dataWave
Make/O/N=100000 dipResults
Variable i
for(i=0;i<100000;i+=1)
dataWave=enoise(100)
StatsDipTest dataWave
dipResults[i]=V_Value
endfor
Histogram/P/B=4 dipResults
// Compute the PDF.
Wave W_Histogram
Integrate/METH=1 W_Histogram/D=W_INT
// Compute the CDF.
Findlevel/Q W_int,(1-alpha)
// Find the critical value.
return V_LevelX
End
/Z
Ignores errors. V_flag will be set to -1 for any error and to zero otherwise.
F(x;μ,) =
exp x  μ





whenx < μ
1 1
2 exp  x  μ





whenx  μ







f(x;μ,)= 1
2 exp  x  μ


 

 ,
