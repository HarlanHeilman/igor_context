# The Load Waves Dialog for Igor Binary

Chapter II-9 — Importing and Exporting Data
II-155
The Igor Binary Wave File
The Igor binary wave file format is Igor’s native format for storing waves. This format stores one wave per file 
very efficiently. The file includes the numeric contents of the wave (or text contents if it is a text wave) as well 
as all of the auxiliary information such as the dimension scaling, dimension and data units and the wave note. 
In an Igor packed experiment file, any number of Igor Binary wave files can be packed into a single file.
The file name extension for an Igor binary wave file is “.ibw”. Old versions of Igor used “.bwav” and this is 
still accepted. The Macintosh file type code is IGBW and the creator code is IGR0 (last character is zero).
The name of the wave is stored inside the Igor binary wave file. It does not come from the name of the file. 
For example, wave0 might be stored in a file called “wave0.ibw”. You could change the name of the file to 
anything you want. This does not change the name of the wave stored in the file.
The Igor binary wave file format was designed to save waves that are part of an Igor experiment. In the case 
of an unpacked experiment, the Igor binary wave files for the waves are stored in the experiment folder and 
can be loaded using the LoadWave operation. In the case of a packed experiment, data in Igor Binary format 
is packed into the experiment file and can be loaded using the LoadData operation.
.ibw files do not support waves with more than 2 billion elements. you can use the SaveData operation or 
the Data Browser Save Copy button to save very large waves in a packed experiment file (.pxp) instead.
Some Igor users have written custom programs that write Igor binary wave files which they load into an 
experiment. Igor Technical Note #003, “Igor Binary Format”, provides the details that a programmer needs 
to do this. See also Igor Pro Technical Note PTN003.
The Load Waves Dialog for Igor Binary
The basic process of loading data from an Igor binary wave file is as follows:
1.
Choose DataLoad WavesLoad Waves to display the Load Waves dialog.
2.
Choose Igor Binary from the File Type pop-up menu.
3.
Click the File button to select the file containing the data.
4.
Check the “Copy to home” checkbox.
5.
Click Do It.
When you click Do It, Igor’s LoadWave operation runs. It executes the Load Igor Binary routine which 
loads the file. If the wave that you are loading has the same name as an existing wave or other Igor object, 
Igor presents a dialog in which you can resolve the conflict.
Notice the “Copy to home” checkbox in the Load Waves dialog. It is very important.
If it is checked, Igor will disassociate the wave from its source file after loading it into the current experi-
ment. When you next save the experiment, Igor will store a new copy of the wave with the current experi-
ment. The experiment will not reference the original source file. We call this “copying” the wave to the 
current experiment.
If “Copy to home” is unchecked, Igor will keep the connection between the wave and the file from which 
it was loaded. When you save the experiment, it will contain a reference to the source file. We call this “shar-
ing” the wave between experiments.
We strongly recommend that you copy waves rather than share them. See Sharing Versus Copying Igor 
Binary Wave Files on page II-156 for details.
LoadData 
Operation
Packed and 
unpacked files
Copies data from one experiment to 
another.
See LoadData on page V-500 for 
details.
To automatically load data using 
an Igor Procedure.
Method
Loads
Action
Purpose
