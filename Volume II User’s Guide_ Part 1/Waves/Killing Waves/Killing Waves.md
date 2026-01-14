# Killing Waves

Chapter II-5 — Waves
II-70
For information on dates and times in graphs, see Date/Time Axes on page II-315.
Duplicate Operation
Duplicate is a handy and frequently-used operation. It can make new waves that are exact clones of existing 
waves. It can also clone a section of a wave and thus provides an easy way to break a big wave up into 
smaller waves.
Here are some reasons to use Duplicate:
•
To hold the results of a transformation (e.g. integration, differentiation, FFT) while preserving the 
original data.
•
To hold the “destination” of a curve fit.
•
For holding temporary results within an Igor procedure.
•
To extract a section of a wave.
The Duplicate Waves dialog provides an interface to the Duplicate operation (see page V-185). To use it, 
choose Duplicate Waves from the Data menu.
The cursors button is used in conjunction with a graph. You can make a graph of your template wave. Then 
put the cursors on the section of the template that you want to extract. Choose Duplicate Waves from the 
Data menu and click the cursors button. Then click Do It. This clones the section of the template wave iden-
tified by the cursors.
People sometimes make the mistake of using the Make operation when they should be using Duplicate. For 
example, the destination wave in a curve fit must have the same number of points, numeric type and 
numeric precision as the source wave. Duplicating the source wave insures that this will be true.
Duplicate Operation Examples
Clone a wave and then transform the clone:
Duplicate/O wave0, wave0_d1; Differentiate wave0_d1
Use Duplicate to inherit the properties of the template wave:
Make/N=200 wave0; SetScale x 0, 2*PI, wave0; wave0 = sin(x)
Duplicate wave0, wave1; wave1 = cos(x)
Make a destination wave for a curve fit:
Duplicate/O data1, data1_fit
CurveFit gauss data1 /D=data1_fit
Compare the first half of a wave to the second:
Duplicate/O/R=[0,99] data1, data1_1
Duplicate/O/R=[100,199] data1, data1_2
Display data1_1, data1_2
We often use the /O flag (overwrite) with Duplicate because we don’t know or care if a wave already exists 
with the new wave name.
Killing Waves
The KillWaves operation (see page V-471) removes waves from the current experiment. This releases the 
memory used by the waves. Waves that you no longer need clutter up lists and pop-up menus in dialogs. 
By killing them, you reduce this clutter.
Here are some situations in which you would use KillWaves:
•
You are finished examining data that you loaded from a file.
•
You are finished using a wave that you created for experimentation.
