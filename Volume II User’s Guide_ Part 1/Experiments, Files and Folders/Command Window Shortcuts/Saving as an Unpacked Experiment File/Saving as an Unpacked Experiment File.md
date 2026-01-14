# Saving as an Unpacked Experiment File

Chapter II-3 — Experiments, Files and Folders
II-17
In Igor Pro 9 and later, you can save HDF5 packed experiment files in compressed form. This section pro-
vides a brief introduction to HDF5 compression as it relates to saving experiment files. For details on com-
pression, see HDF5 Compression on page II-213.
Compression can reduce file size but also takes more time. Whether compression is worthwhile for you 
depends on the nature of your data and how you trade off file size versus time. If your experiments contain 
lots of relatively small waves with lots of noise, compression will save little disk space. If your experiments 
contain large waves with large sections containing one value (for example, an image that is mostly black), 
compression can save considerable disk space. The only way to tell if compression is worthwhile for you is 
to experiment with it.
To save an HDF5 packed experiment with compression via the File menu you need to enable HDF5 default 
compression and then provide three parameters via the Experiment section of the Miscellaneous Settings 
dialog. The parameters are:
•
The minimum size a wave must be before compression is used
•
A compression level from 0 (no compression) to 9 (max)
•
Whether you want to enable shuffle (an optional process before compression)
Here are instructions for testing HDF5 compression with your experiment files. These instructions use the 
SaveExperiment operation via the TestHDF5ExperimentCompression function, not File->Save Experiment, 
and consequently are independent of the default compression settings in the Miscellaneous dialog.
1.
Activate the "Test HDF5 Experiment Compression.ipf" procedure file as a global procedure file and 
restart Igor. The file is in WaveMetrics Procedures/File Input Output in your Igor Pro folder.
2.
If you don't know how to do this, see Activating WaveMetrics Procedure Files on page II-33.
3.
Open a typical experiment file.
4.
Execute this:
TestHDF5ExperimentCompression(10000, 2, 0)
10000 is the minimum number of elements in a wave to be compressed. Smaller waves are saved 
uncompressed.
2 is the zip compression level.
0 means shuffle is off which is usually what you want.
The TestHDF5ExperimentCompression command saves copies of the current experiment in uncompressed 
form and in compressed form using the specified parameters and prints a message in the command 
window history area showing the effect of compression on the time to save the experiment and on the file 
size. The command deletes the copies so there is no junk left over.
Try different parameters for the minimum wave size and zip compression level to see how they affect save 
time and compression ratio. In most cases, higher zip compression levels provide small increases in com-
pression and are not worth the time required.
Unless you find significant compression ratios, we recommend that you eschew compression. Disk space 
is abundant and time is precious.
By default, compression is disabled when you use the File menu to save an HDF5 packed experiment file. 
If you decide that you want to use compression, see HDF5 Default Compression on page II-214 to learn 
how to enable compression via the Miscellaneous Settings dialog.
Saving as an Unpacked Experiment File
In the unpacked format, an experiment is saved as an experiment file and an experiment folder. The file 
contains instructions that Igor uses to recreate the experiment while the folder contains files from which 
Igor loads data. The experiment folder is also called the home folder.

Chapter II-3 — Experiments, Files and Folders
II-18
The main utility of this format is that it is faster for experiments that contain very large numbers of waves (thou-
sands or more). However the unpacked format is more fragile and thus is not recommended for routine use.
To save a new experiment in the unpacked format, choose Save Experiment from the File menu. At the 
bottom of the resulting Save File dialog, choose Unpacked Experiment Files from the popup menu. When 
you click Save, Igor writes the unpacked experiment file which as a ".uxp" extension.
Igor then automatically generates the experiment folder name by appending " Folder" or the Japanese 
equivalent, to the experiment file name. It then creates the unpacked experiment folder without further 
interaction. For example, if you enter "Test.uxp" as the unpacked experiment file name, Igor automatically 
uses "Test Folder", or the Japanese equivalent, as the unpacked experiment folder name.
If a folder named "Test Folder" already exists then Igor displays an alert asking if you want to reuse the 
folder for the unpacked experiment.
If the automatic generation of the unpacked experiment folder name causes a problem for you then you can 
save an experiment with the names of your choice using the SaveExperiment /F operation.
This illustration shows the icons used with an unpacked experiment and explains where things are stored.
You normally have no need to deal with the files inside the experiment folder. Igor automatically writes 
them when you save an experiment and reads them when you open an experiment.
If the experiment includes data folders (see Chapter II-8, Data Folders) other than the root data folder, then 
Igor will create one subfolder in the experiment folder for each data folder in the experiment. The experi-
ment shown in the illustration above contains no data folders other than root.
Contains the startup commands that Igor executes to 
recreate the experiment, including all experiment windows.
Contains files for waves, variables, history, 
procedures, notebooks and other objects.
