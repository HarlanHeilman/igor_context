# Histogram of White Noise

Chapter I-2 — Guided Tour of Igor Pro
I-53
Guided Tour 3 - Histograms and Curve Fitting
In this tour we will explore the Histogram operation and will perform a curve fit using weighting. The 
optional last portion creates a residuals plot and shows you how to create a useful procedure from com-
mands in the history.
Starting Guided Tour 3
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
We need something to analyze, so let’s generate some random values.
1.
Type the following in the command line and then press Return or Enter:
SetRandomSeed 0.1
This initializes the random number generator so you will get the same results as this guided tour.
2.
Type the following in the command line and then press Return or Enter:
Make/N=10000 fakeY = enoise(1)
This generates a 10,000 point wave filled with evenly distributed random values from -1 to 1.
Histogram of White Noise
Here we will generate a histogram of the evenly distributed “white” noise.
1.
Choose the AnalysisHistogram menu item.
The Histogram dialog appears.
2.
Select fakeY from the Source Wave list.
3.
Verify that Auto is selected in the Output Wave menu.
4.
Uncheck any checkboxes in the dialog that are checked, including the Display Output Wave check-
box.
5.
Click the Auto-set Bin Range radio button.
6.
Set the Number of Bins box to 100.
Note in the command box at the bottom of the dialog there are two commands:
Make/N=100/O fakeY_Hist;DelayUpdate
Histogram/B=1 fakeY,fakeY_Hist
The first command makes a wave to receive the results, the second performs the analysis. The Histo-
gram operation in the “Auto-set bin range” mode takes the number of bins from the output wave.
7.
Click the Do It button.
The histogram operation is performed.
Now we will display the results.
8.
Choose WindowsNew Graph.
9.
Select fakeY_Hist in the Y Waves list and “_calculated_” in the X list.
