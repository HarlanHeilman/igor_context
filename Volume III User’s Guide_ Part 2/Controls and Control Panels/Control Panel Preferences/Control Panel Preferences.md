# Control Panel Preferences

Chapter III-14 — Controls and Control Panels
III-445
applies the expansion factor. The result is that the top/left corner of Panel2 is the same as Panel1 but Panel2 
is twice as wide and twice as tall. We wind up with width=200 and height=100 in both cases but, because of 
panel expansion, Panel2 is twice as large as Panel1.
The left, top, right, and bottom parameters are in normal panel units but NewPanel interprets the internally 
computed width and height as control panel units (i.e., normal units to which control panel expansion is to 
be applied).
If you use /I (inches) or /M (centimeters) before /W then the interpretation of the parameters is different. 
They are converted from inches or centimeters to points and the result is treated as points, as with the 
Display operation.
Interpretation of Control Operation Coordinates
Now we consider the pos={left,top} and size={width,height} keywords of control operations like Button and 
TitleBox.
All of these parameters are treated as control panel units. This means that they are first treatedas points or 
pixels as described above and then the expansion factor of the targeted panel, if other than 1.0, is applied.
Consider these examples which use Panel1 and Panel2 from the preceding section:
AutopositionWindow /R=Panel1 Panel2
// Make panels side-by-side
Button button0 win=Panel1, pos={100,50}, size={100,20}, title="Button"
Button button0 win=Panel2, pos={100,50}, size={100,20}, title="Button"
We created buttons that are one-half the width of the panel and with the top/left corner of the button one-
half of the way from the top to the bottom and one-half of the way from the left to the right. We did this 
using the same parameters in both cases. This gives different results because the Button operation interprets 
the parameters as being expressed in control panel units.
Interpretation of Drawing Coordinates
When you use drawing tools and drawing operations in control panels, coordinates are interpreted as 
control panel units the same as for control operations such as Button.
See also Control Panel Resolution on Windows on page III-456, ScreenResolution on page V-832, Panel-
Resolution on page V-732
Control Panel Preferences
Control panel preferences allow you to control what happens when you create a new control panel. To set 
preferences, create a panel and set it up to your taste. We call this your prototype panel. Then choose 
Capture Panel Prefs from the Panel menu.
Preferences are normally in effect only for manual operations, not for automatic operations from Igor pro-
cedures. This is discussed in more detail in Chapter III-18, Preferences.
When you initially install Igor, all preferences are set to the factory defaults. The dialog indicates which 
preferences you have changed.
The preferences affect the creation of new panels only.
Selecting the Show Tools category checkbox captures whether or not the drawing tools palette is initially 
shown or hidden when a new panel is created.
See also Control Panel Expansion on page III-443.
