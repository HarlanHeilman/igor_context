# Indexing with an index wave

Chapter II-5 — Waves
II-77
is not legal. In this assignment, x ranges from 4 to 5. You can get the desired effect using:
wave1(4,5) = wave2(x+1)
// OK!
By virtue of the range specified on the left hand side, x goes from 4 to 5. Therefore, x+1 goes from 5 to 6 and 
the right-hand expression returns the values of wave2 from 5 to 6.
Indexing with an index wave
You can set specific elements of the destination wave using another wave to provide index values using this 
syntax:
destWave[indexWave] = <expression>
This feature was added in Igor Pro 8.00.
When the destination wave is one dimensional, the index wave must contain a list of valid point numbers. 
For example:
Make/O/N=10 destWave = 0
Make/O indexWave = {2,5,8}
destWave[indexWave] = p; Print destWave
destWave[0]= {0,0,2,0,0,5,0,0,8,0}
When the destination wave is multidimensional, the index wave can be two dimensional with a valid row 
index in the first column and a valid column index in the second column. The next example sets all elements 
of the destination wave to zero except for elements (3,2), (5,4), and (7,6) which it sets to 999.
Make/O/N=(10,10) destWave = 0
Make/O/N=(3,2) indexWave
indexWave[0][0] = {3,5,7}
// Store row indices in column 0
indexWave[0][1] = {2,4,6}
// Store column indices in column 1
Edit indexWave
destWave[indexWave] = 999
Edit destWave
When the destination wave is multidimensional, it is legal for the index wave to be 1D containing linear 
point numbers as if the destination wave were itself 1D. The assignment statement is evaluated as if the des-
tination wave were 1D so q, r, s, y, z and t return zero on the righthand side. This example uses a 1D index 
wave to set the same elements as the preceding example:
Make/O/N=(10,10) destWave = 0
Make/O indexWave = {23,45,67}
destWave[indexWave] = 888
In addition to using an index wave on the left hand side, you can also use a value wave on the right with 
this syntax:
destWave[indexWave] = {valueWave}
The value wave is a 1D vector of values. It should contain the same number of values as there are index 
values and should have the same type (numeric, string, etc.) as the destination wave. Here is an example:
Make/O/N=10 destWave = 0
Make/O indexWave = {2,5,8}
Make/O valueWave = {777,776,775}
destWave[indexWave] = {valueWave}
When you use an index wave, a list of individual values is not supported:
destWave[indexWave] = {777,776,775}
// Error - value wave expected in braces
In the next example we treat a 2D destination wave as 1D by providing a 1D index wave:
