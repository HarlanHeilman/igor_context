#pragma rtGlobals=2		// Use modern global access method.
//
// SaveFloatingPointTIFF.ipf
//
// October, 2002 - JP
// WMSaveFloatOr16bitTIFFtoFile() saves 16-bit unsigned integer or floating point TIFF files.
// 16-bit unsigned integer waves are saved as 16-bit unsigned integer TIFF files.
// 32-bit and 64-bit floating point waves are always saved as 32-bit single precision IEEE floating point TIFF files.
//
//	Notes:
//		ImageSave can save 16-bit unsigned integer TIFFs, but not 32-bit floating point TIFFs.
//		Amazingly, ImageLoad can load both types.
//
//		Technically we don't need to use these routines for saving 16-bit TIFFs, but we don't have an
//		ImageSave dialog of any kind, so here's a simple way to save at least 16-bit and floating-point TIFFs.
//
//		See also Image Saver.ipf.

Menu "Save Waves"
	"Save floating point or 16-bit TIFF...",  WMSaveFloatingOr16BitTIFF()
End

Proc WMSaveFloatingOr16BitTIFF(w, path, depthMenuItem, fileName)
	String w
	String path="_none_"
	Variable depthMenuItem=2
	String fileName="SavedImage.TIF"
	Prompt w, "image", popup, WMKeepOnlyImagePaths(WaveList("*",";",""))
	Prompt path, "path", popup, "_none_;"+PathList("*",";","")
	Prompt depthMenuItem, "bits", popup, "16;32 (floating point)"
	Prompt fileName, "file name"
	
	if( exists(w) != 1 )	// handle "_none_"
		return
	endif
	Variable waveIsText = WaveType($w) == 0
	Variable waveIsComplex = WaveType($w) & 0x01
	if( waveIsText || waveIsComplex )
		DoAlert 0, "Expected real-valued numeric image wave!"
		return
	endif

	Variable refNum
	if( CmpStr(path,"_none_") == 0 )
		Open/Z=2/T=".TIF" refNum as fileName
	else
		Open/Z=2/T=".TIF"/P=$path refNum as fileName
	endif
	if( V_Flag == 0 )
		saveAsFloatingPoint= depthMenuItem == 2
		WMSavetoFloatOr16bitTIFFFile(refNum, $w, saveAsFloatingPoint, 0)
		Close refNum
	endif
End

Function/S WMKeepOnlyImagePaths(listOfWavePaths)
	String listOfWavePaths

	String listOfImagePaths=""
	Variable i=0
	do
		String path= StringFromList(i,listOfWavePaths)
		if( strlen(path) == 0 )
			break
		endif
		WAVE/Z image= $path
		if( WaveExists(image) )
			if( DimSize(image,1) > 0 && DimSize(image,2) == 0 )
				Variable waveIsText = WaveType(image) == 0
				Variable waveIsComplex = WaveType(image) & 0x01
				if( !waveIsText && !waveIsComplex )
					listOfImagePaths += path + ";"
				endif
			endif		
		endif
		i += 1
	while(1)
	
	return listOfImagePaths
End

//
// Saves the image w as either 16-bit unsigned integer or as 32-bit floating point.
// The input wave cannot be a text wave, nor can it be complex
Function WMSavetoFloatOr16bitTIFFFile(refNum,w, saveAsFloatingPoint, dotsPerInch)
	Variable refNum
	Wave w							// the image, expected to exist.
	Variable saveAsFloatingPoint	//  0 for 16-bit unsigned integer, 1 for 32-bit floating point.
	Variable dotsPerInch			// 0 if you don't know or don't care.

	Variable waveIsText = WaveType(w) == 0
	Variable waveIsComplex = WaveType(w) & 0x01
	if( waveIsText || waveIsComplex )
		return 0
	endif
	
	Variable waveIs16BitInteger= !saveAsFloatingPoint
	
	// Igor-related weirdness:
	// in TIFF, "strips" or "rows" are a row of contiguous columns, from column 0 to column ncols-1
	// Igor images are stored as columns of contiguous rows, from row 0 to row nRows-1.
	// in order to save the data directly with fBinWrite without transposing the data, we lie about a few things:
	Variable imageWidthTIFFCols= DimSize(w,0)	// tiff columns = Igor rows
	Variable imageLengthTIFFRows= DimSize(w,1)	// tiff rows = Igor columns

	if( imageWidthTIFFCols < 1 || imageLengthTIFFRows < 1 )
		return 0
	endif

	Variable bytesPerPixel= saveAsFloatingPoint ? 4 : 2
	Variable imageBytes= imageWidthTIFFCols * imageLengthTIFFRows * bytesPerPixel
	Variable offsetToImageData=8
	
	// 8-byte TIFF Header
	Variable endian=2	// Big Endian (Motorola/Macintosh format) - PCs can open these, too!
	// "In the MM format, byte order is always from most significant to least significant,
	//  for both 16-bit and 32-bit integers. This is called big-endian byte order." -- TIFF 6.0 specification
	String header="MM"
	// 42 decimal in 16-bit
	header += WMTIFF16BitInt(42)
	// 32-bit offset to first IFD from the file start,  must be to a word boundary.
	// We put it directly after the image data.
	Variable offsetToIFD= offsetToImageData + imageBytes
	header += WMTIFF32BitInt(offsetToIFD)
	FBinWrite/B=(endian) refNum, header
	
	// write the image at offset 8
	if( waveIs16BitInteger )
		FBinWrite/B=(endian)/U/F=2 refNum, w	// unsigned 16 bit word; writes 2 bytes per value, starting with all the IGOR rows of IGOR column 0 
	else
		FBinWrite/B=(endian)/F=4 refNum, w	// 32 bit IEEE floating point; writes 4 bytes per value, starting with all the IGOR rows of IGOR column 0 
	endif

	// Write Image File Directory, 2 bytes for count, 12 bytes each, 4 bytes for offset to next IFD (even if 0, which it is).
	Variable numIFDEntries= 13
	String ifd	 = WMTIFF16BitInt(numIFDEntries)
	
	// each IFD entry in the file directory consumes 12 bytes
	Variable tagNum16
	Variable fieldType16
	Variable numValues32
	Variable valueOffset32

	// NOTE: the 13 entries in an IFD must be sorted in ascending order by Tag #
	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// ImageWidth					256		LONG (4)		1		TIFF columns = Igor rows
	// ImageLength					257		LONG (4)		1		TIFF rows = Igor columns
	// BitsPerSample				258		SHORT	(3)		1		32 for single-precision float, 16 for unsigned integer (in high word) 
	// Compression					259		SHORT	(3)		1		1 (in high word) = no compression
	// PhotometricInterpretation	262		SHORT	(3)		1		1 (in high word) = BlackIsZero
	// StripOffsets					273		LONG (4)		1		file offset to image data.
	// Orientation					274		SHORT	(3)		1		1 (in high word) TIFF rows are plotted top-to bottom, TIFF columns left-to-right
	// RowsPerStrip				278		LONG (4)		1		TIFFrows (1 strip with all the rows in it)
	// StripByteCounts				279		LONG (4)		1		TIFFrows*TIFFCols*sizeof(imagetype)
	// XResolution					282		RATIONAL (5)	1		file offset to rational number expressed as two LONGs, numerator, denominator
	//																		value= pixels/cm, possibly calibrated. If not, then 72 dpi = 7200/254 dots/cm
	// YResolution					283		RATIONAL (5)	1		file offset to rational number expressed as two LONGs, numerator, denominator
	//																		value= pixels/cm, possibly calibrated. If not, then 72 dpi = 7200/254 dots/cm
	// ResolutionUnit				296		SHORT	(3)		1		3 (in high word) = cm
	// SampleFormat				339		SHORT	(3)		1		3 (in high word) for IEEE float (since BitsPerSample is 32, that means single-precision)
	//																	or	1 (in high word) for unsigned integer (the default).

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// ImageWidth					256		LONG (4)		1		TIFF columns = Igor rows
	tagNum16= 256
	fieldType16= 4
	numValues32= 1
	valueOffset32= imageWidthTIFFCols
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// ImageLength					257		LONG (4)		1		TIFF rows = Igor columns
	tagNum16= 257
	fieldType16= 4
	numValues32= 1
	valueOffset32= imageLengthTIFFRows
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// BitsPerSample				258		SHORT	(3)		1		32 (?) (in high word) for single-precision float, 16 for unsigned integer
	tagNum16= 258
	fieldType16= 3
	numValues32= 1
	valueOffset32=  bytesPerPixel * 8
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF16BitIntIn32BitField(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// Compression					259		SHORT	(3)		1		1 (in high word) = no compression
	tagNum16= 259
	fieldType16= 3
	numValues32= 1
	valueOffset32= 1
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF16BitIntIn32BitField(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// PhotometricInterpretation	262		SHORT	(3)		1		1 (in high word) = BlackIsZero
	tagNum16= 262
	fieldType16= 3
	numValues32= 1
	valueOffset32= 1
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF16BitIntIn32BitField(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// StripOffsets					273		LONG (4)		1		file offset to image data.
	tagNum16= 273
	fieldType16= 4
	numValues32= 1
	valueOffset32= offsetToImageData
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// Orientation					274		SHORT	(3)		1		1 (in high word) TIFF rows are plotted top-to bottom, TIFF columns left-to-right
	tagNum16= 274
	fieldType16= 3
	numValues32= 1
	valueOffset32= 1
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF16BitIntIn32BitField(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// RowsPerStrip				278		LONG (4)		1		TIFFrows (1 strip with all the rows in it)
	tagNum16= 278
	fieldType16= 4
	numValues32= 1
	valueOffset32= imageLengthTIFFRows
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// StripByteCounts				279		LONG (4)		1		number of bytes in the (only) strip = TIFFrows*TIFFCols*sizeof(imagetype)
	tagNum16= 279
	fieldType16= 4
	numValues32= 1
	valueOffset32= imageBytes
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// XResolution					282		RATIONAL (5)	1		file offset to rational number expressed as two LONGs, numerator, denominator
	//																	value= pixels/cm, possibly calibrated. If not, then 72 dpi = 7200/254 dots/cm
	Variable offsetToXResolution= offsetToIFD + 2 + numIFDEntries * 12 + 4	// +2 for ifd count bytes, +4 for offset to next IFD (ending LONG 0)
	tagNum16= 282
	fieldType16= 5
	numValues32= 1
	valueOffset32= offsetToXResolution
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)
	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// YResolution					283		RATIONAL (5)	1		file offset to rational number expressed as two LONGs, numerator, denominator
	//															value= pixels/cm, possibly calibrated. If not, then 72 dpi = 7200/254 dots/cm
	Variable offsetToYResolution= offsetToXResolution + 4*2			// + length of two LONGs
	tagNum16= 283
	fieldType16= 5
	numValues32= 1
	valueOffset32= offsetToYResolution
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF32BitInt(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// ResolutionUnit				296		SHORT	(3)		1		2 (in high word) = inches
	tagNum16= 296
	fieldType16= 3
	numValues32= 1
	valueOffset32= 2				// inches.
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF16BitIntIn32BitField(valueOffset32)

	// TagName				   		 Tag#		Type	   		 Count	Value
	// -------------			 -----		-------		 ----	--------
	// SampleFormat				339		SHORT	(3)		1		3 (in high word) for IEEE float (since BitsPerSample is 32, that means single-precision)
	//																	or	1 (in high word) for unsigned integer (the default).
	tagNum16= 339
	fieldType16= 3
	numValues32= 1
	valueOffset32= saveAsFloatingPoint ? 3 : 1
	ifd += WMTIFF16BitInt(tagNum16)+WMTIFF16BitInt(fieldType16)+ WMTIFF32BitInt(numValues32)+WMTIFF16BitIntIn32BitField(valueOffset32)

	// offset to next image file directory, or 0 for none
	ifd += WMTIFF32BitInt(0)
	
	// Write the IFD
	FBinWrite/B=(endian) refNum, ifd
	
	// write the X resolution in pixels/cm (ratio of 2 LONGs)
	Variable numerator, denominator
	if( dotsPerInch > 0 )
		numerator= dotsPerInch*1000
		denominator= 1000
	else	// 0/1 (none)
		numerator= 0
		denominator= 1
	endif
	FBinWrite/B=(endian)/U/F=3 refNum, numerator		// unsigned 32 bit word; writes four bytes. 
	FBinWrite/B=(endian)/U/F=3 refNum, denominator	// unsigned 32 bit word; writes four bytes. 
	
	// write the Y resolution in pixels/cm (ratio of 2 LONGs)
	FBinWrite/B=(endian)/U/F=3 refNum, numerator		// unsigned 32 bit word; writes four bytes. 
	FBinWrite/B=(endian)/U/F=3 refNum, denominator	// unsigned 32 bit word; writes four bytes. 
	
	// calling routine must close the refNum.
End

Function/S WMTIFF16BitInt(num)
	Variable num	// represent this in two bytes
	
	Variable msByte= trunc(num/256)
	Variable lsByte= trunc(num %& 0xFF)
	return num2char(msByte)+num2char(lsByte) // Big-endian
End

Function/S WMTIFF16BitIntIn32BitField(num)
	Variable num	// represent this in two bytes
	
	Variable msByte= trunc(num/256)
	Variable lsByte= trunc(num %& 0xFF)
	return num2char(msByte)+num2char(lsByte)+num2char(0)+num2char(0) // Big-endian
End

Function/S WMTIFF32BitInt(num)
	Variable num	// represent this in two bytes
	
	Variable mask=0xFF000000
	Variable byte1= trunc( (num %& mask ) / 2^24)
	mask=0xFF0000
	Variable byte2= trunc( (num %& mask ) / 2^16)
	mask=0xFF00
	Variable byte3= trunc( (num %& mask ) / 2^8)
	mask=0xFF
	Variable byte4= trunc(num %& mask)
	return num2char(byte1)+num2char(byte2)+num2char(byte3)+num2char(byte4) // Big-endian
End

