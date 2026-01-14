# Slow

SliderControl
V-877
See WMSliderAction for details on the WMSliderAction structure.
See Handling Slider Events on page III-430 for a demonstration of slider event handling.
Although the return value is not currently used, action procedures should always return zero.
This old format for a slider action procedure should not be used in new code:
Function MySliderProc(name, value, event) : SliderControl
String name
// name of this slider control
Variable value
// value of slider
Variable event
// bit field:bit 0:value set; 1:mouse down,
// 2:mouse up, 3:mouse moved
return 0
// other return values reserved
End
Repeating Sliders
A repeating slider calls your action procedure periodically while the user is clicking the thumb. See 
Repeating Sliders on page III-418 for an overview.
When the repeat style is set to 2, the call rate is proportional to the slider value. See the Slider reference 
documentation in the online help for the formula.
Whereas the rate can be set as high as 1000 calls per second, if your action procedure takes more time to 
execute than the period of the slider repeat, you will simply lose repeats. It is unlikely that a rate of more 
than about 50 calls per second can realistically be achieved.
Examples
Function SliderExample()
NewPanel /W=(150,50,501,285)
Variable/G var1
Execute "ModifyPanel cbRGB=(56797,56797,56797)"
SetVariable setvar0,pos={141,18},size={122,17},limits={-Inf,Inf,1},value=var1
Slider foo,pos={26,31},size={62,143},limits={-5,10,1},variable=var1
Slider foo2,pos={173,161},size={150,53}
Slider foo2,limits={-5,10,1},variable=var1,vert=0,thumbColor=(0,1000,0)
Slider foo3,pos={80,31},size={62,143}
Slider foo3,limits={-5,10,1},variable=var1,side=2,thumbColor=(1000,1000,0)
Slider foo4,pos={173,59},size={150,13}
Slider foo4,limits={-5,10,1},variable=var1,side=0,vert=0
Slider foo4,thumbColor=(1000,1000,1000)
Slider foo5,pos={173,90},size={150,53}
Slider foo5,limits={-5,10,1},variable= var1,side=2,vert=0
Slider foo5,ticks=5,thumbColor=(500,1000,1000)
End
See Also
Chapter III-14, Controls and Control Panels, Handling Slider Events on page III-430
ControlInfo, GetUserData
Demos
Choose FileExample ExperimentsFeature Demos 2Slider Labels.
Choose FileExample ExperimentsFeature Demos 2Slider Repeat Demo.
SliderControl 
SliderControl
SliderControl is a procedure subtype keyword that identifies a macro or function as being an action 
procedure for a user-defined slider control. See Procedure Subtypes on page IV-204 for details. See Slider 
for details on creating a slider control.
Slow 
Slow ticks
The Slow operation is obsolete. Prior to Igor Pro 7 it slowed down execution of macros for debugging 
purposes. It now does nothing.
