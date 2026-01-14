# Make Operation

Chapter II-5 — Waves
II-67
For most work, single precision waves are appropriate.
Single precision waves take up half the memory and disk space of double precision. With the exception of 
the FFT and some special purpose operations, Igor uses double precision for calculations regardless of the 
numeric precision of the source wave. However, the narrower dynamic range and smaller precision of 
single precision is not appropriate for all data. If you are not familiar with numeric errors due to limited 
range and precision, it is safer to use double precision for analysis.
Integer waves are intended for data acquisition purposes and are not intended for use in analysis. See 
Integer Waves on page II-85 for details.
Default Wave Properties
When you create a wave using the Make operation (see page V-526) operation with no optional flags, it has 
the following default properties.
These are the key wave properties. For a comprehensive list of properties, see Wave Properties on page 
II-88.
If you make a wave by loading it from a file or by typing in a table, it has the same default properties except 
for the number of points.
However you make waves, if they represent waveforms as opposed to XY pairs, you should use the Change 
Wave Scaling dialog to set their X scaling and units.
Make Operation
Most of the time you will probably make waves by loading data from a file (see Importing Data on page 
II-126), by entering it in a table (see Using a Table to Create New Waves on page II-239), or by duplicating 
existing waves (see Duplicate Operation on page II-70).
The Make operation is used for making new waves. See the Make operation (see page V-526) for additional 
details.
Here are some reasons to use Make:
•
To make waves to play around with.
•
For plotting mathematical functions.
•
To hold the output of analysis operations.
•
To hold miscellaneous data, such as the parameters used in a curve fit or temporary results within 
an Igor procedure.
The Make Waves dialog provides an interface to the Make operation. To use it, choose Make Waves from 
the Data menu.
Waves have a definite number of points. Unlike a spreadsheet program which automatically ignores blank 
cells at the end of a column, there is no such thing as an “unused point” in Igor. You can change the number 
of points in a wave using the Redimension Waves dialog or the Redimension operation (see page V-788).
Property
Default
Number of points
128
Data type
Real, single-precision floating point
X scaling
x0=0, dx=1 (point scaling)
X units
Blank
Data units
Blank
