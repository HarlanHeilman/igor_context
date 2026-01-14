# Creating Multidimensional Waves

Chapter II-6 — Multidimensional Waves
II-92
Overview
Chapter II-5, Waves, concentrated on one-dimensional waves consisting of a number of rows. In Chapter 
II-5, Waves, the rows were referred to as “points” and the symbol p stood for row number, which was called 
“point number”. Scaled row numbers were called X values and were represented by the symbol x.
This chapter now extends the concepts from Chapter II-5, Waves, to waves of up to four dimensions by 
adding the column, layer and chunk dimensions. The symbols q, r and s stand for column, layer and chunk 
numbers. Scaled column, layer and chunk numbers are called Y, Z and T values and are represented by the 
symbols y, z and t.
We call a two-dimensional wave a “matrix”; it consists of rows (the first dimension) and columns (the 
second dimension). After two dimensions the terminology becomes a bit arbitrary. We call the next two 
dimensions “layers” and “chunks”.
Here is a summary of the terminology:
Each element of a 1D wave has one index, the row index, and one data value.
Each element of a 2D wave has two indices, the row index and the column index, and one data value.
Each element of a 3D wave has three indices (row, column, layer) and one data value.
Each element of a 4D wave has four indices (row, column, layer, chunk) and one data value.
Creating Multidimensional Waves
Multidimensional waves can be created using the Make operation:
Make/N=(numRows,numColumns,numLayers,numChunks) waveName
When making an N-dimensional wave, you provide N values to the /N flag. For example:
// Make a 1D wave with 20 rows (20 points total)
Make/N=20 wave1
// Make a matrix (2D) wave with 20 rows and 3 columns (60 elements total)
Make/N=(20,3) wave2
The Redimension operation’s /N flag works the same way.
// Change both wave1 and wave2 so they have 10 rows and 4 columns
Redimension/N=(10,4) wave1, wave2
The operations InsertPoints and DeletePoints take a flag (/M=dimensionNumber) to specify the dimension 
into which elements are inserted. For example:
InsertPoints/M=1 2,5,wave2
//M=1 means column dimension
This command inserts 5 new columns in front of column number 2. If the /M=1 had been omitted or if /M=0 
had been used then 5 new rows would have been inserted in front of row number 2.
You can also create multidimensional waves using the Make operation with a list of data values. For exam-
ple:
// Create a 1D wave consisting of a single column of 3 rows
Make wave1 = {1,2,3}
Dimension Number
0
1
2
3
Dimension Name
row
column
layer
chunk
Dimension Index
p
q
r
s
Scaled Dimension Index
x
y
z
t
