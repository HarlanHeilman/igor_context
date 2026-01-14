# Layout Contextual Menu for a Single Object

Chapter II-18 — Page Layouts
II-484
Gizmo Pop-Up Menu
The Gizmo pop-up menu provides a handy way to append a 3D Gizmo plot object to the layout layer. It 
contains a list of all the Gizmo windows that are currently open. Choosing the name of a Gizmo window 
appends the Gizmo object to the layout layer.
The Layout Layer Contextual Menu
When the layout layer is active, Control-clicking (Macintosh) or right-clicking (Windows) displays the 
Layout Layer contextual menu. The contents of the menu depend on whether you click directly on an object 
or on a part of the page where there is no object.
Layout Contextual Menu for a Single Object
If you Control-click (Macintosh) or right-click (Windows) directly on an object, the layout contextual menu 
includes these items:
Activate Object’s Window
Activates the graph, table or 3D Gizmo plot window associated with the object.
Recreate Object’s Window
Recreates the graph, table or 3D Gizmo plot window associated with the object by running the window rec-
reation macro that was created when the window was killed.
Kill Object’s Window
Kills the graph, table or 3D Gizmo plot window associated with the object. Before it is killed, Igor displays 
a dialog that you can use to create or update its window recreation macro.
If you press the Option key on Macintosh while selecting this item, the window is killed with no dialog and 
without creating or updating the window recreation macro. Any changes you made to the window will be 
lost so use this feature carefully. This feature does not work on Windows because the Alt key interferes with 
menu behavior.
Show Object’s Window
Shows the corresponding window if it is hidden.
Hide Object’s Window
Hides the corresponding if it is visible.
Scale Object
Changes the size of the layout object in terms of percent of its current size or percent of its normal size. Although 
this can work on any type of object, it is most useful for scaling pictures relative to their normal size.
For a picture or annotation object, “normal” size is the inherent size of the picture or annotation before any 
shrinking or expanding. For a graph, table or Gizmo object, “normal” size means the size of the correspond-
ing window.
If a graph’s size is hardwired via the Modify Graph dialog, the corresponding layout object can not be scaled.
Tip:
You can quickly return a picture or annotation to its normal size by double-clicking it while 
pressing Option (Macintosh) or Alt (Windows).
Convert Object to Embedded
This item converts a graph, table or Gizmo object to an embedded subwindow. In doing so, the standalone 
window which the object represented is killed, leaving just the embedded subwindow.
