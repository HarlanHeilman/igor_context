# Magnitude and Phase Using WaveMetrics Procedures

Chapter III-9 — Signal Processing
III-274
points, then Igor changes its display mode to Sticks to zero. Also, if you perform an IFFT on a wave that is 
displayed in a graph and the display mode for that wave is Sticks to zero then Igor changes its display mode 
to Lines between points.
Effect of the Number of Points on the Speed of the FFT
Although the prime factor FFT algorithm does not require that the number of points be a power of two, the 
speed of the FFT can degrade dramatically when the number of points can not be factored into small prime 
numbers. The following graph shows the speed of the FFT on a complex vector of varying number of points. 
Note that the time (speed) axis is log. The results are from a Power Mac 9500/120.
The arrow is at N=4096, a power of two. For that number of points, the FFT time was less than 0.02 seconds 
while other nearby values exceed one second. The moral of the story is that you should avoid numbers of 
points that have large prime factors (4078 takes a long time- it has prime factors 2039 and 2). You should 
endeavor to use a number with small prime factors (4080 is reasonably fast — it has prime factors 
2*2*2*2*3*5*17). For best performance, the number of points should be a power of 2, like 4096.
Finding Magnitude and Phase
The FFT operation can create a complex, real, magnitude, magnitude squared, or phase result directly when 
you choose the desired output type in the Fourier Transforms dialog
If you choose to use the complex wave result of the FFT operation you can compute the magnitude and 
phase using the WaveTransform operation (see page V-1090) (with keywords magnitude, magsqr, and 
phase), or with various procedures from the WaveMetrics Procedures folder (described in the next section).
If you want to unwrap the phase wave (to eliminate the phase jumps that occur between ±180 degrees), use 
the Unwrap operation or the Unwrap Waves dialog in the Data menu. See Unwrap on page V-1050. In two 
dimensions you can use ImageUnwrapPhase operation (see page V-433).
Magnitude and Phase Using WaveMetrics Procedures
For backward compatibility you can compute FFT magnitude and phase using the WaveMetrics-provided 
procedures in the “WaveMetrics Procedures:Analysis:DSP (Fourier Etc)” folder.
You can access them using Igor’s “#include” mechanism. See The Include Statement on page IV-166 for 
instructions on including a procedure file.
The WM Procedures Index help file, which you can access from the HelpHelp Windows menu, is a good 
way to find out what routines are available and how to access them.
FTMagPhase Functions
The FTMagPhase functions provide an easy interface to the FFT operation. FTMagPhase has the following 
features:
• Automatic display of the results.
0.01
2
4
6
8
0.1
2
4
6
8
1
2
FFT Time, s
4140
4120
4100
4080
4060
