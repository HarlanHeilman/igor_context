# Creating Synthetic Data

Chapter I-2 — Guided Tour of Igor Pro
I-46
Guided Tour 2 - Data Analysis
In this tour we will concentrate on the data analysis features of Igor Pro. We will generate synthetic data 
and then manipulate it using sorting and curve fitting.
Starting Guided Tour 2
1.
If Igor is already running, activate it and choose FileNew Experiment.
In this case, skip to step 2.
2.
Double-click your Igor64 alias or shortcut.
Instructions for creating this alias or shortcut can be found under Creating an Igor64 Alias or Short-
cut on page I-13.
On Windows, you an also launch Igor64 using the Start menu.
3.
Choose MiscPreferences Off.
Turning preferences off ensures that the tour works the same for everyone.
Creating Synthetic Data
We need something to analyze, so we generate some random X values and create some Y data using a math 
function.
1.
Type the following in the command line and then press Return or Enter:
SetRandomSeed 0.1
This initializes the random number generator so you will get the same results as this guided tour.
2.
Type the following in the command line and then press Return or Enter:
Make/N=100 fakeX = enoise(5)+5,fakeY
This generates two 100 point waves and fills fakeX with evenly distributed random values ranging 
from 0 to 10.
3.
Execute this in the same way:
fakeY = exp(-(fakeX-4)^2)+gnoise(0.1)
This generates a Gaussian peak centered at 4.
4.
Choose the WindowsNew Graph menu item.
5.
If you see a button labeled Fewer Choices, click it.
6.
In the Y Waves list, select “fakeY”.
7.
In the X Wave list, select “fakeX”.
8.
Click Do It.
The graph is a rat’s nest of lines because the X values are not sorted.
9.
Double-click the red trace.
The Modify Trace Appearance dialog appears.
10.
From the Mode pop-up choose Markers.
11.
From the Markers pop-up menu choose the open circle.
