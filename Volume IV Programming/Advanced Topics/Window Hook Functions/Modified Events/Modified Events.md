# Modified Events

Chapter IV-10 — Advanced Topics
IV-299
Mouse Events
Igor sends mouse down and mouse up events with the eventCode field of the WMWinHookStruct struc-
ture set to 3 or 5. With rare exceptions, your hook function should act on the mouse up event. Consider, for 
instance, a click on a button- the button's action should occur when you release the mouse button.
One exception is for a contextual click, that is, right-click on Windows, or Ctrl-click on Macintosh. On Mac-
intosh, a contextual menu should be displayed on the mouse-down event. On Windows, the contextual 
menu should be shown on mouse-up, but in Igor confoundingly, the mouse-down is not delivered until the 
mouse-up has occurred. Thus, displaying a contextual menu on mouse-down on Windows will do the 
Right Thing.
A mouse click on a table cell causes Igor to send a mouse down event to your hook function before Igor acts 
on the click, allowing you to block the action by returning a non-zero result. Igor then sends a mouse down 
event after Igor has acted on the click.
In Igor6, the mouse down event was sent only when the selection was finished, that is, after the mouse up 
event occurred. If you have existing code that uses the mouse down event to get a table selection, you need 
to change your code to use the mouse up event.
Modified Events
A modified event is sent when a modification to the window has been made. This is sent to graph and note-
book windows only.
As of Igor Pro 9.00, modified events are sent to both top-level graphs and notebooks and also to graph and 
notebook subwindows. That means that a window hook on a control panel window could receive a modi-
fied event for a notebook or graph subwindow in the panel. In that case, the winName member of the 
WMWinHookStruct structure is set to the subwindow path.
It is an error to try to kill a graph or notebook window or subwindow from the window hook during the 
modified event.
The modified event is issued in Igor's outer loop when it is idling (i.e., after any processing is finished). This 
means that, if you modify a graph or notebook programmatically, the modified event is not sent to hook 
functions until Igor returns to idling.
Most changes to the graph are reported by the modified event, but not all:
1. At present, only in top-level windows, not in graph subwindows.
2. But see events 18, 19, 20, and 21 in Named Window Hook Events on page IV-295.
In Igor Pro 9.00 and later, if you modify a notebook from a modified event, this does not cause recursion 
into your hook function.
If your hook function modifies a graph window, this may trigger another modify event after your function 
returns from the first. Without something to stop it, this will create a cascade of modified events. Checking 
Action
Sends Modified Event
Dragging axis
Yes
Dragging plot area
Yes
Dragging trace
Sent only after drag ends
Dragging annotation
Yes - see note 1
Adding, removing or changing a control
No
Showing or hiding drawing tools
No - see note 1
Showing or hiding info panel
No - see note 1
