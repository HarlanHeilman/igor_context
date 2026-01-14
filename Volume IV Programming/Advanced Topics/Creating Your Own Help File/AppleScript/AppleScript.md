# AppleScript

Chapter IV-10 — Advanced Topics
IV-263
To specify a window, use object class cWindow ('cwin') and either formAbsolutePosition or formName 
with name=title of window.
AppleScript
This topic is of interest to Macintosh programmers. For Windows, see ActiveX Automation on page IV-265.
Event
Class
Code
Action
Open 
Application
'aevt'
'oapp'
Basically a nop; don’t use.
Open 
Document
'aevt'
'odoc'
Loads an experiment. Direct object is assumed to be 
coercible to a File System Spec record.
Print 
Document
'aevt'
'pdoc'
NA; don’t use.
Quit 
Application
'aevt'
'quit'
Quits the program. If the experiment was modified, then 
Igor attempts to interact with the user to get save/no save 
directions. If interaction is not allowed, then an error is 
returned and nothing is done.
To prevent errors, send the close event with appropriate 
save options prior to sending quit.
Close
'core'
'clos'
Acts on an experiment or window.
For a window, the save/no save/ask optional parameter 
(keyAESaveOptions) is allowed and refers to 
making/replacing a recreation macro.
For a document (experiment), keyAESaveOptions is 
allowed and an additional optional parameter 
keyAEDestination may be used to specify where to save 
(must be coercible to a FSS). If this is not given and the 
experiment is untitled and if an attempt to interact with the 
user fails then the experiment is not saved and an error 
(such as errAENoUserInteraction) is returned.
Note that if the optional destination is given then the save 
options are ignored (why give a destination and then say no 
save?).
Save
'core'
'save'
Acts on experiment only.
Takes same optional destination parameters as Close. A 
save with a destination is the same as a Save as.
Do Script
'misc'
'dosc'
Same as Eval Expression.
Eval 
Expression
'aevt'
'eval'
Executes commands. Acts just as if commands had been 
typed into the command line except the individual 
command lines are preceded by a percent symbol rather 
than the usual bullet symbol. Also, errors are returned in the 
error reply parameter of the event rather than putting up a 
dialog.
Note: You can suppress history logging by executing the 
command, “Silent 2”, and you can turn it back on by 
executing “Silent 3”.
Direct parameter must be text and not a file. Text can be of 
any length.
You can return a string containing results by using the 
fprintf command with a file reference number of zero.
