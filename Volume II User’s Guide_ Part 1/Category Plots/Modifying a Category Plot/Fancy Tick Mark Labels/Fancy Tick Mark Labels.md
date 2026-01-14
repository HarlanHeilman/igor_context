# Fancy Tick Mark Labels

Chapter II-14 — Category Plots
II-358
The settings unique to category plots are described in the following sections.
Bar and Category Gaps
You can control the gap size between bars and between categories.
Generally, the category gap should be larger than the bar gap so that it is clear which bars are in the same 
category. However, a category gap of 100% leaves no space for bars.
The gap sizes are set in the Modify Axis dialog which you can display by choosing GraphModify Axis 
or by double-clicking the category axis.
Tick Mark Positioning
You can cause the tick marks to appear in the center of each category 
slot rather than at the edges. Double-click the category axis to display 
the Modify Axis dialog and check the “Tick in center” checkbox in the 
“Auto/Man Ticks” pane. This looks best when there is only one bar per 
category.
Fancy Tick Mark Labels
Tick mark labels on the category axis are drawn using the contents of your category text wave. In addition 
to simple text, you can insert special escape codes in your category text wave to create multiline labels and 
to include font changes and other special effects. The escape codes are exactly the same as those used for 
axis labels and for annotation text boxes — see Annotation Text Content on page III-35.
There is no point-and-click way to insert the codes in this version of Igor Pro. You will have to either 
remember the codes or use the Add Annotation dialog to create a string you can paste into a cell in a table.
To enter multi-line text in a table cell, click the text editor widget at the right end of the table entry line.
You can also make a multi-line label from the command line, like this:
Make/T/N=5 CatWave
// Mostly you won't need this line
CatWave[0]="Line 1\rLine2" // "\r" Makes first label with two lines
Multiline labels are displayed center-aligned on a horizontal category axis and right-aligned on a left axis but 
left-aligned on a right axis. You can override the default alignment using the alignment escape codes as used in 
the Add Annotation dialog. See the Annotation Text Escape Codes operation on page III-35 for a description of 
the formatting codes.
15 min
1 hr
Bar Gap
Bar Width (100%)
Category Width (100%)
Category Gap
200
100
0
15 min
1 hr
