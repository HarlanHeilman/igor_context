# Creating a Category Plot

Chapter II-14 — Category Plots
II-356
Overview
Category plots are two-dimensional plots with a continuous numeric variable on one axis and a non-
numeric (text) category on the other. Most often they are presented as bar charts with one or more bars occu-
pying a category slot either side-by-side or stacked or some combination of the two. You can also combine 
them with error bars:
Category plots are created in ordinary graphs when you use a text wave or dimension labels as the X data. 
For more on graphs, see Chapter II-13, Graphs.
Creating a Category Plot
To create a category plot, first create your numeric wave(s) and your text category wave.
The numeric waves used to create a category plot should have “point scaling” (X scaling with Offset = 0 and 
Delta = 1). See Category Plot Pitfalls on page II-362 for an explanation.
Then invoke the Category Plot dialog by choosing WindowsNewCategory Plot. You can append to an 
existing graph by choosing GraphAppend to GraphCategory Plot.
Select the numeric waves from the Y Waves list, and the category (text) wave from the X Wave list.
You can use also the Display command directly to create a category plot:
Make/O control={100,300,50,500},test={50,200,70,300}
Make/O/T sample={"15 min","1 hr","6 hrs","24 hrs"}
Display control,test vs sample
//vs text wave creates category plot
ModifyGraph hbFill(control)=5,hbFill(test )=7
SetAxis/A/E=1 left
Legend
0.0
0.5
1.0
μm
 14 
 13.5 
 13.25 
 13 
 12.75 
 12.5 
500
400
300
200
100
0
15 min
1 hr
6 hrs
24 hrs
 control
 test
