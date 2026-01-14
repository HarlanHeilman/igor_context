# Adding a Tag

Chapter I-2 — Guided Tour of Igor Pro
I-17
4.
Change the second instance of “yval” to “Magnitude”.
The annotation annotation text should now be “\s(yval) Magnitude”.
5.
Click the Frame tab and choose Box from the Annotation Frame pop-up menu.
6.
Choose Shadow from the Border pop-up menu.
7.
Click the Position tab and choose Right Top from the Anchor pop-up menu.
Specifying an anchor point helps Igor keep the annotation in the best location as you make the graph 
window bigger or smaller.
8.
Click Do It.
Adding a Tag
1.
Choose the GraphAdd Annotation menu item.
2.
Choose Tag from the Annotation pop-up menu in the top-left corner of the dialog.
3.
Click the Text tab, and in the annotation text entry area of the Text tab, type “When time is ”.
4.
Choose Attach Point X Value from the Dynamic pop-up menu in the Insert area of the dialog.
Igor inserts the \0X escape code into the annotation text entry area.
5.
In the annotation text entry area, add “, Magnitude is ”.
6.
Choose Attach Point Y Value from the Dynamic pop-up menu.
Igor inserts the \0Y escape code into the annotation text entry area.
7.
Click the Frame tab and choose None from the Annotation Frame pop-up menu.
8.
Click the Tag Arrow tab and choose Arrow from the Connect Tag to Wave With pop-up menu.

Chapter I-2 — Guided Tour of Igor Pro
I-18
9.
Click the Position tab and choose “Middle center” from the Anchor pop-up menu.
The dialog should now look like this:
10.
Click Do It.
The graph should now look like this:
The tag is attached to the first point. An arrow is drawn from the center of the tag to the data point 
but you can’t see it because it is hidden by the tag text.
11.
Position the cursor over the text of the tag.
The cursor changes to a hand. This indicates you can reposition the tag relative to the data point it is 
attached to.
