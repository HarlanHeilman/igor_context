#pragma rtGlobals=1

// Version 1.10: Added support for XWAVEDF, YWAVEDF and AXISZ keywords.

//	AnnotationInfo Procedures
//
//	These functions can be used to find information about a tag, textbox or legend in a graph
//	or page layout window.
//
//	Example:
//		String infoStr = AnnotationInfo("Graph0", "text0")
//		Print AnnotationYWave(infoStr), AnnotationAttachX(infoStr)

Function/S ExtractAIField(packedStr, keyStr)
	String packedStr, keyStr
	
	Variable startPos, endPos
	
	startPos = strsearch(packedStr, keyStr, 0) + strlen(keyStr)
	if (CmpStr(keyStr, "TEXT:") == 0)		// TEXT is always the LAST keyword in packedStr
		endPos = strlen(packedStr)
	else
		endPos = strsearch(packedStr, ";", startPos) - 1
	endif

	return packedStr[startPos, endPos]
End

Function/S AnnotationType(infoStr)
	String infoStr					// infoStr is the output from AnnotationInfo function
	
	return ExtractAIField(infoStr, "TYPE:")
End

Function/S AnnotationFlags(infoStr)
	String infoStr					// infoStr is the output from AnnotationInfo function
	
	return ExtractAIField(infoStr, "FLAGS:")
End

Function/S AnnotationXWave(infoStr)
	String infoStr					// infoStr is the output from AnnotationInfo function
	
	return ExtractAIField(infoStr, "XWAVE:")
End

Function/S AnnotationYWave(infoStr)
	String infoStr					// infoStr is the output from AnnotationInfo function
	
	return ExtractAIField(infoStr, "YWAVE:")
End

Function/S AnnotationXWaveDataFolder(infoStr)		// Added in version 1.10
	String infoStr					// infoStr is the output from AnnotationInfo function
	
	return ExtractAIField(infoStr, "XWAVEDF:")
End

Function/S AnnotationYWaveDataFolder(infoStr)		// Added in version 1.10
	String infoStr					// infoStr is the output from AnnotationInfo function
	
	return ExtractAIField(infoStr, "YWAVEDF:")
End

Function/D AnnotationAttachX(infoStr)
	String infoStr					// infoStr is the output from AnnotationInfo function

	return str2num(ExtractAIField(infoStr, "ATTACHX:"))
End

Function/D AnnotationAbsX(infoStr)	
	String infoStr					// infoStr is the output from AnnotationInfo function

	return str2num(ExtractAIField(infoStr, "ABSX:"))
End

Function/D AnnotationAbsY(infoStr)	
	String infoStr					// infoStr is the output from AnnotationInfo function

	return str2num(ExtractAIField(infoStr, "ABSY:"))
End

Function/D AnnotationAxisX(infoStr)	
	String infoStr					// infoStr is the output from AnnotationInfo function

	return str2num(ExtractAIField(infoStr, "AXISX:"))
End

Function/D AnnotationAxisY(infoStr)	
	String infoStr					// infoStr is the output from AnnotationInfo function

	return str2num(ExtractAIField(infoStr, "AXISY:"))
End

Function/D AnnotationAxisZ(infoStr)		// Added in version 1.10
	String infoStr					// infoStr is the output from AnnotationInfo function

	return str2num(ExtractAIField(infoStr, "AXISZ:"))
End

Function/S AnnotationText(infoStr)	
	String infoStr					// infoStr is the output from AnnotationInfo function

	return ExtractAIField(infoStr, "TEXT:")
End
