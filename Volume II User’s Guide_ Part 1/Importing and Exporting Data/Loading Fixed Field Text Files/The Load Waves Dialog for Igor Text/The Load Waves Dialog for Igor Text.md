# The Load Waves Dialog for Igor Text

Chapter II-9 — Importing and Exporting Data
II-152
Normally you should make single or double precision floating point waves. Integer waves are normally used 
only to contain raw data acquired via external operations. They are also appropriate for storing image data.
The /N flag is needed only if the data is multidimensional but the flag is allowed for one-dimensional data, 
too. Regardless of the dimensionality, the dimension size list must always be inside parentheses. Examples:
WAVES/N=(5) wave1D
WAVES/N=(3,3) wave2D
WAVES/N=(3,3,3) wave3D
Integer waves are signed unless you use the /U flag to make them unsigned.
If you use the /C flag then a pair of numbers in a line supplies the real and imaginary value for a single point 
in the resulting wave.
If you specify a wave name that is already in use and you don’t use the overwrite option, Igor displays a 
dialog so that you can resolve the conflict.
The /T flag makes text rather than numeric waves. See Loading Text Waves from Igor Text Files on page 
II-154.
A command in an Igor Text file is introduced by the keyword X followed by a space. The command follows 
the X on the same line. When Igor encounters this while loading an Igor Text file it executes the command.
Anything that you can execute from Igor’s command line is acceptable after the X. Introduce comments 
with “X //”. There is no way to do conditional branching or looping. However, you can call an Igor proce-
dure defined in a built-in or auxiliary procedure window.
Commands, introduced by X, are executed as if they were entered on the command line or executed via the 
Execute operation. Such command execution is not thread-safe. Therefore, you can not load an Igor text file 
containing a command from an Igor thread.
Setting Scaling in an Igor Text File
When Igor writes an Igor Text file, it always includes commands to set each wave’s scaling, units and 
dimension labels. It also sets each wave’s note.
If you write a program that generates Igor Text files, you should set at least the scaling and units. If your 
1D data is uniformly spaced in the X dimension, you should use the SetScale operation to set your waves X 
scaling, X units and data units. If your data is not uniformly spaced, you should set the data units only. For 
multidimensional waves, use SetScale to set Y, Z and T units if needed.
The Load Waves Dialog for Igor Text
The basic process of loading data from an Igor Text file is as follows:
1.
Choose DataLoad WavesLoad Waves to display the Load Waves dialog.
2.
Choose Igor Text from the File Type pop-up menu.
3.
Click the File button to select the file containing the data.
/D
Makes waves double precision floating point.
/I
Makes waves 32 bit integer.
/W
Makes waves 16 bit integer.
/B
Makes waves 8 bit integer.
/U
Makes integer waves unsigned.
/T
Specifies text data type.
Flag
Effect
