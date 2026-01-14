# Loading PNG Files

Chapter II-9 — Importing and Exporting Data
II-157
Copy or Share Wave Dialog
When you load an Igor binary wave file interactively (i.e., not via a command), by default Igor displays the 
Copy or Share Wave dialog which allows you to choose to copy the wave into the current experiment or to 
share it with other experiments. You can change the default behavior to always copy or always share using 
the Data Loading section of the Miscellaneous Settings dialog.
If you interactively load multiple Igor binary wave files at one time, by default, you will see the Copy or 
Share Wave dialog once for each file being loaded. In Igor Pro 9 and later, you can apply your choice to all 
of the files by checking the Apply to All Igor Binary Wave Files in the Batch Currently Being Loaded check-
box. This feature is available only when you:
•
Choose DataLoad WavesLoad Igor Binary
•
Drag multiple Igor binary wave files into the Igor command window
•
Drag multiple Igor binary wave files into the Igor frame window (Windows only)
•
Drag multiple Igor binary wave files into the Data Browser (Windows only)
The Copy or Share Wave dialog is not displayed when you load Igor binary wave files using the Data 
Browse Browse Expt button. In that case, the waves are always copied to the current experiment.
When loading multiple Igor binary wave files, the output variables V_Flag, S_waveNames, S_path, and 
S_fileName reflect only the last file loaded.
Loading Image Files
You can load JPEG, PNG, TIFF, BMP, and Sun Raster image files into Igor Pro using the Load Image dialog.
You can load numeric plain text files containing image data using the Load Waves dialog via the Data 
menu. Check the "Load columns into matrix" checkbox.
You can load images from HDF5 files. For help, execute this in Igor:
DisplayHelpTopic "HDF5 in Igor Pro"
You can load images from HDF4 files. For help, execute this in Igor:
DisplayHelpTopic "HDF Loader XOP"
You can also load images by grabbing frames. See the NewCamera operation.
The Load Image Dialog
To load an image file into an Igor wave, choose DataLoad WavesLoad Image to display the Load Image 
dialog.
When you choose a particular type of image file from the File Type pop-up menu, you are setting a file filter 
that is used when displaying the image file selection dialog. If you are not sure that your image file has the 
correct file name extension, choose “Any” from the File Type pop-up menu so that the filter does not restrict 
your selection.
The name of the loaded wave can be the name of the file or a name that you specify. If you enter a wave 
name in the dialog that conflicts with an existing wave name and you do not check the Overwrite Existing 
Waves checkbox, Igor appends a numeric suffix to the new wave name.
Loading PNG Files
There are two menu choices for the PNG format: Raw PNG and PNG. When Raw PNG is selected, the data 
is read directly from the file into the wave. When PNG is selected, the file is loaded into memory, an 
offscreen image is created, and the wave data is set by reading the offscreen image. In nearly all cases, you 
should choose Raw PNG.
