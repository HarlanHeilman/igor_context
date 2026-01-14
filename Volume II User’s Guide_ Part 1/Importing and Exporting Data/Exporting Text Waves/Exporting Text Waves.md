# Exporting Text Waves

Chapter II-9 — Importing and Exporting Data
II-180
The Save Igor Binary dialog is similar to the Save Delimited Text dialog. There is a difference in file naming 
since, in the case of Igor Binary, each wave is saved in a separate file. If you select a single wave from the 
dialog’s list, you can enter a name for the file. However, if you select multiple waves, you can not enter a 
file name. Igor will use default file names of the form “wave0.ibw”.
When you save an experiment in a packed experiment file, all of the waves are saved in Igor Binary format. 
The waves can then be loaded into another Igor experiment using The Data Browser (see page II-114) or 
The LoadData Operation (see page II-156).
.ibw files do not support waves with more than 2 billion elements. you can use the SaveData operation or 
the Data Browser Save Copy button to save very large waves in a packed experiment file (.pxp) instead.
Saving Waves in Image Files
To save a wave in TIFF, PNG, raw PNG, or JPEG format, choose DataSave WavesSave Image to display 
the Save Image dialog.
JPEG uses lossy compression. TIFF, PNG and raw PNG use lossless compression. To avoid compression 
loss, don’t use JPEG.
JPEG supports only 8 bits per sample. 
PNG supports 24 and 32 bits per sample. Raw PNG supports 8 and 16 bits per sample.
The extended TIFF file format supports 8, 16, and 32 bits per sample and you can use image stacks to export 
3D and 4D waves.
See the ImageSave operation on page V-405 for details.
Saving Sound Files
You can save waves as sound files using the SoundSaveWave operation.
Exporting Text Waves
Igor does not quote text when exporting text waves as a delimited or general text file. It does quote text 
when exporting it as an Igor Text file.
Certain special characters, such as tabs, carriage returns and linefeeds, cause problems during exchange of 
data between programs because most programs consider them to separate one value from the next or one 
line of text from the next. Igor Text waves can contain any character, including special characters. In most 
cases, this will not be a problem because you will have no need to store special characters in text waves or, 
if you do, you will have no need to export them to other programs.
When Igor writes a text file containing text waves, it replaces the following characters, when they occur 
within a wave, with their associated escape codes:
Igor does this because these would be misinterpreted if not changed to escape sequences. When Igor loads a 
text file into text waves, it reverses the process, converting escape sequences into the associated ASCII code.
This use of escape codes can be suppressed using the /E flag of the Save operation (see page V-812). This is 
necessary to export text containing backslashes to a program that does not interpret escape codes.
Character
Name
ASCII Code
Escape Sequence
CR
carriage return
13
\r
LF
linefeed
10
\n
tab
tab
9
\t
\
backslash
92
\\
