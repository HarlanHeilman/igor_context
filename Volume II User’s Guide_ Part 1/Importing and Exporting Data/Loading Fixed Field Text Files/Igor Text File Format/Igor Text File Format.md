# Igor Text File Format

Chapter II-9 — Importing and Exporting Data
II-151
Loading this would create two double-precision waves named unit1 and unit2 and set their X scaling, X 
units and data units.
Igor Text with extra commands
IGOR
WAVES/D/O xdata, ydata
BEGIN
98.822
486.528
109.968
541.144
119.573
588.21
133.178
654.874
142.906
702.539
END
X SetScale d 0,0, "V", xdata
X SetScale d 0,0, "A", ydata
X Display/N=TempGraph ydata vs xdata
X ModifyGraph mode=2,lsize=5
X CurveFit line ydata /X=xdata /D
X Textbox/A=LT/X=0/Y=0 "ydata= \\{W_coef[0]}+\\{W_coef[1]}*xdata"
X PrintGraphs TempGraph
X KillWindow TempGraph
// Kill the graph
X KillWaves xdata, ydata, fit_ydata // Kill the waves
Loading this would create two double-precision waves and set their data units. It would then make a graph, 
do a curve fit, annotate the graph and print the graph. The last two lines do housekeeping.
Igor Text File Format
An Igor Text file starts with the keyword IGOR. The rest of the file may contain blocks of data to be loaded 
into waves or Igor commands to be executed and it must end with a blank line.
A block of data in an Igor Text file must be preceded by a declaration of the waves to be loaded. This declaration 
consists of the keyword WAVES followed by optional flags and the names of the waves to be loaded. Next the 
keyword BEGIN indicates the start of the block of data. The keyword END marks the end of the block of data.
A file can contain any number of blocks of data, each preceded by a declaration. If the waves are 1D, the 
block can contain any number of waves but waves in a given block must all be of the same data type. Mul-
tidimensional waves must appear one wave per block.
A line of data in a block consists of one or more numeric or text items with tabs separating the numbers and 
a terminator at the end of the line. The terminator can be CR, LF, or CRLF. Each line should have the same 
number of items.
You can’t use blanks, dates, times or date/times in an Igor Text file. To represent a missing value in a 
numeric column, use “NaN” (not-a-number). To represent dates or times, use the standard Igor date format 
(number of seconds since 1904-01-01).
There is no limit to the number of waves or number of points except that all of the data must fit in available 
memory.
The WAVES keyword accepts the following optional flags:
Flag
Effect
/N=(…)
Specifies size of each dimension for multidimensional waves.
/O
Overwrites existing waves.
/R
Makes waves real (default).
/C
Makes waves complex.
/S
Makes waves single precision floating point (default).
