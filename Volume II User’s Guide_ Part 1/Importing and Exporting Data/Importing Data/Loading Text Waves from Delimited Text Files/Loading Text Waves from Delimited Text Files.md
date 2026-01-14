# Loading Text Waves from Delimited Text Files

Chapter II-9 — Importing and Exporting Data
II-134
To understand the row/column label/position controls, you need to understand Igor’s view of a 2D delim-
ited text file:
In the simplest case, your file has just the wave data — no labels or positions. You would indicate this by 
deselecting all four label/position checkboxes.
2D Label and Position Details
If your file does have labels or positions, you would indicate this by selecting the appropriate checkbox. 
Igor expects that row labels appear in the first column of the file and that column labels appear in the first 
line of the file unless you instruct it differently using the Tweaks subdialog (see Delimited Text Tweaks on 
page II-136). Igor loads row/column labels into the wave’s dimension labels (described in Chapter II-6, Mul-
tidimensional Waves).
Igor can treat column positions in one of two ways. It can use them to set the dimension scaling of the wave 
(appropriate if the positions are uniformly-spaced) or it can create separate 1D waves for the positions. Igor 
expects row positions to appear in the column immediately after the row labels or in the first column of the 
file if the file contains no row labels. It expects column positions to appear immediately after the column 
labels or in the first line of the file if the file contains no column labels unless you instruct it differently using 
the Tweaks subdialog.
A row position wave is a 1D wave that contains the numbers in the row position column of the file. Igor 
names a row position wave “RP_ ” followed by the name of the matrix wave being loaded. A column posi-
tion wave is a 1D wave that contains the numbers in the column position line of the file. Igor names a 
column position wave “CP_” followed by the name of the matrix wave being loaded. Once loaded (into sep-
arate 1D waves or into the matrix wave’s dimension scaling), you can use row and column position infor-
mation when displaying a matrix as an image or when displaying a contour of a matrix.
If your file contains header information before the data, column labels and column positions, you need to 
use the Tweaks subdialog to specify where to find the data of interest. The “Line containing column labels” 
tweak specifies the line on which to find column labels. The “First line containing data” tweak specifies the 
first line of data to be stored in the wave itself. The first line in the file is considered to be line zero.
If you instruct LoadWave to read column positions, it determines which line contains them in one of two 
ways, depending on whether or not you also instructed it to read column labels. If you do ask LoadWave 
to read column labels, then LoadWave assumes that the column positions line immediately follows the 
column labels line. If you do not ask LoadWave to read column labels, then LoadWave assumes that the 
column positions line immediately precedes the first data line.
Loading Text Waves from Delimited Text Files
There are a few issues relating to special characters that you may need to deal with when loading data into 
text waves.
By default, the Load Delimited Text operation considers comma and tab characters to be delimiters which 
separate one column from the next. If the text that you are loading may contain commas or tabs as values 
rather than as delimiters, you will need to change the delimiter characters. You can do this using the Tweaks 
subdialog of the Load Delimited Text dialog.
Col 0
Col 1
Col 2
Col 3
6.0
6.5
7.0
7.5
Row 0
0.0
12.4
24.5
98.2
12.4
Row 1
0.1
43.7
84.3
43.6
75.3
Row 2
0.2
83.8
33.9
43.8
50.1
Optional 
column labels
Optional 
column 
positions
Optional row positions
Optional row 
labels
Wave data
