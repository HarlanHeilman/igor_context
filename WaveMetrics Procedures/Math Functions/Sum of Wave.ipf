
// The following three functions return the sum of the y values
// of a wave.  The first works from point number pStart up to
//  and including point number pStop.  The second is similar
// but uses x values and the third sums the entire wave.
Function/D PSumWave(w,pStart,pStop)
	wave/D w
	variable pStart,pStop

	Variable/D sum=0
	do
		sum+=w[pStart]
		pStart += 1
	while(pStart<=pStop)
	return sum
end

Function/D XSumWave(w,xStart,xStop)
	wave/D w
	variable/D xStart,xStop

	return PSumWave(w,x2pnt(w,xStart),x2pnt(w,xStop))
end

Function/D SumWave(w)
	wave/D w

	return PSumWave(w,0,numpnts(w)-1)
end
