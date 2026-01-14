# Tags Attached to Offscreen Points

Chapter III-2 — Annotations
III-46
The Fat option specifies the width-to-length ratio. 0 or Auto gives the default ratio of 0.5. Larger numbers 
result in fatter arrows. If the number is small (say, 0.1), the arrow may seem to disappear unless the arrow 
length is made longer. Printed arrows can appear narrower than screen-displayed arrows.
Tag Line and Arrow Standoff
You can specify how close to bring the line or arrow to that trace with the Line/Arrow Standoff setting. You can 
enter an explicit distance in points. If you enter Auto or 0, Igor varies the distance according to the output device 
resolution and graph size. Use a value of 1 to bring the line as near to the trace as possible. When the wave is 
graphed with markers, you might prefer to set the standoff to a value larger than the marker size so that the line 
or arrow does not intersect the marker.
Tag Anchor Point
A tag has an anchor point that is on the tag itself. If there is an arrow or line, it is drawn from the anchor 
point on the tag to the attachment point on the trace. The anchor setting also determines the precise spot on 
the tag which represents the position of the tag.
The line is always drawn behind the tag so that if the anchor point is middle center the line doesn’t interfere 
with the text.
Tag Positioning
The position of a tag is determined by the position of the point to which it is attached and by the XY Offset 
settings in the Position tab. The XY Offset gives the horizontal and vertical distance from the attachment 
point to the tag’s anchor in percentage of the horizontal and vertical sizes of the graph’s plot area.
Once a tag is on a graph you can change its XY offset and therefore its position by merely dragging it. You 
can prevent the tag from being dragged by choosing “frozen” in the Position pop-up menu in the Position 
Tab. Igor freezes tags when it creates them for contour labels.
The interior/exterior setting used with textboxes does not apply to tags.
Tags Attached to Offscreen Points
When only a portion of a wave is shown in a graph, it is possible that the attachment point of a tag isn’t 
shown in the graph; it is “off screen” or “out-of-range”.
This usually occurs because the graph has been manually expanded or the axes are not autoscaled. Igor 
draws the attachment line toward the offscreen attachment point.
In this example graph, the attachment point at x=3.75 falls within the range of displayed X axis values:
middle center
left bottom
left center
left top
Peak Reading from wave1 
X = 1.5625 
Y = 0.999966
right bottom
right top
middle bottom
right center
middle top
