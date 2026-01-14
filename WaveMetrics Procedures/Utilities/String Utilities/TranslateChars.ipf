// <TranslateChars>

// Returns oldStr after replacing any of oldChars with the corresponding character in newChars.
//
// For example, str=TranslateChars(str,"abc","xyz")	// replace a with x, b with y, and c with z
// If newChars is "", deletes oldChars from str
// Does not check for newChars already in str before translation;
// if you want to delete oldChars, then call TranslateChars(str,oldChars,"") first.
Function/S TranslateChars(oldStr,oldChars,newChars)
	String oldStr,oldChars,newChars
	Variable ndx,whichOldChar=0,whichNewChar=0
	Variable numOldChars=strlen(oldChars),numNewChars=strlen(newChars)
	String oldChar,newChar,newStr=oldStr
	if( (strlen(oldStr)>0) %& (numOldChars>0) )
		do
			ndx= 0	// scan str from start
			oldChar= oldChars[whichOldChar,whichOldChar]	// could be "", then strsearch returns -1
			do
				ndx= strsearch(oldStr,oldChar,ndx)		// search original string so that swap via Translate(str,"ab","ba") works
				if( ndx == -1 )
					break
				endif
				newChar= newChars[whichNewChar,whichNewChar]
				newStr[ndx,ndx]= newChar	// replace in new string, newChar could be ""
				if( strlen(newChar)==0 )
					oldStr[ndx,ndx]=""		// keep old and new string character positions synchronized
				else
					ndx += 1		
				endif
			while( 1 )	// exit via break
			whichOldChar += 1
			whichNewChar= mod(whichOldChar,numNewChars)	// when replacement chars are exhausted, start over
		while( whichOldChar < numOldChars )
	endif
	return newStr
End
