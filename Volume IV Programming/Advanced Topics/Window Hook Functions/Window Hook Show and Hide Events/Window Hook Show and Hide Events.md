# Window Hook Show and Hide Events

Chapter IV-10 — Advanced Topics
IV-304
There are several ways to prevent a window being killed. You might want to do this in order to enforce use 
of a Done or Do It button, or to prevent killing a control panel while some hardware action is taking place.
The best method is to use /K=2 when creating the window (see Display or NewPanel). Then the only way 
to kill the window is via the DoWindow/K command, or KillWindow command. In general, you would 
provide a button that kills the window after checking for any conditions that would prevent it.
The KillVote event is more flexible but harder to use. It gives your code a chance to decide whether or not 
killing is allowed. This means the user can close and kill the window with the window close box when it is 
allowed.
Returning 2 for the window kill event is not recommended. If you have old code that uses this method, we 
strongly recommend changing it to return 2 for the killVote event. New code should never return 2 for the 
kill event.
As of Igor Pro 7, returning 2 for the window kill event does not prevent the window from being killed. If you 
have old code that uses this technique, change it to return 2 for the killVote event instead.
Window Hook Show and Hide Events
Igor sends the show event to your hook function when the affected window is about to be shown but is still 
hidden. Likewise, Igor sends the hide event when the window is about to be hidden but is still visible. Other 
events, notably resize or move events, may be triggered by showing or hiding a window and may be sent 
before the change in visibility actually occurs. Here is an example that illustrates this issue:
Function MyHookFunction(s)
STRUCT WMWinHookStruct &s
strswitch(s.eventName)
case "resize":
GetWindow $(s.winName) hide
if (V_value)
Print "Resized while hidden"
else
Print "Resized while visible"
endif
break
case "moved":
GetWindow $(s.winName) hide
if (V_value)
Print "Moved while hidden"
else
Print "Moved while visible"
endif
break
case "hide":
print "Hide event"
break
case "show":
print "Show event"
break
endswitch
return 0
// Don't interfere with Igor's handling of events
End
Function MakePanelWithHook()
NewPanel/N=MyPanel/HIDE=1
