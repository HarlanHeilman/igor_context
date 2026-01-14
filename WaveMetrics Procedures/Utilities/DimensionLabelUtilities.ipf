#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function/WAVE CopyDimLabelsToWave(WAVE w, Variable dimension[, String newName])
	
	if (ParamIsDefault(newName))
		newName = NameOfWave(w) + "_LBL"+num2str(dimension)
	endif
	
	if (dimension > WaveDims(w)-1)
		Make/T/O/N=0 $newName/WAVE=outw
		return outw
	endif
	
	Make/T/O/N=(DimSize(w, dimension)) $newName/WAVE=outw
	outw = GetDimLabel(w, dimension, p)
	
	return outw
end

Function CopyWaveToDimLabels(WAVE/T labels, WAVE destw, Variable dimension [, Variable src_start, Variable src_step, Variable dest_start, Variable dest_step])

	if (dimension > WaveDims(destw)-1)
		return 1
	endif
	
	if (ParamIsDefault(src_start))
		src_start = 0
	endif
	if (ParamIsDefault(src_step))
		src_step = 1
	endif
	if (ParamIsDefault(dest_start))
		dest_start = 0
	endif
	if (ParamIsDefault(dest_step))
		dest_step = 1
	endif
	
	Variable dest_i=dest_start, src_i = src_start
	Variable maxSrc = numpnts(labels)-1
	Variable maxDest = DimSize(destw, dimension)-1
	do
		SetDimLabel dimension, dest_i, $(labels[src_i]), destw
		dest_i += dest_step
		if (dest_i > maxDest)
			break
		endif
		src_i += src_step
		if (src_i > maxSrc)
			break
		endif
	while(1)
	
	return 0
end

// if dimension = -1, erases all dimensions
Function EraseDimLabels(Wave w, Variable dimension)

	if (dimension > WaveDims(w)-1)
		return 1
	endif
	
	Variable i
	
	Variable startdim = dimension < 0 ? 0 : dimension
	Variable enddim = dimension < 0 ? WaveDims(w)-1 : dimension
	Variable j
	
	for (j = startdim; j <= enddim; j++)
		Variable nmax = DimSize(w, j)
		for (i = 0; i < nmax; i++)
			SetDimLabel j, i, $"", w
		endfor
	endfor
	
	return 0
end