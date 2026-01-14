# Using Header Variables From a Function

Chapter II-9 — Importing and Exporting Data
II-169
If you use the /V flag, which corresponds to the the Set JCAMP Variables checkbox in the dialog, it also sets 
"header variables". Header variables are variables that contain data which JCAMPLoadWave gleans from 
the JCAMP header.
When JCAMPLoadWave is called from a macro, it creates the header variables as local variables. When it 
is called from the command line or from a user-defined function, it creates the header variables as global 
variables. The section Using Header Variables From a Function on page II-169 explains this in more detail.
The header variable names are set based on the JCAMP label with a prefix of "SJC_" for string variables or 
"VJC_" for numeric variables. Thus, when it encounters the ##TITLE label, JCAMPLoadWave creates a 
string variable named SJC_TITLE which contains the label.
Certain JCAMP labels are parsed for numeric information and a numeric variable is created. Numeric vari-
ables that might be created include:
If you are loading Fourier domain data, these variables may be created to reflect the fact that the data rep-
resent optical retardation and amplitude: VJC_FIRSTR, VJC_LASTR, VJC_DELTR, VJC_RFACTOR, 
VJC_AFACTOR.
Any other labels found in the header result in a string variable with name SJC_<label> where <label> is 
replaced with the name of the JCAMP label. For instance, the ##YUNITS label results in a string variable 
named SJC_YUNITS.
Since successive data sets in a single file have the same standard labels, the contents of the variables are set 
by the last instance of a given label in the file.
Using Header Variables From a Function
If you execute JCAMPLoadWave from a user-defined function and tell it to create header variables via the 
/V flag, the variables are created as global variables in the current data folder. To access these variables, you 
must use NVAR and SVAR references. These references must appear after the call to JCAMPLoadWave. 
For example:
Function LoadJCAMP()
JCAMPLoadWave/P=JCAMPFiles "JCAMP1.dx"
if (V_Flag == 0)
Print "No waves were loaded"
return -1
endif
NVAR VJC_NPOINTS
Printf "Number of points: %d\r", VJC_NPOINTS
VJC_NPOINTS
Set to the number of points in the data set. This is set from the header information. If the actual 
number of data points in the file is different, this variable will not reflect this fact.
VJC_FIRSTX
Set to the X value of the first data point in the data set.
VJC_LASTX
Set to the X value of the last data point in the data set.
VJC_DELTAX
Set to the interval between successive abscissa values. This is calculated from (VJC_LASTX 
-VJC_FIRSTX)/ (VJC_NPOINTS - 1), and so might be slightly different from the value given 
by the ##DELTAX=label.
VJC_XFACTOR
Set to the multiplier that must be applied to the X data values in the file to give real-world 
values.
VJC_YFACTOR
Set to the multiplier that must be applied to the Y data values in the file to give real-world 
values.
VJC_MINY
Set to the minimum Y value found in the data set.
VJC_MAXY
Set to the maximum Y value found in the data set.
