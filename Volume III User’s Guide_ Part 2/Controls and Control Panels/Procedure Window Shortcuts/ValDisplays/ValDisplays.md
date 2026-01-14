# ValDisplays

Chapter III-14 — Controls and Control Panels
III-418
Sliders 
Slider controls can be used to graphically select either discrete or contin-
uous values. When used to select discrete values, a slider is similar to a 
pop-up menu or a set of radio buttons. Sliders can be live, updating a 
variable or running a procedure as the user drags the slider, or they can 
be configured to wait until the user finishes before performing any action.
Repeating Sliders
Sliders can be configured to call your action procedure repeatedly while the user is clicking on the thumb. 
They can be configured to operate at a constant rate or at a rate proportional to the value, and optionally to 
spring back to a resting value when released. This feature was added in Igor Pro 8.00.
To implement a repeating slider, use the repeat keyword with the Slider operation. For a demonstration, 
see the Slider Repeat Demo demo experiment.
TabControl 
TabControls are used to create complex panels containing many more controls than would otherwise fit. 
When the user clicks on a tab, the programmers procedure runs and hides the previous set of controls while 
showing the new set.
TitleBox 
TitleBox controls are mainly decorative elements. They are used 
provide explanatory text in a control panel. They may also be 
used to display textual results. The text can be unchanging, or 
can be the contents of a global string variable. In either case, the 
user can’t inadvertently change the text.
ValDisplays 
ValDisplay controls display numeric or string values in a variety of forms ranging from a simple numeric 
readout to a thermometer bar. Regardless of the form, ValDisplays are just readouts. There is no interaction 
with the user. They display the current value of whatever expression the programmer specified. Often this 
will be just the value of a numeric variable, but it can be any numeric expression including calls to user-
defined functions and external functions.
