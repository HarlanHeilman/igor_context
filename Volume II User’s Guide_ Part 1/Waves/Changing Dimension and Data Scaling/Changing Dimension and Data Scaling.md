# Changing Dimension and Data Scaling

Chapter II-5 — Waves
II-68
The “Overwrite existing waves” option is useful when you don’t know or care if there is a wave with the 
same name as the one you are about to make.
Make Operation Examples
Make coefs for use in curve fitting:
Make/O coefs = {1.5, 2e-3, .01}
Make a wave for plotting a math function:
Make/O/N=200 test; SetScale x 0, 2*PI, test; test = sin(x)
Make a 2D wave for image or contour plotting:
Make/O/N=(20,20) w2D; w2D = (p-10)*(q-10)
Make a text wave for a category plot:
Make/O/T quarters = {"Q1", "Q2", "Q3", "Q4"}
It is often useful to make a clone of an existing wave. Don’t use Make for this. Instead use the Duplicate 
operation (see page V-185).
Make/O does not preserve the contents of a wave and in fact will leave garbage in the wave if you change 
the number of points, numeric precision or numeric type. Therefore, after doing a Make/O you should not 
assume anything about the wave’s contents. If you know that a wave exists, you can use the Redimension 
operation instead of Make. Redimension does preserve the wave’s contents.
Waves and the Miscellaneous Settings Dialog
The state of the Type popup menu in the Make Waves dialog, the precision of waves created by typing in 
a table, and the way Igor Binary waves are loaded (whether they are copied or shared) are preset with the 
Miscellaneous Settings dialog using the Data Loading Settings category; see Miscellaneous Settings on 
page III-500.
Changing Dimension and Data Scaling
When you make a 1D wave, it has default X scaling, X units and data units. You should use the SetScale 
operation (see page V-853) to change these properties.
The Change Wave Scaling dialog provides an interface to the SetScale operation. To use it, choose Change 
Wave Scaling from the Data menu.
Scaled dimension indices can represent ordinary numbers, dates, times or date&time values. In the most 
common case, they represent ordinary numbers and you can leave the Units Type pop-up menu in the Set 
X Properties section of the dialog on its default value: Numeric.
If your data is waveform data, you should enter the appropriate Start and Delta X values. If your data is XY 
data, you should enter 0 for Start and 1 for Delta. This results in the default “point scaling” in which the X 
value for a point is the same as the point number.
Normally you should leave the Set X Properties and Set Data Properties checkboxes selected. Deselect one 
of them if you want the dialog to generate commands to set only X or only Data properties. When working 
with multidimensional data, the X of Set X Properties can be changed to Y, Z or T via the pop-up menu. See 
Chapter II-6, Multidimensional Waves.
If you want to observe the properties of a particular wave, double-click it in the list or select the wave and 
then click the From Wave button. This sets all of the dialog items according to that wave’s properties.
