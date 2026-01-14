# Set Scaling After Loading General Text Data

Chapter II-9 — Importing and Exporting Data
II-140
The Load Waves Dialog for General Text — 1D
The basic process of loading data from a general text file is as follows:
1.
Choose DataLoad WavesLoad Waves to display the Load Waves dialog.
2.
Choose General Text from the File Type pop-up menu.
3.
Click the File button to select the file containing the data.
4.
Click Do It.
When you click Do It, Igor’s LoadWave operation runs. It executes the Load General Text routine which 
goes through the following steps:
1.
Locate the start of the block of data using the technique of counting numbers in successive lines. 
This step also skips the header, if any, and determines the number of columns in the block.
2.
Optionally, determine if there is a row of column labels immediately before the block of numbers.
3.
Optionally, present another dialog allowing you to confirm or change wave names.
4.
Create waves.
5.
Load data into the waves until the end of the file or a until a row that contains a different number 
of numbers.
6.
If not at the end of the file, go back to step 1 to look for another block of data.
Igor looks for a row of column labels only if you enable the “Read wave names” option. It looks in the line 
immediately preceding the block of data. If it finds labels and if the number of labels matches the number 
of columns in the block, it uses these labels as wave names. Otherwise, Igor automatically generates wave 
names of the form wave0, wave1 and so on.
If you choose DataLoad WavesLoad General Text instead of choosing DataLoad WavesLoad Waves, 
Igor displays the Open File dialog in which you can select the general text file to load directly. This is a shortcut 
that skips the Load Waves dialog and uses default options for the load. This will always load 1D waves, not a 
matrix. The precision of numeric waves is controlled by the Default Data Precision setting in the Data Loading 
section of the Miscellaneous Settings dialog. Before you use this shortcut, take a look at the Load Waves dialog 
so you can see what options are available.
Editing Wave Names for a Block
In step 3 above, the Load General Text routine presents a dialog in which you can change wave names. This 
works exactly as described above for the Load Delimited Text routine except that it has one extra button: 
“Skip this block”.
Use “Skip this block” to skip one or more blocks of a multiple block general text file.
Click the Skip Column button to skip loading of the column corresponding to the selected name box. Shift-
click the button to skip all columns except the selected one.
The Load Waves Dialog for General Text — 2D
Igor can load a 2D wave using the Load General Text routine. However, Load General Text does not 
support the loading of row/column labels and positions. If the file has such rows and columns, you must 
load it as a delimited text file.
The main reason to use the Load General Text routine rather than the Load Delimited Text routine for 
loading a matrix is that the Load General Text routine can automatically skip nonnumeric header informa-
tion. Also, Load General Text treats any number of spaces and tabs, as well as one comma, as a single delim-
iter and thus is tolerant of less rigid formatting.
Set Scaling After Loading General Text Data
If your 1D data is uniformly spaced in the X dimension then you will be able to use the many operations 
and functions in Igor designed for waveform data. You will need to set the X scaling for your waves after 
you load them, using the Change Wave Scaling dialog.
