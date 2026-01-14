# The Default Text Encoding

Chapter III-16 — Text Encodings
III-465
Because an English font controls the built-in procedure window, Igor6.3x thinks that the text encoding for 
the procedure window is western (MacRoman or Windows-1252) and records this information in the exper-
iment.
When Igor7 or later opens this experiment, it must convert the procedure window text to UTF-8. Since the 
Igor6.3x recorded the file's text encoding as western (MacRoman or Windows-1252), Igor attempts to 
convert the text from western to UTF-8. You will wind up with gibberish western characters where the Jap-
anese text should be.
In this example Igor mistook Japanese text for western and the result was gibberish. If Igor mistakes 
western text for Japanese, you can either wind up with gibberish, or you may get an error, or you may see 
the Unicode replacement character (a white question mark on a black background) where the misidentified 
text was.
Fortunately this kind of problem is relatively rare. To fix it you need to manually repair the gibberish text.
The Experiment File Text Encoding
Experiments saved by Igor6.3x or later record the "experiment file text encoding". This is the text encoding 
used by the built-in procedure window at the time the experiment was saved. As explained below, Igor uses 
the experiment file text encoding as the source text encoding when converting a wave element to UTF-8 if 
the element's text encoding is unknown.
Prior to version 6.30 Igor did not record the experiment file text encoding so it defaults to unknown when 
a pre-Igor6.3x experiment is loaded into Igor7 or later. It also defaults to unknown when you first launch 
Igor and when you create a new experiment.
You can display the experiment file text encoding for the currently open experiment by right-clicking the 
status bar and choosing Show Experiment Info. Igor will display something like "Unknown / 6.22" or "Mac 
Roman / 6.36". The first item is the experiment file text encoding while the second is the version of Igor that 
saved the experiment file. This information is usually of interest only to experts investigating text encoding 
issues.
You can also see the experiment file text encoding by choosing FileExperiment Info.
The Default Text Encoding
Because it is not always possible for Igor to correctly determine a file's text encoding, it sometimes needs 
additional information. You supply this information through the Default Text Encoding submenu in the 
Text Encoding submenu in the Misc menu. Igor uses your selected default text encoding when it can not 
otherwise determine the text encoding of a file or wave.
You can display the default text encoding for the currently open experiment by right-clicking the status bar 
and choosing Show Default Text Encoding. Displaying this information in the status bar is usually of inter-
est only to experts investigating text encoding issues.
Igor experiment files record the platform (Macintosh or Windows) on which they were last saved. In 
Igor6.3x and later, Igor records text encoding information for most of the items stored in an experiment file. 
Neither platform information nor text encoding information is stored in standalone plain text files. Conse-
quently determining the text encoding of an experiment file is different from determining the text encoding 
of a standalone file. This makes Igor's handling of text encodings and the meaning of the default text encod-
ing setting more complicated than we would like.
The Default Text Encoding submenu contains the following items:
UTF-8
Western
MacRoman
Windows-1252
Japanese
Simplified Chinese
