# X Scaling Moves Bars

Chapter II-14 — Category Plots
II-362
More details about these modes can be found in Grouping, Stacking and Adding Modes on page II-296.
Numeric Categories
You can create category plots with numeric categories by creating a text wave from your numeric category 
data. Create a text wave containing the numeric values by using the num2str function. For example, if we 
have years in a numeric wave:
Make years={1993,1995,1996,1997}
we can create an equivalent text wave:
Make/T/N=4 textYears= num2str(years)
Then create your category plot using textYears:
Display ydata vs textYears
// vs 1993, 1995, 1996, 1997 (as text)
Combining Numeric and Category Traces
Normally when you create a category plot, you can append only another category trace (a numeric wave 
plotted versus a text wave) to that plot. In rare cases, you may want to add a numeric trace to a category 
plot. You can do this using the /NCAT flag. Here is an example:
Make/O/T catx = {"cat0", "cat1", "cat2"}
Make/O caty = {1, 3, 2}
Display caty vs catx
SetAxis/A/E=1 left
// Plot simulated original data for a category
Make/N=10/O cat1over = gnoise(1) + 1.5
SetScale/P x, 1.5, 1e-5, cat1over
// Delta x can not be zero
AppendToGraph/NCAT cat1over
ModifyGraph mode(cat1over)=3, marker(cat1over)=19, rgb(cat1over)=(0,0,65535)
The /NCAT flag, used with AppendToGraph, tells Igor to allow adding a numeric trace to a category plot. 
This flag was added in Igor Pro 6.20.
In Igor Pro 6.37 or later, the Display operation also supports the /NCAT flag. This allows you to create a 
numeric plot and then append a category trace.
Category Plot Pitfalls
You may encounter situations in which the category plot doesn’t look like you expect it to.
X Scaling Moves Bars
Category plots position the bars using the X scaling of the value (numeric) waves. The X scaling of the cat-
egory (text) wave is completely ignored. It is usually best if you leave the X scaling of the category plot 
0.1
1
La
Ce
Nd
Sm
0.1
1
La
Ce
Nd
Sm
None mode
Keep with Next Mode
