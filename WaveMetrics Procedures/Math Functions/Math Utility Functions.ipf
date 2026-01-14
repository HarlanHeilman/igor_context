
// return log base 2
Function/D log2(x)
	variable/D x
	
	return   1.442695040888963*ln(x)
end

// return the smallest power of 2 not smaller than x
Function/D CeilPwr2(x)
	variable/D x
	
	return 2^(ceil(log2(x)))
end

// return sinc(x)/x
// the sinc function is built in to Igor Pro in version 3.02 or later.
