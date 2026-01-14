# Page Breaks

Chapter III-1 — Notebooks
III-19
book. If you open the notebook on Macintosh, the EMF will display as a gray box because EMF is a 
Windows-specific format. However, if you right-click the EMF picture and choose Update Selection, Igor 
will regenerate it using a Macintosh format.
An Igor-object picture never updates unless you do so. Thus you can keep pictures of a given object taken 
over time to record the history of that object.
The Size of the Picture
The size of the picture is determined when you initially paste it into the notebook. If you update the picture, 
it will stay the same size, even if you have changed the size of the graph window from which the picture is 
derived. Normally, this is the desired behavior. If you want to change the size of the picture in the notebook, 
you need to repaste a new picture over the old one.
Activating The Igor-Object Window
You can activate the window associated with an Igor-object picture by double-clicking the Igor object 
picture in the notebook. If the window exists it is activated. If it does not exist but the associated window 
recreation macro does exist, Igor runs the window recreation macro.
Breaking the Link Between the Object and the Picture
Lets say you create a picture from a graph and paste it into a notebook. Now you kill the graph. When you 
click the picture, Igor displays a question mark after the name of the graph in the notebook’s status area to 
indicate that it can’t find the object from which the picture was generated. Igor can not update this picture. 
If you recreate the graph or create a new graph with the same name, this reestablishes the link between the 
graph and the picture.
If you change the name of a graph, this breaks the link between the graph and the picture. To reestablish it, 
you need to create a new picture from the graph and paste it into the layout.
Compatibility Issues
A Windows format picture, when updated on Macintosh, is converted to a Macintosh format, and vice 
versa.
Igor does not recognized Igor-object pictures created by Igor versions before 6.10.
If you save a notebook containing a Gizmo picture and open it in Igor6 version 6.37 or before, you will get 
errors in Igor6. If you open it in Igor6 version 6.38 or later, it will display correctly.
Cross-Platform Pictures
If you want to create a notebook that contains pictures that display correctly on both Macintosh and Win-
dows, you can use the PDF or PNG (Portable Network Graphics) format. If some pictures are already in 
JPEG or TIFF format, these too will display correctly on either platform.
PDF pictures are displayed correctly on Windows in Igor Pro 9.00 or later. In earlier versions on Windows, 
PDF pictures are displayed as gray boxes.
You can convert other types of pictures to PNG using the Convert to PNG item in the Special submenu of 
the Notebook menu.
Page Breaks
When you print a notebook, Igor automatically goes to the next page when it runs out of room on the 
current page. This is an automatic page break.
