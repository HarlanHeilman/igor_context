# DefaultTextEncoding

DefaultTextEncoding
V-151
DefaultTextEncoding
DefaultTextEncoding [encoding=textEncoding, overrideDefault=override]
The DefaultTextEncoding operation programmatically changes the default text encoding and experiment 
text encoding override settings. These settings, which are discussed under The Default Text Encoding on 
page III-465, are also accessible via the MiscText EncodingDefault Text Encoding menu.
DefaultTextEncoding is rarely needed because typically you will change the default text encoding 
manually using the menu, if at all.
The DefaultTextEncoding operation was added in Igor Pro 7.00.
Parameters
All parameters are optional. If none are specified, no action is taken, but the output variables are still set.
Details
The default text encoding affects Igor’s behavior when opening a file whose text encoding is unknown. See 
The Default Text Encoding on page III-465 for details.
The experiment text encoding affects how files are loaded during experiment loading only. The override 
setting allows you to override the experiment text encoding stored in the experiment file. Normally you will 
not need to do this. See The Default Text Encoding on page III-465 for further discussion.
You may occasionally find it necessary to change the default text encoding because an Igor operation lacks 
a /ENCG flag that allows you to specify the text encoding and instead uses the current default text encoding. 
In such cases it is a good idea to save the original default text encoding, change it as necessary, and then 
change it back to the original text encoding. The example below demonstrates this technique.
Output Variables
DefaultTextEncoding sets the following output variables to indicate the settings that are in effect after the 
command executes: 
Example
Function DemoDefaultTextEncoding()
// Store the original default text encoding
DefaultTextEncoding
Variable originalTextEncoding = V_defaultTextEncoding
// Set new default text encoding
DefaultTextEncoding encoding = 3
// 3= Windows-1252
[ Do something that depends on the default text encoding ]
// Restore the original default text encoding
DefaultTextEncoding encoding = originalTextEncoding
End
encoding=textEncoding
textEncoding specifies the new default text encoding. See Text Encoding Names and 
Codes on page III-490 for a list of codes.
Pass 0 to set the default text encoding to the equivalent of selecting "Western" from 
the Default Text Encoding submenu.
The value 255, corresponding to the binary text encoding type, is treated as an invalid 
value for the textEncoding parameter.
overrideDefault=override
Turns overriding of the experiment's text encoding off or on.
0: Turns override off
1: Turns override on
V_defaultTextEncoding
A text encoding code.
V_overrideExperiment
A value of zero means the setting is off, nonzero means the setting is on.
