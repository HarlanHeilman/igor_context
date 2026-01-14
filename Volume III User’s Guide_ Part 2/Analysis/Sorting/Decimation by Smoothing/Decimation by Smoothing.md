# Decimation by Smoothing

Chapter III-7 — Analysis
III-136
Decimation by Smoothing
While decimation by omission completely discards some of the data, decimation by smoothing combines 
all of the data into the decimated result. The smoothing can take many forms: from simple averaging to 
various kinds of lowpass digital filtering.
The simplest form of smoothing is averaging (sometimes called “boxcar” smoothing). You can decimate by aver-
aging some number of points in your original data set. If you have 1000 points, you can create a 100 point repre-
sentation by averaging every set of 10 points down to one point. For example, make a 1000 point test waveform:
Make/O/N=1000 wave0
SetScale x 0, 5, wave0
wave0 = sin(x) + gnoise(.1)
Now, make a 100 point waveform to contain the result of the decimation:
Make/O/N=100 wave1
SetScale x 0, 5, wave1
wave1 = mean(wave0, x, x+9*deltax(wave0))
Notice that the output wave, wave1, has one tenth as many points as the input wave.
The averaging is done by the waveform assignment
wave1 = mean(wave0, x, x+9*deltax(wave0))
This evaluates the right-hand expression 100 times, once for each point in wave1. The symbol “x” returns 
the X value of wave1 at the point being evaluated. The right-hand expression returns the average value of 
wave0 over the segment that corresponds to the point in wave1 being evaluated.
It is essential that the X values of the output wave span the same range as the X values of the input range. 
In this simple example, the SetScale commands satisfy this requirement.
Results similar to the example above can be obtained more easily using the Resample operation (page 
V-803) and dialog.
Resample is based on a general sample rate conversion algorithm that optionally interpolates, low-pass fil-
ters, and then optionally decimates the data by omission. The lowpass filter can be set to “None” which 
averages an odd number of values centered around the retained data points. So decimation by a factor of 
10 would involve averaging 11 values centered around every 10th point.
The decimation by averaging above can be changed to be 11 values centered around the retained data point 
instead 10 values from the beginning of the retained data point this way:
Make/O/N=100 wave1Centered
SetScale x 0, 5, wave1Centered
wave1Centered = mean(wave0, x-5*deltax(wave0), x+5*deltax(wave0))
Each decimated result (each average) is formed from different values than wave1 used, but it isn’t any less 
valid as a representation of the original data.
1.0
0.0
-1.0
5
4
3
2
1
0
-1.0
0.0
1.0
4
3
2
1
0
wave0
wave1
