# Supported Matlab Data Types

Chapter II-9 — Importing and Exporting Data
II-164
6.
Click the Accept button.
Igor records the location of the Matlab dynamic libraries in preferences for use in future sessions.
If you call MLLoadWave before you specify the Matlab dynamic library locations, MLLoadWave displays 
the Find Matlab dialog. Follow the steps above to locate your Matlab installation.
Matlab Dynamic Library Issues
NOTE: MLLoadWave requires compatible Matlab dynamic libraries built for the same architecture as your 
version of Igor Pro. IGOR32 (32-bit Igor Pro, Windows only) requires the 32-bit Matlab libraries, while 
IGOR64 (64-bit Igor Pro) requires the 64-bit Matlab libraries. 
If you don't have Matlab or if your Matlab version is not compatible with Igor, or if you simply prefer to 
work with HDF5 files, see Loading Version 7.3 MAT Files as HDF5 Files on page II-165 for a workaround.
Matlab Dynamic Library Issues on Macintosh
On Macintosh, MLLoadWave has been verified to work with Matlab version 2010b and 2015b. It should 
work with later versions. It may or may not work with earlier versions.
For Matlab 2010b, you need to create an alias to the libraries as described next. Matlab 2015b does not 
require the alias. We do not know whether the alias is necessary for versions between 2010b and 2015b.
On Macintosh it sometimes happens that you point Igor to valid Matlab dynamic libraries but Igor still can't 
link with them. This occurs when the dynamic libraries to which Igor directly links cannot find other 
dynamic libraries which they require. To address this problem, create an alias pointing to the Matlab librar-
ies directory as follows:
1.
In the Finder, open the Applications folder and locate the 64-bit Matlab application.
2.
Right click on the Matlab application and open it by selecting "Show Package Contents".
3.
Inside the Matlab package, navigate to the folder containing your Matlab dynamic libraries. This will 
be one of the following:
/Applications/MATLAB_<version>.app/bin/maci64
// 64-bit Macintosh
where <version> is your Matlab version, for example, R2010b. 
4.
Right click the maci64 folder and select Make Alias.
5.
Rename the alias as MLLoadWave64Support.
6.
Move the alias to your Applications folder.
7.
Restart Igor and try Finding Matlab Dynamic Libraries again.
Matlab Dynamic Library Issues on Windows
Prior to Igor Pro 7.02, it was required that the path to the Matlab dynamic libraries directory be in the 
Windows PATH environment variable. As of 7.02, this should no longer be necessary.
However, we can not test with all versions of Matlab and future versions may behave differently. If you 
follow the steps listed under Finding Matlab Dynamic Libraries on page II-163 but Igor is still unable to 
link with the Matlab dynamic libraries, try adding the Matlab libraries path to your Windows PATH envi-
ronment variable. Remember that IGOR32 requires 32-bit Matlab libraries and IGOR64 requires 64-bit 
Matlab libraries. Restart Igor before re-testing.
We have received reports that Matlab 2021 is not compatible with Igor Pro 9. This appears to be caused by 
a dynamic library conflict. See Loading Version 7.3 MAT Files as HDF5 Files on page II-165 for a work-
around.
Supported Matlab Data Types
MLLoadWave can load 1D, 2D, 3D and 4D numeric and string data. MLLoadWave can not load data of 
dimension greater than 4.
