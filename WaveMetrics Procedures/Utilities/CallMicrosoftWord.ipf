#pragma rtGlobals=1		// Use modern global access method.

// This file illustrates a method for calling Word from Igor. It works on Microsoft Windows only.
// As of Igor Pro 5, Igor can not be an Automation client so you can't call Word directly.
// Therefore, we call word by creating a Visual Basic Script (VBS) file and then submitting it to the OS for execution.
// The VBS file contains a program to control Word.
//
// See the DemoCallWord() function below for an example that creates a new document in Word,
// adds some text to it and then adds a graph. Word must already be running.
//
// For a Macintosh example, see "Igor Pro Folder:Miscellaneous:AppleScript:SendGraphToMSWordMac.ipf".

// HR, 070824: Removed ".ShapeRange.ConvertToInlineShape". See note below. 

Menu "Macros"
	"Demonstrate Calling Already-Running Word", DemoCallWord()
End

// GetNextParagraph(startPos, text, paragraphText, needReturn)
//	This picks one paragraph out of a string that might contain many.
static Function GetNextParagraph(startPos, text, paragraphText, needReturn)
	Variable startPos					// Offset into text to start of next paragraph.
	String text						// One or more paragraphs' worth of text.
	String &paragraphText				// Output: The text for the next paragraph.
	Variable &needReturn				// Output: True if we need a return after the paragraph text.
	
	Variable len, pos, thisCharCode
	String thisChar
	
	paragraphText = ""
	needReturn = 0

	len = strlen(text)
	if (startPos >= len)
		return -1								// Signifies all done
	endif

	pos = 0
	for (pos=startPos; pos<len; pos+=1)
		thisChar = text[pos]
		thisCharCode = char2num(thisChar)
		if (thisCharCode == 13)					// CR?
			needReturn = 1
			pos += 1							// Skip CR.
			if (pos < len)
				thisChar = text[pos]
				thisCharCode = char2num(thisChar)
				if (thisCharCode == 10)			// LF following CR?
					pos += 1					// Skip LF too.
					break
				endif
			endif
			break
		endif
		if (thisCharCode==10)					// LF?
			needReturn = 1
			pos += 1							// Skip LF.
			break
		endif
		paragraphText += thisChar
	endfor
	
	return pos						// Start here next time.
End

// ExecuteWindowsScriptHostText(scriptText, fileName, waitTime)
//	Calls Windows Script Host (WScript.exe) to execute the specified script text.
Function ExecuteWindowsScriptHostText(scriptText, fileName, waitTime)
	String scriptText
	String fileName					// Name to use for a temporary file to hold the script.
	Variable waitTime					// Max number of seconds to wait for script to finish.

	String quote = "\""					// A double-quote character
	
	// HR, 2012-06-20, 6.30B01: This used to write to the Igor Pro folder but Windows no longer allows that.
	String dirPath = SpecialDirPath("Igor Pro User Files", 0, 0, 0)
	String filePath = dirPath + fileName
	
	// Create a .vbs (Visual Basic Script) file to hold the script text
	Variable refNum
	Open refNum as filePath
	FBinWrite refNum, scriptText
	Close refNum
	
	// Make WScript.exe execute the script file
	String cmd			// This is the command that we will send to the Windows OS using ExecuteScriptText.
	PathInfo Igor			// Sets S_path
	filePath = ParseFilePath(5, filePath, "*", 0, 0)		// Convert to Windows path.
	cmd = "WScript.exe " + quote + filePath + quote
	ExecuteScriptText/W=(waitTime) cmd				// /W=60 means wait up to 60 seconds for script to finish.
	
	// Delete the temporary script file.
	DeleteFile filePath
End

// TestWindowsScriptHost()
// For testing Windows Script Host independent of Microsoft Word.
// It should display a dialog saying "Hello World".
Function TestWindowsScriptHost()
	String CRLF = "\r\n"		// Line terminator

	String scriptText = "WScript.Echo \"Hello World\"" + CRLF
	scriptText += "WScript.Quit" + CRLF
	
	ExecuteWindowsScriptHostText(scriptText, "Test Windows Script Host.vbs", 10)
End

// SendTextToWord(text)
//	Inserts the specified text into the currently active Word document.
//	Word is assumed to be running with the targeted Word document open and active.
//
//	text is a string containing zero or more paragraphs of text. "Paragraph" means all
//	of the characters up to a CR, LF or CRLF.
//
//	The point of this function is to demonstrate how to drive a program (like Word) that
//	supports ActiveX Automation.
Function SendTextToWord(text)
	String text
	
	String CRLF = "\r\n"		// Line terminator
	String quote = "\""			// A double-quote character
	
	String scriptText = ""		// This will hold the Visual Basic script text that we will write to a file and then execute.
	
	String paragraphText		// Text for one paragraph
	Variable needReturn
	Variable pos1 = 0, pos2
	
	// Start generation of script text
	
		// Connect to already running Word
		scriptText += "Dim WordApp" + CRLF
		scriptText += "Set WordApp = GetObject(, \"Word.Application\")" + CRLF
	
		// Insert text at selection
		scriptText += "With WordApp.Selection" + CRLF
			// This generates a TypeText method call for each paragraph in the input text.
			do
				pos2 = GetNextParagraph(pos1, text, paragraphText, needReturn)

				if (pos2 < 0)
					break			// No more paragraphs to add.
				endif
				
				scriptText += "\t.TypeText " + quote + paragraphText + quote + CRLF
				if (needReturn)
					scriptText += "\t.TypeParagraph" + CRLF
				endif
				
				pos1 = pos2
			while (1)
		scriptText += "End With" + CRLF
		
	// End generation of script text

	String scriptFileName = "TempWindowsScriptHostScript.vbs"
	ExecuteWindowsScriptHostText(scriptText, scriptFileName, 60)
End

// SendGraphToWord(graphName, exportType, width, height)
//	Inserts a graphic of the specified graph into the currently active Word document.
//	Word is assumed to be running with the targeted Word document open and active.
//
//	Example: SendGraphToWord("Graph0", -2, 5*72, 4*72)
//
//	The point of this function is to demonstrate how to drive a program (like Word) that
//	supports ActiveX Automation.
Function SendGraphToWord(graphName, exportType, width, height)
	String graphName
	Variable exportType		// Used with SavePICT /E flag. Typically -2 for EMF.
	Variable width			// Exported graph width in points (72 points/inch)
	Variable height			// Exported graph height in points (72 points/inch)
	
	String CRLF = "\r\n"		// Line terminator
	
	String scriptText = ""		// This will hold the Visual Basic script text that we will write to a file and then execute.
	
	// Generate picture of graph and put it in the clipboard.
	if (width==0 || height==0)	// Want default size?
		SavePICT/O/WIN=$graphName/E=(exportType) as "Clipboard"
	else
		SavePICT/O/WIN=$graphName/E=(exportType)/W=(0,0,width,height) as "Clipboard"
	endif
	
	// Start generation of script text
	
		// Connect to already running Word
		scriptText += "Dim WordApp" + CRLF
		scriptText += "Set WordApp = GetObject(, \"Word.Application\")" + CRLF
	
		// Insert text at selection
		scriptText += "With WordApp.Selection" + CRLF
			String wordCmd
		
		//	VBScript does not seem to work with keyword:=value parameters as in  ".PasteSpecial dataType:=wdPasteEnhancedMetafile, placement:=wdInLine"
		//	VBScript does not recognize wdPasteEnhancedMetafile (a Word enum representing the number 9)
			wordCmd = ".PasteSpecial 0, False, wdInLine, False, 9"
			scriptText += "\t" + wordCmd  + CRLF

		// HR, 070824: For some reason, this makes Windows Script Host crash.
		//	At one time it was necessary but now does not seem to be necessary
		// as the picture layout property appears to be inline by default,
		// at least with my Word 2000 version today.
		//	wordCmd = ".ShapeRange.ConvertToInlineShape"
		//	scriptText += "\t" + wordCmd  + CRLF
			
		//	wordCmd = ".MoveRight Unit:=wdCharacter, Count:=1"	// Position caret after inserted graphic.
			wordCmd = ".MoveRight 1, 1"						// Position caret after inserted graphic.
			scriptText += "\t" + wordCmd  + CRLF

		scriptText += "End With" + CRLF
		
	// End generation of script text

	String scriptFileName = "TempWindowsScriptHostScript.vbs"
	ExecuteWindowsScriptHostText(scriptText, scriptFileName, 60)
End

// SendCommandsToWord(commands)
//	Sends Visual Basic commands to be executed by Word.
//	Word is assumed to be running with the targeted Word document open and active.
//
//	Each command line for Word must be separated by CRLF.
//
//	This function prepends some text that connects to the already-running Word application
//	and defines "WordApp" as an object representing Word.
//
//	Example: SendCommandsToWord("WordApp.Documents.Add")
//
//	The point of this function is to demonstrate how to drive a program (like Word) that
//	supports ActiveX Automation.
Function SendCommandsToWord(commands)
	String commands			// One or more commands separated by CRLF
	
	String CRLF = "\r\n"		// Line terminator
	
	String preamble = ""
	
	// Connect to already running Word
	preamble += "Dim WordApp" + CRLF
	preamble += "Set WordApp = GetObject(, \"Word.Application\")" + CRLF
	
	String scriptFileName = "TempWindowsScriptHostScript.vbs"
	ExecuteWindowsScriptHostText(preamble + commands, scriptFileName, 60)
End

// DemoCallWord()
//	Creates a new document and puts some text and graphics in it.
//	Word is assumed to be already running.
Function DemoCallWord()
	String CRLF = "\r\n"		// Line terminator
	
	// Create new document in already-running Word.
	String commands = ""
	commands += "WordApp.Documents.Add" + CRLF
	SendCommandsToWord(commands)
	
	// Add some text.
	String text = "This is a graph from Igor Pro:" + CRLF
	SendTextToWord(text)
	
	// Add a graph.
	DoWindow DemoGraph				// Test if graph exists.
	if (V_flag == 0)
		Make/O demoWave = sin(x/8)
		Display demoWave
		DoWindow/C DemoGraph
	endif
	SendGraphToWord("DemoGraph", -2, 0, 0)
	
	// Add a paragraph after the graph.
	SendTextToWord(CRLF)
End
