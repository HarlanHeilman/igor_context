# Layout Tiling Guided Tour

Chapter II-18 — Page Layouts
II-488
Before we get into details, we will look at a simple example that demonstrates tiling concepts.
Layout Tiling Guided Tour
In this tour, we will create a page layout displaying some graphs and arrange them using tiling.
We assume that we are creating the layout to produce a graphic of a specific size for use on a web page or 
in a paper, not for printing hard copy.
We start by making some graphs to tiled and then create a page layout containing the graphs.
1.
In a new experiment, execute the following commands:
Make/O jack=sin(x/8), fred=cos(x/8), bob=jack*fred
Display/W=(35,50,300,175) jack
Display/W=(35,200,300,325) fred
Display/W=(35,350,300,475) bob
Layout/W=(350,50,850,650) Graph0, Graph1, Graph2
ModifyLayout mag=1, units=0
2.
If necessary, adjust the layout magnification and window size so you can see the entire page.
Next we will set the page size and margins appropriate for using in a web page or paper.
3.
Choose LayoutPage Size, enter the following settings, and click Do It:
Units: Points
Width: 432
Height: 360
Margins: 0 for all
Margins are useful when printing but usually serve no purpose when creating graphics for a paper 
or web page.
4.
Choose LayoutAppend to Layout and append Graph0, Graph1, and Graph2.
5.
Use EditSelect All to select all of the graph objects in the layout.
6.
Choose LayoutArrange Objects.
Click the Tile radio button.
Set the other settings as follows:
Grout: 8
Rows: Auto
Columns: Auto
Click Do It.
The graphs are tiled in a 2 row by 2 column arrangment leaving the bottom/right tile empty.
Suppose we want to leave the bottom/left tile empty rather than the bottom right.
7.
Drag the bottom/left graph and position it roughly in the bottom/right position.
Use EditSelect All to select all of the graph objects.
Choose LayoutArrange Objects.
Check the Preserve Arrangement checkbox.
Click Do It.
The Preserve Arrangement feature tiled the last graph in the bottom/right position as you had 
roughly positioned it.
Next we will assume that you want to use just a portion of the page rather than the whole thing, per-
haps to leave room for textboxes or other objects.
8.
Click the Misc icon in the tool palette and choose Points.
Click a blank area of the page to deselect all objects.
