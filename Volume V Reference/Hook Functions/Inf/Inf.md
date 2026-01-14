# Inf

IndexSort
V-442
IndexSort 
IndexSort [ /DIML ] indexWaveName, sortedWaveName [, sortedWaveName]…
The IndexSort operation sorts the values in each sortedWaveName wave according to the Y values of 
indexWaveName.
Flags
Details
indexWaveName can not be complex. indexWaveName is presumed to have been the destination of a previous 
MakeIndex operation.
This has the effect of putting the sortedWaveName waves in the same order as the wave from which the index 
values in indexWaveName was made.
All of the sortedWaveName waves must be of equal length.
See Also
Sorting on page III-132, MakeIndex and IndexSort on page III-134, Sort, MakeIndex
IndexToScale
IndexToScale(wave, index, dim)
The IndexToScale function returns the scaled coordinate value corresponding to wave element index in the 
specified dimension.
The IndexToScale function was added in Igor Pro 7.00.
Details
The function returns the expression:
DimOffset(wave,dim) + index*DimDelta(wave,dim)
index is an integer.
dim is 0 for rows, 1 for columns, 2 for layers or 3 for chunks.
The function returns NaN if dim is not a valid dimension or if index is greater than the number of elements 
in the specified dimension. 
Examples
Make/N=(10,20,30,40) w4D
SetScale/P y 2,3,"", w4D
SetScale/P z 4,5,"", w4D 
SetScale/P t 6,7,"", w4D
Print IndexToScale(w4D,1,0)
Print IndexToScale(w4D,1,1)
Print IndexToScale(w4D,1,2)
Print IndexToScale(w4D,1,3)
Print IndexToScale(w4D,1,4)
Print IndexToScale(w4D,-1,0)
Print IndexToScale(w4D,11,0)
See Also
ScaleToIndex, pnt2x, DimDelta, DimOffset
Waveform Model of Data on page II-62 for an explanation of wave scaling.
Inf 
Inf
The Inf function returns the “infinity” value.
/DIML
Moves the dimension labels with the values (keeps any row dimension label with the 
row's value).
