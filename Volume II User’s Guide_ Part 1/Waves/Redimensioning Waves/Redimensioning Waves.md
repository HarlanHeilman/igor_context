# Redimensioning Waves

Chapter II-5 — Waves
II-72
Browsing Waves
The Data Browser (Data menu) lets you see what waves (as well as strings and variables) exist at any given 
time. It also lets you see what data folders exist and set the current data folder. The Data Browser is 
described in detail in Chapter II-8, Data Folders.
Igor Pro 6 had a Browse Waves dialog which you accessed via the DataBrowse Waves menu item. Because it 
provided the same functionality as the Data Browser, the dialog and menu item were removed in Igor Pro 7.00.
Renaming Waves
You can rename a wave using:
•
The Data Browser
•
The Rename dialog (Data menu)
•
The Rename operation from the command line
The Rename operation (see page V-796) renames waves as well as other objects.
Here are some reasons for renaming waves:
•
You have loaded a bunch of waves from a file and Igor auto-named the waves.
•
You have decided on a naming convention for waves and you want to make existing waves follow 
the convention.
•
You are about to load a set of waves whose names will be the same as existing waves and you want 
to get the existing waves out of the way but still keep them in memory. (You could also achieve this 
by moving them to a new data folder.)
To use the Rename operation, choose Rename from the Data menu. This brings up the Rename Objects dialog.
Redimensioning Waves
The Redimension operation can change the following properties of a wave:
•
The number of dimensions in the wave
•
The number of elements in each dimension
•
The numeric precision (e.g., single to double)
•
The numeric type (e.g., real to complex)
The Redimension Waves dialog provides an interface to the Redimension operation (see page V-788). To 
use it, choose Redimension Waves from the Data menu.
When Redimension adds new elements to a wave, it sets them to zero for a numeric wave and to blank for 
a text wave.
The following commands illustrate two ways of changing the numeric precision of a wave. Redimension 
preserves the contents of the wave whereas Make does not.
Make/N=5 wave0=x
Edit wave0
Redimension/D wave0
// This preserves the contents of wave0
Make/O/D/N=5 wave0
// This does not
See Vector (Waveform) to Matrix Conversion on page II-98 for information on converting a 1D wave into 
a 2D wave while retaining the data (i.e., reshaping).
