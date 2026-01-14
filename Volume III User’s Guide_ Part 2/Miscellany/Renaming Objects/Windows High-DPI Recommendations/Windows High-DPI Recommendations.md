# Windows High-DPI Recommendations

Chapter III-17 — Miscellany
III-508
Since Igor Pro 8, we now use fast custom code when drawing lines that are two or more pixels wide. How-
ever, because the custom code lines are not as pleasing as the system code, it is used only under conditions 
where the system code is slow, particularly when very long traces are used. 
When you need the fastest update speed, you can specify that a trace should use the fast line draw code by 
using the ModifyGraph live keyword with a value of 2. This will cause even one pixel thick lines to be 
drawn with the new code. The speed improvement is on the order of a factor of two.
You can use the Live Mode demo experiment to see how different settings affect the speed of graph 
updates.
Windows High-DPI Recommendations
High-DPI (dots-per-inch) displays have resolutions substantially higher than the Windows standard 96 
DPI. These displays sometimes go by the names Retina, 4K, 5K, Ultra HD and Quad HD.
Since the pixels of a high-DPI monitor are typically about one-half the size of pixels on standard monitors, 
software running on a high-DPI monitor must make adjustments. These adjustments are made by some 
combination of the operating system and the program itself.
On Macintosh, with its “Retina” high-DPI screens, the operating system handles most resolution issues and 
there are few problems with Igor on Retina monitors.
On Windows, both the operating system and the Qt framework that Igor uses introduce complexities that 
sometimes result in less than perfect behavior. This section provides guidance for Windows user to mini-
mize these issues.
To get the best experience when using a high-DPI display, we recommend that you use Windows 10 or 
later. We do not test or explicitly support high-DPI features on older Windows versions.
If you only have one display, such as a laptop with a high-DPI display, and no external displays are con-
nected, you should not need to make any changes to Igor's default configuration to achieve the correct 
behavior.
If you have multiple displays with different resolutions, such as a high-resolution laptop display and a stan-
dard-resolution external monitor, you may see problems such as text, menus, windows or icons too big or 
too small. In our experience with Igor8, most or all of these issues are resolved if you make your high-res-
olution display your main display using the Windows 10 Display control panel.
As an example, here are instructions for configuring a typical mixed-resolution system - a laptop with a 
built-in high-resolution display and an external standard-resolution monitor:
1.
Connect the external standard-resolution monitor.
2.
Open the Display settings page. You can do this by right-clicking the Start menu, choosing Settings, 
clicking System, and selecting Display in the lefthand pane.
3.
In the Multiple Displays setting, near the bottom of the pane, select Extend These Displays.
4.
Click the Identify link below the diagram of your displays at the top of the pane to confirm which 
display is which. For these instructions, we assume that display #1 is the high-resolution built-in 
display and display #2 is a standard-resolution external monitor.
5.
Click the box representing the built-in high-resolution display (display #1 for this example).
6.
Set Resolution to the recommended value, such as 3840 x 2160.
7.
Set Scale and Layout to the recommended value, which may be 200%, 225%, or 250% depending on 
your hardware.
8.
Check the Make This My Main Display checkbox near the bottom of the pane.
9.
Close the settings control panel.
