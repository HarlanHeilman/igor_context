# The Load Waves Dialog for Delimited Text — 2D

Chapter II-9 — Importing and Exporting Data
II-133
3.
Click the File button to select the file containing the data.
4.
Click Do It.
When you click Do It, the LoadWave operation runs. It executes the Load Delimited Text routine which 
goes through the following steps:
1.
Optionally, determine if there is a row of column labels.
2.
Determine the number of columns.
3.
Determine the format of each column (number, text, date, time or date/time).
4.
Optionally, present another dialog allowing you to confirm or change wave names.
5.
Create waves.
6.
Load the data into the waves.
Igor looks for a row of labels only if you enable the “Read wave names” option. If you enable this option 
and if Igor finds a row of labels then this determines the number of columns that Igor expects in the file. 
Otherwise, Igor counts the number of data items in the first row in the file and expects that the rest of the 
rows have the same number of columns.
In step 3 above, Igor determines the format of each column by examining the first data item in the column. 
Igor tries to interpret all of the remaining items in a given column using the format that it determines from 
the first item in the column.
If you choose DataLoad WavesLoad Delimited Text instead of choosing DataLoad WavesLoad 
Waves, Igor displays the Open File dialog in which you can select the delimited text file to load directly. This 
is a shortcut that skips the Load Waves dialog and uses default options for the load. This always loads 1D 
waves, not a matrix. The precision of numeric waves is controlled by the Default Data Precision setting in the 
Data Loading section of the Miscellaneous Settings dialog. Before you use this shortcut, take a look at the Load 
Waves dialog so you can see what options are available.
Editing Wave Names
The “Auto name & go” option is used mostly when you are loading 1D data under control of an Igor pro-
cedure and you want everything to be automatic. When loading 1D data manually, you normally leave the 
“Auto name & go” option deselected. Then Igor presents an additional Loading Delimited Text dialog in 
which you can confirm or change wave names.
The context area of the Loading Delimited Text dialog gives you feedback on what Igor is about to load. 
You can’t edit the file here. If you want to edit the file, abort the load and open the file as an Igor notebook 
or open it in a text editor.
Set Scaling After Loading Delimited Text Data
If your 1D numeric data is uniformly spaced in the X dimension then you will be able to use the many oper-
ations and functions in Igor designed for waveform data. You will need to set the X scaling for your waves 
after you load them, using the Change Wave Scaling dialog.
Note:
If your 1D data is uniformly spaced it is very important that you set the X scaling of your waves. 
Many Igor operations depend on the X scaling information to give you correct results.
If your 1D data is not uniformly spaced then you will use XY pairs and you do not need to change X scaling. 
You may want to use Change Wave Scaling to set the data units.
The Load Waves Dialog for Delimited Text — 2D
To load a delimited text file as a 2D wave, choose the Load Waves menu item. Then, select the “Load 
columns into matrix” checkbox.
When you load a matrix (2D wave) from a text file, Igor creates a single wave. Therefore, there is no need 
for a second dialog to enter wave names. Instead, Igor automatically names the wave based on the base 
name that you specify. After loading, you can then rename the wave if you want.
