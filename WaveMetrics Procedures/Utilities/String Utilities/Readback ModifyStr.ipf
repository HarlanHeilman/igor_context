// <Readback ModifyStr>
//
// Special purpose routine to help parse the string returned by TraceInfo or AxisInfo
// 
Function/D GetNumFromModifyStr(modstr,key,listChar,itemNo)
	String modstr				// readback string from TraceInfo or AxisInfo
	String key					// keyword as used in Modify command, example: axisEnab
	String listChar			// null or "{" or "(" depending on syntax
	Variable itemNo			// if listChar not null then the number of the item to return
	
	key += "(x)="			// standard stuff
	Variable v1,v2
	v1= strsearch(modstr, key, 0)
	if( v1 < 0 )
		return NaN			// error, key not found
	endif
	v2= v1+strlen(key)
	if( strlen(listChar) != 0 )
		v2= strsearch(modstr, listChar, v2)+1
		do
			if( itemNo==0 )
				break
			endif
			v2= strsearch(modstr, ",", v2)+1
			itemNo -= 1
		while(1)
	endif
		
	return str2num(modstr[v2,v2+50])
End

