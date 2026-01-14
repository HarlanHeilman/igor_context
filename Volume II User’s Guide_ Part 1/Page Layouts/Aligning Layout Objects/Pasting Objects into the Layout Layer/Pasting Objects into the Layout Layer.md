# Pasting Objects into the Layout Layer

Chapter II-18 — Page Layouts
II-493
After doing these steps, the horizontal plot areas in the stacked graphs will be perfectly aligned. This does 
not, however, guarantee that the left axes will line up. The reason for this is the graphs’ axis standoff set-
tings. The axis standoff setting, if enabled, moves the left axis to the left of the plot area to prevent the dis-
played traces from colliding with the axis. If the graphs have different sized markers, for example, it will 
offset the left axis of each graph by a different amount. Thus, although the plot areas are perfectly-aligned 
horizontally, the left axes are not aligned. The solution for this is to use the Modify Axis dialog (Graph 
menu) to turn axis standoff off for each graph.
Copying and Pasting Layout Objects
This section discusses copying objects from the layout layer of a page layout and pasting them into the same 
or another page layout. Most users will not need to do this.
Copying Objects from the Layout Layer
You can copy objects to the clipboard by selecting them with the arrow tool or enclosing them with the 
marquee tool and then choosing Copy from the Edit menu. You can also choose Copy from the pop-up 
menu that appears when you click inside the marquee.
When you copy an object to the clipboard, it is copied in two formats:
•
As an Igor object in a format used internally by Igor
•
As a picture that can be understood by other applications
Although you can do a copy for the purposes of exporting to another application, this is not the best way. 
See Exporting Page Layouts on page II-498 for a discussion of exporting graphics to another application. 
This section deals with copying objects for the purposes of pasting them in the same or another layout. Since 
it is easy to append graphs and tables to a layout using the pop-up menus in the tool palette, the main utility 
of this is for copying annotations or pictures from one layout to another.
Copying as an Igor Object Only
There are times when a straightforward copy operation is not desirable. Imagine that you have some graph 
objects in a layout and you want to put the same objects in another layout. You could copy the graph objects and 
paste them into the other layout. However, if the graphs are very complex, it could take a lot of time and memory 
to copy them to the clipboard as a picture. If your purpose is not to export to another application, there is really 
no need to copy as a picture. If you press Option (Macintosh) or Alt (Windows) while choosing Copy, then Igor 
will do the copy only as Igor objects, not as a picture. You can now paste the copied graphs in the other layout.
Pasting Objects into the Layout Layer
This section discusses pasting Igor objects that you have copied from the same or a different page layout. 
For pasting a new picture that you have generated with another application, see Inserting a Picture in the 
Layout Layer on page II-496.
To paste layout objects that you have copied to the clipboard from the same Igor experiment, just choose 
Paste from the Edit menu.
When you copy a graph, table, Gizmo or picture layout object from a layout to the clipboard, it is copied as 
a picture and as an Igor object in an internal Igor format. The Igor format includes the name by which Igor 
knows the layout object. If you later paste into a layout, Igor will use this name to determine what object 
should be added to the layout. It normally does not paste the picture representation of the object. In other 
words, the Igor format of the object that is copied to the clipboard refers to a graph, table, Gizmo or picture 
by its name.
In rare cases, you may actually want to paste as a picture, not as an Igor object. You might plan to change 
the graph but want a representation of it as it is now in the layout. To do this, press Option (Macintosh) or 
Alt (Windows) while choosing EditPaste. This creates a new named picture in the current experiment.
