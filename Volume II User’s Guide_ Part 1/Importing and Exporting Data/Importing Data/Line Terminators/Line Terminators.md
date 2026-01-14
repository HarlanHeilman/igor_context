# Line Terminators

Chapter II-9 — Importing and Exporting Data
II-128
Load Waves Submenu
You access all of these routines via the Load Waves submenu of the Data menu.
The Load Waves item in this submenu leads to the Load Waves dialog. This dialog provides access to the 
built-in routines for loading Igor binary wave files, Igor text files, delimited text files, general text files, and 
fixed field text files, and provides access to all available options.
The Load Igor Binary, Load Igor Text, Load General Text, and Load Delimited Text items in the Load Waves 
submenu are shortcuts that access the respective file loading routines with default options. We recommend that 
you start with the Load Waves item so that you can see what options are available.
The precision of numeric waves created by DataLoad General Text and DataLoad Delimited Text is con-
trolled by the Default Data Precision setting in the Data Loading section of the Miscellaneous Settings dialog.
There are no shortcut items for loading fixed field text or image data because these formats require that you 
specify certain parameters.
The Load Image item leads to the Load Image dialog which provides the means to load various kinds of 
image files.
Line Terminators
The character or sequence of characters that marks the end of a line of text is known as the “line terminator” 
or “terminator” for short. Different computer systems use different terminator.
Excel
Supports the .xls and .xlsx file formats.
See Loading Excel Files on page II-159.
HDF4
Requires activating an Igor extension. For help, execute this in Igor:
DisplayHelpTopic "HDF Loader XOP"
HDF5
For help, execute this in Igor:
DisplayHelpTopic "HDF5 in Igor Pro"
Matlab
See Loading Matlab MAT Files on page II-163.
JCAMP-DX
The JCAMP-DX format is used primarily in infrared spectroscopy.
See Loading JCAMP Files on page II-168.
Sound
Supports a variety of sound file formats.
See Loading Sound Files on page II-170.
TDMS
Loads data from National Instruments TDMS files.
Requires activating an extension.
Supported on Windows only.
See the “TDM Help.ihf” help file for details.
Nicolet WFT
Loads data written by old Nicolet oscilloscopes.
Requires activating an extension.
See the “NILoadWave Help.ihf” help file for details.
SQL Databases
Loads data from SQL databases.
Requires activating an extension and expertise in database programming.
See Accessing SQL Databases on page II-181.
File Type
Description
