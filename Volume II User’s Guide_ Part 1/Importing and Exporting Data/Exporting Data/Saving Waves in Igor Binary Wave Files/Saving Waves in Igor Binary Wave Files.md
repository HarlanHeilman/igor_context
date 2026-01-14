# Saving Waves in Igor Binary Wave Files

Chapter II-9 — Importing and Exporting Data
II-179
can optionally include a row of column labels. When writing a matrix, it can optionally write row labels as 
well as column labels plus row and column position information.
Save Delimited Text can save waves of any dimensionality. Multidimensional waves are saved one wave 
per block. Data is written in row/column/layer/chunk order. Multidimensional waves saved as delimited 
text can not be loaded back into Igor as delimited text because the Load Delimited Text routine does not 
support multiple blocks. They can be loaded back in as general text. However, for data that is intended to 
be loaded back into Igor later, the Igor Text, Igor Binary or Igor Packed Experiment formats are preferable.
The order of the columns in the file depends on the order in which the wave names appear in the Save com-
mand. This dialog generates the wave names based on the order in which you select waves in the Source 
Waves list.
By default, the Save operation writes numeric data using the “%.15g” format for double-precision data and 
“%.7g” format for data with less precision. These formats give you up to 15 or 7 digits of precision in the file.
To use different numeric formatting, create a table of the data that you want to export. Set the numeric for-
matting of the table columns as desired. Be sure to display enough digits in the table because the data will 
be written to the file as it appears in the table. In the Save Delimited Text dialog, select the “Use table for-
matting” checkbox. When saving a multi-column wave (1D complex wave or multi-dimensional wave), all 
columns of the wave are saved using the table format for the first table column from the wave.
The SaveTableCopy and wfprintf operations can also be used to save waves to text files using a specific 
numeric format.
The Save operation is capable of appending to an existing file, rather than overwriting the file. This is useful 
for accumulating results of a analysis that you perform regularly in a single file. You can also use this to 
append a block of numbers to a file containing header information that you generated with the fPrintf oper-
ation. The append option is not available through the dialog. If you want to do this, see the discussion of 
the Save operation (see page V-812).
Saving Waves in a General Text File
Saving waves in a general text file is very similar to saving a delimited text file. The Save General Text 
dialog is identical to the Save Delimited Text dialog.
All of the columns in a single block of a general text file must have the same length. The Save General Text 
routine writes as many blocks as necessary to save all of the specified waves. For example, if you ask it to 
save two 1D waves with 100 points and two 1D waves with 50 points, it will write two blocks of data. Mul-
tidimensional waves are written one wave per block.
Saving Waves in an Igor Text File
The Igor Text format is capable of saving not only the data of a wave but its other properties as well. It saves 
each wave’s dimension scaling, units and labels, data full scale and units and the wave’s note, if any. All of 
this data is saved more efficiently as binary data when you save as an Igor packed experiment using the 
SaveData operation.
As in the general text format, all of the columns in a single block of an Igor Text file must have the same 
length. The Save Igor Text routine handles this requirement by writing as many blocks as necessary.
Save Igor Text can save waves of any dimensionality. Multidimensional waves are saved one wave per 
block. The /N flag at the start of the block identifies the dimensionality of the wave. Data is written in 
row/column/layer/chunk order.
Saving Waves in Igor Binary Wave Files
Igor’s Save Igor Binary routine saves waves in Igor binary wave files, one wave per file. Most users will not 
need to do this since Igor automatically saves waves when you save an Igor experiment. You might want 
to save a wave in an Igor binary wave file to send it to a colleague.
