# Zooming and Panning

Chapter I-2 — Guided Tour of Igor Pro
I-35
26.
Choose EditClear Cmd Buffer or press Command-K (Macintosh) or Ctrl+K (Windows).
When a command generates an error, it is left in the command line so you can edit and re-execute it. 
In this case we just wanted to clear the command line.
Synthesizing Data
In this section we will make waves and fill them with data using arithmetic expressions.
1.
Choose FileNew Experiment.
This clears any windows and data left over from previous experimentation.
2.
Choose the DataMake Waves menu item.
The Make Waves dialog appears.
3.
Type “spiralY” in the first box, press the tab key, and type “spiralX” in the second box.
4.
Change Rows to 1000.
5.
Click Do It.
Two 1000 point waves have been created. They are now part of the experiment but are not visible 
because we haven’t displayed them in a table or graph.
6.
Choose DataChange Wave Scaling.
The Change Wave Scaling dialog appears. We will use it to set the X scaling of the waves.
7.
If a button labeled More Options is showing, click it.
8.
In the Waves list, click spiralY and then Command-click (Macintosh) or Ctrl-click (Windows) spi-
ralX.
9.
Choose Start and Right in the SetScale Mode pop-up menu.
10.
Enter “0” for Start and “50” for Right.
11.
Click Do It.
This executes a SetScale command specifying the X scaling of the spiralX and spiralY waves. X scaling 
is a property of a wave that maps a point number to an X value. In this case we are mapping point 
numbers 0 through 999 to X values 0 through 50.
12.
Type the following on the command line and then press Return or Enter:
spiralY = x*sin(x)
This is a waveform assignment statement. It assigns a value to each point of the destination wave (spiralY). 
The value stored for a given point is the value of the right-hand expression at that point. The meaning of x 
in a waveform assignment statement is determined by the X scaling of the destination wave. In this case, x 
takes on values from 0 to 50 as Igor evaluates the right-hand expression for points 0 through 999.
13.
Execute this in the command line:
spiralX = x*cos(x)
Now both spiralX and spiralY have their data values set.
Zooming and Panning
1.
Choose the WindowsNew Graph menu item.
2.
If necessary, uncheck the From Target checkbox.
3.
In the Y Waves list, select “spiralY”.
4.
In the X Wave list, select “_calculated_”.
5.
Click Do It.
Igor creates a graph of spiralY’s data values versus its X values.
Note that the X axis goes from 0 to 50. This is because the SetScale command we executed earlier set 
the X scaling property of spiralY which tells Igor how to compute an X value from a point number.
