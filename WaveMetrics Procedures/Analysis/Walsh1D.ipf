#pragma rtGlobals=1		// Use modern global access method.

// AG08MAR04
// The following function performs a 1D Walsh transform on the input wave.  The number of points  
// in the wave must be a power of 2.  The result (the transform) is stored in W_WalshTransform
// in the current data folder.  Note that many implementations of Walsh transforms use integers for
// both the input and output.  This implementation makes the output the same data type as the input.
// If your input is an integer wave and you would like to get the single precision output, you can
// just uncomment the redimension line below.
// The following code was translated from a public domain implementation by Tim Tyler.  I have
// changed the last line of code because it seemed to violate the condition that two transforms in a row
// return the original data.
//________________________________________________________________
Function doWalsh1DTransform(inWave)
	Wave inWave
	
	// check that length of the wave is power of 2
	Variable num=DimSize(inWave,0)
	Variable powerOf2=log(num)/log(2)					// not an integer.
	if(2^trunc(powerOf2)!=num)
		Abort "Walsh Transform input requires a Power of 2."
		return 0
	endif

	Duplicate/O inWave,W_WalshTransform
	// uncomment the following line if you want an SP result from integer wave
	// Redimension/S W_WalshTransform
	Variable data_size =num
	Variable data_sizemo=data_size-1
	Variable data_sizeo2=data_size/2						// no need to round since the input is power of 2.

	Variable straddle_width=1
	Variable blockstart=data_sizemo
	Variable a,b,left_index,right_index,block,pair
	
	do 
		left_index=0
		blockstart=trunc(blockstart/2)						// this is our right-shift.
            
		for (block = blockstart; block >= 0; block-=1) 
			right_index = left_index + straddle_width
			for (pair = 0; pair < straddle_width; pair+=1) 
				a = W_WalshTransform[left_index]
				b = W_WalshTransform[right_index]
				W_WalshTransform[left_index] = a + b
				W_WalshTransform[right_index] = a - b
				left_index+=1
				right_index+=1
			endfor
               
			left_index = right_index
		endfor
		
		straddle_width = (straddle_width *2) & data_sizemo
	while (straddle_width != 0)
         
        // The following line appeared in the original code but seems to cause a problem with the first data point.
	// W_WalshTransform[0] = data_sizeo2 - W_WalshTransform[0]
End

//________________________________________________________________
