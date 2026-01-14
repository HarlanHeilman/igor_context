# Numeric Wave Data Types

Chapter II-5 — Waves
II-66
To make them unambiguous, you must enclose liberal names in single straight quotes whenever they are 
used in commands or waveform arithmetic expressions. For example:
wave0 = 'miles/hour'
Display 'run 98', 'run 99'
NOTE:
Writing procedures that work with liberal names requires extra effort and testing on the part of 
Igor programmers (See Programming with Liberal Names on page IV-168). We recommend that 
you avoid using liberal names until you understand the potential problems and how to solve 
them.
See Object Names on page III-501 for a discussion of object names in general.
Number of Dimensions
Waves can consist of one to four dimensions. You determine this when you make a wave. You can change it 
using the Redimension operation (see page V-788). See Chapter II-6, Multidimensional Waves for details.
Wave Data Types
Each wave has data type that determines the kind of data that it stores.You set a wave’s data type when you 
create it. You can change it using the Data Browser, the Redimension operation (see page V-788) or the Red-
imension dialog.
There are three classes of wave data types:
•
Numeric data types
•
Text
•
References (wave referencesand data folder references)
Each numeric data type can be either real or complex. Text and reference data types can not be complex.
Reference data types are used in programming only.
You can programmatically determine the data type of a wave using the WaveType function.
Numeric Wave Data Types
This table shows the numeric precisions available in Igor.
The 64-bit integer types were added in Igor Pro 7.00.
Precision
Range
Bytes per Point
Double-precision floating point
10-324 to 10+307 (~15 decimal digits)
8
Single-precision floating point
10-45 to 10+38 (~7 decimal digits)
4
Signed 64-bit integer
-2^63 to 2^63 - 1
8
Signed 32-bit integer
-2,147,483,647 to 2,147,483,648
4
Signed 16-bit integer
-32,768 to 32,767
2
Signed 8-bit integer
-128 to 127
1
Unsigned 64-bit integer
0 to 2^64 - 1
8
Unsigned 32-bit integer
0 to 4,294,967,295
4
Unsigned 16-bit integer
0 to 65,535
2
Unsigned 8-bit integer
0 to 255
1
