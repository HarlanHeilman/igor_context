# NewPath

NewPath
V-690
endif
break
endswitch
return 0
End
Window ExSwTest() : Graph
PauseUpdate; Silent 1
// building window...
Display /W=(803,377,1158,591)
Button bNewSW,pos={35,21},size={181,30},proc=bpNewExSw,title="Exterior Subwindow"
SetVariable svLeft,pos={118,82},size={96,15},title="left"
SetVariable svLeft,limits={0,100,1},value= epsizes[0],bodyWidth= 76
SetVariable svTop,pos={120,97},size={94,15},title="top"
SetVariable svTop,limits={0,100,1},value= epsizes[1],bodyWidth= 76
SetVariable svRight,pos={112,113},size={102,15},title="right"
SetVariable svRight,limits={0,100,1},value= epsizes[2],bodyWidth= 76
SetVariable svBottom,pos={103,129},size={111,15},title="bottom"
SetVariable svBottom,limits={0,100,1},value= epsizes[3],bodyWidth= 76
CheckBox ckUseRect,pos={70,62},size={61,14},title="Use Rect:",value= 0
PopupMenu popSide,pos={73,149},size={78,20},title="Side"
PopupMenu popSide,mode=1,popvalue="Right",value= #"\"Right;Left;Bottom;Top\""
CheckBox ckResizeable,pos={76,176},size={65,14},title="Resizeable",value= 0
EndMacro
Function test()
Make/O/N=4 epsizes=0
Execute "ExSwTest()"
End
After compiling the procedures, execute test() on the command line. You can now experiment with 
different sides and size values.
See Also
Chapter III-14, Controls and Control Panels, for details about control panels and controls.
Interpretation of NewPanel Coordinates on page III-444 for a discussion of the units used with NewPanel 
/W.
The ModifyPanel operation.
NewPath 
NewPath [flags] pathName [, pathToFolderStr]
The NewPath operation creates a new symbolic path name that can be used as a shortcut to refer to a folder 
on disk.
Parameters
pathToFolderStr is a string containing the path to the folder for which you want to make a symbolic path. 
pathToFolderStr can also point to an alias (Macintosh) or shortcut (Windows) for a folder.
If you use a full path for pathToFolderStr, see Path Separators on page III-451 for details on forming the path. 
If you use a partial path or just a simple name for pathToFolderStr, and you use the /C flag, a new folder is 
created relative to the Igor Pro folder. No dialog is presented.
If you omit pathToFolderStr, you get a chance to select a folder or create a new folder from a dialog.
Flags
Details
Symbolic paths help to isolate your experiments from specific file system paths that contain files created or 
used by Igor. By using a symbolic path, if the actual location or name of the folder changes, you won’t need 
/C
Create the folder specified by pathToFolderStr if it does not already exist.
/M=messageStr
Specifies the prompt message in the dialog.
/O
Overwrites the symbolic path if it exists.
/Q
Suppresses printing path information in the history.
/Z
Doesn’t generate an error if the folder does not exist.
