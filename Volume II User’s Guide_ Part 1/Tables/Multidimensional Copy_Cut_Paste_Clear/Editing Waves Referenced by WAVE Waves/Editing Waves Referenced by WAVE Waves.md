# Editing Waves Referenced by WAVE Waves

Chapter II-12 — Tables
II-270
5.
Enter 0 for the number of columns and click Do It.
You now have a 1D wave created from a column of a 3D wave.
Save Table Copy
You can save the active table as an Igor packed experiment file or as a tab or comma-delimited text file by 
choosing FileSave Table Copy.
The main uses for saving as a packed experiment are to save an archival copy of data or to prepare to merge 
data from multiple experiments (see Merging Experiments on page II-19). The resulting experiment file 
preserves the data folder hierarchy of the waves displayed in the table starting from the “top” data folder, 
which is the data folder that encloses all waves displayed in the table. The top data folder becomes the root 
data folder of the resulting experiment file. Only the table and its waves are saved in the packed experiment 
file, not variables or strings or any other objects in the experiment.
Save Table Copy does not know about dependencies. If a table contains a wave, wave0, that is dependent 
on another wave, wave1 which is not in the table, Save Table Copy will save wave0 but not wave1. When 
the saved experiment is open, there will be a broken dependency.
The main use for saving as a tab or comma-delimited text file is for exporting data to another program.
The point column is never saved.
When saving as text, the data format matches the format shown in the table. This causes truncation if the 
underlying data has more precision than shown in the table.
To save data as text with full precision, choose DataSave WavesSave Delimited Text or use the SaveTa-
bleCopy operation with /F=1.
When saving 3D and 4D waves as text, only the visible layer is saved. To save the entirety of a 3D or 4D wave, 
choose DataSave WavesSave Delimited Text.
The SaveTableCopy provides options that are not available using the Save Table Copy menu command.
Object Reference Waves in Tables
This topic is for advanced users.
Object reference waves are waves containing wave references (WAVE waves) or data folder references 
(DFREF waves).
Object reference wave elements are formatted as hexadecimal by default. See Object Reference Wave For-
matting on page II-258 for details.
Because entering an invalid reference may cause a crash, you can not modify the elements of an object ref-
erence wave by editing in the table.
If you display an object reference wave in a table, turn column info tags on via the Table menu, and hover 
the mouse over an element of the object reference wave, Igor displays in the column info tag information 
about the wave or data folder referenced by the element. This feature works in the debugger if you have 
column info tags turned on.
Editing Waves Referenced by WAVE Waves
This is a feature for advanced users.
If you have a WAVE wave displayed in table, you can select one or more cells of that wave, right-click, and 
choose Edit Waves. Igor creates a new table showing the waves referenced by the selected wave references 
in the table.
