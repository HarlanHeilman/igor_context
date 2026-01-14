# Lists of Values

Chapter II-5 — Waves
II-78
Make/O/N=(10,10) destWave = 0
Make/O indexWave = {23,45,67}
Make/O valueWave = {666,665,664}
destWave[indexWave] = {valueWave}
In the next example we treat a 2D the destination wave as 2D by providing a 2D index wave:
Make/O/N=(10,10) destWave = 0
Make/O/N=(3,2) indexWave
indexWave[0][0] = {3,5,7}
// Store row indices in column 0
indexWave[0][1] = {2,4,6}
// Store column indices in column 1
Make/O valueWave = {555,554,553}
destWave[indexWave] = {valueWave}
Interpolation in Wave Assignments
If you specify a fractional point number or an X value that falls between two data points, Igor will return a 
linearly interpolated data value. For example, wave1[1.75] returns the value of wave1 three-quarters of the 
way from the data value of point 1 to the data value of point 2. This interpolation is done only for one-
dimensional waves. See Multidimensional Wave Assignment on page II-96, for information on assign-
ments with multidimensional data.
This is a powerful feature. Imagine that you have an evenly spaced calibration curve, called calibration, and 
you want to find the calibration values at a specific set of X coordinates as stored in a wave called xData. If 
you have set the X scaling of the calibration wave, you can do the following:
Duplicate xData, yData
yData = calibration(xData)
This uses the interpolation feature of Igor’s wave assignment statement to find a linearly-interpolated value 
in the calibration wave for each X coordinate in the xData wave.
Lists of Values
You can assign values to a wave or to a subrange of a wave using a list of values in curly braces. You can 
also add rows and columns.
1D Lists of Values
This section shows how to set elements of a 1D wave and add rows using lists of values. As shown below 
a 1D list of values consists of a lists of row values in curly braces.
Make/O/N=5 wave0 = NaN
// Make 5 point wave and display in table
Edit/W=(5,45,450,350) wave0
wave0 = {0, 1, 2}
// Redimension wave0 to 3 rows and set Y values
Make/O/N=5 wave0 = NaN
// Restore to 5 points
wave0[1,3]= {1, 2, 3}
// Set points 1 through 3
wave0 = NaN
wave0[1]= {1, 2, 3}
// Set points 1 through 3 (same as previous)
wave0 = NaN
wave0[0,4;2]= {0, 2, 4}
// Set points 0, 2, and 4 using a step of 2
// Extend wave0 from 5 rows to 8 rows and set new Y values.
// Adds rows because the index, 5, is equal to the number of wave rows.
wave0 = NaN
wave0[5]= {5, 6, 7}
Make/O/N=5 wave0 = NaN
// Restore to 5 points
