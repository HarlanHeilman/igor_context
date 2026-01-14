# Table Style Macros

Chapter II-12 — Tables
II-272
Table Preferences
Table preferences allow you to control what happens when you create a new table or add new columns to 
an existing table. To set preferences, create a table and set it up to your taste. We call this your prototype 
table. Then choose Capture Table Prefs from the Table menu.
Preferences are normally in effect only for manual operations, not for automatic operations from Igor pro-
cedures. This is discussed in more detail in How to Use Preferences on page III-516.
When you initially install Igor, all preferences are set to the factory defaults. The dialog indicates which 
preferences you have changed, and which are factory defaults.
The Window Position and Size preference affects the creation of new tables only.
The Column Styles preference affects the formatting of newly created tables and of columns added to an 
existing table. This preference stores column settings for the point column and for one additional column - 
the first column after the point column in the prototype table. When you create a new table or add columns 
to a table, these settings determine the formatting of the columns.
The page setup preference affects what happens when you create a new experiment, not when you create a 
new table. Here is why.
Each experiment stores one page setup for all tables in that experiment. The preferences also store one page 
setup for tables. When you set the preferred page setup for tables, Igor stores a copy of the current experi-
ment’s page setup for tables in the preferences file. When you create a new experiment, Igor stores a copy 
of the preferred page setup for tables in the experiment.
Table Style Macros
The purpose of a table style macro is to allow you to create a number of tables with the same stylistic prop-
erties. Using the Window Control dialog, you can instruct Igor to automatically generate a style macro from 
a prototype table. You can then apply the macro to other tables.
Igor can generate style macros for graphs, tables and page layouts. However, their usefulness is mainly for 
graphs. See Graph Style Macros on page II-350. The principles explained there apply to table style macros also.
