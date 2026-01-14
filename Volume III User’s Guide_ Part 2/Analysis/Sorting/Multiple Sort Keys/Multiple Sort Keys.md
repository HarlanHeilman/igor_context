# Multiple Sort Keys

Chapter III-7 — Analysis
III-133
There are other sorting-related operations: MakeIndex and IndexSort. These are used in rare cases and are 
described the section MakeIndex and IndexSort on page III-134. The SortColumns operation sorts 
columns of multidimensional waves. Also see the SortList function for sorting string lists.
To use the Sort operation, choose Sort from the Analysis menu.
The sort key wave controls the reordering of points. However, the key wave itself is not reordered unless 
it is also selected as a destination wave in the “Waves to Sort” list.
The number of points in the destination wave or waves must be the same as in the key wave. When you 
select a wave from the dialog’s Key Wave list, Igor shows only waves with the same number of points in 
the Waves to Sort list.
The key wave can be a numeric or text wave, but it must not be complex. The destination wave or waves can 
be text, real or complex except for the MakeIndex operation in which case the destination must be text or real.
The number of destination waves is constrained by the 2500 byte limit in Igor’s command buffer. To sort a 
very large number of waves, use several Sort commands in succession, being careful not to sort the key 
wave until the very last.
By default, text sorting is case-insensitive. Use the /C flag with the Sort operation to make it case-sensitive.
Simple Sorting
In the simplest case, you would select a single wave as both the source and the destination. Then Sort would 
merely sort that wave.
If you want to sort an XY pair such that the X wave is in order, you would select the X wave as the source 
and both the X and Y waves as the destination.
Sorting to Find the Median Value
The following user-defined function illustrates a simple use of the Sort operation to find the median value 
of a wave.
Function FindMedian(w, x1, x2)// Returns median value of wave w
Wave w
Variable x1, x2
// Range of interest
Variable result
Duplicate/R=(x1,x2)/FREE w, medianWave // Make a clone of wave
Sort tempMedianWave, medianWave
// Sort clone
SetScale/P x 0,1,medianWave
result = medianWave((numpnts(medianWave)-1)/2)
return result
End
It is easier and faster to use the built-in median function to find the median value in a wave.
Multiple Sort Keys
If the key wave has two or more identical values, you may want to use a secondary source to determine the 
order of the corresponding points in the destination. This requires using multiple sort keys. The Sorting 
dialog does not provide a way to specify multiple sort keys but the Sort operation does. Here is an example 
demonstrating the difference between sorting by single and by multiple keys. Notice that the sorted wave 
(tdest) is a text wave, and the sort keys are text (tsrc) and numeric (nw1):
Make/O/T tsrc={"hello","there","hello","there"}
Duplicate/O tsrc,tdest
Make nw1= {3,5,2,1}
tdest= tsrc + " " + num2str(nw1)
Edit tsrc,nw1,tdest
