# History Carbon Copy

Chapter II-2 — The Command Window
II-10
To make it easy tocopy a command from the history to the command line, clicking a line in the history area 
selects the entire line. You can still select just part of a line by clicking and dragging.
Up Arrow and Down Arrow move the selection range in the history up or down one line selecting an entire 
line at a time. Since you normally want to select a line in the history to copy a command to the command line, 
Up Arrow and Down Arrow skip over non-command lines. Left Arrow and Right Arrow move the insertion 
point in the command line.
When you save an experiment, the contents of the history area are saved. The next time you load the exper-
iment the history will be intact. Some people have the impression that Igor recreates an experiment by reex-
ecuting the history. This is not correct. See How Experiments Are Loaded on page II-26 for details.
Limiting Command History
The contents of the history area can grow to be quite large over time. You can limit the number of lines of 
text retained in the history using the Limit Command History feature in the Command Window section of 
the Miscellaneous Settings dialog which is accessible through the Misc menu.
If you limit command history, when you save the experiment, Igor checks the number of history lines. If 
they exceed the limit, the oldest lines are deleted.
History Archive
When history lines are deleted through the Limit Command History feature, the History Archive feature 
allows you to tell Igor to write the deleted lines to a text file in the experiment's home folder.
To enable the History Archive feature for a given experiment, create a plain text file in the home folder of 
the experiment. The text file must be named
<Experiment Name> History Archive UTF-8.txt
where <Experiment Name> is the name of the current experiment. Now, when you save the experiment, 
Igor writes any deleted history lines to the history archive file.
Prior to Igor Pro 7 the history archive file was written in system text encoding and was named
<Experiment Name> History Archive.txt
If you used the history archive in Igor Pro 6 you need to create a new history archive file whose name 
includes “UTF-8”.
If the history archive file is open in another program, including Igor, the history archive feature may fail 
and history lines may not be written.
History Carbon Copy
This feature is expected to be of interest only in rare cases for advanced Igor programmers such as Bela 
Farago who requested it.
You can designate a notebook to be a "carbon copy" of the history area by creating a plain text or formatted 
notebook and setting its window name, via Windows->Window Control, to HistoryCarbonCopy. If the His-
toryCarbonCopy notebook exists, Igor inserts history text in the notebook as well as in the history. How-
ever, if a command is initiated from the HistoryCarbonCopy notebook (see Notebooks as Worksheets on 
page III-4), Igor suspends sending history text to that notebook during the execution of the command.
If you rename the notebook to something other than HistoryCarbonCopy, Igor will cease sending history 
text to it. If you later rename it back to HistoryCarbonCopy, Igor will resume sending history text to it.
The history trimming feature accessed via the Miscellaneous Settings dialog does not apply to the History-
CarbonCopy notebook. You must trim it yourself. Notebooks are limited to 16 million paragraphs.
When using a formatted notebook as the history carbon copy, you can control the formatting of commands 
and results by creating notebook rulers named Command and Result. When Igor sends text to the history
