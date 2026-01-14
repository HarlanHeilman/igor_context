# The Strings Tab

Chapter III-16 — Text Encodings
III-487
Status: After you click the Convert Waves button, this column shows the outcome of the conversion - if the 
conversion succeeded or if there was an error.
You can double-click a cell to display a modal Data Browser dialog for closer inspection of a wave.
Select one or more cells in the list and click Edit Waves to close the dialog and display a table showing those 
waves. If you click Edit Waves when no cells are selected in the list, all of the waves are displayed in the 
table.
Two checkboxes under the list of waves control whether waves requiring non-trivial changes and trivial 
changes are displayed in the list.
Waves containing non-ASCII text using a text encoding other than UTF-8 are deemed to require a non-
trivial change. Also, text waves in which the text data content appears to contain binary data but which are 
not yet marked as binary are deemed to require a non-trivial change.
Waves containing ASCII text only but which are marked as using a non-UTF-8 text encoding are deemed 
to require a trivial change. Because the text is ASCII only, and because ASCII text is the same in all text 
encodings used in Igor waves, no actual text conversion is required. The wave elements just need to be 
marked as UTF-8.
You may find it convenient to convert the waves requiring trivial changes only first to get them out of the 
way so that you can focus on those that require non-trivial conversion.
Two checkboxes under the list of waves control whether home waves and shared waves are displayed in 
the list. Converting shared waves increases the possiblity that the conversion may adversely affect other 
experiment but this is usually a concern only if you need Igor6 compatibility.
Below the checkboxes, Igor displays an explanation of what waves need conversion.
If no items in the list are selected, clicking the Convert Waves button converts all of the waves in the list. 
The Status column then indicates if the conversion succeeded or failed.
If items are selected in the list, the Convert Waves button changes to Convert Selected Waves. Clicking the 
button converts the selected waves only.
After doing a conversion, the Convert Waves button changes to Refresh. Clicking Refresh refreshes the list, 
showing waves remaining to be converted, if any.
The Strings Tab
The Strings tab lists the global string variables in the experiment and allows you to convert those that need 
conversion.
As described under String Variable Text Encodings on page III-478, unlike waves, there is no text encoding 
setting for string variables. Consequently Igor treats each string variable as if it contains UTF-8 text when 
printing it to the history area or when displaying it in an annotation or control panel or otherwise treating 
it as text.
If a string was created in Igor6 or before and contains non-ASCII characters, treating it as UTF-8 results in 
incorrect characters being displayed. The Strings tab allows you to fix this by converting such strings to 
UTF-8.
The following types of strings do not need to be converted:
•
Strings containing only ASCII characters
•
Strings that are already valid as UTF-8
•
Strings that appear contain binary data (typically created by procedure packages)
This leaves non-ASCII, non-binary strings that are not valid as UTF-8 to be converted.

Chapter III-16 — Text Encodings
III-488
To convert text to UTF-8, Igor needs to know the text encoding in effect when the text was entered. For 
string variables created in Igor7 and later, this will be UTF-8, and such string variables require no conver-
sion. String variables created in Igor6 or before typically use MacRoman, Windows-1252, or Shift JIS (Japa-
nese) text encodings and require conversion if they contain non-ASCII text.
An experiment may contain a combination of non-UTF-8 strings and UTF-8 strings. This happens if you 
create non-ASCII strings in Igor6 or before and then create more non-ASCII strings in the same experiment 
in Igor7 or later.
Since string variables have no text encoding settings, there is no way for Igor to know what text encoding 
was used to create them. Instead, in the Strings tab of the dialog, Igor uses the text encoding selected in the 
pop-up menu below the list of strings. When you enter the dialog, the pop-up menu is set to the text encod-
ing governing the experiment, if it is known. As described below, you may need to choose a different text 
encoding from the pop-up menu.
The list in the Strings tab comprises three columns:
String: Lists the full data folder path to the string variable.
Contents: Shows the contents of the string variable.
The contents of strings that need to be converted are displayed assuming that their text was entered using 
the text encoding selected in the pop-up menu. If the displayed contents appear incorrect then you probably 
need to select another text encoding.
Strings that appear to contain binary are not converted and are displayed using hex escape codes for bytes 
that don't appear in normal ASCII text, such as "\x00" to represent a null byte.
Strings that are already valid as UTF-8, which includes ASCII strings since ASCII is a subset of UTF-8, also 
do not need to be converted and are displayed as UTF-8.
Status: The Status column displays the following:
Two checkboxes under the list of strings control whether strings that require conversion or do not require 
conversion are displayed in the list.
Strings that contain non-ASCII text that is not valid as UTF-8 and which do not appear to contain binary 
data need to be converted to UTF-8. Such strings appear in the list when the Show Strings That Need to be 
Converted checkbox is checked.
Strings that that appear to contain binary data, are all ASCII, or contain non-ASCII text that is already valid 
as UTF-8 do not need to be converted to UTF-8. Such strings appear in the list when the Show Strings That 
Do Not Need to be Converted checkbox is checked. You may want to display these strings to verify that 
their contents looks right.
Can be converted
The string can be converted to UTF-8 using the text encoding selected in the 
popup menu. The string will be converted when you click the Convert Strings 
button if it is selected or if no strings are selected.
Converted to UTF-8
The string was converted to UTF-8 using the text encoding selected in the popup 
menu. This appears after you click the Convert Strings button.
<An error message>
The string needs to be converted but can not be converted using the text encoding 
selected in the popup menu.
ASCII
The string is plain ASCII and does not need to be converted.
Valid non-ASCII UTF-8
The string contains non-ASCII text that is valid as UTF-8 and does not need to be 
converted.
Binary detected
The string appears to contain binary data and will not be converted.
