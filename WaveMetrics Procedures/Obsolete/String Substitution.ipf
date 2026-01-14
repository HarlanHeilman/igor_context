#pragma rtGlobals=3		// Use modern global access method.
// <String Substitution>
//
// returns theStr with all instances of srcPat in theStr replaced with destPat
// note: Search is case sensitive

Function/S StrSubstitute(srcPat,theStr,destPat)
	String srcPat,theStr,destPat
	
	Variable sstart=0,sstop,srcLen= strlen(srcPat), destLen= strlen(destPat)
	do
		sstop= strsearch(theStr, srcPat, sstart)
		if( sstop < 0 )
			break
		endif
		theStr[sstop,sstop+srcLen-1]= destPat
		sstart= sstop+destLen
	while(1)
	return theStr
End

