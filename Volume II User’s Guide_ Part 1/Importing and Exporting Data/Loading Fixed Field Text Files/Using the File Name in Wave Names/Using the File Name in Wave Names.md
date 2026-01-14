# Using the File Name in Wave Names

Chapter II-9 — Importing and Exporting Data
II-142
•
If it detects a change in the number of columns, it starts loading a new block into a new set of waves.
If merely inspecting the file does not identify the problem then you should try the technique of loading a 
subset of your data. This is described under Troubleshooting Delimited Text Files on page II-137 and often 
sheds light on the problem. In the same section, you will find instructions for sending the problem file to 
WaveMetrics for analysis, if necessary.
LoadWave Generation of Wave Names
When loading an Igor binary file or an Igor Text file, LoadWave uses the wave name or names stored in the 
file being loaded.
When loading files as delimited text (/J), as fixed field text (/F), and as general text (/G), wave names are 
determined by the /A, /N, /W, /B, and /NAME flag. This section provides describes how these naming flags 
work.
If you omit all of the naming flags, LoadWave generates wave names like wave0, wave1, and wave2 but if 
such wave already exist, it generates unique names like wave3, wave4, and wave5. LoadWave then dis-
plays a dialog in which you can edit the names.
The /A flag behaves the same except that it turns on "auto name and go" which skips the dialog in which 
you can edit the names. /A=baseName is the same as /A except that allows you to specify a base name other 
than 'wave'.
The /N flag is the same as /A except that it always uses suffix numbers starting from zero and increments 
by one for each wave loaded from the file. If the resulting name conflicts with an existing wave, the existing 
wave is overwritten. For example, /N=wave gives wave names like wave0, wave1, and wave2.
The /W flag loads wave names from the file itself. By default, LoadWave expects the wave names to be in 
the first line of the file but the /L flag allows you to specify another line. If the names in the file conflict with 
existing waves and you specify overwrite (/O), the existing waves are overwritten; if you do not specify 
overwrite, LoadWave displays a dialog in which you can enter unique names.
The /B flag, used when calling LoadWave from a user-defined function, allows you to specify explicit 
names for each column. See Specifying Characteristics of Individual Columns on page II-145 for details.
The /NAME flag provides an easy way to incorporate the file name in the wave names. See the next section 
for details.
/NAME overrides /B which overrides /W which overrides /N which overrides /A.
Using the File Name in Wave Names
The LoadWave /NAME flag was added in Igor Pro 9.00 primarily to provide an easy way to incorporate the 
file name in the wave names.
The Load Waves dialog (DataLoad WavesLoad Waves) supports the /NAME flag through the Use File 
Name in Wave Names and Include Normal Name checkboxes. The dialog does not provide access to all fea-
tures of /NAME but is sufficient for most common uses.
This section provides a general description of the /NAME flag. Subsequent sections with examples which 
should clarify how to use it.
The format of the flag is:
/NAME={namePrefix, nameSuffix, nameOptions}
The generated wave names consist of the following components:
<namePrefix><normal name><nameSuffix><suffix number>
