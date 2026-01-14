# Plain Text File Text Encodings

Chapter III-16 — Text Encodings
III-466
Traditional Chinese
<Other text encodings>
Override Experiment
When you open an experiment, Western means MacRoman if the experiment was last saved on Macintosh 
and Windows-1252 if it was last saved on Windows. When you open a standalone file, Western means Mac-
Roman if you are running on Macintosh and Windows-1252 if you are running on Windows.
The remaining text encoding items, such as MacRoman, Windows-1252 and Japanese, specify the text 
encoding to use for conversions to UTF-8 without regard to the platform on which the file was last saved 
or on which you are currently running.
When opening an experiment saved in Igor6.3x or later, Igor normally uses the text encoding information 
in the experiment file. As explained above under Text Encoding Misidentification Problems on page 
III-463, occasionally this information will be wrong. The Override Experiment item gives you a way to force 
Igor to use your selected text encoding even when opening experiments that contain text encoding infor-
mation.
When Igor first runs it sets the default text encoding to Western or Japanese based on your system locale. 
This will give the right behavior when opening Igor6 experiments in most cases. Igor stores the default text 
encoding in preferences so when your launch Igor again it is restored.
For normal operation, leave the default text encoding setting on Western if you use a Western language or 
on the appropriate Asian language if you use an Asian language and leave Override Experiment 
unchecked.
Change these only if a problem arises. For example, if you are running an English system but you are 
opening a file containing Japanese, or if you are running a Japanese system but you are opening a file con-
taining non-ASCII western text, you may get incorrect text or errors. To fix this, change the settings in this 
menu and reload the file. After loading the problematic file, reset the menu items for normal operation.
Igor sets the Override Experiment setting to unchecked each time Igor is launched since this is less likely to 
result in undetected erroneous text conversion than if you turned it on and unintentionally left it turned on.
In addition to affecting text encoding conversion during the loading of files, the default text encoding 
setting is used as follows:
•
When you choose New Experiment, it determines the text encoding of the history area and built-in 
procedure window. This determines the text encoding used for these items when the experiment is 
saved to disk.
•
When you create a new procedure or notebook window, if a text encoding was not explicitly spec-
ified, it determines the text encoding used when the file is saved to disk.
•
When you insert text into an existing document using EditInsert File, it determines the source 
text encoding for conversion to UTF-8.
•
When Igor loads a wave, it determines the source text encoding for conversion to UTF-8 if the 
source text encoding is not otherwise specified. This will be the case for waves created before Ig-
or6.3x.
•
When the help browser searches procedure files, notebook files and help files, it determines the 
source text encoding for conversion to UTF-8 if it is not otherwise known.
Plain Text File Text Encodings
Plain text files include procedure files, plain text notebook files, the built-in procedure window text and 
history text. Igor uses UTF-8 when writing new instances of these items.
When reading existing files, Igor must convert text that it reads from plain text files to UTF-8 for storage in 
memory. In order to do this, it needs to know what text encoding to convert from. Most plain text files
