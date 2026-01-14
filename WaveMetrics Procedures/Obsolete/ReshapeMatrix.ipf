#pragma version=6.30		// Revised for Igor 6.3
#pragma IgorVersion=5		// For optional function parameters

// ====================================================
// NOTE: THIS PROCEDURE IS OBSOLETE: Use Redimension/E=1 instead.
// ====================================================

// ReshapeMatrix
// Allows you to redimension a 2-D matrix from NxM to KxL, as long as N*M == K*L
// The Redimension command didn't used to do this, but Redimension/E=1 now does.

// You can set newRows to NaN to have the macro choose the right number of rows
// for the given value of newCols. The reverse is true, too.
// However, they can't both be NaN!

Macro ReshapeMatrix(matrix,newRows,newCols)
	String matrix
	Variable newRows = NaN, newCols = 1	// defaults to 1 column
	Prompt matrix,"matrix to reshape",popup,WaveList("*",";","")
	Prompt newRows,"new number of rows, or NaN for auto"
	Prompt newCols,"new number of columns, or NaN for auto"
	DoReshapeMatrix($matrix,newRows,newCols,verbose = 1)
End

Function DoReshapeMatrix(matrix,newRows,newCols[,verbose])
	wave matrix
	variable newRows, newCols, verbose
	
	if(paramisdefault(verbose))
		verbose = 0
	endif
	
	if( WaveDims(matrix) != 2 )
		DoAlert 0, nameofwave(matrix)+" is not a two-dimensional wave."
		return 0
	endif
	Variable oldRows = DimSize(matrix,0)
	Variable oldCols = DimSize(matrix,1)
	Variable points = oldRows*oldCols
	if(verbose)
		Print "old number of rows = "+num2istr(oldRows)+", old number columns = "+num2istr(oldCols)
	endif
	if( (numtype(newRows) != 0) && (numtype(newCols) != 0) )
		DoAlert 0, "You must specify one or both of newrows and newcols"
		return 0
	endif
	if( numtype(newRows) != 0 )
		newRows= points/newCols
	endif
	if( numtype(newCols) != 0 )
		newCols= points/newRows
	endif
	if( floor(newRows) != newRows )
		DoAlert 0, "non-integer new rows: "+num2str(newRows)
		return 0
	endif
	if( floor(newCols) != newCols )
		DoAlert 0, "non-integer new columns: "+num2str(newCols)
		return 0
	endif
	if( newRows*newCols != points )
		DoAlert 0, "number of points mismatch: new = "+num2str(newRows*newCols)+", old = "+num2str(points)
		return 0
	endif
	Redimension/E=1/N=(newRows,newCols) matrix
	if(verbose)
		Print nameofwave(matrix)+" reshaped to "+num2istr(newRows)+" rows by "+num2istr(newCols)+" columns"
	endif
	return 1 // success
End
