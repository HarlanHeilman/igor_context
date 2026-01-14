#pragma rtGlobals=1		// Use modern global access method.
#pragma version=6.38		// shipped with Igor 6.38

// NOTE: All of these routines work with waves in only the current data folder.
//
// Version 6.02: Added XYZSubsetToXYZTriplet() macro, WMXYZToXYZTriplet() now uses Concatenate,
//				added memory of previous entries which are shared with GizmoUtils.ipf's WMMakeTripletDialog()
// Version 6.38: Added menu definition.

Menu "Macros"	// the traditional location
	"XYZ Waves to XYZ Triplet", XYZToXYZTriplet()
	"XYZ Subset to XYZ Triplet", XYZSubsetToXYZTriplet()
	"XYZ Triplet to XYZ Waves", XYZTripletToXYZ()
End

//
// XYZToXYZTriplet converts separate X, Y, and Z waves
// into one triplet wave containing ALL of the X, Y, and Z values in columns 0, 1, and 2 respectively.
//
Macro XYZToXYZTriplet(wx,wy,wz,triplet,mktbl)
	String wx= StrVarOrDefault("root:Packages:WMMakeTriplet:srcx","")	// same as GizmoUtils' WMMakeTripletDialog()
	String wy= StrVarOrDefault("root:Packages:WMMakeTriplet:srcy","")
	String wz= StrVarOrDefault("root:Packages:WMMakeTriplet:srcz","")
	String triplet=StrVarOrDefault("root:Packages:WMMakeTriplet:outName","xyzTriplet")
	Variable mktbl=NumVarOrDefault("root:Packages:WMMakeTriplet:mktbl",2)	// No
	Prompt wx,"X Wave",popup,WaveList("*",";","DIMS:1")
	Prompt wy,"Y Wave",popup,WaveList("*",";","DIMS:1")
	Prompt wz,"Z Wave",popup,WaveList("*",";","DIMS:1")
	Prompt triplet,"Output 3-column wave name"
	Prompt mktbl,"Put triplet wave in new table?",popup,"Yes;No"

	Silent 1;PauseUpdate
	if( !WaveExists($wx) || WaveDims($wx) != 1)
		Abort wx+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wy) || WaveDims($wy) != 1)
		Abort wy+" is not a one-dimensional wave!"
	endif
	if( !WaveExists($wz) || WaveDims($wz) != 1)
		Abort wz+" is not a one-dimensional wave!"
	endif
	if(numpnts($wx)!=numpnts($wy) || numpnts($wx)!=numpnts($wz))
		Abort "All three waves must have the same number of points!"
	endif

	triplet= CleanupName(triplet,1)	// allow liberal names
	if( strlen(triplet) == 0 )
		Abort "Please enter a name for the output wave"
	endif

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMMakeTriplet
	String/G root:Packages:WMMakeTriplet:srcx = wx
	String/G root:Packages:WMMakeTriplet:srcy = wy
	String/G root:Packages:WMMakeTriplet:srcz = wz
	String/G root:Packages:WMMakeTriplet:outName = triplet
	Variable/G root:Packages:WMMakeTriplet:mktbl= mktbl

	WMXYZToXYZTriplet($wx,$wy,$wz,triplet)
	
	if( mktbl == 1)
		Preferences 1
		Edit $triplet
	endif
End

Function WMXYZToXYZTriplet(wx,wy,wz, outputName)
	Wave wx,wy,wz		// input x, y, and z waves, they MUST be the same length.
	String outputName	// output triplet wave name
	
	Concatenate/O/DL {wx,wy,wz},$outputName
End

//
// XYZSubsetToXYZTriplet converts separate X, Y, and Z waves
// into one triplet wave containing A SUBSET of the X, Y, and Z values in columns 0, 1, and 2 respectively.
//
Macro XYZSubsetToXYZTriplet()
	Silent 1;PauseUpdate
	fXYZSubsetToXYZTriplet()
End

// Renamed WMMakeTripletDialog function from GizmoUtils.ipf
Function fXYZSubsetToXYZTriplet()

	String srcx= StrVarOrDefault("root:Packages:WMMakeTriplet:srcx","")
	String srcy= StrVarOrDefault("root:Packages:WMMakeTriplet:srcy","")
	String srcz= StrVarOrDefault("root:Packages:WMMakeTriplet:srcz","")
	String outName=StrVarOrDefault("root:Packages:WMMakeTriplet:outName","myTriplet")
	Variable minX=NumVarOrDefault("root:Packages:WMMakeTriplet:minX",NaN)
	Variable maxX=NumVarOrDefault("root:Packages:WMMakeTriplet:maxX",NaN)
	Variable minY=NumVarOrDefault("root:Packages:WMMakeTriplet:minY",NaN)
	Variable maxY=NumVarOrDefault("root:Packages:WMMakeTriplet:maxY",NaN)
	Variable mktbl=NumVarOrDefault("root:Packages:WMMakeTriplet:mktbl",2)	// No
	Prompt srcx,"X-Wave",popup,WaveList("*",";","DIMS:1")
	Prompt srcy,"Y-Wave",popup,WaveList("*",";","DIMS:1")
	Prompt srcz,"Z-Wave",popup,WaveList("*",";","DIMS:1")
	Prompt outName,"Triplet Wave Name:"
	Prompt minx,"Minimum X or NaN for no min:"
	Prompt maxX,"Maximum X or NaN for no max:"
	Prompt minY,"Minimum Y or NaN for no min:"
	Prompt maxY,"Maximum Y or NaN for no max:"
	Prompt mktbl,"Put triplet wave in new table?",popup,"Yes;No"
	DoPrompt "3 Waves To Triplet XY Subset",srcx,minX,srcy,maxX,srcz,minY,outName,maxY,mkTbl
	if( V_Flag == 0 )	// continue
		Wave xWave=$srcx
		Wave yWave=$srcy
		Wave zWave=$srcz
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:WMMakeTriplet
		String/G root:Packages:WMMakeTriplet:srcx = srcx
		String/G root:Packages:WMMakeTriplet:srcy = srcy
		String/G root:Packages:WMMakeTriplet:srcz = srcz
		String/G root:Packages:WMMakeTriplet:outName = outName
		Variable/G root:Packages:WMMakeTriplet:minX= minX
		Variable/G root:Packages:WMMakeTriplet:maxX= maxX
		Variable/G root:Packages:WMMakeTriplet:minY= minY
		Variable/G root:Packages:WMMakeTriplet:maxY= maxY
		Variable/G root:Packages:WMMakeTriplet:mktbl= mktbl
		Variable succeeded= fWMMakeTripletWaveSubset(xWave,yWave,zWave,outName,minX,maxX,minY,maxY)
		if( succeeded && (mktbl == 1) )
			Preferences 1
			Wave triplet=$outName
			Edit triplet
		endif
	endif
End


//
// fWMMakeTripletWaveSubset converts from 3 1D waves into a single triplet wave,
// excluding triplets whose X or Y exceeds the min and max x or y values.
// This is a renamed copy of WMMakeTripletWaveSubset() from GizmoUtils.ipf
//
Function fWMMakeTripletWaveSubset(xWave,yWave,zWave,outName,minX,maxX,minY,maxY)
	Wave xWave,yWave,zWave
	Variable minx,maxX,minY,maxY
	String outName
	if(NumPnts(xWave)!=NumPnts(yWave) || NumPnts(xWave)!=NumPnts(zWave))
		DoAlert 0, "All three waves must have the same number of points"
		return 0
	endif
	Variable i, n= NumPnts(xWave), xOK, yOK, numOK=0
	Duplicate/O zWave, $outName
	Wave tripletWave=$outName
	Redimension/N=(n,3) tripletWave
	for(i=0; i<n; i+=1)
		xOK= 1
		if( (xWave[i] < minx) || (xWave[i] > maxX) )		// a comparison with NaN is always false
			xOK= 0
		endif
		yOK= 1
		if( (yWave[i] < minY) || (yWave[i] > maxY) )		// a comparison with NaN is always false
			yOK= 0
		endif
		if( xOK && yOK )
			tripletWave[numOK][0]=xWave[i]
			tripletWave[numOK][1]=yWave[i]
			tripletWave[numOK][2]=zWave[i]
			numOK += 1
		endif
	endfor
	Redimension/N=(numOK,3) tripletWave
	return 1
End


//
// XYZTripletToXYZ converts
// one triplet wave containing all of the X, Y, and Z values in columns 0, 1, and 2 respectively
// into separate X, Y, and Z waves.
//
Macro XYZTripletToXYZ(wtriplet,wx,wy,wz,mktbl)
	String wx= StrVarOrDefault("root:Packages:WMMakeTriplet:srcx","xWave")
	String wy= StrVarOrDefault("root:Packages:WMMakeTriplet:srcy","yWave")
	String wz= StrVarOrDefault("root:Packages:WMMakeTriplet:srcz","zWave")
	String wtriplet=StrVarOrDefault("root:Packages:WMMakeTriplet:outName","myTriplet")
	Variable mktbl=NumVarOrDefault("root:Packages:WMMakeTriplet:mktbl",2)	// No
	Prompt wtriplet,"3-column XYZ wave",popup,WaveList("*",";","DIMS:2,MINCOLS:3,MAXCOLS:30")
	Prompt wx,"X Output Wave"
	Prompt wy,"Y Output Wave"
	Prompt wz,"Z Output Wave"
	Prompt mktbl,"Put x, y, and z waves in new table?",popup,"Yes;No"

	Silent 1;PauseUpdate
	if( !WaveExists($wtriplet) || WaveDims($wtriplet) != 2 || DimSize($wtriplet,1) < 3)
		Abort wtriplet+" is not a triplet wave!"
	endif

	wx= CleanupName(wx,1)	// allow liberal names
	if( strlen(wx) == 0 )
		Abort "Please enter an name for the X output wave"
	endif
	wy= CleanupName(wy,1)	// allow liberal names
	if( strlen(wy) == 0 )
		Abort "Please enter an name for the Y output wave"
	endif
	wz= CleanupName(wz,1)	// allow liberal names
	if( strlen(wz) == 0 )
		Abort "Please enter an name for the Z output wave"
	endif

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:WMMakeTriplet
	String/G root:Packages:WMMakeTriplet:srcx = wx
	String/G root:Packages:WMMakeTriplet:srcy = wy
	String/G root:Packages:WMMakeTriplet:srcz = wz
	String/G root:Packages:WMMakeTriplet:outName = wtriplet
	Variable/G root:Packages:WMMakeTriplet:mktbl= mktbl

	WMXYZTripletToXYZWaves($wtriplet,wx,wy,wz)
	
	if( mktbl == 1)
		Preferences 1
		Edit $wx, $wy, $wz
	endif
End

Function WMXYZTripletToXYZWaves(xyz,xName, yName, zName)
	Wave xyz						// input triplet wave
	String xName, yName, zName	// output wave names	
	
	Duplicate/O xyz, $xName
	WAVE wx= $xName
	Redimension/N=(-1,0) wx
	
	Duplicate/O wx, $yName, $zName
	WAVE wy= $yName
	WAVE wz= $zName
	
	wx= xyz[p][0]
	wy= xyz[p][1]
	wz= xyz[p][2]
End