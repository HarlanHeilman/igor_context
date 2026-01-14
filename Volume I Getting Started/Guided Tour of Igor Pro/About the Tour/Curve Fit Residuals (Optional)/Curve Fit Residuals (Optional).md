# Curve Fit Residuals (Optional)

Chapter I-2 — Guided Tour of Igor Pro
I-57
15.
Click Do It.
The curve fit starts, does a few passes, and waits for you to click OK.
There is one small issue not addressed above. One of the bins contains zero; the square root of zero is, 
of course, zero. So the weighting wave contains a zero, which causes the curve fit to ignore that data 
point. It’s not clear what is the best approach for fixing that problem. Some replace the zero with a 
one. These commands replace any zeroes in the weighting wave and re-do the fit:
W_SqrtN = W_SqrtN[p] == 0 ? 1 : W_SqrtN[p]
CurveFit/NTHR=0 gauss fakeY_Hist /W=W_SqrtN /I=1 /D /R
This doesn’t change the result very much, since there was just one zero in the histogram:
Coefficient values ± one standard deviation
y0 
=-0.40357 ± 0.464
A 
=644.76 ± 7.98
x0 
=-0.0014186 ± 0.00996
width
=1.4065 ± 0.0115
Saving Your Work - Tour 3C
1.
Choose the FileSave Experiment As menu item.
2.
Navigate to your “Guided Tours” folder.
This is the folder that you created under Saving Your Work - Tour 1A on page I-21.
3.
Type “Tour 3C.pxp” in the name box and click Save.
Curve Fit Residuals (Optional)
The remaining guided tour sections are primarily of interest to people who want to use Igor programming 
to automate tasks. You may want to skip them and come back later. If so, jump ahead to For Further Explo-
ration on page I-64.
In the next section, as an illustration of how the history area can be used as a source of commands to gen-
erate procedures, we will create a procedure that appends residuals to a graph. The preceding section illus-
trated that Igor is able to automatically display residuals from a curve fit, so the procedure that we write in 
the next section is not needed. Still, it demonstrates the process of creating a procedure. In preparation for 
writing the procedure, in this section we append the residuals manually.
If the curve fit to a Gaussian function went well and if the gnoise function truly produces noise with a 
Gaussian distribution, then a plot of the difference between the histogram data and the fitted function 
should not reveal any curvature.
1.
To remove the automatically generated residual from the Gaussian fit in the previous section, Con-
trol-click (Macintosh) or right-click (Windows) directly on the residual trace at the top of the graph 
and select Remove Res_fakeY_Hist from the pop-up menu.

Chapter I-2 — Guided Tour of Igor Pro
I-58
2.
Choose the DataDuplicate Waves menu item.
3.
Choose fakeY_Hist from the Template pop-up menu. 
4.
In the first Names box, enter “histResids”. 
5.
Click Do It. 
You now have a wave suitable for containing residuals.
6.
In the history area of the command window, find the line that reads:
fit_fakeY_Hist= W_coef[0]+W_coef[1]*exp(-((x-W_coef[2])/W_coef[3])^2)
W_coef is a wave created by the CurveFit operation to contain the fit parameters. W_coef[0] is the y0 
parameter, W_coef[1] is the A parameter, W_coef[2] is the x0 parameter and W_coef[3] is the width 
parameter.
This line shows conceptually what the CurveFit operation did to set the data values of the fit destina-
tion wave.
7.
Click once on the line to select it and then press Return or Enter once.
The line is transferred to the command line.
8.
Edit the line to match the following:
histResids = fakeY_Hist -(W_coef[0]+W_coef[1]*exp(-((x-W_coef[2])/W_coef[3])^2))
In other words, change fit_fakeY_Hist to histResids, click after the equals and type 
fakeY_Hist - ( and then add a ) to the end of the line.
The expression inside the parentheses that you added represents the model value using the parame-
ters determined by the fit. This command computes residuals by subtracting the model values from 
the data values on which the fit was performed.
If the fit had used an X wave rather than calculated X values then it would have been necessary to 
substitute the name of the X wave for the “x” in the expression.
9.
Press Return or Enter.
This wave assignment statement calculates the difference between the measured data (the output of the 
Histogram operation) and the theoretical Gaussian (as determined by the CurveFit operation).
Now we will append the residuals to the graph stacked above the current contents.
10.
Choose GraphAppend Traces to Graph.
11.
Select histResids from the Y waves list and “_calculated_” from the X wave list.
12.
Choose New from the Axis pop-up menu under the Y Waves list.
13.
Enter “Lresid” in the Name box and click OK.
14.
Click Do It.
The new trace and axis is added.
Now we need to arrange the axes. We will do this by partioning the available space between the Left 
and Lresid axes.
15.
Double-click the far-left axis.
The Modify Axis dialog appears. If any other dialog appears, cancel and try again making sure the 
cursor is over the axis.
If you have enough screen space you will be able to see the graph change as you change settings in the 
dialog. Make sure that the Live Update checkbox in the top/right corner of the dialog is selected.
16.
Click the Axis tab.
The Left axis should already be selected in the pop-up menu in the top-left corner of the dialog.
17.
Set the Left axis to draw between 0 and 70% of normal.
18.
Choose Lresid from the Axis pop-up menu.
19.
Set the Lresid axis to draw between 80 and 100% of normal.
