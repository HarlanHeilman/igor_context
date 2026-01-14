# Comparison of General Text, Fixed Field and Delimited Text

Chapter II-9 — Importing and Exporting Data
II-139
3.18934
5.91134
1.04205
6.90194
The Load General Text routine would create four waves with three points each or, if you specify loading as 
a matrix, a single 3 row by 4 column wave.
General text with header
Date: 3/2/93
Sample: P21-3A
ch0
ch1
ch2
ch3
(optional row of labels)
2.97055
1.95692
1.00871
8.10685
3.09921
4.08008
1.00016
7.53136
3.18934
5.91134
1.04205
6.90194
The Load General Text routine would automatically skip the header lines (Date: and Sample:) and would create 
four waves with three points each or, if you specify loading as a matrix, a single 3 row by 4 column wave.
General text with header and multiple blocks
Date: 3/2/93
Sample: P21-3A
ch0_1
ch1_1
ch2_1
ch3_1
(optional row of labels)
2.97055
1.95692
1.00871
8.10685
3.09921
4.08008
1.00016
7.53136
3.18934
5.91134
1.04205
6.90194
Date: 3/2/93
Sample: P98-2C
ch0_2
ch1_2
ch2_2
ch3_2
(optional row of labels)
2.97055
1.95692
1.00871
8.10685
3.09921
4.08008
1.00016
7.53136
3.18934
5.91134
1.04205
6.90194
The Load General Text routine would automatically skip the header lines and would create eight waves 
with three points each or, if you specify loading as a matrix, two 3 row by 4 column waves.
Comparison of General Text, Fixed Field and Delimited Text
You may wonder whether you should use the Load General Text routine, Load Fixed Field routine or the 
Load Delimited Text routine. Most commercial programs create simple tab-delimited files which these rou-
tines can handle. Files created by scientific instruments, mainframe programs, custom programs, or 
exported from spreadsheets are more diverse. You may need to try these routines to see which works better. 
To help you decide which to try first, here is a comparison.
Advantages of the Load General Text compared to Load Fixed Field and to Load Delimited Text:
•
It can automatically skip header text.
•
It can load multiple blocks from a single file.
•
It can tolerate multiple tabs or spaces between columns.
Disadvantages of the Load General Text compared to Load Fixed Field and to Load Delimited Text:
•
It can not handle blanks (missing values).
•
It can not tolerate columns of non-numeric text or non-numeric values in a numeric column.
•
It can not load text values, dates, times or date/times.
•
It can not handle comma as the decimal point (European number style).
The Load General Text routine can load missing values if they are represented in the file explicitly as “NaN” 
(Not-a-Number). It can not handle files that represent missing values as blanks because this confounds the 
technique for determining where a block of numbers starts and ends.
