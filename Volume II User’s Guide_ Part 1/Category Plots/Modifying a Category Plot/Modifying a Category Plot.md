# Modifying a Category Plot

Chapter II-14 — Category Plots
II-357
Category Plot Commands
The Display operation that creates a category plot is the same Display operation that creates an XY plo t. 
When you use a text wave for the X wave, Igor creates a category plot. When you use a numeric wave for 
tthe X wave, Igor creates an XY plot. The same applies to the AppendToGraph operation.
You can control the gap between categories and the gap between bars within a single category using the 
ModifyGraph operation with the barGap and catGap keywords. You can create a stacked category plot 
using the ModifyGraph toMode keyword. See Bar and Category Gaps.
Combining Category Plots and XY Plots
You can have ordinary XY plots and category plots in the same graph window. However, once an axis has 
been used as either numeric or category, it is not usable as the other type.
For example, if you tried to append an ordinary XY plot to the graph shown above, you would find that the 
bottom (category) axis was not available in the Axis pop-up menu. If you try to append data to an existing 
category plot using a different text wave as the category wave, the new category wave is ignored.
The solution to these problems is to create a new axis using the Append Traces to Graph dialog or the 
Append Category Plot dialog.
Category Plot Using Dimension Labels
An alternative to using a text wave to create a category plot is to use the dimension labels from the Y wave. 
This feature was added in Igor Pro 8.00.
The easiest way to create the dimension labels is to edit the dimension labels in a table (see Showing 
Dimension Labels on page II-235). This example shows how to programmatically make a category plot 
using dimension labels:
Function DemoCategoryPlotUsingDimensionLabels()
Make/O control={100,300,50,500}, test={50,200,70,300}
SetDimLabel 0, 0, '15 min', control
SetDimLabel 0, 1, '1 hour', control
SetDimLabel 0, 2, '6 hrs', control
SetDimLabel 0, 3, '24 hrs', control
Display /W=(35,45,430,253) control, test vs '_labels_'
ModifyGraph hbFill(control)=5,hbFill(test)=7
SetAxis/A/E=1 left
Legend
End
The _labels_ keyword must be enclosed in single quotes because it has the form of a liberal name and it is 
used in a place where a wave name is expected.
Using the Y wave's dimension labels is convenient for category plots having just one Y wave because it 
keeps the category labels and the numeric Y data in one place. If you are making the graph manually, you 
can enter the labels in a table, instead of executing a separate command for each label.
When you have more than one Y wave, the first trace added to a category axis controls the category labels. 
If you remove the first trace or change the order of traces, the labels may change or become blank. You can 
prevent this by setting the dimension labels for all the Y waves.
Modifying a Category Plot
Because category plots are created in ordinary graph windows, you can change the appearance of the cat-
egory plot using the same methods you use for XY plots. For example, you can modify the bar colors and 
line widths using the Modify Trace Appearance dialog. For information on traces, XY plots and graphs, see 
Modifying Traces on page II-290.
