# Saving Waves in a Delimited Text File

Chapter II-9 — Importing and Exporting Data
II-178
Saving Waves in a Delimited Text File
To save a delimited text file, choose DataSave WavesSave Delimited Text to display the Save Delimited 
Text dialog.
The Save Delimited Text routine writes a file consisting of numbers separated by tabs, or another delimiter 
of your choice, with a selectable line terminator at the end of each line of text. When writing 1D waves, it 
General text
Used for archiving results or for exporting to another program.
Row Format: <number><tab><number><terminator>*
Contains one or more blocks of numbers with any number of rows and columns. A 
row of column labels is optional.
Columns in a block must be equal in length.
Can export 1D or 2D waves.
See Saving Waves in a General Text File on page II-179.
Igor Text
Used for archiving waves or for exporting waves from one Igor experiment to another.
Format: See Igor Text File Format on page II-151 above.
Contains one or more wave blocks with any number of waves and rows. A given 
block can contain either numeric or text data.
Consists of special Igor keywords, numbers and Igor commands.
Can export waves of dimension 1 through 4.
See Saving Waves in an Igor Text File on page II-179.
Igor Binary 
Used for exporting waves from one Igor experiment to another.
Contains data for one Igor wave.
Format: See Igor Technical Note #003, “Igor Binary Format”.
See Sharing Versus Copying Igor Binary Wave Files on page II-156.
Image 
Used for exporting waves to another program.
Format: TIFF, PNG, raw PNG, JPEG.
See Saving Waves in Image Files on page II-180.
HDF4
Igor does not support exporting data in HDF4 format.
HDF5
For help, execute this in Igor:
DisplayHelpTopic "HDF5 in Igor Pro"
Sound 
Used for exporting waves to another program.
Format: AIFC, WAVE.
See Saving Sound Files on page II-180.
TDMS
Saves data to National Instruments TDMS files.
Requires activating an extension.
Supported on Windows only.
See the “TDM Help.ihf” help file for details.
SQL Databases
Writes data to SQL databases.
Requires activating an extension and expertise in database programming.
See Accessing SQL Databases on page II-181.
*
<terminator> can be carriage return, linefeed or carriage return/linefeed. You would use carriage re-
turn for exporting to a Macintosh program, carriage return/linefeed for Windows systems, and linefeed 
for Unix systems.
File type
Description
