# Writing a Procedure (Optional)

Chapter I-2 — Guided Tour of Igor Pro
I-59
20.
Choose Fraction of Plot Area in the “Free axis position” menu.
The Lresid axis is a “free” axis. This moves it horizontally so it is in line with the Left axis.
21.
Choose Bottom from the Axis pop-up menu.
22.
Click the Axis Standoff checkbox to turn standoff off.
Just a couple more touch-ups and we will be done. The ticking of the Lresid axis can be improved. The 
residual data should be in dots mode.
23.
Choose Lresid from the Axis pop-up menu again.
24.
Click the Auto/Man Ticks tab.
25.
Change the Approximately value to 2.
26.
Click the Axis Range tab.
27.
In the Autoscale Settings area, choose “Symmetric about zero” from the menu currently reading 
“Zero isn’t special”.
28.
Click the Do It button.
29.
Double-click the histResids trace.
The Modify Trace Appearance dialog appears with histResids already selected in the list.
30.
Choose Dots from the Mode pop-up menu
31.
Set the line size to 2.00.
32.
Click Do It.
The graph should now look like this:
Saving Your Work - Tour 3D
1.
Choose the FileSave Experiment As menu item.
2.
Navigate to your “Guided Tours” folder.
This is the folder that you created under Saving Your Work - Tour 1A on page I-21.
3.
Type “Tour 3D.pxp” in the name box and click Save.
Writing a Procedure (Optional)
In this section we will collect commands that were created as we appended the residuals to the graph. We 
will now use them to create a procedure that will append a plot of residuals to a graph.
1.
Make the command window tall enough to see the last 10 lines by dragging the top edge of the 
window upward.

Chapter I-2 — Guided Tour of Igor Pro
I-60
2.
Find the fifth line from the bottom that reads:
•AppendToGraph/L=Lresid histResids
3.
Select this line and all the lines below it and copy them to the clipboard.
4.
Choose the WindowsNewProcedure menu item.
5.
Type “Append Residuals” (without the quotes) in the Document Name box and click OK.
A new procedure window appears. We could have used the always-present built-in procedure window, but 
we will save this new procedure window as a standalone file so it can be used in other experiments.
6.
Add a blank line to the window, type “Function AppendResiduals()”, and press Return or Enter.
7.
Paste the commands from the clipboard into the new window.
8.
Type “End” and press Return or Enter.
9.
Select the five lines that you pasted into the procedure window and then choose EditAdjust 
Indentation.
This removes the bullet characters copied from the history and prepends tabs to apply the normal 
indentation for procedures.
Your procedure should now look like this:
Function AppendResiduals()
AppendToGraph/L=Lresid histResids
SetAxis/A/E=2 Lresid
ModifyGraph nticks(Lresid)=2,standoff(bottom)=0,axisEnab(left)={0,0.7};DelayUpdate
ModifyGraph axisEnab(Lresid)={0.8,1}, freePos(Lresid)=0;DelayUpdate
ModifyGraph mode(histResids)=2,lsize(histResids)=2
End
10.
Delete the “;DelayUpdate” at the end of the two ModifyGraph commands.
DelayUpdate has no effect in a function.
We now have a nearly functional procedure but with a major limitation — it only works if the residuals 
wave is named “histResids”. In the following steps, we will change the function so that it can be used with 
any wave and also with an XY pair, rather than just with equally-spaced waveform data.
11.
Replace the first two lines of the function with the following:
Function AppendResiduals(yWave, xWave)
Wave yWave
Wave xWave
// X wave or null if there is no X wave
if (WaveExists(xWave))
AppendToGraph/L=Lresid yWave vs xWave
else
AppendToGraph/L=Lresid yWave
endif
String traceName = NameOfWave(yWave)
12.
In the last ModifyGraph command in the function, change both “histResids” to “$traceName” 
(without the quotes).
The “$” operator converts the string expression that follows it into the name of an Igor object.
Here is the completed procedure.
Function AppendResiduals(yWave,xWave)
Wave yWave
Wave/Z xWave
// X wave or null if there is no X wave
if (WaveExists(xWave))
AppendToGraph/L=Lresid yWave vs xWave
else
AppendToGraph/L=Lresid yWave
endif
String traceName = NameOfWave(yWave)
SetAxis/A/E=2 Lresid
ModifyGraph nticks(Lresid)=2,standoff(bottom)=0,axisEnab(left)={0,0.7}

Chapter I-2 — Guided Tour of Igor Pro
I-61
ModifyGraph axisEnab(Lresid)={0.8,1},freePos(Lresid)={0,kwFraction}
ModifyGraph mode($traceName)=2,lsize($traceName)=2
End
Let’s try it out.
13.
Click the Compile button at the bottom of the procedure window to compile the function.
If you get an error, edit the function text to match the listing above.
14.
Click the close button in the Append Residuals procedure window. A dialog asks if you want to 
kill or hide the window. Click Hide.
If you press Shift while clicking the close button, the window will be hidden without a dialog.
15.
Choose WindowsNew Graph and click the Fewer Choices button if it is available.
16.
Choose fakeY_Hist from the Y Waves list and _calculated_ from the X Wave list and click Do It.
A graph without residuals is created.
17.
In the command line, execute the following command:
AppendResiduals(histResids, $"")
Because we have no X wave, we use $”” to pass NULL to AppendResiduals for the xWave parameter.
The AppendResiduals function runs and displays the residuals in the graph, above the original his-
togram data.
Next we will add a function that displays a dialog so we don’t have to type wave names into the com-
mand line.
18.
Choose WindowsProcedure WindowsAppend Residuals to show the Append Residuals pro-
cedure window.
19.
Enter the following function below the AppendResiduals function.
Function AppendResidualsDialog()
String yWaveNameStr, xWaveNameStr
Prompt yWaveNameStr,"Residuals Data",popup WaveList("*",";","")
Prompt xWaveNameStr,"X Data", popup "_calculated_;"+WaveList("*",";","")
DoPrompt "Append Residuals", yWaveNameStr, xWaveNameStr
if (V_flag != 0)
return -1
// User canceled
endif
AppendResiduals($yWaveNameStr, $xWaveNameStr)
return 0
// Success
End
This function displays a dialog to get parameters from the user and then calls the AppendResiduals 
function.
Let’s try it out.
20.
Click the Compile button at the bottom of the procedure window to compile procedures.
If you get an error, edit the function text to match the listing above.
21.
Shift-click the close button to hide the procedure window. Then activate Graph1.
22.
Control-click (Macintosh) or right-click (Windows) the residual trace at the top of the graph and 
select Remove histResids from the pop-up menu.
The Lresid axis is removed because the last wave graphed against it was removed.
23.
On the command line, execute this command:
AppendResidualsDialog()
The AppendResidualsDialog function displays a dialog to let you choose parameters.
24.
Choose histResids from the Residuals Data pop-up menu.
25.
Leave the X Wave pop-up set to “_calculated_”.
