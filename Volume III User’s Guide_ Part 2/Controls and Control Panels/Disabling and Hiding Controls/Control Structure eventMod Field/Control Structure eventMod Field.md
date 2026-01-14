# Control Structure eventMod Field

Chapter III-14 — Controls and Control Panels
III-438
Function ControlStructureTest()
NewPanel
Button b0,proc= NewButtonProc
End
Structure MyButtonInfo
Int32 mousedown
Int32 isLeft
EndStructure
Function NewButtonProc(s)
STRUCT WMButtonAction &s
STRUCT MyButtonInfo bi
Variable biChanged= 0
StructGet/S bi,s.userdata
if( s.eventCode==1 )
bi.mousedown= 1
bi.isLeft= s.mouseLoc.h < (s.ctrlRect.left+s.ctrlRect.right)/2
biChanged= 1
elseif( s.eventCode==2 || s.eventCode==3 )
bi.mousedown= 0
biChanged= 1
elseif( s.eventCode==5 )
print "Enter button"
elseif( s.eventCode==6 )
print "Leave button"
endif
if( s.eventCode==4 )
// mousemoved
if( bi.mousedown )
if( bi.isLeft )
printf "L"
else
printf "R"
endif
else
printf "*"
endif
endif
if( biChanged )
StructPut/S bi,s.userdata
// written out to control
endif
return 0
End
Control Structure eventMod Field
The eventMod field appears in the built-in structure for each type of control. It is a bitfield defined as fol-
lows:
See Setting Bit Parameters on page IV-12 for details about bit settings.
EventMod Bit
Meaning
Bit 0
A mouse button is down.
Bit 1
Shift key is down.
Bit 2
Option (Macintosh ) or Alt (Windows ) is down.
Bit 3
Command (Macintosh ) or Ctrl (Windows ) is down.
Bit 4
Contextual menu click occurred.
