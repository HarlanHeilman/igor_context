# Updating a Report Form

Chapter III-1 — Notebooks
III-27
The command
Notebook Notebook0 picture={Graph0(0,0,360,144), -1, 0}
creates a new picture of the named graph and inserts it into the notebook. The numeric parameters allow 
you to control the size of the picture, the type of picture and whether the picture is black and white or color. 
This creates an anonymous (unnamed) picture. It has no name and does not appear in the Pictures dialog. 
However, it is an Igor-object picture with embedded information that allows Igor to recognize that it was 
generated from Graph0.
The command
Notebook Notebook0 picture={PICT_0, 1, 0}
makes a copy of the named picture, PICT_0, stored in the experiment’s picture gallery, and inserts the copy 
into the notebook as an anonymous picture. The inserted anonymous picture is no longer associated with 
the named picture from which it sprang.
See Pictures on page III-509 for more information on pictures.
Updating a Report Form
In this example, we assume that we have a notebook that contains a form with specific values to be filled 
in. These could be the results of a curve fit, for example. This procedure opens the notebook, fills in the 
values, prints the notebook and then kills it.
// DoReport(value1, value2, value3)
// Opens a notebook file with the name "Test Report Form",
// searches for and replaces "<value 1>", "<value 2>" and "<value3>".
// Then prints the notebook and kills it.
// "<value 1>", "<value 2>" and "<value 3>" must appear in the form 
// notebook, in that order.
// This procedure assumes that the file is in the Igor folder.
Function DoReport(value1, value2, value3)
String value1, value2, value3
OpenNotebook/P=IgorUserFiles/N=trf "Test Report Form.ifn"
Notebook trf, findText={"<value 1>", 1}, text=value1
Notebook trf, findText={"<value 2>", 1}, text=value2
Notebook trf, findText={"<value 3>", 1}, text=value3
PrintNotebook/S=0 trf
KillWindow trf
End
To try this function, enter it in the Procedure window. Then create a formatted notebook that contains 
“<value 1>”, “<value 2>” and “<value 3>” and save it in the Igor User Files folder using the file name “Test 
Report Form.ifn”. The notebook should look like this:
Now kill the notebook and execute the following command:
DoReport("123", "456", "789")
This will print the form using the specified values.
