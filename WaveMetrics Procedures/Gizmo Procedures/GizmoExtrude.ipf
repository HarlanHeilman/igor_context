#pragma rtGlobals=1		// Use modern global access method.

// Use one of the following function to extrude the data in the desired direction.
// The input must be a triplet wave.   The extrusion is either constant value
// or a value provided by a wave, e.g., WM_ExtrudePathZ(ddd,0,offsetWave=zzr)

Function WM_ExtrudePathX(inTriplet,inOffset[,offsetWave])
	Wave inTriplet
	Variable inOffset
	Wave offsetWave
	
	
	if(WaveExists(inTriplet)==0 || DimSize(inTriplet,1)<2 || DimSize(inTriplet,1)>3)
		Abort "Input should have a triplet wave."
		return 0
	endif
	
	Variable num=DimSize(inTriplet,0)
	Variable newNum=2*num
	String name=nameOfWave(inTriplet)
	name=CleanupName(name+"_exX",1)
	Variable i,count
	
	if(ParamIsDefault(offsetWave) && inOffset>0)
		// extrude the whole path by a constant non-negative value
		Make/O/N=(newNum,3) $name
		Wave outWave=$name
		for(i=0;i<num;i+=1)
			outWave[count][0]=inTriplet[i][0]
			outWave[count][1]=inTriplet[i][1]
			outWave[count][2]=inTriplet[i][2]
			count+=1
			outWave[count][0]=inTriplet[i][0]+inOffset
			outWave[count][1]=inTriplet[i][1]
			outWave[count][2]=inTriplet[i][2]
			count+=1
		endfor
	else
		if(WaveExists(offsetWave))
			Make/O/N=(newNum,3) $name
			Wave outWave=$name
			for(i=0;i<num;i+=1)
				outWave[count][0]=inTriplet[i][0]
				outWave[count][1]=inTriplet[i][1]
				outWave[count][2]=inTriplet[i][2]
				count+=1
				outWave[count][0]=inTriplet[i][0]+offsetWave[i]
				outWave[count][1]=inTriplet[i][1]
				outWave[count][2]=inTriplet[i][2]
				count+=1
			endfor
		else
			Abort  "Bad input parameters"
			return 0
		endif
	endif
End


Function WM_ExtrudePathY(inTriplet,inOffset[,offsetWave])
	Wave inTriplet
	Variable inOffset
	Wave offsetWave
	
	
	if(WaveExists(inTriplet)==0 || DimSize(inTriplet,1)<2 || DimSize(inTriplet,1)>3)
		Abort "Input should have a triplet wave."
		return 0
	endif
	
	Variable num=DimSize(inTriplet,0)
	Variable newNum=2*num
	String name=nameOfWave(inTriplet)
	name=CleanupName(name+"_exY",1)
	Variable i,count
	
	if(ParamIsDefault(offsetWave) && inOffset>0)
		// extrude the whole path by a constant non-negative value
		Make/O/N=(newNum,3) $name
		Wave outWave=$name
		for(i=0;i<num;i+=1)
			outWave[count][0]=inTriplet[i][0]
			outWave[count][1]=inTriplet[i][1]
			outWave[count][2]=inTriplet[i][2]
			count+=1
			outWave[count][0]=inTriplet[i][0]
			outWave[count][1]=inTriplet[i][1]+inOffset
			outWave[count][2]=inTriplet[i][2]
			count+=1
		endfor
	else
		if(WaveExists(offsetWave))
			Make/O/N=(newNum,3) $name
			Wave outWave=$name
			for(i=0;i<num;i+=1)
				outWave[count][0]=inTriplet[i][0]
				outWave[count][1]=inTriplet[i][1]
				outWave[count][2]=inTriplet[i][2]
				count+=1
				outWave[count][0]=inTriplet[i][0]
				outWave[count][1]=inTriplet[i][1]+offsetWave[i]
				outWave[count][2]=inTriplet[i][2]
				count+=1
			endfor
		else
			Abort  "Bad input parameters"
			return 0
		endif
	endif
End


Function WM_ExtrudePathZ(inTriplet,inOffset[,offsetWave])
	Wave inTriplet
	Variable inOffset
	Wave offsetWave
	
	
	if(WaveExists(inTriplet)==0 || DimSize(inTriplet,1)<2 || DimSize(inTriplet,1)>3)
		Abort "Input should have a triplet wave."
		return 0
	endif
	
	Variable num=DimSize(inTriplet,0)
	Variable newNum=2*num
	String name=nameOfWave(inTriplet)
	name=CleanupName(name+"_exZ",1)
	Variable i,count
	
	if(ParamIsDefault(offsetWave) && inOffset>0)
		// extrude the whole path by a constant non-negative value
		Make/O/N=(newNum,3) $name
		Wave outWave=$name
		for(i=0;i<num;i+=1)
			outWave[count][0]=inTriplet[i][0]
			outWave[count][1]=inTriplet[i][1]
			outWave[count][2]=inTriplet[i][2]
			count+=1
			outWave[count][0]=inTriplet[i][0]
			outWave[count][1]=inTriplet[i][1]
			outWave[count][2]=inTriplet[i][2]+inOffset
			count+=1
		endfor
	else
		if(WaveExists(offsetWave))
			Make/O/N=(newNum,3) $name
			Wave outWave=$name
			for(i=0;i<num;i+=1)
				outWave[count][0]=inTriplet[i][0]
				outWave[count][1]=inTriplet[i][1]
				outWave[count][2]=inTriplet[i][2]
				count+=1
				outWave[count][0]=inTriplet[i][0]
				outWave[count][1]=inTriplet[i][1]
				outWave[count][2]=inTriplet[i][2]+offsetWave[i]
				count+=1
			endfor
		else
			Abort  "Bad input parameters"
			return 0
		endif
	endif
End

// Use the following function to extrude an arbitrary path using a triplet wave
// which contains the extrusion size for each component at each point.
Function WM_ExtrudePath(inTriplet,offsetWave)
	Wave inTriplet
	Wave offsetWave
	
	
	if(WaveExists(inTriplet)==0 || DimSize(inTriplet,1)<2 || DimSize(inTriplet,1)>3)
		Abort "Input should have a triplet wave."
		return 0
	endif
	
	if(WaveExists(offsetWave)==0 || DimSize(offsetWave,1)!=3)
		Abort "Offsetwave should have a triplet wave."
		return 0
	endif
	 
	Variable num=DimSize(inTriplet,0)
	Variable newNum=2*num
	String name=nameOfWave(inTriplet)
	name=CleanupName(name+"_ex",1)
	Variable i,count
	
	Make/O/N=(newNum,3) $name
	Wave outWave=$name
	for(i=0;i<num;i+=1)
		outWave[count][0]=inTriplet[i][0]
		outWave[count][1]=inTriplet[i][1]
		outWave[count][2]=inTriplet[i][2]
		count+=1
		outWave[count][0]=inTriplet[i][0]+offsetWave[i][0]
		outWave[count][1]=inTriplet[i][1]+offsetWave[i][1]
		outWave[count][2]=inTriplet[i][2]+offsetWave[i][2]
		count+=1
	endfor
End