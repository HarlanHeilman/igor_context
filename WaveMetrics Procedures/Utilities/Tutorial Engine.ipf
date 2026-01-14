#pragma version = 1.01		// Made suitable for Windows using TEBulletCharCode function.

// This file contains routines used by WaveMetrics to implement tutorial experiments.
// See the "X Scaling Tutorial" in the "Learning Aids" folder for an example.

#include <Strings as Lists>
#include <Keyword-Value>

Function TEInitGlobals()		// This is to auto-create and document globals used by the tutorial engine
	String saveDF = GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:TutorialEngine
	Variable/G gTETutorialState = 0						// 0 = waiting for next step, 1 = waiting to execute commands
	Variable/G gTETutorialParagraph = 0					// Used to keep track of where in tutorial we are
	String/G gTETutorialCmdText = ""						// Commands waiting to be executed
	String/G gTEControlCenter = "TE_ControlCenter"		// Name of control center window
	String/G gTETutorialData = "TE_TutorialData"		// Name of notebook containing tutorial data
	String/G gTETutorialCmdText = ""						// Command to be executed when user presses Next button.
	SetDataFolder saveDF
End

Function/S TEBulletCharCode()
	Variable charCode
	
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		charCode =  0xA5			// Character code for bullet on Mac.
	else
		charCode =  0x95			// Character code for bullet on Windows.
	endif
	return num2char(charCode)
End

// The client experiment must supply the following routines:
//	TEClientStartOver

Function TESetupTutorial()				// Called when client experiment is loaded to do some initialization
	NVAR/Z gTETutorialState = root:Packages:TutorialEngine:gTETutorialState
	if (!NVar_Exists(gTETutorialState))
		TEInitGlobals()
	endif
End

Function/S TESplitParagraphUp(in, charsPerLine)
	String in							// input text
	Variable charsPerLine				// desired approximate chars per line
	
	Variable totalLen
	Variable i
	Variable lineLen
	String ch
	String out = ""
	
	totalLen = strlen(in)
	i = 0
	lineLen = 0
	do
		ch = in[i] 
		if ((lineLen >= charsPerLine) %& (cmpstr(ch, " ")==0))
			out += "\r"
			lineLen = 0
		else
			out += ch
			lineLen += 1
		endif
		i += 1
	while (i < totalLen)
	
	return out
End

Function TESetHeading(text)
	String text
	
	Textbox/C/N=heading "\\Z12\\f01" + text
End

Function TESetMessage(text)
	String text
	
	Textbox/C/N=message "\\Z10" + text
End

Function TESetCommand(text)
	String text
	
	Textbox/C/N=command "\\Z09\\F'Monaco'" + text
End

Function TESetTutorialState(state)
	Variable state
	
	NVAR gTETutorialState = root:Packages:TutorialEngine:gTETutorialState
	gTETutorialState = state
	
	if (state == 0)			// normal
		TESetCommand("")
		Button NextStep title="Next Step"
	endif
	
	if (state == 1)			// waiting to execute a command
		Button NextStep title="Execute"
	endif
End

Function TEExecuteCommandList(commands)
	String commands
	
	String cmd
	Variable i
	
	i = 0
	do
		cmd = GetStrFromList(commands, i, "\r")
		if (strlen(cmd) == 0)
			break
		endif
		Printf "%s\t%s\r", TEBulletCharCode(), cmd
		Execute cmd
		i += 1
	while (1)
End

Function TENextStep(ctrlName) : ButtonControl
	String ctrlName
	
	Variable p
	Variable isRegularMessage, isHiddenCommand, isImmediateCommand
	Variable calledFromTEGoToSection
	Variable selectionLength
	String message, command
	String bulletStr = TEBulletCharCode()
	String temp
	
	calledFromTEGoToSection = cmpstr(ctrlName, "TEGoToSection") == 0
	
	SVAR gTEControlCenter = root:Packages:TutorialEngine:gTEControlCenter
	DoWindow/F $gTEControlCenter

	NVAR gTETutorialParagraph = root:Packages:TutorialEngine:gTETutorialParagraph
	p = gTETutorialParagraph
	
	NVAR gTETutorialState = root:Packages:TutorialEngine:gTETutorialState
	SVAR gTETutorialCmdText = root:Packages:TutorialEngine:gTETutorialCmdText
	if (gTETutorialState == 1)		// waiting to execute a command ?
		TEExecuteCommandList(gTETutorialCmdText)
		gTETutorialCmdText = ""
		TESetCommand("")
		TESetMessage("")
		TESetTutorialState(0)		// back to normal state
	endif
	
	message = ""; command = ""
	SVAR gTETutorialData = root:Packages:TutorialEngine:gTETutorialData
	do
		p += 1
		Notebook $gTETutorialData selection={(p,0), (p,0)}, selection={startOfParagraph, endOfChars}
		Notebook $gTETutorialData findText = {"", 1}		// for debugging, scroll selected text into view
		
		GetSelection notebook, $gTETutorialData, 3
		if (V_startParagraph != p)
			Beep; DoAlert 1, "This is the end of the tutorial. Do you want to start again?"
			if (V_flag == 1)
				TEClientStartOver("TENextStep")	// Client must supply the TEClientStartOver routine
				p = gTETutorialParagraph
			else
				p = V_startParagraph
			endif
			break
		else
			isRegularMessage = 1									// assume this is regular message
			isImmediateCommand = 0
			isHiddenCommand = 0
			selectionLength = strlen(S_selection)
			if (selectionLength > 0)
				if (cmpstr(S_selection[0], "*")==0)			// Is this a section heading?
					temp = S_selection[2, selectionLength]		// skip * and tab
					TESetHeading(temp)
					TESetMessage("")
					isRegularMessage = 0
				endif

				if (cmpstr(S_selection[0], bulletStr)==0)	// Is this an executable command?
					isRegularMessage = 0
					isImmediateCommand = cmpstr(S_selection[1, 1], "=")==0
					if (isImmediateCommand)
						Execute S_selection[2,  selectionLength]
					else
						isHiddenCommand = cmpstr(S_selection[1, 1], bulletStr)==0	// True if command should not be added to textbox.
						if (strlen(gTETutorialCmdText))		// adding a new paragraph to command ?
							gTETutorialCmdText += "\r"
						endif
						if (!isHiddenCommand)
							if (strlen(command))				// adding a new paragraph to command ?
								command += "\r"
							endif
						endif
						temp = S_selection[2,  selectionLength]	// skip bullet and tab
						gTETutorialCmdText += temp				// add to commands to be executed
						if (!isHiddenCommand)
							command += temp						// add to commands to be displayed
						endif
					endif
				endif

				if (cmpstr(S_selection[0], "-")==0)			// Is this the end of a step?
					if (!calledFromTEGoToSection)
						TESetMessage(message)
						TESetCommand(command)
					endif
					if (strlen(gTETutorialCmdText))
						TESetTutorialState(1)					// waiting to execute a command
					else
						TESetTutorialState(0)					// waiting for next step
					endif
					break
				endif
				
				if (isRegularMessage)
					if (strlen(message))		// adding a new paragraph to message ?
						message += "\r"
					endif
					temp = TESplitParagraphUp(S_selection, 90)
					message += temp
				endif
			endif
		endif
	while (1)						// continue till non-empty paragraph

	gTETutorialParagraph = p
End

Function TEPrevStep(ctrlName) : ButtonControl
	String ctrlName

	Variable p
	Variable countDown = 2
	
	NVAR gTETutorialParagraph = root:Packages:TutorialEngine:gTETutorialParagraph
	SVAR gTETutorialData = root:Packages:TutorialEngine:gTETutorialData
	p = gTETutorialParagraph
	do
		p -= 1
		if (p <= 0)
			p = -1
			break
		endif
		Notebook $gTETutorialData selection={(p, 0), (p, 2)}
		GetSelection notebook, $gTETutorialData, 2
		if (cmpstr(S_selection, "--") == 0)
			countDown -= 1
		endif
	while (countDown)
	gTETutorialParagraph = p
	TESetTutorialState(0)					// normal state
	TENextStep("TEPrevStep")
End

Function TEStartOver(nameOfCallingRoutine)
	String nameOfCallingRoutine
	
	SVAR gTEControlCenter = root:Packages:TutorialEngine:gTEControlCenter
	DoWindow/F $gTEControlCenter
	NVAR gTETutorialParagraph = root:Packages:TutorialEngine:gTETutorialParagraph
	gTETutorialParagraph = -1
	SVAR gTETutorialCmdText = root:Packages:TutorialEngine:gTETutorialCmdText
	gTETutorialCmdText = ""
	TESetTutorialState(0)				// normal state
	if (cmpstr(nameOfCallingRoutine, "TEGoToSection") != 0)
		TENextStep("TEStartOver")
	endif
End

Function TEKillClientWindows(winTypesMask)
	Variable winTypesMask
	
	String win
	Variable index = 0
	
	do
		win = WinName(index,winTypesMask)
		if (strlen(win) == 0)
			break
		endif
		if (CmpStr(win[0,2], "TE_") == 0)	// protected TE window ?
			index += 1							// skip this window
		else
			DoWindow/K $win
		endif
	while (1)
End

Function TEGoToSection(section)
	String section
	
	String temp
	
	TEClientStartOver("TEGoToSection")	// Client must supply the TEClientStartOver routine
	SVAR gTEControlCenter = root:Packages:TutorialEngine:gTEControlCenter
	do
		TENextStep("TEGoToSection")
		temp = StrByKey("TEXT", AnnotationInfo(gTEControlCenter, "heading"))
		if (StrSearch(temp, section, 0) != -1)
			break
		endif
	while (1)
End

Function/S TESectionList()
	String list
	Variable pos1=0, pos2
	
	list = ""
	SVAR gTETutorialData = root:Packages:TutorialEngine:gTETutorialData
	Notebook $gTETutorialData selection={startOfFile, endOfFile}
	GetSelection notebook, $gTETutorialData, 3		// all text is now in S_selection
	do
		pos1 = strsearch(S_selection, "*\t", pos1)
		if (pos1 == -1)
			break
		endif
		pos2 = strsearch(S_selection, "\r", pos1)
		if (pos2 == -1)
			break
		endif
		list += S_selection[pos1+2, pos2-1] + ";"
		pos1 = pos2 + 1
	while (1)
	
	return list
End

Proc TEDoGoToSection(section)
	String section
	Prompt section, "Select section", popup TESectionList()
	
	TEGoToSection(section)
End
