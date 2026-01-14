#pragma rtGlobals=1		// Use modern global access method.


// Perform Wiener filtering on an image=convolvedImage given a known 2D impulseResponse
// and a kValue which represents the ratio of the spectra of noise to signal.
// Here: 	y=x*h where x is the original image, h is the impulse response and y is the convolved image.
// The estimated deconvolved image is given by:
// X=YG  where Y is the FT of y, X is the FT of x and G=conj(H)/((mag(H)^2+Sn/Sx)
// Sn is the spectrum of the noise and Sx is the spectrum of the image. kValue=(Sn/Sx).
// The deconvolved image is saved in the wave wienerImage.
// The convolvedImage is a real 2D wave of any data type.  impulseResponse is also a 2D wave
// That should have the same dimensions as the image and where the zero is the center of the image.
// 15JUL03 initial version.

Function doWienerFilterImage(convolvedImage,impulseResponse,kValue)
	Wave convolvedImage,impulseResponse
	Variable kValue
	
	if(DimSize(convolvedImage,1)<=0 || DimSize(impulseResponse,1)<=0 || DimSize(convolvedImage,2)>0 || DimSize(impulseResponse,2)>0)
		Abort "Input waves must be 2D."
		return 0
	endif
	
	FFT/OUT=1/DEST=impulseResponse_FFT impulseResponse		// transfer function.
	FFT/OUT=1/DEST=convolvedImage_FFT convolvedImage			// fft of the output image.
	Duplicate/O/C impulseResponse_FFT, hCC						// complex conjugate of the transfer function.
	hCC=conj(impulseResponse_FFT)								
	convolvedImage_FFT*=hcc/((HCC*impulseResponse_FFT+cmplx(kValue,0)))
	IFFT/DEST=wienerImage convolvedImage_FFT
	ImageTransform swap wienerImage
	KillWaves/Z  convolvedImage_FFT,hCC,impulseResponse_FFT
End