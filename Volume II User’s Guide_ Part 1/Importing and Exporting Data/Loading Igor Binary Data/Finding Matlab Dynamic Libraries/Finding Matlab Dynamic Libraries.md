# Finding Matlab Dynamic Libraries

Chapter II-9 — Importing and Exporting Data
II-163
// Load row 1 into numeric waves
XLLoadWave/S=worksheetName/R=($startCell,$endCell)/COLT="N"/O/V=0/K=0/Q fileName
if (V_flag == 0)
return -1
// User cancelled
endif
String names = S_waveNames
// S_waveNames is created by XLLoadWave
String nameOut = UniqueName("Matrix", 1, 0)
Concatenate /KILL /O names, $nameOut
// Create matrix and kill 1D waves
String format = "Created numeric matrix wave %s containing cells %s to %s in 
worksheet \"%s\"\r"
Printf format, nameOut, startCell, endCell, worksheetName
End
Loading Matlab MAT Files
The MLLoadWave operation loads Matlab MAT-files into Igor Pro. You can access it directly via the 
MLLoadWave operation or by choosing DataLoad WavesLoad Matlab MAT File which displays the 
Load Matlab MAT File dialog.
MLLoadWave relies on dynamic libraries provided by the Matlab application. You must have a compatible 
version of Matlab installed on your machine to use MLLoadWave. If you don't have Matlab or if your 
Matlab version is not compatible with Igor, or if you simply prefer to work with HDF5 files, see Loading 
Version 7.3 MAT Files as HDF5 Files on page II-165 for a workaround.
The MLLoadWave operation was incorporated into Igor for Igor Pro 7.00. In earlier versions it was imple-
mented as an XOP. The XOP was originally created by Yves Peysson and Bernard Saoutic.
Finding Matlab Dynamic Libraries
MLLoadWave dynamically links with libraries supplied by The Mathworks when you install Matlab. You 
will need to tell Igor where to look as follows:
1.
Choose DataLoad WavesLoad Matlab MAT File.
This displays the Load Matlab MAT File dialog.
2.
Click the Find 32-bit Matlab Libraries button or the Find 64-bit Matlab Libraries button.
The button title depends on whether you are running IGOR32 (Windows only) or IGOR64. Clicking 
it displays the Find Matlab dialog.
3.
Click the Folder button to display a Choose Folder dialog.
4.
Navigate to your Matlab folder and select it.
This will be something like:
C:\Program Files\MATLAB\<version>
// 64-bit Windows
C:\Program Files (x86)\MATLAB\<version>
// 32-bit Windows
/Applications/MATLAB_<version>.app/bin/maci64
// 64-bit Macintosh
where <version> is your Matlab version, for example, R2015a. 
5.
Click the Choose button.
Igor searches your Matlab folder to find the required dynamic libraries. If found, Igor attempts to 
load them. If the search and loading succeeds, the Accept button is enabled. If the search and load-
ing fails, the Accept button is disabled. The search will fail if Igor can not find the required Matlab 
dynamic libraries or if the system can not find other dynamic libraries required by the Matlab dy-
namic libraries.
If you have selected a valid Matlab folder but the Accept button remains disabled, see Matlab Dy-
namic Library Issues.
