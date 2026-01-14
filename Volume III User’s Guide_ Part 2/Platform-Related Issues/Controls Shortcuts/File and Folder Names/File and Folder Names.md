# File and Folder Names

Chapter III-15 — Platform-Related Issues
III-450
Formats that are not supported on the current platform are drawn as gray boxes.
Although Igor does not display non-native graphic formats, it does preserve them. For example, you can 
create an experiment on Windows and paste a Windows metafile into a page layout, graph, or notebook 
window. If you save the experiment and open it on Macintosh, the Windows metafile is displayed as a gray 
box. If you now save and open the experiment on Windows again, the Windows metafile is displayed cor-
rectly.
Converting to PNG
If you want platform-specific pictures to be displayed correctly on both platforms, you must convert the 
pictures to PNG. To convert to PNG, use the Pictures dialog (Misc menu) for pictures in graphs and page 
layouts, or for pictures in notebooks, use the Special submenu in the Notebook menu.
Converting a picture to PNG makes it a bitmap format and may degrade resolution. This is fine for graphics 
intended to be viewed on the screen but not for graphics intended to be printed at high resolution. You can 
convert to a high resolution PNG without losing much picture quality.
Page Setup Compatibility
Page setup records store information regarding the size and orientation of the page. Prior to Igor Pro 7, page 
setups contained platform-depedent and printer-depedent data. This is no longer the case, but as a conse-
quence, only minimal information is stored.
In each experiment file, Igor stores a separate page setup for each page layout, notebook, and procedure 
window, and stores a single page setup for all graphs and a single page setup for all tables.
File System Issues
This section discusses file system issues that you need to take into account if you use Igor on both Macintosh 
and Windows.
File and Folder Names
On Windows, the following characters are illegal in file and folder names: backslash (\), forward slash (/), 
colon (:), asterisk (*), question mark (?), double-quote ("), left angle bracket (<), right angle bracket (>), ver-
tical bar (|). On Macintosh, the only illegal character is colon.
This means, for example, that you can not create a file with a name like “Data 1/23/98” on Windows. You 
can create a file with this name on Macintosh. If you write an Igor procedure that generates a file name like 
this, it will run on Macintosh but fail on Windows.
Therefore, if you are concerned about cross-platform compatibility, you must not use any of the Windows 
illegal characters in a file or folder name, even if you are running on Macintosh. Also, don’t use period 
except before a file name extension.
File and folder names in Windows can theoretically be up to 255 characters in length. Because of some lim-
itations in Windows and also in Igor, you will encounter errors if you use file names that long. However, 
both Igor and Windows are capable of dealing with file names up to about 250 characters in length. It is 
unlikely that you will approach this limit.
EPS (Encapsulated 
PostScript)
Use MiscPictures
High resolution vector format. EPS is largely obsolete. 
Use PDF instead.
SVG (Scalable Vector 
Graphics)
Use MiscPictures
Cross-platform high resolution vector format.
Format
How To Create
Notes
