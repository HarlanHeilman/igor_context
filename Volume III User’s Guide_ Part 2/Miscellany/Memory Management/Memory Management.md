# Memory Management

Chapter III-17 — Miscellany
III-512
See Creating Igor Extensions on page IV-208 if you are a programmer interested in writing your own XOPs.
Activating 64-bit Extensions
To activate a 64-bit extension, you put it, or an alias or shortcut pointing to it, in the "Igor Extensions (64-
bit)" folder in your "Igor Pro User Files" folder.
For illustration purposes, we show here the steps you need to take to activate Igor's SQL XOP which pro-
vides access to databases.
1. In Igor, choose Help->Show Igor Pro User Files to open your "Igor Pro User Files" folder on the desktop.
2. In Igor, choose Help->Show Igor Pro Folder to open your "Igor Pro Folder" on the desktop.
3. Open the "Igor Pro Folder\More Extensions (64-bit)\Utilities" folder on the desktop.
4. Make an alias (Macintosh) or shortcut (Windows) for "SQL64.xop" and put it in the "Igor Extensions (64-
bit)" folder inside your "Igor Pro User Files" folder.
5. Restart Igor64.
If you want to activate an XOP for all users on a given machine, you can put the alias or shortcut in the "Igor 
Extensions (64-bit)" folder inside your Igor Pro Folder. You may need to run as administrator to do this.
Changes that you make to either "Igor Extensions (64-bit)" folder take effect the next time Igor is launched.
Activating 32-bit Extensions
If you are running the 32-bit version of Igor on Windows, you can activate the 32-bit version of an XOP fol-
lowing the instructions in the preceding section with a few modifications.
Use "Igor Extensions" instead of "Igor Extensions (64-bit)" and "More Extensions" instead of "More Exten-
sions (64-bit)". Activate the 32-bit version of the XOP, for example SQL.xop, instead of SQL64.xop
XOPs on MacOS 10.15 and Later
In MacOS 10.15 (Catalina), Apple added strict security features that prevent downloaded XOPs from 
running without special security certification ("notarization").
WaveMetrics XOPs that ship with Igor Pro 8.04 or later have the required notarization and so work.
XOPs that you compiled on your own machine are likely to run correctly unless they depend on libraries 
that are not compatible with Catalina.
Most third-party XOPs that you downloaded will not run on Catalina.
For further information, see https://www.wavemetrics.com/news/igor-pro-macos-1015-catalina and 
https://www.wavemetrics.com/node/21088 for a workaround.
Memory Management
Igor comes in 32-bit and 64-bit versions called IGOR32 and IGOR64 respectively. IGOR32 is available on 
Windows only. The only reason to run IGOR32 is if you depend on 32-bit XOPs that have not been ported 
to 64 bits.
IGOR32 can theoretically address 4GB of virtual address space. For the vast majority of Igor applications, 
this is more than sufficient. If you must load gigabytes of data into memory at one time, you may run out 
of memory. This may happen long before you load 4GB of data into memory, because, to allocate a wave 
for example, you not only need free memory, but the free memory must also be continguous, and memory 
becomes fragmented over time.
