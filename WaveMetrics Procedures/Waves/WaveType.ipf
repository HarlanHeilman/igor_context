// Version 1.2; Use with Igor Pro 3.0 or later only.
//
//	Removed WaveType function because that is now built-in to
//	Igor Pro 3.0. Changed SetWaveType to handle unsigned ints,
//	liberal wave names and data folders

// Use value of the kind returned by WaveType() to set the wave's type
// Returns the wave's type before it was changed.
Function SetWaveType(w,wType)
	Wave w;Variable wType
	
	Variable oldType= WaveType(w)
	Variable isCmplx= wType %& 0x1
	Variable isUnsigned= wType %& 0x40
	Variable baseType= wType %& (%~0x41)
	String flags="",aflag="SDBWI???"
	if( isCmplx )
		flags += "/C"
	endif
	if( isUnsigned )
		flags += "/U"
	endif
	flags += "/"+aflag[log(baseType)/log(2)-1]
	String cmd="Redimension"+flags+" $\""+GetWavesDataFolder(w, 1)+PossiblyQuoteName(NameOfWave(w))+"\""
	Execute cmd
	return oldType
End
	
