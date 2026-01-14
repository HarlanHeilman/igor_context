# Custom Smoothing Coefficients

Chapter III-9 — Signal Processing
III-298
SetScale/I x, V_Min, V_max, "", fittedNOx
Loess/CONF={0.99,cp,cm}/DEST=fittedNOx/DFCT/SMTH=(2/3) srcWave=NOx,factors={EquivRatio}
// Display the fit (smoothed results) and confidence intervals
AppendtoGraph fittedNOx, cp,cm
ModifyGraph rgb(fittedNOx)=(0,0,65535)
ModifyGraph mode(fittedNOx)=2,lsize(fittedNOx)=2
Legend
Loess is memory intensive, especially when generating confidence intervals. Read the Memory Details 
section of the Loess operation (see page V-515) if you use confidence intervals.
Custom Smoothing Coefficients
You can smooth data with your own set of smoothing coefficients by selecting the Custom Coefs algorithm. 
Use this option when you have low-pass filter (smoothing) coefficients created by another program or by 
the Igor Filter Design Laboratory.
Choose the wave that contains your coefficients from the pop-up menu that appears. Igor will convolve 
these coefficients with the input wave using the FilterFIR operation (see page V-230). You should use Fil-
terFIR when convolving a short wave with a much longer one. Use the Convolve operation (see page V-101) 
when convolving two waves with similar number of points; it’s faster.
All the values in the coefficients wave are used. FilterFIR presumes that the middle point of the coefficient 
wave corresponds to the delay = 0 point. This is usually the case when the coefficient wave contains the two-
sided impulse response of a filter, which has an odd number of points. (For a coefficient wave with an even 
number of points, the “middle” point is numpnts(coefs)/2-1, but this introduces a usually unwanted 
delay in the smoothed data).
In the following example, the coefs wave smooths the data by a simple 7 point Bartlett (triangle) window 
(omitting the first and last Bartlett window values which are 0):
// This example shows a unit step signal smoothed
// by a 7-point Bartlett window
Make/O/N=10 beforeWave = (p>=5)
// unit step at p == 5
Make/O coefs={1/3,2/3,1,2/3,1/3}
// 7 point Bartlett window
WaveStats/Q coefs
coefs/= V_Sum
Duplicate/O beforeWave,afterWave
FilterFIR/E=3/COEF=coefs afterWave
Display beforeWave,afterWave
5
4
3
2
1
0
1.2
1.1
1.0
0.9
0.8
0.7
 NOx vs EquivRatio
Original Y vs X
 fittedNOx
Smoothed waveform result
 cp
+99% confidence interval
 cm
-99% confidence interval
