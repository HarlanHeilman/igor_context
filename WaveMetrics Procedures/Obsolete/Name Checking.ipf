
// return truth numeric value given by c represents an alphabetic character
//
Function IsAlpha(c)
	Variable c
	
	Variable t= (c>=65) %& (c<=90)
	return t %| ( (c>=97) %& (c<=122))
end

// return truth numeric value given by c represents a numeric character
//
Function IsNumeric(c)
	Variable c
	
	return  (c>=48) %& (c<=57)
end

// given a proposed name for an object (wave or something else) return:
//	0 -- no problem
//	1 -- didn't start with a letter
//	2 -- too long
//	3 -- illegal char in name
//	negative value -- already exists. value is minus the  code returned by exists()
//
Function CheckObjName(s,isWave)
	String s; Variable isWave
	
	if( !IsAlpha(char2num(s[0])) )
		return 1
	endif
	Variable n=strlen(s)
	if( isWave )
		if( n > 18 )
			return 2
		endif
	else
		if( n > 31 )
			return 2
		endif
	endif
	Variable i=0,ch
	do
		i+=1
		if( i>=n)
			break
		endif
		ch= char2num(s[i])
		if( !( IsAlpha(ch) %| IsNumeric(ch) %| (ch==95) ) )
			return 3
		endif
	while(1)
	return -exists(s)
end

// Given a base name, append digits until a name is found that
// does not conflict with other object names
//
Function/S FormUniqueName(base)
	String base
	
	Variable i=0
	String s
	do
		sprintf s,"%s%d",base,i
		if( exists(s) == 0 )
			return s
		endif
		i+=1
	while(i<10000)
	return "*****"	// should never happen
End
