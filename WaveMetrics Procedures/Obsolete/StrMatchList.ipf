// StrMatchList v.10
// MatchList() and StrMatch()

// MatchList(matchStr,list,sep)
// Returns the items of the list whose items match matchStr
// The lists are separated by the sep character, usually ";"
//
// matchStr may be something like "abc", in which case it is identical to CmpStr
// matchStr may also be "*" to match anything, "abc*" to match anything starting with "abc",
//	"*abc" to match anything ending with "abc".
// matchStr may also begin with "!" to indicate a match to anything not matching the rest of
// 	the pattern.
// At most one "*" and one "!" are allowed in matchStr, otherwise the results are not guaranteed.
//
Function/S MatchList(matchStr,list,sep)
	String matchStr,list,sep
	String item,outList=""
	Variable n=strlen(list)
	Variable en,st=0
	do
		en= strsearch(list,sep,st)
		if( en < 0 )
			if( st < n-1 )
				en= n	// no trailing separator
				sep=""  // don't put sep in output, either
			else
				break	// no more items in list
			endif
		endif
		item=list[st,en-1]
		if( StrMatch(matchStr,item) == 0 )
			outlist += item+sep
		Endif
		st=en+1	
	while (st < n )	// exit is by break, above
	return outlist
End

// StrMatch(matchStr,str)
// Returns 0 if the pattern in matchStr matches str, else it returns 1
//
// matchStr may be something like "abc", in which case it is identical to CmpStr
// matchStr may also be "*" to match anything, "abc*" to match anything starting with "abc",
//	"*abc" to match anything ending with "abc".
// matchStr may also begin with "!" to indicate a match to anything not matching the rest of
// 	the pattern.
// At most one "*" and one "!" are allowed in matchStr, otherwise the results are not guaranteed.
//
Function StrMatch(matchStr,str)
	String matchStr,str
	Variable match = 1		// 0 means match
	Variable invert= strsearch(matchStr,"!",0) == 0
	if( invert )
		matchStr[0,0]=""	// remove the "!"
	endif
	Variable st=0,en=strlen(str)-1
	Variable starPos= strsearch(matchStr,"*",0)
	if( starPos >= 0 )	// have a star
		if( starPos == 0 )	// at start
			matchStr[0,0]=""				// remove star at start
		else					// at end
			matchStr[starPos,999999]=""	// remove star and rest of (ignored, illegal) pattern
		endif
		Variable len=strlen(matchStr)
		if( len > 0 )
			if(starPos == 0)	// star at start, match must be at end
				st=en-len+1
			else
				en=len-1	// star at end, match at start
			endif
		else
			str=""	// so that "*" matches anything
		endif
	endif
	match= !CmpStr(matchStr,str[st,en])==0	// 1 or 0
	if( invert )
		match= 1-match
	endif
	return match
End

