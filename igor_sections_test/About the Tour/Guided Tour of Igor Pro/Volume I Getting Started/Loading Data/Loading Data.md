# Loading Data

Chapter I-2 — Guided Tour of Igor Pro
I-22
4.
Choose FileSave Experiment As.
The save file dialog appears.
5.
Make sure that Packed Experiment File is selected as the file format.
6.
Navigate to the “Guided Tours” folder.
7.
Type “Tour 1A.pxp” in the name box.
8.
Click Save.
The “Tour 1A.pxp” file contains all of your work in the current experiment, including waves that you 
created, graphs, tables and page layout windows.
If you want to take a break, you can quit Igor Pro now.
Loading Data
Before loading data we will use a notebook window to look at the data file.
1.
If you are returning from a break, launch Igor and open your “Tour 1A.pxp” experiment file. Then 
turn preferences off using the Misc menu.
Opening the “Tour 1A.pxp” experiment file restores the Igor workspace to the state it was in when you 
saved the file. You can open the experiment file by using the Open Experiment item in the File menu. by 
double-clicking the experiment file, or by choosing FileRecent ExperimentsTour #1a.pxp.
2.
Choose the FileOpen FileNotebook menu item.
3.
Navigate to the folder “Igor Pro 9 Folder:Learning Aids:Sample Data” folder and open “Tutorial 
Data #1.txt.”
The Igor Pro 9 folder is typically installed in “/Applications” on Macintosh and in “C:/Program 
Files/WaveMetrics” on Windows.
A notebook window showing the contents of the file appears. If desired, we could edit the data and then 
save it. For now we just observe that the file appears to be tab-delimited (tabs separate the columns) and 
contains names for the columns. Note that the name of the first column will conflict with the data we just 
entered and the other names have spaces in them.
4.
Click the close button or press Command-W (Macintosh) or Ctrl+W (Windows).
A dialog appears asking what you want to do with the notebook window.
5.
Click the Kill button.
The term “kill” means to “completely remove from the experiment”. The file will not be affected.
Now we will actually load the data.
6.
Choose DataLoad WavesLoad Delimited Text.
An Open File dialog appears.
7.
Again choose “Tutorial Data #1.txt” and click Open.
The Loading Delimited Text dialog appears. The name “timeval” is highlighted and an error message 
is shown. Observe that the names of the other two columns were fixed by replacing the spaces with 
underscore characters.
