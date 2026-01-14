# Variables Set By JCAMPLoadWave

Chapter II-9 — Importing and Exporting Data
II-168
GBLoadWave can not currently read VAX "D" (another 64 bit format). However, VAX D format is the same 
as F with an additional 4 bytes of fraction. This makes it possible to load VAX D format as F format, throw-
ing away the extra fractional bits. Here is an example:
GBLoadWave/W=2/V/P=VAXData/T={2,2}/J=2/N=temp "VAX D File"
KillWaves temp1
Rename temp0, VAXDData_WithoutExtraFractBits
The /W=2 flag tells GBLoadWave that there are two arrays in the file. The /V flag tells it that they are inter-
leaved. The first four bytes of each data point in the file wind up in the temp0 wave. The seconds four bytes, 
which contain the extra fractional bits in the D format, wind up in temp1 which we discard.
Loading JCAMP Files
Igor can load JCAMP-DX files using the JCAMPLoadWave operation. The JCAMP-DX format is used pri-
marily in infrared spectroscopy. It is a plain text format that uses only ASCII characters. 
You can invoke the JCAMPLoadWave operation directly or by choosing DataLoad WavesLoad 
JCAMP-DX File which displays the Load JCAMP-DX File dialog.
JCAMPLoadWave understands JCAMP-DX file headers well enough to read the data and set the wave 
scaling appropriately. Because JCAMP-DX is intended primarily for evenly-spaced data, a single wave is 
produced for each data set. The wave's X scaling is set based on information in the JCAMP-DX file header. 
The header information is optionally stored in the wave note, and optionally in a series of Igor variables. If 
you choose to create these variables, there will be one variable for each JCAMP-DX label in the header.
Files JCAMPLoadWave Can Handle
JCAMPLoadWave can load one or more waves from a single file. The JCAMP-DX standard calls for each 
new data set to start with a new header. Each header should start with the ##TITLE= label. As far as we can 
tell, most spectrometer systems write only one data set per file.
In addition, the JCAMP-DX standard includes simple optional compression techniques which JCAMP-
LoadWave supports. Files that do not use compression are human-readable.
We believe that JCAMPLoadWave should load most files stored in standard JCAMP-DX format. If you 
have a JCAMP-DX file that does not load correctly, please send it to support@wavemetrics.com.
Some systems produce a hybrid format in which the data itself is stored in a binary file, accompanied by an 
ASCII file that contains just a JCAMP-DX style header. We know that certain Bruker NMR spectrometers 
do this. To accomodate these systems, it is possible to select an option to load the header information only. 
You would then have to load the data separately, most likely using GBLoadWave.
Loading JCAMP Header Information
JCAMPLoadWave provides two mechanisms to load the header information into Igor:
•
Storing all header text in the wave note
•
Creating one Igor variable for each JCAMP label encountered in the header
In the Load JCAMP-DX File dialog, checking the Make Wave Note checkbox invokes the /W flag which 
stores the entire header in the wave note.
Checking Set JCAMP Variables invokes the /V flag which creates one Igor variable for each JCAMP label 
encountered in the header. This is explained in the next section.
Variables Set By JCAMPLoadWave
JCAMPLoadWave sets the standard Igor file-loader output variables: S_fileName, S_path, V_flag and 
S_waveNames. These are described in the JCAMPLoadWave reference documentation.
