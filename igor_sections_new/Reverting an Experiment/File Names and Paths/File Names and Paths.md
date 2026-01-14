# File Names and Paths

Chapter II-3 — Experiments, Files and Folders
II-21
New Experiments
If you choose New from the File menu, Igor first asks if you want to save the current experiment if it was 
modified since you last saved it. Then Igor creates a new, empty experiment. The new experiment has no 
experiment file until you save it.
By default, when you create a new experiment, Igor automatically creates a new, empty table. This is con-
venient if you generally start working by entering data manually. However, in Igor data can exist in 
memory without being displayed in a table. If you wish, you can turn automatic table creation off using the 
Experiment Settings category of the Miscellaneous Settings dialog (Misc menu).
Saving an Experiment as a Template
A template experiment provides a way to customize the initial contents of a new experiment. When you 
open a template experiment, Igor opens it normally but leaves it untitled and disassociates it from the tem-
plate experiment file. This leaves you with a new experiment based on your prototype. When you save the 
untitled experiment, Igor creates a new experiment file.
Packed template experiments have ".pxt" as the file name extension instead of ".pxp". Unpacked template 
experiments have ".uxt" instead of ".uxp".
To make a template experiment, start by creating a prototype experiment with whatever waves, variables, 
procedures and other objects you would like in a new experiment. Then choose FileSave Experiment As, 
choose Packed Experiment Template or Unpacked Experiment Template from the file type pop-up menu, 
and save the template experiment.
You can convert an existing experiment file into a template file by changing the extension (".pxp" to ".pxt" 
or ".uxp" to ".uxt").
The Macintosh Finder’s file info window has a Stationery Pad checkbox. Checking it turns a file into a sta-
tionery pad. When you double-click a stationery pad file, Mac OS X creates a copy of the file and opens the 
copy. For most uses, the template technique is more convenient.
Browsing Experiments
You can see what data exists in the current experiment as well as experiments saved on disk using the Data 
Browser. To open the browser, choose DataData Browser. Then click the Browse Expt button. See Data 
Folders on page II-107 for details.
File Names and Paths
Igor supports file names up to 255 bytes long.
File paths can be up to 2000 byte long. Igor's 2000 byte limit applies even if the operating system supports 
longer paths.
As of this writing, on Macintosh, the operating system limits paths to 1026 bytes.
On Windows, prior to Windows 10 build 1607, released in August of 2016, the operating system limited 
paths to 260 bytes. Build 1607 raised this limit to 32767 characters. As of this writing, this feature is available 
only on systems that have "opted in" by setting the LongPathsEnabled registry setting. Using paths longer 
than 260 bytes may cause errors on some systems and with some software.
As described under Path Separators on page III-451, Igor accepts paths with either colons or backslashes 
on either platform.
