
// This function generates a string of the desired length. It is typically used
// with the FBinRead operation.
// 
Function/S NewString(n)
	variable n
	
	String str1=""
	do
		if( n < 10 )
			break
		endif
		str1 += "0123456789"
		n -= 10
	while(1)
	do
		if( n < 1 )
			break;
		endif
		str1 += "A"
		n -= 1
	while(1)
	return str1
end

