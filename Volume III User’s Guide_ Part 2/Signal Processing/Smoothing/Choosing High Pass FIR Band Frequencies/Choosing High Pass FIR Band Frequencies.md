# Choosing High Pass FIR Band Frequencies

Chapter III-9 — Signal Processing
III-308
Duplicate/O otherData, otherDataFiltered
FilterFIR /DIM=0 /COEF=savedFIRfilter otherDataFiltered
Select Filter Coefficients Wave
This section shows how to apply a saved FIR or IIR filter to other data using the Filter Design and Applica-
tion Dialog dialog.
1.
Select the saved filter design wave in the Select Filter Coefficients Wave tab of the dialog.
2.
Select the wave to be filtered from the Apply Filter tab below.
Example: High Pass FIR Filter
Next we design a high pass filter that preserves only the signal components that were removed by the low 
pass filter.
Choose AnalysisFilter and set "Design using this Sampling Frequency (Hz)" to 48000. 
Uncheck Low Pass, check High Pass, and leave uncheck Notch.
Choosing High Pass FIR Band Frequencies
Set the End of Reject Band to 4400 and set Start of Pass Band to 4600 to define the same transition band as 
the low pass filter that we created above. Use 301 terms to get a steep transition between rejecting low fre-
quencies and passing high frequencies:

Chapter III-9 — Signal Processing
III-309
Click the Apply Filter tab to see the result of applying the designed filter to a waveform. Select the fieldRe-
cording wave and click Update Output Now:
