# Sharing Versus Copying Igor Binary Wave Files

Chapter II-9 — Importing and Exporting Data
II-156
If you choose DataLoad WavesLoad Igor Binary instead of choosing DataLoad WavesLoad Waves, 
Igor displays the Open File dialog in which you can select the Igor binary wave file to load directly. This is 
a shortcut that skips the Load Waves dialog. When you take this shortcut, you lose the opportunity to set 
the “Copy to home” checkbox. Thus, during the load operation, Igor presents a dialog from which you can 
choose to copy or share the wave.
The LoadData Operation
The LoadData operation provides a way for Igor programmers to automatically load data from packed Igor 
experiment files or from a file-system folder containing unpacked Igor binary wave files. It can load not only 
waves but also numeric and string variables and a hierarchy of data folders that contains waves and variables.
The Data Browser’s Browse Expt button provides interactive access to the LoadData operation and permits 
you to drag a hierarchy of data from one Igor experiment into the current experiment in memory. To 
achieve the same functionality in an Igor procedure, you need to use the LoadData operation directly. See 
the LoadData operation (see page V-500).
LoadData, accessed from the command line or via the Data Browser, has the ability to overwrite existing 
waves, variables and data folders. Igor automatically updates any graphs and tables displaying the over-
written waves. This provides a very powerful and easy way to view sets of identically structured data, as 
would be produced by successive runs of an experiment. You start by loading the first set and create graphs 
and tables to display it. Then, you load successive sets of identically named waves. They overwrite the pre-
ceding set and all graphs and tables are automatically updated.
Sharing Versus Copying Igor Binary Wave Files
There are two reasons for loading a binary file that was created as part of another Igor experiment: you may 
want your current experiment to share data with the other experiment or, you may want to copy data to the 
current experiment from the other experiment.
There is a potentially serious problem that occurs if two experiments share a file. The file can not be in 
two places at one time. Thus, it will be stored with the experiment that created it but separate from the other. 
The problem is that, if you move or rename files or folders, the second experiment will be unable to find the 
binary file.
Here is an example of how this problem can bite you.
Imagine that you create an experiment at work and save it as an unpacked experiment file on your hard 
disk. Let’s call this “experiment A”. The waves for experiment A are stored in individual Igor binary wave 
files in the experiment folder.
Now you create a new experiment. Let’s call this “experiment B”. You use the Load Igor Binary routine to 
load a wave from experiment A into experiment B. You elect to share the wave. You save experiment B on 
your hard disk. Experiment B now contains a reference to a file in experiment A’s home folder.
Now you decide to use experiment B on another computer so you copy it to the other computer. When you 
try to open experiment B, Igor can’t find the file it needs to load the shared wave. This file is back on the 
hard disk of the original computer.
A similar problem occurs if, instead of moving experiment B to another computer, you change the name or 
location of experiment A’s folder. Experiment B will still be looking for the shared file under its old name 
or in its old location and Igor will not be able to load the file when you open experiment B.
Because of this problem, we recommend that you avoid file sharing as much as possible. If it is necessary to 
share a binary file, you will need to be very careful to avoid the situation described above.
The Data Browser always copies when transferring data from disk into memory.
For more information on the problem of sharing files, see References to Files and Folders on page II-24.
