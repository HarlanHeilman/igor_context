# Loading MultiDimensional Waves from Igor Text Files

Chapter II-9 — Importing and Exporting Data
II-153
4.
Click Do It.
When you click Do It, Igor’s LoadWave operation runs. It executes the Load Igor Text routine which loads 
the file.
If you choose DataLoad WavesLoad Igor Text instead of choosing DataLoad WavesLoad Waves, 
Igor displays the Open File dialog in which you can select the Igor Text file to load directly. This is a shortcut 
that skips the Load Waves dialog.
Loading MultiDimensional Waves from Igor Text Files
In an Igor Text file, a block of wave data is preceded by a WAVES declaration. For multidimensional data, 
you must use a separate block for each wave. Here is an example of an Igor Text file that defines a 2D wave:
IGOR
WAVES/D/N=(3,2) wave0
BEGIN
1
2
3
4
5
6
END
The “/N=(3,2)” flag specifies that the wave has three rows and two columns. The first line of data (1 and 2) 
contains data for the first row of the wave. This layout of data is recommended for clarity but is not 
required. You could create the same wave with:
IGOR
WAVES/D/N=(3,2) wave0
BEGIN
1
2
3
4
5
6
END
Igor merely reads successive values and stores them in the wave, storing a value in each column of the first 
row before moving to the second row. All white space (spaces, tabs, return and linefeed characters) are 
treated the same.
When loading a 3D wave, Igor expects the data to be in column/row/layer order. You can leave a blank line 
between layers for readability but this is not required.
Here is an example of a 3 rows by 2 columns by 2 layers wave:
IGOR
WAVES/D/N=(3,2,2) wave0
BEGIN
1
2
3
4
5
6
11
12
13
14
15
16
END
The first 6 numbers define the values of the first layer of the 3D wave. The second 6 numbers define the 
values of the second layer. The blank line improves readability but is not required.
When loading a 4D wave, Igor expects the data to be in column/row/layer/chunk order. You can leave a 
blank line between layers and two blank lines between chunks for readability but this is not required.
If loading a multidimensional wave, Igor expects that the dimension sizes specified by the /N flag are accu-
rate. If there is more data in the file than expected, Igor ignores the extra data. If there is less data than 
expected, some of the values in the resulting waves will be undefined. In either of these cases, Igor prints a 
message in the history area to alert you to the discrepancy.
