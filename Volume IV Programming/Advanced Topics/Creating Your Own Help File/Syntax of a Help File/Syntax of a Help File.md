# Syntax of a Help File

Chapter IV-10 — Advanced Topics
IV-256
3.
Enter your help text in the new file.
4.
Save and kill the notebook.
5.
Open the file as a help file using FileOpen FileHelp File.
When you open the file as a help file, it needs to be compiled. When Igor compiles a help file, it scans through it 
to find out where the topics start and end and makes a note of subtopics. When the compilation is finished, it 
saves the help file which now includes the help compiler information.
Once Igor has successfully compiled the help file, it acts like any other Igor help file. That is, when opened it 
appears in the Help Windows submenu, its topics will appear in the Help Browser, and you can click links to 
jump around.
Here are the steps for modifying a help file.
1.
If the help file is open, kill it by pressing Option (Macintosh) or Alt (Windows) and clicking the close but-
ton.
2.
Open it as a notebook, using FileOpen FileNotebook.
Alternatively, you can press Shift while choosing the file from FileRecent Files. Then, in the resulting 
dialog, specify that you want to open the file as a formatted notebook.
3.
Modify it using normal editing techniques.
4.
Choose Save Notebook from the File menu.
5.
Click the close button and kill the notebook.
6.
Reopen it as a help file using FileOpen FileHelp File.
Alternatively, you can press Shift while choosing the file from FileRecent Files. Then, in the resulting 
dialog, specify that you want to open the file as a help file.
Syntax of a Help File
Igor needs to be able to identify topics, subtopics, related topics declarations, and links in Igor help files. To do 
this it looks for certain rulers, text patterns and text formats described in Creating Links on page IV-257. You 
can get most of the required text formats by using the appropriate ruler from the Igor Help File Template file.
Igor considers a paragraph to be a help topic declaration if it starts with a bullet character followed by a tab 
and if the paragraph’s ruler is named Topic. By convention, the Topic ruler’s font is Geneva on Macintosh 
or Arial on Windows, its text size is 12 and its text style is bold-underlined. The bullet and tab characters 
should be plain, not bold or underlined.
The easiest way to create a new topic with the right formatting is to copy an existing topic and then modify it.
Once Igor finds a topic declaration, it scans the body of the topic. The body is all of the text until the next 
topic declaration, a related-topics declaration, or the end of the file. While scanning, it notes any subtopics.
Igor considers a paragraph to be a subtopic declaration if the name of the ruler governing the paragraph 
starts with “Subtopic”. Thus if the ruler is named Subtopic or Subtopic+ or Subtopic2, the paragraph is a 
subtopic declaration. By convention, the Subtopic ruler’s font is Geneva on Macintosh or Arial on Windows, 
its text size is 10 and its text style is bold and underlined. Text following the subtopic name that is not bold 
and underlined is not part of the subtopic name.
The easiest way to create a new subtopic with the right formatting is to copy an existing subtopic and then 
modify it.
Igor considers a paragraph to be a related-topics declaration if the ruler governing the paragraph is named 
RelatedTopics and if the paragraph starts with the text pattern “Related Topics:”. When Igor sees this 
pattern it knows that this is the end of the current topic. The related-topics declaration is optional. Prior to 
Igor Pro 4, Igor displayed a list of related topics in the Igor Help Browser. Igor Pro no longer displays this 
list. The user can still click the links in the related topics paragraph to jump to the referenced topics.
