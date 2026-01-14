#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3	// Use modern global access method.
#pragma moduleName= WMMultiPeakFit
#pragma version=3.03
#pragma IgorVersion=9.00
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#include <PeakFunctions2> version>=3.02
#include <Manual Peak Adjust> version>=1.2
#include <Peak AutoFind> version>=5.13
#include <AutoMPFit GUI> version>=1.00

//*************************************** 
// 	JW 090708 version 2.01
//		Added background information to results report list and notebook
//	JW 080104 first beta release of version 2.00
//	JW 080109:	beta version 2
//		Fixed bug: If Do Fit is clicked before any peaks have been added to the list, an error results.
//		Fixed bug: If a graph is selected in the Start Multi-peak Fit panel, the graph is killed, then Continue is clicked,  Bad Things happen.
//		Fixed bug: If there are no peaks in the list and you try to use the g item from the marquee, a bad peak is created.
//		Fixed bug: Deleting the last peak left the last peak in the fit curve on the graph.
//	JW 080110:	beta version 3
//		Fixed bug: If you open the Baseline row before adding any peaks, you get a NULL wave reference for the auto-locate wave.
//		Fixed bug: If you close the control panel while the Edit or Add Peaks windows is open, an error results. Now, closing
//			the control panel or the graph also closes the Edit or Add Peaks window.
//		Fixed bug: If you click the Peak Results button when the Do Fit button is not enabled, an error results.
//		Added contextual menu to the peak list with Delete Peak when you click on a peak container row.
//		Added help message when the Do Fit button is not enabled telling how to add peaks.
//	JW 080121:	beta version 4
//		Changed default baseline type from "None" to "Constant"
//		Changed default panel position to "Right"
//		Added ability to right-click a peak in the Add or Edit graph and select Remove.
//		Right-click on peak list offers either "Delete Selected Peaks" or "Delete Peak N" where N is the number of the peak clicked on.
//		Changed lblPosMode for residuals and peaks to 1 (absolute mode).
//		Drawing the gray lines on the graph now restores the existing draw layer selection. This depends on a feature added to Igor 6.1 on 1/25/2008.
//		Changed delete key handling to use new listbox event 12.
//	JW 080130:	beta version 5
//		Added Set Waves from Trace menu to the Start Multi-peak Fit panel. Shown only when From Target is checked and the target window is a graph.
//		Fixed bug: when From Target was checked, it was impossible to select any waves that weren't in the first trace in the target graph.
//	JW 080131:	beta version 5
//		Fixed bug: Bringing up the Add or Edit Peaks graph failed to restore the current data folder properly.
//	JW	080403:	beta version 7
//		Fixed bug: New peaks created in the Add or Edit Peaks graph had NaNs or zeroes where they shouldn't have if you chose either ExpModGauss or
//			ExpConfExp peak functions.
// 		Fixed problem: If graph had log X axis, the fit curve went kooky after the fit was finished.
// 	JW 080501:	patch for beta version 7
//		Fixed bug: Selecting baseline "None", then clicking Auto-locate Peaks Now would fill the fit curve and residuals with NaNs because it was setting
//		the baseline back to "Constant" when it shouldn't have, and without properly initializing the coefficient wave.
//	JW 080508:	beta version 8
//		Added LogNormal peak shape. That involved changing only PeakFunctions2.ipf
//	JW 080509:	beta version 9
//		Added background curve to graph.
//	JW 080513:
//		The Add or Edit graph now alters only peaks that are modified or added during the Add or Edit session.
// 	JW 080515:
//		Improved FuncFit error control.
//	JW 080520:
//		Results graph button on Results control panel.
//		Added Help button to the Start Multi-peak Fit panel.
//	JW 080522: 	beta version 10
//		Fixed a bug in reported errors in results table and delimited text file.
// 	JW 080527:	beta version 10
//		Added Options disclosure and support for mask and weight waves.
//	JW 090127:	beta version 11
// 		Needed /Z flag on Wave statements for weighting and masking waves.
//
// JW 091012:	Release 2.01
//		Removed two vestigial lines in MPF2_DoMPFit() that caused a "WAVE Reference to <wave name> failed" error message.
// JW 091229:	Release 2.02
//		Added abs() to calculation of npnts in MPF2_AddFitCurveToGraph() to handled reversed X values. But the Add/Edit window still doesn't handle this well (at all!).
// JW 100211:	Release 2.03
//		Added Fit Curve Points control to the Options section of the control panel.
//		Changed tab-delimited output notebook tab stops to 108 points.
// JW 100329: 	Release 2.04
//		Added handling for user renaming the graph window.
//		Added an additional sanity check to MPF2_GraphMarqueeDef for cases where no graph window is open.
// JW 100419:	Release 2.05
//		Added Total Area printout on results window
//		Fixed bug: Include Background Info checkbox in the Results window didn't move when the window was re-sized.
//		The mask wave was specified using /W instead of /M!
// JW 100426:	Still release 2.05, since we haven't released a new beta yet
//		Fixed out-of-bounds access to HoldStrings wave in MPF2_HoldStringForPeakListItem()
// JP 100622:	Still 2.05, more out-of-bound HoldString access fixes in PeakListClosingNotify() and PeakListOpenNotify().
// JW 100713: Release 2.06
//		Fixed bug: If you re-used a previous set, it would wipe out all the baseline coefficients except the first.
//		Fixed another index-out-of-range error.
//		Fixed bug: Closing and re-opening the panel (using a previously saved set) failed to restore holds.
//		Added ability to start from a previous set.
//		If you clicked the Peak Results button before a fit was done, the current data folder was not restored properly.
//		Added checkpoint menu.
// JW 100809:
//		Fixed out-of-range wave index error if the center of a peak isn't within the range of the X data (most likely a bad fit).
//		Fixed bug: initializing from a previous set resulted in fitting to the waves in that previous set.
// JW 100812:	 version 2.07		bumped the version number because we released 2.06 with 6.20 beta 4
//		Fixed a couple more out-of-range wave index bugs.
// JW 100907:
//		Fixed yet another out-of-range wave index bug, calculating attachment point for peaks that are out of the range of fitting.
// JW 100914: Release 2.08
//		Fixed bug: reversed X range caused Add or Edit Peaks window to fail to show existing peaks. 
//		Added Background-subtracted data set button to Results window.
// JW 101207: Release 2.09
//		Fixed bug in MPF2_AddPeaksToGraph where an index-out-of-range error occurs if the estimated peak info is bad. I don't know why
//			the peak info is bad, but Peter Dedecker sent an example.
//		Fixed errors when only one cursor is on the graph with the Use Graph Cursors checkbox checked.
//		Now the Edit or Add Peaks panel ignores a click without a drag, which previously created a peak with zero width. That
//			fixes the origin of the problem reported by Peter Dedecker.
// JW 110111: Release 2.10
//		Fixed bug in Add or Edit window: if the X values were backwards (either negative X scaling, or decreasing values in X wave) the
//			Add or Edit graph didn't use the marquee width as the range.
// JW 110217: Release 2.11
//		Added Option: Display Peaks Full X Width of Graph checkbox added to the Options area of the main panel.
// JW 110714: Version 2.12
//		Changed method for updating graph curves after editing coefficients in the list. Old method tried to evaluate the old coefficients for the changed peak or baseline,
//			then subtract it from the curve, then evaluate the new coefficients and add it to the curve. This was fragile. Now it updates the coefficient wave involved, then
//			simply re-evaluates the curves from scratch. That way, if something goes wrong at some point, it's self-correcting.
// JW 120227: Version 2.13
//		Fixed bug: Mask wave popup assigned result to Weight wave global string. This would only affect reconstruction of the panel; the actual mask wave was correctly
//			recorded in the structure used to transmit the wave to the fit.
//		Added notation of the weight and mask waves to the results notebook.
//		Fixed bug: The Graph button would put the baseline wave on the graph even if the current setting for the baseline function was None.
// JW 120612: Version 2.14
//		Changed behavior (fixed design bug): The function to compute derived parameter values is now called with the correct number of rows in the output wave.
// NH 120717: Version 2.15
// 		Added constraints.  New functions at the bottom of the file, plus changes to some existing functions.  Added new controls ("Apply Constraints" checkbox and "Inter-Peak Constraints"),
//			and increased the size of the MultiPeakFit listbox.  The "Apply Constraints" checkbox controls the visibility of the new columns in the listbox, the size of the panel and whether or not
//			the constraints are applied
//		Fixed a bug in MPF2_RestoreCoefWavesFromBackup().  The baseline coef backup wave might not get created in MPF2_BackupCoefWaves(), but Restore 
//			always tried to create it
// 		Fixed a bug that peaks deleted via the "Add Or Edit Peaks" dialog are not removed from the peak axis on the graph.  
//		Fixed a bug that HoldStrings grew as peaks were added and removed.
//		Fixed a bug that once Use Graph Cursors was checked the cursors were applied even if Use Graph Cursors is unchecked
//		Fixed a few more bugs only revealed with heavy use
// JW 130429: Version 2.16
//		Fixed bugs caused by adding prefixes to wave names that were too long after adding the prefix.
//		Added check for problems with proposed name for baseline-subtraced wave.
// JW 130429: Version 2.17
//		Relaxed the requirement that X values be monotonic- used to be that duplicate X values failed the monotonicity test, now
//		they are allowed. A quick test showed that the auto-peak detector is OK with that.
// JW 140313: Version 2.18
// 		Now the Use Graph Cursors checkbox adjusts the fit panel's notion of the X Range; you don't have to click the Auto-locate Peaks Now button
//		to make it notice the checkbox.
// NH  140317: Version 2.19
//		Fixed an error when a MultiPeakFit2Panel is killed, then re-created using the Start Multi-peak Fit dialog.  An attempt to update a non-existing panel 
//			generated an error.
// JW 140520: Version 2.20
//		MPF2_AutoMPFit now optionally computes the derived parameters that may include things like FWHM or peak area. Also now optionally computes
//		fit curves for each fit in the batch.
// NH  140610: Version 2.21
//		Added copying a backup copy of the constraint text wave passed to FuncFit in the current set's package folder. Added the ability to set a single set of constraints in the
//		MPF2_AutoMPFit. Fixed a couple of cases where execution paths could lead to the current directory not being maintained by a function.
// NH	150204: Version 2.22
//		Changed the Inter-peak constraints SetVariable control into a notebook - a painful process.  Did this to allow for inter-peak constraints that are > 255 characters.  Made 
//		changes to re-size, disclose constraints and version update hook functions.  Now the panel will only grow horizontally when the Apply Constraints checkbox is checked if
//		the window below a certain width.  The old way caused the panel width to change whenever Apply Constraints was checked, whether necessary or not.  This seems a less
//		intrusive approach. 
// JW 150405: Version 2.23
//		MPF2_AutoMPFit() needed Make/O for derived results because a couple of the initial guess modes copy the previous result data folder when making the next one.
// JW 150410: Verstion 2.24
//		MPF2_AutoMPFit() now creates MPFChiSquare variable in each result folder
// 		MPF2_AutoMPFit() now accepts optional inputs startPoint and endPoint to set the same subrange for every data set.
// JW 150930: Version 2.25
//		Now refuses to apply auto peak finder to data sets with fewer than 21 points.
// NH 160411: Version 2.26
//		Now uses an xy pair for "fit_" and "Bkg_" waves when the graph's x-axis is in log scale.  This is to prevent monstrous 
//		waves when log scaled data cover a wide magnitude of data.
// JP 160517: Version 2.27
//		Uses SetWindow sizeLimit for Igor 7. Fixed some control positions and min sizes.
// JW 160524: Version 2.28
//		Added DoUpdate to MPF2_SetDataPointRange so that the axis range will be correct when gotten using GetAxis.
// JW 160909: Version 2.29
//		Fixed a couple of places where the wave to pass into the derived paramFunc (PeakFuncInfo_ParameterFunc) was being made with four rows instead of
//			checking the length of the list of parameter names and using that for the number of rows.
// JW 180320: version 2.30
//		Remove clearing of FuncListString global in MPF2_GetNParamsForFuncs. Turns out that a user depends on the global and clearing it there
//		renders it less useful. It appears that it was created as a debugging aid, but since it's useful, let's keep it and not mess with it.
// JW 180328: version 2.31
//		Now you can enter "Point for Point" in the Fit Curve Points SetVariable control (in the Options area) to request that the fit
//		curve have the same number of points as the data wave, and use the X data wave if present.
// JW 180713: version 2.32
//		Fixed a bug: clicking the Revert to Guesses button failed to update the coefficient values in the list.
// JW 190410: version 2.33
//		Added new constraint choices: All widths equal and paired locations
//		Moved the "interpeak constraints" notebook window to its own small panel along with checkboxes for the new options
// JW 180727: version 2.40
//		Reviewed the use of data folders to make it more likely that the current data folder is always restored (or never changed)
//			while the MPF2 code is running. Hopefully didn't introduce too many bugs.
//		Added the Resume existing set menu item allowing the user to close the graph and panel for a set, then go back to working on it later.
//		The data graph is now created with /K=1 to discourage the saving of recreation macros, which probably don't work well.
//		Expanded the minimum size of the peak list control panel to allow a (somewhat) nicer layout.
//		Moved the Use Graph Cursors checkbox and the Help button to a position where perhaps people will notice them more readily.
//		Added Table button to the Results panel that constructs a table with coefficients, etc. This will allow users to copy numbers from
//			the coefficient waves for their own purposes.
// JW 181022: version 2.41
// 	In function doMPF2FitCurves(), added /O flag to Duplicate command to avoid errors during execution of MPF2_AutoMPFit()
// JW 190716: version 2.42
//		Fixed run-time errors in the Start panel if the From Target checkbox is checked and there are no traces available in the target window.
// JW 191120: version 2.43
//		Fixed bug: Opening up the options portion of the Locate Peaks group box failed because
//			the definition of a subwindow guide had been changed, but that change wasn't reflected
//			in the action of the disclosure control.
//	JW 191206: version 2.44
//		Fixed bug: Use Graph Cursors checkbox was being ignored because the enclosing panel subwindow was changed but the calls
//			to ControlInfo for that checkbox weren't updated to reflect the new panel path.
// JW 200220: version 2.45
//		Attempt to make the coefficient printouts in the Results panel and notebook show a number of digits
//			appropriate to the estimated error for that parameter.
//		Added Options control to set the digits used in the coefficient list.
// JW 200311: version 2.46
//		The Resume Set menu item built a graph that didn't have graph cursors, when the original did have.
//		The Resume Set menu item cursors were not functional.
//		The Resume Set menu item failed to set the graph's userdata holding the set number, resulting in
//			potentially a wide range of problems.
//		In the Start Multi-peak Fit control panel, if you choose Initialization from an existing set, an attempt
//			is made to make sure the point ranges in use in the existing set are compatible with the new set.
//			If the existing set waves are still available, the point range is translated to an X range and that
//			X range is applied to the new waves if at all possible. If the existing set waves are missing, then
//			the range is set to be the entire range of the new waves.
// ST 200327: version 2.47
// 		More Constraints panel: Parse constraints with '=' into a <,> pair on the fly and parse constraints list
//			from ';' to '\r' upon display for better readability. Minor layout changes of the panel controls.
//		The 'More Constraints' button is now enabled/disabled when 'Apply Constraints' is checked/unchecked to emphasize their relation.
// 		Fixed bug: Empty constraints could be created (via space / return) inside the More Constraints panel.
//		Fixed bug: The results panel would break upon resuming a checkpoint, so it is forced to close instead.
//		The Use Graph Cursors checkbox now cannot be activated if cursor A and/or B are not on the graph.
//		Fixed bug: Revert to Guesses was failing at the start of a session and when some peak types changed before pressing Do Fit.
//		Fixed bug: A non-existed graph could stay selected under 'Use Graph' in the start panel which leads to a several errors.
// ST 200416: version 2.48
// 		Make it possible to have a baseline function without active coefficients. For this, the baseline must have one parameter and
//			the baseline function name must end with '_FixCoef_BLFunc'.
//		The check for out-of-range peaks has been moved from the cursor hook function into the DoFitButton function. If there are
//			out-of-range peaks a message appears which asks the user whether such peaks should be deleted.
//		Fixed bug: All peaks were detected as out of range if the delta scaling or x-range was negative.
//		Resume Fit panel: If the data is missing then the original data location and name is displayed to aid the user.
//		Backgrounds can now have initialization functions which are called once upon selection (to give initial guesses for example).
//		The raw y- and x-data is passed to background functions now. Goes together with an extended definition in
//			PeakFunctions2 version 2.03.
//		Fixed bug: Negative values in the fit results where not returned with the right precision (precision defaulted to 1).
//		Now cursors A and B can only be placed on the raw y-data trace when the 'Use Graph Cursors' checkbox is set
//			to prevent misbehavior of the fit caused by to cursors on peak traces etc.
// ST 200523: version 2.49
//		Fixed bug: The auto-guess for the height of both PCI and DS peak shapes was wrong.
//		Fixed a bug in the main panel: The right-click menu offered the option to delete the baseline.
//		Fixed a bug in the Shirley and Tougaard background functions: The calculation failed for data with NaNs.
// 		Fixed panel layout issues in the Start New Fit panel: Some controls were overlapping and others were misaligned.
// 		Fixed panel layout issues in the Main panel and an error when the Apply Constraints checkbox was toggled with the
//			Auto-Locate Peaks options open.
//		Fixed bugs in the Edit or Add Peaks panel: - Error when pressing Redo after an Undo action deletes the last available peak.
//			- Clicking without dragging a peak disabled the cancel and done buttons, and fails to resume 'peak-highlighting' mode.
//			- Undo and Redo could be clicked while in peak-drag mode.
//			- It was possible to press Redo once too often when a peak was added after pressing Undo.
//			- The right-click menu entry 'Add or Edit Peaks' was displayed even with the MPF2 panel closed.
//		Fixed bug: The Revert to Guesses button threw a missing-wave error after adding a new peak but before pressing Do Fit.
//		Fixed bug: The Revert to Guesses button copies the wrong coef values when the number of peaks has changed.
//		The results-table output options are now within the MultipeakFit 2 Results panel and not in a separate panel.
//		The Revert to Guesses button is renamed to 'Revert' and a help tool-tip is added to explain the buttons functionality.
//		It is now possible to overwrite baseline-subtracted data from the results panel.
//		Fixed bug in the Make Results Graph panel: The Graph Title option was not honored.
//		The Start New Fit and Resume Fit panels are now merged into one panel.
//		Fixed a bug with Auto-locate Peaks, where the size of HoldStrings was not updated with the baseline set to 'none'.
//		Fixed a bug in the Results Panel: The Include Background Info now properly updates the panel to include the background values.
//		Renaming the raw data waves while working with MPF2 is now possible, i.e., the set data and variables adapts to the new names.
//		Added the option to locate missing waves in a different folder to the Start and Resume Panel.
//		Fixed a bug in the Start or Resume Panel: It was possible to resume a XY wave set even when (only) the x wave was missing.
//		Fixed a bug when a new set with initialization from previous set was started: XPointRangeBegin and XPointRangeEnd could end
//			up out-of-bounds if the new data wave is smaller than the wave from the initialization set.
//		Fixed bug: Starting a new set with initialization from a previous set left the fit waves ('fit_','Bkg_','res_') from the
//			initialization set inside new set folder, cluttering up the folder with unneeded waves. These waves are cleaned up now.
//		Fixed bug: Starting a set with initialization or resuming a set does not set any hold checkboxes from the previous sets.
//		Fixed bug with the results-table output: The Location for Waves setting was not honored. Additionally, the folder selection has new options now.
//		Fixed bug: Checkpoint folders are excluded now from the Resume Set list.
//		Added buttons for decreasing or increasing peak numbers of selected inter-peak constraints in the More Constraints panel.
//		Fixed a bug with the Results Notebook output where inter-peak constraints lead to wave assignment errors.
//		Fixed bug in the results panel: the output precision was set wrong if the sigma value is zero.
//		Added right-click menu to the Results Panel to directly copy values to the clipboard.
//		Fixed bug: When using an x wave and the 'point for point' size option then the background wave was not written to.
//		Fixed bug: Using an x wave and the 'point for point' size option failed to set a proper x scaling for the fit wave.
//		Fixed bug: Some graph elements such as the background trace did not update while the fit's end-message panel is displayed.
//		Fixed bug: Log scale together with a fixed no. of points in the Fit Curve Points setting gave a wrong dx value for the fitx wave.
//		Now log-scale fit waves are used even for inverse raw data scaling (i.e., when rightx < leftx).
//		Show a mirror axis for all axes and display the current chi square value in a text box.
//		Added a Notebook Overview of All Sets button to the starter panel to create a summary of all available sets.
//		Only a small fraction of the peak may be displayed in the graph if the initial guess and the fitted width are very different.
//			For the internal peak shapes a better size estimate using the current fit coefficients is calculated in MPF2_GetGaussWidthFromPeakCoefs().
//		Added an option to the MPF panel to control the fit tolerance (V_FitTol).
//		Added the possibility to auto-locate peaks in the residuals.
//		Added a button to add or edit peaks in the MPF panel as well to make this functionality more visible.
//		By dragging a marquee outside the (cursor-limited) fit range it was possible to add peaks there, which threw up the peak handling.
//			Now a warning is displayed instead.
//		Added Expand All and Collapse all options to the popup menu for expanding/collapsing all peak coefficients of the peak list.
//		Added a more convenient step size for the Noise Level (1/10 the current value) and Min Fraction (0.01) SetVariable controls.
//		Now it is possible to manually create and edit asymmetric peak shapes within the Add or Edit Peaks panel.
//		Added an option to export the fit data to the user folder while creating the results graph.
//		Fit curves now are updated live when moving a cursor.
//		Fixed bug: Peak tags are correctly placed at position lines even for peaks which are outside the fit range.
// ST 200523: version 2.50
//		Bumped all version numbers to 2.5, and made sure the update panel routines don't ask again if the user presses No during the update request.
//		Now peak and background function can display status messages by calling MPF2_DisplayStatusMessage(MessageStr, setDF).
//		Fixed bug: Peaks are displayed partially even outside the marked fit range, when both cursors are placed far away from the peak center.
//		Fixed bug: It was possible to start a MPF set with different sizes for the x and y data waves, which leads to errors later on.
//		The the menu entry to start or resume MPF is now in the main Analysis menu.
//		The precision calculation of MPF2_PrintNumberWithPrecision() outputs now one digit more to guarantee overlap of the displayed digits
//			with the significant digit of the error.
//		Fixed bug: Starting a set with initialization from a previous set which had a completely different x axis may give an out-of-range error.
//		Fixed bug: The From Target checkbox in the starter panel did not properly select the Use Graph and Initialization parameters.
//		Fixed bug: A too small range for the individual peaks was displayed for some peak types when the width coefficients got negative.
//		Fixed bug: Using Auto-locate Peaks may apply stale hold settings from an old HoldStrings wave -> cleared now when using auto-locate peaks.
//		Fixed bug: The temporary SavedCoefWave was created in the root folder instead of the MPF2 folder, which interfered with some background functions.
//		Fixed bug: Could not properly delete peaks which were displayed in a results graph as well.
//		Fixed bug: Find More in Residuals did not set the correct peak type sometimes.
//		Fixed bug: Deleting a peak would re-run the initialize function for backgrounds.
// JW 200716: Version 3
//		Stephan Thürmer has made so many enhancements, I think it deserves a new major version number!
// ST 200804: version 3.00
//		Implemented initialization of background functions into MPF2_AutoMPFit() as well.
//		Fixed bug: If a peak position is changed by manual editing in the peak list or after a fit then the out-of-range peak finder and the Add or Edit Peaks
//			panel still think the peak is at its old position since values from W_AutoPeakInfo are used. Now the new position is copied over from the coef waves.
//		The Add or Edit Peaks panel now approximately reads the current position, height, width and skew from the peak shape.
//		Now the x range is zoomed to the previous fit range when resuming a fit set.
//		Fixed bug: It was possible to start the fit with a multi-dimensional wave. A selection filter and check for 1D waves is in place now.
//		Added 'Zoom to Fit Range' marquee-menu entry which zooms the graph to the fit wave.
//		Added possibility to delete the last and all Multipeak Fit set folders to start over.
//		Fixed bug: 'Unload Multipeak Fit Package' now closes all panels and unloads old MPF2 procedures as well.
//		Fixed bug: An occasional data set which does not contain any peaks will be skipped when running MPF2_AutoMPFit().
// JW 200811: version 3.00
//		In MPF2_AutoMPFit, added /Z flag to constraints wave input so that it won't break into the debugger.
// ST 200811: version 3.00
//		Added graphical user interface for MPF2_AutoMPFit.
// ST 200818: version 3.00
//		Open list entries stay open when a peak is added or deleted.
//		Fixed bug: Key stroke codes were printed in history when editing peaks.
//		The Additional Constraints panel opens on top of the main panel now, which makes it less likely that the panel ends up outside the screen.
//		Peaks in the Add or Edit Peaks panel can now be deleted by pressing backspace or delete while highlighting the peak.
//		Fixed bug: Sometimes clicking on peaks inside the Add or Edit Peaks panel did not properly finish edit mode.
// ST 200820: version 3.00
//		Expanded right-click menu of the Results Panel for more options to copy values to the clipboard.
//		Layout changes: Reintroduced the narrow and wide panel sizes, and adjusted the control positions to fit into the smaller size. 
//		Added the possibility to enter a name or comment for each set, which makes it easier to recognize.
//		Fixed layout problem: The Disclose Options function opened the options without resizing the panel.
//		Now panel font sizes are bigger on windows.
// ST 200827: version 3.00
//		Added keyboard shortcuts to increase ([ and m) or decrease (] and n) coefficients in the peak list with live updates to nudge coef values quickly.
// ST 200905: version 3.00
//		Wrong precision in MPF2_PrintNumberWithPrecision() when the sigma value was negative.
//		Made sure that negative widths do not alter the peak in any way. Now peak areas are only negative when the peak is extending down from the baseline.
//		Fixed bug: The fit may fail and the graph is not properly cleaned if all peaks are deleted by the out-of-range check.
//		Fixed bug: The Doniach-Sunjic peak shape was not properly scaled as a negative peak.
//		Make the MPF2ChiSqDisplay text box static: Updates only happen after a successful fit.
// ST 200905: version 3.00
//		Added support for peakType lists in MPF2_AutoMPFit() => pass a string list of peak type names to assign different types to each peak.
// ST 201009: version 3.00
//		Fixed bug: The Raise and Lower buttons of the More Constraints panel were not working correctly for peak numbers larger than 9.
//		Fixed bug: Copy This Item As Number in the results panel did not include exponential factors.
// ST 201025: version 3.00
//		Fixed bug when initializing from an existing set: The fit range start- and end-points are inverted when the previous Y-wave had a negative scaling delta.
//		Fixed bug when initializing from an existing set: When the new Y-wave has a negative scaling delta the set creation fails with an error.
// ST 201126:
//		Changed the behavior of error checking for the More Constraints panel: The validity of constraints is now checked upon pressing 'Done' or when deselecting the panel.
//		Overhauled the layout of the constraints error-report panel to make errors easier to identify.
//		Fixed bug: The Raise and Lower buttons of the More Constraints panel were not working correctly for non-existing peak numbers.
// ST 201203:
//		Fixed bug: Out-of-bounds error upon switching on 'Use Cursors' when both cursors are not on the data and the point number of cursor B is larger than the data size.
//		Now activating 'Use Cursors' updates the fit curves to the new limited range immediately, even in cases where the graph hook "cursormoved" is not called.
//		If Use Cursors is activated then a vertical cross-hair line is displayed for both cursors to mark the fit range. Deactivation removes the lines.
// ST 201204:
//		Fixed bug: Activating 'Use Cursors' when both cursors are not on the data sometimes shifted the cursor position because the cursors were updated one after another.
//			To avoid conflicts with the graph hook, first the position of both cursors is read out and only then they are set to the Ydata trace.
// ST 201229:
//		Improvement of UpdateMultiPeak2Panel: Old MPF2 (Igor 6) panels often did not properly write to interPeakConstraints and MPF2_UserCursors. 
//			UpdateMultiPeak2Panel now covers these cases by reading the Constraints notebook contents and Use Graph Cursors status from the old panel directly.
//		Fixed bug: Drawing the vertical cross-hair for cursors may accidentally call the graph hook during the panel building phase which accesses vital parts of the panel.
//			Cursor status changes are now postponed until the end with Execute/P.
// ST 210219: version 3.00
//		Fixed bug: Add or Edit Peaks button did not work properly sometimes since the call relied on GetLastUserMenuInfo, which is not set by the button.
//			Now MPF2_MarqueeHandler() accepts just an input string instead and the menu handling is external.
//		Added an 'All Heights or Areas Equal' checkbox to the More Constraints panel.
// ST 210323: version 3.00
//		Fixed bug: Now AutoMPFit() cannot be run with an invalid InitialGuessOptions setting.
//		Added InitialGuessOptions = 6 to AutoMPFit() to run the peak finder, but don't actually fit the data.
// ST 210407: version 3.00
//		Added negativePeaks parameter to AutoMPFit(). negativePeaks set to a number > 0 will run the peak finder with inverted data.
// ST 210414: version 3.00
//		Now AutoMPFit() saves the y and x Waves used for fitting in the global string variables 'usedYWave' and 'usedXWave' inside each result folder.
//			A folder note (global string 'notes' inside the folder) is added as well for a quick overview of the fit result.
// ST 210501: version 3.00
//		Added checks for invalid characters (like 'abc') and parameters with missing numbers (like 'p1k1>pk2') to the More Constraints panel.
// ST 210504: version 3.00
//		More Constraints panel: The same invalid expression is only reported once. Also text strings are not checked for coefficients anymore.
// ST 210628: version 3.00
//		Fixed bug: the fit range could become invalid and gives and error if initializing a new fix with a previous fit set of incompatible range.
// ST 210813: version 3.00
//		Using Copy as Number from the Results list sometimes copied a wrong 'e' character together with the number.
//		Fixed bug: Hold check-boxes for the baseline were accidentally cleared if a new peak was added while the baseline list entry is collapsed.
// ST 211022: version 3.01
//		AutoMPFit: Constraints waves can now be two-dimensional to load separate constraints for each set. If the size and the number of sets does not match
//			a new error MPF2_Err_BadSizeOfConstraints is displayed.
// ST 211105: version 3.01
//		Replaced MPF2_GetGaussWidthFromPeakCoefs() with GetGaussParamsFromPeakCoefs() in PeakFunctions2.ipf, which returns a free wave with [loc, height, width, lwidth, rwidth].
//		Now W_AutoPeaksInfo is updated by the UI when fitting, reverting or changing individual parameters in the peak list. This is done via MPF2_UpdateWPIwaveFromPeakCoef().
// ST 211220: version 3.01
//		A custom Fit Curve Point setting is now reloaded when reopening a session.
// ST 220709: version 3.01
//		Added missing /Z flags for some Wave statements where the referenced wave may not exist.
// ST 220712: version 3.01
//		Peak / baseline types are now listed with basic types (from PeakFunctions2.ipf) coming first before user functions. => see MPF2_ListPeakTypeNames() and MPF2_ListBaseLineTypeNames().
// ST 221202: version 3.02
//		Added Guess Options to the MPF starter panel. This sets global variables for use as initial values for the auto-peak guesser.
// ST 221206: version 3.02
//		Added update function for the MPF starter panel.
//		Fixed bug: Resume Set gave an error if a different graph with the same name existed.
// ST 230525: version 3.03
//		Fixed bug: It was still possible to resume a set even after deleting the source data and the info notebook was not properly populated.
// ST 230528: version 3.03
//		Add or Edit Peaks: Now it is possible to add peaks outside the current fit range as long as the marquee is inside the data range and 'use cursors' is unchecked.
// ST 230531: version 3.03
//		MPF2_UserCursors global is now synced with the checkbox state, which fixes issues with initializing a new fit set with an open set.
// ST 230608: version 3.03
//		Fixed bug: Delete latest set gave an error if the set also had a save-point folder (ending 'CP').
//		Added Delete Set button to the Start and Resume panel.
// ST 230618: version 3.03
//		Redesigned the Start and Resume Panel into a tabbed version, which has now become the Start and Manage Sets panel.
//		Set Notes can now be directly modified from the Manage tab.
//		Displayed information in the Manage/Resume panel is more detailed.
//		Fixed Bug: Checkpoints could not be loaded after renaming the y data while working on the fit.
//		Locate Missing Data in the Manage Sets tab now selects waves instead of folders => users can locate renamed source data now.
// ST 230921: version 3.03
//		Fixed bug: Changing the set description while the associated MPF panel is closed gave an error.
//***************************************


//***************************************
// POSSIBLE ENHANCEMENTS
//
//	1)	Preferences
//				Residuals			Yes or No
//				fit curve			Yes or No
//				Updates during fits	Yes or No
//				Add baseline curve	Yes or No
//	2)	Some sort of support for metadata:
//				A)	Date
//				B)	File name
//				C)	Any kind of user data...
//	3)	Support for database...
//	4)	Function that can get Amplitude, Area and FWHM from a peak that doesn't have the param function
//	5)	Bootstrap estimation of the errors for the peak parameters.
//	DONE 6)	Constraints
//	DONE 7)	Weighting?
//	DONE 8)	Separate baseline curve added to graph.
//	9)	Support for additional peak types:
//				Weibull		http://www.systat.com/products/tablecurve2d/help/?sec=1247
//				DONE: Doniach-Sunjic
//				Logistic Dose Response Peak? http://www.systat.com/products/tablecurve2d/help/?sec=1186
//	DONE 10)	Add auto-pick from the residuals to add peaks missed the first time around?
//	DONE 12)	Ability to create a baseline-subtracted data set.
//	DONE 13)	Export a fit curve data set.
//	DONE 14)	A GUI for MPF2_AutoMPFit()
//	DONE 15)	A new Manual Peak Adjust that allows for asymmetric peaks. Ability to drag left and right sides separately- but how to *not* screw up symmetric peaks?
//***************************************

#include <HierarchicalListWidget>
#include <PopupWaveSelector>
#include <SaveRestoreWindowCoords>
#include <Axis Utilities>

static strconstant MPF2_VERSIONSTRING="3.00"					// ST: 200529 - bumped to version 2.5 => JW: decided 3 is justified
static constant MPF2_UPDATEPANELVERSION=3.00
static constant MPF2_UPDATESTARTERVERSION=3.03					// ST: 221206 - the starter panel has a version now

// JW 180727 Made these the same to accommodate a rearrangement of some of the controls
// That means there are quite a few places where a test is made that doesn't really do anything.
// I think that can be tolerated as we might want to have this logic available in the future.
static constant MPF2_NarrowWidth=340
static constant MPF2_PanelWidth=412
static constant MPF2_PanelHeight=386							// ST: 200820 - set global panel height here
static constant MPF2_MinHeight=346
static constant MPF2_CtrlMargin=15								// ST: 200821 - set left and right margin for controls in main panel 
static constant MPF2_PeakListTop = 25

strconstant PEAK_INFO_SUFFIX="_PeakFuncInfo"
strconstant BL_INFO_SUFFIX="_BLFuncInfo"
strconstant BL_FIXEDCOEFFUNC_SUFFIX="_FixCoef_BLFunc"			// ST 2.48: new suffix for baselines with inactive coefficient
strconstant MENU_ARROW_STRING="\JR\W523"

Menu "Analysis"
//	"Multipeak Fit: Start or Resume", /Q, fStartMultipeakFit2()				// ST: merged with resume panel & moved to main menu
	"Multipeak Fit: Start New Fit Set", 	/Q, fStartMultipeakFit2(tab=0)	// ST: 230618 - the starter panel has a tabbed interface now
	"Multipeak Fit: Manage and Resume Sets",/Q, fStartMultipeakFit2(tab=1)
	Submenu "Multipeak Fit"
		//"Resume existing set", /Q, fResumeMultipeakFit2Panel()
		"Automatic Multipeak Batch Fitting", /Q, MPF_BuildAutoMPFitPanel()
		"Unload Multipeak Fit Package", /Q, MPF2_UnloadMultiPeakFit()
		"Help for Multipeak Fitting", /Q, DisplayHelpTopic "Multipeak Fitting"
		"Multipeak Fitting Guided Tour", /Q, MPF2_LoadMPF2Demo()
		"-"
		"Delete Latest Multipeak Fit Set", /Q, MPF2_DeleteHighestMPFSetFolder()
		"Delete All Multipeak Fit Sets", /Q, MPF2_DeleteAllMPFSetFolders()
		"-"
		"Load Addon: Tougaard Background",/Q,Execute/P/Q/Z "INSERTINCLUDE <MPF_TougaardBackground>";Execute/P/Q/Z "COMPILEPROCEDURES "
		"Load Addon: Post-Collision Interaction Peaks",/Q,Execute/P/Q/Z "INSERTINCLUDE <MPF_PCIPeakShapes>";Execute/P/Q/Z "COMPILEPROCEDURES "
	end
end

Menu "GraphMarquee", dynamic
	MPF2_GraphMarqueeDef(),/Q, GetLastUserMenuInfo; MPF2_MarqueeHandler(S_value)		// ST: 210219 - Move GetLastUserMenuInfo call outside of MPF2_MarqueeHandler to make the function flexible
end

Function MPF2_LoadMPF2Demo()

//	DoAlert 1, "Continuing will close the current experiment and open the Multipeak Fitting Demo experiment.\r\rContinue?"
//	if (V_flag == 1)
		Execute/P/Q/Z "LOADHELPEXAMPLE :Examples:Curve Fitting:Multipeak Fit Demo.pxp"
//	endif
end

Function  MPF2_UnloadMultiPeakFit()
	if (WinType(GetStartPanelName()) != 0)
		DoWindow/K $GetStartPanelName()
	endif
	MPF2_CloseAllMPFWindows()									// ST: 200804 - make sure all MPF related windows are closed
	Execute/P/Q/Z "DELETEINCLUDE  <Multi-peak fitting 2.0>"		// ST: 200804 - for older experiments
	Execute/P/Q/Z "DELETEINCLUDE  <Multipeak Fitting>"
	Execute/P/Q/Z "DELETEINCLUDE  <MPF_TougaardBackground>"
	Execute/P/Q/Z "DELETEINCLUDE  <MPF_PCIPeakShapes>"
	Execute/P/Q/Z "COMPILEPROCEDURES "
end

#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)			// For compatibility with Igor 7
	String wName
	return 72
End
#endif

Structure MPFitInfoStruct
	Variable NPeaks
	Wave yWave
	Wave xWave
	Wave maskWave
	Wave weightWave
	
	Variable XPointRangeBegin
	Variable XPointRangeEnd
	Variable FitCurvePoints
	Variable fitOptions					// this value will be used to set V_fitOptions
	
	String ListOfFunctions				// first item in the list is the baseline type, which might be "None"; the rest will be one peak type per peak to fit.
	String ListOfCWaveNames				// first is name of coefficient wave for baseline. If baseline function is "None", the first item is ignored (but must be present)
	String ListOfHoldStrings			// semicolon-separated string containing one hold string for each fit function in ListOfFunctions. If it is "" then no holds. Any one entry can be ""; and that will make no holds for that particular fit function.
	
	// outputs
	String FuncListString				// the string used with FuncFit {String=...}
	Variable fitError
	Variable fitQuitReason
	String fitErrorMsg
	Variable chisq
	Variable fitPnts
	Variable dateTimeOfFit
	
	// Added for version 2.15
	Wave /T constraints 				// NH added 
	Variable fitMaxIters
EndStructure

Constant MPF2_Err_NoError = 0
Constant MPF2_Err_NoSuchBLType = -1
Constant MPF2_Err_BLCoefWaveNotFound = -2
Constant MPF2_Err_NoSuchPeakType = -3
Constant MPF2_Err_PeakCoefWaveNotFound = -4
Constant MPF2_Err_BadNumberOfFunctions = -5
Constant MPF2_Err_BadNumberOfCWaves = -6
Constant MPF2_Err_XYListLengthMismatch = -7
Constant MPF2_Err_NoDataSets = -8
Constant MPF2_Err_MissingDataSet = -9
Constant MPF2_Err_NoDataFolder = -10
Constant MPF2_Err_BLCoefWrongNPnts = -11
Constant MPF2_Err_PeakCoefWrongNPnts = -12
Constant MPF2_Err_UserCancelledBatchRun = -13
Constant MPF2_Err_SingularMatrixError = -14
Constant MPF2_Err_NaNorInf = -15
Constant MPF2_Err_IterationLimit = -16
Constant MPF2_Err_OutOfMemory = -17
Constant MPF2_Err_NoPeaksToFit = -18			// ST: 200804 - error if no peaks to fit are found in the data set
Constant MPF2_Err_WrongGuessMode = -19			// ST: 210323 - error if InitialGuessOptions is wrong
Constant MPF2_Err_BadSizeOfConstraints = -20	// ST: 211022 - error for individual constraints if the size of the constraint wave does not match the number of sets

Constant MPF2_ErrorFromDoMPFit = -10000

// resultDFBase				String containing a base name for data folders to be created to hold results. That would include the fit coefficient waves and
//							error estimate waves for a given data set. The data folder names will be generated by adding "_n" to resultDFBase, where n is the sequence
//							number of the dataset within the list yWaveList.
// peakType					string expression giving the name of a peak type. The peak type string will have "_PeakFuncInfo" appended; if there
//							is no function of that name, it returns MPF2_Err_NoSuchPeakType. This can be a single name such as "Gauss" to assign the same type for all
//							peaks or a list (example: "Gauss;Gauss;Voigt;"). If the number of peaks is exceeding the number of provided peak types then the first peak
//							type in the list is used for all remaining peaks.
// PeakCoefWaveFormat		a string containing "%d" somewhere. It will be used as the format string for a call to sprintf for generating coefficient wave names for the peaks.
// BLType					string expression giving the name of a baseline type. If BLType is "None", no baseline is added. Otherwise, the peak type 
//							string will have "_BLFuncInfo" appended and if there is no function of that name, it returns MPF2_Err_NoSuchBLType. 
// BLCoefWaveName			a string containing the name to use for the baseline coefficient wave.
// yWaveList				list of the Y waves with peak data to be fit.
// xWaveList				list of the X waves with peak data to be fit. Any entry in the list that doesn't name an actual wave causes the fit to use "_calculated_".
//							You can use "" to indicate that there all data sets should use "_calculated_".
// InitialGuessOptions		0: 	Do not run AutoPeakFind. Initial guesses will be pre-loaded in coefficient waves in the data folder resultDFBase+"_0".
//								Use those values for every data set.
//							1:	Do not run AutoPeakFind. Initial guesses will be pre-loaded in coefficient waves in the data folder resultDFBase+"_0". 
//								Use those values for the first data set, then use the previous result as initial guess for the next.
//							2:	Do not run AutoPeakFind. Initial guesses will be pre-loaded for every data set in a series of data folders resultDFBase+"_n", n = 0,1,...
//							3:	Run AutoPeakFind once on the first data set and use the result as the initial guess for every data set.
//							4:	Run AutoPeakFind once on the first data set and use the result as the initial guess for the first data set. For every other data set,
//								use the result of the previous fit as the initial guess for the next.
//							5:	Run AutoPeakFind on every data set to generate initial guesses for each fit.
//							6:	Run AutoPeakFind on every data set to generate initial guesses, but don't run the fit. This makes it possible to optimize peak finding
//								parameters before actually running the fit with InitialGuessOptions = 2.
// noiseEst, smFact			If InitialGuessOptions > 2, and you provide values for both these parameters, then EstPeakNoiseAndSmfact() will not be called.
//							If InitialGuessOptions > 2, and you provide values for one of these parameters, then EstPeakNoiseAndSmfact() will be called to get 
//							a value for the missing one.
//							If InitialGuessOptions > 2, and you don't provide values for either of these parameters, then EstPeakNoiseAndSmfact() will be called 
//							to get estimated values.
//							If InitialGuessOptions <= 2, these are ignored.
// noiseEstMult, smFactMult
//							Used only if InitialGuessOptions > 2.
//							When EstPeakNoiseAndSmfact is called to estimate noiseEst and smFact, the resulting estimates are multiplied by these factors.
//							These factors are used only if you don't provide your own value of noiseEst or smFact. That is, if you don't provide either noiseEst or smFact,
//							then EstPeakNoiseAndSmfact() will be called, and these multipliers will be applied to the results.
//							If you provide one of noiseEst or smFact, EstPeakNoiseAndSmfact will be called to get the missing value, and the multiplier will be applied
//							to the estimate of the missing value. If you provide both noiseEst and smFact, EstPeakNoiseAndSmfact() will not be called, and these factors
//							will be ignored. Default is 1 for both.
// minAutoFindFraction		Fraction of most intense peak that will be accepted as the least intense peak. Default is 0.05.
// negativePeakGuess		If this optional parameter is included and set to non-zero then the peak finder will try to find negative instead of positive peaks in the data.
// doDerivedResults			If this optional parameter is included and set to non-zero, each successful fit will also compute the derived parameters for the given peak type. These
//							are results that are not fit coefficients, but are derived from them. For any given peak type it may include FWHM or peak area. These derived parameters
//							are stored in a wave with the same name as the coefficient wave, but with "DER" added to the end of the name. The wave has dimension labels to tell
//							you what each row represents. The parameters are stored in column 0, the estimated standard deviation is stored in column 1.
// doFitCurves				If this option parameter is included and set to non-zero, for each successful fit curves are computed based on the fit results. The fit curves are these waves:
//								MPF2PeakCurveN		a single peak computed for peak N
//								MPF2BaselineCurve	the fitted baseline. If the baseline is "None" it is filled with zeroes.
//								MPF2FitCurve			a curve formed by summing all the peak curves.
//								MPF2FitCurve_PLusBL	the curve formed by summing all the peak curves and adding the baseline. This should be the curve that matches your input data.
//							Unlike the GUI-based Multipeak Fit 2, the fit curves are computed at the X values used in the fit.
//							In addition to the fit curves, a wave MPF2FitCurve_X is created that has the X values for the fit data.
// constraints				A text wave of constraints in the format described in DisplayHelpTopic "Fitting With Constraints". This wave can also be two-dimensional to define constraints
//							for each data set individually. In this case the column dimension must match the number of sets to fit.
Function MPF2_AutoMPFit(resultDFBase, peakType, PeakCoefWaveFormat, BLType, BLCoefWaveName, yWaveList, xWaveList, InitialGuessOptions [, noiseEst, smFact, noiseEstMult, smFactMult, minAutoFindFraction, negativePeakGuess, doDerivedResults, doFitCurves, constraints, startPoint, endPoint])
	String resultDFBase
	String peakType, PeakCoefWaveFormat
	String BLType, BLCoefWaveName
	String yWaveList, xWaveList
	Variable InitialGuessOptions
	Variable noiseEst, smFact
	Variable noiseEstMult, smFactMult
	Variable minAutoFindFraction
	Variable negativePeakGuess									// ST: 210407 - parameter to run peak finder with inverted data
	Variable doDerivedResults, doFitCurves
	Wave/Z /T constraints
	Variable startPoint, endPoint
	
	InitialGuessOptions = round(InitialGuessOptions)			// ST: 210323 - make sure this is an integer
	if (InitialGuessOptions < 0 || InitialGuessOptions > 6)		// ST: 210323 - block wrong guess options
		return MPF2_Err_WrongGuessMode
	endif
	
	Variable nDataSets = ItemsInList(yWaveList)
	if (nDataSets == 0)
		return MPF2_Err_NoDataSets
	endif
	if ( (strlen(xWaveList) > 0) && (ItemsInList(xWaveList) != nDataSets) )
		return MPF2_Err_XYListLengthMismatch			// ******** EXIT ***********
	endif
	
	Variable i, j
	
	Variable nPeakParams
	Variable nBLParams
	Variable nPeakTypes = itemsInList(peakType)
	String PeakInfoFuncName
	String BLFuncName
	String BLInitName
	Variable nPeaks
	Variable/C peakFindParams
	String cwavename
	
	// check y waves for existence. Can't check the X waves- non-existence simply means "_calculated_"
	for (i = 0; i < nDataSets; i += 1)
		Wave/Z w = $StringFromList(i, yWaveList)
		if (!WaveExists(w))
			return MPF2_Err_MissingDataSet				// ******** EXIT ***********
		endif
	endfor
	
	// Find out about the peak type.
	for (i = 0; i < nPeakTypes; i += 1) 				// ST: 200909 - add support for peakType lists
		PeakInfoFuncName = StringFromList(i,peakType)+PEAK_INFO_SUFFIX
		if (strlen(FunctionInfo(PeakInfoFuncName)) == 0)
			return MPF2_Err_NoSuchPeakType				// ******** EXIT ***********
		endif
	endfor
	
	// Find out about the baseline type.
	String BLInfoFuncName = BLType+BL_INFO_SUFFIX
	if (strlen(FunctionInfo(BLInfoFuncName)) == 0)
		return MPF2_Err_NoSuchBLType					// ******** EXIT ***********
	endif
	FUNCREF MPF2_FuncInfoTemplate BLInfoFunc=$BLInfoFuncName
	nBLParams = ItemsInList(BLInfoFunc(BLFuncInfo_ParamNames))		// the "None" baseline type has zero parameters, but an info func exists for it
	BLFuncName = BLInfoFunc(BLFuncInfo_BaselineFName)
	BLInitName = BLInfoFunc(BLFuncInfo_InitGuessFunc)
	STRUCT MPF2_BLFitStruct BLStruct
	if (strlen(BLInitName) > 0)
		FUNCREF MPF2_BaselineFunctionTemplate BLInitFunc = $(BLInitName)
	endif
	
	Variable runEstPeakNoiseAndSmfact = 1
	Variable neednoiseEst = 1
	Variable needsmFact = 1
	if (InitialGuessOptions < 3)
		runEstPeakNoiseAndSmfact = 0
	endif
	if (runEstPeakNoiseAndSmfact)
		if (!ParamIsDefault(noiseEst))
			neednoiseEst = 0
		endif
		if (!ParamIsDefault(smFact))
			needsmFact = 0
		endif
		if (!(neednoiseEst || needsmFact))
			runEstPeakNoiseAndSmfact = 0
		endif
	endif
	if (ParamIsDefault(noiseEstMult))
		noiseEstMult = 1
	endif
	if (ParamIsDefault(smFactMult))
		smFactMult = 1
	endif
	if (ParamIsDefault(minAutoFindFraction))
		minAutoFindFraction = 0.05
	endif
	if (ParamIsDefault(negativePeakGuess))						// ST: 210407 - default setting is off
		negativePeakGuess = 0
	endif
	
	Variable firstPoint = 0
	if (!ParamIsDefault(startPoint))
		firstPoint = max(startPoint, 0)
	endif
	Variable lastPoint		// initialized where it's used because it depends on each y wave
	
	String dataFolderPath = GetDataFolder(1)
	
	String resultDF
	String sourceDF
	
	// Do data folder for data set 0
	if (InitialGuessOptions < 3)
		// Sanity check for user-supplied results data folder for data set number 0
		resultDF = resultDFBase+"_0"
		if (!DataFolderExists(resultDF))
			return MPF2_Err_NoDataFolder						// ******** EXIT ***********
		endif
		SetDataFolder resultDF
		if (nBLParams > 0)
			Wave/Z w = $BLCoefWaveName							// ST: 220709 - prevent error
			if (!WaveExists(w))
				SetDataFolder dataFolderPath
				return MPF2_Err_BLCoefWaveNotFound				// ******** EXIT ***********
			endif
			if (numpnts(w) != nBLParams)
				SetDataFolder dataFolderPath
				return MPF2_Err_BLCoefWrongNPnts				// ******** EXIT ***********
			endif
		endif
		
		// This loop counts the peaks as it checks the length of the coefficient waves
		nPeaks = 0
		do
			sprintf cwavename, PeakCoefWaveFormat, nPeaks
			Wave /Z w = $cwavename
			if (!WaveExists(w))
				break;
			endif
			
			if (nPeaks >= nPeakTypes)							// ST: 200909 - the first peak type is used as default
				PeakInfoFuncName = StringFromList(0,peakType)+PEAK_INFO_SUFFIX
			else
				PeakInfoFuncName = StringFromList(nPeaks,peakType)+PEAK_INFO_SUFFIX
			endif
			FUNCREF MPF2_FuncInfoTemplate peakInfoFunc=$PeakInfoFuncName
			nPeakParams = ItemsInList(peakInfoFunc(PeakFuncInfo_ParamNames))
			
			if (numpnts(w) != nPeakParams)
				SetDataFolder dataFolderPath
				return MPF2_Err_PeakCoefWrongNPnts				// ******** EXIT ***********
			endif
			nPeaks += 1
		while(1)
		if (nPeaks == 0)
			SetDataFolder dataFolderPath
			return MPF2_Err_PeakCoefWaveNotFound				// ******** EXIT ***********
		endif
		Variable/G gNumPeaks = nPeaks
	else
		// Create results data folder for data set 0
		Wave yw = $StringFromList(0, yWaveList)
		Wave/Z xw = $StringFromList(0, xWaveList)
		resultDF = resultDFBase+"_0"
		KillDataFolder/Z $resultDF
		NewDataFolder/O/S $resultDF
		lastPoint =  numpnts(yw)-1
		if (!ParamIsDefault(endPoint))
			lastPoint = min(endPoint, numpnts(yw)-1)
		endif
		if (negativePeakGuess)									// ST: 210407 - support for negative peak guesses
			Duplicate/O/FREE yw, TempYDataForNegativePeaks
			WAVE yw = TempYDataForNegativePeaks
			yw = -yw
		endif
		if (runEstPeakNoiseAndSmfact)
			peakFindParams = EstPeakNoiseAndSmfact(yw, firstPoint, lastPoint)
			if (neednoiseEst)
				noiseEst = real(peakFindParams)*noiseEstMult
			endif
			if (needsmFact)
				smFact = imag(peakFindParams)*smFactMult
			endif
		endif
		nPeaks = AutoFindPeaks(yw, firstPoint, lastPoint, noiseEst, smFact, Inf)
		if (nPeaks > 0)							// ST: 200804 - make sure there are peaks to work with
			Wave wpi = W_AutoPeakInfo			// may or may not exist
			AdjustAutoPeakInfoForX(wpi, yw,  xw)
			nPeaks = TrimAmpAutoPeakInfo(wpi, minAutoFindFraction)
			MPF2_SortAutoPeakWave(wpi)
			if (negativePeakGuess)
				wpi[][2] = -wpi[p][2]
			endif
			CreateCWavesInCDFFromAutoPkInfo(wpi, peakType, PeakCoefWaveFormat)
		endif
		Variable/G gNumPeaks = nPeaks
				
		String/G usedYWave = GetWavesDataFolder(yw,2)			// ST: 210414 - record input waves in folder (here mainly for mode 6; will be recreated after fit)
		String/G notes = "Y-Wave = "+GetWavesDataFolder(yw,2)	// ST: 210414 - write folder notes (will be overwritten later if the fit succeeds)
		if (WaveExists(xw))
			String/G usedXWave = GetWavesDataFolder(xw,2)
			notes += "\rX-Wave = "+GetWavesDataFolder(xw,2)
		else
			String/G usedXWave = ""
		endif
		notes += "\rNo. of peaks = "+num2str(gNumPeaks)
		
		if (nBLParams > 0)
			Make/D/O/N=(nBLParams) $BLCoefWaveName
			if (strlen(BLInitName) > 0)			// ST: 200718 - initialize BL coefficients
				Wave BLStruct.cWave = $BLCoefWaveName
				Wave BLStruct.yWave = yw
				Wave/Z BLStruct.xWave = xw
				if (WaveExists(xw))
					BLStruct.xStart = xw[firstPoint]
					BLStruct.xEnd = xw[lastPoint]
				else
					BLStruct.xStart = pnt2x(yw, firstPoint)
					BLStruct.xEnd = pnt2x(yw, lastPoint)
				endif
				BLStruct.x = BLStruct.xStart
				BLInitFunc(BLStruct)
			endif
		endif
	endif

	SetDataFolder dataFolderPath

// InitialGuessOptions		0: 	Do not run AutoPeakFind. Initial guesses will be pre-loaded in coefficient waves in the data folder resultDFBase+"_0".
//								Use those values for every data set.
//							1:	Do not run AutoPeakFind. Initial guesses will be pre-loaded in coefficient waves in the data folder resultDFBase+"_0". 
//								Use those values for the first data set, then use the previous result as initial guess for the next.
//							2:	Do not run AutoPeakFind. Initial guesses will be pre-loaded for every data set in a series of data folders resultDFBase+"_n", n = 0,1,...
//							3:	Run AutoPeakFind once on the first data set and use the result as the initial guess for every data set.
//							4:	Run AutoPeakFind once on the first data set and use the result as the initial guess for the first data set. For every other data set,
//								use the result of the previous fit as the initial guess for the next.
//							5:	Run AutoPeakFind on every data set to generate initial guesses for each fit.
//							6:	Run AutoPeakFind on every data set to generate initial guesses, but don't run the fit.
	switch (InitialGuessOptions)
		case 0:
		case 3:
			// these options use the data set 0 initial guesses for all data sets, so we need to duplicate the data folder for data set 0 nDataSets times
			sourceDF = resultDFBase+"_0"
			for (i = 1; i < nDataSets; i += 1)
				resultDF = resultDFBase+"_"+num2str(i)
				if (DataFolderExists(resultDF))
					KillDataFolder/Z $resultDF
				endif
				DuplicateDataFolder $sourceDF, $resultDF
			endfor
			break;
		case 5:
		case 6:
			for (i = 1; i < nDataSets; i += 1)
				Wave yw = $StringFromList(i, yWaveList)
				Wave/Z xw = $StringFromList(i, xWaveList)
				resultDF = resultDFBase+"_"+num2str(i)
				KillDataFolder/Z $resultDF
				NewDataFolder/O/S $resultDF
				lastPoint =  numpnts(yw)-1
				if (!ParamIsDefault(endPoint))
					lastPoint = min(endPoint,  numpnts(yw)-1)
				endif
				if (negativePeakGuess)					// ST: 210407 - support for negative peak guesses
					Duplicate/O/FREE yw, TempYDataForNegativePeaks
					WAVE yw = TempYDataForNegativePeaks
					yw = -yw
				endif
				if (runEstPeakNoiseAndSmfact)
					peakFindParams = EstPeakNoiseAndSmfact(yw, firstPoint, lastPoint)
					if (neednoiseEst)
						noiseEst = real(peakFindParams)*noiseEstMult
					endif
					if (needsmFact)
						smFact = imag(peakFindParams)*smFactMult
					endif
				endif
				nPeaks = AutoFindPeaks(yw, firstPoint, lastPoint, noiseEst, smFact, Inf)
				if (nPeaks > 0)							// ST: 200804 - make sure there are peaks to work with
					Wave wpi = W_AutoPeakInfo			// may or may not exist
					AdjustAutoPeakInfoForX(wpi, yw,  xw)
					nPeaks = TrimAmpAutoPeakInfo(wpi, minAutoFindFraction)
					MPF2_SortAutoPeakWave(wpi)
					if (negativePeakGuess)
						wpi[][2] = -wpi[p][2]
					endif
					CreateCWavesInCDFFromAutoPkInfo(wpi, peakType, PeakCoefWaveFormat)
				endif
				Variable/G gNumPeaks = nPeaks
				
				String/G usedYWave = GetWavesDataFolder(yw,2)			// ST: 210414 - record input waves in folder (here mainly for mode 6; will be recreated after fit)
				String/G notes = "Y-Wave = "+GetWavesDataFolder(yw,2)	// ST: 210414 - write folder notes (will be overwritten later if the fit succeeds)
				if (WaveExists(xw))
					String/G usedXWave = GetWavesDataFolder(xw,2)
					notes += "\rX-Wave = "+GetWavesDataFolder(xw,2)
				else
					String/G usedXWave = ""
				endif
				notes += "\rNo. of peaks = "+num2str(gNumPeaks)
				
				if (nBLParams > 0)
					Make/D/O/N=(nBLParams) $BLCoefWaveName
					if (strlen(BLInitName) > 0)			// ST: 200718 - initialize BL coefficients
						Wave BLStruct.cWave = $BLCoefWaveName
						Wave BLStruct.yWave = yw
						Wave/Z BLStruct.xWave = xw
						if (WaveExists(xw))
							BLStruct.xStart = xw[firstPoint]
							BLStruct.xEnd = xw[lastPoint]
						else
							BLStruct.xStart = pnt2x(yw, firstPoint)
							BLStruct.xEnd = pnt2x(yw, lastPoint)
						endif
						BLStruct.x = BLStruct.xStart
						BLInitFunc(BLStruct)
					endif
				endif

				SetDataFolder dataFolderPath
			endfor
		 	break;
		 case 2:
		 	// do a sanity check of each of the data folders
			for (i = 1; i < nDataSets; i += 1)
				resultDF = resultDFBase+"_"+num2str(i)
				if (!DataFolderExists(resultDF))
					SetDataFolder dataFolderPath
					return MPF2_Err_NoDataFolder						// ******** EXIT ***********
				endif
				SetDataFolder resultDF
				if (nBLParams > 0)
					Wave/Z w = $BLCoefWaveName
					if (!WaveExists(w))
						SetDataFolder dataFolderPath
						return MPF2_Err_BLCoefWaveNotFound				// ******** EXIT ***********
					endif
					if (numpnts(w) != nBLParams)
						SetDataFolder dataFolderPath
						return MPF2_Err_BLCoefWrongNPnts				// ******** EXIT ***********
					endif
				endif
				
				// This loop counts the peaks as it checks the length of the coefficient waves
				nPeaks = 0
				do
					sprintf cwavename, PeakCoefWaveFormat, nPeaks
					Wave/Z w = $cwavename
					if (!WaveExists(w))
						break;
					endif
					
					if (nPeaks >= nPeakTypes)							// ST: 200909 - the first peak type is used as default
						PeakInfoFuncName = StringFromList(0,peakType)+PEAK_INFO_SUFFIX
					else
						PeakInfoFuncName = StringFromList(nPeaks,peakType)+PEAK_INFO_SUFFIX
					endif
					FUNCREF MPF2_FuncInfoTemplate peakInfoFunc=$PeakInfoFuncName
					nPeakParams = ItemsInList(peakInfoFunc(PeakFuncInfo_ParamNames))
					
					if (numpnts(w) != nPeakParams)
						SetDataFolder dataFolderPath
						return MPF2_Err_PeakCoefWrongNPnts				// ******** EXIT ***********
					endif
					nPeaks += 1
				while(1)
				if (nPeaks == 0)
					SetDataFolder dataFolderPath
					return MPF2_Err_PeakCoefWaveNotFound				// ******** EXIT ***********
				endif
				Variable/G gNumPeaks = nPeaks
			
				if (nBLParams > 0)
					Make/D/O/N=(nBLParams) $BLCoefWaveName
				endif
			
				SetDataFolder dataFolderPath
			endfor
			break;
	endswitch
	
	if (InitialGuessOptions == 6)	// ST: 210323 - guess only mode -> quit here
		return 0
	endif
	
	Variable nonfatalError = 0
	Variable ConstraintsForEach = 0
	
	STRUCT MPFitInfoStruct MPFs
	if (!paramIsDefault(constraints))
		if (WaveExists(constraints) && DimSize(constraints,1) > 1)
			if (DimSize(constraints,1) < nDataSets)
				return MPF2_Err_BadSizeOfConstraints
			endif
			ConstraintsForEach = 1										// ST: 211022 - a set of constraints for each set
		else
			Wave/Z /T MPFs.constraints = constraints
		endif
	endif
	i = 0
	do
//	 for (i = 0; i < nDataSets; i += 1)
		if (ConstraintsForEach)											// ST: 211022 - assign one column from the collection as constraints wave
			Make/T/Free/N=(DimSize(constraints,0)) currConstraints = constraints[p][i]
			String tempConstraintsStr
			wfprintf tempConstraintsStr, "%s;", currConstraints			// ST: 211022 - convert to list to easily remove empty entries
			tempConstraintsStr = RemoveFromList("",tempConstraintsStr)
			Wave/T MPFs.constraints = ListToTextWave(tempConstraintsStr, ";")
		endif
		Wave MPFs.yWave = $StringFromList(i, yWaveList)
		Wave/Z MPFs.xWave = $StringFromList(i, xWaveList)
		resultDF = resultDFBase+"_"+num2str(i)
		SetDataFolder resultDF
		NVAR gNumPeaks
		
		String/G usedYWave = GetWavesDataFolder(MPFs.yWave,2)			// ST: 210414 - record input waves in folder
		String/G notes = "Y-Wave = "+GetWavesDataFolder(MPFs.yWave,2)	// ST: 210414 - write folder notes for real
		if (WaveExists(MPFs.xWave))
			String/G usedXWave = GetWavesDataFolder(MPFs.xWave,2)
			notes += "\rX-Wave = "+GetWavesDataFolder(MPFs.xWave,2)
		else
			String/G usedXWave = ""
		endif
		
		if (gNumPeaks == 0)			// ST: 200804 - make sure there are peaks => if not, jump over this set
			Variable/G MPFError = MPF2_Err_NoPeaksToFit
			nonfatalError = MPF2_Err_NoPeaksToFit
			SetDataFolder dataFolderPath
			i += 1
			if (i == nDataSets)
				break;
			endif
			continue
		endif
		
		MPFs.NPeaks = gNumPeaks
		if (ParamIsDefault(startPoint))
			MPFs.XPointRangeBegin = max(0, startPoint)
		else
			MPFs.XPointRangeBegin = startPoint
		endif
		if (ParamIsDefault(endPoint))
			MPFs.XPointRangeEnd = numpnts(MPFs.yWave)-1
		else
			MPFs.XPointRangeEnd = min(endPoint, numpnts(MPFs.yWave)-1)
		endif
		MPFs.FitCurvePoints = 100
		MPFs.fitOptions = 4
		MPFs.ListOfFunctions = BLType+";"
		MPFs.ListOfCWaveNames = BLCoefWaveName+";"
		MPFs.ListOfHoldStrings = ""
		for (j = 0; j < gNumPeaks; j += 1)
			String CurrentPeakType
			if (j >= nPeakTypes)									// ST: 200909 - the first peak type is used as default
				CurrentPeakType = StringFromList(0,peakType)
			else
				CurrentPeakType = StringFromList(j,peakType)
			endif
			sprintf cwavename, PeakCoefWaveFormat, j
			MPFs.ListOfFunctions += CurrentPeakType+";"
			MPFs.ListOfCWaveNames += cwavename+";"
		endfor
		
		Variable err = MPF2_DoMPFit(MPFs, GetDataFolder(1), doUpdates=0, doAutoDest=0, doAutoResid=0)
		if (err)
			err += MPF2_ErrorFromDoMPFit
			Variable/G MPFError = err
			notes += "\rFit error = "+num2str(err)					// ST: 210414 - write error into folder notes
			SetDataFolder dataFolderPath
			return err												// ******** EXIT ***********
		endif
		
		if (MPFs.fitError || ((MPFs.fitQuitReason > 0) && (MPFs.fitQuitReason < 3)) )
			Variable doRestore = 1
			if (MPFs.fitQuitReason == 2)
				Variable/G MPFError = MPF2_Err_UserCancelledBatchRun
				notes += "\rFit error = "+num2str(MPF2_Err_UserCancelledBatchRun)	// ST: 210414 - write error into folder notes
				SetDataFolder dataFolderPath
				return MPF2_Err_UserCancelledBatchRun				// ******** EXIT ***********
			endif
			if (MPFs.fitError & 2)
				Variable/G MPFError = MPF2_Err_SingularMatrixError
			endif
			if (MPFs.fitError & 4)
				Variable/G MPFError = MPF2_Err_OutOfMemory
			endif
			if (MPFs.fitError & 8)
				Variable/G MPFError = MPF2_Err_NaNorInf
			endif
			if (MPFs.fitQuitReason == 1)
				Variable/G MPFError = MPF2_Err_NaNorInf
				doRestore = 0		// allow the fit to continue from where it left off if Do Fit is clicked again
			endif
			if (doRestore)
				MPF2_RestoreCoefWavesFromBackup(MPFs.ListOfCWaveNames, GetDataFolder(1))
			endif
		else
			Variable/G MPFError = MPF2_Err_NoError
			Variable/G MPFChiSquare = MPFs.chisq
			
			if (doDerivedResults)
				doMPF2DerivedResults(MPFs)
			endif
			if (doFitCurves)
				doMPF2FitCurves(MPFs)
			endif
		endif
		if (MPFError)
			nonfatalError = MPFError
		endif
		
		notes += "\rFit completed = "+Secs2Time(DateTime, 0)+" "+Secs2Date(DateTime, 1)	// ST: 210414 - write yet more folder notes after completed fit
		if (MPFError != 0)
			notes += "\rFit error = "+num2str(MPFError)
		else
			notes += "\rChi square = "+num2str(MPFs.chisq)
		endif
		if ( (firstPoint != 0) || (lastPoint != numpnts(yw)-1) )
			notes += "\rFit range = "+num2str(firstPoint)+" to "+num2str(lastPoint)
		endif
		notes += "\rFitted points = "+num2str(MPFs.fitpnts)
		notes += "\rNo. of peaks = "+num2str(gNumPeaks)
		notes += "\rPeak type = "+peakType
		notes += "\rBaseline type = "+BLType

		SetDataFolder dataFolderPath
		
		i += 1
		if (i == nDataSets)
			break;
		endif
		
		if ( (InitialGuessOptions == 1) || (InitialGuessOptions == 4) )
			sourceDF = resultDFBase+"_"+num2str(i-1)
			resultDF = resultDFBase+"_"+num2str(i)
			if (DataFolderExists(resultDF))
				KillDataFolder/Z $resultDF												// ST: 211022 - the DF cannot be killed if the result is displayed somewhere
				//KillDataFolder $resultDF
			endif
			DuplicateDataFolder $sourceDF, $resultDF
		endif
//	 endfor
	while(1)
	 
	 SetDataFolder dataFolderPath
	 
	 return nonfatalError
end

// Service function for MPF2_AutoMPFit; implements the computation of derived peak parameters
Function doMPF2DerivedResults(MPStruct)
	STRUCT MPFitInfoStruct &MPStruct

	Variable j
	// The covariance matrix for the fit is required for computing errors for the derived parameters. MPF2_DoMPFit tells FuncFit to save the 
	// covariance matrix, so it should exist here.
	Wave M_Covar
	// The covariance matrix is in one big lump. To get the particular values we need, we need to know how many overall fit coefficients
	// there are. So here we find out the name of the baseline coefficient wave (if any) and record the number of baseline coefficients.
	String BLName = StringFromList(0, MPStruct.ListOfCWaveNames)
	Wave/Z blw = $BLName
	Variable totalParams = WaveExists(blw) ? numpnts(blw) : 0
	// Now we loop through each peak computing derived parameters for each.
	for (j = 0; j < MPStruct.NPeaks; j += 1)
		// The coefficient wave from the fit
		Wave cWave = $(StringFromList(j+1, MPStruct.ListOfCWaveNames))
		// and the name of the peak function used for this peak
		String functionName = StringFromList (j+1, MPStruct.ListOfFunctions)
 
		// We need the info func for this peak type to get the information needed to call the derived parameter function.
		// MPF2_FuncInfoTemplate is defined by Multipeak Fit 2.
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(functionName+PEAK_INFO_SUFFIX)
		// Now we can all the info func to get the names of the derived parameters (and the length of the list of names
		// also tells us how many there are)
		String ParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
		// This gets the name of the derived parameter function so that we can make a FUNCREF allowing us to call it.
		// MPF2_ParamFuncTemplate is defined by Multipeak Fit 2.
		String derivedParamFunc = infoFunc(PeakFuncInfo_ParameterFunc)
		FUNCREF MPF2_ParamFuncTemplate paramFunc=$derivedParamFunc
		// Now make a wave to receive the derived parameters. It has two columns- one for the value and one for the standard deviation.
		Variable numDerivedParams = ItemsInList(ParamNames)
 				Make/O/D/N=(numDerivedParams, 2) $(NameOfWave(cWave)+"DER")/WAVE=dw
 				dw = NaN
 				// As a help to the person who has to look at this, we put the names of the derived parameters as dimension labels. They can be
 				// viewed in a table by selecting the Edit Dimension Labels and Data Columns option in the New Table dialog.
 				Variable k
 				Variable ncoefs = numpnts(cWave)
 				for (k = 0; k < numDerivedParams; k += 1)
 					SetDimLabel 0, k, $(StringFromList(k, ParamNames)),dw
 				endfor
 				// Extract the part of the covariance matrix that applies to the particular peak fit we're working on here
 				Make/D/N=(ncoefs, ncoefs)/FREE tempCovar
		tempCovar[][] = M_covar[totalParams+p][totalParams+q]
		// Finally! We can call the function to get the derived parameters
		paramFunc(cWave, tempCovar, dw)
 
		totalParams += ncoefs
	endfor
end

// Service function for MPF2_AutoMPFit; implement calculation of various fit curve waves.
Function doMPF2FitCurves(MPStruct)
	STRUCT MPFitInfoStruct &MPStruct
	
	Wave yw = MPStruct.yWave
	Wave/Z xw = MPStruct.xWave
	
	Variable i
	Variable xbegin = MPStruct.XPointRangeBegin
	Variable xend = MPStruct.XPointRangeEnd
	Variable points = xend - xbegin + 1

	String BLType = StringFromList (0, MPStruct.ListOfFunctions)
	Duplicate/O/R=[xbegin, xend] yw, MPF2BaselineCurve
	MPF2BaselineCurve = 0
	
	if (CmpStr(BLType, "None") != 0)
		String BLWName = StringFromList(0, MPStruct.ListOfCWaveNames)
		Wave/Z blw = $BLWName

	
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BLType + BL_INFO_SUFFIX)
		String BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		
		FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
		STRUCT MPF2_BLFitStruct BLStruct
		
		Wave BLStruct.cWave = blw
		Wave BLStruct.yWave = yw		// ST 2.48: fill in y- and x-data pointers
		Wave/Z BLStruct.xWave = xw
		if (WaveExists(xw))
			BLStruct.xStart = xw[xbegin]
			BLStruct.xEnd = xw[xend]
			for (i = 0; i < points; i += 1)
				BLStruct.x = xw[i + xbegin]
				MPF2BaselineCurve[i] = blFunc(BLStruct)
			endfor
		else
			BLStruct.xStart = pnt2x(yw, xbegin)
			BLStruct.xEnd = pnt2x(yw, xend)
			for (i = 0; i < points; i += 1)
				BLStruct.x = pnt2x(yw, i + xbegin)
				MPF2BaselineCurve[i] = blFunc(BLStruct)
			endfor
		endif
	endif
	
	Duplicate/O MPF2BaselineCurve, MPF2FitCurve, MPF2FitCurve_PlusBL
	MPF2FitCurve = 0

	Variable nPeaks = MPStruct.nPeaks
	
	for (i = 0; i < nPeaks; i += 1)
		String coefsName = StringFromList(i+1, MPStruct.ListOfCWaveNames)
		Wave coefs = $coefsName

		String PeakTypeName = StringFromList (i+1, MPStruct.ListOfFunctions)
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		String PeakFuncName = 	infoFunc(PeakFuncInfo_PeakFName)
		FUNCREF MPF2_PeakFunctionTemplate peakFunc = $PeakFuncName

		Duplicate/O MPF2FitCurve, $("MPF2PeakCurve"+num2str(i))/WAVE=peakw
		if (WaveExists(xw))
			Duplicate/R=[xbegin, xend]/O xw, MPF2FitCurve_X
		else
			Duplicate/R=[xbegin, xend]/O yw, MPF2FitCurve_X
			MPF2FitCurve_X = pnt2x(yw, xbegin+p)
		endif
		peakFunc(coefs, peakw, MPF2FitCurve_X)
		MPF2FitCurve += peakw
	endfor
	MPF2FitCurve_PlusBL += MPF2FitCurve
end

// Function to do a multipeak fit from client code.
// Input: a structure with information about the fit, plus the name of a data folder containing coefficient waves,
// one for each peak, plus a coefficient wave for the baseline (unless the baseline function is "none").
// The contents of DataFolderName is a full path to the data folder, with final ":"
// Returns the function list string used in FuncFit sum-of-functions list.
Function MPF2_DoMPFit(MPstruct, DataFolderName [, doUpdates, doAutoDest, doAutoResid])
	STRUCT MPFitInfoStruct &MPstruct
	String DataFolderName
	Variable doUpdates, doAutoDest, doAutoResid
	
	if (ParamIsDefault(doUpdates))
		doUpdates = 1
	endif
	
	if (ParamIsDefault(doAutoDest))
		doAutoDest = 1
	endif
	
	if (ParamIsDefault(doAutoResid))
		doAutoResid = 1
	endif
	
	Variable npeaks = MPstruct.NPeaks
	Wave yw = MPstruct.yWave
	Wave/Z xw = MPstruct.xWave
	
	Variable wDelta	// ST: get wave's delta for the epsilon size evaluation
	if(WaveExists(xw))
		wDelta = xw[1]-xw[0]
	else
		wDelta = DimDelta(yw,0)
	endif
	
	if (ItemsInList(MPstruct.ListOfFunctions) != npeaks+1)		// +1 for the baseline function
		return MPF2_Err_BadNumberOfFunctions
	endif
	
	if (ItemsInList(MPstruct.ListOfCWaveNames) != npeaks+1)
		return MPF2_Err_BadNumberOfCWaves
	endif
	
	MPstruct.FuncListString = ""
	String holdString
	
	String BL_TypeName = StringFromList(0, MPstruct.ListOfFunctions)
	Variable doBaseLine = CmpStr(BL_TypeName, "None") != 0
	if (doBaseLine)
		String BL_FuncName
		Variable nBLParams
		
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		nBLParams = ItemsInList(blinfo(BLFuncInfo_ParamNames))
		if (nBLParams == 0)
			return MPF2_Err_NoSuchBLType
		endif
		
		STRUCT MPF2_BLFitStruct BLStruct
		Wave BLStruct.yWave = yw		// ST 2.48: fill in y- and x-data pointers
		Wave/Z BLStruct.xWave = xw
		if (WaveExists(xw))
			BLStruct.xStart = xw[MPstruct.XPointRangeBegin]
			BLStruct.xEnd = xw[MPstruct.XPointRangeEnd]
		else
			BLStruct.xStart = pnt2x(yw, MPstruct.XPointRangeBegin)
			BLStruct.xEnd = pnt2x(yw, MPstruct.XPointRangeEnd)
		endif
		String blcoefwname = StringFromList(0, MPstruct.ListOfCWaveNames)
		Wave/Z blcoefwave = $(DataFolderName+PossiblyQuoteName(blcoefwname))
		if (!WaveExists(blcoefwave))
			return MPF2_Err_BLCoefWaveNotFound
		endif
		MPstruct.FuncListString += "{"+BL_FuncName+", "+GetWavesDataFolder(blcoefwave,2)
Duplicate/O blcoefwave, blepswave
blepswave = (abs(blcoefwave[p]) > 1e-6 || blcoefwave[p] == 0) ? 1e-6 : 1e-6*abs(blcoefwave[p])		// ST: check for small coefficients and adjust epsilon accordingly
MPstruct.FuncListString += ", EPSW="+GetWavesDataFolder(blepswave,2)
		holdString = StringFromList(0, MPstruct.ListOfHoldStrings)
		
		if (StringMatch(BL_FuncName, "*"+BL_FIXEDCOEFFUNC_SUFFIX))					// ST 2.48: inactive (=hold) coefficient for passive backgrounds
			holdString = "1"
		endif
		
		if (strlen(holdString) > 0)
			MPstruct.FuncListString += ", HOLD=\""+holdString+"\""
		endif
		MPstruct.FuncListString += ", STRC=BLStruct}"
	endif
	
	Variable i
	for (i = 0; i < nPeaks; i += 1)
		String PeakTypeName = StringFromList(i+1, MPstruct.ListOfFunctions)
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		String PeakFuncName = 	infoFunc(PeakFuncInfo_PeakFName)
		if (strlen(PeakFuncName) == 0)
			return MPF2_Err_NoSuchPeakType
		endif

		String pwname = StringFromList(i+1, MPstruct.ListOfCWaveNames)
		pwname = PossiblyQuoteName(pwname)
		pwname = DataFolderName + pwname
		Wave/Z coefw = $pwname
		if (!WaveExists(coefw))
			return MPF2_Err_PeakCoefWaveNotFound
		endif
		
		MPstruct.FuncListString += "{"+PeakFuncName+","+pwname
Duplicate/O coefw, $(NameOfWave(coefw)+"eps")
Wave epsw = $(NameOfWave(coefw)+"eps")
epsw[0]  = (wDelta > 1e-6 || wDelta == 1e-6) ? 1e-6 : 1e-6*wDelta						// ST: location epsilon depends on the waves delta scaling
epsw[1,] = (abs(coefw[p]) > 1e-6 || coefw[p] == 0) ? 1e-6 : 1e-6*abs(coefw[p])			// ST: check for small coefficients and adjust epsilon accordingly
MPstruct.FuncListString += ", EPSW="+GetWavesDataFolder(epsw,2)
		holdString = StringFromList(i+1, MPstruct.ListOfHoldStrings)					// i+1 to account for the fact that the first hold string goes with the baseline
		if (strlen(holdString) > 0)
			MPstruct.FuncListString += ", HOLD=\""+holdString+"\""
		endif
		MPstruct.FuncListString += "}"
	endfor

	Variable V_FitQuitReason = 0
	Variable V_FitMaxIters=500
	if (MPStruct.fitMaxIters > 0)
		V_FitMaxIters=MPStruct.fitMaxIters
	endif
	Variable V_FitOptions=MPStruct.fitOptions

//print MPstruct.FuncListString
	MPstruct.fitErrorMsg = ""
	
	MPF2_BackupCoefWaves(MPstruct.ListOfCWaveNames, DataFolderName)

	Variable errorCode=0
	DebuggerOptions
	Variable doDebugOnError = V_debugOnError
	DebuggerOptions debugOnError=0
	try
		Variable xPtRgBgn = MPstruct.XPointRangeBegin	//added to avoid FuncFit command being 400 chars - NH
		Variable xPtRgEnd = MPstruct.XPointRangeEnd                    				
		if (!WaveExists(MPstruct.Constraints))
			Make /T/Free/N=0 MPstruct.Constraints
		endif
		
		FuncFit/Q=1/N=(doUpdates==0?1:0)/M=2 {string=MPstruct.FuncListString} yw[xPtRgBgn,xPtRgEnd]/X=xw[xPtRgBgn,xPtRgEnd]/W=MPstruct.weightWave[xPtRgBgn,xPtRgEnd]/I=1/M=MPstruct.maskWave[xPtRgBgn,xPtRgEnd] /AD=(doAutoDest)/AR=(doAutoResid)/A=1/NWOK/C=MPstruct.constraints;AbortOnRTE  
	catch
		MPstruct.fitErrorMsg = GetRTErrMessage()
		Variable semiPos = strsearch(MPstruct.fitErrorMsg, ";", 0)
		if (semiPos >= 0)
			String errWithPeaksNamed = MPF2_StringKToPeakNotation(MPstruct.fitErrorMsg[semiPos+1, inf], MPstruct)
			MPstruct.fitErrorMsg = errWithPeaksNamed 	// MPstruct.fitErrorMsg[semiPos+1, inf]
		endif
		errorCode = GetRTError(1)
	endtry
	DebuggerOptions debugOnError=doDebugOnError
	
	MPstruct.dateTimeOfFit = DateTime
	MPstruct.fitPnts = V_npnts
	MPstruct.chisq = V_chisq
	MPstruct.fitError = errorCode
	MPstruct.fitQuitReason = V_FitQuitReason
		
	return MPF2_Err_NoError
end

static Function MPF2_BackupCoefWaves(listofWaveNames, DataFolderName, [backupName])
	String listofWaveNames, DataFolderName, backupName

	String saveDF = GetDataFolder(1)
	SetDataFolder DataFolderName
	
	Variable nWaves = ItemsInList(listofWaveNames)
	
	if (ParamIsDefault(backupName))
		backupName = "MPF2_CoefsBackup_"
	endif

	Variable i
	for (i = 0; i < nWaves; i += 1)
		Wave/Z coefs = $StringFromList(i, listofWaveNames)
		if (WaveExists(coefs))				// this is actually because the baseline coefficient wave may not exist.
			Duplicate/O coefs, $(backupName+num2istr(i))
		endif
	endfor
	
	SetDataFolder saveDF
end

Function MPF2_RestoreCoefWavesFromBackup(listofWaveNames, DataFolderName, [backupName])
	String listofWaveNames, DataFolderName, backupName

	String saveDF = GetDataFolder(1)
	SetDataFolder DataFolderName
	
	Variable nWaves = ItemsInList(listofWaveNames)

	if (ParamIsDefault(backupName))
		backupName = "MPF2_CoefsBackup_"
	endif

	Variable i
	for (i = 0; i < nWaves; i += 1)
		Wave/Z coefs = $StringFromList(i, listofWaveNames)
		if (WaveExists(coefs))	// if this wave doesn't exist, it didn't get made by MPF2_BackupCoefWaves() above - NH
			Wave backupWave = $(backupName+num2istr(i))
			Duplicate/O backupWave, $StringFromList(i, listofWaveNames)
		endif
	endfor
	
	SetDataFolder saveDF
end

Function fStartMultipeakFit2([int tab])							// ST: 230618 - added support for the tabbed starter panel
	int chooseTab = ParamIsDefault(tab) ? 0 : tab
	if (WinType(GetStartPanelName()) == 7)
		DoWindow/F $GetStartPanelName()
		if (WinType(GetStartPanelName(tab=chooseTab)) == 7)
			MPF2_SetStartPanelTabContent(chooseTab)
		endif
		return 0
	endif
	
	if (!DataFolderExists("root:Packages:MultiPeakFit2"))
		String SaveDF = GetDataFolder(2)
		SetDataFolder root:
		NewDataFolder/O/S Packages
		NewDataFolder/O/S MultiPeakFit2
		Variable/G currentSetNumber = 0
		SetDataFolder saveDF
	endif
	
	fBuildMultiPeak2StarterPanel(tab=chooseTab)
	
//	MultiPeakFit2_Initialize()
end
	
Function MultiPeakFit2_Initialize()								// ST: 230618 - this is not called anymore but stays as legacy code
	if (!DataFolderExists("root:Packages:MultiPeakFit2"))
		String SaveDF = GetDataFolder(2)
		SetDataFolder root:
		NewDataFolder/O/S Packages
		NewDataFolder/O/S MultiPeakFit2
		
		Variable/G currentSetNumber = 0

		//String/G MPF2_DoFitHelpBoxText			// ST: 200804 - not needed anymore
		
		//MPF2_DoFitHelpBoxText = "To get started, add peaks to the list."
		//MPF2_DoFitHelpBoxText += "\rEither click the \f01Auto-locate Peaks\f]0 button, above,"
		//MPF2_DoFitHelpBoxText += "\ror drag a marquee on the graph and select"
		//MPF2_DoFitHelpBoxText += "\r\f01Add or Edit Peaks\f]0 from the marquee menu."
		//Variable/G MPF2_DontShowHelpMessage=0
		
		SetDataFolder saveDF
	endif
	
	fBuildMultiPeak2StarterPanel()
end

Function fBuildMultiPeak2StarterPanel([int tab])				// ST: 230618 - the interface is now tabbed with sub-panels
	int chooseTab = ParamIsDefault(tab) ? 0 : tab

	Variable panelH = 305, panelW = 390
	String baseName = GetStartPanelName()
	
	NewPanel/W=(50,50,50+panelW,50+panelH)/K=1/N=$baseName as "Start and Manage Multipeak Fit Sets"	// ST: redesigned starter panel and merged with resume panel
	
	DefineGuide TabAreaLeft={FL,15}
	DefineGuide TabAreaRight={FR,-15}
	DefineGuide TabAreaTop={FT,70}
	DefineGuide TabAreaBottom={FB,-10}
	
	TabControl MPF2_StartTabControl,pos={10,45},size={panelW-20,panelH-55}
	TabControl MPF2_StartTabControl,tabLabel(0)="\\Zr110Start a New Set"
	TabControl MPF2_StartTabControl,tabLabel(1)="\\Zr110Manage and Resume Previous Sets"
	TabControl MPF2_StartTabControl,value=0,focusring=0,proc=WMMultiPeakFit#MPF2_StartPanelTabProc
	
	Button MPF2_StartPanelHelp ,pos={12,10},size={80,25},proc=MPF2_DoHelpButtonProc,title="Help"
	Button MPF2_ResumeDoNotebookReport ,pos={panelW-212,10},size={200,25},proc=MPF2_ResumeDoNotebookReportButtonProc,title="Notebook Overview of All Sets"		// ST: button to generate an overview of all sets so far
	
	// ###### start part: StartSetTab
//	GroupBox MPF2_StartNewSetGroup,pos={10,12},size={360,250},fstyle=1,title="\\Zr110Start a New Set"									// ST: 221202 - slightly increase font size for better distinction
	
	NewPanel/FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom) /HOST=$baseName/N=StartSetTab
		ModifyPanel cbRGB=(60000,60000,60000,0), frameStyle=0, frameInset=0
		String tab0Name = baseName+"#StartSetTab"
		
		TitleBox MPF2_YWaveButtonTitle	,pos={15,12} ,size={42,15} ,title="Y Wave:",frame=0		
		TitleBox MPF2_XWaveButtonTitle	,pos={15,37} ,size={42,15} ,title="X Wave:",frame=0
		Button MPF2_SelectYWaveButton	,pos={65,10} ,size={280,20} ,title="",fSize=10
		Button MPF2_SelectXWaveButton	,pos={65,35} ,size={280,20} ,title="",fSize=10
		
		MakeButtonIntoWSPopupButton(tab0Name, "MPF2_SelectYWaveButton", "MPF2_WaveSelectNotify")
		MakeButtonIntoWSPopupButton(tab0Name, "MPF2_SelectXWaveButton", "MPF2_WaveSelectNotify")
		PopupWS_MatchOptions(tab0Name, "MPF2_SelectYWaveButton", listoptions="DIMS:1,TEXT:0,WAVE:0,DF:0,CMPLX:0")		// ST: 200803 - filter selection for 1D waves
		PopupWS_MatchOptions(tab0Name, "MPF2_SelectXWaveButton", listoptions="DIMS:1,TEXT:0,WAVE:0,DF:0,CMPLX:0")
		PopupWS_AddSelectableString(tab0Name, "MPF2_SelectXWaveButton", "_calculated_")
		PopupWS_SetSelectionFullPath(tab0Name, "MPF2_SelectXWaveButton", "_calculated_")
		
		CheckBox MPF2_StartPanel_FromTarget	,pos={15,67}	,size={80,15} ,title="From Target"								// ST: slightly nudged the positions of FromTarget and TraceMenu to prevent overlapping controls
		CheckBox MPF2_StartPanel_FromTarget,value= 0 ,proc=MPF2_Starter_FromTitleCheckProc
		
		PopupMenu MPF2_StartPanel_TraceMenu	,pos={110,65}	,size={235,20} ,title="Set Waves from Trace" ,proc=MPF2_StarterChooseTraceMenu
		PopupMenu MPF2_StartPanel_TraceMenu,mode=0,bodywidth=235,value= #"TraceNameList(WinName(0,1), \";\", 1)", disable=1
		
		PopupMenu MPF2_ChooseGraph			,pos={110,94}	,size={235,20} ,title="Use Graph:" ,proc=MPF2_ChooseGraphProc	// ST: aligned ChooseGraph and Initialize controls 
		PopupMenu MPF2_ChooseGraph,mode=1,bodyWidth=235,value= #"\"New Graph;\"+MPF2_ListGraphsWSelectedWaves()"
		
		PopupMenu MPF2_InitializeFromSetMenu,pos={110,123}	,size={235,20} ,title="Initialization:"
		PopupMenu MPF2_InitializeFromSetMenu,mode=1,bodyWidth=235,value= #"InitializeMPF2FromMenuString()"
		
		PopupMenu MPF2_PanelPositionMenu	,pos={110,152}	,size={60,20} ,title="Panel Position:"
		PopupMenu MPF2_PanelPositionMenu,mode=2,bodyWidth=60,value= #"\"Below;Right;Left;Above\""
		
		Button MPF2_StarterGuessOptions		,pos={185,150}	,size={160,22} ,title="Auto Peak-Find Options" ,proc=MPF2_StarterGuessOptionsProc	// ST: 221202 - add new button to fine-tune guesses
		Button MPF2_StarterGuessOptions,help={"Set global options for the automatic peak finder. These options will be used whenever a new Multipeak set is started."}
		
		Button MPF2_DataSelectedContinueButton,pos={panelW/2-85,185} ,size={150,25} ,title="Start New Set" ,proc=MPF2_WaveSelectContinueBtnProc,fstyle=1
	SetActiveSubwindow ##
	
	// ###### resume / manage part: ManageSetTab
//	GroupBox MPF2_ResumeSetGroup,pos={10,270},size={360,190},fstyle=1,title="\\Zr110Resume a Previous Set"				// ST: 221202 - slightly increase font size for better distinction
	
	NewPanel/FG=(TabAreaLeft, TabAreaTop, TabAreaRight, TabAreaBottom) /HOST=$baseName/N=ManageSetTab
		ModifyPanel cbRGB=(60000,60000,60000,0), frameStyle=0, frameInset=0
		String tab1Name = baseName+"#ManageSetTab"
		
		DefineGuide UGV0={FL,10},UGH0={FT,40},UGH1={FB,-52},UGV1={FR,-10}
		NewNotebook/F=0/N=NB_WaveNames/W=(150,60,590,180)/FG=(UGV0,UGH0,UGV1,UGH1) /HOST=# 
		Notebook kwTopWin, defaultTab=20, autoSave= 1, magnification=100
		Notebook kwTopWin font="Monaco", fSize=10, fStyle=0, textRGB=(0,0,0)											// ST: 200821 - make the text a bit smaller
		Notebook kwTopWin, zdata= "GaqDU%ejN7!Z)%D?tAb<=R'hO`]tdL!6<Ul\\,"
		Notebook kwTopWin, zdataEnd= 1
		RenameWindow #,NB_WaveNames		
		SetActiveSubwindow ##
		
		PopupMenu MPF2_ResumeSetMenu		,pos={10,10}	,size={100,23} ,title="Choose Set:" ,proc=MPF2_ResumeSetPopMenuProc
		PopupMenu MPF2_ResumeSetMenu,mode=1,value= #"MPF2_ListExistingSetsForResume()"
		
		Button MPF2_ResumeButton			,pos={10,185}	,size={110,25} ,title="Resume Set" ,proc=MPF2ResumeButtonProc,fstyle=1
		Button MPF2_DeleteSelectedSet		,pos={140,185}	,size={80,25}  ,title="Delete Set" ,proc=MPF2_DoDeleteSetButtonProc						// ST: 230618 - added buttons to delete selected set and edit set notes
		Button MPF2_EditSetNotes			,pos={240,185}	,size={110,25} ,title="Edit Description" ,proc=MPF2_DoEditSetNotesButtonProc
		Button MPF2_RetrieveNewDataFolder	,pos={197,9}	,size={150,22} ,title="Locate Missing Data"												// ST: add option to select a different folder where the fit data has been moved
		
//		MakeButtonIntoWSPopupButton(tab1Name, "MPF2_RetrieveNewDataFolder", "MPF2_RetrieveNewDataFolderProc", options=PopupWS_OptionTitleInTitle, content = WMWS_DataFolders)
		
		MakeButtonIntoWSPopupButton(tab1Name, "MPF2_RetrieveNewDataFolder", "MPF2_RetrieveNewDataFolderProc", options=PopupWS_OptionTitleInTitle, content = WMWS_Waves | WMWS_NoDFs)
		PopupWS_MatchOptions(tab1Name, "MPF2_RetrieveNewDataFolder", listoptions="DIMS:1,TEXT:0,WAVE:0,DF:0,CMPLX:0")								// ST: 230618 - now the button selects actual waves -> use can even select renamed data
		
		Variable result = MPF2_PopulateResumeNBWithWaveNames(PanelName=tab1Name)
		Button MPF2_ResumeButton, disable=(result ? 0 : 2)
		
		ControlInfo/W=$tab1Name MPF2_ResumeSetMenu
		Variable setnumber = str2num(S_value)
		Button MPF2_RetrieveNewDataFolder,	disable=(result || numtype(setnumber) != 0 ? 1 : 0)							// ST: the locate data button is invisible if the fit data is found
		Button MPF2_DeleteSelectedSet,		disable=(numtype(setnumber) != 0 ? 1 : 0)									// ST: delete and edit notes buttons are disabled if no set exists
		Button MPF2_EditSetNotes,			disable=(numtype(setnumber) != 0 ? 1 : 0)
	SetActiveSubwindow ##
	// ######
	
	MPF2_SetStartPanelTabContent(chooseTab)
	
	SetWindow $baseName hook(MPF2_StarterHook)=MPF2_StarterHook
	SetWindow $baseName userdata(MPF2_UPDATESTARTERVERSION)=num2str(MPF2_UPDATESTARTERVERSION)							// ST: 221206 - write start panel version number
	
	// center the panel in the monitor or the Windows MDI window
	Variable scrnLeft, scrnTop, scrnRight, scrnBottom, scrnWidth, scrnHeight
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		String scrnInfo = StringByKey("RECT",ReplaceString(",RECT",StringByKey("SCREEN1",IgorInfo(0),":"),";RECT"),"=")
		sscanf scrnInfo, "%d,%d,%d,%d", scrnLeft, scrnTop, scrnRight, scrnBottom
		scrnWidth  = scrnRight-scrnLeft
		scrnHeight = scrnBottom-scrnTop
	elseif (CmpStr(IgorInfo(2), "Windows") == 0)
		GetWindow kwFrameInner, wsize
		scrnWidth  = V_right-V_left
		scrnHeight = V_bottom-V_top
	endif
	
	Variable halfWidth  = panelW/2*PanelResolution("MultiPeak2StarterPanel")/screenResolution
	Variable halfHeight = panelH/2*PanelResolution("MultiPeak2StarterPanel")/screenResolution
	MoveWindow/W=$baseName scrnWidth/2 - halfWidth, scrnHeight/2 - halfHeight, scrnWidth/2 + halfWidth, scrnHeight/2 + halfHeight
	SetWindow $baseName ,sizelimit={2*halfWidth, 2*halfHeight, inf, 2*halfHeight}								// ST: fix window size
end

Function MPF2_ChooseGraphProc(s) : PopupMenuControl
	Struct WMPopupAction &s
	
	ControlInfo/W=$(s.win) MPF2_InitializeFromSetMenu
	Variable menuItem = V_value
	if ( (CmpStr(s.popStr, "New Graph") == 0) || (strlen(GetUserData(s.popStr, "", "MPF2_DataSetNumber")) == 0) )
		if (menuItem == 2)
			PopupMenu MPF2_InitializeFromSetMenu, win=$(s.win),mode=1
		endif
	endif
end

Function MPF2_StarterHook(s)
	STRUCT WMWinHookStruct &s

	strswitch (s.eventName)
		case "activate":
			String lastTarget = GetUserData(s.winName, "", "lastTarget")
			if (CmpStr(lastTarget, WinName(0, 1+2, 1)) != 0)
				ControlInfo/W=$GetStartPanelName(tab=0) MPF2_StartPanel_FromTarget
				if (V_value)		// from target is checked
					MPF2_Starter_FromTitleCheckProc("MPF2_StartPanel_FromTarget", 1)
					//print WinName(0, 0xFFFF), WinName(1, 0xFFFF)
				endif
				SetWindow $s.winName, userData(lastTarget)=WinName(0, 1+2, 1)
			endif
			
			ControlInfo/W=$GetStartPanelName(tab=0) MPF2_ChooseGraph					// ST 2.47: the start panel produces a range of bugs if a non-existent graph is still selected => reset upon activation
			String SelectedGraph = S_value
			if (WinType(SelectedGraph) == 0 && !StringMatch(SelectedGraph,"New Graph"))	// ST: this selection does not exist anymore (make sure New Graph is not selected)
				PopupMenu MPF2_ChooseGraph,win=$GetStartPanelName(tab=0),mode=1			// reset popups
				PopupMenu MPF2_InitializeFromSetMenu,win=$GetStartPanelName(tab=0),mode=1
			endif
			
			ControlInfo/W=$GetStartPanelName(tab=1) MPF2_ResumeSetMenu					// ST: initialize the resume function after a first set has been created
			if (V_Flag != 0)															// ST: make sure this control exists in the starter panel
				Variable setnumber = str2num(S_value)
				if (numtype(setnumber) != 0)
					DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(1)					// ST: look if the first set exists, and set checkbox if yes
					if (DataFolderRefStatus(DFRpath))
						PopupMenu MPF2_ResumeSetMenu,win=$GetStartPanelName(tab=1),mode=1
						setnumber = 1													// ST: 230608 - we just confirmed that set 1 exists
					endif
				else
					DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)			// ST: 200803 check if the current selection is still valid
					if (!DataFolderRefStatus(DFRpath))
						PopupMenu MPF2_ResumeSetMenu,win=$GetStartPanelName(tab=1),mode=1
					endif
				endif
				Variable result = MPF2_PopulateResumeNBWithWaveNames(PanelName=GetStartPanelName(tab=1))	// ST: 230525 - make sure to populate notebook and check disable state in any case
				Button MPF2_ResumeButton 			,win=$GetStartPanelName(tab=1), disable=(result ? 0 : 2)
				Button MPF2_RetrieveNewDataFolder	,win=$GetStartPanelName(tab=1), disable=(result || numtype(setnumber) != 0 ? 1 : 0)
				ControlInfo/W=$GetStartPanelName(tab=1) MPF2_DeleteSelectedSet			// ST: 230618 - introduced Delete Set and Edit Notes buttons
				if (V_flag != 0)
					Button MPF2_DeleteSelectedSet	,win=$GetStartPanelName(tab=1), disable=(numtype(setnumber) != 0 ? 1 : 0)
				endif
				ControlInfo/W=$GetStartPanelName(tab=1) MPF2_EditSetNotes
				if (V_flag != 0)
					Button MPF2_EditSetNotes		,win=$GetStartPanelName(tab=1), disable=(numtype(setnumber) != 0 ? 1 : 0)
				endif
			endif
			
			Variable updatePanelNum = str2num(GetUserData(GetStartPanelName(),"","MPF2_UPDATESTARTERVERSION"))
			updatePanelNum = numtype(updatePanelNum) != 0 ? 0 : updatePanelNum
			if (updatePanelNum < MPF2_UPDATESTARTERVERSION)	 							// ST: 221206 - update the starter panel to the latest version
				Execute/P/Q "MPF2_UpdateMPFStarterPanel()"
			endif
			break;
//		case "deactivate":
//			SetWindow $s.winName, userData(lastTarget)=WinName(0, 1+2, 1)
//			break;
		case "resize":
			GetWindow $GetStartPanelName(), wsize
			Variable panelwidth = (V_right - V_left)/PanelResolution(GetStartPanelName())*screenResolution
			ControlInfo/W=$GetStartPanelName() MPF2_StartNewSetGroup
			if (V_Flag == 9)
				GroupBox MPF2_StartNewSetGroup,	 win=$GetStartPanelName(), size={panelwidth - 20, V_height}
			endif
			ControlInfo/W=$GetStartPanelName() MPF2_ResumeSetGroup
			if (V_Flag == 9)
				GroupBox MPF2_ResumeSetGroup, 	 win=$GetStartPanelName(), size={panelwidth - 20, V_height}
			endif
			ControlInfo/W=$GetStartPanelName() MPF2_StartTabControl						// ST: 230618 resize new tab control instead as of panel version 3.03
			if (V_Flag == 8)
				TabControl MPF2_StartTabControl, win=$GetStartPanelName(), size={panelwidth - 20, V_height}
			endif
			break
	endswitch
end

static Function/S GetStartPanelName([int tab])											// ST: 230618 - returns valid sub-panel names for both legacy and tabbed starter panels
	int whichTab = ParamIsDefault(tab) ? -1 : tab
	String basePanel = "MultiPeak2StarterPanel"
	String subPanel = StringFromList(whichTab,"StartSetTab;ManageSetTab;")
	if (strlen(subPanel) && WinType(basePanel+"#"+subPanel) == 7)
		return basePanel+"#"+subPanel
	else
		return basePanel
	endif
End

static Function MPF2_SetStartPanelTabContent(int whichTab)
	TabControl MPF2_StartTabControl, win=$GetStartPanelName(),value=whichTab
	SetWindow $GetStartPanelName(tab=0) hide=!(whichTab==0)
	SetWindow $GetStartPanelName(tab=1) hide=!(whichTab==1)
End

static Function MPF2_StartPanelTabProc(STRUCT WMTabControlAction &s)
	if (s.eventCode == 2)
		MPF2_SetStartPanelTabContent(s.tab)
	endif
End

static Function rebuildStarterPanelinPlace()											// ST: 230618 - rebuilds the panel while keeping the same position on the screen 
	String panel = GetStartPanelName()
	GetWindow $panel wSize
	Variable topEdge = V_top, leftEdge = V_left											// ST: save current position
	KillWindow $panel
	fBuildMultiPeak2StarterPanel(tab=0)													// ST: build the default panel
	GetWindow $panel wSize																// ST: shift the panel to its previous position
	topEdge -= V_top;	leftEdge -= V_left
	MoveWindow/W=$panel V_left+leftEdge, V_top+topEdge, V_right+leftEdge, V_bottom+topEdge
	return 0
end

Function MPF2_UpdateMPFStarterPanel()													// ST: 230618 - starter panel update function; now enhanced to cope with tabs / sub-panels
	String mainPanel = GetStartPanelName()
	string tab0Name = GetStartPanelName(tab=0)
	string tab1Name = GetStartPanelName(tab=1)
	int isOldPanel = !CmpStr(tab0Name,tab1Name)											// ST: panel version before introduction of tabs
	String subPanelList = SelectString(isOldPanel,tab0Name+";"+tab1Name+";",mainPanel)
	
	int i, j
	String ctrlPathList = "", disableList = "", popStateList = "", checkStateList = ""
	String currCtrl, curPanel, ctrlList
	for (j = 0; j < ItemsInList(subPanelList); j++)										// ST: go through all controls in the old panel and save their status
		curPanel = StringFromList(i,subPanelList)
		ctrlList = ControlNameList(curPanel, ";", "*")
		for (i = 0; i < ItemsInList(ctrlList); i++)
			currCtrl = StringFromList(i,ctrlList)
			ctrlPathList += curPanel+"@"+currCtrl+";"									// ST: save current control path
			ControlInfo/W=$curPanel $currCtrl
			disableList += currCtrl + ":" + num2str(V_disable) + ";"					// ST: save disable state
			if (V_flag == 2)
				checkStateList += currCtrl + ":" + num2str(V_Value) + ";"				// ST: save checkbox states
			endif
			if (V_flag == 3)
				popStateList += currCtrl + ":" + S_Value + ";"							// ST: save pop-up menu states
			endif
		endfor
	endfor
	String yWName = PopupWS_GetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton")	
	String xWName = PopupWS_GetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton")
	
	rebuildStarterPanelinPlace()
	
	if (isOldPanel)
		tab0Name = GetStartPanelName(tab=0)
		tab1Name = GetStartPanelName(tab=1)
		string tab0Controls = ControlNameList(tab0Name, ";", "*")
		string tab1Controls = ControlNameList(tab1Name, ";", "*")
		for (i = 0; i < ItemsInList(ctrlPathList); i++)									// ST: replace all old panel paths with new ones
			curPanel = StringFromList(0,StringFromList(i,ctrlPathList),"@")
			currCtrl = StringFromList(1,StringFromList(i,ctrlPathList),"@")
			if (FindListItem(currCtrl, tab0Controls) > -1)
				ctrlPathList = ReplaceString(curPanel+"@"+currCtrl,ctrlPathList,tab0Name+"@"+currCtrl)
			endif
			if (FindListItem(currCtrl, tab1Controls) > -1)
				ctrlPathList = ReplaceString(curPanel+"@"+currCtrl,ctrlPathList,tab1Name+"@"+currCtrl)
			endif
		endfor
	endif
	
	for (i = 0; i < ItemsInList(ctrlPathList); i++)										// ST: re-apply all states
		curPanel = StringFromList(0,StringFromList(i,ctrlPathList),"@")
		currCtrl = StringFromList(1,StringFromList(i,ctrlPathList),"@")
		ControlInfo/W=$curPanel $currCtrl
		if (!V_flag)																	// ST: the control does not exist (anymore)
			continue
		endif
		ModifyControl $currCtrl win=$curPanel ,disable=NumberByKey(currCtrl, disableList)
		Variable checkVal = NumberByKey(currCtrl, checkStateList)
		if (numtype(checkVal) == 0)
			CheckBox  $currCtrl win=$curPanel ,value=checkVal
		endif
		String popStr = StringByKey(currCtrl, popStateList)
		if (strlen(popStr))
			PopupMenu $currCtrl win=$curPanel ,popmatch=popStr
		endif
	endfor
	PopupWS_SetSelectionFullPath(tab0Name, "MPF2_SelectYWaveButton", yWName)
	PopupWS_SetSelectionFullPath(tab0Name, "MPF2_SelectXWaveButton", xWName)
	
	PopupMenu MPF2_StartPanel_TraceMenu win=$tab0Name ,mode=0							// ST: make sure the title mode is correct
	return 0
End

Function fResumeMultipeakFit2Panel()		// ST: not called from the menu anymore - left for backward compatibility
	if (WinType("ResumeMultipeakFitSetPanel") == 7)
		DoWindow/F ResumeMultipeakFitSetPanel
	else
		NewPanel /K=1 /W=(110,69,552,254) as "Resume Multipeak Fit Set"
		RenameWindow $S_name, ResumeMultipeakFitSetPanel

		PopupMenu MPF2_ResumeSetMenu,pos={44.00,13.00},size={94.00,23.00},proc=MPF2_ResumeSetPopMenuProc,title="Choose Set:"
		PopupMenu MPF2_ResumeSetMenu,mode=1,value= #"MPF2_ListExistingSetsForResume()"

		DefineGuide UGV0={FL,43},UGH0={FT,45},UGH1={UGH0,91},UGV1={FR,-47}
		NewNotebook /F=0 /N=NB_WaveNames /W=(149,58,589,177)/FG=(UGV0,UGH0,UGV1,UGH1) /HOST=# 
		Notebook kwTopWin, defaultTab=20, autoSave= 1, magnification=100
		Notebook kwTopWin font="Monaco", fSize=11, fStyle=0, textRGB=(0,0,0)
		Notebook kwTopWin, zdata= "GaqDU%ejN7!Z)%D?tAb<=R'hO`]tdL!6<Ul\\,"
		Notebook kwTopWin, zdataEnd= 1
		RenameWindow #,NB_WaveNames		
		SetActiveSubwindow ##
		
		Button MPF2_ResumeButton,pos={44.00,149.00},size={100.00,20.00},proc=MPF2ResumeButtonProc,title="Resume"
		
		Variable result = MPF2_PopulateResumeNBWithWaveNames(PanelName = "ResumeMultipeakFitSetPanel")
		Button MPF2_ResumeButton, disable=(result ? 0 : 2)
	endif
end

// Also returns 1 if the waves still exist, 0 otherwise
Function MPF2_PopulateResumeNBWithWaveNames([String PanelName])
	Variable result = 0
	
	String CalledPanel = "ResumeMultipeakFitSetPanel"		// ST: backwards compatibility with the old resume panel
	if(!ParamIsDefault(PanelName))
		CalledPanel = PanelName
	endif
	
	if (wintype(PanelName) == 7)
		ControlInfo/W=$PanelName MPF2_ResumeSetMenu
		Variable setnumber = str2num(S_value)
		// erase the notebook
		Notebook $(PanelName)#NB_WaveNames selection={startOfFile, endOfFile},text=""
		if (numtype(setnumber) == 0)
			DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
			
			SVAR/Z UserNotes = DFRPath:UserNotes			// ST: 200820 - add support for set notes
			if (SVAR_Exists(UserNotes) && strlen(UserNotes) > 0)
				Notebook $(PanelName)#NB_WaveNames text="Notes:\t"+UserNotes+"\r"
			endif
				
			NVAR/Z FitDate  = DFRpath:MPF2_FitDate			// ST: 230618 - add more information to the notebook
			Wave/Z wpi = DFRpath:W_AutoPeakInfo
			if (NVAR_Exists(FitDate))
				Notebook $(PanelName)#NB_WaveNames text="Last Fit:\t"+Secs2Time(FitDate, 0)+" on "+Secs2Date(FitDate, 1)+"\r"
			endif
			if (WaveExists(wpi))
				Notebook $(PanelName)#NB_WaveNames text="Peak Num:\t"+num2str(DimSize(wpi,0))+"\r"
			endif
			
			SVAR YWvName = DFRpath:YWvName
			SVAR XWvName = DFRpath:XWvName
			Wave/Z yw = $YWvName
			Wave/Z xw = $XWvName
			if (WaveExists(yw))
				NVAR XPointRangeBgn	= DFRpath:XPointRangeBegin
				NVAR XPointRangeEnd	= DFRpath:XPointRangeEnd
				string FitRange = ""
				if ( (XPointRangeBgn != 0) || (XPointRangeEnd != numpnts(yw)-1) )
					FitRange = "["+num2str(XPointRangeBgn)+", "+num2str(XPointRangeEnd)+"]"
				endif
				
				if (strlen(XWvName) > 0)					// ST: make sure the x data wave can be found as well
					if (WaveExists(xw))
						//Notebook $(PanelName)#NB_WaveNames text="Y Wave: "+YWvName+"\r"		// ST: 230618 - changed the layout for the larger resume tab
						//Notebook $(PanelName)#NB_WaveNames text="X Wave: "+XWvName
						Notebook $(PanelName)#NB_WaveNames text="Y Path = "+ParseFilePath(1, YWvName, ":", 1, 0)+"\r"
						Notebook $(PanelName)#NB_WaveNames text="Y Wave = "+ParseFilePath(0, YWvName, ":", 1, 0)+FitRange+"\r"
						Notebook $(PanelName)#NB_WaveNames text="X Path = "+ParseFilePath(1, XWvName, ":", 1, 0)+"\r"
						Notebook $(PanelName)#NB_WaveNames text="X Wave = "+ParseFilePath(0, XWvName, ":", 1, 0)
						result = 1
					else
						Notebook $(PanelName)#NB_WaveNames text="\rDATA WAVES ARE MISSING\r(was: " + YWvName + SelectString(strlen(XWvName), "", "\rand ") + XWvName + ")"
					endif
				else
					//Notebook $(PanelName)#NB_WaveNames text="Y Wave: "+YWvName+"\r"
					Notebook $(PanelName)#NB_WaveNames text="Y Path = "+ParseFilePath(1, YWvName, ":", 1, 0)+"\r"
					Notebook $(PanelName)#NB_WaveNames text="Y Wave = "+ParseFilePath(0, YWvName, ":", 1, 0)+FitRange+"\r"
					Notebook $(PanelName)#NB_WaveNames text="X Wave = _calculated_"
					result = 1
				endif
			else
				Notebook $(PanelName)#NB_WaveNames text="\rDATA WAVES ARE MISSING\r(was: " + YWvName + SelectString(strlen(XWvName), "", "\rand ") + XWvName + ")"		// ST 2.48: display what is missing; gives the user the chance to fix things
			endif
			Notebook $(PanelName)#NB_WaveNames selection={startOfFile, startOfFile}, findText={"",1}		// ST: scroll all the way to the left
		endif
	endif
	
	return result
end

Function MPF2_ResumeSetPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable result = MPF2_PopulateResumeNBWithWaveNames(PanelName = pa.win)
			Button MPF2_ResumeButton, win=$pa.win, disable=(result ? 0 : 2)
			ControlInfo/W=$pa.win MPF2_RetrieveNewDataFolder			// ST: update visibility of the locate data button
			if (V_Flag != 0)
				Button MPF2_RetrieveNewDataFolder, win=$pa.win, disable=(result ? 1 : 0)
			endif
			break
	endswitch

	return 0
End

Function MPF2ResumeButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ControlInfo/W=$(ba.win) MPF2_ResumeSetMenu
			Variable setnumber = str2num(S_value)
			MPF2_ResumeFitSet(setnumber)
			break
	endswitch

	return 0
End

Function MPF2_RetrieveNewDataFolderProc(Variable event, String wavepath, String windowName, String ctrlName)		// ST: sets a new folder if the fit data is found there
	if (strlen(wavepath) == 0 || event != WMWS_SelectionChanged)			// ST: only act on a select event
		return 0
	endif
	
	ControlInfo/W=$windowName MPF2_ResumeSetMenu
	Variable setnumber = str2num(S_value)
	if (numtype(setnumber) != 0)
		return 0
	endif
	
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	String YDataName = ParseFilePath(0, YWvName, ":", 1, 0)
	String XDataName = ParseFilePath(0, XWvName, ":", 1, 0)
	Wave/Z NewXWave = $XWvName
	
	int isfolder = DataFolderExists(wavepath) || !CmpStr(wavepath,"root")
	if (isfolder)															// ST: COMPATIBILITY - the button before version 3.03 selected folders
		Wave/Z NewYWave = $(wavepath + ":" + YDataName)
	else
		String NewYName = ParseFilePath(0, wavepath, ":", 1, 0)
		if (CmpStr(YDataName, NewYName) != 0)								// ST: non-matching names of the old and new waves
			DoAlert/T="Y Wave Names are Different" 1, "The name of the selected Y wave is different than before. Are you sure "+NewYName+" is correct?\r\rPress no and try again if you have accidentally selected the wrong wave (for example, X data instead of Y data)."
			if (V_flag != 1)
				return 0
			endif
		endif
		Wave/Z NewYWave = $wavepath
	endif
	
	if (!WaveExists(NewYWave))
		Abort "Could not locate "+YDataName+" in the folder " + wavepath
	endif
	
	int success = 0
	if (!strlen(XDataName) || WaveExists(NewXWave))							// ST: x wave was not set or  x data remained in the old folder
		success = 1
	else
		if (isfolder)
			Wave/Z NewXWave = $(wavepath + ":" + XDataName)
		else
			Wave/Z NewXWave = $(GetWavesDataFolder(NewYWave,1) + XDataName)
		endif
		
		if (WaveExists(NewXWave))											// ST: old x wave in new folder => were moved together
			XWvName = GetWavesDataFolder(NewXWave, 2)
			success = 1
		else
			if (isfolder)
				Abort "Could not locate " + XDataName
			endif
			
			String location, oldLoc, newLoc
			XDataName = ReplaceString("'",XDataName,"")						// ST: ask the user to locate X data
			oldLoc = ParseFilePath(1,XWvName,":",1,0)						// ST: Select between old and new folders
			newLoc = GetWavesDataFolder(NewYWave,1)
			
			if (!CmpStr(oldLoc,newLoc))
				location = oldLoc
				Prompt XDataName,"Enter new X wave name:"
				DoPrompt "Help to Locate X Data", XDataName
			else
				
				Prompt location,"New location of X wave:",popup,oldLoc+";"+newLoc+";"
				Prompt XDataName,"If renamed, enter new name:"
				DoPrompt "Help to Locate X Data", location, XDataName
			endif
			if (V_Flag)
				return 0
			endif
			
			Wave/Z NewXWave = $(location + PossiblyQuoteName(XDataName))
			if (WaveExists(NewXWave) && WaveDims(NewXWave)==1 && WaveType(NewXWave,1)==1)
				success = 1
			else
				Abort "Could not locate " + XDataName + " or was the wrong format. Please try again."
			endif
		endif
	endif
	
	if (success)
		UpdateMPFFolderForRenamedWaves(setNumber, YDataName, NewYWave, NewXWave)
		Variable result = MPF2_PopulateResumeNBWithWaveNames(PanelName = windowName)
		Button MPF2_ResumeButton, 			win=$windowName, disable=(result ? 0 : 2)
		Button MPF2_RetrieveNewDataFolder,	win=$windowName, disable=(result ? 1 : 0)
	endif
	return 0
End

Function MPF2_ResumeFitSet(Variable setnumber)
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
	if (datafolderRefStatus(DFRpath) == 1)
		DFREF saveDFR = GetDataFolderDFR()
		SetDataFolder DFRpath		
			SVAR gname = GraphName
			SVAR YWvName
			SVAR XWvName
			Wave yw = $YWvName
			Wave/Z xw = $XWvName
			NVAR XPointRangeBegin
			NVAR XPointRangeEnd
			NVAR XPointRangeReversed
			NVAR/Z graphleft
			NVAR/Z graphtop
			NVAR/Z graphright
			NVAR/Z graphbottom
			NVAR MPF2_UserCursors
		SetDataFolder saveDFR
		if (WinType(gname) == 1)
			DoWindow/F $gname
		else
			// JW 180623 Display/N=$gname works even if there is a window macro with the same name.
			// RenameWindow doesn't allow you to rename a window to a name that's already in use as a window macro.
			// So here we have to use Display/N just in case the user has saved the recreation macro.
			if (WaveExists(xw))
				Display/N=$gname/K=1 yw vs xw
			else
				Display/N=$gname/K=1 yw
			endif
			if (NVAR_Exists(graphleft))
				MoveWindow/W=$gname graphleft, graphtop, graphright, graphbottom
			endif
		endif
		
		// ST: 221206 - we should not assume the graph is already prepared, just because it has the same name (could be new) => set up in any case
		SetWindow $gname userdata(MPF2_DataSetNumber)=num2str(setNumber)
		if (MPF2_UserCursors)
			ShowInfo/W=$gname
			Cursor/P A $NameOfWave(yw) XPointRangeBegin
			Cursor/P B $NameOfWave(yw) XPointRangeEnd
		elseif (XPointRangeBegin != 0 || XPointRangeEnd != (numpnts(yw)-1))
			Variable left	= XPointRangeReversed ? pnt2x(yw,XPointRangeEnd) : pnt2x(yw,XPointRangeBegin)
			Variable right	= XPointRangeReversed ? pnt2x(yw,XPointRangeBegin) : pnt2x(yw,XPointRangeEnd)
			if(WaveExists(xw))
				left	= XPointRangeReversed ? xw[XPointRangeEnd] : xw[XPointRangeBegin]
				right	= XPointRangeReversed ? xw[XPointRangeBegin] :xw[XPointRangeEnd]
			endif
			SetAxis bottom ,left ,right		// ST: 200729 - scale the horizontal axis to the previous fit range
			SetAxis/A=2 left
		endif
		
		//endif
		if (Wintype(gname+"#MultiPeak2Panel") != 7)
			NVAR panelPosition = DFRpath:panelPosition
			BuildMultiPeak2Panel(gname, setNumber, panelPosition)

			NVAR position = DFRpath:panelPosition
			NVAR negativePeaks = DFRpath:negativePeaks
			Wave /Z wpi = DFRpath:W_AutoPeakInfo
			Variable nPeaks=0
			if (WaveExists(wpi))
				npeaks = DimSize(wpi, 0)
			endif
			
			// JW 180727 If we are "Resuming" a set that wasn't actually ever used, there is no SavedFunctionTypes
			// and the list of peaks is absent from the peak list
			SVAR/Z SavedFunctionTypes = DFRpath:SavedFunctionTypes
			
			ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,userdata(MPF2_DataSetNumber)=num2str(setnumber)
			MakeListIntoHierarchicalList(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "PeakListOpenNotify", selectionMode=WMHL_SelectionContinguous, userListProc="MPF2_PeakListProc")
			WMHL_AddColumns(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 6)		
			WMHL_SetNotificationProc(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "PeakListClosingNotify", WMHL_SetClosingNotificationProc)
			Wave/Z cwave = DFRpath:'Baseline Coefs'
			if (!WaveExists(cwave))
				Make/O/D/N=1 DFRpath:'Baseline Coefs'
			endif
			WMHL_AddObject(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "", "Baseline", 1)
			
			if (SVAR_Exists(SavedFunctionTypes))
				WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0, StringFromList(0, SavedFunctionTypes)+MENU_ARROW_STRING, 0)
				Variable i
				for (i = 0; i < npeaks; i += 1)
					WMHL_AddObject(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "", "Peak "+num2str(i), 1)
					WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, i+1, StringFromList(i+1, SavedFunctionTypes)+MENU_ARROW_STRING, 0)
				endfor
			endif
					
			NVAR/Z MPF2ConstraintsShowing = DFRpath:MPF2ConstraintsShowing
			if (!NVAR_Exists(MPF2ConstraintsShowing))
				Variable/G DFRpath:MPF2ConstraintsShowing
				NVAR MPF2ConstraintsShowing = DFRpath:MPF2ConstraintsShowing
				MPF2ConstraintsShowing = 0
			endif
			if (MPF2ConstraintsShowing)
				ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={16,70,110,50,30,35,30,35}		// ST: 200820 - adjusted column spacing
			else 
				ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={20,85,130,55,0,0,0,0}
			endif
	
			NVAR displayPeaksFullWidth = DFRpath:displayPeaksFullWidth
			if (waveExists(wpi))
				MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
				MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))	// ST: 211220 -  set the fit curve point setting from the panel
			endif
			Wave/Z/T HoldStrings = DFRpath:HoldStrings 
			if (!WaveExists(HoldStrings))
				Make/T/N=(npeaks+1)/O DFRpath:HoldStrings=""
			else
				SetHoldCheckboxesFromWave(setNumber)					// ST: reset hold check boxes
			endif
			
			MPF2_EnableDisableDoFitButton(setNumber)
		endif
	endif
end

Function MPF2_ResumeDoNotebookReportButtonProc(s) : ButtonControl		// ST: creates a notebook as an overview of all MPF sets
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif

	DFREF MPF_DFR = root:Packages:MultiPeakFit2:
	Variable numFolders = CountObjectsDFR(MPF_DFR, 4)
	
	if (numFolders == 0)
		DoAlert 0, "No fit sets found. First start at least one set before using this function."
		return 0
	endif

	String theList = "", currFolder = ""
	Variable i
	for (i = 0; i < numFolders; i += 1)
		currFolder = GetIndexedObjNameDFR(MPF_DFR, 4, i)
		if (StringMatch(currFolder, "MPF_SetFolder_*") && !StringMatch(currFolder, "*CP*"))
			theList += currFolder+";"
		endif
	endfor
	
	numFolders = itemsInList(theList)

	String nb = "MultipeakSetOverview"
	if (WinType(nb) == 5)
		DoWindow/K $nb
	endif
	NewNotebook/F=1/K=1/N=$nb as "Multipeak Fit Set Overview"
	Notebook $nb showRuler=0
	Notebook $nb newRuler=HeaderRuler, justification=0, margins={0,0,504}, spacing={0,0,0}, tabs={36}, rulerDefaults={"Geneva",11,1,(0,0,0)}
	Notebook $nb newRuler=ParamsRuler, justification=0, margins={0,0,504}, spacing={0,0,0}, tabs={36}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	
	Notebook $nb ruler=ParamsRuler, text="Overview from " + Secs2Date(DateTime, 1) + " at " + Secs2Time(DateTime, 0)+"\r"
	Notebook $nb ruler=ParamsRuler, text="Number of Multipeak Fit Sets: " + num2str(numFolders) + "\r"
	Notebook $nb ruler=ParamsRuler, text="Multipeak fit version: "+MPF2_VERSIONSTRING+"\r"
	
	for (i = 0; i < numFolders; i += 1)
		currFolder = StringFromList(i, theList)
		DFREF currDF = MPF_DFR:$currFolder
		
		SVAR YWvName = currDF:YWvName
		SVAR XWvName = currDF:XWvName
		SVAR WeightWvName	= currDF:MPF2WeightWaveName
		SVAR MaskWvName		= currDF:MPF2MaskWaveName
		SVAR/Z LastFuncList	= currDF:SavedFunctionTypes
		NVAR XPointRangeBgn	= currDF:XPointRangeBegin
		NVAR XPointRangeEnd	= currDF:XPointRangeEnd
		SVAR/Z UserNotes	= currDF:UserNotes					// ST: 200820 - add support for set notes
		NVAR/Z FitChiSq		= currDF:MPF2_FitChiSq
		NVAR/Z FitDate		= currDF:MPF2_FitDate
		Wave/Z wpi = currDF:W_AutoPeakInfo
		
		String Notes = ""
		if (SVAR_Exists(UserNotes) && strlen(UserNotes) > 0)
			Notes = "\t( " + UserNotes + " )"
		endif
		
		Notebook $nb ruler=HeaderRuler,fstyle=-1,text="\rMultiPeak Fit Set " + ReplaceString("MPF_SetFolder_", currFolder, "") + Notes + "\r"		// ST: 200804 - make sure the set number matches the folder
		
		if (NVAR_Exists(FitDate) && NVAR_Exists(FitChiSq))
			Notebook $nb ruler=ParamsRuler, text="Last Fit at "+Secs2Time(FitDate, 0)+" on "+Secs2Date(FitDate, 1)
			Notebook $nb text=" (X", fSize=7, vOffset=-5, text="2", fSize=-1, vOffset=0, text=" = "+num2str(FitChiSq)+")" + "\r"
		endif

		Notebook $nb ruler=ParamsRuler,fstyle=1, text="Y data wave:\t"+YWvName
		Wave/Z yw = $YWvName
		if (WaveExists(yw))
			if ( (XPointRangeBgn != 0) || (XPointRangeEnd != numpnts(yw)-1) )
				Notebook $nb ruler=ParamsRuler, text=" ["+num2str(XPointRangeBgn)+", "+num2str(XPointRangeEnd)+"]"
			endif
		endif
		Notebook $nb text="\r"
		
		if (strlen(XWvName) > 0)
			Notebook $nb ruler=ParamsRuler,fstyle=-1, text="X data wave:\t"+XWvName+"\r"
		endif
		
		if (strlen(WeightWvName) > 0)
			Notebook $nb ruler=ParamsRuler,fstyle=-1, text="Weight wave:\t"+WeightWvName+"\r"
		endif
		
		if (strlen(MaskWvName) > 0)
			Notebook $nb ruler=ParamsRuler,fstyle=-1, text="Mask wave:\t"+MaskWvName+"\r"
		endif

		if (WaveExists(wpi) > 0)
			Notebook $nb ruler=ParamsRuler,fstyle=-1, text="No. of Peaks:\t"+num2str(DimSize(wpi,0))+"\r"
		endif
		
		if (SVAR_Exists(LastFuncList))
			Notebook $nb ruler=ParamsRuler,fstyle=-1, text="Background:\t"+StringFromList(0,LastFuncList)+"\r"
		endif
	endfor
End

Function MPF2_CursorsCheckProc(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode == 2)			// mouse up
		Variable RangeBegin
		Variable RangeEnd
		Variable RangeReversed
		Variable noiseFactor
		
		String saveDF = GetDataFolder(1)
	
		Variable setNumber = GetSetNumberFromWinName(s.win)
		DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)

		SVAR gname = DFRpath:GraphName
		SVAR YWvName = DFRpath:YWvName
		SVAR XWvName = DFRpath:XWvName
		Wave YData = $YWvName
		Wave/Z XData = $XWvName
		NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
		NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
		NVAR useCursors = DFRPath:MPF2_UserCursors
		
		if (s.checked == 1 && (strlen(CsrInfo(A, gname)) == 0 || strlen(CsrInfo(B, gname)) == 0))		// ST 2.47: check if both cursors are set => if not the uncheck the checkbox again.
			CheckBox MPF2_UserCursorsCheckbox,win=$(s.win),value=0	
			DoAlert 0, "You need to add both cursors A and B to the graph to use this function."
			useCursors = 0
			return 0																					// ST: 201203 - make sure to exit here
		endif
		useCursors = s.checked																			// ST: 230531 - immediately update global variable
		
		String YDataN = ParseFilePath(0, YWvName, ":", 1, 0)											// ST 2.48: extract the yData name
		String TraceofCsrA = PossiblyQuoteName(CsrWave(A,gname))
		String TraceofCsrB = PossiblyQuoteName(CsrWave(B,gname))
		Variable csrApos = nan, csrBpos = nan
		Variable useXwave = WaveExists(XData)
		
		if (!StringMatch(TraceofCsrA, YDataN) && s.checked == 1 && strlen(CsrInfo(A, gname)) > 0)		// ST 2.48: cursor A is not on yData
			csrApos = xcsr(A, gname)
			if (useXwave)																				// ST 2.48: convert to points for XY-data
				FindLevel/P/Q XData, csrApos
				csrApos = V_LevelX
			endif
		endif
		if (!StringMatch(TraceofCsrB, YDataN) && s.checked == 1 && strlen(CsrInfo(B, gname)) > 0)		// ST 2.48: cursor B is not on yData
			csrBpos = xcsr(B, gname)
			if (useXwave)																				// ST 2.48: convert to points for XY-data
				FindLevel/P/Q XData, csrBpos
				csrBpos = V_LevelX
			endif
		endif
																										// ST: 201204 - make sure the position of both cursors is extracted before moving one of them. ...
		if (numtype(csrApos) == 0)																		// ... reason: the graph hook will update the fit curves. This may shift the other cursor if on one of the fit traces.
			if (useXwave)
				Cursor/P A $YDataN csrApos
			else
				Cursor A $YDataN csrApos
			endif
		endif
		if (numtype(csrBpos) == 0)
			if (useXwave)
				Cursor/P B $YDataN csrBpos
			else
				Cursor B $YDataN csrBpos
			endif
		endif
		
		if (s.checked == 1)																				// ST; 201203 - mark the fit range with vertical cross hairs
			Cursor/M/H=2 A
			Cursor/M/H=2 B
		else
			Cursor/M/H=0 A
			Cursor/M/H=0 B
		endif
		
		MPF2_SetDataPointRange(gname, YData, XData, RangeBegin, RangeEnd, RangeReversed)
		XPointRangeBegin = RangeBegin
		XPointRangeEnd = RangeEnd
		
		Wave/Z wpi = DFRpath:W_AutoPeakInfo																// ST: 201203 - update fit curves when cursors are switched on
		if (WaveExists(wpi) && s.checked == 1)
			NVAR displayPeaksFullWidth = DFRpath:$("displayPeaksFullWidth")
			String panelName = gname+"#MultiPeak2Panel"
			MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
			MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(panelName))
		endif
	endif
end

Function BuildMultiPeak2Panel(hostgraph, setNumber, position)
	String hostgraph
	Variable setNumber
	Variable position

	DoWindow/F $hostgraph
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	// constraints visible
	NVAR/Z MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")
	if (!NVAR_Exists(MPF2ConstraintsShowing))
		Variable/G $(DFPath+":MPF2ConstraintsShowing")
		NVAR MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")
		MPF2ConstraintsShowing = 0
	endif
	
	NVAR/Z MPF2_FitTolerance = $(DFPath+":V_FitTol")				// ST: global variable to change the fit convergence tolerance for chi square
	if (!NVAR_Exists(MPF2_FitTolerance))
		Variable/G $(DFPath+":V_FitTol")
		NVAR MPF2_FitTolerance = $(DFPath+":V_FitTol")
		MPF2_FitTolerance = 0.001									// ST: default value without this variable 
	endif
	
	SVAR/Z UserNotes = $(DFPath+":UserNotes")						// ST: 200820 - add support for a set name
	if (!SVAR_Exists(UserNotes))
		String/G $(DFPath+":UserNotes")
		SVAR UserNotes = $(DFPath+":UserNotes")
		UserNotes = ""
	endif

	Variable width		= MPF2ConstraintsShowing ? MPF2_PanelWidth : MPF2_NarrowWidth
	Variable addWidth	= MPF2ConstraintsShowing ? (MPF2_PanelWidth - MPF2_NarrowWidth)/2 : 0		// ST: 200820 - make panel elements smaller or wider depending on the panel size
	Variable left, top, right, bottom
	switch(position)
		case 0:			// right
			left=0; top=MPF2_PanelHeight; right=width; bottom=MPF2_PanelHeight;
			break;
		case 1:			// left
			left=width; top=MPF2_PanelHeight; right=0; bottom=MPF2_PanelHeight;
			break;
		case 2:			// below
			left=width; top=0; right=width; bottom=MPF2_PanelHeight;
			break;
		case 3:			// above
			left=width; top=MPF2_PanelHeight; right=width; bottom=0;
			break;
	endswitch
	
	NewPanel /W=(left,top,right,bottom)/K=1/HOST=$hostgraph/EXT=(position) as "Multipeak Fit Set "+num2str(setNumber)
	String panelName = hostgraph+"#"+S_name
	RenameWindow $panelName, MultiPeak2Panel
	panelName = hostgraph+"#MultiPeak2Panel"
	ModifyPanel/W=$panelName fixedSize=0
	DefineGuide UGH0={FT,32}
	DefineGuide UGH1={UGH0,70}
	DefineGuide UGH3={FB,-23}
	DefineGuide UGH2={UGH3,-89}

	///// Panel has had significant changes for version 2.15.  Need a way to check for the old version and update the panel
	///// It will be done by checking existence of new variables.  If they don't exist then check for a userdata version number
	///// If the userdata version doesn't exist or < MPF2_UPDATEPANELVERSION then update the panel and additional coefficients
	SetWindow $panelName userdata(MPF2_UPDATEPANELVERSION)=num2str(MPF2_UPDATEPANELVERSION)
	
	// Variable/G $(DFPath+":negativePeaks") = NumVarOrDefault(DFPath+":negativePeaks", 0)
	Variable doNegPeaks = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindNegativePeaks", 0)		// ST: 221202 - initialize with global options
	Variable/G $(DFPath+":negativePeaks") = doNegPeaks
	NVAR negativePeaks = $(DFPath+":negativePeaks")
	Variable/G $(DFPath+":displayPeaksFullWidth") = NumVarOrDefault(DFPath+":displayPeaksFullWidth", 0)
	NVAR displayPeaksFullWidth = $(DFPath+":displayPeaksFullWidth")
	Variable/G $(DFPath+":panelPosition") = position

	Variable/G $(DFPath+":MPF2_UserCursors") = NumVarOrDefault(DFPath+":MPF2_UserCursors", 0)
	NVAR useCursors = $(DFPath+":MPF2_UserCursors")
	
	Variable listprecision = NumVarOrDefault(DFPath+":MPF2_CoefListPrecision", 5)
	Variable/G $(DFPath+":MPF2_CoefListPrecision") = listprecision
	NVAR MPF2_CoefListPrecision = $(DFPath+":MPF2_CoefListPrecision")
	
	String SetNote = "\\K(40000,40000,40000)You can give this set a name or description"		// ST: 200820 - the set notes control
	if (strlen(UserNotes) > 0)
		SetNote = UserNotes
	endif
	SetVariable MPF2_SetNoteControl,pos={10,8},size={width-20,20},bodyWidth=width-75,title="Set Note:"
	SetVariable MPF2_SetNoteControl,value=_STR:SetNote,proc=MPF2_SetNoteControlProc,styledText=1
	
	String ControlList = ""
	//// Panel P0 - Peak location
	NewPanel/N=P0/W=(0,86,width,149)/FG=(FL,UGH0,FR,UGH1)/HOST=$panelName 
	ModifyPanel frameStyle=0, frameInset=0

		GroupBox MPF2_LocatePeaksGroupBox,pos={8,2},size={width-16,61},title="Locate Peaks"
		GroupBox MPF2_LocatePeaksGroupBox,fStyle=1
	
		Button MPF2_AutoLocatePeaksButton,pos={20,21},size={145+addWidth,20},title="Auto-locate Peaks Now"
		Button MPF2_AutoLocatePeaksButton,proc=MPF2_AutoLocatePeaksButtonProc
		
		Button MPF2_AutoLocateFromResidualsButton,pos={width-addWidth-165,21},size={145+addWidth,20},title="Find More in Residuals"		// ST: button to auto-locate peaks in residuals
		Button MPF2_AutoLocateFromResidualsButton,proc=MPF2_AutoLocateFromResidualsButtonProc
		
		CheckBox MPF2_NegativePeaksCheck,pos={(width-60)/2,44},size={85,14},title="Negative Peaks"
		CheckBox MPF2_NegativePeaksCheck,variable=negativePeaks
	
		CheckBox MPF2_DiscloseAutoPickParams,pos={14,45},size={16,14},proc=MPF2_DiscloseAutoPickCheckProc,title=""
		CheckBox MPF2_DiscloseAutoPickParams,value=0,mode=2
		
#if IgorVersion() >= 7
		CheckBox MPF2_DiscloseAutoPickParams focusRing=0
#endif
		if (CmpStr(IgorInfo(2), "Macintosh") == 0)
			ControlList = "MPF2_AutoLocatePeaksButton;MPF2_AutoLocateFromResidualsButton;MPF2_NegativePeaksCheck;"
			ModifyControlList ControlList fsize=10
		endif
	SetActiveSubwindow ##

	//// Panel P1 - fit controls
	NewPanel/N=P1/FG=(FL,UGH1,FR,UGH2)/HOST=$panelName 
		ModifyPanel frameStyle=0, frameInset=0
		String listPanel = panelName+"#P1"
		GetWindow $listPanel, wsize
		Variable panelHeight = V_bottom - V_top
		Variable listHeight = panelHeight - MPF2_PeakListTop - 2
	
		CheckBox MPF2_UserCursorsCheckbox,win=$listPanel,pos={10,2},size={102,14},title="Use Graph Cursors"
		CheckBox MPF2_UserCursorsCheckbox,win=$listPanel,value=useCursors,proc=MPF2_CursorsCheckProc
		
		String ModifyCursors = ""
		if (useCursors == 1)															// ST; 201203 - mark the fit range with vertical cross hairs
			if (strlen(CsrInfo(A, hostgraph)) > 0)
				ModifyCursors += "Cursor/M/H=2 A;"
			endif
			if (strlen(CsrInfo(B, hostgraph)) > 0)
				ModifyCursors += "Cursor/M/H=2 B;"
			endif
			Execute/P/Q/Z ModifyCursors													// ST: 201229 - postpone cursor actions until everything is built, since this command calls "cursormoved" of the graph hook
		endif

		CheckBox MPF2_DiscloseConstraints,win=$listPanel,pos={(MPF2_NarrowWidth-60)/2,2},size={85,15},title="Apply Constraints",value=MPF2ConstraintsShowing,proc=MPF2_DiscloseConstraints		// ST: center & nudge this control a bit to the right

		Button MPF2_HelpButton,pos={width-60,0},size={50,20},title="Help", proc=MPF2_DoHelpButtonProc
		
		ListBox MPF2_PeakList,win=$listPanel,pos={6,MPF2_PeakListTop},size={width-12,listHeight},clickEventModifiers=2+4	// don't allow checkbox toggle or selection with option or context click
		ListBox MPF2_PeakList win=$listPanel,userdata(MPF2_DataSetNumber)=num2str(setnumber)
		
		MakeListIntoHierarchicalList(listPanel, "MPF2_PeakList", "PeakListOpenNotify", selectionMode=WMHL_SelectionNonContinguous, userListProc="MPF2_PeakListProc")
		WMHL_AddColumns(listPanel, "MPF2_PeakList", 6)		
		WMHL_SetNotificationProc(listPanel, "MPF2_PeakList", "PeakListClosingNotify", WMHL_SetClosingNotificationProc)
		WMHL_AddObject(listPanel, "MPF2_PeakList", "", "Baseline", 1)
		WMHL_ExtraColumnData(listPanel, "MPF2_PeakList", 0, 0, "Constant"+MENU_ARROW_STRING, 0)
		
		if (MPF2ConstraintsShowing)
			ListBox MPF2_PeakList win=$listPanel,widths={16,70,110,50,30,35,30,35}		// ST: 200820 - adjusted column spacing
		else 
			ListBox MPF2_PeakList win=$listPanel,widths={20,85,130,55,0,0,0,0}
		endif
		
		if (CmpStr(IgorInfo(2), "Macintosh") == 0)
			ControlList = "MPF2_UserCursorsCheckbox;MPF2_DiscloseConstraints;MPF2_HelpButton;"
			ModifyControlList ControlList fsize=10
		endif
	SetActiveSubwindow ##

	NewPanel/N=P2/W=(65,86,width,260)/FG=(FL,UGH2,FR,UGH3)/HOST=$panelName 
		ModifyPanel frameStyle=0, frameInset=0
		String buttonPanel = panelName+"#P2"
		//Variable leftSideControlOffset = floor(MPF2_NarrowWidth/20)

		PopupMenu MPF2_SetAllPeakTypesMenu,win=$buttonPanel,pos={width-MPF2_CtrlMargin-175,6},size={175,20},proc=MPF2_SetAllPeakTypesMenuProc,title="\JCSet Type for All Peaks"			// ST: aligned left-hand controls and center text
		PopupMenu MPF2_SetAllPeakTypesMenu,win=$buttonPanel,mode=0,bodywidth=175,value= #"MPF2_ListPeakTypeNames()"

		Button MPF2_AddOrEditPeaksButton,win=$buttonPanel,pos={MPF2_CtrlMargin,5},size={120,20},proc=MPF2_AddOrEditPeaksButtonProc,title="Add or Edit Peaks"								// ST: adds the option to edit peaks in the panel

		Button MPF2_DoFitButton,win=$buttonPanel,pos={MPF2_CtrlMargin,35},size={50,20},proc=MPF2_DoFitButtonProc,title="Do Fit"
		Button MPF2_DoFitButton,win=$buttonPanel,fStyle=1,fColor=(32768,32770,65535), disable=2

		Button MPF2_PeakResultsButton,win=$buttonPanel,pos={width-MPF2_CtrlMargin-175,35},size={175,20},proc=MPF2_PeakResultsButtonProc,title="Peak Results..."

		Button MPF2_RevertToGuessesButton,win=$buttonPanel,pos={MPF2_CtrlMargin,65},size={50,20},proc=MPF2_RevertToPreviousButtonProc,title="Revert",help={"Tries to revert the coefficients to a state before the Do Fit button was pressed."} 		// ST: rename the button just to 'revert'
	
		Variable CPExists = DataFolderExists(DFpath+"CP")
		String CheckPointName = "\JC" + SelectString(CPExists, "No Checkpoint Yet", "Checkpoint Saved")												// ST: show whether a checkpoint exists or not in the title
		String CheckPointSelection = "\"Save Checkpoint;"+SelectString(CPExists, "\"", "Restore Checkpoint;\"")
		PopupMenu MPF2_CheckPointMenu,pos={width-MPF2_CtrlMargin-175,66},size={175,20},title=CheckPointName, proc=MPF2_CheckpointMenuProc		// ST: aligned left-hand controls
		PopupMenu MPF2_CheckPointMenu,mode=0,bodywidth=175,value= #CheckPointSelection
		
		if (CmpStr(IgorInfo(2), "Macintosh") == 0)
			ControlList = "MPF2_AddOrEditPeaksButton;MPF2_DoFitButton;MPF2_PeakResultsButton;MPF2_RevertToGuessesButton;"
			ModifyControlList ControlList fsize=10
		endif
	SetActiveSubwindow ##
	
	NewPanel/N=P3/W=(65,86,196,386)/FG=(FL,UGH3,FR,FB)/HOST=# 
		ModifyPanel frameStyle=0, frameInset=0
		
		NVAR/Z MPF2OptionsShowing = $(DFPath+":MPF2OptionsShowing")
		if (!NVAR_Exists(MPF2OptionsShowing))
			Variable/G $(DFPath+":MPF2OptionsShowing")
			NVAR MPF2OptionsShowing = $(DFPath+":MPF2OptionsShowing")
			MPF2OptionsShowing = 0
			
			String/G $(DFPath+":MPF2WeightWaveName")
			SVAR MPF2WeightWaveName = $(DFPath+":MPF2WeightWaveName")
			MPF2WeightWaveName = ""
			String weightPath = "_none_"
			
			String/G $(DFPath+":MPF2MaskWaveName")
			SVAR MPF2MaskWaveName = $(DFPath+":MPF2MaskWaveName")
			MPF2MaskWaveName = ""
			String maskPath = "_none_"
		else
			SVAR MPF2WeightWaveName = $(DFPath+":MPF2WeightWaveName")
			SVAR MPF2MaskWaveName = $(DFPath+":MPF2MaskWaveName")
			Wave/Z w = $MPF2WeightWaveName
			if (WaveExists(w))
				weightPath = GetWavesDataFolder(w, 2)
			else
				weightPath = "_none_"
			endif
			Wave/Z w = $MPF2MaskWaveName
			if (WaveExists(w))
				maskPath = GetWavesDataFolder(w, 2)
			else
				maskPath = "_none_"
			endif
		endif
		
		CheckBox MPF2_DiscloseOptions,pos={10,5},size={51,14},title="Options",value= 0,mode=2,proc=MPF2_DiscloseOptions
#if IgorVersion() >= 7
		CheckBox MPF2_DiscloseOptions focusRing=0
#endif

		Button MPF2_MoreConstraintsButton, pos={MPF2_CtrlMargin,25},size={120,20},title="More Constraints...",disable=2*(!MPF2ConstraintsShowing),proc=MPF2_MoreConstraintsButtonProc	// ST 2.47: disable state depends on constraints checkbox state

		CheckBox MPF2_DisplayPeakXWidthCheck,pos={width-MPF2_CtrlMargin-175,28},size={175,14},title="Display Peaks on Full X Range"
		CheckBox MPF2_DisplayPeakXWidthCheck,variable=displayPeaksFullWidth,proc=MPF2_DisplayPeakXWidthCheckProc

		SetVariable MPF2_SetListPrecision,pos={MPF2_CtrlMargin+85,52},size={180,14},bodyWidth=90,proc=MPF2_SetListPrecisionProc		// ST: center this control as well, adjusted text size
		SetVariable MPF2_SetListPrecision,title="Coefficient List Precision:",value=MPF2_CoefListPrecision

		SetVariable MPF2_SetFitTolerance,pos={MPF2_CtrlMargin+85,74},size={180,16},bodyWidth=90,title="Fit Converge Tolerance:"		// ST: set the tolerance of the fit
		SetVariable MPF2_SetFitTolerance,value=MPF2_FitTolerance,limits={1E-10,0.1,0}
		SetVariable MPF2_SetFitTolerance,Help={"Decides the fractional decrease of chi-square from one iteration to the next after which the fit terminates. Smaller values are more strict."}
		
		String FitPntSet = "Auto"											// ST: 211220 - load saved fit point setting
		SVAR/Z savedFitPntSet = $(DFpath+":Panel_FitPointSetting")
		if (SVAR_Exists(savedFitPntSet))
			FitPntSet = savedFitPntSet
		endif
		
		SetVariable MPF2_SetFitCurvePoints,pos={MPF2_CtrlMargin+85,96},size={180,16},bodyWidth=90,title="Fit Curve Points:"
		SetVariable MPF2_SetFitCurvePoints,value= _STR:FitPntSet,proc=MPF2_SetFitCurvePointsProc
		SetVariable MPF2_SetFitCurvePoints,Help={"\"Auto\", \"Point for Point\", or a number"}

		TitleBox MPF2_MaskWaveTitle,pos={MPF2_CtrlMargin+10,122},size={57,13},title="Mask Wave:",frame=0   		
		Button MPF2_SelectMaskWave,pos={MPF2_CtrlMargin+85,120},size={180,20},title=""
		MakeButtonIntoWSPopupButton(panelName+"#P3", "MPF2_SelectMaskWave", "MPF2_MaskWaveSelectNotify")
		PopupWS_AddSelectableString(panelName+"#P3", "MPF2_SelectMaskWave", "_none_")
		PopupWS_SetSelectionFullPath(panelName+"#P3", "MPF2_SelectMaskWave", maskPath)

		TitleBox MPF2_WeightWaveTitle,pos={MPF2_CtrlMargin,147},size={67,13},title="Weight Wave:",frame=0
		Button MPF2_SelectWeightWave,pos={MPF2_CtrlMargin+85,145},size={180,20},title=""
		MakeButtonIntoWSPopupButton(panelName+"#P3", "MPF2_SelectWeightWave", "MPF2_WeightWaveSelectNotify")
		PopupWS_AddSelectableString(panelName+"#P3", "MPF2_SelectWeightWave", "_none_")
		PopupWS_SetSelectionFullPath(panelName+"#P3", "MPF2_SelectWeightWave", weightPath)
		
		if (CmpStr(IgorInfo(2), "Macintosh") == 0)
			ControlList = "MPF2_DiscloseOptions;MPF2_MoreConstraintsButton;MPF2_DisplayPeakXWidthCheck;MPF2_SetListPrecision;MPF2_SetFitTolerance;MPF2_SetFitCurvePoints;MPF2_MaskWaveTitle;MPF2_WeightWaveTitle;"
			ModifyControlList ControlList fsize=10
		endif
//		RenameWindow #,P3
	SetActiveSubwindow ##
	
	SetWindow $panelName userdata(MPF2_hostgraph) = hostgraph
	SetWindow $panelName userdata(MPF2_DataSetNumber) = num2str(setNumber)

	SetWindow $hostgraph, hook(MPF2_DataGraphHook)=MPF2_DataGraphHook
	SetWindow $panelName, hook(MPF2_PanelKillHook)=MPF2_PanelKillHook
	SetWindow $panelName, hook(MPF2_PanelResizeHook)=MPF2_PanelResizeHook
		
	if (MPF2OptionsShowing)
		STRUCT WMCheckboxAction s
		s.win = panelName+"#P3"
		s.checked = 1
		s.eventCode = 2
		CheckBox MPF2_DiscloseOptions,win=$(panelName+"#P3"),value=1
		MPF2_DiscloseOptions(s)
	endif
	
	// ST: 200603 - The function MPF2_DisplayStatusMessage(MessageStr, setDF) can be called to display text in the MPF2StatusDisplay textbox below.
	// This function can be called inside background and peak functions to convey information to the user, like a failed calculation etc.
	// The textbox text is reset to "" upon every update inside MPF2_AddPeaksToGraph(), MPF2_UpdateBaselineOnGraph() and MPF2_UpdateOnePeakOnGraph().
	TextBox/W=$hostgraph/C/N=MPF2StatusDisplay/F=0/B=1/A=LT/X=2.00/Y=21 ""	// ST: add a display for generic status messages
	TextBox/W=$hostgraph/C/N=MPF2ChiSqDisplay/F=0/B=1/A=RT/X=2.00/Y=19.5 ""	// ST: add a display for the chi square value
	ModifyGraph/W=$hostgraph mirror=1,standoff=0,minor(bottom)=1			// ST: get a cleaner graph appearance
	MPF2_DisplayChiSqInfo(setNumber)
End

Function MPF2_UseCursorsIsChecked(String gname)
	ControlInfo/W=$(gname+"#MultiPeak2Panel#P1") MPF2_UserCursorsCheckbox
	return V_value
end

Function MPF2_SetListPrecisionProc(s) : SetVariableControl
	STRUCT WMSetVariableAction &s

	switch( s.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			String panelName = ParseFilePath(1, s.win, "#", 1, 0)
			String peakPanel = panelName+"P1"
			panelName = panelName[0, strlen(panelName)-2]					// ParseFilePath leaves the separator string on the end
			Variable setNumber = GetSetNumberFromWinName(s.win)
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
			
			Variable precision = s.dval
			NVAR MPF2_CoefListPrecision = $(DFPath+":MPF2_CoefListPrecision")
			MPF2_CoefListPrecision = floor(precision)

			ControlInfo/W=$peakPanel MPF2_PeakList
			WAVE listwave = $(S_DataFolder+S_value)
			Variable nrows = DimSize(listwave, 0)
			Variable i
			for (i = 0; i < nrows; i++)
				if (WMHL_RowIsContainer(peakPanel, "MPF2_PeakList", i))
					if (WMHL_RowIsOpen(peakPanel, "MPF2_PeakList", i))
						String itempath = WMHL_GetItemForRowNumber(peakPanel, "MPF2_PeakList", i)
						WMHL_closeAContainer(peakPanel, "MPF2_PeakList", itempath)
						WMHL_OpenAContainer(peakPanel, "MPF2_PeakList", itempath)
					endif
				endif
			endfor
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function MPF2_SetNoteControlProc(struct WMSetVariableAction & s) : SetVariableControl
	if (s.eventCode == 7 && StringMatch(s.sval,"*You can give this set a name or description"))
		SetVariable MPF2_SetNoteControl, win=$s.win, value=_STR:""
	endif
	if (s.eventCode == 2 || s.eventCode == 8)
		writeSetNotesAndUpdateControl(s.win, s.sval)
		
		// Variable setNumber = GetSetNumberFromWinName(s.win)
		// String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
		// SVAR/Z UserNotes = $(DFPath+":UserNotes")				// ST: 200820 - add support for a set name
		// if (!SVAR_Exists(UserNotes))
			// String/G $(DFPath+":UserNotes")
			// SVAR UserNotes = $(DFPath+":UserNotes")
		// endif
		// UserNotes = s.sval
		// if (strlen(s.sval) == 0)
			// SetVariable MPF2_SetNoteControl, win=$s.win, value=_STR:"\\K(40000,40000,40000)You can give this set a name or description"
		// endif
	endif
	return 0
End

static Function writeSetNotesAndUpdateControl(string panel, string content)			// ST: 230618 - separated update function for notes to call from resume panel as well
	String DFpath = MPF2_FolderPathFromSetNumber(GetSetNumberFromWinName(panel))
	SVAR/Z UserNotes = $(DFPath+":UserNotes")
	if (!SVAR_Exists(UserNotes))
		String/G $(DFPath+":UserNotes")
		SVAR UserNotes = $(DFPath+":UserNotes")
	endif
	UserNotes = content
	if (WinType(panel) != 7)
		return 0
	endif
	if (strlen(content) == 0)
		SetVariable MPF2_SetNoteControl, win=$panel, value=_STR:"\\K(40000,40000,40000)You can give this set a name or description"
	else
		SetVariable MPF2_SetNoteControl, win=$panel, value=_STR:content
	endif
	return 0
End

Function MPF2_SetFitCurvePointsProc(s) : SetVariableControl
	struct WMSetVariableAction &s
	
	switch (s.eventCode)														
		case 2:																	// enter key
		case 3:																	// live update
			String panelName = ParseFilePath(1, s.win, "#", 1, 0)
			panelName = panelName[0, strlen(panelName)-2]						// ParseFilePath leaves the separator string on the end
			Variable setNumber = GetSetNumberFromWinName(s.win)
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
			
			String/G $(DFpath+":Panel_FitPointSetting") = s.sval				// ST: 211220 - save custom fit point setting for reloading things later
			
			Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
			SVAR YWvName = $(DFpath+":YWvName")
			Wave YData = $YWvName
			SVAR XWvName = $(DFpath+":XWvName")
			Wave/Z XData = $XWvName
				
			MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(panelName))
			break;
	endswitch
end

Function MPF2_MoreConstraintsButtonProc(struct WMButtonAction & s) : ButtonControl
	if (s.eventCode == 2)
		String panelName = StringFromList(0, s.win, "#")
		Variable setNumber = GetSetNumberFromWinName(s.win)
		
		MPF2_MakeExtraConstraintsPanel(setNumber)
	endif
end

Function MPF2_AddOrEditPeaksButtonProc(struct WMButtonAction & s) : ButtonControl		// ST: a button to call the 'Add or Edit Peaks' functionality from the panel
	if (s.eventCode == 2)
		Variable setNumber = GetSetNumberFromWinName(s.win)
		DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
		SVAR gname = DFRpath:GraphName
		
		GetMarquee/W=$gname bottom, left
		if (V_Flag == 0)
			DoAlert 1, "Drag a marquee on the graph around the region where you want to add or edit peaks. You can also select 'Add or Edit Peaks' directly from the marquee menu.\r\rDo you want to use the full graph area for editing?"
			if (V_Flag == 1)
				SetActiveSubwindow $gname
				GetWindow $gname psize
				SetMarquee/W=$gname V_left, V_top, V_right, V_bottom
				MPF2_MarqueeHandler("Add or Edit Peaks")			// ST: 210219 - call with desired action
			endif
		else
			SetActiveSubwindow $gname
			MPF2_MarqueeHandler("Add or Edit Peaks")
		endif
	endif
End

Function MPF2_DisplayPeakXWidthCheckProc(s) : CheckboxControl
	STRUCT WMCheckboxAction &s

	if (s.eventCode != 2)
		return 0
	endif
	
	String panelName = ParseFilePath(1, s.win, "#", 1, 0)
	panelName = panelName[0, strlen(panelName)-2]					// ParseFilePath leaves the separator string on the end
	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	SVAR YWvName = $(DFpath+":YWvName")
	Wave YData = $YWvName
	SVAR XWvName = $(DFpath+":XWvName")
	Wave/Z XData = $XWvName

	NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
	MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
end

static Function MPF2_EnableDisableDoFitButton(setNumber)
	Variable setNumber

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	SVAR gname = $(DFpath+":GraphName")
	String panelName = gname+"#MultiPeak2Panel"								// the hook function is attached to the host graph
	if (!WaveExists(wpi) || (DimSize(wpi, 0) == 0))
		Button MPF2_DoFitButton,win=$(panelName+"#P2"),disable=2
		//TitleBox MPF2_DoFitHelpBox,win=$(panelName+"#P2"),disable=0		// ST: 200804 - not needed anymore
	else
		Button MPF2_DoFitButton,win=$(panelName+"#P2"),disable=0
		//TitleBox MPF2_DoFitHelpBox,win=$(panelName+"#P2"),disable=1
	endif
end

static Function/S MPF2_FindPeaksOutOfRange(setNumber, pl, pr)
	Variable setNumber, pl, pr
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	SVAR YWvName = $(DFpath+":YWvName")
	Wave yw = $YWvName
	SVAR XWvName = $(DFpath+":XWvName")
	Wave/Z xw = $XWvName
	Variable XStart, XEnd
	Variable reversed // ST 2.48: make range aware of negative delta and inverse scaling
	if (WaveExists(xw))
		reversed = xw[0] > xw[numpnts(xw)-1]
		XStart = reversed ? xw[pr] : xw[pl]
		XEnd = reversed ? xw[pl] : xw[pr]
	else
		reversed = deltaX(yw) < 0
		XStart = reversed ? pnt2x(yw, pr) :  pnt2x(yw, pl)
		XEnd = reversed ? pnt2x(yw, pl) : pnt2x(yw, pr)
	endif
	
	String peakList = ""
	if (WaveExists(wpi))
		Variable npeaks = DimSize(wpi, 0)
		Variable i
		for (i = 0; i < npeaks; i += 1)
			if ( (wpi[i][0] < XStart) || (wpi[i][0] > XEnd) )
				peakList += num2str(i)+";"
			endif
		endfor
	endif
	
	return peakList
end

static Function MPF2_getFitCurvePoints(panelName)
	String panelName
	
	Variable points = 0		// Auto
	
	ControlInfo/W=$(panelName+"#P3") MPF2_SetFitCurvePoints
	String pointsStr = S_value
	if (CmpStr(pointsStr, "Point for Point") == 0)
		points = -1
	elseif (CmpStr(pointsStr, "Auto") != 0)
		points = str2num(pointsStr)
		if (Numtype(points) != 0)
			points = 0
		endif
	endif
	
	return points
end
	

// returns 1 to indicate the peak was deleted, or 0 if it was not. It might not be deleted if the peakItemString is not a peak parent row.
static Function MPF2_DeleteAPeak(gname, peakItemString)
	String gname, peakItemString
	
	Variable returnValue = 0
	
	String panelName = gname+"#MultiPeak2Panel"				// the hook function is attached to the host graph
	Variable setNumber = GetSetNumberFromWinName(gname)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	SVAR YWvName = $(DFpath+":YWvName")
	Wave YData = $YWvName
	SVAR XWvName = $(DFpath+":XWvName")
	Wave/Z XData = $XWvName
	
	NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
	
	if (WaveExists(wpi))
		Variable selectedRow = WMHL_GetRowNumberForItem(panelName+"#P1", "MPF2_PeakList", peakItemString)
		Variable BaselineRow = WMHL_GetRowNumberForItem(panelName+"#P1", "MPF2_PeakList", "Baseline")
		if (selectedRow > BaselineRow)						// don't delete the baseline row
			// save the baseline type
			String baselineStr = WMHL_GetExtraColumnData(panelName+"#P1", "MPF2_PeakList", 0, BaselineRow)
			String BL_TypeName = MPF2_PeakOrBLTypeFromListString(baselineStr)
			
			Variable peakNumber
			if (WMHL_RowIsContainer(panelName+"#P1", "MPF2_PeakList", selectedRow))
				sscanf peakItemString, "Peak %d", peakNumber
				MPF2_RemoveAllPeaksFromGraph(gname)
				DoUpdate
				MPF2_DeletePeakInfo(setNumber, peakNumber)
				NVAR negativePeaks = $(DFpath+":negativePeaks")
				MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
				MPF2_EnableDisableDoFitButton(setNumber)
//				DoUpdate
				MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(panelName))
//				DoUpdate
				returnValue = 1
			endif

			MPF2_InfoForBaseline(setnumber, BL_TypeName)
			
			Variable i
			String ListOfCWaveNames = "Baseline Coefs;"		// ST: the number of peaks has changed => backup coef waves
			for (i = 0; i < DimSize(wpi, 0); i += 1)
				ListOfCWaveNames += "Peak "+num2istr(i)+" Coefs;"
			endfor
			MPF2_BackupCoefWaves(ListOfCWaveNames, DFpath)
		endif
	endif
	
	return returnValue
end

Function MPF2_DataGraphHook(s)
	STRUCT WMWinHookStruct &s

	String gname = s.winName
	String panelName = s.winName+"#MultiPeak2Panel"			// the hook function is attached to the host graph
	Variable setNumber = GetSetNumberFromWinName(gname)
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	
	Variable returnValue = 0
	Variable peakNumber

	strswitch(s.eventName)
		case "activate":
			Variable MultiPeakPanelLocation = strsearch(s.winName, "#MultiPeak2Panel", 0)
			
			String MPFpanelName
			if (MultiPeakPanelLocation < 0)					// graph was the activated window
				MPFpanelName = (s.winName)+"#MultiPeak2Panel"
			else
				MPFpanelName = (s.winName)[0, MultiPeakPanelLocation+15]
			endif
			
			DoWindow  /W=$(MPFpanelName) MultiPeak2Panel
			if (V_Flag) 									// be sure the panel exists.
				String updatePanelStr = GetUserData(MPFpanelName, "", "MPF2_UPDATEPANELVERSION")
				Variable updatePanelNum = str2num(updatePanelStr)
				if (numtype(updatePanelNum)==2)
					updatePanelNum = 0
				endif
				
				Variable setNum = GetSetNumberFromWinName(s.winName)
		
				Variable lastUpdate = NumVarOrDefault("root:Packages:MultiPeakFit2:lastPanelUpdateNotification", 0)
				Variable panelVersion = NumVarOrDefault("root:Packages:MultiPeakFit2:MPF2_PanelVersion", 0)
			
				if (updatePanelNum < MPF2_UPDATEPANELVERSION && lastUpdate < MPF2_UPDATEPANELVERSION) 	// ST: 200529 - don't ask again if there was already an update notification for this version
					String cmd = "MPF2_AskAndDoUpdate("+num2str(setNum)+")"
					Execute/P/Q cmd
				endif
			endif
		
			break;
		case "cursormoved":
			if (!MPF2_UseCursorsIsChecked(gname))
				return 0
			endif
			
			NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
			NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
			if ( (strlen(CsrInfo(A, gname)) == 0) || (strlen(CsrInfo(B, gname)) == 0) )
				break		// need both cursors on the graph
			endif
			
			SVAR YWvName = DFRpath:YWvName
			SVAR XWvName = DFRpath:XWvName
			Wave YData = $YWvName
			Wave/Z XData = $XWvName
			
			if (StringMatch(s.cursorName, "A") || StringMatch(s.cursorName, "B"))	// ST 2.48: automatically place the cursor on the yData (only for cursors A & B)
				String YDataN = ParseFilePath(0, YWvName, ":", 1, 0)		// ST 2.48: extract the yData name
				if (!StringMatch(s.traceName, YDataN))						// ST 2.48: cursor is not on yData
					if (strlen(CsrInfo($s.cursorName, s.winName)) > 0)		// ST 2.48: cursor is still on graph
						Variable csrXpos = xcsr($s.cursorName, s.winName)
						if (WaveExists(XData))								// ST 2.48: convert to points for XY-data
							FindLevel/P/Q XData, csrXpos
							csrXpos = V_LevelX
							Cursor/P $s.cursorName $YDataN csrXpos
						else
							Cursor $s.cursorName $YDataN csrXpos			// ST 2.48: place the cursor
						endif
					endif
				endif
			endif

			Variable pl = pcsr(A)
			Variable pr = pcsr(B)
			Variable oldpl = XPointRangeBegin
			Variable oldpr = XPointRangeEnd
			XPointRangeEnd = max(pr, pl)
			XPointRangeBegin = min(pr, pl)
			XPointRangeEnd = min(DimSize(YData,0)-1, XPointRangeEnd)		// ST: 201203 - make sure that the range is not out of bounds here
			XPointRangeBegin = max(0, XPointRangeBegin)	
			
//			if (pl > pr)
//				Variable temp = pl
//				pl = pr
//				pr = temp
//			endif
//			if ( (pl > oldpl) || (pr < oldpr) )		// ST 2.48: do not delete out-of-range peaks here. Out-of-range peaks are cared for within the DoFitButtonProc instead.
//				String peakList = MPF2_FindPeaksOutOfRange(setNumber, pl, pr)
//				if (strlen(peakList) > 0)
//					Variable peaksToDelete = ItemsInList(peakList)
//					MPF2_RemoveAllPeaksFromGraph(gname)
//					for (i = peaksToDelete-1; i >= 0 ; i -= 1)
//						peakNumber = str2num(StringFromList(i, peakList))
//						MPF2_DeletePeakInfo(setNumber, peakNumber)
//					endfor
//					NVAR negativePeaks = DFRpath:negativePeaks
//					Wave/Z wpi = DFRpath:W_AutoPeakInfo
//					
//					NVAR displayPeaksFullWidth = DFRpath:displayPeaksFullWidth
//					MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
//					MPF2_EnableDisableDoFitButton(setNumber)
//					//DoUpdate
//					SVAR YWvName = DFRpath:YWvName
//					Wave YData = $YWvName
//					SVAR XWvName = DFRpath:XWvName
//					Wave/Z XData = $XWvName
//					MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(panelName))
//					//DoUpdate
//				endif
//			endif

			Wave/Z wpi = DFRpath:W_AutoPeakInfo		// ST: update fit curves on cursor move
			if (WaveExists(wpi))
				NVAR displayPeaksFullWidth = DFRpath:$("displayPeaksFullWidth")
				MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
				MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(panelName))
			endif
			break;
		case "renamed":
			SVAR savedGName = DFRpath:GraphName
			savedGName = s.winName 
			break;
		case "modified":							// ST: secretly replace the YWvName and XWvName strings if the raw data name had changed
			String Traces = TraceNameList(s.winName,";",1)
			SVAR YWvName = DFRpath:YWvName
			SVAR XWvName = DFRpath:XWvName
			String YDataTrace = ParseFilePath(0, YWvName, ":", 1, 0)
			String XDataTrace = ParseFilePath(0, XWvName, ":", 1, 0)
			Variable TraceWasModified = FindListItem(YDataTrace, Traces) == -1
			Wave/Z XWave = XWaveRefFromTrace(s.winName, YDataTrace)
			if (WaveExists(XWave))
				if (strlen(XWvName) > 0 && !StringMatch(PossiblyQuoteName(NameOfWave(XWave)), XDataTrace))			// ST: catch changes of the x wave as well
					TraceWasModified = 1
				endif
			endif
			
			if (TraceWasModified && WinType(s.winName+"#MultiPeak2Panel") != 0)		// ST: apparently the data name has changed
				String FolderWaves = "", QuotedNames = "", ChangedDataTrace = ""
				
				DFREF saveDFR = GetDataFolderDFR()
				SetDataFolder DFRpath
					FolderWaves = WaveList("*", ";", "")
				SetDataFolder saveDFR
				Variable i
				for (i = 0; i < ItemsInList(FolderWaves); i += 1)
					QuotedNames += PossiblyQuoteName(StringFromList(i,FolderWaves)) + ";"
				endfor
				ChangedDataTrace = RemoveFromList(QuotedNames,Traces)				// ST: remove everything in the MPF2 folder from the trace list (assumes the only trace not in this folder is the data)
				if (ItemsInList(ChangedDataTrace) > 1)
					DoWindow/F $(s.winName)											// ST: add a warning message if the data is renamed while using MPF2 with multiple traces displayed
					DoAlert 0, "It seems that one wave displayed in Multipeak Fit set "+num2str(setNumber)+" has been renamed.\r\rMulit-Peak Fit may break if the data used (was: "+YDataTrace+") is renamed."
					return 0
				endif
				ChangedDataTrace = StringFromList(0,ChangedDataTrace)
				
				UpdateMPFFolderForRenamedWaves(setNumber, ReplaceString("'",YDataTrace,""), TraceNameToWaveRef(s.winName, ChangedDataTrace), XWaveRefFromTrace(s.winName, ChangedDataTrace))
			endif
			break;
		case "kill":
			GetWindow $(s.winName), wsize
			Variable/G DFRpath:graphleft = V_left
			Variable/G DFRpath:graphtop = V_top
			Variable/G DFRpath:graphright = V_right
			Variable/G DFRpath:graphbottom = V_bottom
			break;
	endswitch
	
	return returnValue
end

static Function UpdateMPFFolderForRenamedWaves(Variable setNumber, String oldName, Wave NewYWave, Wave/Z NewXWave)			// ST: 230618 - separated out YName update functionality and made sure checkpoints are renamed as well
	DFREF SetPath = MPF2_FolderPathFromSetNumberDFR(setnumber)
	DFREF CpyPath = $(MPF2_FolderPathFromSetNumber(setNumber)+"CP")
	
	SVAR YWvName = SetPath:YWvName
	SVAR XWvName = SetPath:XWvName
	YWvName = GetWavesDataFolder(NewYWave, 2)		// ST: replace the name strings
	if (WaveExists(NewXWave))
		XWvName = GetWavesDataFolder(NewXWave, 2)
	else
		XWvName = ""
	endif
	String newName = NameOfWave(NewYWave)

	if (CmpStr(newName,oldName) != 0)
		Wave/Z FitWave = SetPath:$("fit_"+oldName)	// ST: rename all work waves
		if (WaveExists(FitWave))
			Rename FitWave, $("fit_"+newName)
		endif
		Wave/Z FitXWave = SetPath:$("fitx_"+oldName)
		if (WaveExists(FitXWave))
			Rename FitXWave, $("fitx_"+newName)
		endif
		Wave/Z ResWave = SetPath:$("res_"+oldName)
		if (WaveExists(ResWave))
			Rename ResWave, $("res_"+newName)
		endif
		Wave/Z BkgWave = SetPath:$("Bkg_"+oldName)
		if (WaveExists(BkgWave))
			Rename BkgWave, $("Bkg_"+newName)
		endif
	endif
	
	if (!DataFolderRefStatus(CpyPath))				// ST: do the same for the checkpoint if available
		return 0
	endif
	
	SVAR YWvName = CpyPath:YWvName
	SVAR XWvName = CpyPath:XWvName
	YWvName = GetWavesDataFolder(NewYWave, 2)
	if (WaveExists(NewXWave))
		XWvName = GetWavesDataFolder(NewXWave, 2)
	else
		XWvName = ""
	endif
	
	if (CmpStr(newName,oldName) != 0)
		Wave/Z FitWave = CpyPath:$("fit_"+oldName)
		if (WaveExists(FitWave))
			Rename FitWave, $("fit_"+newName)
		endif
		Wave/Z FitXWave = CpyPath:$("fitx_"+oldName)
		if (WaveExists(FitXWave))
			Rename FitXWave, $("fitx_"+newName)
		endif
		Wave/Z ResWave = CpyPath:$("res_"+oldName)
		if (WaveExists(ResWave))
			Rename ResWave, $("res_"+newName)
		endif
		Wave/Z BkgWave = CpyPath:$("Bkg_"+oldName)
		if (WaveExists(BkgWave))
			Rename BkgWave, $("Bkg_"+newName)
		endif
	endif
end

Function MPF2_PanelKillHook(s)
	STRUCT WMWinHookStruct &s
	
	// the panel is <graph name>#MultiPeak2Panel, but the subwindows will get kill events also, and they have names like <graph name>#MultiPeak2Panel#P0
	Variable firstPoundPos = strsearch(s.winName, "#", 0, 0)
	if (firstPoundPos > 0)
		string hostname = s.winName
		hostname = hostname[firstPoundPos+1, strlen(s.winName)-1]
		if (CmpStr(hostname, "MultiPeak2Panel") != 0)
			return 0
		endif
	endif
	
	strswitch (s.eventName)
		case "activate":
			Variable MultiPeakPanelLocation = strsearch(s.winName, "#MultiPeak2Panel", 0)
			
			String MPFpanelName
			if (MultiPeakPanelLocation < 0)					// graph was the activated window
				MPFpanelName = (s.winName)+"#MultiPeak2Panel"
			else
				MPFpanelName = (s.winName)[0, MultiPeakPanelLocation+15]
			endif
			
			DoWindow  /W=$(MPFpanelName) MultiPeak2Panel
			if (V_Flag) 									// be sure the panel exists.
				String updatePanelStr = GetUserData(MPFpanelName, "", "MPF2_UPDATEPANELVERSION")
				Variable updatePanelNum = str2num(updatePanelStr)
				if (numtype(updatePanelNum)==2)
					updatePanelNum = 0
				endif
				
				Variable setNum = GetSetNumberFromWinName(s.winName)
		
				Variable lastUpdate = NumVarOrDefault("root:Packages:MultiPeakFit2:lastPanelUpdateNotification", 0)
				Variable panelVersion = NumVarOrDefault("root:Packages:MultiPeakFit2:MPF2_PanelVersion", 0)
			
				if (updatePanelNum < MPF2_UPDATEPANELVERSION && lastUpdate < MPF2_UPDATEPANELVERSION)	// ST: 200529 - don't ask again if there was already an update notification for this version
					String cmd = "MPF2_AskAndDoUpdate("+num2str(setNum)+")"
					Execute/P/Q cmd
				endif
			endif
			break;
		case "kill":
		case "subwindowKill":
			// save a list of the peak functions and baseline function for use in re-constituting the peak list in the future
			MPF2_RefreshHoldStrings(s.winName)
			MPF2_SaveFunctionTypes(s.winName)
			Variable setNumber = GetSetNumberFromWinName(s.winName)
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
			Variable/G $(DFPath+":MPF2_UserCursors")
			NVAR useCursors = $(DFPath+":MPF2_UserCursors")
			SVAR gname = $(DFpath+":GraphName")

			useCursors = MPF2_UseCursorsIsChecked(gname)
			
			TextBox/W=$gname/K/N=MPF2StatusDisplay	// ST: 200530 - kill info text boxes
			TextBox/W=$gname/K/N=MPF2ChiSqDisplay
			
			if (WinType("EditOrAddPeaksGraph") == 1)
				Variable editSetNumber = str2num(GetUserData("EditOrAddPeaksGraph", "", "MPF2_DataSetNumber"))
				if (editSetNumber == setNumber)
					DoWindow/K EditOrAddPeaksGraph
				endif
			endif
			
			String extraConstraintsPanel = "MPF2_AdditionalConstraints_"+num2str(SetNumber)
			if (WinType(extraConstraintsPanel) == 7)
				// JW 190410 TODO: save equal-width and pair-location constraint info
				KillWindow $extraConstraintsPanel
			endif
			
			break;
	endswitch
end

Function MPF2_ExtraConstraintsNotebookHook(s)
	STRUCT WMWinHookStruct &s
	
	String subWinName
	Variable doValidationAndUpdate = 0
	Variable setNumber = GetSetNumberFromWinName(s.winName)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	SVAR/Z interPeakString = $(DFPath+":interPeakConstraints")
	
	Variable isValid = 0
	switch (s.eventCode)
		case 1:					// deactivate
			doValidationAndUpdate = 1
			
			if (SVAR_exists(interPeakString) && !StringMatch(s.winName, "*#*"))								// ST: 201126 - check constraints when the main panel is deactivated						
				isValid = MPF2_ValidateConstraint(setNumber, s.winName, interPeakString)
			endif
			
			// break			deliberately falling through.  Trying to figure out how to make sure this is executed once and exactly once - user can hit "enter" or user can click somewhere else.
			//					deactivate won't actually get run because there is no keycode.  Have to change the logic.  Seems keyboard lose focus doesn't trigger the deactivate hook, which is good in this case
		case 11:				// keyboard
			if (!stringmatch(s.winName,"*#MPF2_ConstraintExpressions"))	// only respond to events for this notebook
				return 0
			endif
			
			Variable bksl_n = char2num("\n")
			Variable bksl_r = char2num("\r")
			subWinName = StringFromList(ItemsInList(s.winName, "#")-1, s.winName, "#")

			if (CmpStr(subWinName, "MPF2_ConstraintExpressions")==0 && (s.keycode==bksl_n || s.keycode==bksl_r))
				doValidationAndUpdate = 1
			endif
			
			if (doValidationAndUpdate)
				if (!SVAR_exists(interPeakString))
					String /G $(DFPath+":interPeakConstraints")
					SVAR interPeakString = $(DFPath+":interPeakConstraints")
				endif

				GetSelection notebook, $(s.winName), 1
				Variable selstartpara = V_startParagraph
				Variable selstartpos = V_startPos
				Variable selendpara = V_endParagraph
				Variable selendpos = V_endPos
				Notebook $(s.winName), selection={startOfFile, endOfFile}
				GetSelection notebook, $(s.winName), 2

				interPeakString = S_Selection[0, strlen(S_Selection)-1]
				if (strlen(interPeakString) > 0)
					String noteConstrString = interPeakString												// ST 2.47: copy for re-insertion into notebook

					interPeakString += ";"
					interPeakString = ReplaceString("\n", interPeakString, ";")
					interPeakString = ReplaceString("\r", interPeakString, ";")

					String EqualConstraints = GrepList(interPeakString,"=")									// ST 2.47: get items with "="
					EqualConstraints = RemoveFromList(GrepList(interPeakString,"[<,>]"),EqualConstraints)	// ST 2.47: exclude expressions like '<=' or '>='
					Variable convertItems = ItemsInList(EqualConstraints)
					Variable i, skipToNextLine = 0					
					if (convertItems > 0)																	// ST 2.47: converts '=' constraint into '<','>' pair											
						for (i = 0; i < convertItems; i += 1)												// ST 2.47: loop only needed if somebody copies a bunch of '=' constraints from somewhere
							String curritem	= StringFromList(i, EqualConstraints)
							String leftexpr	= curritem[0,strsearch(curritem,"=",0)-1]						// ST 2.47: separate expressions around the '='
							String rightexpr	= curritem[strsearch(curritem,"=",inf,1)+1,inf]
							noteConstrString	= ReplaceString(curritem, noteConstrString, leftexpr + "<" + rightexpr +"\r" + leftexpr + ">" + rightexpr)		// ST 2.47: replace in both the notebook display and saved string
							interPeakString		= ReplaceString(curritem, interPeakString, leftexpr + "<" + rightexpr +";" + leftexpr + ">" + rightexpr)		// ST 2.47: using interpeakString for the notebook is bad, as the selection may be thrown off by the new '\r's
						endfor
						skipToNextLine = 1																	// ST 2.47: jumps to the next paragraph after the conversion
					endif
					
					interPeakString = ReplaceString(" ", interPeakString, "")								// ST 2.47: prevent 'empty' constraints at end
					interPeakString = ReplaceString("\t", interPeakString, "")
					interPeakString = RemoveFromList("",interPeakString)									// ST 2.47: remove all empty items				
					//interPeakString = ReplaceString(";;", interPeakString, ";") 							// ST 2.47: not needed anymore
				
					Notebook $(s.winName), text=noteConstrString											// ST 2.47: re-insert the constraints
					Notebook $(s.winName), selection={(selstartpara, selstartpos),(selendpara, selendpos)}, findText={"",1}
					if (skipToNextLine)																		// ST 2.47: adjust the selection further
						Notebook $(s.winName), selection={endOfNextParagraph,endOfNextParagraph}
					endif
				endif
			endif
			break
		case 17:
			if (SVAR_exists(interPeakString))			
				isValid = MPF2_ValidateConstraint(setNumber, s.winName, interPeakString)					// ST: 201126 - check constraints upon exiting the panel
				if (isValid == 0)
					return 2																				// ST: 201126 - don't kill the window
				endif
			endif
			break
		default:
			break
	endswitch
	
	return 0
End

// PanelCoordEdges is a panel-coordinate replacement for GetWindow wsizeDC for panels or graphs.
//
// A control with these corner coordinates will fill the entire (sub)window.
//
// PanelCoordEdges works with Graph windows, too, but we don't recommend
// putting controls in graphs; put the controls in a panel subwindow within graphs.

Static Function PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	String win	// can be "Panel0#P1", for example
	Variable &vleft, &vtop, &vright, &vbottom	// outputs, host window's left,top is 0,0

	Variable hasGuides = WinType(win) == 1 || winType(win) == 7	// only graphs and panels have guides
	if( hasGuides )
		vleft= NumberByKey("POSITION",GuideInfo(win,"FL"))
		vtop= NumberByKey("POSITION",GuideInfo(win,"FT"))
		vright= NumberByKey("POSITION",GuideInfo(win,"FR"))
		vbottom= NumberByKey("POSITION",GuideInfo(win,"FB"))
	else
		// NOTE: using GetWindow wsize or wsizeDC based on PanelResolution(win) == 72
		// will not work for a subwindow, because GetWindow Panel0#subwindow wsize
		// will instead actually return GetWindow Panel0#subwindow wsizeDC.
		// wsizeRM doesn't have this problem.
		GetWindow $win wsizeRM // restored points
		Variable PointsToPanelUnits = ScreenResolution/PanelResolution(win)
		vleft = V_left*PointsToPanelUnits // now panel units
		vtop = V_top*PointsToPanelUnits
		vright = V_right*PointsToPanelUnits
		vbottom = V_bottom*PointsToPanelUnits
	endif
	return hasGuides
End

static Function MPF2_EnforcePanelMinSize(win)
	String win
	
	Variable PointsToPanelUnits = ScreenResolution/PanelResolution(win)
	GetWindow $win wsize						// points
	Variable left	= V_left*PointsToPanelUnits	// now panel units
	Variable right	= V_right*PointsToPanelUnits
	Variable top	= V_top*PointsToPanelUnits
	Variable bottom	= V_bottom*PointsToPanelUnits
	Variable height	= MPF2_MinHeight			// already panel units
	ControlInfo/W=$(win+"#P0") MPF2_DiscloseAutoPickParams
	if (V_value)
		height += 65
	endif
	ControlInfo/W=$(win+"#P3") MPF2_DiscloseOptions
	if (V_Value)
		height += 150
	endif

	Variable setNumber = GetSetNumberFromWinName(win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	NVAR position = $(DFPath+":panelPosition")
	NVAR MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")	
	Variable baseWidth = MPF2ConstraintsShowing ? MPF2_PanelWidth : MPF2_NarrowWidth
	Variable width = max(baseWidth, right-left)
	height = max(height, bottom-top)

	switch(position)
		case 0:			// right
			left=0; top=height; right=width; bottom=height;
			break;
		case 1:			// left
			left=width; top=height; right=0; bottom=height;
			break;
		case 2:			// below
			left=width; top=0; right=width; bottom=height;
			break;
		case 3:			// above
			left=width; top=height; right=width; bottom=0;
			break;
	endswitch
	MoveSubWindow/W=$win fnum=(left, top, right, bottom)

#if IgorVersion() >= 7
	Variable minWidthPoints= baseWidth / PointsToPanelUnits
	Variable minHeightPoints = height / PointsToPanelUnits
	SetWindow $win sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#endif
End

static Function MPF2_PanelMoveControls(win)
	String win
	
	Variable width= NumberByKey("POSITION", GuideInfo(win, "FR"))	// panel units
	Variable top = NumberByKey("POSITION", GuideInfo(win, "UGH1"))
	Variable bottom = NumberByKey("POSITION", GuideInfo(win, "UGH2"))
	Variable height = bottom-top
	
	Variable grpheight = top + 2
	ControlInfo/W=$(win) MPF2_SetNoteControl
	if (abs(V_flag) == 5)
		Variable grptop = NumberByKey("POSITION", GuideInfo(win, "UGH0"))
		grpheight = top-grptop
		SetVariable MPF2_SetNoteControl, win=$(win), pos={10,8}, size={width-20,20}, bodyWidth=width-75
	endif

	//P0
	Variable addWidth = (width - MPF2_NarrowWidth)/2				// ST: 200820 - make panel elements smaller or wider depending on the panel size
	GroupBox MPF2_LocatePeaksGroupBox,	win=$(win+"#P0"), size={width-16,grpheight-9}
	Button MPF2_AutoLocatePeaksButton, 	win=$(win+"#P0"), size={145+addWidth,20}, pos={20,21}
	ControlInfo/W=$(win+"#P0") MPF2_AutoLocateFromResidualsButton
	if (abs(V_flag) == 1)
		Button MPF2_AutoLocateFromResidualsButton, win=$(win+"#P0"), pos={width-addWidth-165,21}, size={145+addWidth,20}
	endif
	CheckBox MPF2_NegativePeaksCheck, 	win=$(win+"#P0"), pos={(width-60)/2,44}

	//P1
	ListBox MPF2_PeakList,				win=$(win+"#P1"), size={width-16,height-23}		// re-size the listbox
	Button MPF2_HelpButton,				win=$(win+"#P1"), pos={width-60,1}

	//P2
	PopupMenu MPF2_SetAllPeakTypesMenu,	win=$(win+"#P2"), pos={width-MPF2_CtrlMargin-175,6},	size={175,20},bodywidth=175
	Button MPF2_PeakResultsButton,		win=$(win+"#P2"), pos={width-MPF2_CtrlMargin-175,35},	size={175,20}
	PopupMenu MPF2_CheckPointMenu,		win=$(win+"#P2"), pos={width-MPF2_CtrlMargin-175,66},	size={175,20},bodywidth=175
End

Function MPF2_PanelResizeHook(s)
	STRUCT WMWinHookStruct &s

	String win= s.winName	// want <data set graph name>#MultiPeak2Panel
	if ( s.eventCode == 6 && !(WinType(win)==5))	// resize, and make sure the inter-peak constraints notebook isn't the ultimate source
		MPF2_EnforcePanelMinSize(win)
		MPF2_PanelMoveControls(win)
	endif
end

Function MPF2_SaveFunctionTypes(panelName)
	String panelName		// full subwindow path
	
	String saveDF = GetDataFolder(1)

	Variable setNumber = GetSetNumberFromWinName(panelName)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	SetDataFolder DFpath
	String/G SavedFunctionTypes
	Wave/Z wpi = W_AutoPeakInfo
	SetDataFolder saveDF

	Variable BaselineRow = WMHL_GetRowNumberForItem(panelName+"#P1", "MPF2_PeakList", "Baseline")
	String baselineStr = WMHL_GetExtraColumnData(panelName+"#P1", "MPF2_PeakList", 0, BaselineRow)
	SavedFunctionTypes = MPF2_PeakOrBLTypeFromListString(baselineStr)+";"
	
	Variable nPeaks = 0
	if (WaveExists(wpi))
		nPeaks = DimSize(wpi, 0)
	endif
	Variable i
	for (i = 0; i < nPeaks; i += 1)
		Variable theRow = WMHL_GetRowNumberForItem(panelName+"#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		SavedFunctionTypes += MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(panelName+"#P1", "MPF2_PeakList", 0, theRow) ) + ";"
	endfor
end

Function MPF2_WaveSelectNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	ControlInfo/W=$GetStartPanelName(tab=0) MPF2_ChooseGraph
	String selection = S_value
	String graphItems = MPF2_ListGraphsWSelectedWaves()
	Variable selectedItem
	if (strlen(graphItems) == 0)
		selectedItem = 1
	else
		selectedItem = WhichListItem(selection, graphItems)
		selectedItem += 2		// 1 for zero-based list index, 1 for the New Graph item at the start of the menu. If nothing found, returns -1, so this results in selecting item 1, the New Graph item.
	endif
	PopupMenu MPF2_ChooseGraph,win=$GetStartPanelName(tab=0),mode=(selectedItem)
	ControlUpdate/W=$GetStartPanelName(tab=0) MPF2_ChooseGraph
end

Function MPF2_TraceMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Wave yw = TraceNameToWaveRef("", popStr)
	Wave/Z xw = XWaveRefFromTrace("", popStr)
	String waveTitle = "Y Wave: "+NameOfWave(yw)+"\rX Wave: "
	if (WaveExists(xw))
		waveTitle += NameOfWave(xw)
	else
		waveTitle += "_calculated_"
	endif
	TitleBox MPF2_InfoTitleBox, title=waveTitle
	
	// Do auto-find
End

Function MPF2_StarterChooseTraceMenu(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	String gname = WinName(0,1)
	Wave/Z yw = TraceNameToWaveRef(gname, popStr)
	if (WaveExists(yw))
		Wave/Z xw = XWaveRefFromTrace(gname, popStr)
		PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton", GetWavesDataFolder(yw, 2))
		if (WaveExists(xw))
			PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton", GetWavesDataFolder(xw, 2))
		else
			PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton", "_calculated_")
		endif
	endif
End

Function/S MPF2_ListGraphsWSelectedWaves()

	String yWName = PopupWS_GetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton")	
	String xWName = PopupWS_GetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton")
	Wave/Z yw = $yWName
	Wave/Z xw = $xWName
	if (!WaveExists(yw))
		return ""
	endif
	
	return MPF2_ListGraphsWithWaves(yw, xw)
end

Function/S MPF2_ListGraphsWithWaves(yw, xw)
	Wave yw
	Wave/Z xw
	
	String theList=""
	
	Variable i=0
	do
		String gname = WinName(i, 1)
		if (strlen(gname) == 0)
			break;
		endif
		
		Variable gotit = 0
		
		CheckDisplayed/W=$gname yw
		if (V_flag)
			String tlist = TraceNameList(gname, ";", 1)
			Variable nTraces = ItemsInList(tlist)
			Variable j=0
			for (j = 0; j < nTraces; j += 1)
				String tname = StringFromList(j, tlist)
				Wave dyw = TraceNameToWaveRef(gname, tname)
				if (CmpStr(GetWavesDataFolder(dyw, 2), GetWavesDataFolder(yw, 2)) == 0)
					if (WaveExists(xw))
						Wave/Z dxw = XWaveRefFromTrace(gname, tname)
						if (WaveExists(dxw) && (CmpStr(GetWavesDataFolder(dxw, 2), GetWavesDataFolder(xw, 2)) == 0) )
							gotit = 1
							break;
						endif
					else
						if (!WaveExists(XWaveRefFromTrace(gname, tname)))
							gotit = 1
							break;
						endif
					endif
				endif
			endfor
		endif 
		
		if (gotit)
			theList += gname+";"
		endif
		
		i += 1
	while(1)
	
	return theList
end

Function MPF2_Starter_FromTitleCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked			// 1 if selelcted, 0 if not

	String targetWin = WinName(0, 1+2, 1)
	String optionsStr = ""
	if (checked)
		optionsStr = "WIN:"+targetWin+",DIMS:1"
	endif
	PopupWS_MatchOptions(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton", listoptions = optionsStr)
	PopupWS_MatchOptions(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton", listoptions = optionsStr)
	if (checked)
		if (WinType(targetWin) == 1)		// target is a graph: pick the first trace and pre-set the popups to the Y and X waves from the first trace; pre-select the target graph as the graph to use
			String traces = TraceNameList(targetWin, ";", 1)
			if (strlen(traces) > 0)
				String tracename = StringFromList(0, traces)
				Wave yw = TraceNameToWaveRef(targetWin, tracename)
				Wave/Z xw = XWaveRefFromTrace(targetWin, tracename)
				PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton", GetWavesDataFolder(yw, 2))
				if (WaveExists(xw))
					PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton",  GetWavesDataFolder(xw, 2))
				else
					PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton", "_calculated_")
				endif
				Variable InitMode = strlen(GetUserData(targetWin, "", "MPF2_DataSetNumber")) != 0 ? 2 : 1	// ST: 200620 - if MPF2 graph initialize with previous set, if not start fresh
				PopupMenu MPF2_ChooseGraph,win=$GetStartPanelName(tab=0),popmatch=targetWin					// ST: 200620 - select matching graph as start
				PopupMenu MPF2_InitializeFromSetMenu, win=$GetStartPanelName(tab=0),mode=InitMode			// ST: 200620 - select appropriate init mode
			endif
			PopupMenu MPF2_StartPanel_TraceMenu,win=$GetStartPanelName(tab=0), disable=0
		elseif(WinType(targetWin) == 2)	// target is a table. Pre-select "New Graph". Pre-select _calculated_ as the X wave (?); Pre-select first wave in table as the Y wave.
			Variable i=0
			do
				Wave/Z w = WaveRefIndexed(targetWin, i, 1)
				if (WaveExists(w))
					if (WaveDims(w) == 1)
						break;
					endif
				else
					break;
				endif
				i += 1
			while(1)
			PopupMenu MPF2_ChooseGraph,win=$GetStartPanelName(tab=0),mode=1
			if (WaveExists(w))
				PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton", GetWavesDataFolder(w, 2))
				PopupWS_SetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton", "_calculated_")
			endif
			PopupMenu MPF2_StartPanel_TraceMenu,win=$GetStartPanelName(tab=0), disable=1
		endif
	else
		PopupMenu MPF2_StartPanel_TraceMenu,win=$GetStartPanelName(tab=0), disable=1
	endif
end

static Function isMonotonic(wx)
	Wave wx
	
	Variable smallestXIncrement

	Variable isMonotonic=0
	
	Duplicate/O/Free wx, diff
	Differentiate/DIM=0/EP=0/METH=1/P diff 
	WaveStats/Q/M=0 diff
	isMonotonic= (V_min >= 0) == (V_max >= 0)

	return isMonotonic
End

Function MPF2_StarterGuessOptionsProc(ctrlName) : ButtonControl			// ST: 221202 - sets initial parameters for the MPF panel
	String ctrlName
	
	Variable negativePeaks = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindNegativePeaks", 0)+1
	Variable trimFraction  = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindTrimFraction", 0.05)
	Variable userPeakWidth = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindPeakWidth", 0)
	Variable fixSmoothFact = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindfixedSmoothing", 0)
	Prompt negativePeaks, "search for negative peaks:",popup,"no;yes;"
	Prompt userPeakWidth, "minimum expected peak width (in scaled units of your data):"
	Prompt fixSmoothFact, "set a fixed smoothing factor (overrides automatic guess, if > 0):"
	Prompt trimFraction, "minimum trim fraction (peaks with lower height are discarded):"
	String helpStr = "This dialog sets global initial parameters for the peak auto-guessing function to find your peaks better. The minimum peak width is used as a lower limit for the smoothing factor."
	DoPrompt/HELP=helpStr "Global Peak Auto-Guess Settings" negativePeaks, userPeakWidth, fixSmoothFact, trimFraction
	if (!V_flag)
		Variable/G root:Packages:MultiPeakFit2:init_AutoFindNegativePeaks = negativePeaks-1
		Variable/G root:Packages:MultiPeakFit2:init_AutoFindTrimFraction = trimFraction
		Variable/G root:Packages:MultiPeakFit2:init_AutoFindPeakWidth = userPeakWidth
		Variable/G root:Packages:MultiPeakFit2:init_AutoFindfixedSmoothing = fixSmoothFact
	endif
	return 0
End

Function MPF2_WaveSelectContinueBtnProc(ctrlName) : ButtonControl
	String ctrlName

	String yWName = PopupWS_GetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectYWaveButton")	
	String xWName = PopupWS_GetSelectionFullPath(GetStartPanelName(tab=0), "MPF2_SelectXWaveButton")
	Wave/Z yw = $yWName
	Wave/Z xw = $xWName
	
	if (!WaveExists(yw))
		DoAlert 0, "It appears you have not selected data waves yet."
		return -1
	endif
	
	if (WaveDims(yw) > 1)						// ST: 200803 - check if 1D waves were selected
		DoAlert 0, "Multipeak Fit does not work with multidimensional data. Choose one-dimensional data to proceed."
		return -1
	endif
	
	if (WaveExists(xw))
		if (!isMonotonic(xw))
			DoAlert 0, "Your X data wave is not monotonic."
			return -1
		endif
		if (numpnts(yw) != numpnts(xw))			// ST: 200530 - check for size mismatch
			DoAlert 0, "Your X data wave has not the same size as your Y data wave."
			return -1
		endif
	endif

	Variable Panelposition = 0
	ControlInfo/W=$GetStartPanelName(tab=0) MPF2_PanelPositionMenu
	strswitch(S_value)
		case "Below":
			Panelposition = 2
			break;
		case "Left":
			Panelposition = 1
			break;
		case "Right":
			Panelposition = 0
			break;
		case "Above":
			Panelposition = 3
			break;
	endswitch

	ControlInfo/W=$GetStartPanelName(tab=0) MPF2_ChooseGraph
	String theGraph = S_value
	
	ControlInfo/W=$GetStartPanelName(tab=0) MPF2_InitializeFromSetMenu
	Variable initializeFrom = min(V_value, 3)
	Variable menuSetNumber
	sscanf S_value, "Set Number %d", menuSetnumber	

	MPF2_StartNewMPFit(Panelposition, theGraph, yWName, xWName, initializeFrom, menuSetNumber)
end

Function MPF2_StartNewMPFit(Panelposition, theGraph, yWName, xWName, initializeFrom, initializeFromSet)
	Variable Panelposition			// 0: right, 1: left, 2: below, 3: above
	String theGraph					// a graph name or "New Graph"
	String yWName, xWName
	Variable initializeFrom			// 1: Start Fresh; 2: Previous for this graph; 3: from set number...
	Variable initializeFromSet		// if initializeFrom is 2, then this has the set number to initialize from
	
	Variable setnumber
	Variable buildingFromOldData = 0
	
	NVAR currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber

	Wave/Z yw = $yWName
	Wave/Z xw = $xWName
	String SaveDF = GetDataFolder(2)
	
	String gname = theGraph
	if ((CmpStr(gname, "New Graph") != 0) && WinType(gname) != 1)
		DoAlert 1, "The chosen graph does not exist. Do you want to make a new graph?"
		if (V_flag == 1)
			gname = "New Graph"
		else
			return -1											// ********* EXIT ***********
		endif
	endif
	
	Variable panelAlreadyExists = 0
	if (CmpStr(gname, "New Graph") == 0)
		if (WaveExists(xw))
			Display/K=1 yw vs xw
		else
			Display/K=1 yw
		endif
		String newGName = "MultipeakFit_Set"+num2str(currentSetNumber+1)
		RenameWindow $S_name, $newGName
		gname = newGName
	elseif (WinType(gname+"#MultiPeak2Panel"))
		panelAlreadyExists = 1
	endif
	
	if (initializeFrom == 1)													// start fresh
		if (panelAlreadyExists)
			DoAlert 1, "You selected \"Start Fresh\" but there is a Multipeak Fit panel already active for that graph. Close it and continue?"
			if (V_flag == 1)		// Yes was clicked
				KillWindow $(gname+"#MultiPeak2Panel")
			else
				return 0										// ********* EXIT ***********
			endif
		endif
		currentSetNumber += 1
		setnumber = currentSetNumber
		SetDataFolder root:Packages:MultiPeakFit2
		NewDataFolder/S/O $MPF2_FolderNameFromSetNumber(setnumber)
		
		String/G YWvName = GetWavesDataFolder(yw, 2)
		String/G XWvName = ""
		if (WaveExists(xw))
			XWvName = GetWavesDataFolder(xw, 2)
		endif
	elseif (initializeFrom > 1)													// "Previous Set for This Graph" or "Set N"
		String fName
		
		String graphSetNumberStr = GetUserData(gname, "", "MPF2_DataSetNumber" )
		Variable previousSetnumber = str2num(graphSetNumberStr)
		if (initializeFrom == 2 || previousSetnumber == initializeFromSet)		// "Previous Set for This Graph" 
			if (panelAlreadyExists)
				DoWindow/F $gname
				return 0										// ********* EXIT ***********
			endif
			setnumber = previousSetnumber
			fName = "root:Packages:MultiPeakFit2:"+MPF2_FolderNameFromSetNumber(setnumber)
			SetDataFolder $fName
		else																	// "Set N"
			if (panelAlreadyExists)
				DoAlert 1, "You selected Set Number "+num2str(initializeFromSet)+" but there is a Multipeak Fit panel already active for that graph. Close it and continue?"
				if (V_flag == 1)			// Yes was clicked
					KillWindow $(gname+"#MultiPeak2Panel")
				else
					return 0									// ********* EXIT ***********
				endif
			endif
			Variable copySetNumber = initializeFromSet
			String copyfName = "root:Packages:MultiPeakFit2:"+MPF2_FolderNameFromSetNumber(copySetNumber)
			currentSetNumber += 1
			setnumber = currentSetNumber
			fName = "root:Packages:MultiPeakFit2:"+MPF2_FolderNameFromSetNumber(setnumber)
			DuplicateDataFolder $copyfName, $fName
			SetDataFolder $fName
			SVAR YWvName
			SVAR XWvName
			Wave/Z oldY = $YWvName
			Wave/Z oldX = $XWvName
			
			// JW 200311 Try to make sure the point range from the Initialize From set is valid for the new data
			NVAR XPointRangeBegin
			NVAR XPointRangeEnd
			Variable oldXBegin
			Variable oldXEnd
			Variable oldXValid = 1
			if (WaveExists(oldX))
				oldXBegin = oldX[XPointRangeBegin]
				oldXEnd = oldX[XPointRangeEnd]
			elseif (WaveExists(oldY))
				oldXBegin = DimDelta(oldY,0) > 0 ? pnt2x(oldY, XPointRangeBegin) : pnt2x(oldY, XPointRangeEnd)		// ST: 201025 - make sure the order is preserved for negative delta waves
				oldXEnd = DimDelta(oldY,0) > 0 ? pnt2x(oldY, XPointRangeEnd) : pnt2x(oldY, XPointRangeBegin)
			else
				oldXValid = 0
			endif
			if (oldXValid)
				if (WaveExists(xw))
					XPointRangeBegin = BinarySearch(xw, oldXBegin)
					if (XPointRangeBegin == -1)
						XPointRangeBegin = 0
					elseif (XPointRangeBegin == -2)
						XPointRangeBegin = numpnts(xw)-1
					endif
					XPointRangeEnd = BinarySearch(xw, oldXEnd)
					if (XPointRangeEnd == -1)
						XPointRangeEnd = 0
					elseif (XPointRangeEnd == -2)
						XPointRangeEnd = numpnts(xw)-1
					endif
				else
					XPointRangeBegin = x2pnt(yw, oldXBegin)
					XPointRangeEnd = x2pnt(yw, oldXEnd)
				endif
			else
				XPointRangeBegin = 0
				XPointRangeEnd = numpnts(yw)-1
			endif
			
			Wave/Z OldFit = $("fit_"+NameOfWave(oldY))			// ST: clean up the data waves from the copied set, which are not needed anymore
			Wave/Z OldFitX = $("fitx_"+NameOfWave(oldY))
			Wave/Z OldRes = $("res_"+NameOfWave(oldY))
			Wave/Z OldBkg = $("Bkg_"+NameOfWave(oldY))
			KillWaves/Z OldFit, OldFitX, OldRes, OldBkg
			
			// ST: 201025 - make sure the range values are in the right order at this point
			Variable temp
			if (XPointRangeBegin > XPointRangeEnd)
				temp = XPointRangeEnd
				XPointRangeEnd = XPointRangeBegin
				XPointRangeBegin = temp
			endif
			// ST: 200605 - make sure the x range is not larger than the new waves
			XPointRangeBegin = XPointRangeBegin > numpnts(yw)-1 ? 0 : XPointRangeBegin
			XPointRangeBegin = XPointRangeBegin < 0 ? 0 : XPointRangeBegin
			XPointRangeEnd = XPointRangeEnd > numpnts(yw)-1 ? numpnts(yw)-1 : XPointRangeEnd
			XPointRangeEnd = XPointRangeEnd < 0 ? numpnts(yw)-1 : XPointRangeEnd
			XPointRangeBegin = XPointRangeBegin >= XPointRangeEnd ? 0 :XPointRangeBegin		// ST: 201025 - make sure that we haven't nullified the range
			
			YWvName = GetWavesDataFolder(yw, 2)
			if (WaveExists(xw))
				XWvName = GetWavesDataFolder(xw, 2)
			else
				XWvName = ""
			endif
			NVAR MPF2_UserCursors
			if (MPF2_UserCursors)
				ShowInfo/W=$gname
				Cursor/P/W=$gname A $NameOfWave(yw) XPointRangeBegin
				Cursor/P/W=$gname B $NameOfWave(yw) XPointRangeEnd
			endif
		endif
		
		if (initializeFrom == 2)
			SVAR YWvName
			SVAR XWvName
			if (CmpStr(yWName, YWvName) != 0)
				DoAlert 0, "The Y wave you selected ("+yWName+") is not the same as the one previously used with this graph ("+YWvName+"). Maybe it was re-named?"
				SetDataFolder saveDF
				return 0										// ********* EXIT ***********
			endif
			if (WaveExists(xw))
				if (CmpStr(xWName, XWvName) != 0)
					DoAlert 0, "The X wave you selected ("+xWName+") is not the same as the one previously used with this graph ("+XWvName+"). Maybe it was re-named?"
					SetDataFolder saveDF
					return 0									// ********* EXIT ***********
				endif
			else
				Wave/Z xxw = $XWvName
				if (WaveExists(xxw))
					DoAlert 0, "Previously, this graph was used with an XY pair, but you have selected _calculated_ for the X wave."
					SetDataFolder saveDF
					return 0									// ********* EXIT ***********
				endif
			endif
		endif
		buildingFromOldData = 1
	endif
	
	// Just in case we're starting from a previously-used graph, remove old result traces.
	// If they aren't there, /Z makes it OK to do anyway.
	MPF2_RemoveMPTracesFromGraph(gname)

	String/G GraphName = gname
	BuildMultiPeak2Panel(gname, setNumber, Panelposition)
	SetWindow $gname userdata(MPF2_DataSetNumber)=num2str(setNumber)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	if (buildingFromOldData)
		NVAR position = $(DFPath+":panelPosition")
		NVAR negativePeaks = $(DFPath+":negativePeaks")
		Wave /Z wpi = $(DFPath+":W_AutoPeakInfo")
		Variable nPeaks=0
		if (WaveExists(wpi))
			npeaks = DimSize(wpi, 0)
		endif
		SVAR SavedFunctionTypes = $(DFPath+":SavedFunctionTypes")
		
		ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,userdata(MPF2_DataSetNumber)=num2str(setnumber)
		MakeListIntoHierarchicalList(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "PeakListOpenNotify", selectionMode=WMHL_SelectionContinguous, userListProc="MPF2_PeakListProc")
		WMHL_AddColumns(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 6)		
		WMHL_SetNotificationProc(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "PeakListClosingNotify", WMHL_SetClosingNotificationProc)
		Wave/Z cwave = $(DFPath+":'Baseline Coefs'")
		if (!WaveExists(cwave))
			Make/O/D/N=1 $(DFPath+":'Baseline Coefs'")
		endif
		WMHL_AddObject(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "", "Baseline", 1)
		WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0, StringFromList(0, SavedFunctionTypes)+MENU_ARROW_STRING, 0)
		Variable i
		for (i = 0; i < npeaks; i += 1)
			WMHL_AddObject(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "", "Peak "+num2str(i), 1)
			WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, i+1, StringFromList(i+1, SavedFunctionTypes)+MENU_ARROW_STRING, 0)
		endfor
				
		NVAR/Z MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")
		if (!NVAR_Exists(MPF2ConstraintsShowing))
			Variable/G $(DFPath+":MPF2ConstraintsShowing")
			NVAR MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")
			MPF2ConstraintsShowing = 0
		endif
		if (MPF2ConstraintsShowing)
			ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={16,70,110,50,30,35,30,35}		// ST: 200820 - adjusted column spacing
		else 
			ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={20,85,130,55,0,0,0,0}
		endif

		NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
		if (waveExists(wpi))
			MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
			MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1)
		endif
		Wave/Z/T HoldStrings
		if (!WaveExists(HoldStrings))
			Make/T/N=(npeaks+1)/O $(DFPath+":HoldStrings")=""
		else
			SetHoldCheckboxesFromWave(setNumber)														// ST: reset hold check boxes
		endif
	else
		Make/O/D/N=1 $(DFPath+":'Baseline Coefs'")
		Variable RangeBegin, RangeEnd, RangeReversed
		MPF2_SetDataPointRange(gname, yw, xw, RangeBegin, RangeEnd, RangeReversed)
		Variable/G XPointRangeBegin = RangeBegin
		Variable/G XPointRangeEnd = RangeEnd
		Variable/G XPointRangeReversed = RangeReversed
		
		Variable fixSmoothFact = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindfixedSmoothing", 0)
		Variable userPeakWidth = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindPeakWidth", 0)			// ST: 221202 - user-provided width estimate
		if (WaveExists(xw))																							// ST: 221204 - convert width into points
			userPeakWidth /= abs(xw[1]-xw[0])
		else
			userPeakWidth /= DimDelta(yw,0)
		endif
		Variable userAborted = 0
		// if the user aborts EstPeakNoiseAndSmfact(), it can leave the data folder set wrong
		DFREF savedDFR = GetDataFolderDFR()
		try
			Variable/C ctmp = EstPeakNoiseAndSmfact(yw, RangeBegin, RangeEnd, userWidth=userPeakWidth);AbortOnRTE	// from PeakAutoFind.ipf
		catch
			if (V_AbortCode == -4 || V_AbortCode == -1)		// either run-time error, or user abort
				if (GetRTError(1) == 57 || V_AbortCode == -1)
					userAborted = 1
				endif
			endif
		endtry
		// if the user aborts EstPeakNoiseAndSmfact(), it can leave the data folder set wrong
		SetDataFolder savedDFR
		if (userAborted)
			Variable/G AutoFindNoiseLevel = 0
			Variable/G AutoFindSmoothFactor = fixSmoothFact > 0 ? fixSmoothFact : 1									// ST: 221204 - the smoothing factor may be set from global override
		else
			Variable/G AutoFindNoiseLevel = real(ctmp)
			Variable/G AutoFindSmoothFactor = fixSmoothFact > 0 ? fixSmoothFact : imag(ctmp)
		endif
		Variable trimPreset = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindTrimFraction", 0.05)		// ST: 221202 - read from global options
		Variable/G AutoFindTrimFraction = trimPreset
		Make/T/N=1/O $(DFPath+":HoldStrings")=""														// Initially a row for just the baseline
	endif
	
	ControlInfo/W=$gname#MultiPeak2Panel#P0 MPF2_DiscloseAutoPickParams
	if (V_value==1)
		SetVariable MPF2_SetAutoFindNoiseLevel,win=$gname#MultiPeak2Panel,value=AutoFindNoiseLevel
		SetVariable MPF2_SetAutoPeakSmoothFactor,win=$gname#MultiPeak2Panel,value=AutoFindSmoothFactor
		SetVariable MPF2_SetAutoPeakMinFraction,win=$gname#MultiPeak2Panel,value=AutoFindTrimFraction
	endif
	NVAR negativePeaks
	CheckBox MPF2_NegativePeaksCheck,win=$gname#MultiPeak2Panel#P0,variable=negativePeaks
	MPF2_EnableDisableDoFitButton(setNumber)
	
	SetDataFolder saveDF
End

static Function/S MPF2_FolderNameFromSetNumber(setnumber)
	Variable setnumber
	
	return "MPF_SetFolder_"+num2str(setnumber)
end

static Function/S MPF2_FolderPathFromSetNumber(setnumber)
	Variable setnumber
	
	return "root:Packages:MultiPeakFit2:"+MPF2_FolderNameFromSetNumber(setnumber)
end

static Function/DF MPF2_FolderPathFromSetNumberDFR(setnumber)
	Variable setnumber
	
	DFREF dfr = root:Packages:MultiPeakFit2:$MPF2_FolderNameFromSetNumber(setnumber)
	return dfr
end

Function MPF2_DiscloseAutoPickCheckProc(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	String panelName = ParseFilePath(1, s.win, "#", 1, 0)
	panelName = panelName[0, strlen(panelName)-2]					// ParseFilePath leaves the separator string on the end
	String gname = GetUserData(panelName, "", "MPF2_hostgraph")
	
	ControlInfo/W=$s.win MPF2_LocatePeaksGroupBox
	Variable width = V_Width
	Variable height = V_Height
	Variable gbright = V_left+width
	Variable gbtop = V_top+V_height

	Variable setNumber = GetSetNumberFromWinName(s.win)
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	NVAR position = DFRpath:panelPosition
	Variable left, top, right, bottom
	Variable panelHeight = s.checked ? MPF2_PanelHeight+65 : MPF2_PanelHeight
	
	NVAR MPF2ConstraintsShowing = DFRpath:MPF2ConstraintsShowing
	Variable panelWidth = MPF2ConstraintsShowing ? MPF2_PanelWidth : MPF2_NarrowWidth
	switch(position)
		case 0:			// right
			left=0; top=panelHeight; right=panelWidth; bottom=panelHeight;
			break;
		case 1:			// left
			left=panelWidth; top=panelHeight; right=0; bottom=panelHeight;
			break;
		case 2:			// below
			left=panelWidth; top=0; right=panelWidth; bottom=panelHeight;
			break;
		case 3:			// above
			left=panelWidth; top=panelHeight; right=panelWidth; bottom=0;
			break;
	endswitch

#if IgorVersion() >= 7
	SetWindow $panelName sizeLimit={0,0,Inf,Inf}
#endif

	Variable UGHpos = NumberByKey("POSITION", GuideInfo(panelName, "UGH1"))
	if (s.checked)
		DefineGuide/W=$panelName UGH1={FT,UGHpos+65}
		height += 65
	else
		DefineGuide/W=$panelName UGH1={FT,UGHpos-65}
		height -= 65
	endif
	MoveSubwindow/W=$(panelName+"#P0") fnum=(left, top, right, bottom)		// ST: only resize sub-panel
	
	ModifyControl MPF2_LocatePeaksGroupBox, win=$s.win, size={width, height}
	ControlUpdate/W=$s.win MPF2_LocatePeaksGroupBox
	
	NVAR AutoFindNoiseLevel = DFRpath:AutoFindNoiseLevel
	NVAR AutoFindSmoothFactor = DFRpath:AutoFindSmoothFactor
	NVAR AutoFindTrimFraction = DFRpath:AutoFindTrimFraction

	DoUpdate
	if (s.checked)
		left = 35
		SetVariable MPF2_SetAutoFindNoiseLevel,win=$s.win,pos={left,gbtop},size={145,15},title="Noise Level:"
		SetVariable MPF2_SetAutoFindNoiseLevel,win=$s.win,limits={0,inf,AutoFindNoiseLevel/10},value=AutoFindNoiseLevel,bodyWidth= 75		// ST: set a more convenient step size for the up and down arrows of the SetVariable control
		SetVariable MPF2_SetAutoPeakSmoothFactor,win=$s.win,pos={left,gbtop+21},size={145,15},title="Smooth Factor:"
		SetVariable MPF2_SetAutoPeakSmoothFactor,win=$s.win,limits={0,inf,1},value=AutoFindSmoothFactor,bodyWidth= 75
		SetVariable MPF2_SetAutoPeakMinFraction,win=$s.win,pos={left,gbtop+42},size={145,15},title="Min Fraction:"
		SetVariable MPF2_SetAutoPeakMinFraction,win=$s.win,limits={0,inf,0.01},value=AutoFindTrimFraction,bodyWidth= 75						// ST: set a more convenient step size for the up and down arrows of the SetVariable control
		left += 160
		Button MPF2_AutoPickEstimate,win=$s.win,pos={left,83},size={85,20},title="Estimate Now"
		Button MPF2_AutoPickEstimate,win=$s.win,proc=MPF2_EstimateAutoPickPButton
		if (CmpStr(IgorInfo(2), "Macintosh") == 0)
			Button MPF2_AutoPickEstimate,win=$s.win,fsize=10
		endif
	else
		KillControl/W=$s.win MPF2_SetAutoFindNoiseLevel
		KillControl/W=$s.win MPF2_SetAutoPeakSmoothFactor
		KillControl/W=$s.win MPF2_SetAutoPeakMinFraction
		KillControl/W=$s.win MPF2_AutoPickEstimate
	endif
	MPF2_EnforcePanelMinSize(panelName)
	MPF2_PanelMoveControls(panelName)
End

Function MPF2_DiscloseConstraints(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	String panelName = ParseFilePath(1, s.win, "#", 1, 0)
	panelName = panelName[0, strlen(panelName)-2]					// ParseFilePath leaves the separator string on the end
	String gname = GetUserData(panelName, "", "MPF2_hostgraph")
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	NVAR position = $(DFPath+":panelPosition")
	NVAR MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")
	MPF2ConstraintsShowing = s.checked
	
	Variable factor = ScreenResolution/PanelResolution(panelName)
	GetWindow $panelName wsize
	Variable left = V_left*factor
	Variable right = V_right*factor
	Variable top = V_top*factor
	Variable bottom = V_bottom*factor
	Variable panelHeight = bottom-top
	Variable panelWidth = right-left
  	
	panelWidth = s.checked ? panelWidth+(MPF2_PanelWidth-MPF2_NarrowWidth)*(panelWidth/MPF2_NarrowWidth) : panelWidth-(MPF2_PanelWidth-MPF2_NarrowWidth)*(panelWidth/MPF2_PanelWidth) 	// ST: not needed if MPF2_PanelWidth and MPF2_NarrowWidth are the same, but does not hurt
	if (panelWidth < MPF2_PanelWidth && s.checked)
		panelWidth = MPF2_PanelWidth
	elseif (panelWidth < MPF2_NarrowWidth && !s.checked)
		panelWidth = MPF2_NarrowWidth
	endif

	switch(position)
		case 0:			// right
			left=0; top=panelHeight; right=panelWidth; bottom=panelHeight;
			break;
		case 1:			// left
			left=panelWidth; top=panelHeight; right=0; bottom=panelHeight;
			break;
		case 2:			// below
			left=panelWidth; top=0; right=panelWidth; bottom=panelHeight;
			break;
		case 3:			// above
			left=panelWidth; top=panelHeight; right=panelWidth; bottom=0;
			break;
	endswitch
	
	//P0
	// MoveSubwindow /W=$(panelName+"#P0"), fnum=(0,86,panelWidth,149)
	// ControlInfo/W=$(panelName+"#P0") MPF2_LocatePeaksGroupBox					// ST: get the current size of the group box (depends on the open/close state of the options)
	// GroupBox MPF2_LocatePeaksGroupBox, win=$(panelName+"#P0"), size={panelWidth-16,V_Height}
	// Button MPF2_AutoLocatePeaksButton, win=$(panelName+"#P0"), size={135+extraSpace,20}
	// Button MPF2_AutoLocateFromResidualsButton, win=$(panelName+"#P0"), pos={fixWidth-extraSpace-155,21}, size={135+extraSpace,20}
	// CheckBox MPF2_NegativePeaksCheck, win=$(panelName+"#P0"), pos={(fixWidth-85)/2,44}
	
	//P1
	if (!s.checked)
		ListBox MPF2_PeakList, win=$(panelName+"#P1"), widths={20,85,130,55,0,0,0,0}
	else	
		ListBox MPF2_PeakList, win=$(panelName+"#P1"), widths={16,70,110,50,30,35,30,35}
	endif
	
	//P2
	// Variable leftSideControlOffset = floor(MPF2_NarrowWidth/20)
	// PopupMenu MPF2_SetAllPeakTypesMenu, win=$(panelName+"#P2"), pos={fixWidth-leftSideControlOffset-175,6}, size={175,20}, bodywidth=175	// ST: aligned left-hand controls
	// Button MPF2_AddOrEditPeaksButton, win=$(panelName+"#P2"), pos={leftSideControlOffset,5}
	// Button MPF2_DoFitButton, win=$(panelName+"#P2"), pos={leftSideControlOffset,35}
	// Button MPF2_PeakResultsButton, win=$(panelName+"#P2"), pos={fixWidth-leftSideControlOffset-175,35}
	// Button MPF2_RevertToGuessesButton, win=$(panelName+"#P2"), pos={leftSideControlOffset,65}
	// PopupMenu MPF2_CheckPointMenu, win=$(panelName+"#P2"), pos={fixWidth-leftSideControlOffset-175,66}			// ST: aligned left-hand controls

	//P3
	// TitleBox MPF2_ConstraintsExample,win=$(panelName+"#P3"),size={MPF2_NarrowWidth-50,20}						// ST: does not exist anymore
	// SetVariable MPF2_SetFitCurvePoints,win=$(panelName+"#P3"),pos={(MPF2_NarrowWidth-183)/2,96}
	// CheckBox MPF2_DisplayPeakXWidthCheck,win=$(panelName+"#P3"),pos={leftSideControlOffset+130,28}	
	Button MPF2_MoreConstraintsButton,win=$(panelName+"#P3"),disable=2*(!s.checked)									// ST 2.47: enable/disable 'More Constraints' button

	// NVAR /Z MPF2OptionsShowing = $(DFPath+":MPF2OptionsShowing")

#if IgorVersion() >= 7
	SetWindow $panelName sizeLimit={0,0,Inf,Inf}
#endif
	MoveSubwindow/W=$panelName fnum=(left, top, right, bottom)
	MPF2_EnforcePanelMinSize(panelName)
	MPF2_PanelMoveControls(panelName)
end

Function MPF2_DiscloseOptions(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	String panelName = ParseFilePath(1, s.win, "#", 1, 0)
	panelName = panelName[0, strlen(panelName)-2]					// ParseFilePath leaves the separator string on the end
	String gname = GetUserData(panelName, "", "MPF2_hostgraph")
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	NVAR position = $(DFPath+":panelPosition")
	NVAR MPF2OptionsShowing = $(DFPath+":MPF2OptionsShowing")
	MPF2OptionsShowing = s.checked
	
	Variable factor = ScreenResolution/PanelResolution(panelName)
	GetWindow $panelName wsize
	Variable left = V_left*factor
	Variable right = V_right*factor
	Variable top = V_top*factor
	Variable bottom = V_bottom*factor
	Variable panelHeight = bottom-top
	Variable panelWidth = right-left
 
	panelHeight = s.checked ? panelHeight+150 : panelHeight-150
	switch(position)
		case 0:			// right
			left=0; top=panelHeight; right=panelWidth; bottom=panelHeight;
			break;
		case 1:			// left
			left=panelWidth; top=panelHeight; right=0; bottom=panelHeight;
			break;
		case 2:			// below
			left=panelWidth; top=0; right=panelWidth; bottom=panelHeight;
			break;
		case 3:			// above
			left=panelWidth; top=panelHeight; right=panelWidth; bottom=0;
			break;
	endswitch

#if IgorVersion() >= 7
	SetWindow $panelName sizeLimit={0,0,Inf,Inf}
#endif
	if (s.checked)
		MoveSubWindow/W=$panelName fnum=(left, top, right, bottom)				// ST: 200820 - change panel size for options
		DefineGuide/W=$panelName UGH3={FB,-173}
		//Button MPF2_MoreConstraintsButton, win=$(panelName+"#P3"),disable=0	// ST 2.47: do not touch disable state here (is determined by constraints checkbox)
	else
		DefineGuide/W=$panelName UGH3={FB,-23}
		MoveSubWindow/W=$panelName fnum=(left, top, right, bottom)				// ST: 200820 - change panel size for options
		//Button MPF2_MoreConstraintsButton, win=$(panelName+"#P3"),disable=1	// ST 2.47: do not touch disable state here
	endif

	MPF2_EnforcePanelMinSize(panelName)
	MPF2_PanelMoveControls(panelName)
end

Function MPF2_MaskWaveSelectNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	if (event == WMWS_SelectionChanged)
		Variable setNumber = GetSetNumberFromWinName(windowName)
		String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
		SVAR MPF2MaskWaveName = $(DFPath+":MPF2MaskWaveName")
		Wave/Z w = $wavepath
		if (WaveExists(w))
			MPF2MaskWaveName = wavepath
		else
			MPF2MaskWaveName = ""
		endif
	endif
end

Function MPF2_WeightWaveSelectNotify(event, wavepath, windowName, ctrlName)
	Variable event
	String wavepath
	String windowName
	String ctrlName

	if (event == WMWS_SelectionChanged)
		Variable setNumber = GetSetNumberFromWinName(windowName)
		String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
		SVAR MPF2WeightWaveName = $(DFPath+":MPF2WeightWaveName")
		Wave/Z w = $wavepath
		if (WaveExists(w))
			MPF2WeightWaveName = wavepath
		else
			MPF2WeightWaveName = ""
		endif
	endif
end

Function MPF2_DoHelpButtonProc(String ctrlName) : ButtonControl
	DisplayHelpTopic "Multipeak Fitting"
end

Function MPF2_DoDeleteSetButtonProc(STRUCT WMButtonAction &ba) : ButtonControl		// ST: 230608 - deletes set which is selected in MPF2_ResumeSetMenu
	if (ba.eventCode != 2)
		return 0
	endif
	ControlInfo/W=$(ba.win) MPF2_ResumeSetMenu
	Variable setnumber = str2num(S_value)
	if (numtype(setnumber) == 0)
		MPF2_DeleteRequestedMPFSet(setnumber)
	endif
	return 0
end

Function MPF2_DoEditSetNotesButtonProc(STRUCT WMButtonAction &ba) : ButtonControl	// ST: 230608 - deletes set which is selected in MPF2_ResumeSetMenu
	if (ba.eventCode != 2)
		return 0
	endif
	ControlInfo/W=$(ba.win) MPF2_ResumeSetMenu
	Variable setnumber = str2num(S_value)
	if (numtype(setnumber) != 0)
		return 0
	endif
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	SVAR/Z UserNotes = DFRpath:UserNotes
	if (!SVAR_Exists(UserNotes))
		return 0
	endif
	String notes = UserNotes
	Prompt notes,"Enter a brief description of the fit set:"
	DoPrompt "Add or Edit Notes for Set "+num2str(setnumber), notes
	if (!V_Flag)
		SVAR gName = DFRpath:GraphName
		if (WinType(gName+"#MultiPeak2Panel") == 7)									// ST: 230921 - make sure the panel exists
			writeSetNotesAndUpdateControl(gName+"#MultiPeak2Panel", notes)
		else
			UserNotes = notes
		endif
		MPF2_PopulateResumeNBWithWaveNames(PanelName = ba.win)
	endif
	return 0
end

Function MPF2_EstimateAutoPickPButton(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			Variable setNumber = GetSetNumberFromWinName(ba.win)
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
			String saveDF = GetDataFolder(1)
			SetDataFolder DFpath
			
			SVAR YWvName
			SVAR XWvName
			Wave YData = $YWvName
			Wave/Z XData = $XWvName
			NVAR XPointRangeBegin
			NVAR XPointRangeEnd
			
			Variable fixSmoothFact = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindfixedSmoothing", 0)
			Variable userPeakWidth = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindPeakWidth", 0)		// ST: 221202 - user-provided width estimate
			if (WaveExists(XData))																					// ST: 221204 - convert width into points
				userPeakWidth /= abs(XData[1]-XData[0])
			else
				userPeakWidth /= DimDelta(YData,0)
			endif
			Variable/C ctmp=cmplx(0,0)
			if (abs(XPointRangeEnd - XPointRangeBegin) < 21)
				DoAlert 0, "Your data set does not have enough points for the peak auto find algorithm. Please drag a marquee on the graph and select Add or Edit Peaks"
			else
				ctmp = EstPeakNoiseAndSmfact(YData, XPointRangeBegin, XPointRangeEnd, userWidth=userPeakWidth)		// from PeakAutoFind.ipf
			endif
			Variable trimPreset = NumVarOrDefault("root:Packages:MultiPeakFit2:init_AutoFindTrimFraction", 0.05)	// ST: 221202 - read from global options
			Variable/G AutoFindNoiseLevel = real(ctmp)
			Variable/G AutoFindSmoothFactor = fixSmoothFact > 0 ? fixSmoothFact : imag(ctmp)						// ST: 221204 - the smoothing factor may be set from global override
			Variable/G AutoFindTrimFraction = trimPreset
			
			SetDataFolder saveDF
			break
	endswitch
	
	return 0
end

static Function MPF2_SetDataPointRange(gname, YData, XData, RangeBegin, RangeEnd, RangeReversed)
	string gname
	Wave YData
	Wave/Z XData
	Variable &RangeBegin
	Variable &RangeEnd
	Variable &RangeReversed

	RangeBegin= 0;
	RangeEnd= numpnts(YData)-1;
	
	Variable te= RangeEnd
	Variable V_Flag= 0

	CheckDisplayed/W=$gname YData
	Variable isGraphed= V_Flag
	Variable checkAxis = 0
	if( isGraphed )
		DoUpdate			// JW 160524 it is very likely that the graph was just made inside the calling function
		if (MPF2_UseCursorsIsChecked(gname))
			if (strlen(CsrInfo(A, gname)) == 0)
				DoAlert 0, "The Use Graph Cursors checkbox is checked, but the A cursor is not on the graph."
				checkAxis = 1
			endif
			if (strlen(CsrInfo(B, gname)) == 0)
				DoAlert 0, "The Use Graph Cursors checkbox is checked, but the B cursor is not on the graph."
				checkAxis = 1
			endif
			if (checkAxis == 0)
				RangeBegin= pcsr(A, gname)
				RangeEnd= pcsr(B, gname)
			endif
		else
			checkAxis = 1
		endif
		if (checkAxis)
			GetAxis /Q bottom
			if(!WaveExists(XData))
				RangeBegin= x2pnt(YData,V_min)
				RangeEnd= x2pnt(YData,V_max)
			else
				RangeBegin=BinarySearchClipped(XData,V_min)
				RangeEnd=BinarySearchClipped(XData,V_max)
			endif
		endif
	endif
	RangeReversed= RangeBegin>RangeEnd
	if( RangeReversed )
		variable tmp= RangeBegin
		RangeBegin= RangeEnd
		RangeEnd= tmp
	endif
	RangeBegin = max(0, RangeBegin)
	RangeEnd = min(numpnts(YData)-1, RangeEnd)
	return 0
End

// eliminates peaks smaller than minPeakFraction*(max peak height)
Function MPF2_TrimAmpAutoPeakInfo(wpi, minPeakFraction)
	Wave wpi
	Variable minPeakFraction
	
	Variable numRows = DimSize(wpi,0)
	Variable maxHeight = 0
	Variable minHeight
	
	Variable i
	
	for (i = 0; i < numRows; i += 1)
		maxHeight = max(maxHeight, wpi[i][2])
	endfor
	minHeight= maxHeight*minPeakFraction	// user want peaks to be bigger than this
	
	for (i = numRows-1; i >= 0; i -= 1)		// go backwards so we can delete rows without screwing up the index
		if( wpi[i][2] < minHeight )
			DeletePoints i,1,wpi
			if (DimSize(wpi, 0)==0)   		// If columns dimension disappears problems will occur if peaks are added later
				Redimension /N=(0,5) wpi
			endif
		endif
		i -= 1
	endfor

	return DimSize(wpi,0)
end

static Function MPF2_ClearOutOldWaves(setNumber)
	Variable setNumber

	DFREF saveDFR = GetDataFolderDFR()

	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)

	SVAR gname = DFRpath:GraphName
	
	Variable index
	Variable i=0
	String tlist = TraceNameList(gname, ";", 1 )
	Variable nItems = ItemsInList(tlist)
	for (i = 0; i < nItems; i += 1)
		String tname = StringFromList(i, tlist)
		if (CmpStr(tname[0,5], "'Peak ", 1) == 0)			// looking for traces with names beginning with "Peak ". I control the trace names, so I know that case-sensitive is OK. Reduces the chances of getting the wrong trace from a user's graph.
			RemoveFromGraph/W=$gname/Z $tname
		endif
	endfor
	
	DoUpdate
	
	String wname
	i = 0
	do
		wname = "Peak "+num2str(i)
		Wave/Z w = DFRpath:$wname
		if (!WaveExists(w))
			break
		endif
		KillWaves/Z w
		i += 1
	while(1)
	
	i = 0
	do
		wname = "Peak "+num2str(i)+" Coefs"
		Wave/Z w = DFRpath:$wname
		if (!WaveExists(w))
			break
		endif
		KillWaves/Z w
		i += 1
	while(1)
	
	i = 0
	do
		wname = "Peak "+num2str(i)+" CoefsBackup"
		Wave/Z w = DFRpath:$wname
		if (!WaveExists(w))
			break
		endif
		KillWaves/Z w
		i += 1
	while(1)
	
	i = 0
	do
		wname = "W_sigma_"+num2str(i)
		Wave/Z w = DFRpath:$wname
		if (!WaveExists(w))
			break
		endif
		KillWaves/Z w
		i += 1
	while(1)
end

Function MPF2_AutoLocatePeaksButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable RangeBegin
	Variable RangeEnd
	Variable RangeReversed
	Variable noiseFactor
	
	String saveDF = GetDataFolder(1)

	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	DFREF setDF = $DFpath
	
	SVAR gname = setDF:GraphName
	SVAR YWvName = setDF:YWvName
	SVAR XWvName = setDF:XWvName
	Wave YData = $YWvName
	Wave/Z XData = $XWvName
	
	Wave/T HoldStrings = setDF:HoldStrings
	MPF2_RefreshHoldStrings(gname+"#MultiPeak2Panel")    // ST: 200626 - Update the hold strings, keep baseline settings later
	MPF2_ClearOutOldWaves(setNumber)

	NVAR AutoFindNoiseLevel = setDF:AutoFindNoiseLevel
	NVAR AutoFindSmoothFactor = setDF:AutoFindSmoothFactor
	NVAR AutoFindTrimFraction = setDF:AutoFindTrimFraction

	MPF2_SetDataPointRange(gname, YData, XData, RangeBegin, RangeEnd, RangeReversed)
	NVAR XPointRangeBegin = setDF:XPointRangeBegin
	NVAR XPointRangeEnd = setDF:XPointRangeEnd
	XPointRangeBegin = RangeBegin
	XPointRangeEnd = RangeEnd
	
	Wave/Z wpi = setDF:W_AutoPeakInfo			// If it exists, an autofind was done previously, and the list should be in a finished state. In case the user has selected a baseline function, try to get it so it can be restored.
	Variable doingBaseline = 0
	String BaselineFunc
	Variable baselineIsOpen = 0
	Variable BaselineRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
	if (BaselineRow == 0)				// another test for the list being in a finished state
		String baselineStr = WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, BaselineRow)
		if (CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0)
			doingBaseline = 1
			BaselineFunc = MPF2_PeakOrBLTypeFromListString(baselineStr)
			baselineIsOpen = WMHL_RowIsOpen(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", BaselineRow)
			Wave/Z 'Baseline Coefs' = setDF:'Baseline Coefs'
			if (!WaveExists('Baseline Coefs'))
				FUNCREF MPF2_FuncInfoTemplate BLinfoFunc=$(BaselineFunc+BL_INFO_SUFFIX)
				String ParamNameList = BLinfoFunc(BLFuncInfo_ParamNames)
				Variable nparams = ItemsInList(ParamNameList)
				Wave/Z w = $(DFPath+":"+"'Baseline Coefs'")
				if (!WaveExists(w))
					Make/D/N=(nparams) $(DFPath+":"+"'Baseline Coefs'")
				endif
				DoingBaseline = 1
			endif
		endif
	endif
	
	Variable npks = 0
	if (abs(XPointRangeEnd - XPointRangeBegin) < 21)
		DoAlert 0, "Your data set does not have enough points for the peak auto find algorithm. Please drag a marquee on the graph and select Add or Edit Peaks"
	else
		ControlInfo/W=$s.win MPF2_NegativePeaksCheck
		NVAR negativePeaks = setDF:negativePeaks
		negativePeaks = V_value
		if (negativePeaks)
			Duplicate/O/FREE YData, TempYDataForNegativePeaks
			WAVE w = TempYDataForNegativePeaks
			w = -w
		else
			Wave w = YData
		endif
		// AutoFindPeaks assumes that the current data folder is set to the place where we want the results
		SetDataFolder setDF
		npks = AutoFindPeaks(w, XPointRangeBegin, XPointRangeEnd, AutoFindNoiseLevel, AutoFindSmoothFactor, Inf)		// from PeakAutoFind.ipf
		SetDataFolder saveDF
		Wave wpi = setDF:W_AutoPeakInfo			// may or may not exist
	endif
	if( npks>0 )
		AdjustAutoPeakInfoForX(wpi, YData,  XData)
		npks = TrimAmpAutoPeakInfo(wpi, AutoFindTrimFraction)
		MPF2_SortAutoPeakWave(wpi)
		if (negativePeaks)
			wpi[][2] = -wpi[p][2]
		endif
		CreateCoefWavesFromAutoPeakInfo(setnumber, wpi, "Gauss")
		
		MPF2_PutAutoPeakResultIntoList(setNumber, wpi, 1)

		if (doingBaseline)
			if (CmpStr(BaselineFunc, "None") != 0)
				WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, BaselineRow, BaselineFunc+MENU_ARROW_STRING, 0)
				WMHL_OpenAContainer(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
				if (!baselineIsOpen)
					WMHL_CloseAContainer(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
				endif
			endif
		endif
		
		NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
		MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
		MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
		
		Redimension /N=(npks+1) HoldStrings		// ST: make sure this has the correct size
		HoldStrings[1,] = ""					// ST: 200626 - clear all entires besides the baseline
	endif
	MPF2_EnableDisableDoFitButton(setNumber)
End

Function MPF2_AutoLocateFromResidualsButtonProc(s) : ButtonControl		// ST: take residuals to locate additional peaks
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	DFREF setDF = $MPF2_FolderPathFromSetNumber(setNumber)
	
	String saveDF = GetDataFolder(1)

	SVAR gname = setDF:GraphName
	SVAR YWvName = setDF:YWvName
	SVAR XWvName = setDF:XWvName
	
	Wave YData = $YWvName
	Wave/Z XData = $XWvName
	Wave/Z rw = setDF:$(CleanUpName("Res_"+NameOfWave(YData), 1)) 
	
	Wave/Z wpi = setDF:W_AutoPeakInfo
	if (!WaveExists(wpi) || !WaveExists(rw))
		DoAlert 0, "Locating peaks in residuals is only useful if a fit has been done. Use the Auto-locate Peaks Now button to find peaks in the data instead."
		return 0
	endif
	
	Make/Free/N=0 OpenState								// ST: 200817 - preserve open state of all peak entries
	Variable i = 0
	do
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
		if (theRow < 0)
			break;
		endif
		OpenState[DimSize(OpenState,0)] = {WMHL_RowIsOpen(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", theRow)}
		i += 1
	while (1)
	Redimension/N=(DimSize(wpi, 0)) OpenState 			// ST: 200817 - make sure this is the same size as wpi

	NVAR AutoFindNoiseLevel = setDF:AutoFindNoiseLevel
	NVAR AutoFindSmoothFactor = setDF:AutoFindSmoothFactor
	NVAR AutoFindTrimFraction = setDF:AutoFindTrimFraction
	NVAR XPointRangeBegin = setDF:XPointRangeBegin
	NVAR XPointRangeEnd = setDF:XPointRangeEnd
	
	Variable RangeBegin, RangeEnd, RangeReversed, noiseFactor
	MPF2_SetDataPointRange(gname, YData, XData, RangeBegin, RangeEnd, RangeReversed)
	XPointRangeBegin = RangeBegin
	XPointRangeEnd = RangeEnd
	if (abs(XPointRangeEnd - XPointRangeBegin) < 21)
		DoAlert 0, "Your data set does not have enough points for the peak auto find algorithm. Please drag a marquee on the graph and select Add or Edit Peaks"
		return 0
	endif
	
	ControlInfo/W=$s.win MPF2_NegativePeaksCheck
	NVAR negativePeaks = setDF:negativePeaks
	negativePeaks = V_value
	if (negativePeaks)
		Duplicate/O/FREE rw, TempYDataForNegativePeaks	// use the residuals here
		WAVE w = TempYDataForNegativePeaks
		w = -w
	else
		Wave w = rw
	endif
	
	NewDataFolder/O/S setDF:TempAutoFindInResiduals		//	create a separate folder to not destroy the original auto-locate wave (will be merged later on)
		Variable new_npks = AutoFindPeaks(w, XPointRangeBegin, XPointRangeEnd, AutoFindNoiseLevel, AutoFindSmoothFactor, Inf)		// from PeakAutoFind.ipf
		Wave wpi_temp = W_AutoPeakInfo
		Duplicate/free wpi_temp, res_wpi				// create a transient copy
	SetDataFolder setDF
	KillDataFolder TempAutoFindInResiduals
	SetDataFolder saveDF
	
	if( new_npks>0 )
		AdjustAutoPeakInfoForX(res_wpi, YData,  XData)
		if (negativePeaks)
			res_wpi[][2] = -res_wpi[p][2]
		endif
		new_npks = TrimAmpAutoPeakInfo(res_wpi, AutoFindTrimFraction)
		
		// ##### a panel to ask if the peaks really should get added
		String PeaksFoundText = num2str(new_npks)+" Peaks were found"
		if ( new_npks == 1 )
			PeaksFoundText = "1 Peak was found"
		endif
		PeaksFoundText += " (red lines). Do you want to add the peaks?\r\rPress No to abort and adjust the settings to get a different result.\r\r"
		
		SetDrawEnv/W=$gname  gstart,gname = ShowFoundResPeaks
		for (i = 0; i < new_npks; i += 1)
			SetDrawEnv/W=$gname ycoord = prel, xcoord = bottom,linefgc = (65535,0,0)
			DrawLine/W=$gname res_wpi[i][0],0,res_wpi[i][0],1
		endfor
		SetDrawEnv/W=$gname gstop
		DoUpdate/W=$gname
		
		DoAlert 1, PeaksFoundText
		if (V_Flag == 2)
			DrawAction/W=$gname getgroup = ShowFoundResPeaks, delete
			return 0
		else
			DrawAction/W=$gname getgroup = ShowFoundResPeaks, delete
		endif
	
		// ##### actually add the peaks from here on
		
		SetDataFolder setDF
			MPF2_SaveFunctionTypes(gname+"#MultiPeak2Panel")			// ST: 200626 - always save function types (may have changed in-between)
			SVAR SavedFunctionTypes = setDF:SavedFunctionTypes
			
			Variable old_npks = DimSize(wpi,0)
			Duplicate/free wpi, wpi_temp
			Concatenate/NP=0/O {wpi_temp,res_wpi}, W_AutoPeakInfo
			Variable all_npks = DimSize(wpi,0)
			
			NewDataFolder/O/S EditDuplicateCoefWaves
			KillWaves/Z/A
			for (i = 0; i < old_npks; i += 1)
				String wvname = "Peak "+num2str(i)+" Coefs"
				Duplicate/O $("::"+PossiblyQuoteName(wvname)), $wvname
			endfor
			SetDataFolder setDF
			
			Make/FREE/N=(all_npks,2) changedPeaks = p
			changedPeaks[][1] = p > old_npks - 1 ? 1 : 0
			
			Wave/T constraintsTextWave = setDF:constraintsTextWave
			MPF2_RefreshConstraintStrings(setNumber)
			for (i = 0; i < new_npks; i += 1)
				insertPeakConstraints(setNumber, old_npks+i+1)
				SavedFunctionTypes += "Gauss;"
			endfor
			
			Wave/T HoldStrings = setDF:HoldStrings
			MPF2_RefreshHoldStrings(gname+"#MultiPeak2Panel")    	// Update the hold strings
			Redimension /N=(all_npks+1) HoldStrings
			
			String listoftypes = SavedFunctionTypes
			String indexWaveName = MPF2_SortAutoPeakWave(wpi, listOfTypes=listoftypes, holdwave=HoldStrings, constraintswave=constraintsTextWave, killIndexWave = 0) 
			Wave indexWave = $indexWaveName
			SavedFunctionTypes = listoftypes
		
		SetDataFolder saveDF
		
		DFREF dupDFR = setDF:EditDuplicateCoefWaves
		for (i = 0; i < all_npks; i += 1)
			if (changedPeaks[indexWave[i]][1])
				MPF2_CoefWaveForPeak(setNumber, wpi, i, StringFromList(i+1,SavedFunctionTypes))		// i+1: the first of SavedFunctionTypes is for the baseline
			else
				WAVE oldwave = dupDFR:$"Peak "+num2str(changedPeaks[indexWave[i]][0])+" Coefs"
				String newWaveName = MPF2_FolderPathFromSetNumber(setNumber)+":'Peak "+num2str(i)+" Coefs'"
				Duplicate/O oldwave,  $newWaveName
			endif
		endfor
		KillDataFolder/Z dupDFR										// clean up copy
		
		MPF2_RemoveAllPeaksFromGraph(gname)
		MPF2_PutAutoPeakResultIntoList(setNumber, wpi, 0, listOfPeakTypes=SavedFunctionTypes)
		
		if (DimSize(OpenState,0) > 0 && DimSize(indexWave,0) > 0)	// ST: 200817 - reopen all previously opened containers
			ReDimension/N=(DimSize(indexWave,0)) OpenState
			for (i = 0; i < DimSize(OpenState, 0); i += 1)
				if (OpenState[indexWave[i]] == 1)					// ST: assumes that all containers have been rebuilt by MPF2_PutAutoPeakResultIntoList()
					WMHL_OpenAContainer(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
				endif
			endfor
		endif
		
		NVAR displayPeaksFullWidth = setDF:displayPeaksFullWidth
		MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
		MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
		
		String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
		String ListOfCWaveNames = "Baseline Coefs;"					// ST: the number of peaks has changed => backup coef waves
		for (i = 0; i < DimSize(wpi, 0); i += 1)
			ListOfCWaveNames += "Peak "+num2istr(i)+" Coefs;"
		endfor
		MPF2_BackupCoefWaves(ListOfCWaveNames, DFpath)
	else
		DoAlert 0,"No new peaks found. Try to adjust the settings."
	endif
	
	MPF2_EnableDisableDoFitButton(setNumber)
End

// will get the setnumber from a window name of the form "graphname" or "GraphName#MultiPeak2Panel" or any sub-panel of GraphName#MultiPeak2Panel.
// Depends on UserData named "MPF2_DataSetNumber" stored in both the graph window and the main exterior panel window.
Static Function GetSetNumberFromWinName(windowName)
	String windowName
	
	String windowWithData
	
	Variable poundPos = strsearch(windowName, "#", 0)
	if (poundPos < 0)
		windowWithData = windowName
	else
		poundPos = strsearch(windowName, "#", poundPos+1)
		if (poundPos < 0)
			windowWithData = windowName
		else
			windowWithData = windowName[0,poundPos-1]
		endif
	endif
	
	Variable setnum = str2num(GetUserData(windowWithData, "", "MPF2_DataSetNumber"))
	if (numtype(setnum) != 0)
		// JW 190409 This handles a window name that has underscore before a number, such as
		// the Additional Constraints panel: MPF2_AdditionalConstraints_4
		String basename = StringFromList(0, windowName, "#")
		setnum = str2num(GetUserData(basename, "", "MPF2_DataSetNumber"))
	endif
	return setnum
end

Function/S ListExistingSets()

	DFREF MPF_DFR = root:Packages:MultiPeakFit2:
	
	String theList = ""
	Variable numFolders = CountObjectsDFR(MPF_DFR, 4)
	Variable i
	for (i = 0; i < numFolders; i += 1)
		String oneFolder = GetIndexedObjNameDFR(MPF_DFR, 4, i)
		Variable nameLen = strlen(oneFolder)
		if (nameLen > 14)
			if (CmpStr(oneFolder[0,13], "MPF_SetFolder_") == 0 && StringMatch(oneFolder, "*CP*") == 0)		// ST: exclude checkpoint folders
				theList += oneFolder[14,nameLen-1]+";"
			endif
		endif
	endfor
	theList = SortList(theList, ";", 2)		// ST: sort the numbers
	return theList
end

Function/S MPF2_ListExistingSetsForResume()

	String existingSets = ListExistingSets()
	if (strlen(existingSets) == 0)
		existingSets = "\\M1(No set started yet"	// ST: changed message when there are no sets for the new merged panel
	endif
	
	return existingSets
end

Function/S InitializeMPF2FromMenuString()

	String theList = "Start Fresh;"
	ControlInfo/W=$GetStartPanelName(tab=0) MPF2_ChooseGraph
	if (CmpStr(S_value, "New Graph") != 0)
		String graphSetNumberStr = GetUserData(S_value, "", "MPF2_DataSetNumber" )
		if (strlen(graphSetNumberStr) > 0)
			theList += "Previous Set for This Graph;"
		else
			theList += "\\M1(Previous Set for This Graph;"
		endif
	else
			theList += "\\M1(Previous Set for This Graph;"
	endif
	
	String SetList = ListExistingSets()
	Variable i
	Variable nSets = ItemsInList(SetList)
	for (i = 0; i < nSets; i += 1)
		theList += "Set Number "+StringFromList(i, SetList)+";"
	endfor

	return theList
end

Function MPF2_GetExternalPanelPosition(gname)
	String gname
	
	String recMacro = winRecreation(gname, 0)
	Variable asPos = strsearch(recMacro, "as \"Multipeak Fit Set", 0)
	Variable beginPos = strsearch(recMacro, "/EXT=", asPos, 1)		// search backwards
	Variable extPosCode
	sscanf recMacro[beginPos, beginPos+10], "/EXT=%d", extPosCode
	
	return extPosCode
end

Function MPF2_RemoveMPTracesFromGraph(gname)
	String gname
	
	String setNumberStr = GetUserData(gname, "", "MPF2_DataSetNumber")
	if (strlen(setNumberStr) == 0)
		return 0
	endif
	Variable setNumber = str2num(setNumberStr)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	SVAR YWvName = $(DFpath+":YWvName")
	Wave yw = $YWvName
	// NH DEV NOTE: need to remove "fitx_"
	RemoveFromGraph/W=$gname/Z $("fit_"+NameOfWave(yw))
	RemoveFromGraph/W=$gname/Z $("fitx_"+NameOfWave(yw))
	RemoveFromGraph/W=$gname/Z $("res_"+NameOfWave(yw))
	RemoveFromGraph/W=$gname/Z $("Bkg_"+NameOfWave(yw))
	DoUpdate
	
	String tlist = TraceNameList(gname, ";", 1)
	Variable ntraces = ItemsInList(tlist)
	Variable i
	for (i = 0; i < ntraces; i += 1)
		String oneTrace = StringFromList(i, tlist)
		Wave w = TraceNameToWaveRef(gname, oneTrace)
		String wdf = RemoveEnding(GetWavesDataFolder(w, 1), ":")
		if (CmpStr(wdf, DFPath) == 0)
			RemoveFromGraph/W=$gname $oneTrace
		endif
	endfor
end

Function MPF2_CheckpointMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	SVAR YWvName = $(DFpath+":YWvName")
	Wave yw = $YWvName
	SVAR XWvName = $(DFpath+":XWvName")
	Wave/Z xw = $XWvName
	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	SVAR gname = $(DFpath+":GraphName")
	String panelName = gname+"#MultiPeak2Panel"
	String listPanelName = panelName+"#P1"
	
	Variable i
	
	strswitch (s.popStr)
		case "Save Checkpoint":
			MPF2_RefreshHoldStrings(panelName)
			MPF2_SaveFunctionTypes(panelName)
			Variable/G $(DFPath+":MPF2_UserCursors")
			NVAR useCursors = $(DFPath+":MPF2_UserCursors")
			useCursors = MPF2_UseCursorsIsChecked(gname)

			if (DataFolderExists(DFpath+"CP"))
				KillDataFolder/Z $(DFpath+"CP")
			endif
			DuplicateDataFolder $DFpath, $(DFpath+"CP")
			
			PopupMenu MPF2_CheckPointMenu,win=$s.win, title="\JCCheckpoint Saved", value= #"\"Save Checkpoint;Restore Checkpoint;\""		// ST: indicate that a checkpoint is available
			break;
		case "Restore Checkpoint":
			if (DataFolderExists(DFpath+"CP"))
				DoAlert 1, "The present panel and its information will be killed and restored with the saved data. Proceed?"
				if (V_flag == 1)
					Variable panelPosition = MPF2_GetExternalPanelPosition(gname)
					KillWindow $panelName
					KillWindow/Z $("MPF2_ResultsPanel"+"_"+num2str(setNumber))			// ST 2.47: kills results panel if still open, as it will break upon restore
					MPF2_RemoveMPTracesFromGraph(gname)
					String graphname = gname			// save the graph name before the global variable stored in the datafolder is killed.
					KillDataFolder/Z $DFpath
					DuplicateDataFolder $(DFpath+"CP"), $DFpath
					SVAR YWvName = $(DFpath+":YWvName")
					SVAR XWvName = $(DFpath+":XWvName")
					
					// "2" is to use previous set for this graph
					MPF2_StartNewMPFit(panelPosition, graphname, YWvName, XWvName, 2, 0)
				endif
			else
				DoAlert 0, "There is no checkpoint data available."
			endif
			break;
	endswitch
end

Function MPF2_SetAllPeakTypesMenuProc(s) : PopupMenuControl
	STRUCT WMPopupAction &s
	
	if (s.eventCode != 2)
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	SVAR YWvName = $(DFpath+":YWvName")
	Wave yw = $YWvName
	SVAR XWvName = $(DFpath+":XWvName")
	Wave/Z xw = $XWvName
	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	SVAR gname = $(DFpath+":GraphName")
	String panelName = gname+"#MultiPeak2Panel"
	String listPanelName = panelName+"#P1"
	
	Variable i=1			// don't do anything to the baseline row
	do
		if (strlen(WMHL_GetItemForRowNumber(listPanelName, "MPF2_PeakList", i)) == 0)
			break;
		endif
		
		if (WMHL_RowIsContainer(listPanelName, "MPF2_PeakList", i))
			String prevFunc = WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, i)
			prevFunc = RemoveEnding(prevFunc, MENU_ARROW_STRING)	
		
			WMHL_ExtraColumnData(listPanelName, "MPF2_PeakList", 0, i, s.popStr+MENU_ARROW_STRING, 0)
			MPF2_CoefWaveForListRow(setNumber, i, s.popStr)
			
		      String theItem=""
			if (WMHL_RowIsOpen(listPanelName, "MPF2_PeakList", i))
				theItem = WMHL_GetItemForRowNumber(listPanelName, "MPF2_PeakList", i)
				WMHL_CloseAContainer(listPanelName, "MPF2_PeakList", theItem)	// info for this row has changed. Opening the row re-evaluates the info
			endif
			
			//NH: If the type has changed then the hold and constraint strings should be reset.  
			if (CmpStr(prevFunc, s.popStr))
				String currPeakName = WMHL_GetItemForRowNumber(listPanelName, "MPF2_PeakList", i)
			 	Variable peakNumber
			 	sscanf currPeakName, "Peak %d", peakNumber
			
				Wave/T HoldStrings = $(DFpath+":HoldStrings")
				HoldStrings[peakNumber+1] = ""
				resetPeakConstraints(setNumber, peakNumber+1)
			endif
			
			//NH: needed to put this after the close so that clearing out Hold and Constraint data (if necessary) sticks
			if (strlen(theItem)) // if this was set, then the container was open earlier
				WMHL_OpenAContainer(listPanelName, "MPF2_PeakList", theItem)
			endif
		endif
		i += 1
	while (1)
	NVAR negativePeaks = $(DFpath+":negativePeaks")
	NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
	MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
	MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
	MPF2_EnableDisableDoFitButton(setNumber)
End

// Sorts the master coefficient estimate wave (usually from the AutoFindPeaks function). Sorts by X location value.
// If the caller includes a listOfTypes, the list is sorted along with the coefficients estimage wave.
Static Function/S MPF2_SortAutoPeakWave(wpi [, listOfTypes, holdwave, constraintswave, killIndexWave])
	Wave wpi
	String &listOfTypes
	Wave/Z/T holdwave
	Wave/Z/T constraintswave
	Variable killIndexWave
	
	if (ParamIsDefault(killIndexWave))
		killIndexWave = 1
	endif

	Variable i
	
	String indexWaveName = MPF2_MakeIndexAutoPeakWave(wpi)
	Wave MPF2_indexwave = $indexWaveName
	
	Duplicate/O wpi, MPF2_TempWave
	if (DimSize(wpi,0))  // without this the following line crashes if there are no peaks 
		wpi = MPF2_TempWave[MPF2_indexwave[p]][q]
	endif
//DoUpdate	
	Variable tempIndex
	if (!ParamIsDefault(holdwave))
		if (numpnts(holdwave) > 1)
			Duplicate/O/T holdwave, MPF2_TempHoldWave
			holdwave = ""
			holdwave[0] = MPF2_TempHoldWave[0]			// ST: 210813 - make sure to save the baseline hold string
			for (i = 1; i <= numpnts(MPF2_indexwave); i += 1)			
				tempIndex = MPF2_indexwave[i-1]+1
				if (tempIndex < numpnts(MPF2_TempHoldWave) && i < numpnts(holdwave))
					holdwave[i] = MPF2_TempHoldWave[tempIndex]
				endif
			endfor
			KillWaves MPF2_TempHoldWave
		endif
	endif
	
	if (!ParamIsDefault(constraintswave))
		if (numpnts(constraintswave) > 1)
			Duplicate/O/T constraintswave, MPF2_TempConstraintsWave
			constraintswave = ""
			for (i = 1; i <= numpnts(MPF2_indexwave); i += 1)     
				tempIndex = MPF2_indexwave[i-1]+1
				if (tempIndex < numpnts(MPF2_TempConstraintsWave) && i<numpnts(constraintswave))
					constraintswave[i] = MPF2_TempConstraintsWave[tempIndex]
				endif
			endfor
			KillWaves MPF2_TempConstraintsWave
		endif
	endif
	
//DoUpdate	
	if (!ParamIsDefault(listOfTypes))
		Variable nPeaks = DimSize(wpi, 0)
		String newList = StringFromList(0, listOfTypes)+";"		// copy the baseline function type
		for (i = 0; i < nPeaks; i += 1)
			newList += StringFromList(MPF2_indexwave[i]+1, listOfTypes)+";"
		endfor
		listOfTypes = newList
	endif
	
	if (killIndexWave)
		KillWaves MPF2_indexwave
		indexWaveName = ""
	endif
	KillWaves MPF2_TempWave
	
	return indexWaveName
end

// Sorts the master coefficient estimate wave (usually from the AutoFindPeaks function). Sorts by X location value.
// If the caller includes a listOfTypes, the list is sorted along with the coefficients estimage wave.
Static Function/S MPF2_MakeIndexAutoPeakWave(wpi)
	Wave wpi
	
	Make/D/N=(DimSize(wpi, 0))/O MPF2_sortwave, MPF2_indexwave
	MPF2_sortwave = wpi[p][0]
	MakeIndex MPF2_sortwave, MPF2_indexwave
	KillWaves MPF2_sortwave
	
	return GetWavesDataFolder(MPF2_indexwave, 2)
end

Static Function CreateCoefWavesFromAutoPeakInfo(setNumber, AutoPeakInfo, peakTypeName)
	Variable setNumber
	Wave AutoPeakInfo
	String peakTypeName
	
//	NVAR currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	DFREF saveDFR = GetDataFolderDFR()
	SetDataFolder DFRPath
	
	CreateCWavesInCDFFromAutoPkInfo(AutoPeakInfo, peakTypeName, "Peak %d Coefs")
	
	SetDataFolder saveDFR
end

Static Function CreateCWavesInCDFFromAutoPkInfo(AutoPeakInfo, peakTypeNames, coefWaveNameFormat)
	Wave AutoPeakInfo
	String peakTypeNames
	String coefWaveNameFormat
	
	Variable npeaks = DimSize(AutoPeakInfo, 0)
	Variable ntypes = itemsInList(peakTypeNames)
	
	// FUNCREF MPF2_FuncInfoTemplate infoFunc=$(peakTypeName+PEAK_INFO_SUFFIX)
	// Variable nparams
	// String GaussGuessConversionFuncName = infoFunc(PeakFuncInfo_GaussConvFName)
	// if (strlen(GaussGuessConversionFuncName) == 0)
	// else
		// FUNCREF MPF2_GaussGuessConvTemplate gconvFunc=$GaussGuessConversionFuncName
	// endif
	
	String newWName
	Variable i
	for (i = 0; i < npeaks; i += 1)
		if (i >= ntypes)							// ST: 200909 - add support for peakType lists
			FUNCREF MPF2_FuncInfoTemplate infoFunc=$(StringFromList(0,peakTypeNames)+PEAK_INFO_SUFFIX)
		else
			FUNCREF MPF2_FuncInfoTemplate infoFunc=$(StringFromList(i,peakTypeNames)+PEAK_INFO_SUFFIX)
		endif
		String GaussGuessConversionFuncName = infoFunc(PeakFuncInfo_GaussConvFName)
		if (strlen(GaussGuessConversionFuncName) == 0)
			FUNCREF MPF2_GaussGuessConvTemplate gconvFunc=$"MPF2_GaussGuessConvTemplate"
		else
			FUNCREF MPF2_GaussGuessConvTemplate gconvFunc=$GaussGuessConversionFuncName
		endif
	
		sprintf newWName, coefWaveNameFormat, i
		Make/D/O/N=(DimSize(AutoPeakInfo, 1)) $newWName
		Wave w = $newWName
		w = AutoPeakInfo[i][p]
		gconvFunc(w)
	endfor
end

Static Function MPF2_CoefWaveForPeak(setNumber, AutoPeakInfo, peakNumber, peakTypeName)
	Variable setNumber
	Wave AutoPeakInfo
	Variable peakNumber
	String peakTypeName
	
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	
	FUNCREF MPF2_FuncInfoTemplate infoFunc=$(peakTypeName+PEAK_INFO_SUFFIX)
	Variable nparams
	String GaussGuessConversionFuncName = infoFunc(PeakFuncInfo_GaussConvFName)
	if (strlen(GaussGuessConversionFuncName) == 0)
	else
		FUNCREF MPF2_GaussGuessConvTemplate gconvFunc=$GaussGuessConversionFuncName
	endif
	
	String newWName = "Peak "+num2str(peakNumber)+" Coefs"
	Make/D/O/N=(DimSize(AutoPeakInfo, 1)) DFRPath:$newWName
	Wave w = DFRPath:$newWName
	w = AutoPeakInfo[peakNumber][p]
	// ST: support for asymmetric peaks has been added, so below fix is not needed anymore
	// Manually editing or dragging out a peak doesn't have a provision for assymetry; the left and right widths are zero. That
	// screws up the ExpModGauss function guess generator, so here we will simply copy them from the width in column 1
	//w[3] = w[1]/2
	//w[4] = w[1]/2
	gconvFunc(w)
end

Static Function BinarySearchClipped(w,x)
	WAVE w
	Variable x
	
	Variable p= BinarySearch(w,x)
	if( p == -2 )
		p= numpnts(w)-1
	elseif( p == -1 )
		p= 0
	endif
	
	return p
End

Static Function MPF2_PutAutoPeakResultIntoList(setNumber, autoPeakInfo, initializeBaseline [, listOfPeakTypes])
	Variable setNumber
	Wave/Z autoPeakInfo
	Variable initializeBaseline
	String listOfPeakTypes
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname = $(DFpath+":GraphName")
	SVAR YWvName = $(DFpath+":YWvName")
	SVAR XWvName = $(DFpath+":XWvName")
	Wave YData = $YWvName
	Wave/Z XData = $XWvName
	
	Variable i, theRow
	if (!WaveExists(autoPeakInfo) || (DimSize(autoPeakInfo, 0) == 0))
		// If there's any peaks in the listbox get rid of them
		if (!initializeBaseline)
			i = 0
			do
				theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
				if (theRow < 0)
					break;
				endif
				WMHL_DeleteRowAndChildren(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", theRow)
				i += 1
			while (1)
		endif
		
		return 0
	endif
	
	Variable nPeaks = DimSize(	autoPeakInfo, 0)
	Variable currentRow = 0
	Variable reOpenBaseline = 0
	
	if (initializeBaseline)
		// Start from scratch
		ControlInfo/W=$gname#MultiPeak2Panel#P1 MPF2_PeakList
		Variable listHeight = V_height
		Variable listWidth = V_width
		Variable listTop = V_top
		Variable listLeft = V_left
		
		Variable BaselineRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
		String baselineStr
		if (BaselineRow == 0)
			baselineStr = WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, BaselineRow)
		else
			baselineStr = "Constant"+MENU_ARROW_STRING
		endif

		ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,userdata(MPF2_DataSetNumber)=num2str(setnumber)
		MakeListIntoHierarchicalList(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "PeakListOpenNotify", selectionMode=WMHL_SelectionContinguous, userListProc="MPF2_PeakListProc")
		WMHL_SetNotificationProc(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "PeakListClosingNotify", WMHL_SetClosingNotificationProc)
		WMHL_AddColumns(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 6)
		
		WMHL_AddObject(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "", "Baseline", 1)
		WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, currentRow, baselineStr, 0)
		currentRow += 1
	else
		// preserve the baseline info. Just delete all the peaks and add them back again.
		reOpenBaseline = WMHL_RowIsOpen(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0)
		WMHL_CloseAContainer(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
		i = 0
		do
			theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
			if (theRow < 0)
				break;
			endif
			WMHL_DeleteRowAndChildren(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", theRow)
			i += 1
		while (1)
		currentRow = 1
	endif
	
	String peakTypeName = "Gauss"
	for (i = 0; i < npeaks; i += 1)
		WMHL_AddObject(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "", "Peak "+num2str(i), 1)
		if (!ParamIsDefault(listOfPeakTypes))
			peakTypeName = StringFromList(i+1, listOfPeakTypes)		// i+1 because the first is the baseline type
		endif
		WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, currentRow, peakTypeName+MENU_ARROW_STRING, 0)
		currentRow += 1
	endfor
	
	ControlInfo/W=gname#MultiPeak2Panel#P1 MPF2_PeakList
	
	Variable updateRejected = NumVarOrDefault("root:Packages:MultiPeakFit2:updateRejected", 0)
	if (!updateRejected)
		NVAR MPF2ConstraintsShowing = $(DFPath+":MPF2ConstraintsShowing")
		if (MPF2ConstraintsShowing)
			ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={16,70,110,50,30,35,30,35}
		else 
			ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={20,85,130,55,0,0,0,0}
		endif
	else	
		ListBox MPF2_PeakList win=$gname#MultiPeak2Panel#P1,widths={4,15,16,10}
	endif
	
	if (reOpenBaseline)
		WMHL_OpenAContainer(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
	endif
end

Function/S MPF2_FuncInfoTemplate(InfoDesired)
	Variable InfoDesired
	
	return ""		// so we can tell when the template ran by mistake
end

Function MPF2_GaussGuessConvTemplate(w)
	Wave w
	
	return -1
end

Function MPF2_PeakFunctionTemplate(w, yw, xw)
	Wave w
	Wave yw, xw
	
end

Function MPF2_BaselineFunctionTemplate(s)
	STRUCT MPF2_BLFitStruct &s
	
	return -1
end

Function/S MPF2_PeakOrBLTypeFromListString(listString)
	String listString
	
	Variable pos = strsearch(listString, MENU_ARROW_STRING, 0)
	return listString[0,pos-1]
end

Function PeakListOpenNotify(HostWindow, ListControlName, ContainerPath)
	String HostWindow, ListControlName, ContainerPath
	
	Variable setNumber = str2num(GetUserData(HostWindow, ListControlName, "MPF2_DataSetNumber"))
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	Variable theRow = WMHL_GetRowNumberForItem(HostWindow, ListControlName, ContainerPath)
	String PeakType = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(HostWindow, ListControlName, 0, theRow) )
	
	String ParamNameList, GaussGuessConversionFuncName, PeakFuncName
	Variable nparams
	
	Variable DoingBaseline = 0
	if (CmpStr(ContainerPath, "Baseline") == 0)
		FUNCREF MPF2_FuncInfoTemplate BLinfoFunc=$(PeakType+BL_INFO_SUFFIX)			// Get the fit function
		ParamNameList = BLinfoFunc(BLFuncInfo_ParamNames)							// fit function parameter names
		nparams = ItemsInList(ParamNameList)										// number of params in the fit function
		Wave/Z w = $(DFPath+":"+"'Baseline Coefs'")
		if (!WaveExists(w))
			Make/D/N=(nparams) $(DFPath+":"+"'Baseline Coefs'")
		endif
		DoingBaseline = 1
	else
		FUNCREF MPF2_FuncInfoTemplate PKinfoFunc=$(PeakType+PEAK_INFO_SUFFIX) 		// Get the fit function
		ParamNameList = PKinfoFunc(PeakFuncInfo_ParamNames)							// fit function parameter names
		nparams = ItemsInList(ParamNameList)										// number of params in the fit function
	endif

	String wavePath = DFPath+":"+PossiblyQuoteName(ParseFilePath(0, ContainerPath, ":", 1, 0)+" Coefs")
	Wave w = $wavePath
	Variable i
	Variable nrows = DimSize(w, 0)
	
	Wave/Z/T HoldStrings = $(DFPath+":HoldStrings")
	Variable HoldStringsRow
	Variable PeakNumber
	sscanf ContainerPath, "Peak %d", PeakNumber
	HoldStringsRow = DoingBaseline ? 0 : PeakNumber+1
	
	NVAR MPF2_CoefListPrecision = $(DFPath+":MPF2_CoefListPrecision")
	for (i = 0; i < nrows; i += 1)
		WMHL_AddObject(HostWindow, ListControlName, ContainerPath, StringFromList(i, ParamNameList), 0)
		String rowText
		sprintf rowText, "%.*g", MPF2_CoefListPrecision, w[i]
		WMHL_ExtraColumnData(HostWindow, ListControlName, 0, theRow+i+1, rowText, 1)
		Variable selwaveValue = 0x20
		Variable haveHoldString= WaveExists(HoldStrings) && (HoldStringsRow < DimSize(HoldStrings,0)) && (StrLen(HoldStrings[HoldStringsRow]) > 0)
		if (haveHoldString)    // JP100622
			String holdString = HoldStrings[HoldStringsRow]
			if (char2num(holdString[i]) == char2num("1"))
				selwaveValue = 0x10+0x20
			endif
		endif
		WMHL_ExtraColumnData(HostWindow, ListControlName, 1, theRow+i+1, "Hold", 0, setSelWaveValue=selwaveValue)
		
		////////// Constraint information
		Variable waveConstraintIndx = DoingBaseline ? 0 : PeakNumber+1
		WMHL_ExtraColumnData(HostWindow, ListControlName, 2, theRow+i+1, "Min:", 0)
		WMHL_ExtraColumnData(HostWindow, ListControlName, 3, theRow+i+1, getPeakConstraints(setNumber, waveConstraintIndx, i, "Min"), 1)	
		WMHL_ExtraColumnData(HostWindow, ListControlName, 4, theRow+i+1, "Max:", 0)
		WMHL_ExtraColumnData(HostWindow, ListControlName, 5, theRow+i+1, getPeakConstraints(setNumber, waveConstraintIndx, i, "Max"), 1)			
  	endfor
end

// When a peak container row closes we have to save the info from Hold checkboxes.
Function PeakListClosingNotify(HostWindow, ListControlName, ContainerPath, ContainerParentPath, FirstChildRow, LastChildRow)
	String HostWindow, ListControlName, ContainerPath, ContainerParentPath
	Variable FirstChildRow, LastChildRow
	
	Variable setNumber = str2num(GetUserData(HostWindow, ListControlName, "MPF2_DataSetNumber"))
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)

	Wave/Z/T HoldStrings = DFRpath:HoldStrings
	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	
	Variable npeaks=0
	if (WaveExists(wpi))
		npeaks = DimSize(wpi, 0)
	endif
	
	Variable DoingBaseline = (CmpStr(ContainerPath, "Baseline") == 0)

	Variable i
	Variable peakNumber
	sscanf ContainerPath, "Peak %d", peakNumber
	Variable HoldStringsRow = DoingBaseline ? 0 : peakNumber+1
	if (NumType(HoldStringsRow))
		return 0
	endif
	
	String theHolds = ""
	for (i = FirstChildRow; i <= LastChildRow; i += 1)
		Variable isChecked = (WMHL_GetExtraColumnSelValue(HostWindow, ListControlName, 1, i) & 0x10) != 0
		if (isChecked)
			theHolds += "1"
		else
			theHolds += "0"
		endif
		
		////////// Constraints ///////////
		Variable peakWaveIndx
		if (DoingBaseline)
			peakWaveIndx = 0
		else
			peakWaveIndx = peakNumber+1
		endif
		String aVal
		aVal = WMHL_GetExtraColumnData(HostWindow, ListControlName, 3, i)
		setPeakConstraints(setNumber, peakWaveIndx, i-FirstChildRow, minVal=str2num(aVal))
		aVal = WMHL_GetExtraColumnData(HostWindow, ListControlName, 5, i)
		setPeakConstraints(setNumber, peakWaveIndx, i-FirstChildRow, maxVal=str2num(aVal))
	endfor
	
	Variable rowsNeeded= max(npeaks+1,HoldStringsRow+1) 	// JP100622
	if (!WaveExists(HoldStrings) )
		Make/T/N=(rowsNeeded) DFRpath:HoldStrings
		WAVE/T HoldStrings = DFRpath:HoldStrings
	elseif (DimSize(HoldStrings,0) < rowsNeeded)
		Redimension/N=(rowsNeeded,-1,-1,-1) HoldStrings
	endif
	HoldStrings[HoldStringsRow] = theHolds					// +1 to account for the baseline hold row
	
	return 0
end

Function MPF2_RemoveAllPeaksFromGraph(gname)
	String gname

	Variable setNumber = GetSetNumberFromWinName(gname)
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	
	Variable nPeaks// = DimSize(wpi, 0)
	Variable i
	
	// NH: removing peaks by wave name rather than by wpi size.  Cases exist where size of  wpi != number of traces
	//       Also possible to have cases where the peak name's number portion is greater than the number of current peaks, 
	//       which also will not get deleted with the original logic 

	String allTraces = TraceNameList(gname, ";", 1)
	nPeaks =  ItemsInList(allTraces)
	for (i=0; i<nPeaks; i+=1)
		String PeakWaveName = StringFromList(i, allTraces)
		Wave w = TraceNameToWaveRef(gname, PeakWaveName)
		
		if (waveExists(w) && !CmpStr("Peaks_Left", AxisForTrace(gname, PeakWaveName, 0, 1)))
			CheckDisplayed /W=$gname w  
			if (V_flag != 0)
				RemoveFromGraph/W=$gname $PeakWaveName
			endif
		endif
	endfor
end

Function MPF2_DeletePeakInfo(setNumber, peakNumber)
	Variable setNumber, peakNumber
	
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)

	Wave wpi = DFRPath:W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	SVAR gname = DFRPath:GraphName

	if (peakNumber >= npeaks)
		return -1
	endif
	
	DeletePoints peakNumber, 1, wpi
	if (DimSize(wpi, 0)==0)    // If columns dimension disappears problems will occur if peaks are added later
		Redimension /N=(0,5) wpi
	endif
	
	Wave/T HoldStrings = DFRPath:HoldStrings
	DeletePoints peakNumber+1, 1, HoldStrings 
	removePeakConstraints(setNumber, peakNumber+1)     //NH
	Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(peakNumber))
	WMHL_DeleteRowAndChildren(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", theRow)
	Wave peak = DFRPath:$("Peak "+num2istr(peakNumber))						// ST: remove the peak waves as well
	Wave coefs = DFRPath:$("Peak "+num2istr(peakNumber)+" Coefs")
	KillWaves/Z peak, coefs													// ST: 200626 - don't throw an error if the peak is displayed in another graph
	Wave/Z coefseps = DFRPath:$("Peak "+num2istr(peakNumber)+" Coefseps")	// ST: try to remove the coefseps waves
	KillWaves/Z coefseps
	npeaks -= 1
	
	Variable i
	for (i = peakNumber; i < nPeaks; i += 1)
		Wave peak = DFRPath:$("Peak "+num2istr(i+1))						// ST: rename all peak and coefseps waves as well (prevents clutter from stale waves)
		Wave coefs = DFRPath:$("Peak "+num2istr(i+1)+" Coefs")
		Duplicate/O peak, DFRPath:$("Peak "+num2istr(i)); KillWaves/Z peak	// ST: 200626 - use duplicate to prevent name conflicts
		Rename coefs, $("Peak "+num2istr(i)+" Coefs")
		Wave/Z coefseps = DFRPath:$("Peak "+num2istr(i+1)+" Coefseps")
		if (WaveExists(coefseps))
			Rename coefseps, $("Peak "+num2istr(i)+" Coefseps")
		endif
		theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i+1))
		WMHL_ChangeItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i+1), "Peak "+num2istr(i))
	endfor
end

Function MPF2_AddPeaksToGraph(setNumber, wfi, doTags, doGrayLines, doFullwidth)
	Variable setNumber
	Wave/Z wfi
	Variable doTags
	Variable doGrayLines
	Variable doFullwidth		// if non-zero, make the peaks the full width of the graph
	
	if (!WaveExists(wfi)) 		// || (DimSize(wfi, 0) == 0)) 
		return 0
	endif
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	DFREF setDF = $DFPath
	SVAR gname = setDF:GraphName

	MPF2_DisplayStatusMessage("", setDF)		// ST: 200603 - delete any status messages.
	
	Variable i
	
	NVAR XPointRangeBegin = setDF:XPointRangeBegin
	NVAR XPointRangeEnd = setDF:XPointRangeEnd
	SVAR YWvName = setDF:YWvName
	SVAR XWvName = setDF:XWvName
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	Variable XStart, XEnd
	if (WaveExists(xw))
		XStart = xw[XPointRangeBegin]
		XEnd = xw[XPointRangeEnd]
	else
		XStart = pnt2x(yw, XPointRangeBegin)
		XEnd = pnt2x(yw, XPointRangeEnd)
	endif
	
	if (XStart > XEnd)
		Variable temp = XStart
		XStart = XEnd
		XEnd = temp
	endif

	String taglist = AnnotationList(gname)
	Variable nItems = ItemsInList(taglist)
	String aTagName
	for (i = 0; i < nItems; i += 1)
		aTagName = StringFromList(i, taglist)
		if (stringmatch(aTagName, "PeakTag*"))
			Tag/W=$gname/K/N=$aTagName
		endif
	endfor
	SetDrawLayer/W=$gname/K ProgBack
	String oldDrawLayer = S_name
	
	Variable nPeaks = DimSize(wfi, 0)
	if (nPeaks == 0)							// ST: 200906 - return after things have been cleaned up
		return 0
	endif
	
	Make/N=(doFullWidth?1000:200)/O/D/FREE MPF2_TempXWave
	for (i = 0; i < nPeaks; i += 1)
		if ( (wfi[i][1] == 0) || (wfi[i][2] == 0) )
			// width or height estimate is zero- bad info; skip it.
			// fixes index-out-of-range error that results from trying to set up the peak trace with bad data. But how did the bad data get into the wfi wave?
			continue
		endif
		String PeakWaveName = "Peak "+num2istr(i)
		Make/D/N=(doFullWidth?1000:200)/O setDF:$PeakWaveName
		Wave w = setDF:$PeakWaveName
		Wave coefs = setDF:$("Peak "+num2istr(i)+" Coefs")
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		String PeakFuncName = infoFunc(PeakFuncInfo_PeakFName)
		FUNCREF MPF2_PeakFunctionTemplate peakFunc = $PeakFuncName
		
		Variable center = coefs[0]
		if (doFullWidth)
			SetScale/I x XStart, XEnd, "", w
		else
			Variable width = wfi[i][1]

			// ST: since the initial guess width could be totally off from the current width, take the width from the current parameters instead (for the internal peaks only)
			//Variable directwidth = MPF2_GetGaussWidthFromPeakCoefs(PeakTypeName, coefs)
			Wave gaussParam = GetGaussParamsFromPeakCoefs(PeakTypeName, coefs)		// ST: 211105 - rewrote function to return free wave with all parameters at once
			Variable gaussWidth = gaussParam[1]										// ST: 211105 - gaussParam contains the same info as a row in W_AutoPeakInfo (width is the second value)
			if (numtype(gaussWidth) == 0 && gaussWidth != 0)						// ST: Make sure nothing breaks
				width = gaussWidth
			endif
			Variable StartScale = center-4*width
			Variable EndScale = center+4*width
			StartScale = max(StartScale, XStart)									// ST: 200605 - make sure the peak is not rendered outside the cursor range
			StartScale = StartScale > XEnd ? XStart : StartScale
			EndScale = min(EndScale, XEnd)
			EndScale = EndScale < XStart ? XEnd : EndScale
			SetScale/I x StartScale, EndScale, "", w
		endif
		MPF2_TempXWave = pnt2x(w, p)
		peakFunc(coefs, w, MPF2_TempXWave)
		
		CheckDisplayed/W=$gname w
		if (V_flag == 0)
			AppendToGraph/L=Peaks_Left/W=$gname w
			if (i == 0)
				ModifyGraph/W=$gname mirror(Peaks_Left)=1,standoff(Peaks_Left)=0	// ST: get a cleaner graph appearance
			endif
		endif
		
		if (doTags)
			String anchorCode = "MB"
			if (center < XStart || center > XEnd)									// ST: draw the tags against the bottom axis if outside the fit range
				Variable attachPoint = center < XStart ? XStart : (center > XEnd ? XEnd : center)
				Tag/W=$gname/N=$("PeakTag"+num2str(i))/A=$anchorCode/F=0/L=0/P=1/Y=1/X=0/B=1 bottom, center, "\\Zr080"+num2istr(i)
			else
				if (w(center) < 0)
					anchorCode = "MT"
				endif
				Tag/W=$gname/N=$("PeakTag"+num2str(i))/A=$anchorCode/F=0/L=0/P=1/Y=1/X=0/B=1 $NameOfWave(w), center, "\\Zr080"+num2istr(i)
			endif
		endif
		if (doGrayLines)
			SetDrawEnv/W=$gname linefgc=(56797,56797,56797),  xcoord=bottom, ycoord=prel
			DrawLine/W=$gname center, 0, center, 1
		endif
	endfor
	MPF2_AdjustAxes(gname)
	SetDrawLayer/W=$gname $oldDrawLayer
end

// ST: 211105 - depreciated: look for GetGaussParamsFromPeakCoefs within PeakFunctions2.ipf instead
//Function MPF2_GetGaussWidthFromPeakCoefs(String PeakTypeName, Wave coefs)
//End

// ST: 211105 - function to update WPI values with Gauss parameters converted from peak coefficient
Function MPF2_UpdateWPIwaveFromPeakCoef(Wave wpi, Variable row, String PeakTypeName, Wave coefs)
	Wave gaussParam = GetGaussParamsFromPeakCoefs(PeakTypeName, coefs)
	Variable currWidth = wpi[row][3]+wpi[row][4]								// should be the same as wpi[row][1]
	wpi[row][] = numtype(gaussParam[q]) == 0 ? gaussParam[q] : wpi[row][q]		// update only valid entries
	
	if (numtype(gaussParam[3]+gaussParam[4]) != 0)								// deal with undefined lwidth and rwidth parameters
		Variable widthDiff = (wpi[row][1] - currWidth)/2
		wpi[row][3] += widthDiff												// just add the difference in total width
		wpi[row][4] += widthDiff												// this keeps the absolute difference between lw and rw the same
	endif
	return 0
End


Function MPF2_UpdateBaselineOnGraph(setNumber, FitWaveName, OldCoefs, OldBLType, DoResidual, ResidWaveName, XDataWave, YDataWave)
	Variable setNumber
	String FitWaveName
	Wave OldCoefs
	String OldBLType
	Variable DoResidual
	String ResidWaveName
	Wave/Z XDataWave
	Wave YDataWave
	
	Variable nParams
	Variable i
	String BL_FuncName		

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	DFREF setDF = $DFpath
	SVAR gname = setDF:GraphName

	MPF2_DisplayStatusMessage("", setDF)	// ST: 200603 - delete any status messages.

	DFREF saveDFR = GetDataFolderDFR()
	SetDataFolder setDF
	
	NVAR XPointRangeBegin
	NVAR XPointRangeEnd

	Wave/Z w = $FitWaveName
	if (!WaveExists(w))
		Wave/Z wpi = W_AutoPeakInfo
		MPF2_AddFitCurveToGraph(setNumber, wpi, yDataWave, xDataWave, doResidual, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
	endif
	if (doResidual)
		Wave rw = $ResidWaveName
	endif
	SetDataFolder saveDFR
	
	STRUCT MPF2_BLFitStruct BLStruct
	Wave BLStruct.yWave = yDataWave			// ST 2.48: fill in y- and x-data pointers
	Wave/Z BLStruct.xWave = xDataWave
	if (WaveExists(xDataWave))
		BLStruct.xStart = xDataWave[XPointRangeBegin]
		BLStruct.xEnd = xDataWave[XPointRangeEnd]
	else
		BLStruct.xStart = pnt2x(yDataWave, XPointRangeBegin)
		BLStruct.xEnd = pnt2x(yDataWave, XPointRangeEnd)
	endif

	if (CmpStr(OldBLType, "None") != 0)
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(OldBLType + BL_INFO_SUFFIX)
		BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		
		FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
		Wave BLStruct.cWave = OldCoefs
		for (i = 0; i < numpnts(w); i += 1)
			BLStruct.x = pnt2x(w, i)		// the original
			w[i] -= blFunc(BLStruct)
		endfor
		if (doResidual)
			if (WaveExists(xDataWave))
				for (i = 0; i < numpnts(rw); i += 1)
					BLStruct.x = xDataWave[i]
					rw[i] += blFunc(BLStruct)
				endfor
			else
				for (i = 0; i < numpnts(rw); i += 1)
					BLStruct.x = pnt2x(rw, i)
					rw[i] += blFunc(BLStruct)
				endfor
			endif
		endif
	endif

	String baselineStr = WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0)
	if (CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0)
		String BL_TypeName = MPF2_PeakOrBLTypeFromListString(baselineStr)
		
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		
		FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
		Wave BLStruct.cWave = setDF:'Baseline Coefs'
		for (i = 0; i < numpnts(w); i += 1)
			BLStruct.x = pnt2x(w, i)
			w[i] += blFunc(BLStruct)
		endfor
		if (doResidual)
			if (WaveExists(xDataWave))
				for (i = 0; i < numpnts(rw); i += 1)
					BLStruct.x = xDataWave[i]
					rw[i] -= blFunc(BLStruct)
				endfor
			else
				for (i = 0; i < numpnts(rw); i += 1)
					BLStruct.x = pnt2x(rw, i)
					rw[i] -= blFunc(BLStruct)
				endfor
			endif
		endif
	endif
end	

Function MPF2_UpdateOnePeakOnGraph(setNumber, PeakNumber, FitWaveName, OldCoefs, OldPeakType, DoResidual, ResidWaveName, XDataWave)
	Variable setNumber
	Variable PeakNumber
	String FitWaveName
	Wave OldCoefs
	String OldPeakType
	Variable DoResidual
	String ResidWaveName
	Wave/Z XDataWave
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	DFREF setDF = $DFpath
	SVAR gname = setDF:GraphName
	
	MPF2_DisplayStatusMessage("", setDF)		// ST: 200603 - delete any status messages.
	
	FUNCREF MPF2_FuncInfoTemplate infoFunc=$(OldPeakType+PEAK_INFO_SUFFIX)
	String PeakFuncName = infoFunc(PeakFuncInfo_PeakFName)
	FUNCREF MPF2_PeakFunctionTemplate peakFunc = $PeakFuncName
	
	Wave w = setDF:$FitWaveName
	Make/N=(numpnts(w))/D/O/FREE MPF2_TempXWave,MPF2_TempYWave
	MPF2_TempXWave = pnt2x(w, p)
	peakFunc(OldCoefs, MPF2_TempYWave, MPF2_TempXWave)
	w -= MPF2_TempYWave
	if (DoResidual)
		Wave rw = setDF:$ResidWaveName
		Make/N=(numpnts(rw))/D/O/FREE MPF2_TempXRWave,MPF2_TempYRWave
		if (WaveExists(XDataWave))
			peakFunc(OldCoefs, MPF2_TempYRWave, XDataWave)
		else
			MPF2_TempXRWave = pnt2x(rw, p)
			peakFunc(OldCoefs, MPF2_TempYRWave, MPF2_TempXRWave)
		endif
		rw += MPF2_TempYRWave
	endif
DoUpdate	
	Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(PeakNumber))
	String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
	
	FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
	PeakFuncName = infoFunc(PeakFuncInfo_PeakFName)
	FUNCREF MPF2_PeakFunctionTemplate peakFunc = $PeakFuncName
	
	Wave coefs = setDF:$("Peak "+num2istr(PeakNumber)+" Coefs")
	peakFunc(coefs, MPF2_TempYWave, MPF2_TempXWave)
	w += MPF2_TempYWave
	
	String PeakWaveName = "Peak "+num2istr(PeakNumber)
	Wave w = setDF:$PeakWaveName
	Make/D/N=(numpnts(w))/O/FREE MPF2_TempPeakXWave
	MPF2_TempPeakXWave = pnt2x(w, p)
	peakFunc(coefs, w, MPF2_TempPeakXWave)
	if (DoResidual)
		if (WaveExists(XDataWave))
			peakFunc(coefs, MPF2_TempYRWave, XDataWave)
		else
			peakFunc(coefs, MPF2_TempYRWave, MPF2_TempXRWave)
		endif
		rw -= MPF2_TempYRWave
	endif
DoUpdate	
end

Function MPF2_MinPeakWidthLog(wpi, minxLog, maxxLog)
	Wave /Z wpi
	Variable & minxLog
	Variable & maxxLog
	
	if (!WaveExists(wpi) || (DimSize(wpi, 0) == 0))
		return 0
	endif
	
	Variable nPeaks = DimSize(wpi, 0)
	Variable i
	Variable minWidth = inf, currMin
	for (i = 0; i < nPeaks; i += 1)
		Variable dbg0 = wpi[i][0]+wpi[i][1]/2
		Variable dbg1 = wpi[i][0]-wpi[i][1]/2
	
		currMin = log(wpi[i][0]+wpi[i][1]/2)-log(wpi[i][0]-wpi[i][1]/2)
		if (currMin < minWidth)
			minWidth = currMin
			minxLog = log(wpi[i][0]-wpi[i][1]/2)
			maxxLog = log(wpi[i][0]+wpi[i][1]/2)
		endif
	endfor
	
	return minWidth
End

Function MPF2_MinPeakWidth(wpi)
	Wave/Z wpi
	
	if (!WaveExists(wpi) || (DimSize(wpi, 0) == 0))
		return 0
	endif
	
	Variable nPeaks = DimSize(wpi, 0)
	Variable i
	Variable minWidth = inf
	for (i = 0; i < nPeaks; i += 1)
		minWidth = min(wpi[i][1], minWidth)
	endfor
	
	return minWidth
end

Function MPF2_AdjustAxes(gname)
	String gname

	Variable axisBits = 0
	GetAxis/W=$gname/Q Left
	if (V_flag == 0)
		axisBits += 1
	endif
	GetAxis/W=$gname/Q Res_Left
	if (V_flag == 0)
		axisBits += 2
	endif
	GetAxis/W=$gname/Q Peaks_Left
	if (V_flag == 0)
		axisBits += 4
	endif

	switch (axisBits)
		case 1:
			ModifyGraph/W=$gname axisEnab(left)={0,1}
			break;
		case 2:		// highly unlikely
			ModifyGraph/W=$gname axisEnab(Res_Left)={0, 1}, lblPosMode(Res_Left)=1			// lblPosMode set to Absolute mode
			break;
		case 3:
			ModifyGraph/W=$gname axisEnab(left)={0,.75}
			ModifyGraph/W=$gname axisEnab(Res_Left)={.8, 1}, lblPosMode(Res_Left)=1			// lblPosMode set to Absolute mode
			break;
		case 4:		// highly unlikely
			ModifyGraph/W=$gname axisEnab(Peaks_Left)={0, 1}, lblPosMode(Peaks_Left)=1		// lblPosMode set to Absolute mode
			ModifyGraph/W=$gname freePos(Peaks_Left)={0,kwFraction}
			break;
		case 5:
			ModifyGraph/W=$gname axisEnab(left)={.25, 1}
			ModifyGraph/W=$gname axisEnab(Peaks_Left)={0, .2}, lblPosMode(Peaks_Left)=1		// lblPosMode set to Absolute mode
			ModifyGraph/W=$gname freePos(Peaks_Left)={0,kwFraction}
			break;
		case 6:		// highly unlikely
			ModifyGraph/W=$gname axisEnab(Res_Left)={.52, 1}, lblPosMode(Res_Left)=1		// lblPosMode set to Absolute mode
			ModifyGraph/W=$gname axisEnab(Peaks_Left)={0, .48}, lblPosMode(Peaks_Left)=1	// lblPosMode set to Absolute mode
			ModifyGraph/W=$gname freePos(Peaks_Left)={0,kwFraction}
			break;
		case 7:
			ModifyGraph/W=$gname axisEnab(left)={.25,.75}
			ModifyGraph/W=$gname axisEnab(Res_Left)={.8, 1}, lblPosMode(Res_Left)=1			// lblPosMode set to Absolute mode
			ModifyGraph/W=$gname axisEnab(Peaks_Left)={0, .2}, lblPosMode(Peaks_Left)=1		// lblPosMode set to Absolute mode
			ModifyGraph/W=$gname freePos(Peaks_Left)={0,kwFraction}
			break;
	endswitch
end

Function MPF2_AddFitCurveToGraph(setNumber, wfi, yDataWave, xDataWave, doResidual [, overridePoints])
	Variable setNumber
	Wave/Z wfi
	Wave yDataWave
	Wave/Z xDataWave
	Variable doResidual
	Variable overridePoints
	Variable pointForPoint = overridePoints < 0		// JW 180328 Make the fit curve point-for-point with the data. That is, a point for each point in the X data
	
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname = DFRpath:GraphName
	
	NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
	NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
	NVAR XPointRangeReversed = DFRpath:XPointRangeReversed

	Variable xleft
	Variable xright
	if (WaveExists(xDataWave))
		xleft = xDataWave[XPointRangeBegin]
		xright = xDataWave[XPointRangeEnd]
	else
		xleft = pnt2x(yDataWave, XPointRangeBegin)
		xright = pnt2x(yDataWave, XPointRangeEnd)
	endif

	Variable doLogScale = 0
	String aInfo = AxisInfo(gname, "bottom")
	String aRecreation = aInfo[StrSearch(aInfo, "RECREATION",0)+11, strlen(aInfo)-1]
	if (str2num(StringByKey("log(x)",aRecreation,"=", ";")))	// ST: enable log scale for inverse scales => // && xright > xleft) 
		doLogScale = 1
	endif

	Variable dx, npnts
	
	if (pointForPoint)
		npnts = -1
	else
		if (doLogScale)
			Variable minxLog, maxxLog
			MPF2_MinPeakWidthLog(wfi, minxLog, maxxLog)	
			dx = (maxxLog-minxLog)/10
			npnts = 200
			if (overridePoints > 0)
				npnts = overridePoints
				dx = (log(xright)-log(xleft))/(npnts-1)			// ST: recalculate dx value
			else
				if (dx > 0)				
					npnts = abs(ceil((log(xright)-log(xleft))/dx))
					dx = (log(xright)-log(xleft))/(npnts-1)		// ST: recalculate dx value
				endif
			endif
		else 
			dx = MPF2_MinPeakWidth(wfi)/10
			npnts = 200
			if (overridePoints > 0)
				npnts = overridePoints
			else
				if (dx > 0)
					npnts = abs(xright-xleft)/dx
				endif
			endif	
		endif
	endif
	
	Variable/G DFRpath:MPF2_FitCurvePoints = npnts
	
	String fitName = CleanUpName("fit_"+NameOfWave(yDataWave),1)
	String fitNameX = CleanUpName("fitX_"+NameOfWave(yDataWave),1)
	
	Wave /Z xw
	if (pointForPoint)
		Duplicate/O yDataWave, DFRpath:$fitName/WAVE=yw
		if (WaveExists(xDataWave))
			Wave xw = xDataWave							// ST: correct wave reference
			SetScale/I x xw[0],xw[numpnts(xw)-1], yw	// ST: scale the fit wave accordingly
		endif
		Note yw, "usefitx=3;"
		yw = 0
	else
		Make/O/N=(npnts) DFRpath:$fitName
		Wave yw = DFRpath:$fitName
		if (doLogScale)
			Note yw, "usefitx=1;"
			Make /O/N=(npnts) DFRpath:$fitNameX
			Wave xw = DFRpath:$fitNameX
			xw = 10^(log(xleft) + p*dx)
		else	
			Note yw, "usefitx=0;"
			setscale/I x min(xleft, xright), max(xleft, xright), yw
		endif
		yw = 0
	endif

	CheckDisplayed/W=$gname yw
	if (V_flag == 0)
		if (WaveExists(xw))
			AppendToGraph/W=$gname yw vs xw
		else
			AppendToGraph/W=$gname yw
		endif
		ModifyGraph/W=$gname rgb($NameOfWave(yw))=(1,4,52428)
	else
		if (WaveExists(xw))
			ReplaceWave /W=$gname /X trace=$NameOfWave(yw), xw
		else
			Wave/Z txw = XWaveRefFromTrace(gname, NameOfWave(yw) )			
			if (WaveExists(txw))
				ReplaceWave/W=$gname/X trace=$NameOfWave(yw), $""
			endif
		endif
	endif
	
	if (doResidual)
		String resname = CleanUpName(("Res_"+NameOfWave(yDataWave)), 1)
		Duplicate/O yDataWave, DFRpath:$resname
		Wave rw = DFRpath:$resname
		if (WaveType(rw) != 4)
			Redimension/D rw
		endif
		if (XPointRangeBegin > 0)
			rw[0,XPointRangeBegin-1] = 0
		endif
		if (XPointRangeEnd < numpnts(rw)-2)
			rw[XPointRangeEnd+1,]=0
		endif
		CheckDisplayed/W=$gname rw
		if (V_flag == 0)
			if (WaveExists(xDataWave))
				AppendToGraph/W=$gname/L=Res_left rw vs xDataWave
			else
				AppendToGraph/W=$gname/L=Res_left rw
			endif
			ModifyGraph/W=$gname rgb($NameOfWave(yw))=(1,4,52428)
			ModifyGraph freePos(Res_left)={0,kwFraction}
			ModifyGraph/W=$gname mirror(Res_left)=1,standoff(Res_left)=0,zero(Res_left)=4	// ST: get a cleaner graph appearance
		endif
	endif

	Variable nParams
	Variable i
	String bkgName
	
	Variable BaselineRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
	String baselineStr = WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, BaselineRow)
	if (CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0)
		String BL_FuncName
		String BL_TypeName = MPF2_PeakOrBLTypeFromListString(baselineStr)
		
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		
		FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
		STRUCT MPF2_BLFitStruct BLStruct
		Wave BLStruct.yWave = yDataWave						// ST 2.48: fill in y- and x-data pointers
		Wave/Z BLStruct.xWave = xDataWave
		if (WaveExists(xDataWave))
			BLStruct.xStart = xDataWave[XPointRangeBegin]
			BLStruct.xEnd = xDataWave[XPointRangeEnd]
		else
			BLStruct.xStart = pnt2x(yDataWave, XPointRangeBegin)
			BLStruct.xEnd = pnt2x(yDataWave, XPointRangeEnd)
		endif
		Wave BLStruct.cWave = DFRpath:'Baseline Coefs'
		if (doResidual)
			for (i = XPointRangeBegin; i <= XPointRangeEnd; i += 1)
				if (WaveExists(xDataWave))
					BLStruct.x = xDataWave[i]
				else
					BLStruct.x = pnt2x(rw, i)
				endif
				rw[i] -= blFunc(BLStruct)
			endfor
		endif
		bkgName = CleanUpName("Bkg_"+NameOfWave(yDataWave), 1)

		Wave /Z bkgw = $""
		if (WaveExists(xw))
			Make/O/N=(dimsize(xw,0)) DFRpath:$bkgName
			Wave bkgw = DFRpath:$bkgName		
		
			Variable nBkgPts = dimsize(bkgw, 0)				// ST: correct size population
			for (i=0; i<nBkgPts; i+=1)
				BLStruct.x = xw[i]
				yw[i] = blFunc(BLStruct)
			endfor
			bkgw = yw
			
			CheckDisplayed/W=$gname bkgw
			if (V_flag == 0)
				AppendToGraph/W=$gname bkgw vs xw
				ModifyGraph/W=$gname rgb($NameOfWave(bkgw))=(2,39321,1)
			else
				ReplaceWave/W=$gname/X trace=$NameOfWave(bkgw), xw
			endif 			
		else
			Make/O/N=(dimsize(yw,0)) DFRpath:$bkgName		// ST: baseline wave the same size as the fit wave
			Wave bkgw = DFRpath:$bkgName		
			SetScale x leftx(yw), rightx(yw), bkgw
			for (i = 0; i < numpnts(yw); i += 1)
				BLStruct.x = pnt2x(yw, i)
				yw[i] += blFunc(BLStruct)
			endfor
			bkgw = yw(x)

			CheckDisplayed/W=$gname bkgw
			if (V_flag == 0)
				AppendToGraph/W=$gname bkgw
				ModifyGraph/W=$gname rgb($NameOfWave(bkgw))=(2,39321,1)
			else
				ReplaceWave/W=$gname/X trace=$NameOfWave(bkgw), $""
			endif
		endif		
	else
		bkgName = CleanUpName("Bkg_"+NameOfWave(yDataWave), 1)
		RemoveFromGraph/W=$gname/Z $bkgName
	endif

	Variable nPeaks = 0
	if (WaveExists(wfi))
		nPeaks = DimSize(wfi, 0)
	endif
	Make/N=(numpnts(yw))/O/D/FREE MPF2_TempXWave, MPF2_TempYWave
	if (WaveExists(xw))
		MPF2_TempXWave = xw
	else
		MPF2_TempXWave = pnt2x(yw, p)
	endif
	MPF2_TempYWave = yw

	if (doResidual)
		Duplicate/O/FREE rw, MPF2_TempYRWave
		Make/N=(numpnts(rw))/O/D/FREE MPF2_TempXRWave
		if (WaveExists(xDataWave))
			MPF2_TempXRWave = XDataWave
		else
			MPF2_TempXRWave = pnt2x(rw, p)
		endif
	endif
	for (i = 0; i < nPeaks; i += 1)
		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		String PeakFuncName = 	infoFunc(PeakFuncInfo_PeakFName)
		FUNCREF MPF2_PeakFunctionTemplate peakFunc = $PeakFuncName
		
		peakFunc(coefs, MPF2_TempYWave, MPF2_TempXWave)
		yw += MPF2_TempYWave
		if (doResidual)
			peakFunc(coefs, MPF2_TempYRWave, MPF2_TempXRWave)
			rw[XPointRangeBegin, XPointRangeEnd] -= MPF2_TempYRWave[p]
		endif
//doupdate
	endfor

	MPF2_AdjustAxes(gname)
//doupdate
end

Function/S MPF2_ListPeakTypeNames()

	//String funcList = FunctionList("*"+PEAK_INFO_SUFFIX, ";", "NPARAMS:1,VALTYPE:4")
	String funcList = FunctionList("*"+PEAK_INFO_SUFFIX, ";", "NPARAMS:1,VALTYPE:4,WIN:PeakFunctions2.ipf")		// ST: 220712 - makes sure that standard peak functions always come first
	funcList += RemoveFromList(funcList, FunctionList("*"+PEAK_INFO_SUFFIX, ";", "NPARAMS:1,VALTYPE:4"))
	
	String theList=""
	Variable nItems = ItemsInList(funcList)
	Variable i
	
	for (i = 0; i < nItems; i += 1)
		String oneFunc = StringFromList(i, funcList)
		theList += oneFunc[0,strlen(oneFunc)-strlen(PEAK_INFO_SUFFIX)-1] + ";"
	endfor
	
	return theList
end

Function/S MPF2_ListBaseLineTypeNames()

	//String funcList = FunctionList("*"+BL_INFO_SUFFIX, ";", "NPARAMS:1")
	String funcList = FunctionList("*"+BL_INFO_SUFFIX, ";", "NPARAMS:1,WIN:PeakFunctions2.ipf")					// ST: 220712 - makes sure that standard background functions always come first
	funcList += RemoveFromList(funcList, FunctionList("*"+BL_INFO_SUFFIX, ";", "NPARAMS:1"))
	
	String theList=""
	Variable nItems = ItemsInList(funcList)
	Variable i
	
	for (i = 0; i < nItems; i += 1)
		String oneFunc = StringFromList(i, funcList)
		theList += oneFunc[0,strlen(oneFunc)-strlen(BL_INFO_SUFFIX)-1] + ";"
	endfor
	
	return theList
end

Function MPF2_GetSavedPeakOrBLInfo(setNumber, ListRow, SavedCoefWave, SavedPeakorBLType, PeakNumber)
	Variable setNumber
	Variable ListRow
	Wave SavedCoefWave
	String &SavedPeakorBLType
	Variable &PeakNumber
	
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	
	SVAR gname = DFRpath:GraphName
	
	string parentitem = WMHL_GetParentItemForRow(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", ListRow)
	if (strlen(parentItem) > 0)
		ListRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", parentitem)
	endif
	
	if (ListRow == 0)		// it's the container row for the baseline
		String baselineStr = WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0)
		SavedPeakorBLType = MPF2_PeakOrBLTypeFromListString(baselineStr)
		if (CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0)
			Wave cwave = DFRpath:'Baseline Coefs'
			Redimension/N=(numpnts(cwave)) SavedCoefWave
			SavedCoefWave = cwave
		endif
	else
		SavedPeakorBLType = MPF2_PeakOrBLTypeFromListString(WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, ListRow))
		String peakName = ParseFilePath(0, WMHL_GetItemForRowNumber(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", ListRow), ":", 1, 0)
		Wave cwave = DFRpath:$(peakName + " Coefs")
		Redimension/N=(numpnts(cwave)) SavedCoefWave
		SavedCoefWave = cwave
		sscanf peakName, "Peak %d", peakNumber
	endif
end

Function SetHoldCheckboxesFromWave(setNumber)
	Variable setNumber
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	Wave/T HoldStrings = $(DFPath+":HoldStrings")
	SVAR gname = $(DFPath+":GraphName")
	
	Variable i, j
	String hs
	Variable nchildren
	Variable selWaveValue
	
	// set checkboxes for baseline row
	if (WMHL_RowIsOpen(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0))
		hs = HoldStrings[0]
		nchildren = ItemsInList(WMHL_ListChildRows(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0))
		for (j = 0; j < nchildren; j += 1)
			selWaveValue = 0x20		// a checkbox with the Checked attribute turned off
			if ( (strlen(hs) > 0) && (char2num(hs[j]) == char2num("1")) )
				selwaveValue = 0x10+0x20
			endif
			WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 1, j+1, "Hold", 0, setSelWaveValue=selwaveValue)
		endfor
	endif

	i = 0

	do
		Variable parentRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
		if (parentRow < 0)
			break;
		endif
		if (WMHL_RowIsOpen(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", parentRow))
			hs = HoldStrings[i+1]
			nchildren = ItemsInList(WMHL_ListChildRows(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", parentRow))
			for (j = 0; j < nchildren; j += 1)
				selWaveValue = 0x20		// a checkbox with the Checked attribute turned off
				if ( (strlen(hs) > 0) && (char2num(hs[j]) == char2num("1")) )
					selwaveValue = 0x10+0x20
				endif
				WMHL_ExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 1, parentRow+j+1, "Hold", 0, setSelWaveValue=selwaveValue)
			endfor
		endif
		
		i += 1
	while (1)
end

Static Function/S RemoveNonPeaksFromList(inputList)
	String inputList
	
	Variable nItems = itemsInList(inputList)
	Variable i
	String newList = ""
	
	for (i = nItems-1; i >= 0; i -= 1)
		String oneItem = StringFromList(i, inputList)
		if (CmpStr(oneItem[0,4], "Peak ") == 0)
			newList += oneItem+";"
		endif
	endfor
	
	return newList
end

// Action procedure 
Function MPF2_PeakListProc(s)
	STRUCT WMListboxAction &s

	if (s.eventCode == -1)			// control being killed, presumably because the window is being closed
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	Variable retValue = 0

	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	Variable npeaks = 0
	if (WaveExists(wpi))
		npeaks = DimSize(wpi, 0)
	endif
	SVAR YWvName = $(DFpath+":YWvName")
	Wave yw = $YWvName
	SVAR XWvName = $(DFpath+":XWvName")
	Wave/Z xw = $XWvName
	SVAR gname=$(DFPath+":"+"GraphName")

	Variable i
	Variable peakNum
	String peakorBLtype=""
	Variable peakNumber
	string parentitem
	string rowItem
	Variable itemRow
	String peakType
	Variable rowIsOpen
	Variable itemOffset, paramNum
	
	switch(s.eventCode)
		case 1:					// mouse down
			if ( (s.row >= 0) && (s.row < DimSize(s.listWave, 0)) )
				if (s.col >= 1)
					Make/D/O/N=0 $(DFPath+":SavedCoefWave") /WAVE = SavedCoefWave		// ST: 200626 - create this temporary wave inside the MPF folder
					MPF2_GetSavedPeakOrBLInfo(setNumber, s.row, SavedCoefWave, peakorBLtype, peakNumber)
					parentitem = WMHL_GetParentItemForRow(s.win, s.ctrlName, s.row)
					Variable parentRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, parentItem)
					if (strlen(parentitem) > 0)		// > 0 means "not the baseline row"
						// has a parent, must be one of the coefficient value rows. Possibly put up a menu with "Set all to this value" or "Hold all of this"
						if (s.eventMod & 16)		// contextual menu click
							retValue = 1
							if ( (s.col == 1) || (s.col == 2) )
								PopupContextualMenu "Copy This Value to All Peaks of This Type;"
								if (V_flag > 0)
									sscanf parentItem, "Peak %d", peakNum
									Wave coefs = $(DFPath+":'Peak "+num2istr(peakNum)+" Coefs'")
									paramNum = s.row-parentRow-1
									Variable coefValue = coefs[paramNum]
									i = 0;
									do
										itemRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, "Peak "+num2str(i))
										if (itemRow < 0)
											break;
										endif
										peakType = MPF2_PeakOrBLTypeFromListString(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, itemRow))
										if (CmpStr(peakType, peakorBLtype) == 0)		// same type of peak as the one clicked on
											Wave coefs = $(DFPath+":'Peak "+num2istr(i)+" Coefs'")
											coefs[paramNum] = coefValue
											rowIsOpen = WMHL_RowIsOpen(s.win, s.ctrlName, itemRow)
											if (rowIsOpen)
												rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, itemRow)
												WMHL_CloseAContainer(s.win, s.ctrlName, rowItem)	// info for this row has changed. Opening the row re-evaluates the info
												WMHL_OpenAContainer(s.win, s.ctrlName, rowItem)
											endif
										endif
										i += 1
									while(1)
									NVAR negativePeaks = $(DFPath+":negativePeaks")
									NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
									MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
									MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
								endif
							elseif (s.col == 3)	
								PopupContextualMenu "Hold for All Peaks of This Type;No Hold for All Peaks of This Type;"
								if (V_flag > 0)
									Variable doHold = V_flag == 1
									Variable nParams = ItemsInList(WMHL_ListChildRows(s.win, s.ctrlName, parentRow))
									itemOffset = s.row-parentRow
									Wave/T HoldStrings= $(DFPath+":HoldStrings")
									MPF2_RefreshHoldStrings(gname+"#MultiPeak2Panel")
									i = 0;
									do
										itemRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, "Peak "+num2str(i))
										if (itemRow < 0)
											break;
										endif
										peakType = MPF2_PeakOrBLTypeFromListString(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, itemRow))
										if (CmpStr(peakType, peakorBLtype) == 0)		// same type of peak as the one clicked on
											String hs = HoldStrings[i+1]
											if (strlen(hs) == 0)
												hs = PadString(hs, nParams, char2num("0"))
											endif
											if (doHold)
												hs[itemOffset-1, itemOffset-1] = "1"
											else
												hs[itemOffset-1, itemOffset-1] = "0"
											endif
											HoldStrings[i+1] = hs
										endif
										i += 1
									while(1)
									SetHoldCheckboxesFromWave(setNumber)
								endif
							elseif (s.col==4 || s.col==5)
								PopupContextualMenu "Copy This Value to All Peaks of This Type;"
								if (V_flag > 0)
									MPF2_RefreshConstraintStrings(setNumber)						
									paramNum = s.row-parentRow-1
									Variable minVal = str2num(getPeakConstraints(setNumber, peakNumber+1, paramNum, "Min"))
									i = 0;
									do
										itemRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, "Peak "+num2str(i))
										if (itemRow < 0)
											break;
										endif
										peakType = MPF2_PeakOrBLTypeFromListString(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, itemRow))
										if (CmpStr(peakType, peakorBLtype) == 0)					// same type of peak as the one clicked on	
											rowIsOpen = WMHL_RowIsOpen(s.win, s.ctrlName, itemRow)
											if (rowIsOpen)
												rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, itemRow)
												WMHL_CloseAContainer(s.win, s.ctrlName, rowItem)	// info for this row has changed. Opening the row re-evaluates the info
											endif
											setPeakConstraints(setNumber, i+1, paramNum, minVal=minVal)	
											if (rowIsOpen)
												WMHL_OpenAContainer(s.win, s.ctrlName, rowItem)
											endif
										endif
										i += 1
									while(1)
								endif
							elseif (s.col==6 || s.col==7)
								PopupContextualMenu "Copy This Value to All Peaks of This Type;"
								if (V_flag > 0)
									MPF2_RefreshConstraintStrings(setNumber)						
									paramNum = s.row-parentRow-1
									Variable maxVal = str2num(getPeakConstraints(setNumber, peakNumber+1, paramNum, "Max"))
									i = 0;
									do
										itemRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, "Peak "+num2str(i))
										if (itemRow < 0)
											break;
										endif
										peakType = MPF2_PeakOrBLTypeFromListString(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, itemRow))
										if (CmpStr(peakType, peakorBLtype) == 0)					// same type of peak as the one clicked on	
											rowIsOpen = WMHL_RowIsOpen(s.win, s.ctrlName, itemRow)
											if (rowIsOpen)
												rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, itemRow)
												WMHL_CloseAContainer(s.win, s.ctrlName, rowItem)	// info for this row has changed. Opening the row re-evaluates the info
											endif
											setPeakConstraints(setNumber, i+1, paramNum, maxVal=maxVal)	
											if (rowIsOpen)
												WMHL_OpenAContainer(s.win, s.ctrlName, rowItem)
											endif
										endif
										i += 1
									while(1)																									
								endif
							endif
						endif
					else
						// has no parent, must be a peak type row. Possibly put up a peak type selection menu
						if (s.col == 2)
							string selection = MPF2_ContextMenuForBLorPeakType(s.win, s.row)
							if (strlen(selection) > 0)
								WMHL_ExtraColumnData(s.win, s.ctrlName, 0, s.row, selection+MENU_ARROW_STRING, 0)
								if (s.row == 0)
									MPF2_InfoForBaseline(setnumber, selection)
									MPF2_InitializeBaseline(setnumber, selection) 				// ST: 200627 - separated out the initialization function
									MPF2_UpdateBaselineOnGraph(setnumber, CleanUpName("fit_"+NameOfWave(yw), 1), SavedCoefWave, peakorBLtype, 1, CleanUpName("Res_"+NameOfWave(yw), 1), xw, yw)
								else
									MPF2_CoefWaveForListRow(setNumber, s.row, selection)							
									MPF2_UpdateOnePeakOnGraph(setnumber, peakNumber, CleanUpName("fit_"+NameOfWave(yw), 1), SavedCoefWave, peakorBLtype, 1, CleanUpName("Res_"+NameOfWave(yw), 1), xw)
								endif
								// This is a sledgehammer to get the baseline curve to update
								MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
								rowIsOpen = WMHL_RowIsOpen(s.win, s.ctrlName, s.row)
								if (rowIsOpen)
									rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, s.row)
									WMHL_CloseAContainer(s.win, s.ctrlName, rowItem)			// info for this row has changed. Opening the row re-evaluates the info
								endif
								Wave/T HoldStrings = $(DFpath+":HoldStrings")
								if (s.row == 0)
									HoldStrings[0] = ""
									resetPeakConstraints(setNumber, 0)
								else
									HoldStrings[peakNumber+1] = ""
									resetPeakConstraints(setNumber, peakNumber+1)
								endif
								if (rowIsOpen)
									WMHL_OpenAContainer(s.win, s.ctrlName, rowItem)
								endif
								
								String ListOfCWaveNames = "Baseline Coefs;"						// ST 2.47: The peak type (and thus number of parameters/coefs) might have changed => backup
								for (i = 0; i < npeaks; i += 1)
									ListOfCWaveNames += "Peak "+num2istr(i)+" Coefs;"
								endfor
								MPF2_BackupCoefWaves(ListOfCWaveNames, DFpath)
							endif
						else
							if (s.eventMod & 16)		// contextual menu click
								String listOfSelectedPeaks = WMHL_SelectedObjectsList(s.win, s.ctrlName)
								listOfSelectedPeaks = RemoveNonPeaksFromList(listOfSelectedPeaks)
								rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, s.row)
					
								String menuString = ""
								Variable doSelection = 0
								if (!StringMatch(rowItem, "Baseline"))							// ST: don't offer to delete the baseline
									if (strlen(listOfSelectedPeaks) > 0)
										menuString = "Delete Selected Peaks;"
										doSelection = 1
									else
										menuString = "Delete "+rowItem+";"
									endif
								endif
								menuString += "Expand All;Collapse All;"						// ST: add menu option to expand or collapse all peak rows
								
								PopupContextualMenu menuString
								Selection = S_selection
								if (V_Flag > 0)
									if (StringMatch(Selection, "Delete*"))
										if (doSelection)
											listOfSelectedPeaks = SortList(listOfSelectedPeaks, ";", 17)		// sort alphanumerically in descending order so we delete higher-numbers peaks first
											for (i = 0; i < ItemsInList(listOfSelectedPeaks); i += 1)
												MPF2_DeleteAPeak(gname, StringFromList(i, listOfSelectedPeaks))
											endfor
											retvalue = 1
										else
											rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, s.row)
											retvalue = MPF2_DeleteAPeak(gname, rowItem)
										endif
									else														// ST: open or close all rows depending on selection
										rowIsOpen = WMHL_RowIsOpen(s.win, s.ctrlName, 0)		// ST: do the baseline (row = 0) first
										rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, 0)
										if (!rowIsOpen && StringMatch(Selection, "Expand All"))
											WMHL_OpenAContainer(s.win, s.ctrlName, rowItem)
										endif
										if (rowIsOpen && StringMatch(Selection, "Collapse All"))
											WMHL_CloseAContainer(s.win, s.ctrlName, rowItem)
										endif
										
										i = 0;
										do														// ST: now do all peaks
											itemRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, "Peak "+num2str(i))
											if (itemRow < 0)
												break;
											endif
											rowIsOpen = WMHL_RowIsOpen(s.win, s.ctrlName, itemRow)
											rowItem = WMHL_GetItemForRowNumber(s.win, s.ctrlName, itemRow)
											if (!rowIsOpen && StringMatch(Selection, "Expand All"))
												WMHL_OpenAContainer(s.win, s.ctrlName, rowItem)
											endif
											if (rowIsOpen && StringMatch(Selection, "Collapse All"))
												WMHL_CloseAContainer(s.win, s.ctrlName, rowItem)
											endif
											i += 1
										while(1)
									endif
								endif
							endif
						endif
					endif
				endif
				KillWaves SavedCoefWave
			endif
			break;
		case 2:						// mouse up
			if (s.eventMod & 16)	// contextual menu click
				retvalue = 1
			endif
			break;
		case 6:						// begin edit
			break;
		case 12:					// keyboard event
			//print s.row			// debug: print key code
			if ( (s.row == 8) || (s.row == 127) )									// backspace or delete
				String selections = WMHL_SelectedObjectsList(s.win, s.ctrlName)
				Variable nItems = ItemsInList(selections)
				Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
				SVAR YWvName = $(DFpath+":YWvName")
				Wave YData = $YWvName
				SVAR XWvName = $(DFpath+":XWvName")
				Wave/Z XData = $XWvName
				if (WaveExists(wpi))
					for (i = nItems-1; i >= 0; i -= 1)
						String selectedItem = StringFromList(i, selections)
						MPF2_DeleteAPeak(gname, selectedItem)
					endfor
				endif
			endif
			
			// ST: 200827 - implement live keyboard increase and decrease of values
			Variable updatePeaks = 0
			if ( (s.row == 91) || (s.row == 93) || (s.row == 109) || (s.row == 110))	// left bracket '[' and right bracket ']' as well as m and n
				Duplicate/FREE/RMD=[][2] s.selwave, CoefSelection						// ST: look only at the coef column
				Redimension/I/N=(-1) CoefSelection
				FindValue/Z/I=3 CoefSelection											// ST: find the row of the current (first) selection directly in the selwave
				Variable selectItem = V_Value
				Variable multiplier = 0.01												// ST: by how much in % the value gets changed
				if (selectItem > 0)
					Variable selectValue = str2num(s.listwave[selectItem][2])
					if (numtype(selectValue) == 0)
						parentitem = WMHL_GetParentItemForRow(s.win, s.ctrlName, selectItem)
						Variable isPeak = CmpStr(parentitem[0,3], "Peak") == 0
						Variable isFirstItem = WMHL_RowIsContainer(s.win, s.ctrlName, selectItem-1)
						
						if ( isPeak && isFirstItem )									// ST: the peak location is treated in a special way
							GetAxis/W=$gname/Q bottom
							Variable delta = (V_max - V_min) / 100						// ST: use 1 % of the displayed range for changing the value
							if (numtype(delta) != 0)
								break;
							endif
							
							if ( s.row == 91 || s.row == 109)		// [ and m : increase
								selectValue += delta
							elseif ( s.row == 93 || s.row == 110 )	// ] and n : decrease
								selectValue -= delta
							endif
						else
							if ( s.row == 91 || s.row == 109)		// [ and m : increase
								selectValue *= (1 + multiplier)
							elseif ( s.row == 93 || s.row == 110 )	// ] and n : decrease
								selectValue *= (1 - multiplier)
							endif
						endif
						
						NVAR MPF2_CoefListPrecision = $(DFPath+":"+"MPF2_CoefListPrecision")
						String numbers
						sprintf numbers, "%.*g", MPF2_CoefListPrecision, selectValue
						s.listwave[selectItem][2] = numbers								// ST: inject the value directly back into the list-wave; the selection is preserved
						s.row = selectItem												// ST: put the row in here and fall through to case 7
						updatePeaks = 1													// ST: skip the break => deliberately fall through to update the peaks
					endif
				endif
			endif
			if (!updatePeaks)
				break;
			endif
		case 7:						// finish edit
			// first, update the edited coefficient wave
			parentitem = WMHL_GetParentItemForRow(s.win, s.ctrlName, s.row)
			if (CmpStr(parentitem[0,3], "Peak") == 0)
				sscanf parentItem, "Peak %d", peakNum
				String peakName = ParseFilePath(0, parentitem, ":", 1, 0)
				String wavePath = DFPath+":"+PossiblyQuoteName(peakName+" Coefs")
				Wave wcoef = $wavePath
				parentRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, parentitem)
				String peakRows = WMHL_ListChildRows(s.win, s.ctrlName, parentRow)
				for (i = 0; i < ItemsInList(peakRows); i += 1)
					Variable coefRow = str2num(stringFromList(i, peakRows))
					wcoef[i] = str2num(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, coefRow))
				endfor
				// wpi[peakNum][0] = wcoef[0]		// ST: 200719 - copy current peak location into wpi to keep 'Add or Edit Peaks' and the out-of-range finder up-to-date
				
				itemRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, parentItem)
				peakType = MPF2_PeakOrBLTypeFromListString(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, itemRow))
				MPF2_UpdateWPIwaveFromPeakCoef(wpi, peakNum, peakType, wcoef)			// ST: 211105 - use peak coefs to update the full WPI
			elseif (CmpStr(parentitem, "Baseline") == 0)
				wavePath = DFPath+":"+"'Baseline Coefs'"
				Wave wcoef = $wavePath
				parentRow = WMHL_GetRowNumberForItem(s.win, s.ctrlName, parentitem)
				String baselineRows = WMHL_ListChildRows(s.win, s.ctrlName, parentRow)
				for (i = 0; i < ItemsInList(baseLineRows); i += 1)
					coefRow = str2num(stringFromList(i, baselineRows))
					wcoef[i] = str2num(WMHL_GetExtraColumnData(s.win, s.ctrlName, 0, coefRow))
				endfor
			endif

			// now re-evaluate the graph curves
			NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
			MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
			MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
			break;
	endswitch
	
	MPF2_EnableDisableDoFitButton(setNumber)
	return retValue
end		// listbox

Function MPF2_CoefWaveForListRow(setNumber, row, peakTypeName)
	Variable setNumber
	Variable row
	String peakTypeName
	
	Variable nparams
	String GaussGuessConversionFuncName

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname=$(DFPath+":"+"GraphName")
	
	Wave wpi = $(DFPath+":"+"W_AutoPeakInfo")
	string ContainerPath = WMHL_GetItemForRowNumber(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", row)
	String peakName = ParseFilePath(0, ContainerPath, ":", 1, 0)
	String wavePath = DFPath+":"+PossiblyQuoteName(peakName+" Coefs")
	Make/D/O/N=(DimSize(wpi, 1)) $wavePath
	
	Wave w = $wavePath
	Variable infoWaveRow = str2num(ContainerPath[5, strlen(ContainerPath)-1])
	Redimension/N=(DimSize(wpi, 1)) w
	w = wpi[infoWaveRow][p]
	
	FUNCREF MPF2_FuncInfoTemplate infoFunc=$(peakTypeName+PEAK_INFO_SUFFIX)
	GaussGuessConversionFuncName = infoFunc(PeakFuncInfo_GaussConvFName)
	FUNCREF MPF2_GaussGuessConvTemplate conversionFunc = $GaussGuessConversionFuncName
	conversionFunc(w)
end

Function MPF2_RefreshListCoefs(Variable setNumber)

	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	SVAR gname = DFRpath:GraphName
	String listPanelName = gname+"#MultiPeak2Panel#P1"
	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	Variable NPeaks = DimSize(wpi, 0)

	Variable BaselineRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", "Baseline")
	String baselineStr = WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, BaselineRow)
	Variable doBaseLine = CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0

	Variable i
	
	String numbers
	NVAR MPF2_CoefListPrecision = DFRpath:MPF2_CoefListPrecision
	
	if (doBaseLine)
		if (WMHL_RowIsOpen(listPanelName, "MPF2_PeakList", BaselineRow))
			Wave/SDFR=DFRpath 'Baseline Coefs'
			String baselineRows = WMHL_ListChildRows(listPanelName, "MPF2_PeakList", BaselineRow)
			Variable numBLRows = ItemsInList(baseLineRows)
			for (i = 0; i < numBLRows; i += 1)
				Variable BLcoefRow = str2num(stringFromList(i, baselineRows))
				sprintf numbers, "%.*g", MPF2_CoefListPrecision, 'Baseline Coefs'[i]
				WMHL_ExtraColumnData(listPanelName, "MPF2_PeakList", 0, BLcoefRow, numbers, 1)
			endfor
		endif
	endif

	for (i = 0; i < NPeaks; i += 1)
		Variable PeakRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", "Peak "+num2istr(i))
		if (WMHL_RowIsOpen(listPanelName, "MPF2_PeakList", PeakRow))
			Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
			String coefRows = WMHL_ListChildRows(listPanelName, "MPF2_PeakList", PeakRow)
			Variable numCoefRows = ItemsInList(coefRows)
			Variable j
			for (j = 0; j < numCoefRows; j += 1)
				Variable peakCoefRow = str2num(stringFromList(j, coefRows))
				sprintf numbers, "%.*g", MPF2_CoefListPrecision, coefs[j]
				WMHL_ExtraColumnData(listPanelName, "MPF2_PeakList", 0, peakCoefRow, numbers, 1)
			endfor
		endif
	endfor
end

Function/S MPF2_ContextMenuForBLorPeakType(hostWindow, row)
	String hostWindow
	Variable row
	
	String selectedItem = ""
	
	if (row == 0)		// it's the container row for the baseline
		PopupContextualMenu MPF2_ListBaseLineTypeNames()
	else
		if (strlen(WMHL_GetParentItemForRow(hostWindow, "MPF2_PeakList", row)) == 0)
			PopupContextualMenu MPF2_ListPeakTypeNames()
		endif
	endif
	if (V_flag > 0)
		selectedItem = S_selection
	endif
	
	return selectedItem
end

Function MPF2_InfoForBaseline(setnumber, BL_typename)
	Variable setnumber
	String BL_typename
	
	Variable nParams
	String ParamNameList
	FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
	ParamNameList = blinfo(BLFuncInfo_ParamNames)
	nparams = ItemsInList(ParamNameList)

	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	Make/O/D/N=(nparams) DFRPath:$("Baseline Coefs")
End

Function MPF2_InitializeBaseline(Variable setnumber, String BL_typename)	// ST 2.48: prepare initial guess for baseline
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	Wave blcoef = DFRPath:$("Baseline Coefs")
	
	STRUCT MPF2_BLFitStruct BLStruct
	Wave BLStruct.cWave = blcoef
	SVAR YWvName = DFRpath:$"YWvName"
	SVAR XWvName = DFRpath:$"XWvName"
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	Wave BLStruct.yWave = yw		// ST 2.48: fill in y- and x-data pointers
	Wave/Z BLStruct.xWave = xw
	NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
	NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
	if (WaveExists(xw))
		BLStruct.xStart = xw[XPointRangeBegin]
		BLStruct.xEnd = xw[XPointRangeEnd]
	else
		BLStruct.xStart = pnt2x(yw, XPointRangeBegin)
		BLStruct.xEnd = pnt2x(yw, XPointRangeEnd)
	endif
	BLStruct.x = BLStruct.xStart
	
	FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
	String BLInitFunc = blinfo(BLFuncInfo_InitGuessFunc)
	if (strlen(BLInitFunc) > 0)		// ST 2.48: execute only for backgrounds which know about initialization
		FUNCREF MPF2_BaselineFunctionTemplate blinit = $(BLInitFunc)
		blinit(BLStruct)
	endif
end

Static Function/S MPF2_HoldStringForPeakListItem(theItem, DatafolderPath, thePanelWin)
	String theItem, DatafolderPath, thePanelWin
	
	DFREF setDFR = $DatafolderPath
	
	Wave/Z/T HoldStrings = setDFR:HoldStrings
	if (!WaveExists(HoldStrings))
		return ""
	endif
	
	String holdString = ""
	Variable isBaseLine = CmpStr(theItem, "Baseline") == 0
	String children=""
	Variable i
	Variable numItems
	Variable rownumber
	Variable HoldStringsRow
	
	// It is possible to get into this function without having set the size of the hold strings wave correctly
	Wave/Z wpi = setDFR:W_AutoPeakInfo
	Variable npeaks = 0
	if (WaveExists(wpi))
		npeaks = DimSize(wpi, 0)
	endif
	if (DimSize(HoldStrings, 0) < npeaks+1)
		Variable oldSize = DimSize(HoldStrings, 0)
		Redimension/N=(npeaks+1) HoldStrings
		HoldStrings[oldSize, npeaks] = ""
	endif
	
	if (isBaseLine)
		HoldStringsRow = 0
	else	
		sscanf theItem, "Peak %d", HoldStringsRow
		HoldStringsRow += 1			// to account for the fact that the baseline holds are in row 0
	endif

	rownumber = WMHL_GetRowNumberForItem(thePanelWin, "MPF2_PeakList", theItem)
	if (WMHL_RowIsOpen(thePanelWin, "MPF2_PeakList", rownumber))
		children = WMHL_ListChildRows(thePanelWin, "MPF2_PeakList", rownumber)
		numItems = ItemsInList(children)
		for (i = 0; i < numitems; i += 1)
			rownumber = str2num(StringFromList(i, children))
			Variable SelWaveValue = WMHL_GetExtraColumnSelValue(thePanelWin, "MPF2_PeakList", 1, rownumber)
			if (SelWaveValue & 0x10)
				holdString += "1"
			else
				holdString += "0"
			endif
		endfor
	else
		holdString = HoldStrings[HoldStringsRow]
	endif
	
	Variable numchars = strlen(holdString)
	Variable Char1 = char2num("1")
	
	for (i = 0; i < numchars; i += 1)
		if (char2num(holdString[i]) == Char1)
			break;			// found a 1
		endif
	endfor
	if (i == numchars)
		holdString = ""		// didn't find a 1
	endif
	
	return holdString
end


// finds rows in the peak list that are open and writes the holds from those peaks (or the baseline) into the HoldStrings text wave
Static Function MPF2_RefreshHoldStrings(PanelWin)
	String PanelWin
	
	Variable setNumber = GetSetNumberFromWinName(PanelWin)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	Wave/T HoldStrings = $(DFPath+":HoldStrings")
	String listPanel = PanelWin+"#P1"

	Variable rownumber = WMHL_GetRowNumberForItem(listPanel, "MPF2_PeakList", "Baseline")
	if (WMHL_RowIsOpen(listPanel, "MPF2_PeakList", rownumber))
		HoldStrings[0] = MPF2_HoldStringForPeakListItem("Baseline", DFPath, listPanel)
	endif

	Variable i=0
	do
		String peakItem = "Peak "+num2str(i)
		rownumber = WMHL_GetRowNumberForItem(listPanel, "MPF2_PeakList", peakItem)
		if (rownumber < 0)
			break;
		endif
		HoldStrings[i+1] = MPF2_HoldStringForPeakListItem(peakItem, DFPath, listPanel)
		
		i += 1
	while(1)
end

// Please have the current data folder set to the correct data folder for the current set
//
// This function makes a theoretical peak using the peak function and parameters for the given row, then applies the algorithm used
// by AutoPeakFind to re-construct the auto peak picker info.
//static Function MPF2_GetSimulatedAutoPickData(peakCoefRow, listPanelName, tempAutoPickInfo)
//	Variable peakCoefRow
//	String listPanelName
//	Wave tempAutoPickInfo
//	
//	String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, peakCoefRow) )
//	FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
//	String PeakFuncName = infoFunc(PeakFuncInfo_PeakFName)
//	FUNCREF MPF2_PeakFunctionTemplate peakFunc = $PeakFuncName
//	String ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
//	Variable nDerivedParams = ItemsInList(infoFunc(PeakFuncInfo_DerivedParamNames))
//	Make/O/N=(nDerivedParams,2) tempParams
//	
//	FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
//	String peakName = WMHL_GetItemForRowNumber(listPanelName, "MPF2_PeakList", peakCoefRow)
//	Wave coef = $(peakName+" Coefs")
//	Make/D/N=(numpnts(coef), numpnts(coef))/O dummycov=0
//	paramFunc(coef, dummycov, tempParams)
//	Make/D/N=1001/O/D tempPeakWavey, tempPeakWavex
//	Variable location, FWHM
//	location = tempParams[0][0]
//	FWHM = tempParams[3][0]
//	SetScale/I x location-10*FWHM, location +10*FWHM, tempPeakWavey
//	tempPeakWavex = pnt2x(tempPeakWavey, p)
//	peakFunc(coef, tempPeakWavey, tempPeakWavex)
//	Duplicate/O tempPeakWavey, difPeakWavey
//	
//	// OK, we finally have a synthetic peak
//	if (tempParams[1][0] < 0)
//		difPeakWavey = -difPeakWavey
//	endif
//	Differentiate difPeakWavey
//	Differentiate difPeakWavey
//	WaveStats/Q difPeakWavey
//	Variable autoPeakLocation = V_minLoc
//	Variable locP = x2pnt(tempPeakWavey, autoPeakLocation)
//	
//	FindLevel/Q/R=[locP,] difPeakWavey,0
//	Variable xr= V_LevelX
//	FindLevel/Q/R=[locP,0] difPeakWavey,0		// note search is from right to left
//	Variable xl= V_LevelX
//	Variable baseline = (tempPeakWavey(xr) + tempPeakWavey(xl))/2
//	Variable height = 2*(tempPeakWavey(autoPeakLocation) - baseline)
//	
//	tempAutoPickInfo = {autoPeakLocation, xr-xl, height, autoPeakLocation-xl, xr-autoPeakLocation}
//end

Function MPF2_DoFitButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	STRUCT MPFitInfoStruct MPStruct
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	DFREF setDFR = $DFpath
	
	Wave/Z wpi = setDFR:W_AutoPeakInfo
	if (!WaveExists(wpi))
		DoAlert 0, "There are no peaks to fit."
		return -1
	endif

	SVAR YWvName = setDFR:YWvName
	SVAR XWvName = setDFR:XWvName
	Wave MPStruct.yWave = $YWvName
	Wave/Z MPStruct.xWave = $XWvName
	SVAR gname = setDFR:GraphName
	String listPanelName = gname+"#MultiPeak2Panel#P1"
	
	Wave/Z MPStruct.weightWave = $PopupWS_GetSelectionFullPath( gname+"#MultiPeak2Panel#P3", "MPF2_SelectWeightWave")
	Wave/Z MPStruct.maskWave = $PopupWS_GetSelectionFullPath( gname+"#MultiPeak2Panel#P3", "MPF2_SelectMaskWave")

	DFREF saveDFR = GetDataFolderDFR()

	//// do a check on the Use Graph Cursors checkbox to determine xPointRangeBegin&End
	NVAR XPointRangeBegin = setDFR:XPointRangeBegin
	NVAR XPointRangeEnd = setDFR:XPointRangeEnd
	if (MPF2_UseCursorsIsChecked(gname))			// use cursors
		MPStruct.XPointRangeBegin = XPointRangeBegin
		MPStruct.XPointRangeEnd = XPointRangeEnd
	else					// don't use cursors - use visible graph range size
		Variable RangeBegin, RangeEnd, RangeReversed
		MPF2_SetDataPointRange(gname, MPStruct.yWave, MPStruct.xWave, RangeBegin, RangeEnd, RangeReversed)
		MPStruct.XPointRangeBegin = RangeBegin
		MPStruct.XPointRangeEnd = RangeEnd
		XPointRangeBegin = RangeBegin	// NH 4/12/16: XPointRangeBegin and XPointRangeBegin are used in MPF2_AddFitCurveToGraph()
		XPointRangeEnd	= RangeEnd 		//		User showed a case where the XPointRangeEnd was not the end, but there were not cursors active.
										//		Not sure how he did it, but this will fix it for the next time "Do Fit" is pressed
	endif
	
	Variable i
	Variable peakNumber
	
	
	NVAR/Z IgnoreOoR = setDFR:IgnoreOutOfRangePeaks			// ST 2.48: load setting for out-of-range peaks
	if (!NVAR_Exists(IgnoreOoR))
		Variable/G setDFR:IgnoreOutOfRangePeaks = 0
		NVAR IgnoreOoR = setDFR:IgnoreOutOfRangePeaks
	endif
	String OutOfRangepeakList = MPF2_FindPeaksOutOfRange(setNumber, XPointRangeBegin, XPointRangeEnd)
	if (strlen(OutOfRangepeakList) > 0 && !IgnoreOoR)		// ST 2.48: ask what to do with out-of-range peaks
		String DeleteYesOrNo, DontAskAgain
		String PromptHelpText = "Peaks outside the fit range often lead to runaway coefficients which result in numerical errors during the fit. You may apply constraints or hold coefficients for such peaks to prevent unreasonable coefficient values."
		Prompt DeleteYesOrNo,"The fit may fail with out-of-range peaks.\rDo you want to delete them?",popup,"Yes, delete all out-of-range peaks;No, leave out-of-range peaks alone;"
		Prompt DontAskAgain,"Save your coice:",popup,"Ask again next time;Don't bother me again;"
		DoPrompt/Help=PromptHelpText "There are peaks outside the fit range!",DeleteYesOrNo,DontAskAgain
		if (V_Flag) // cancel
			return 0
		endif
		
		if (StringMatch(DeleteYesOrNo,"Yes,*"))				// 'delete peaks' choice
			Variable peaksToDelete = ItemsInList(OutOfRangepeakList)
			MPF2_RemoveAllPeaksFromGraph(gname)
			for (i = peaksToDelete-1; i >= 0 ; i -= 1)
				peakNumber = str2num(StringFromList(i, OutOfRangepeakList))
				MPF2_DeletePeakInfo(setNumber, peakNumber)
			endfor
			Wave YData = $YWvName
			Wave/Z XData = $XWvName
			NVAR displayPeaksFullWidth = setDFR:displayPeaksFullWidth
			MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
			MPF2_AddFitCurveToGraph(setNumber, wpi, YData, XData, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
		endif
		
		if (StringMatch(DontAskAgain,"Don't*"))				// don't-ask-again choice
			IgnoreOoR = 1
		endif
	endif
	
	MPStruct.NPeaks = DimSize(wpi, 0)						// ST 2.48: make sure to count peaks after some may have been deleted
	if (MPStruct.NPeaks == 0)								// ST: 200906 - no peaks to fit => abort
		return 0
	endif
	
	NVAR MPF2_FitCurvePoints = setDFR:MPF2_FitCurvePoints
	MPStruct.FitCurvePoints = MPF2_FitCurvePoints

	// JW 180320 After the fit, this will hold a copy of MPStruct.FuncListString, which is the actual
	// list of functions, coefficient waves, etc., passed to FuncFit via {string=MPstruct.FuncListString}.
	// It turns out to have potential use, so we will preserve this. Nobody should mess with it.
	String/G setDFR:FuncListString=""
	SVAR FuncListString = setDFR:FuncListString
	
	Variable nBLParams
	String ParamNameList
	String pwname
	
	String OneHoldString = ""
	Wave/T HoldStrings = setDFR:HoldStrings
	
	Variable BaselineRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", "Baseline")
	String baselineStr = WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, BaselineRow)
	MPStruct.ListOfFunctions = MPF2_PeakOrBLTypeFromListString(baselineStr)+";"
	Variable doBaseLine = CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0
	MPStruct.ListOfCWaveNames = "Baseline Coefs;"			// if baseline type is "None", this wave probably doesn't exist, but it doesn't matter because it will be ignored
	if (doBaseLine)
		MPStruct.ListOfHoldStrings = MPF2_HoldStringForPeakListItem("Baseline", DFpath, listPanelName)+";"
	else
		MPStruct.ListOfHoldStrings = ";"
	endif
	
	for (i = 0; i < MPStruct.NPeaks; i += 1)
		MPStruct.ListOfCWaveNames += "Peak "+num2istr(i)+" Coefs;"
		String peakItem = "Peak "+num2istr(i)
		Variable theRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", peakItem)
		String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, theRow) )
		MPStruct.ListOfFunctions += PeakTypeName+";"
		MPStruct.ListOfHoldStrings += MPF2_HoldStringForPeakListItem(peakItem, DFpath, listPanelName)+";"
	endfor

	//// Check inter-peak constraints ////
	Variable constraintsShowing = NumVarOrDefault(DFPath+":MPF2ConstraintsShowing", 0)
	if (constraintsShowing)
		Variable wasError
		Wave/Z /T MPStruct.constraints = getGlobalConstraintsWave(setNumber, 1, wasError)		// ST 2.48: added /Z for null wave return
		if (wasError)
			return 0
		endif

		Duplicate /O MPStruct.constraints, setDFR:MPF2_ConstraintsBackup
	else	
		KillWaves /Z setDFR:MPF2_ConstraintsBackup
	endif

	// Added to have a FuncFit ready constraints wave ready.  

	MPStruct.fitOptions = 4
	
	MPF2_SaveFunctionTypes(gname+"#MultiPeak2Panel")
	
//Variable etime = ticks	
	SetDataFolder setDFR
	MPF2_DoMPFit(MPStruct, DFPath+":")
	SetDataFolder saveDFR
//etime = ticks-etime
//print "Time for fit: ", etime/60," seconds"	
	FuncListString = MPStruct.FuncListString

	String QuitMessage = ""			// ST: push the display of the quit message to the end
	Variable doRestore = 0
	if (MPStruct.fitError || MPstruct.fitQuitReason)
		doRestore = 1
		if (MPStruct.fitError)
			QuitMessage = "Multipeak Fit failed: \r\r"+MPstruct.fitErrorMsg
		else
			switch (MPstruct.fitQuitReason)
				case 1:
					QuitMessage = "Multipeak fit exceeded the iteration limit. Click Do Fit again to continue."
					doRestore = 0
					break;
				case 2:
					QuitMessage = "Multipeak fit cancelled."
					break;
				case 3:
					QuitMessage = "Multipeak fit is not progressing. Chances are the fit is good."
					doRestore = 0
					break;
			endswitch
		endif	
		if (doRestore)
			MPF2_RestoreCoefWavesFromBackup(MPStruct.ListOfCWaveNames, DFPath)
		endif
	endif
	if (doRestore == 0)
		SetDataFolder setDFR
		Variable/G MPF2_FitDate = MPStruct.dateTimeOfFit
		Variable/G MPF2_FitPoints = MPStruct.fitPnts
		Variable/G MPF2_FitChiSq = MPStruct.chisq
		SetDataFolder saveDFR
		// Now update the list with the fit results
		MPF2_RefreshListCoefs(setNumber)		
		MPF2_RefreshPeakResults(setNumber)
		
		SVAR SavedFunctionTypes = setDFR:SavedFunctionTypes
		for (i = 0; i < MPStruct.NPeaks; i += 1)
			Wave coefs = $(DFPath+":'Peak "+num2istr(i)+" Coefs'")
			// wpi[i][0] = coefs[0]		// ST: 200719 - copy current peak location into wpi to keep 'Add or Edit Peaks' and the out-of-range finder up-to-date
			MPF2_UpdateWPIwaveFromPeakCoef(wpi, i, StringFromList(i+1,SavedFunctionTypes), coefs)	// ST: 211105 - use peak coefs to update the full WPI
		endfor
	endif

	NVAR negativePeaks = setDFR:negativePeaks
	NVAR displayPeaksFullWidth = setDFR:displayPeaksFullWidth
	MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
	MPF2_AddFitCurveToGraph(setNumber, wpi, MPStruct.yWave, MPStruct.xWave, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))

	MPF2_DisplayChiSqInfo(setNumber)// ST: 200906 - update the chi square text box here
	
	if (strlen(QuitMessage) > 0)
		DoUpdate/W=$gname			// ST: force graph update before displaying the quit message
		DoAlert 0, QuitMessage
	endif
End

Function MPF2_RevertToPreviousButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	switch( s.eventCode )
		case 2: // mouse up
			STRUCT MPFitInfoStruct MPStruct
			
			Variable setNumber = GetSetNumberFromWinName(s.win)
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
			SVAR YWvName = $(DFpath+":YWvName")
			SVAR XWvName = $(DFpath+":XWvName")
			SVAR gname = $(DFpath+":GraphName")
			SVAR peakTypes = $(DFpath+":SavedFunctionTypes")
			
			Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
			if (!WaveExists(wpi))													// ST 2.47: do nothing if there is no peak info yet (e.g., at start)
				DoAlert 0, "No peaks are available yet."
				return 0
			endif
			
			Variable NPeaks = DimSize(wpi, 0)
			
			Wave/Z LastBackup = $(DFPath+":"+"MPF2_CoefsBackup_"+num2str(NPeaks))	// ST: check if the number of backup waves matches the number of current peaks
			if (!WaveExists(LastBackup))
				DoAlert 0, "The number of peaks has changed since the last fit."
				return 0
			endif
			
			String ListOfCWaveNames = "Baseline Coefs;"		// if baseline type is "None", this wave probably doesn't exist, but it doesn't matter because it will be ignored
			
			Variable i
			for (i = 0; i < NPeaks; i += 1)
				ListOfCWaveNames += "Peak "+num2istr(i)+" Coefs;"
			endfor
			MPF2_RestoreCoefWavesFromBackup(ListOfCWaveNames, DFPath)
			NVAR displayPeaksFullWidth = $(DFpath+":displayPeaksFullWidth")
			MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
			Wave yWave = $YWvName
			Wave/Z xWave = $XWvName
			MPF2_AddFitCurveToGraph(setNumber, wpi, yWave, xWave, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
			MPF2_RefreshListCoefs(setNumber)
			
			for (i = 0; i < NPeaks; i += 1)
				Wave coefs = $(DFPath+":'Peak "+num2istr(i)+" Coefs'")
				// wpi[i][0] = coefs[0]															// ST: 200719 - copy previous peak location back into wpi (probably has changed after a fit)
				MPF2_UpdateWPIwaveFromPeakCoef(wpi, i, StringFromList(i+1,peakTypes), coefs)	// ST: 211105 - use peak coefs to update the full WPI
			endfor
			break
	endswitch

	return 0
End

//*******************************
// Results Display
//*******************************

static strconstant SMALL_DOWNARROW_STRING=" \Zr075\W523\M"		// large-to-small sorting
static strconstant SMALL_UPARROW_STRING=" \Zr075\W517\M"		// small-to-large sorting
static strconstant GRAY_TEXT_STRING="\K(39321,39321,39321)\k(39321,39321,39321)"

Function MPF2_ParamFuncTemplate(cw, sw, outWave)
	Wave cw, sw, outWave

end

Function MPF2_RefreshPeakResults(setNumber)
	Variable setNumber

	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	//SVAR/Z MPF2_ResultsPanelName = DFRpath:MPF2_ResultsPanelName
	String MPF2_ResultsPanelName = "MPF2_ResultsPanel"+"_"+num2str(setNumber)		// ST: the SVAR does not exist. Make a local string instead
	if ( WinType(MPF2_ResultsPanelName) == 7)
		MPF2_DoPeakResults(setNumber)
	endif
end

// PanelUnits
static constant resultsMinWidth=680 		// was 240, then 545
static constant resultsMinHeight=370 		// was 176, then 245, then 350
static constant resultsDefaultWidth=680		// was 620	// ST: increase the panel size for new layout
static constant resultsDefaultHeight=370	// was 350
static constant resultsListHeightDif=210	// was 200

static Function MPF2_AllSamePeakType(setNumber, theType)
	Variable setNumber
	String &theType
	
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)

	SVAR gname=DFRpath:GraphName
	Variable AllSamePeakType = 1
	String lastPeakType = ""
	Wave wpi = DFRpath:W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	
	Variable i
	String PeakTypeName = ""
	for (i = 0; i < npeaks; i += 1)
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		if (CmpStr(lastPeakType, PeakTypeName) != 0)
			if (strlen(lastPeakType) > 0)
				AllSamePeakType = 0
			endif
			lastPeakType = PeakTypeName
		endif
	endfor

	theType = PeakTypeName
	return AllSamePeakType
end

static Function/S MPF2_PrintNumberWithPrecision(Variable number, Variable sigma)
	Variable precision = 6
	if (numtype(sigma) == 0)
		precision = ceil(log(abs(number/sigma)))	// ST: 200904 - correct calculation for negative numbers and sigmas
		precision += 2								// ST: 200603 - make sure there are always enoguh digits for a nice overlap with the significant digit of the error
		precision = max(6, precision)
		precision = sigma == 0 ? 6 : precision		// ST: make sure the precision parameter is not inf
	endif
	String pnumber
	sprintf pnumber, "%.*g", precision, number
	
	return pnumber
end

Function MPF2_DoPeakResults(setNumber)
	Variable setNumber

	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)

	SVAR gname=DFRpath:GraphName
	NVAR/Z MPF2_FitDate = DFRpath:MPF2_FitDate		// if this variable doesn't exist, it means that a fit hasn't been done yet
	
	if (!NVAR_Exists(MPF2_FitDate))
		DoAlert 0, "No fit results are available yet."
		return -1
	endif
	
	Wave wpi = DFRpath:W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	
	Variable i, nParamsMax=0, nDerivedParamsMax = 4	// basic set is location, height, area and FWHM
	Variable nParams
	Variable j

	String PeakTypeName
	Variable AllSamePeakType = MPF2_AllSamePeakType(setNumber, PeakTypeName)		// don't actually use the type name returned by PeakTypeName here
	
	Variable reportBackground = 0, exportData = 0
	String MPF2_ResultsPanelName = "MPF2_ResultsPanel"+"_"+num2str(setNumber)	
	if (WinType(MPF2_ResultsPanelName) == 7)
		ControlInfo/W=$MPF2_ResultsPanelName MPFTResults_BackgroundCheck
		reportBackground = V_value
		ControlInfo/W=$MPF2_ResultsPanelName MPFGResults_ExportFitData				// ST: 200530 - save export checkbox state
		exportData = V_value
	endif
	
	Make/FREE/N=(npeaks)/O ndp
	for (i = 0; i < npeaks; i += 1)
		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		if (MPF2_FitDate < modDate(coefs ))
			DoAlert 0, "The coefficient wave for Peak "+num2istr(i)+" was modified after the last fit, so the results are out of date."
			return -1
		endif
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		String ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		nParamsMax = max(nParamsMax, ItemsInList(ParamNames))
		
		ParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
		ndp[i] = ItemsInList(ParamNames)
		nDerivedParamsMax = max(nDerivedParamsMax, ndp[i])
	endfor

	Variable numBLParams = 0
	String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
	if (CmpStr(BL_typename, "None") != 0)
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		numBLParams = ItemsInList(blinfo(BLFuncInfo_ParamNames))
		Wave/Z blw = DFRpath:'Baseline Coefs'
		if (MPF2_FitDate < modDate(blw ))
			DoAlert 0, "The coefficient wave for the baseline function was modified after the last fit, so the results are out of date."
			return -1
		endif
	endif
	
	Variable nCols = 2 + 2*nDerivedParamsMax + 2*nParamsMax + 2*reportBackground		// 2 for Peak Number and Peak Type name; 2* for value and uncertainty.

	// Waves for the listbox version
	Make/O/T/N=(npeaks, nCols) DFRpath:MPF2_ResultsListWave = ""
	WAVE/T MPF2_ResultsListWave = DFRpath:MPF2_ResultsListWave
	Make/O/T/N=(nCols) DFRpath:MPF2_ResultsListTitles = ""
	WAVE/T MPF2_ResultsListTitles = DFRpath:MPF2_ResultsListTitles
	MPF2_ResultsListTitles[0] = GRAY_TEXT_STRING+SMALL_UPARROW_STRING					// up arrow indicates sorting from small to large (like the Macintosh finder). Starts out sorted by peak number which is in column zero.
	MPF2_ResultsListTitles[1] = "Peak Type"
	MPF2_ResultsListTitles[2] = "Location"
	MPF2_ResultsListTitles[4] = "Amplitude"
	MPF2_ResultsListTitles[6] = "Area"
	MPF2_ResultsListTitles[8] = "FWHM"
	if (AllSamePeakType)
		// put the parameter names into the column titles because all the peaks are the same type
		theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak 0")
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		ParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
		nParams = ItemsInList(ParamNames)
		if (nParams > 4)
			for (i = 4; i < nParams; i += 1)
				MPF2_ResultsListTitles[2+2*i] = StringFromList(i, ParamNames)
			endfor
		endif
		ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		nParams = ItemsInList(ParamNames)
		for (i = 0; i < nParams; i += 1)
			MPF2_ResultsListTitles[2+2*nDerivedParamsMax + 2*i] = StringFromList(i, ParamNames)
		endfor
	else
		// we will be putting the other parameter names into the individual cells because the peak types are variable
		MPF2_ResultsListTitles[2+2*nDerivedParamsMax] = "Params"
	endif
	
	if (reportBackground)
		MPF2_ResultsListTitles[2 + 2*nDerivedParamsMax + 2*nParamsMax] = "Background at Loc."
		MPF2_ResultsListTitles[2 + 2*nDerivedParamsMax + 2*nParamsMax + 1] = "Height/Background"
	endif

	Variable firstColumn = 2+2*nDerivedParamsMax
	Variable totalParams = numBLParams
	Variable totalArea = 0
	Variable totalAreaVariance = 0
	
	// a wave of waves, each of which is nParams for the correspoding peak.  Values are 0|1 indicating if the coefficient is constrained
	Wave /Wave contraintsSetWave =  MPF2_isConstrainedWave(setNumber)
	
	for (i = 0; i < npeaks; i += 1)
		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		nParams = ItemsInList(ParamNames)

		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		Variable sigmaSequenceNumber = (numBLParams > 0) ? i+1 : i
		Wave sigma = DFRpath:$("W_sigma_"+num2istr(sigmaSequenceNumber))

		MPF2_ResultsListWave[i][0] = "Peak "+num2str(i)
		MPF2_ResultsListWave[i][1] = PeakTypeName
		
		String ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
		if (strlen(ParamFuncName) > 0)
			FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
			Wave M_covar = DFRpath:M_covar
			Make/O/D/N=(nParams, nParams)/FREE MPF2_TempCovar
			Make/O/D/N=(ndp[i],2)/FREE MPF2_TempParams=NaN			// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
			MPF2_TempCovar[][] = M_covar[totalParams+p][totalParams+q]
			paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
			
			String derivedParamNames = ""
			if (!AllSamePeakType)
				derivedParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
			endif

			// the first four parameters are always the same and the names are always in the column titles
			for (j = 0; j < 4; j += 1)
				Variable resultColumn = 2*j+2
				MPF2_ResultsListWave[i][resultColumn] = MPF2_PrintNumberWithPrecision(MPF2_TempParams[j][0], MPF2_TempParams[j][1])
				resultColumn += 1
				if (numtype(MPF2_TempParams[j][1]) == 2)
					MPF2_ResultsListWave[i][resultColumn] = "(Not Available)"
				else
					MPF2_ResultsListWave[i][resultColumn] = "+/- "+num2str(MPF2_TempParams[j][1])
				endif
			endfor
			
			totalArea += MPF2_TempParams[2][0]				// area is always in row 2
			totalAreaVariance += MPF2_TempParams[2][1]^2
			
			// if there are further derived parameters...
			for (; j < nDerivedParamsMax; j += 1)
				if (j < DimSize(MPF2_TempParams, 0))
					resultColumn = 2*j+2
					if (AllSamePeakType)
						MPF2_ResultsListWave[i][resultColumn] = ""
					else
						MPF2_ResultsListWave[i][resultColumn] = StringFromList(j, derivedParamNames)+"="
					endif
					MPF2_ResultsListWave[i][resultColumn] += MPF2_PrintNumberWithPrecision(MPF2_TempParams[j][0], MPF2_TempParams[j][1])
					resultColumn += 1
					if (numtype(MPF2_TempParams[j][1]) == 2)
						MPF2_ResultsListWave[i][resultColumn] = "(Not Available)"
					else
						MPF2_ResultsListWave[i][resultColumn] = "+/- "+num2str(MPF2_TempParams[j][1])
					endif
				endif
			endfor
		endif
	
		Wave coefConstrained = contraintsSetWave[i+1]  // constraintsSetWave includes baseline info at constraintsSetWave[0]
		Variable listColumn
		for (j = 0; j < nParams; j += 1)
			listColumn = firstColumn+2*j
			if (AllSamePeakType)
				MPF2_ResultsListWave[i][listColumn] = ""
			else
				MPF2_ResultsListWave[i][listColumn] = StringFromList(j, ParamNames)+"="
			endif
			MPF2_ResultsListWave[i][listColumn] += MPF2_PrintNumberWithPrecision(coefs[j], sigma[j])
			if (coefConstrained[j])
				MPF2_ResultsListWave[i][listColumn] += " (constrained)"
			endif
			listColumn += 1
			if (numtype(sigma[j]) == 2)
				MPF2_ResultsListWave[i][listColumn] = "(Not Available)"
			else
				MPF2_ResultsListWave[i][listColumn] = "+/- "+num2str(sigma[j])
			endif
		endfor	
		totalParams += nParams
		
		if (reportBackground)
			BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
			if (CmpStr(BL_typename, "None") != 0)
				String ParamNameList//, BL_FuncName
				FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
				string BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
				FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
				STRUCT MPF2_BLFitStruct BLStruct
				Wave BLStruct.cWave = DFRpath:'Baseline Coefs'
				BLStruct.x = MPF2_TempParams[0][0]
				SVAR YWvName = DFRpath:$"YWvName"
				SVAR XWvName = DFRpath:$"XWvName"
				Wave yw = $YWvName
				Wave/Z xw = $XWvName
				Wave BLStruct.yWave = yw		// ST 2.48: fill in y- and x-data pointers
				Wave/Z BLStruct.xWave = xw
				NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
				NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
				if (WaveExists(xw))
					BLStruct.xStart = xw[XPointRangeBegin]
					BLStruct.xEnd = xw[XPointRangeEnd]
				else
					BLStruct.xStart = pnt2x(yw, XPointRangeBegin)
					BLStruct.xEnd = pnt2x(yw, XPointRangeEnd)
				endif
				Variable bgValue = blFunc(BLStruct)
				MPF2_ResultsListWave[i][2 + 2*nDerivedParamsMax + 2*nParamsMax] = num2str(bgValue)
				MPF2_ResultsListWave[i][2 + 2*nDerivedParamsMax + 2*nParamsMax+1] = num2str(MPF2_TempParams[1][0]/bgValue)				
			endif
		endif
	endfor
	
	Variable left,top,right,bottom
 	
	Variable PointsToPanelUnits = ScreenResolution/PanelResolution("MPF2_ResultsPanelName")
	if (WinType(MPF2_ResultsPanelName) == 7)
		GetWindow $MPF2_ResultsPanelName wsize
		left = V_left*PointsToPanelUnits
		top = V_top*PointsToPanelUnits
		right = V_right*PointsToPanelUnits
		bottom = V_bottom*PointsToPanelUnits
		DoWindow/K $MPF2_ResultsPanelName
	else
		GetWindow $gname wsize
		left = V_left*PointsToPanelUnits + 50
		top = V_top*PointsToPanelUnits + 50
		right = left + resultsDefaultWidth
		bottom = top + resultsDefaultHeight
	endif
	
	Variable height = bottom - top
	
	NewPanel/K=1/N=$MPF2_ResultsPanelName/W=(left,top,right,bottom) as "Multipeak Fit Results"

	String/G DFRpath:MPF2_Results_DataWavesTitle
	SVAR MPF2_Results_DataWavesTitle = DFRpath:MPF2_Results_DataWavesTitle
	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	Wave/Z xw=$XWvName
	if (WaveExists(xw))
		MPF2_Results_DataWavesTitle = "\f01\K(65535,1,1)Y Wave:\f00\K(0,0,0)  "+YWvName		//\K(0,0,65535)xxx\K(52428,1,1)yyy\K(0,0,0)zzz
		MPF2_Results_DataWavesTitle += "\r\f01\K(65535,1,1)X Wave:\f00\K(0,0,0)  "+XWvName
	else
		MPF2_Results_DataWavesTitle = "\f01\K(52428,1,1)Data Wave:\f00\K(0,0,0)  "+YWvName
	endif
	TitleBox MPF2_ResultsYWave,pos={355,7},size={259,32}
	TitleBox MPF2_ResultsYWave,frame=1
	TitleBox MPF2_ResultsYWave,variable=MPF2_Results_DataWavesTitle,anchor= RC
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		TitleBox MPF2_ResultsYWave,fSize=9
	endif

	String/G DFRpath:MPF2_Results_DateTitle
	SVAR MPF2_Results_DateTitle = DFRpath:MPF2_Results_DateTitle
	NVAR MPF2_FitDate = DFRpath:MPF2_FitDate
	MPF2_Results_DateTitle = "Multipeak fit completed " + Secs2time(MPF2_FitDate, 0)
	MPF2_Results_DateTitle += " " + Secs2Date(MPF2_FitDate, 0)
	MPF2_Results_DateTitle += "\rMultipeak Fit Set "+num2str(setNumber)
	TitleBox MPF2_Results_DataTitle,pos={10,7},size={250,16},frame=1
	TitleBox MPF2_Results_DataTitle,variable=MPF2_Results_DateTitle
	if (CmpStr(IgorInfo(2), "Macintosh") == 0)
		TitleBox MPF2_Results_DataTitle,fSize=9
	endif

	String titlestr, totalAreaStr, totalAreaStDevStr						// ST: combine all output values into one TitleBox
	NVAR MPF2_FitChiSq = DFRpath:MPF2_FitChiSq
	sprintf titlestr, "Chi-square = %g",MPF2_FitChiSq
//	sprintf totalAreaStr, "Total Area = %g",totalArea
	sprintf totalAreaStDevStr, "+- %g",sqrt(totalAreaVariance)
	totalAreaStr = "Total Area = "
	totalAreaStr += MPF2_PrintNumberWithPrecision(totalArea, sqrt(totalAreaVariance)) + totalAreaStDevStr
	TitleBox MPF2_Results_Total,pos={540,220},size={102,12},title=titlestr + "    "+ totalAreaStr
	TitleBox MPF2_Results_Total,frame=0,anchor= RC

	// TitleBox MPF2_Results_ChiSquare,pos={280,220},size={102,12},title=titlestr
	// TitleBox MPF2_Results_ChiSquare,frame=0,anchor= RC
	// TitleBox MPF2_Results_TotalArea,pos={540,220},size={102,12},title=totalAreaStr
	// TitleBox MPF2_Results_TotalArea,frame=0,anchor= RC
	// TitleBox MPF2_Results_TotalAreaStdev,pos={500,282},size={102,12},title=totalAreaStDevStr
	// TitleBox MPF2_Results_TotalAreaStdev,frame=0,anchor= RC

	ListBox MPF2_FitResultsList,pos={1,54},size={right-left-2,height-resultsListHeightDif},proc=MPF2_resultsListProc,mode=5, selRow=-1
	ListBox MPF2_FitResultsList,listWave=MPF2_ResultsListWave,titleWave=MPF2_ResultsListTitles
	ListBox MPF2_FitResultsList,widths={50,72,100},userColumnResize=1,frame=2

	Button MPF2_TabDelimitedResultsButton		,pos={12,height-147},size={240,20},proc=MPF2_TabDelimitedResultsBtnProc,title="Standard Parameters, Tab-Delimited"		// ST: rearrange the buttons
	Button MPF2_ResultsDoNotebookButton			,pos={12,height-117},size={240,20},proc=MPF2_ResultsDoNotebookButtnProc,title="Report in Notebook"
	Button MPF2_ResultsTable_MakeTableButton	,pos={12,height-87}	,size={240,20},title="Table with Waves",proc=MPF2Results_TableButtonProc,userdata(setnumber)=num2str(setnumber)
	Button MPF2Results_GraphButton				,pos={12,height-57} ,size={240,20},proc=MPF2Results_GraphButtonProc,title="Results Graph..."
	Button MPF2_BaselineSubtracted				,pos={12,height-27}	,size={240,20},title="Baseline-Subtracted Data",proc=MPF2_BLSubtractedDataButtonProc

	Checkbox MPFGResults_ExportFitData			,pos={270,height-54}, fsize=12, title="Export Fit Data to Raw Data Folder when Creating Graph",value=exportData
	Checkbox MPFTResults_BackgroundCheck		,pos={270,height-114}, fsize=12, title="Include Background Info at Peak Position", proc=MPF2_reportBackground, value=reportBackground
	
	//Button MPF2Results_TableButton,pos={172, height-120},size={100.00,20.00},proc=MPF2_MakeResultsTablePanel,title="Table..."
	//Button MPF2Results_TableButton,userdata(setnumber)=num2str(setnumber)
	PopupMenu MPF2_ResultsTable_SortMenu,mode=1,bodywidth=100,value= #"\"Peak Number;Location;Height;Area;Width;\""
	PopupMenu MPF2_ResultsTable_SortMenu,pos={270,height-86},size={140,23},title="Sorting:"																				// ST: table output options directly in results panel
	PopupMenu MPF2_ResultsTable_Datafolder,mode=1,bodywidth=180,value= #"\"Current Data Folder;Multipeak Fit Set Folder;Root Folder;Subfolder in Current;Subfolder in Root;\""
	PopupMenu MPF2_ResultsTable_Datafolder,pos={460,height-86},size={220,23},title="Loc. for Waves:"

	Variable numPathElements = ItemsInList(YWvName, ":")
	String newWaveName = StringFromList(numPathElements-1, YWvName, ":")
	if (CmpStr(newWaveName[0], "'") == 0)
		newWaveName = newWaveName[1,strlen(newWaveName)-2]
	endif
	newWaveName = newWaveName[0, min(strlen(newWaveName), 25)]+"_BlSub"
	SetVariable MPF2_BLSubtractedWaveName,pos={275,height-27},size={415,19},bodyWidth=0,title="Wave Name for BL Subtracted Data:"
	SetVariable MPF2_BLSubtractedWaveName,fSize=12,value= _STR:newWaveName

	SetWindow $MPF2_ResultsPanelName, userdata(MPF2_DataSetNumber)=num2str(setnumber)
	SetWindow $MPF2_ResultsPanelName, hook(MPF2_ResultsResizeHook)=MPF2_ResultsResizeHook
	
	MPF2_ResultsEnforceMinSize(MPF2_ResultsPanelName)
	MPF2_ResultsMoveControls(MPF2_ResultsPanelName)		
end

Function MPF2_ShowInfoAsTableCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			String windowname = cba.win + "#T0"
			SetWindow $windowname, hide = cba.checked ? 0 : 1
			ListBox MPF2_FitResultsList, win=$(cba.win),disable=(cba.checked ? 1 : 0)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function MPF2_ResultsEnforceMinSize(win)
	String win
	
	if (strsearch(win, "#", 0) > 0)
		return 0		// JW 180724 Don't try to do this to a subwindow
	endif

	Variable PointsPerPanelUnit = PanelResolution(win)/ScreenResolution
	Variable minWidthPoints= resultsMinWidth * PointsPerPanelUnit
	Variable minHeightPoints= resultsMinHeight * PointsPerPanelUnit
#if IgorVersion() >= 7
	SetWindow $win sizeLimit={minWidthPoints, minHeightPoints, Inf, Inf}
#else
	GetWindow $win wsize	// points
	Variable widthPoints= V_right-V_left
	Variable heightPoints= V_bottom-V_top
	
	if( widthPoints < minWidthPoints-1 || heightPoints < minHeightPoints-1 )
		widthPoints = max(resultsMinWidth, widthPoints)
		heightPoints = max(resultsMinHeight, heightPoints)
		MoveWindow/W=$win V_left, V_top, V_left+widthPoints, V_top+heightPoints
	endif
#endif
End

Function MPF2_ResultsMoveControls(win)
	String win

	Variable vleft, vtop, vright, vbottom
	PanelCoordEdges(win, vleft, vtop, vright, vbottom)
	Variable width= vright-vleft
	Variable height= vbottom-vtop
	
	// re-size the listbox
	ListBox MPF2_FitResultsList,win=$win,size={width-2,height-resultsListHeightDif}
	// move the buttons
	//Button MPF2Results_TableButton,win=$win,pos={172, height-120}
	Button MPF2_TabDelimitedResultsButton	,win=$win,pos={12,height-147}	// ST: rearranged buttons
	Button MPF2_ResultsDoNotebookButton		,win=$win,pos={12,height-117}
	Button MPF2_ResultsTable_MakeTableButton,win=$win,pos={12,height-87}	// ST: table output button directly in results panel
	Button MPF2Results_GraphButton			,win=$win,pos={12,height-57}
	Button MPF2_BaselineSubtracted			,win=$win,pos={12,height-27}
	Checkbox MPFGResults_ExportFitData		,win=$win,pos={270,height-54}
	Checkbox MPFTResults_BackgroundCheck	,win=$win,pos={270,height-114}
	PopupMenu MPF2_ResultsTable_SortMenu	,win=$win,pos={270,height-86} ,size={140,23} ,bodywidth=100

	ControlInfo/W=$win MPF2_BaselineSubtracted
	// leave as much room to the right of the button as to the left
	// for the Wave Name for BL Subtracted Data control	
	Variable SVLeft= V_left + V_left + V_width + 5
	Variable margin=10
	Variable SVWidth = max(width-margin-SVLeft, 100)	// leave 10 panel units to the right of the control
	SetVariable MPF2_BLSubtractedWaveName, win=$win, pos={SVLeft, height-27}, size={SVWidth,0}, bodywidth=0
	PopupMenu MPF2_ResultsTable_Datafolder,win=$win, pos={SVLeft+210,height-86}, size={SVWidth-210,23}, bodywidth=SVWidth-250		// ST: table output options will resize too

	// Move the data waves readout
	TitleBox MPF2_ResultsYWave,win=$win,pos={width-margin,7},size={0,0},anchor=RT
	// Move the chi-square readout
	TitleBox MPF2_Results_Total,win=$win,pos={width-margin-5,height-150},size={0,0},anchor=RT
	//TitleBox MPF2_Results_ChiSquare,win=$win,pos={width-margin-5,height-150},size={0,0},anchor=RT
	//TitleBox MPF2_Results_TotalArea,win=$win,pos={width-margin-5,height-150},size={0,0},anchor=RT
	//TitleBox MPF2_Results_TotalAreaStdev,win=$win,pos={width-margin-5,height-47},size={0,0},anchor=RT
End

Function MPF2_ResultsResizeHook(s)
	STRUCT WMWinHookStruct &s

	if ( s.eventCode == 6)			// resize
		if (strsearch(s.winName, "#", 0) > 0)
			return 0
		endif
		String win= s.winName
		MPF2_ResultsEnforceMinSize(win)
		MPF2_ResultsMoveControls(win)
	endif
	return 0
end

Function MPF2_reportBackground(s) : CheckBoxControl
	STRUCT WMCheckboxAction &s

	if (s.eventCode == 2)			// mouse up
		MPF2_RefreshPeakResults(GetSetNumberFromWinName(s.win))
	endif
end

Function MPF2_PeakResultsButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)			// mouse-up in the control
		return 0
	endif
	
	MPF2_DoPeakResults(GetSetNumberFromWinName(s.win))
End

Function MPF2_resultsListProc(s)
	STRUCT WMListboxAction &s
	
	Variable i, nRows
	Variable retValue = 0
	
	if (s.eventCode == 1)			// mouse-down
		nRows = DimSize(s.listWave, 0)
		if (s.row < 0)				// click in title cell
			Make/N=(nRows)/T/O MPF2_TempListSortWave
			MPF2_TempListSortWave = s.listwave[p][s.col]
			Make/N=(nRows)/O MPF2_TempListIndexWave
			String CurrentTitle = s.titleWave[s.col]
			Variable StartOfArrowString = -1
			Variable doReverse = 0
			if (strsearch(CurrentTitle, SMALL_UPARROW_STRING, 0) >= 0)			// currently sorted small-to-large; use reverse sort
				doReverse = 1
				StartOfArrowString = strsearch(CurrentTitle, GRAY_TEXT_STRING, 0)
				CurrentTitle = CurrentTitle[0,StartOfArrowString-1] + GRAY_TEXT_STRING + SMALL_DOWNARROW_STRING
				s.titleWave[s.col] = CurrentTitle
			elseif (strsearch(CurrentTitle, SMALL_DOWNARROW_STRING, 0) >= 0)	// currently sorted large-to-small (reversed); use forward sort
				doReverse = 0
				StartOfArrowString = strsearch(CurrentTitle, GRAY_TEXT_STRING, 0)
				CurrentTitle = CurrentTitle[0,StartOfArrowString-1] + GRAY_TEXT_STRING + SMALL_UPARROW_STRING
				s.titleWave[s.col] = CurrentTitle
			else																// currently sorted by a different column; use forward sort, and find the current sort column in order to remove the sort arrow
				doReverse = 0
				Variable numCols = DimSize(s.listWave, 1)
				// search for current sort column and remove the sort-indicator arrow
				for (i = 0; i < numCols; i += 1)
					CurrentTitle = s.titleWave[i]
					StartOfArrowString = strsearch(CurrentTitle, GRAY_TEXT_STRING, 0)
					if (StartOfArrowString >= 0)
						CurrentTitle = CurrentTitle[0, StartOfArrowString-1]
						s.titleWave[i] = CurrentTitle
						break;
					endif
				endfor
				// set the up-arrow on the new sort column
				s.titleWave[s.col] = (s.titleWave[s.col]) + GRAY_TEXT_STRING + SMALL_UPARROW_STRING
			endif
			// we now have a sort index, do the sort
			if (doReverse)
				MakeIndex/R/A MPF2_TempListSortWave, MPF2_TempListIndexWave
			else
				MakeIndex/A MPF2_TempListSortWave, MPF2_TempListIndexWave
			endif
			Duplicate/O/T s.listWave, MPF2_TempListSortWave
			s.listWave[][] = MPF2_TempListSortWave[MPF2_TempListIndexWave[p]][q]
			KillWaves MPF2_TempListSortWave, MPF2_TempListIndexWave
		else
			if (s.eventMod & 16)		// ST: add right-click menu to directly copy values
				retValue = 1
				PopupContextualMenu "(Copy to Clipboard:;-;Copy This Item As Text;Copy This Item As Number;Copy Whole Column As Text;Copy Whole Column As Numbers;"
				if (V_Flag > 0 && s.row < nRows)
					String output = ""
					Switch (V_flag)		// ST: 200820 - extend the options for copying text
						case 3:
							PutScrapText s.listWave[s.row][s.col]
							break
						case 4:
							PutScrapText MPF2_GetNumberFromResultsString(s.listWave[s.row][s.col])
							break
						case 5:
							for (i = 0; i<DimSize(s.listWave,0); i+=1)
								output += s.listWave[i][s.col] + "\r\n"
							endfor
							PutScrapText output
							break
						case 6:
							for (i = 0; i<DimSize(s.listWave,0); i+=1)
								output += MPF2_GetNumberFromResultsString(s.listWave[i][s.col]) + "\r\n"
							endfor
							PutScrapText output
							break
					EndSwitch
				endif
			endif
		endif
	endif
	return retValue
end

Static Function/S MPF2_GetNumberFromResultsString(String input)		// ST: 200820 - cleans up strings of any non-numeric characters
	input = ReplaceString("+/-", input, "")
	input = ReplaceString("(constrained)", input, "")				// ST: 210813 - remove these words as well, since they contain an 'e'
	input = ReplaceString("(Not Available)", input, "")
	Variable equalPos = strsearch(input,"=",0)						// ST: 210813 - remove any preceding words like 'Pos='
	input = input[equalPos+1,inf]
	
	String output = ""
	Variable i
	do
		String char = input[i]
		if (strlen(char) == 0)
			break
		endif
		if (GrepString(char,"[+-.0-9e]"))							// ST: 201009 - make sure exponential prefix is honored as well
			output += char
		endif
		i+= 1
	while(1)
	if(strlen(output) == 0)
		output = "NaN"
	endif
	return output
End

Function MPF2_ResultsDoNotebookButtnProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname = DFRpath:GraphName
	
	String nb = "MultipeakSet"+num2str(setNumber)+"Report"
	if (WinType(nb) == 5)
		DoWindow/K $nb
	endif
	NewNotebook/F=1/K=1/N=$nb as "Multipeak Fit Report for Data Set "+num2str(setNumber)
	String/G DFRpath:MPF2_ReportName = nb
	Notebook $nb showRuler=0
	
	Wave wpi = DFRpath:W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	
	Variable i, nParamsMax=0
	Variable j
	Variable theRow
	String PeakTypeName
	String ParamNames
	String DerivedParamNames
	
	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	SVAR WeightWaveName = DFRpath:MPF2WeightWaveName
	SVAR MaskWaveName = DFRpath:MPF2MaskWaveName
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	Wave/Z wt = $WeightWaveName
	Wave/Z mask = $MaskWaveName
	Wave/Z constraints = DFRpath:constraints
	NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
	NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
	SVAR/Z UserNotes = DFRpath:UserNotes					// ST: 200820 - add support for set notes
	NVAR MPF2_FitDate = DFRpath:MPF2_FitDate
	NVAR MPF2_FitPoints = DFRpath:MPF2_FitPoints
	NVAR MPF2_FitChiSq = DFRpath:MPF2_FitChiSq

	String MPF2_ResultsPanelName = "MPF2_ResultsPanel"+"_"+num2str(setNumber)	
	ControlInfo/W=$MPF2_ResultsPanelName MPFTResults_BackgroundCheck
	Variable reportBackground = V_value

	Notebook $nb newRuler=PeakHeaderRuler, justification=0, margins={0,0,504}, spacing={0,0,0}, tabs={}, rulerDefaults={"Geneva",10,1,(0,0,0)}
	Notebook $nb newRuler=PeakParamsRuler, justification=0, margins={0,0,504}, spacing={0,0,0}, tabs={36,126+3*8192,205+1*8192,234+3*8192,305,394}, rulerDefaults={"Geneva",10,0,(0,0,0)}
	
	if (SVAR_Exists(UserNotes) && strlen(UserNotes) > 0)
		Notebook $nb ruler=PeakHeaderRuler, text="Set notes: "+UserNotes+"\r"
	endif
	
	Notebook $nb ruler=PeakParamsRuler, text="Fit completed: "+Secs2Time(MPF2_FitDate, 0)+" "+Secs2Date(MPF2_FitDate, 1)+"\r"
	Notebook $nb ruler=PeakParamsRuler, text="Y data wave: "+GetWavesDataFolder(yw, 2)
	if ( (XPointRangeBegin != 0) || (XPointRangeEnd != numpnts(yw)-1) )
		Notebook $nb ruler=PeakParamsRuler, text="["+num2str(XPointRangeBegin)+", "+num2str(XPointRangeEnd)+"]"
	endif
	Notebook $nb text="\r"
	
	if (WaveExists(xw))
		Notebook $nb ruler=PeakParamsRuler, text="X data wave: "+GetWavesDataFolder(xw, 2)+"\r"
	endif
	
	if (WaveExists(wt))
		Notebook $nb ruler=PeakParamsRuler, text="Weight wave: "+GetWavesDataFolder(wt, 2)+"\r"
	endif
	
	if (WaveExists(mask))
		Notebook $nb ruler=PeakParamsRuler, text="Mask wave: "+GetWavesDataFolder(mask, 2)+"\r"
	endif
	
	Notebook $nb ruler=PeakParamsRuler, text="Chi square: "+num2str(MPF2_FitChiSq)+"\r"
	Notebook $nb ruler=PeakParamsRuler, text="Total fitted points: "+num2str(MPF2_FitPoints)+"\r"

	Notebook $nb ruler=PeakParamsRuler, text="Multipeak fit version: "+MPF2_VERSIONSTRING+"\r"

	GetSelection notebook, $nb, 1
	Variable paragraphNumberforTotalArea = V_startParagraph

	Notebook $nb text="\r"
		
	Variable numBLParams = 0
	String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
	if (CmpStr(BL_typename, "None") != 0)
		String ParamNameList
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		ParamNameList = blinfo(BLFuncInfo_ParamNames)
		numBLParams = ItemsInList(ParamNameList)

		Notebook $nb ruler=PeakHeaderRuler,fstyle=-1,text="Baseline\tType: "+BL_typename
		Notebook $nb text="\r\r"
		
		Notebook $nb ruler=PeakParamsRuler
		Notebook $nb fStyle=0
		
		Wave blw = DFRpath:'Baseline Coefs'
		Wave ble = DFRpath:W_sigma_0
		for (i = 0; i < numBLParams; i += 1)
			Notebook $nb text= "\t"+StringFromList(i, ParamNameList)+" = \t"+MPF2_PrintNumberWithPrecision(blw[i], ble[i])+"\t +/- \t"+num2str(ble[i])
			String blConstraint = getPeakConstraints(setNumber, 0, i, "Min")
			if (strlen(blConstraint))
				Notebook $nb text="\tMin: "+blConstraint
			endif
			blConstraint = getPeakConstraints(setNumber, 0, i, "Max")
			if (strlen(blConstraint))
				Notebook $nb text="\tMax: "+blConstraint
			endif
			Notebook $nb text="\r"
		endfor
	endif
	
	Notebook $nb text="\r"

	Wave/T MPF2_ResultsListWave = DFRpath:MPF2_ResultsListWave

	Variable firstColumn = 8
	Variable totalParams = numBLParams
	Variable totalArea = 0
	Variable totalAreaVariance = 0
	
	NVAR/Z doEqualWidths = DFRpath:DoEqualWidthsContraint
	NVAR/Z doPairedLocations = DFRpath:DoPairedLocationConstraint
	NVAR/Z pairedLocationSep = DFRpath:PairedLocationDistance

	for (i = 0; i < npeaks; i += 1)
		Variable Peak_number
		sscanf MPF2_ResultsListWave[i][0], "Peak %d", Peak_number
		
		Wave coefs = DFRpath:$("Peak "+num2istr(Peak_number)+" Coefs")
		theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(Peak_number))
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		Variable nParams = ItemsInList(ParamNames)
		DerivedParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)

		Wave coefs = DFRpath:$("Peak "+num2istr(Peak_number)+" Coefs")
		Variable sigmaSequenceNumber = (numBLParams > 0) ? Peak_number+1 : Peak_number
		Wave sigma = DFRpath:$("W_sigma_"+num2istr(sigmaSequenceNumber))

		Notebook $nb ruler=PeakHeaderRuler,fstyle=-1,text="Peak "+num2str(Peak_number)+"\t"
		Notebook $nb text="Type: "+PeakTypeName
		if (NVAR_Exists(doPairedLocations) && doPairedLocations && mod(i,2)==1)
			Notebook $nb text="; Location constrained to Peak "+num2str(i-1) + " + " + num2str(pairedLocationSep)
		endif
		Notebook $nb text="\r\r"
		Notebook $nb fStyle=0
		
		Notebook $nb ruler=PeakParamsRuler
		String ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
		if (strlen(ParamFuncName) > 0)
			FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
			Wave M_covar = DFRpath:M_covar
			Make/O/D/N=(nParams, nParams)/FREE MPF2_TempCovar
			Variable nDerivedParams = ItemsInList(DerivedParamNames)
			Make/O/D/N=(nDerivedParams,2)/FREE MPF2_TempParams=NaN			// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
			MPF2_TempCovar[][] = M_covar[totalParams+p][totalParams+q]
			paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
			for (j = 0; j < nDerivedParams; j += 1)
				Notebook $nb text="\t" + StringFromList(j, DerivedParamNames) + " = \t"+MPF2_PrintNumberWithPrecision(MPF2_TempParams[j][0], MPF2_TempParams[j][1])
				if (numtype(MPF2_TempParams[j][1]) != 2)
					Notebook $nb text= "\t +/- \t" + num2str(MPF2_TempParams[j][1])
				endif
				Notebook $nb text="\r"
			endfor
		endif
		
		totalArea += MPF2_TempParams[2][0]				// area is always in row 2
		totalAreaVariance += MPF2_TempParams[2][1]^2
			
		Notebook $nb text="\r"
		Notebook  $nb text="\tFit function parameters\r"
		for (j = 0; j < nParams; j += 1)
			String pname = StringFromList(j, ParamNames)
			Notebook  $nb text= "\t"+pname+" =\t"+MPF2_PrintNumberWithPrecision(coefs[j], sigma[j]) + "\t+/-\t"+num2str(sigma[j])
			String paramConstraint = getPeakConstraints(setNumber, i+1, j, "Min")
			if (strlen(paramConstraint))
				Notebook $nb text="\tMin: "+paramConstraint
			endif
			paramConstraint = getPeakConstraints(setNumber, i+1, j, "Max")
			if (strlen(paramConstraint))
				Notebook $nb text="\tMax: "+paramConstraint
			endif
			Notebook  $nb text="\r"
		endfor

		if (reportBackground)
			Notebook $nb text="\r"
			Notebook  $nb text="\tBackground Info\r"	// ST: fixed typo

			BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
			if (CmpStr(BL_typename, "None") != 0)
				FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
				string BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
				FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
				STRUCT MPF2_BLFitStruct BLStruct
				Wave BLStruct.cWave = DFRpath:'Baseline Coefs'
				BLStruct.x = MPF2_TempParams[0][0]
				SVAR YWvName = DFRpath:YWvName
				SVAR XWvName = DFRpath:XWvName
				Wave yw = $YWvName
				Wave/Z xw = $XWvName
				Wave BLStruct.yWave = yw				// ST 2.48: fill in y- and x-data pointers
				Wave/Z BLStruct.xWave = xw
				NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
				NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
				if (WaveExists(xw))
					BLStruct.xStart = xw[XPointRangeBegin]
					BLStruct.xEnd = xw[XPointRangeEnd]
				else
					BLStruct.xStart = pnt2x(yw, XPointRangeBegin)
					BLStruct.xEnd = pnt2x(yw, XPointRangeEnd)
				endif
				Variable bgValue = blFunc(BLStruct)
				Notebook  $nb text="\tBackground at peak location =\t"+num2str(bgValue)+"\r"
				Notebook  $nb text="\tRatio peak height to background =\t"+num2str(MPF2_TempParams[1][0]/bgValue)+"\r"
			endif
		endif
		
		totalParams += nParams
		Notebook $nb text="\r"
	endfor
	
	///// Print global constraints /////	
	SVAR /Z interPeakString = DFRpath:interPeakConstraints
	if (SVAR_exists(interPeakString) && strlen(interPeakString))
		Variable isValid = MPF2_ValidateConstraint(setNumber, gname+"#MultiPeak2Panel", interPeakString, doErrPanel=0)		// ST: validate constraints before writing to notebook
		if (isValid)
			String spelledOutIPString = interPeakString
			
			Notebook $nb fstyle=1,text="Inter Peak Constraints:\r\r"
			Notebook $nb fstyle=0,ruler=PeakParamsRuler//, text=interPeakString
			
			String peakConstraints = MPF2_interPeakToStringList(setNumber, interPeakString)
			Variable nVals = ItemsInList(peakConstraints)
			
			for (i=0; i<nVals; i+=1)
				String keyVal, key, val
				keyVal = StringFromList(i, peakConstraints)
				key = StringFromList(0, keyVal, ":")
				val = StringFromList(1, keyVal, ":")
				spelledOutIPString = ReplaceString(key, spelledOutIPString, " ["+val+"] ")
			endfor
			
			nVals = ItemsInList(spelledOutIPString)
			for (i=0; i<nVals; i+=1)
				Notebook $nb text="\t"+StringFromList(i, spelledOutIPString)+"\r"
			endfor
		endif
	endif
	if (NVAR_Exists(doEqualWidths) && doEqualWidths)
		Notebook $nb text="\tAll peak widths constrained to be equal\r"
	endif
	if (NVAR_Exists(doPairedLocations) && doPairedLocations)
		Notebook $nb text="\tPeak pair locations constrained to be separated by "+num2str(pairedLocationSep)+"\r"
	endif
	
	KillWaves/Z MPF2_TempCovar, MPF2_TempParams
	
	Notebook $nb, selection={(paragraphNumberforTotalArea, 0), (paragraphNumberforTotalArea, 0)}
	Notebook $nb, text = "Total Peak Area = "+num2str(totalArea)+" +/- "+num2str(sqrt(totalAreaVariance))+"\r"
	
	Notebook $nb selection={startOfFile,startOfFile},findText={"", 1}
End

Function MPF2_TabDelimitedResultsBtnProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname = DFRpath:GraphName
	
	String nb = "MultipeakSet"+num2str(setNumber)+"_TD"
	if (WinType(nb) == 5)
		DoWindow/K $nb
	endif
	NewNotebook/F=0/K=1/N=$nb
	String/G DFRpath:MPF2_TDReportName = nb
	Notebook $nb defaultTab=108
	
	Wave wpi = DFRpath:W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	
	Variable i, nParamsMax=0
	Variable j
	Variable theRow
	String PeakTypeName
	String ParamNames
	
	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	NVAR XPointRangeBgn	= DFRpath:XPointRangeBegin
	NVAR XPointRangeEnd	= DFRpath:XPointRangeEnd
	SVAR/Z UserNotes	= DFRpath:UserNotes				// ST: 200820 - add support for set notes
	NVAR MPF2_FitDate	= DFRpath:MPF2_FitDate
	NVAR MPF2_FitPoints	= DFRpath:MPF2_FitPoints
	NVAR MPF2_FitChiSq	= DFRpath:MPF2_FitChiSq

	if (SVAR_Exists(UserNotes) && strlen(UserNotes) > 0)
		Notebook $nb text="Set notes: "+UserNotes+"\r"
	endif

	Notebook $nb text="Fit completed "+Secs2Time(MPF2_FitDate, 0)+" "+Secs2Date(MPF2_FitDate, 1)+"\r"
	Notebook $nb text="Y data wave: "+GetWavesDataFolder(yw, 2)
	if ( (XPointRangeBgn != 0) || (XPointRangeEnd != numpnts(yw)-1) )
		Notebook $nb text="["+num2str(XPointRangeBgn)+", "+num2str(XPointRangeEnd)+"]"
	endif
	Notebook $nb text="\r"
	
	if (WaveExists(xw))
		Notebook $nb text="X data wave: "+GetWavesDataFolder(xw, 2)+"\r"
	endif
	
	Notebook $nb text="Chi square: "+num2str(MPF2_FitChiSq)+"\r"
	Notebook $nb text="Total fitted points: "+num2str(MPF2_FitPoints)+"\r"

	Notebook $nb text="Multipeak fit version "+MPF2_VERSIONSTRING+"\r"

	GetSelection notebook, $nb, 1
	Variable paragraphNumberforTotalArea = V_startParagraph

	Notebook $nb text="\r"
	
	Wave/T MPF2_ResultsListWave = DFRpath:MPF2_ResultsListWave

	Notebook $nb text="Type\tLocation\tLocSigma\tAmplitude\tAmpSigma\tArea\tAreaSigma\tFWHM\tFWHMSigma\r"

	Variable numBLParams = 0
	String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
	if (CmpStr(BL_typename, "None") != 0)
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		numBLParams = ItemsInList(blinfo(BLFuncInfo_ParamNames))
	endif
	
	Variable totalParams = numBLParams
	String OneParamText
	String oneLine
	
	Variable totalArea = 0
	Variable totalAreaVariance = 0

	for (i = 0; i < npeaks; i += 1)
		oneLine = ""
		
		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		oneLine = PeakTypeName
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		Variable nParams = ItemsInList(ParamNames)

		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		Variable sigmaSequenceNumber = (numBLParams > 0) ? i+1 : i
		Wave sigma = DFRpath:$("W_sigma_"+num2istr(sigmaSequenceNumber))


		MPF2_ResultsListWave[i][0] = "Peak "+num2str(i)
		MPF2_ResultsListWave[i][1] = PeakTypeName
		
		String ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
		if (strlen(ParamFuncName) > 0)
			String derivedParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
			Variable numDerivedParams = ItemsInList(derivedParamNames)
			FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
			Wave M_covar = DFRpath:M_covar
			Make/O/D/N=(nParams, nParams)/FREE MPF2_TempCovar
			Make/O/D/N=(numDerivedParams, 2)/FREE MPF2_TempParams=NaN		// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
			MPF2_TempCovar[][] = M_covar[totalParams+p][totalParams+q]
			paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
			
			totalArea += MPF2_TempParams[2][0]								// area is always in row 2
			totalAreaVariance += MPF2_TempParams[2][1]^2
			
			// the first four parameters are always the same and the names are always in the column titles
			for (j = 0; j < 4; j += 1)
				sprintf OneParamText, "\t%g\t%g", MPF2_TempParams[j][0], MPF2_TempParams[j][1]
				oneLine += OneParamText
			endfor
			Notebook $nb text=oneLine+"\r"
		endif
	
		totalParams += nParams
	endfor
	
	Notebook $nb, selection={(paragraphNumberforTotalArea, 0), (paragraphNumberforTotalArea, 0)}
	Notebook $nb, text = "Total Peak Area = "+num2str(totalArea)+" +/- "+num2str(sqrt(totalAreaVariance))+"\r"
End

Function MPF2_BLSubtractedDataButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	ControlInfo/W=$(s.win) MPF2_BLSubtractedWaveName
	String newWaveName = S_value
	
	if (strlen(newWaveName) > 31)
		DoAlert 0, "The proposed wave name, \""+newWaveName+"\", contains too many characters ("+num2str(strlen(newWaveName))+"). The limit is 31 characters."
		return 0
	endif
	if (CheckName(newWaveName, 1) != 0)		// ST: check if the name contains illegal characters, if not ask for overwrite.
		if (Exists(newWaveName) == 1)
			DoAlert 1, "The wave with the name, \""+newWaveName+"\", already exists. Do you want to overwrite the data?"
			if (V_flag != 1)
				return 0
			endif
		else
			DoAlert 0, "The proposed wave name, \""+newWaveName+"\", contains illegal characters or is a reserved expression."
			return 0
		endif
	endif
	
	MPF2_BLSubtractedData(setNumber, newWaveName)
	
	return 0
end

Function MPF2_BLSubtractedData(setNumber, newWaveName)
	Variable setNumber
	String newWaveName

	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname = DFRpath:GraphName

	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	Wave yw = $YWvName
	Wave/Z xw=$XWvName
	NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
	NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
	Variable xpstart = min(XPointRangeBegin, XPointRangeEnd)
	Variable xpend = max(XPointRangeBegin, XPointRangeEnd)
	
	Duplicate/O/R=[xpstart, xpend]  yw, $newWaveName/WAVE=newW

	String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
	if (CmpStr(BL_typename, "None") != 0)
		String ParamNameList//, BL_FuncName
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		string BL_FuncName = blinfo(BLFuncInfo_BaselineFName)
		FUNCREF MPF2_BaselineFunctionTemplate blFunc = $BL_FuncName
		
		STRUCT MPF2_BLFitStruct BLStruct
		Wave BLStruct.cWave = DFRpath:'Baseline Coefs'
		Wave BLStruct.yWave = yw		// ST 2.48: fill in y- and x-data pointers
		Wave/Z BLStruct.xWave = xw
		if (WaveExists(xw))
			BLStruct.xStart = xw[XPointRangeBegin]
			BLStruct.xEnd = xw[XPointRangeEnd]
		else
			BLStruct.xStart = pnt2x(yw, XPointRangeBegin)
			BLStruct.xEnd = pnt2x(yw, XPointRangeEnd)
		endif
		Variable i, endp
		endp = xpend - xpstart + 1
		for (i = 0; i < endp; i += 1)
			Variable point = i + xpstart
			if (WaveExists(xw))
				BLStruct.x = xw[point]
			else
				BLStruct.x = pnt2x(yw, point)
			endif
			newW[i] -= blFunc(BLStruct)
		endfor
	else
		DoAlert 0,"No baseline function was used in fitting this data set"
	endif
end

Function MPF2Results_GraphButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)				// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	
	MPF2_ResultsGraphPanel(setNumber)
	
	return 0
End

Function MPF2_ResultsGraphPanel(setNumber)
	Variable setNumber
	String panelName = "MakeResultsGraph_Set_"+num2str(setNumber)

	if (WinType(panelName) == 7)		// ST: 200529 - make sure this is not called twice
		DoWindow/F $panelName
		return 0
	endif
	
	NewPanel /FLT=1 /K=1 /W=(512,538,775,893) as "Create Results Graph for Set "+num2str(setNumber)		// ST: add proper panel title
	RenameWindow $S_name, $panelName

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	String saveDF = GetDataFolder(1)
	Variable dummy
	SetDataFolder DFpath
		dummy = NumVarOrDefault(DFpath+":ResultGraph_IncludeData", 1)
		Variable/G ResultGraph_IncludeData = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_IncludeFitCurve", 1)
		Variable/G ResultGraph_IncludeFitCurve = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_IncludePeaks", 1)
		Variable/G ResultGraph_IncludePeaks = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_IncludeResidual", 1)
		Variable/G ResultGraph_IncludeResidual = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_IncludeBackground", 0)
		Variable/G ResultGraph_IncludeBackground = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_PeaksOnDataAxis", 0)
		Variable/G ResultGraph_PeaksOnDataAxis = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_PeaksAddLines", 0)
		Variable/G ResultGraph_PeaksAddLines = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_PeaksAddTags", 0)
		Variable/G ResultGraph_PeaksAddTags = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_TagPkNum", 0)
		Variable/G ResultGraph_TagPkNum = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_TagRealLoc", 0)
		Variable/G ResultGraph_TagRealLoc = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_TagFWHM", 1)
		Variable/G ResultGraph_TagFWHM = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_TagPkArea", 1)
		Variable/G ResultGraph_TagPkArea = dummy
		dummy = NumVarOrDefault(DFpath+":ResultGraph_TagHeight", 0)
		Variable/G ResultGraph_TagHeight = dummy
	SetDataFolder saveDF

	GroupBox MPF2_Graph_IncludeGroup,pos={8,7},size={249,254},title="Include in Graph"
	GroupBox MPF2_Graph_IncludeGroup,fSize=12

	CheckBox MPF2_Graph_includeData,pos={41,34},size={86,14},title="Your Input Data",Variable = ResultGraph_IncludeData
	CheckBox MPF2_Graph_IncludeFitCurve,pos={41,54},size={57,14},title="Fit Curve",Variable = ResultGraph_IncludeFitCurve
	CheckBox MPF2_Graph_IncludePeaks,pos={41,114},size={86,14},title="Individual Peaks",Variable = ResultGraph_IncludePeaks
	CheckBox MPF2_Graph_IncludeResidual,pos={41,94},size={58,14},title="Residuals",Variable = ResultGraph_IncludeResidual
	CheckBox MPF2_Graph_IncludeBackground,pos={41,74},size={97,14},title="Background Curve",Variable = ResultGraph_IncludeBackground
	CheckBox MPF2_Graph_PeakDataAxis,pos={56,134},size={149,14},title="On the Same Axis as Fit Curve",Variable = ResultGraph_PeaksOnDataAxis
	CheckBox MPF2_Graph_PeaksAddLines,pos={56,154},size={81,14},title="Location Lines",Variable = ResultGraph_PeaksAddLines
	CheckBox MPF2_Graph_PeaksAddTags,pos={56,174},size={60,14},title="Tags with",Variable = ResultGraph_PeaksAddTags
	CheckBox MPF2_Graph_TagPkNum,pos={72,194},size={75,14},title="Peak Number",Variable = ResultGraph_TagPkNum
	CheckBox MPF2_Graph_TagRealLoc,pos={72,214},size={55,14},title="Location",Variable = ResultGraph_TagRealLoc
	CheckBox MPF2_Graph_TagFWHM,pos={72,235},size={45,14},title="FWHM",Variable = ResultGraph_TagFWHM
	CheckBox MPF2_Graph_TagPkArea,pos={160,194},size={61,14},title="Peak Area",Variable = ResultGraph_TagPkArea
	CheckBox MPF2_Graph_TagHeight,pos={160,214},size={46,14},title="Height",Variable = ResultGraph_TagHeight

	SetVariable MPF2_Graph_GName,pos={31,267},size={217,15},bodyWidth=160,title="Graph Name"
	SetVariable MPF2_Graph_GName,value= _STR:"MPF2Graph"+num2str(setNumber)
	SetVariable MPF2_Graph_GTitle,pos={36,290},size={211,15},bodyWidth=160,title="Graph Title"
	SetVariable MPF2_Graph_GTitle,value= _STR:"Multipeak Fit Set "+num2str(setNumber)+" Results"

	Button MPF2_Graph_MakeGraph,pos={8,324},size={100,20},proc=MPF2_Graph_MakeGraphButtonProc,title="Make Graph"
	Button MPF2_Graph_Cancel,pos={157,324},size={100,20},proc=MPF2_Graph_CancelButtonProc,title="Cancel"

	SetWindow $panelName, userdata(MPF2_DataSetNumber)=num2str(setnumber)
	
//SetActiveSubwindow _endfloat_	
End

Function MPF2_Graph_CancelButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	switch( s.eventCode )
		case 2: // mouse up
			KillWindow $(s.win)
			break
	endswitch

	return 0
End

// returns a bit pattern:
// bit 0:	bottom or left is autoscaled
// bit 1:	top or right is autoscaled
static Function axisAutoScaleInfo(graphname, axisname)
	String graphname, axisname
	
	String SetScaleCmd = stringbykey("SETAXISCMD", axisinfo(graphname, axisname), ":", ";")
	
	if (strsearch(SetScaleCmd, "/A", 0) > 0)
		return 3										// The /A flag indicates both ends are auto-scaled
	endif
	
	Variable startOfLimits = strsearch(SetScaleCmd, axisname, 0)+strlen(axisname)
	
	Variable returnValue = 0
	
	String lowerLimit, upperLimit, theRest
	String expr = "(?i)[^ ]+ [[:word:]]+ ?([^,]+),(.*)"	// case insensitive, one or more non-space characters, a space, one or more word characters, one space, one or more non-comma characters, a comma, the rest of the line
	SplitString/E=(expr) SetScaleCmd, lowerLimit, upperLimit
	
	if (strsearch(lowerLimit, "*", 0) >= 0)
		returnValue += 1
	endif
	if (strsearch(upperLimit, "*", 0) >= 0)
		returnValue += 2
	endif
	
	return returnValue
end

static Function/S GetAxisRecreation(theGraph, theAxis)
	String theGraph, theAxis
	
	return GetAxisRecreationFromInfoString(AxisInfo(theGraph, theAxis), ":")
end

static Function/S GetAxisRecreationFromInfoString(info, keySeparator)
	String info, keySeparator
	
	Variable sstop = strsearch(info, "RECREATION"+keySeparator, 0)
	info= info[sstop+strlen("RECREATION"+keySeparator),1e6]		// want just recreation stuff
	return info
end

static Function isLogAxis(theGraph, theAxis)
	String theGraph, theAxis
	
	if (strsearch(GetAxisRecreation(theGraph, theAxis), "log(x)=1", 0) >= 0)
		return 1
	endif
	
	return 0
end

Function MPF2_Graph_MakeGraphButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable i
	String NoteText = ""
	
	Variable setNumber = GetSetNumberFromWinName(s.win)
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)

	SVAR YWvName = DFRpath:YWvName
	Wave YData = $YWvName
	SVAR XWvName = DFRpath:XWvName
	Wave/Z XData = $XWvName
	SVAR gname = DFRpath:GraphName
	
	ControlInfo/W=$s.win MPF2_Graph_GName
	String graphName = S_value
	ControlInfo/W=$s.win MPF2_Graph_GTitle 		// ST: graph title option was not honored
	String graphTitle = S_value
	
	if (WinType(graphName) == 1)
		DoAlert 1, "A graph with the name "+graphname+" already exists. Kill it and make the new graph?"
		if (V_flag != 1)
			return -1			// something other than Yes was clicked.
		endif
		KillWindow $graphName
	endif
	
	Display as graphTitle
	RenameWindow $S_name, $GraphName
	
	ControlInfo/W=$s.win MPF2_Graph_includeData
	if (V_value)
		if (WaveExists(XData))
			AppendToGraph/W=$GraphName YData vs XData
		else
			AppendToGraph/W=$GraphName YData
		endif
	endif
	
	Variable autoscaleInfo = axisAutoScaleInfo(gname, "bottom")
	GetAxis/W=$gname/Q bottom
	Variable low = V_min
	Variable high = V_max
	if ( ((autoscaleInfo & 1) == 0) && ((autoscaleInfo & 2) == 0) )
		SetAxis/W=$GraphName bottom, low, high
	elseif ((autoscaleInfo & 1) == 0)
		SetAxis/W=$GraphName bottom, low, *
	elseif ((autoscaleInfo & 2) == 0)
		SetAxis/W=$GraphName bottom, *, high
	endif
	
	Variable LogScale = isLogAxis(gname, "bottom")				// ST: prepare graph for log scale
	if (LogScale)
		ModifyGraph log(bottom)=1
	endif
	
	Wave/Z fitwave	= DFRpath:$(CleanUpName("fit_"+NameOfWave(YData), 1))
	Wave/Z fitxwave	= DFRpath:$(CleanUpName("fitX_"+NameOfWave(YData), 1))
	Wave/Z bkgwave	= DFRpath:$(CleanUpName("bkg_"+NameOfWave(YData), 1))
 
	DFREF YDataFolder = GetWavesDataFolderDFR(YData)
	ControlInfo/W=$("MPF2_ResultsPanel_"+num2str(setNumber)) MPFGResults_ExportFitData
	Variable ExportFitData = V_Value 
	// #### ST: the fit data is exported instead
	if (ExportFitData)
		Duplicate/O fitwave, YDataFolder:$(CleanUpName(NameOfWave(YData)+"_fit", 1))
		Wave fitwave = YDataFolder:$(CleanUpName(NameOfWave(YData)+"_fit", 1))
		
		NVAR MPF2_FitDate 	= DFRpath:MPF2_FitDate				// ST: for use in the wave note
		NVAR MPF2_FitPoints	= DFRpath:MPF2_FitPoints
		NVAR MPF2_FitChiSq	= DFRpath:MPF2_FitChiSq
		SVAR/Z UserNotes 	= DFRpath:UserNotes					// ST: 200820 - add support for set notes
		SVAR SavedFunctions = DFRpath:SavedFunctionTypes
		SVAR WeightWaveName = DFRpath:MPF2WeightWaveName
		SVAR MaskWaveName	= DFRpath:MPF2MaskWaveName
		Wave/Z wt = $WeightWaveName
		Wave/Z mask = $MaskWaveName
		
		NoteText  = "Fit completed: "+Secs2Time(MPF2_FitDate, 0)+" on "+Secs2Date(MPF2_FitDate, 1)+"\r"
		if (SVAR_Exists(UserNotes) && strlen(UserNotes) > 0)
			NoteText += "Set notes: "+UserNotes+"\r"
		endif
		if (SVAR_Exists(SavedFunctions))
			NoteText += "Number of peaks: "+num2str(itemsInList(SavedFunctions)-1)+"\r"
			NoteText += "Background type: "+StringFromList(0,SavedFunctions)+"\r"
		endif
		NoteText += "Y data wave: "+GetWavesDataFolder(YData, 2)+"\r"
		if (WaveExists(XData))
			NoteText += "X data wave: "+GetWavesDataFolder(XData, 2)+"\r"
		endif
		if (WaveExists(wt))
			NoteText += "Weight wave: "+GetWavesDataFolder(wt, 2)+"\r"
		endif
		if (WaveExists(mask))
			NoteText += "Mask wave: "+GetWavesDataFolder(mask, 2)+"\r"
		endif
		NoteText += "Chi square: "+num2str(MPF2_FitChiSq)+"\r"
		NoteText += "Total fitted points: "+num2str(MPF2_FitPoints)+"\r"
		NoteText += "Multipeak fit version: "+MPF2_VERSIONSTRING+"\r"
		Note/K fitwave, NoteText
		
		if (WaveExists(fitxwave))
			Duplicate/O fitxwave, YDataFolder:$(CleanUpName(NameOfWave(YData)+"_fitX", 1))
			Wave fitxwave = YDataFolder:$(CleanUpName(NameOfWave(YData)+"_fitX", 1))
			Note/K fitxwave, NoteText
		endif
	endif
	// #### 	
		
	ControlInfo/W=$s.win MPF2_Graph_IncludeFitCurve
	if (V_value && WaveExists(fitwave))
		if (WaveExists(fitxwave) && LogScale)					// ST: Make sure to append with the x wave (for log axis)
			AppendToGraph/C=(1,4,52428)/W=$GraphName fitwave vs fitxwave
		else
			AppendToGraph/C=(1,4,52428)/W=$GraphName fitwave
		endif
	endif
	
	ControlInfo/W=$s.win MPF2_Graph_IncludeBackground
	if (V_value)
		SVAR SavedFunctionTypes = DFRpath:SavedFunctionTypes
		if (CmpStr(StringFromList(0,SavedFunctionTypes), "None") != 0 && WaveExists(bkgwave))
			if (ExportFitData)									// ST: export background
				Duplicate/O bkgwave, YDataFolder:$(CleanUpName(NameOfWave(YData)+"_bkg", 1))
				Wave bkgwave = YDataFolder:$(CleanUpName(NameOfWave(YData)+"_bkg", 1))
			endif
			
			if (WaveExists(fitxwave) && LogScale)				// ST: Make sure to append with the x wave (for log axis)
				AppendToGraph/C=(2,39321,1)/W=$GraphName bkgwave vs fitxwave
			else
				AppendToGraph/C=(2,39321,1)/W=$GraphName bkgwave
			endif
		endif
	endif
	
	Variable leftAxisBottom = 0
	Variable leftAxisTop = 1
	Variable theRow

	String derivedParamNames
	Variable numDerivedParams

	ControlInfo/W=$s.win MPF2_Graph_IncludePeaks
	if (V_value)
		Wave wpi = DFRpath:W_AutoPeakInfo
		Variable npeaks = DimSize(wpi, 0)
		
		ControlInfo/W=$s.win MPF2_Graph_PeakDataAxis
		Variable UseLeftAxis = V_value
		String axisName = "PeaksLeft"
		String PeakWaveName
		String PeakTypeName
		String ParamNames
		Variable nParams
		Variable sigmaSequenceNumber
		String ParamFuncName
		Variable realLoc
		
		if (ExportFitData)
			NewDataFolder/O YDataFolder:$(CleanUpName(NameOfWave(YData)+"_pks", 1))
			DFREF PeakFolder = YDataFolder:$(CleanUpName(NameOfWave(YData)+"_pks", 1))
		endif
		
		Wave/T/Z MPF2_ResultsListWave = DFRpath:MPF2_ResultsListWave					// ST: for exported wave note
		Wave/T/Z MPF2_ResultsListTitles = DFRpath:MPF2_ResultsListTitles
		
		for (i = 0; i < npeaks; i += 1)
			PeakWaveName = "Peak "+num2istr(i)
			Wave w = DFRpath:$PeakWaveName
			
			if (ExportFitData)															// ST: export peaks
				Duplicate/O w, PeakFolder:$PeakWaveName
				Wave w = PeakFolder:$PeakWaveName
				
				if (WaveExists(MPF2_ResultsListWave))									// ST: 200529 - add a note to each peak with parameters from the list wave
					Variable pos
					NoteText = MPF2_ResultsListTitles[1] + ": "+ MPF2_ResultsListWave[i][1] + "\r"
					for (pos = 2; pos < DimSize(MPF2_ResultsListWave,1); pos += 2)
						if (StringMatch(MPF2_ResultsListTitles[pos], "Background*"))	// ST: special handling of the 'Background' entries
							NoteText += "\r" + MPF2_ResultsListTitles[pos] + "=" +  MPF2_ResultsListWave[i][pos] + "\r"
							NoteText += MPF2_ResultsListTitles[pos+1] + "=" + MPF2_ResultsListWave[i][pos+1] + "\r"
						else
							// ST: ListTitle = abs_Value +/- error
							NoteText += MPF2_ResultsListTitles[pos]
							if (strsearch(MPF2_ResultsListWave[i][pos],"=",0) == -1 && strlen(MPF2_ResultsListWave[i][pos]) > 0)
								NoteText += "=" 
							endif
							NoteText += MPF2_ResultsListWave[i][pos] + " " + MPF2_ResultsListWave[i][pos+1] + "\r"
						endif
					endfor
					NoteText = ReplaceString("Params",NoteText,"\rParams\r")			// ST: improve formatting
					NoteText = ReplaceString("=",NoteText," = ")
					NoteText = ReplaceString("+/-",NoteText,"+/- ")
					NoteText = RemoveFromList(" ",NoteText,"\r")						// ST: remove empty entries
					Note/K w, NoteText
				endif
			endif
			
			if (UseLeftAxis)
				axisName = "left"
				AppendToGraph/W=$GraphName w
			else
				AppendToGraph/W=$GraphName/L=$axisName w
			endif
		endfor
		DoUpdate
		
		Wave/T MPF2_ResultsListWave = DFRpath:MPF2_ResultsListWave
		
		ControlInfo/W=$s.win MPF2_Graph_PeaksAddTags
		Variable addTags = V_value
		ControlInfo/W=$s.win MPF2_Graph_PeaksAddLines
		Variable addLines = V_value
		
		Variable numBLParams
		if (addTags || addLines)
			String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
			if (CmpStr(BL_typename, "None") != 0)
				FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
				numBLParams = ItemsInList(blinfo(BLFuncInfo_ParamNames))
			endif
		endif
		
		if (addTags)
			for (i = 0; i < npeaks; i += 1)
				String tagtext = ""
				String lineEnd = ""

				theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
				PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
				
				FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
				ParamNames = infoFunc(PeakFuncInfo_ParamNames)
				nParams = ItemsInList(ParamNames)
		
				Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
				sigmaSequenceNumber = (numBLParams > 0) ? i+1 : i
				Wave sigma = DFRpath:$("W_sigma_"+num2istr(sigmaSequenceNumber))
		
				ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
				if (strlen(ParamFuncName) > 0)
					derivedParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
					numDerivedParams = ItemsInList(derivedParamNames)
					FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
					Wave M_covar = DFRpath:M_covar
					Make/O/D/N=(nParams, nParams)/FREE MPF2_TempCovar
					Make/O/D/N=(numDerivedParams,2)/FREE MPF2_TempParams=NaN			// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
					MPF2_TempCovar[][] = M_covar[numBLParams+nParams+p][numBLParams+nParams+q]
					paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
					
					realLoc = MPF2_TempParams[0][0]
					Variable realHeight = MPF2_TempParams[1][0]
					Variable realArea = MPF2_TempParams[2][0]
					Variable realFWHM = MPF2_TempParams[3][0]
		
					PeakWaveName = "Peak "+num2istr(i)
					ControlInfo/W=$s.win MPF2_Graph_TagPkNum
					if (V_value)
						tagtext += lineEnd + PeakWaveName
						lineEnd = "\r"
					endif
					ControlInfo/W=$s.win MPF2_Graph_TagRealLoc
					if (V_value)
						tagtext += lineEnd + "Location: "+num2str(realLoc)
						lineEnd = "\r"
					endif
					ControlInfo/W=$s.win MPF2_Graph_TagFWHM
					if (V_value)
						tagtext += lineEnd + "FWHM: "+num2str(realFWHM)
						lineEnd = "\r"
					endif
					ControlInfo/W=$s.win MPF2_Graph_TagPkArea
					if (V_value)
						tagtext += lineEnd + "Area: "+num2str(realArea)
						lineEnd = "\r"
					endif
					ControlInfo/W=$s.win MPF2_Graph_TagHeight
					if (V_value)
						tagtext += lineEnd + "Height: "+num2str(realHeight)
						lineEnd = "\r"
					endif
					
					Tag/A=MB/F=2/L=1/N=$("PeakTag"+num2istr(i))/W=$GraphName $PeakWaveName, realLoc, tagtext
				endif
			endfor
			DoUpdate
		endif
		
		if (addLines)
			for (i = 0; i < npeaks; i += 1)
				Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
				theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
				PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
				
				FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
				ParamNames = infoFunc(PeakFuncInfo_ParamNames)
				nParams = ItemsInList(ParamNames)
		
				Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
				sigmaSequenceNumber = (numBLParams > 0) ? i+1 : i
				Wave sigma = DFRpath:$("W_sigma_"+num2istr(sigmaSequenceNumber))
		
				ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
				if (strlen(ParamFuncName) > 0)
					derivedParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
					numDerivedParams = ItemsInList(derivedParamNames)
					FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
					Wave M_covar = DFRpath:M_covar
					Make/O/D/N=(nParams, nParams)/FREE MPF2_TempCovar
					Make/O/D/N=(numDerivedParams,2)/FREE MPF2_TempParams=NaN			// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
					MPF2_TempCovar[][] = M_covar[numBLParams+nParams+p][numBLParams+nParams+q]
					paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
					
					realLoc = MPF2_TempParams[0][0]
					SetDrawLayer/W=$GraphName userBack
					SetDrawEnv/W=$GraphName linefgc=(56797,56797,56797),  xcoord=bottom, ycoord=prel
					DrawLine/W=$GraphName realLoc, 0, realLoc, 1
				endif
			endfor
		endif
		
		if (!UseLeftAxis)
			leftAxisBottom = .3
			ModifyGraph/W=$GraphName axisEnab(left)={leftAxisBottom, leftAxisTop}, standoff(left)=0
			ModifyGraph/W=$GraphName axisEnab($axisName)={0,.25}
			ModifyGraph freePos($axisName)={0,kwFraction}
		endif
	endif
	
	ControlInfo/W=$s.win MPF2_Graph_IncludeResidual
	Wave/Z rw = DFRpath:$(CleanUpName("Res_"+NameOfWave(yData), 1))
	if (V_value && WaveExists(rw))			// ST: make sure the residuals exist
		if (ExportFitData)					// ST: export residuals
			Duplicate/O rw, YDataFolder:$(CleanUpName(NameOfWave(YData)+"_res", 1))
			Wave rw = YDataFolder:$(CleanUpName(NameOfWave(YData)+"_res", 1))
		endif
	
		if (WaveExists(XData))
			AppendToGraph/W=$GraphName/L=Res_left rw vs XData
		else
			AppendToGraph/W=$GraphName/L=Res_left rw
		endif
		leftAxisTop = .75
		ModifyGraph/W=$GraphName axisEnab(left)={leftAxisBottom, leftAxisTop}, standoff(left)=0
		ModifyGraph/W=$GraphName axisEnab(Res_left)={leftAxisTop+.05, 1}, standoff(left)=0		
		ModifyGraph freePos(Res_left)={0,kwFraction}
	endif
	
	KillWindow $s.win
	
	return 0
End

//*******************************
// Add or Edit Peaks Support
//*******************************

Function/S MPF2_GraphMarqueeDef()

	if (!DataFolderExists("root:Packages:MultiPeakFit2"))
		return ""
	endif
	String gname = WinName(0,1)
	Variable gnamelen = strlen(gname)
	if ( (gnamelen == 0) || (numtype(gnamelen) != 0) )
		return ""
	endif
	Variable setNumber = GetSetNumberFromWinName(gname)
	if (numtype(setNumber))
		return ""
	endif
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	if (!DataFolderExists(DFpath ))
		return ""
	endif
	SVAR MPF2graph = $(DFpath+":GraphName")
	if (CmpStr(MPF2graph, WinName(0,1,1)) != 0)
		return ""
	endif
	if (WinType(MPF2graph+"#MultiPeak2Panel") == 0)		// ST: do not allow editing when the panel is closed
		return ""
	endif
	
	String ZoomEntry = "(Zoom to Fit Range;"			// ST: 200803 - added possibility to zoom to the last completed fit range
	String FitTrace = GrepList(TraceNameList(MPF2graph, ";",1), "^fit_|'fit_", 0 , ";")
	if (strlen(FitTrace) > 0)
		ZoomEntry =  "Zoom to Fit Range;"
	endif
	return "-;Add or Edit Peaks;" + ZoomEntry
end

static Function MPF2_FillReadoutList(listwave, peakName, valueWave, valueRow)
	Wave/T listwave
	String peakName
	Wave/Z valueWave
	Variable valueRow

	if (numpnts(listwave) != 5)							// ST: support for asymmetric peaks
		Redimension/N=5 listwave
	endif

	if (CmpStr(peakName[0,3], "edit") == 0)
		listwave[0] = peakName[4, strlen(peakName)-1]
	elseif (CmpStr(peakName[0,3], "newp") == 0)
		listwave[0] = "New "+peakName[3,strlen(peakName)-1]
	else
		listwave[0] = peakName
	endif
	
	if (WaveExists(valueWave))
		Variable width = (abs(valueWave[valueRow][3])+abs(valueWave[valueRow][4]))/2	// ST: calculate both width and skew
		Variable skew  = (abs(valueWave[valueRow][4])-abs(valueWave[valueRow][3]))/2
		skew = width != 0 ? round (skew*10000/width)/(10000/width) : 0					// ST: 200719 - don't show miniscule skews
		
		listwave[1] = "loc. = " + num2str(valueWave[valueRow][2])
		listwave[2] = "height = "+ num2str(valueWave[valueRow][1])
		listwave[3] = "width = " + num2str(width)
		listwave[4] = "skew = " + num2str(skew)
	else
		listwave[1] = "loc. = "
		listwave[2] = "height = "
		listwave[3] = "width = "
		listwave[4] = "skew = "
	endif
end

Function MPF2_MarqueeHandler(menuStr)
	//GetLastUserMenuInfo									// ST: 210219 - input menuStr instead of using GetLastUserMenuInfo to make MPF2_MarqueeHandler() usable for non-menu calls
	String menuStr// = S_value
	
	String gname = WinName(0,1)
	GetMarquee bottom, left
	Variable xleft = V_left
	Variable xright = V_right
	Variable temp
	
	Variable setNumber = GetSetNumberFromWinName(gname)
	if (numtype(setNumber))
		return 0
	endif
	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	
	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	
	if (StringMatch(menuStr, "Zoom to Fit Range"))			// ST: 200803 - zoom to the fit trace
		Wave/Z fitwave = DFRpath:$(CleanUpName("fit_"+NameOfWave(yw), 1))
		if (WaveExists(fitwave))
			SetAxis bottom ,pnt2x(fitwave,0) ,pnt2x(fitwave,numpnts(fitwave)-1)
			SetAxis/A=2 left
		endif
		return 0
	elseif (!StringMatch(menuStr, "Add or Edit Peaks"))		// ST: 200803 - just quit for a yet unknown selection
		return 0
	endif
	
	MPF2_SaveFunctionTypes(gname+"#MultiPeak2Panel")
	
	Variable npeaks = 0
	if (WaveExists(wpi))
		npeaks = DimSize(wpi, 0)
	endif
	NVAR negativePeaks = DFRpath:negativePeaks
	NVAR XPointRangeBegin = DFRpath:XPointRangeBegin
	NVAR XPointRangeEnd = DFRpath:XPointRangeEnd
	Variable useCursors = MPF2_UseCursorsIsChecked(gname)	// ST: 230528 - if cursors are set then limit to fit range
	Variable xb, xe
	if (WaveExists(xw))
		if (useCursors)
			xb = xw[XPointRangeBegin]
			xe = xw[XPointRangeEnd]
		else
			xb = xw[0]										// ST: 230528 - otherwise limit range to full data set
			xe = xw[numpnts(xw)-1]
		endif
		if (xb > xe)
			temp = xb
			xb = xe
			xe = temp
		endif
	else
		if (useCursors)
			xb = pnt2x(yw, XPointRangeBegin)
			xe = pnt2x(yw, XPointRangeEnd)
		else
			xb = leftx(yw)
			xe = rightx(yw)
		endif
		if (xb > xe)
			temp = xb
			xb = xe
			xe = temp
		endif
	endif
	
	if ( (xleft < min(xb,xe) && xright < min(xb,xe)) || (xleft > max(xb,xe) && xright > max(xb,xe)) )		// ST: prevent adding peaks outside the data range.
		if (useCursors)
			DoAlert 0, "Marquee outside used fit range. You cannot add peaks here. Drag a marquee over part of the fit region or uncheck Use Graph Cursors."
		else
			DoAlert 0, "Marquee outside data range. You cannot add peaks here. Drag a marquee over a part of the data."
		endif
		return 0
	endif
	
	xleft = max(xleft, xb)
	xright = min(xright, xe)
	
	if (xleft > xright)
		temp = xleft
		xleft = xright
		xright = temp
	endif
	
	if (WinType("EditOrAddPeaksGraph"))
		DoWindow/K EditOrAddPeaksGraph
	endif
	
	Variable defLeft = 50
	Variable defTop = 70
	Variable defRight = 560
	Variable defBottom = 420
	Variable i
	
	String fmt="Display/K=1/W=(%s)/N=EditOrAddPeaksGraph as \"Add or Edit Peaks\""	// ST: 200822 - make window title consistent with the menu and button labels
	String cmd = WC_WindowCoordinatesSprintf("EditOrAddPeaksGraph", fmt, defLeft, defTop, defRight, defBottom, 0)
	Execute cmd

	if (WaveExists(xw))
		AppendToGraph/W=EditOrAddPeaksGraph yw vs xw
	else
		AppendToGraph/W=EditOrAddPeaksGraph yw
	endif
	SetAxis/W=EditOrAddPeaksGraph bottom, xleft, xright
	SetAxis/W=EditOrAddPeaksGraph/A=2 left
	ModifyGraph/W=EditOrAddPeaksGraph standoff=0, mirror=2
	ModifyGraph/W=EditOrAddPeaksGraph margin(left)=40,margin(bottom)=40,margin(right)=15,margin(top)=15			// ST: 200822 - center plot area
	SVAR/Z TraceInfoForAddOrEditData = root:Packages:MultiPeakFit2:TraceInfoForAddOrEditData
	if (SVAR_Exists(TraceInfoForAddOrEditData))
		Variable sstop= strsearch(TraceInfoForAddOrEditData, "RECREATION:", 0)
		string tinfo= TraceInfoForAddOrEditData[sstop+strlen("RECREATION:"),1e6]	// want just recreation stuff
		String tname = "("+PossiblyQuoteName(NameOfWave(yw))+")"
		String sitem,xstr
		i = 0
		do
			sitem= StringFromList(i,tinfo)
			if( strlen(sitem) == 0 )
				break;
			endif
			xstr= "ModifyGraph "+ReplaceString("(x)",sitem,tname,1)					// replace "(x)" in sitem with, for example, "(left)"
			Execute xstr
			i+=1
		while(1)	
	endif
	
	Variable miny
	if (WaveExists(xw))
		Variable x1 = pnt2x(yw, BinarySearch(xw, xleft))
		Variable x2 = pnt2x(yw, BinarySearch(xw, xright))
		if (negativePeaks)
			minY = wavemax(yw, x1, x2)
		else
			minY = wavemin(yw, x1, x2)
		endif
	else
		if (negativePeaks)
			miny = wavemax(yw, xleft, xright)
		else
			miny = wavemin(yw, xleft, xright)
		endif
	endif
	
	NewDataFolder/O DFRpath:EditPeaksStuff
	DFREF EditPeaksDFR = DFRpath:EditPeaksStuff
	
	Make/O/D/N=(0,5) EditPeaksDFR:Editwpi			// ST: expand to 5 entries to include left and right width
	Make/O/T/N=0 EditPeaksDFR:EditPeakList
	Make/O/N=(0,7) EditPeaksDFR:UndoInfo			// col 0: 1=added, 0=edited; col 1: index into Editwpi; col 2,3,4,5,6: Editwpi values before editing
	Variable/G EditPeaksDFR:UndoIndex = -1			// points to current undo info; when < 0, no undo info available.
	Wave Editwpi = EditPeaksDFR:Editwpi
	Wave/T EditPeakList = EditPeaksDFR:EditPeakList
	Variable nPeaksToEdit=0
	String/G EditPeaksDFR:editedPeaksList = ""
	Variable/G EditPeaksDFR:numNewPeaks = 0
	String/G EditPeaksDFR:NewPeakTypeList = ""
	for (i = 0; i < npeaks; i += 1)
		if ( (wpi[i][0] > xleft) && (wpi[i][0] < xright) )
			String peakName = "Peak "+num2str(i)
			String editPeakName = "EditPeak "+num2str(i)
			Duplicate/O DFRpath:$PeakName, EditPeaksDFR:$editPeakName
			Wave w = EditPeaksDFR:$editPeakName
			AppendToGraph/W=EditOrAddPeaksGraph w
			ModifyGraph rgb($editPeakName)=(0,0,65535)
			
			InsertPoints nPeaksToEdit, 1, Editwpi, EditPeakList
			Editwpi[nPeaksToEdit][0] = minY
			Editwpi[nPeaksToEdit][1] = wpi[i][2]
			Editwpi[nPeaksToEdit][2] = wpi[i][0]
			Editwpi[nPeaksToEdit][3] = wpi[i][3]*2	// ST: read the half widths in here
			Editwpi[nPeaksToEdit][4] = wpi[i][4]*2
			EditPeakList[nPeaksToEdit] = editPeakName
			
			WaveStats/Q w							// ST: 200719 - find the center from the peak maximum (minimum for negative peaks)
			Variable maxY = abs(V_max) > abs(V_min) ? V_max : V_min
			Variable center = abs(V_max) > abs(V_min) ? V_maxloc : V_minloc
			if (numtype(maxY) == 0)
				Editwpi[nPeaksToEdit][1] = maxY		// ST: 200719 - use the current peak height (wpi value might be old)
				Make/D/Free/n=2 Levels
				FindLevels/Q/D=Levels w, maxY/2		// ST: 200719 - find left and right with from half-maximum analysis
				if (V_LevelsFound == 2 && numtype(center) == 0)
					Editwpi[nPeaksToEdit][2] = center
					Editwpi[nPeaksToEdit][3] = abs(center-Levels[0])*1.2
					Editwpi[nPeaksToEdit][4] = abs(Levels[1]-center)*1.2
				endif
			endif
			nPeaksToEdit += 1
			w += minY
		endif
	endfor

	ControlBar 32
	ControlBar/L 150													// ST: 200822 - increase control area and align controls
	NewPanel/W=(0.2,0.2,0.8,0.8)/FG=(FL,GT,GL,FB)/HOST=# 
	ModifyPanel frameStyle=0
	Button MPF2_EditPeaksUndoButton,pos={20,5},size={110,20},proc=MPF2_EditPeaksUndoButtonProc,title="Undo",disable=2
	Button MPF2_EditPeaksRedoButton,pos={20,35},size={110,20},proc=MPF2_EditPeaksRedoButtonProc,title="Redo",disable=2
	Button MPF2_EditOrAddCancelButton,pos={20,75},size={110,20},proc=MPF2_EditOrAddCancelButtonProc,title="Cancel"
	Button MPF2_AddOrEditDoneButton,pos={20,105},size={110,20},proc=MPF2_EditOrAddDoneButtonProc,title="Done"
	Make/O/N=5/T EditPeaksDFR:MPF2_PeakReadoutListWave					// ST: support for asymmetric peaks
	Wave MPF2_PeakReadoutListWave = EditPeaksDFR:MPF2_PeakReadoutListWave
	ListBox MPF2_AddOrEditReadoutList,pos={10,140},size={130,100},mode=0,listwave=MPF2_PeakReadoutListWave
	MPF2_FillReadoutList(MPF2_PeakReadoutListWave, "", $"",0)
	PopupMenu AddOrEdit_NewPeakTypeMenu,pos={20,275},size={110,20}		// ST: align with buttons
	PopupMenu AddOrEdit_NewPeakTypeMenu,mode=1,bodyWidth= 110,value="Ask;"+MPF2_ListPeakTypeNames()
	String typeName
	Variable mode=1
	if ( (npeaks > 0) && MPF2_AllSamePeakType(setNumber, typeName))
		mode = WhichListItem(typeName, "Ask;"+MPF2_ListPeakTypeNames())+1
	endif
	PopupMenu AddOrEdit_NewPeakTypeMenu,mode=mode
	TitleBox AddOrEdit_NewPeakTypeTitle,pos={20,255},size={90,12},title="Type for New Peaks:"
	TitleBox AddOrEdit_NewPeakTypeTitle,frame=0
	RenameWindow #,PLeft
	SetActiveSubwindow ##
	
	Variable factor = PanelResolution("EditOrAddPeaksGraph")/screenResolution
	SetWindow EditOrAddPeaksGraph, sizelimit={538*factor, 340*factor, inf, inf}		// ST: 200822 - constrain windows size

	// if (DataFolderExists("root:Packages:ManualPeaks"))				// ST: kill at the end of manual peak editing instead
		// KillDataFolder root:Packages:ManualPeaks
	// endif
	// JW 180720 Strangely, InitManualPeakPlacePackage() saves the current data folder, sets its own folder, then returns
	// a string with the saved data folder.
	SetDataFolder InitManualPeakPlacePackage()

	NewPanel/W=(0.2,0.2,0.8,0)/FG=(FL,FT,GR,)/HOST=# 
	ModifyPanel frameStyle=0
	SetVariable MPF2_AddOrEditMessageBox,pos={150,9},size={370,18},title=" "
	SetVariable MPF2_AddOrEditMessageBox,frame=1,fSize=12,fStyle=0
	SetVariable MPF2_AddOrEditMessageBox,value= root:Packages:ManualPeaks:gMessage,noedit= 1
	RenameWindow #,PTop
	SetActiveSubwindow ##

	SetWindow EditOrAddPeaksGraph, hook(MPF2_EditGraphCursor) = MPF2_EditGraphCursorHook
	SetWindow EditOrAddPeaksGraph, userdata(MPF2_EditMouseMode) = "up"
	SetWindow EditOrAddPeaksGraph, userdata(MPF2_DataSetNumber) = num2str(setNumber)
end

//******************************* Results Table ****************************************

 Function MPF2_MakeResultsTablePanel(ba) : ButtonControl		// ST: no extra panel needed
	STRUCT WMButtonAction &ba
	
	if (ba.eventCode == 2)		// mouse up
		return 0
		// Variable setNumber = GetSetNumberFromWinName(ba.win)
		// String panelname = "MPF2_ResultsTablePanel_Set"+num2str(setNumber)
	
		// if (WinType(panelname) == 7)
			// DoWindow/F $panelname
		// else
			// NewPanel /W=(100,100,446,300)/N=$panelname/K=1 as "Make Results Table for Set Number "+num2str(setnumber)
			// PopupMenu MPF2_ResultsTable_SortMenu,pos={79.00,36.00},size={144.00,23.00},title="Sorting:"
			// PopupMenu MPF2_ResultsTable_SortMenu,mode=1,value= #"\"Peak Number;Location;Height;Area;Width;\""
			// PopupMenu MPF2_ResultsTable_Datafolder,pos={26.00,81.00},size={233.00,23.00},title="Location for Waves:"
			// PopupMenu MPF2_ResultsTable_Datafolder,mode=1,value= #"\"Current Data Folder;Multipeak Fit Set Folder;\""
			// Button MPF2_ResultsTable_MakeTableButton,pos={33.00,149.00},size={100.00,20.00},title="Make Table",proc=MPF2Results_TableButtonProc
			// Button MPF2_ResultsTable_MakeTableButton,userdata(setnumber)=num2str(setnumber)
			// Button MPF2_ResultsTable_CancelButton,pos={207.00,149.00},size={100.00,20.00},proc=MPF2_ResultsTable_CancelButtonProc,title="Cancel"
		// endif
	endif
End

// Function MPF2_ResultsTable_CancelButtonProc(ba) : ButtonControl
	// STRUCT WMButtonAction &ba

	// switch( ba.eventCode )
		// case 2: // mouse up
			// KillWindow $(ba.win)
			// break
	// endswitch

	// return 0
// End

Function MPF2Results_TableButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			ControlInfo/W=$(ba.win) MPF2_ResultsTable_SortMenu
			Variable sortcode = V_value - 1
			ControlInfo/W=$(ba.win) MPF2_ResultsTable_Datafolder
			Variable dfcode = V_value - 1
			Variable setNumber = str2num(GetUserData(ba.win, ba.ctrlName, "setnumber"))
			MPF2Results_MakeTable(setnumber, sortcode, dfcode)
			//KillWindow $(ba.win)		// ST: do not kill the results main panel
			break
	endswitch

	return 0
End

// sortcode: zero-based from this list: Peak Number;Location;Height;Area;Width;
// dfcode: zero-based from this list: Current Data Folder;Multipeak Fit Set Folder;
Function MPF2Results_MakeTable(Variable setnumber, Variable sortcode, Variable dfcode)

	DFREF DFRpath = $MPF2_FolderPathFromSetNumber(setNumber)
	DFREF TableWavesDFR = GetDataFolderDFR()
	Switch (dfcode)		// ST: add more folder options: Multipeak Fit Set Folder;Root Folder;Subfolder in Current;Subfolder in Root;
		case 1:
			TableWavesDFR = DFRpath
		break
		case 2:
			TableWavesDFR = root:
		break
		case 3:
			NewDataFolder/O TableWavesDFR:$("Set"+num2str(setnumber)+"_results")
			TableWavesDFR = TableWavesDFR:$("Set"+num2str(setnumber)+"_results")
		break
		case 4:
			NewDataFolder/O root:$("Set"+num2str(setnumber)+"_results")
			TableWavesDFR = root:$("Set"+num2str(setnumber)+"_results")
		break
	Endswitch
	
	//if (dfcode == 1)
	//	TableWavesDFR = DFRpath
	//endif
	
	SVAR gname = DFRpath:GraphName
	
	String tablename = "MPF2_ResultsTable_Set"+num2str(setNumber)
	
	Variable left,top,right,bottom
 	
	if (WinType(tablename) == 2)
		GetWindow $tablename wsize
		left = V_left
		top = V_top
		right = V_right
		bottom = V_bottom
		DoWindow/K $tablename
	else
		GetWindow $gname wsize
		left = V_left + 50
		top = V_top + 50
		right = left + resultsDefaultWidth
		bottom = top + resultsDefaultHeight
	endif
	
	Edit/N=$tablename/K=1/W=(left,top,right,bottom) as "Results for Multipeak Fit Set "+num2str(setnumber)

	Wave wpi = DFRpath:W_AutoPeakInfo
	Variable npeaks = DimSize(wpi, 0)
	
	Variable i, j
	
	NVAR/Z MPF2_FitDate = DFRpath:MPF2_FitDate			// if this variable doesn't exist, it means that a fit hasn't been done yet
	
	if (!NVAR_Exists(MPF2_FitDate))						// shouldn't happen since the button to get here is in the Results panel
		DoAlert 0, "No fit results are available yet."
		return -1
	endif

	for (i = 0; i < npeaks; i += 1)
		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		if (MPF2_FitDate < modDate(coefs ))
			DoAlert 0, "The coefficient wave for Peak "+num2istr(i)+" was modified after the last fit, so the results are out of date."
			return -1
		endif
	endfor

	Variable numBLParams = 0
	String BL_typename = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, 0) )
	if (CmpStr(BL_typename, "None") != 0)
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
		String BLParams = blinfo(BLFuncInfo_ParamNames)
		numBLParams = ItemsInList(BLParams)
		Wave/Z blw = DFRpath:'Baseline Coefs'
		if (MPF2_FitDate < modDate(blw ))
			DoAlert 0, "The coefficient wave for the baseline function was modified after the last fit, so the results are out of date."
			return -1
		endif
		Make/D/N=(numBLParams, 2)/O TableWavesDFR:$("Set"+num2str(setnumber)+"_Baseline")/WAVE=blwave
		for (i = 0; i < numBLParams; i++)
			SetDimLabel 0, i, $StringFromList(i, BLParams), blwave
		endfor
		SetDimLabel 1, 0, Value, blwave
		SetDimLabel 1, 1, Sigma, blwave
		blwave[][0] = blw[p]
		Wave ble = DFRpath:W_sigma_0
		blwave[][1] = ble[p]
		AppendToTable/W=$tablename blwave.ld
		ModifyTable width($GetWavesDataFolder(blwave,2).l)=120		// ST: use the full wave folder here
	endif

	Variable totalParams = numBLParams

	totalParams = numBLParams
	Variable totalArea=0
	Variable totalAreaVariance=0

	if (sortcode > 0)
		Make/D/N=(npeaks)/FREE SortWave
	endif
	Make/WAVE/N=(npeaks)/FREE tablewaves
	
	for (i = 0; i < npeaks; i += 1)
		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(i))
		String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
		FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
		String ParamNames = infoFunc(PeakFuncInfo_ParamNames)
		Variable nParams = ItemsInList(ParamNames)
		
		String DerivedParamNames = infoFunc(PeakFuncInfo_DerivedParamNames)
		Variable nDerivedParams = ItemsInList(DerivedParamNames)
		
		String allParamNames = DerivedParamNames+ParamNames
		
		Variable totalPeakParams = nParams + nDerivedParams
		Make/D/N=(totalPeakParams, 2)/O TableWavesDFR:$("Set"+num2str(setnumber)+"_Peak_"+num2str(i))/WAVE=cw		// ST: make inside TableWavesDFR
		Variable row = 0
		for (j = 0; j < nDerivedParams; j++)
			SetDimLabel 0, row, $StringFromList(j, DerivedParamNames), cw
			row++
		endfor
		for (j = 0; j < nParams; j++)
			SetDimLabel 0, row, $StringFromList(j, ParamNames), cw
			row++
		endfor
		SetDimLabel 1, 0, Value, cw
		SetDimLabel 1, 1, Sigma, cw
		SetDimLabel 0, -1, $PeakTypeName, cw	
		SetDimLabel 1, -1, $("Peak "+num2str(i)), cw

		Wave coefs = DFRpath:$("Peak "+num2istr(i)+" Coefs")
		Variable sigmaSequenceNumber = (numBLParams > 0) ? i+1 : i
		Wave sigma = DFRpath:$("W_sigma_"+num2istr(sigmaSequenceNumber))
		
		cw[nDerivedParams,][0] = coefs[p-nDerivedParams]
		cw[nDerivedParams,][1] = sigma[p-nDerivedParams]

		String ParamFuncName = infoFunc(PeakFuncInfo_ParameterFunc)
		if (strlen(ParamFuncName) > 0)
			FUNCREF MPF2_ParamFuncTemplate paramFunc=$ParamFuncName
			Wave M_covar = DFRpath:M_covar
			Make/O/D/N=(nParams, nParams)/FREE MPF2_TempCovar
			Make/O/D/N=(nDerivedParams,2)/FREE MPF2_TempParams=NaN				// initialize to blanks so that if the function doesn't exist, we just get blanks back- the template function doesn't do anything.
			MPF2_TempCovar[][] = M_covar[totalParams+p][totalParams+q]
			paramFunc(coefs, MPF2_TempCovar, MPF2_TempParams)
			
			cw[0,nDerivedParams-1][] = MPF2_TempParams[p][q]

			totalArea += MPF2_TempParams[2][0]									// area is always in row 2
			totalAreaVariance += MPF2_TempParams[2][1]^2

			if (sortcode > 0)
				sortwave[i] = MPF2_TempParams[sortcode-1][0]
			endif
		endif
		tablewaves[i] = cw

		totalParams += nParams
	endfor
	
	if (sortcode > 0)
		Sort SortWave, SortWave, tablewaves
	endif
	for (i = 0; i < npeaks; i++)
		WAVE w=tablewaves[i]
		AppendToTable/W=$tablename w.ld
		ModifyTable width($GetWavesDataFolder(w,2).l)=120						// ST: use the full wave folder here
	endfor
	
	NVAR MPF2_FitChiSq = DFRpath:MPF2_FitChiSq
	Make/N=3/O/D TableWavesDFR:$("Set"+num2str(setNumber)+"_summary")/WAVE=sw	// ST: make inside TableWavesDFR
	SetDimLabel 0, 0, 'Chi-square', sw
	sw[0] = MPF2_FitChiSq
	SetDimLabel 0, 1, 'Total Area', sw
	sw[1] = totalArea
	SetDimLabel 0, 2, 'Area sigma', sw
	sw[2] = sqrt(totalAreaVariance)
	AppendToTable/W=$tablename sw.ld
end

//******************************* end of Results Table ****************************************

static Function/S PossiblyUnquoteName(name)
	String name
	
	if (char2num(name[0]) == char2num("'"))
		return name[1, strlen(name)-2]
	endif
	
	return name
end

Function MPF2_EditGraphCursorHook(s)
	STRUCT WMWinHookStruct &s
	
	String highlightedTrace = GetUserData(s.winName, "", "MPF2_HighlightTrace" )
	Variable setNumber	= GetSetNumberFromWinName(s.winName)
	DFREF DFRpath		= $MPF2_FolderPathFromSetNumber(setNumber)
	DFREF EditPeaksDFR	= DFRpath:EditPeaksStuff
	Wave/T EditPeakList	= EditPeaksDFR:EditPeakList
	Variable npeaks = DimSize(EditPeakList, 0)
	
	Variable i
	
	// If we are in editing or peak placing mode, ignore all events except the keyboard event that will cancel out of peak editing mode
	if (CmpStr(GetUserData("EditOrAddPeaksGraph", "", "MPF2_EditMouseMode"), "down") == 0)
		if (s.eventCode == 11)		// keycode
			if (s.keycode == 27)
				Button MPF2_EditOrAddCancelButton,win=EditOrAddPeaksGraph#PLeft,disable=0
				Button MPF2_AddOrEditDoneButton,win=EditOrAddPeaksGraph#PLeft,disable=0
				SetWindow EditOrAddPeaksGraph, userdata(MPF2_EditMouseMode) = "up"
				EndManualPeakMode()
			endif
			return 1				// ST: 200817 - exit for ALL key strokes to prevent triggering ManPeakInsertHookProc()
		endif
		
		Wave/T listWave = EditPeaksDFR:MPF2_PeakReadoutListWave
		Wave/Z EditCoef = root:Packages:ManualPeaks:wcoef	
		if (WaveExists(EditCoef))	// ST: live value update
			Make/free transcoef ={{EditCoef[0]},{EditCoef[1]},{EditCoef[2]},{EditCoef[3]},{EditCoef[4]}}
			MPF2_FillReadoutList(listWave, listWave[0], transcoef, 0)
		endif
		return 0
	endif

	strswitch (s.eventName)
		case "keyboard":
			if (CmpStr(s.winName, "EditOrAddPeaksGraph") != 0)
				return 0
			endif
			if (s.keycode == 8 || s.keycode == 127)			// ST: 200818 - delete peak with backspace or delete key
				if ( (strlen(highlightedTrace) > 0) && (npeaks > 0) )
					MPF2_EditPeaksRemoveHighlighted(highlightedTrace, EditPeaksDFR)
					MPF2_AddOrEditUpdtUndoRedoBtn(setnumber)
				endif
				return 1
			endif
			break;
		case "mousedown":
			if (CmpStr(s.winName, "EditOrAddPeaksGraph") != 0)
				return 0
			endif
			if (s.eventMod & 16)														// right-click
				if ( (strlen(highlightedTrace) > 0) && (npeaks > 0) )
					PopupContextualMenu "Remove;"
					if (V_flag == 1)
						MPF2_EditPeaksRemoveHighlighted(highlightedTrace, EditPeaksDFR)
						MPF2_AddOrEditUpdtUndoRedoBtn(setnumber)
					endif
					return 1
				endif
				break;
			endif
		
			SVAR YWvName = DFRpath:YWvName
			Wave yw = $YWvName
			
			Wave/D/Z EditInfo=$""
			Wave/T/Z EditTrace=$"" 
			Variable/G EditPeaksDFR:EditPeakNumber = -1
			NVAR EditPeakNumber = EditPeaksDFR:EditPeakNumber
			if ( (strlen(highlightedTrace) > 0) && (npeaks > 0) )
				Wave Editwpi = EditPeaksDFR:Editwpi
				Make/O/D/N=(1, 5) EditPeaksDFR:EditInfo/WAVE=EditInfo					// ST: expand to 5 entries to include left and right width
				Make/O/N=1/T EditPeaksDFR:EditTrace/WAVE=EditTrace						// ST: 200719 - create inside temp editing folder
				for (i = 0; i < npeaks; i += 1)
					if (CmpStr(EditPeakList[i], highlightedTrace)==0)
						EditInfo[0][] = Editwpi[i][q]
						EditTrace[0] = EditPeakList[i]
						break;
					endif
				endfor
				EditPeakNumber = i
			endif
		
			Button MPF2_EditOrAddCancelButton,win=EditOrAddPeaksGraph#PLeft,disable=2	// ST: disable instead of hide
			Button MPF2_AddOrEditDoneButton,win=EditOrAddPeaksGraph#PLeft,disable=2
			Button MPF2_EditPeaksUndoButton,win=EditOrAddPeaksGraph#PLeft,disable=2		// ST: disable Redo and Undo buttons as well 
			Button MPF2_EditPeaksRedoButton,win=EditOrAddPeaksGraph#PLeft,disable=2
		
			SetWindow EditOrAddPeaksGraph, userdata(MPF2_EditMouseMode) = "down"
			
			return StartManualPeakModeEX(yw, "MPF2_PeakEditCallback", EditTrace, EditInfo, s)
			break;
		case "mousemoved":
			if (CmpStr(s.winName, "EditOrAddPeaksGraph") != 0)
				return 0
			endif

			Wave Editwpi = EditPeaksDFR:Editwpi
			Wave/T listWave = EditPeaksDFR:MPF2_PeakReadoutListWave
			
			Variable peakNum=0
			Variable imax= numpnts(EditPeakList)
			String tname = ""
			if (imax > 0)
				Do
					String theTrace = TraceFromPixel(s.mouseLoc.h, s.mouseLoc.v, "ONLY:"+PossiblyQuoteName(EditPeakList[peakNum])+";")
					if( strlen(theTrace) != 0 )
						tname = EditPeakList[peakNum]
						break
					endif
					peakNum += 1
				while(peakNum < imax)
			endif

			SVAR gMessage = root:Packages:ManualPeaks:gMessage

			if ( (strlen(highlightedTrace) > 0) && (CmpStr(highlightedTrace, tname) != 0) )
				if (strlen(TraceInfo(s.winName, highlightedTrace, 0)) > 0)
					ModifyGraph/W=$(s.winName) lSize($PossiblyQuoteName(highlightedTrace))=1
				endif
				SetWindow $(s.winName) userdata(MPF2_HighlightTrace)=""
			endif
			MPF2_FillReadoutList(listWave, "", $"",0)
			if (strlen(tname) > 0)
				if ( (CmpStr(tname[0,3], "Edit") == 0) || (CmpStr(tname[0,6], "NewPeak") == 0) )
					ModifyGraph/W=$(s.winName) lSize($PossiblyQuoteName(tname))=2
					SetWindow $(s.winName) userdata(MPF2_HighlightTrace)=tname
					gMessage = "Click and drag to edit highlighted peak. Remove with delete key."
					
					MPF2_FillReadoutList(listWave, EditPeakList[peakNum], editwpi, peakNum)
				else
					gMessage = "Click and drag to create new peak."
				endif
			else
				gMessage = "Click and drag to create new peak."
			endif
			break;
		case "kill":			// treat like the Cancel button
			// JW 180720 We use Execute/P here because until the graph is actually gone we can't kill the datafolder.
			// That's because the datafolder contains waves that are used in the graph.
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
			String cmd = "KillDataFolder "+DFpath+":EditPeaksStuff"		
			Execute/P/Q/Z cmd
			String infostr = "EVENT:kill;WINDOW:"+s.winName
			WC_WindowCoordinatesHook(infostr)
			SVAR YWvName = DFRpath:YWvName
			Wave w = $YWvName
			String/G root:Packages:MultiPeakFit2:TraceInfoForAddOrEditData = TraceInfo(s.winName, NameOfWave(w), 0)
			KillDataFolder/Z root:Packages:ManualPeaks		// ST: clean up manual peaks edit folder
			break;
		case "deactivate":
			if ( (strlen(highlightedTrace) > 0) )
				if (strlen(TraceInfo(s.winName, highlightedTrace, 0)) > 0)
					ModifyGraph/W=$(s.winName) lSize($PossiblyQuoteName(highlightedTrace))=1
				endif
				SetWindow $(s.winName) userdata(MPF2_HighlightTrace)=""
			endif
			break;
	endswitch
	
	return 0
end

Function MPF2_EditPeaksRemoveHighlighted(highlightedTrace, EditPeaksDFR)
	String highlightedTrace
	DFREF EditPeaksDFR
	
	Wave/T EditPeakList = EditPeaksDFR:EditPeakList
	Variable npeaks = DimSize(EditPeakList, 0)
	
	Variable removePeakNumber
	for (removePeakNumber = 0; removePeakNumber < npeaks; removePeakNumber += 1)
		if (CmpStr(EditPeakList[removePeakNumber], highlightedTrace)==0)
			break;
		endif
	endfor
	
	Wave Editwpi	= EditPeaksDFR:Editwpi
	Wave UndoInfo	= EditPeaksDFR:UndoInfo						// col 0: 1=added, 0=edited; col 1: index into Editwpi; col 2,3,4,5,6: Editwpi values before editing
	NVAR UndoIndex	= EditPeaksDFR:UndoIndex					// points to current undo info; when < 0, no undo info available.
	NVAR numNewPeaks	 = EditPeaksDFR:numNewPeaks
	Variable numOldPeaks = DimSize(EditPeakList, 0) - numNewPeaks
	SVAR NewPeakTypeList = EditPeaksDFR:NewPeakTypeList
	UndoIndex += 1
	if (DimSize(UndoInfo, 0) <= UndoIndex)
		InsertPoints UndoIndex, 1, UndoInfo
		UndoIndex = DimSize(UndoInfo, 0)-1						// paranoia
	else
		UndoInfo[UndoIndex] = 0
		Redimension/N=(DimSize(UndoInfo, 0)+1, -1) UndoInfo
	endif
	Variable newListItem = removePeakNumber >= numOldPeaks
	UndoInfo[UndoIndex][0] = newListItem ? 3 : 2				// action is a Remove
	UndoInfo[UndoIndex][1] = -1									// It doesn't have a position in the Editwpi wave
	UndoInfo[UndoIndex][2] = Editwpi[removePeakNumber][0]
	UndoInfo[UndoIndex][3] = Editwpi[removePeakNumber][1]
	UndoInfo[UndoIndex][4] = Editwpi[removePeakNumber][2]
	UndoInfo[UndoIndex][5] = Editwpi[removePeakNumber][3]
	UndoInfo[UndoIndex][6] = Editwpi[removePeakNumber][4]		// ST: add 4th entry as well
	String peakWaveName = EditPeakList[removePeakNumber]
	
	if (newListItem)
		Variable newIndex = removePeakNumber - numOldPeaks
		Variable removedPeakNumber
		sscanf highlightedTrace, "NewPeak %d", removedPeakNumber
		UndoInfo[UndoIndex][1] = removedPeakNumber
		NewPeakTypeList = RemoveListItem(newIndex, NewPeakTypeList)
		numNewPeaks -= 1
	else
		String/G EditPeaksDFR:RemovePeakList
		SVAR RemovePeakList = EditPeaksDFR:RemovePeakList
		sscanf highlightedTrace, "EditPeak %d", removedPeakNumber
		UndoInfo[UndoIndex][1] = removedPeakNumber
		RemovePeakList += highlightedTrace+";"
	endif

	DeletePoints removePeakNumber, 1, Editwpi, EditPeakList
	if (DimSize(Editwpi, 0)==0)    // If columns dimension disappears problems will occur if peaks are added later
		Redimension /N=(0,5) Editwpi
	endif
	RemoveFromGraph/W=EditOrAddPeaksGraph $peakWaveName
	KillWaves EditPeaksDFR:$peakWaveName
end

Static Function/S ExtractRootFromSubwindowName(subWinName)
	String subWinName
	
	Variable poundPos = strsearch(subWinName, "#", 0)
	if (poundPos > 0)
		return subWinName[0,poundPos-1]
	endif
	
	return subWinName
end

Function MPF2_EditPeaksUndoButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	
	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName("EditOrAddPeaksGraph")
	
	MPF2_EditOrAddPeaksUndo(setNumber)
	
	MPF2_AddOrEditUpdtUndoRedoBtn(setNumber)
End

Static Function MPF2_AddOrEditUpdtUndoRedoBtn(setNumber)
	Variable setNumber
	
	DFREF DFRpath = $(MPF2_FolderPathFromSetNumber(setNumber)+":EditPeaksStuff")
	NVAR UndoIndex = DFRpath:UndoIndex			// points to current undo info; when < 0, no undo info available.
	Wave UndoInfo = DFRpath:UndoInfo			// col 0: 1=added, 0=edited; col 1: index into Editwpi; col 2,3,4,5,6: Editwpi values before editing
	
	Button MPF2_EditPeaksUndoButton,win=EditOrAddPeaksGraph#PLeft,disable= (UndoIndex < 0 ? 2 : 0)
	Button MPF2_EditPeaksRedoButton,win=EditOrAddPeaksGraph#PLeft,disable= (UndoIndex >= DimSize(UndoInfo, 0)-1 ? 2 : 0)
end

Function MPF2_EditPeaksRedoButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName("EditOrAddPeaksGraph")
	
	MPF2_EditOrAddPeaksRedo(setNumber)
	
	MPF2_AddOrEditUpdtUndoRedoBtn(setNumber)
End

// this function doesn't need to kill the graph, because it is called as a result of killing the graph.
//Function MPF2_AddOrEditModeKillDF(setNumber)
//	Variable setNumber
//
//	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
//
//	KillDataFolder $(DFpath+":EditPeaksStuff")
//end

Function MPF2_EditOrAddCancelButtonProc(ctrlName) : ButtonControl
	String ctrlName
	// Just kill the graph, the hook function will call MPF2_AddOrEditModeKillDF()
	DoWindow/K EditOrAddPeaksGraph
End

Function MPF2_EditOrAddDoneButtonProc(s) : ButtonControl
	STRUCT WMButtonAction &s

	if (s.eventCode != 2)		// mouse-up in the control
		return 0
	endif
	
	Variable setNumber = GetSetNumberFromWinName("EditOrAddPeaksGraph")
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	DFREF DFReditStuff = DFRpath:EditPeaksStuff
	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	SVAR YWvName = DFRpath:YWvName
	SVAR XWvName = DFRpath:XWvName
	Wave yw = $YWvName
	Wave/Z xw = $XWvName
	
	SVAR gname = DFRpath:GraphName

	DoWindow/K EditOrAddPeaksGraph
//	DoUpdate

	if (WinType(gname) != 1)
		DoAlert 0, "The graph and Multipeak Fit control panel have disappeared!"
		return -1
	endif
	if (WinType(gname+"#MultiPeak2Panel") != 7)
		DoAlert 0, "The Multipeak Fit control panel associated with the graph \""+gname+"\" has disappeared!"
		return -1
	endif

	Wave Editwpi = DFReditStuff:Editwpi
	Wave/T EditPeakList = DFReditStuff:EditPeakList
	NVAR numNewPeaks = DFReditStuff:numNewPeaks
	SVAR NewPeakTypeList = DFReditStuff:NewPeakTypeList
	Variable numOldPeaks = DimSize(Editwpi, 0) - numNewPeaks
	SVAR/Z RemovePeakList = DFReditStuff:RemovePeakList
	SVAR editedPeaksList = DFReditStuff:editedPeaksList

	Variable i, peakNumber
	
	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	if (WaveExists(wpi))
		Variable npeaks = DimSize(wpi, 0)
		DFREF saveDFR = GetDataFolderDFR()
		SetDataFolder DFRpath
		NewDataFolder/O/S EditDuplicateCoefWaves
		KillWaves/Z/A
		for (i = 0; i < npeaks; i += 1)
			String wvname = "Peak "+num2str(i)+" Coefs"
			Duplicate/O $("::"+PossiblyQuoteName(wvname)), $wvname
		endfor
		SetDataFolder saveDFR
	endif
	
	// We have to perform the actions in the right order- all the peak numbers refer to peak numbers before the Add or Edit graph was put up.
	// Consequently, we have to store the edited peak values into the wpi wave first, while the row numbers match the peak numbers.
	// Then we have to remove peaks that were removed in the Add or Edit graph, starting with  the highest numbered peak. That's because
	// as the peaks are removed, higher-numbered peaks move down into lower-numbered rows (effectively, they are re-named).
	// Finally, add new peaks, since they are added at the end of the wpi wave, which will later be sorted by peak location.
	
	SVAR SavedFunctionTypes = DFRpath:SavedFunctionTypes
	SavedFunctionTypes += NewPeakTypeList
	 
	Make/N=(0,2)/O/FREE changedPeaks			// column 0: peak number; column 1: 1 for changed, 0 for unchanged
	Variable peaksWereChanged = 0				// NH added this to go through the re-order function even if peaks were moved but not added or removed
	// First handle edits. If the wpi wave doesn't exist yet, then there can't be edited peaks, but we need to make the wpi wave.
	if ( !WaveExists(wpi) || (DimSize(wpi, 0) == 0) )
		Make/D/N=(0,5)/O DFRpath:W_AutoPeakInfo
		wave wpi = DFRpath:W_AutoPeakInfo
	else
		Redimension/N=(DimSize(wpi, 0), 2) changedPeaks
		changedPeaks[][0] = p
		changedPeaks[][1] = 0
		for (i = 0; i < numOldPeaks; i += 1)
			sscanf EditPeakList[i], "EditPeak %d", peakNumber
			if (WhichListItem(num2str(i), editedPeaksList) >= 0)
				wpi[peakNumber][0] = Editwpi[i][2]
				wpi[peakNumber][1] = Editwpi[i][3]/2 + Editwpi[i][4]/2		// ST: add the two half widths
				wpi[peakNumber][2] = Editwpi[i][1]
				wpi[peakNumber][3] = Editwpi[i][3]/2
				wpi[peakNumber][4] = Editwpi[i][4]/2
				changedPeaks[peakNumber][1] = 1
				peaksWereChanged = 1
			endif
		endfor
	endif
	
	Wave/T HoldStrings = DFRpath:HoldStrings
	MPF2_RefreshHoldStrings(gname+"#MultiPeak2Panel")   		// Update the hold strings
	MPF2_RefreshConstraintStrings(setNumber)
	
	Make/Free/N=0 OpenState										// ST: 200817 - preserve open state of all peak entries
	i = 0
	do
		Variable theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
		if (theRow < 0)
			break;
		endif
		OpenState[DimSize(OpenState,0)] = {WMHL_RowIsOpen(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", theRow)}
		i += 1
	while (1)
	Redimension/N=(DimSize(wpi, 0)) OpenState 					// ST: 200817 - make sure this is the same size as wpi

	// next delete removed peaks
	Variable numRemovedPeaks = 0
	if (SVAR_Exists(RemovePeakList))
		RemovePeakList = SortList(RemovePeakList, ";", 17)		// sort alphanumerically in descending order so the first peak in the list is the highest-numbered
		numRemovedPeaks = ItemsInList(RemovePeakList)
		for (i = 0; i < numRemovedPeaks; i += 1)
			String peakName = StringFromList(i, RemovePeakList)
			sscanf peakName, "EditPeak %d", peakNumber
			DeletePoints peakNumber, 1, wpi, changedPeaks, OpenState
			DeletePoints peakNumber+1, 1, HoldStrings	        //HoldStrings is peakNumber+1 because baseline is HoldStrings[0]
			if (DimSize(wpi, 0)==0)    							// If columns dimension disappears problems will occur if peaks are added later
				Redimension /N=(0,5) wpi
			endif
			if (DimSize(wpi, 0)==0)								// If columns dimension disappears problems will occur if peaks are changed later
				Redimension /N=(0,2) changedPeaks
			endif
			
			//keep constraints consistent
			removePeakConstraints(setNumber, peakNumber+1)
		endfor
	endif
	
	// finally, add new peaks at the end of the wave.
	Variable numExistingPeaks = DimSize(wpi, 0)
	InsertPoints numExistingPeaks, numNewPeaks, wpi, changedPeaks
	Variable numCurrentPeaks = DimSize(HoldStrings,0)
	Redimension /N=(numCurrentPeaks+numNewPeaks) HoldStrings
	for (i = 0; i < numNewPeaks; i += 1)
		wpi[numExistingPeaks+i][0] = Editwpi[numOldPeaks+i][2]
		wpi[numExistingPeaks+i][1] = Editwpi[numOldPeaks+i][3]/2 + Editwpi[numOldPeaks+i][4]/2		// ST: add the two half widths
		wpi[numExistingPeaks+i][2] = Editwpi[numOldPeaks+i][1]
		wpi[numExistingPeaks+i][3] = Editwpi[numOldPeaks+i][3]/2
		wpi[numExistingPeaks+i][4] = Editwpi[numOldPeaks+i][4]/2
		changedPeaks[numExistingPeaks+i][1] = 1
		
		insertPeakConstraints(setNumber, numCurrentPeaks+i+1)
	endfor
	
	Variable newNPeaks = DimSize(wpi, 0)-numExistingPeaks
	if ( (newNPeaks > 0) || (numRemovedPeaks > 0) || peaksWereChanged)  						   // Did peaks get added or removed?
	 	Wave /T constraintsTextWave = DFRpath:constraintsTextWave

		if (newNPeaks > 0 && i < DimSize(EditPeakList, 0))
			sscanf EditPeakList[i], "EditPeak %d", peakNumber
		endif
				 
		String listoftypes = SavedFunctionTypes
		DFREF saveDF = GetDataFolderDFR()
		SetDataFolder DFRpath
		String indexWaveName = MPF2_SortAutoPeakWave(wpi, listOfTypes=listoftypes, holdwave=HoldStrings, constraintswave=constraintsTextWave, killIndexWave = 0)    
		SetDataFolder saveDF
		
		Wave indexWave = $indexWaveName
		SavedFunctionTypes = listoftypes
		
		DFREF dupDFR = DFRpath:EditDuplicateCoefWaves
		for (i = 0; i < DimSize(wpi, 0); i += 1)
			if (changedPeaks[indexWave[i]][1])
				MPF2_CoefWaveForPeak(setNumber, wpi, i, StringFromList(i+1,SavedFunctionTypes))		// i+1: the first of SavedFunctionTypes is for the baseline			
			else
				WAVE oldwave = dupDFR:$"Peak "+num2str(changedPeaks[indexWave[i]][0])+" Coefs"
				String newWaveName = MPF2_FolderPathFromSetNumber(setNumber)+":'Peak "+num2str(i)+" Coefs'"
				Duplicate/O oldwave,  $newWaveName
			endif
		endfor
		KillDataFolder/Z dupDFR										// ST: clean up duplicate folder

		MPF2_RemoveAllPeaksFromGraph(gname)							// fixes issue with some peaks lingering after delete
		MPF2_PutAutoPeakResultIntoList(setNumber, wpi, 0, listOfPeakTypes=SavedFunctionTypes)
		
		if (DimSize(OpenState,0) > 0 && DimSize(indexWave,0) > 0)	// ST: 200817 - reopen all previously opened containers
			ReDimension/N=(DimSize(indexWave,0)) OpenState
			for (i = 0; i < DimSize(OpenState, 0); i += 1)
				if (OpenState[indexWave[i]] == 1)					// ST: assumes that all containers have been rebuilt by MPF2_PutAutoPeakResultIntoList()
					WMHL_OpenAContainer(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2str(i))
				endif
			endfor
		endif
		
		NVAR negativePeaks = DFRpath:negativePeaks
		NVAR displayPeaksFullWidth = DFRpath:displayPeaksFullWidth
		MPF2_AddPeaksToGraph(setNumber, wpi, 1, 1, displayPeaksFullWidth)
		MPF2_AddFitCurveToGraph(setNumber, wpi, yw, xw, 1, overridePoints=MPF2_getFitCurvePoints(gname+"#MultiPeak2Panel"))
		
		String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
		String ListOfCWaveNames = "Baseline Coefs;"					// ST: the number of peaks has changed => backup coef waves
		for (i = 0; i < DimSize(wpi, 0); i += 1)
			ListOfCWaveNames += "Peak "+num2istr(i)+" Coefs;"
		endfor
		MPF2_BackupCoefWaves(ListOfCWaveNames, DFpath)
	endif
	
	MPF2_EnableDisableDoFitButton(setNumber)
End

// Undo information is stored in the wave EditPeakStuff:UndoInfo. Each peak that has been edited or added has a row in the UndoInfo wave.
// The information in that row is 
// 		column 0:		type of action: 0 = edited; 1 = added new peak; 2 = remove an old peak; 3 = remove a new peak
//		Column 1:		row in the Editwpi wave.  If column 0 is 2 (remove) this column is not meaningful.
//		Column 2-5:	y0, a, x0, w values

// An undo of an edit (column 0 is 0):
// 1) swap y0, a, x0, w values between appropriate rows in editwpi and UndoInfo waves.
// 2) re-compute the peak wave used to display the peak on the Edit or Add graph.

// Re-doing an edit is the same as un-doing an edit

// An undo of a new wave (column 0 is 1):

// 1) objectIndex = UndoInfo[UndoIndex][1]								Get the index of the added peak in the editwpi wave
// 2) peakWaveName = EditPeakList[objectIndex]							Get the name of the wave that displays the peak on the graph
// 3) DeletePoints objectIndex, 1, Editwpi, EditPeakList				Remove the entry in the editwpi wave
// 4) RemoveFromGraph/W=EditOrAddPeaksGraph $peakWaveName				Remove the peak from the graph
// 5) KillWaves $peakWaveName											and kill the display wave
// 6) numNewPeaks -= 1													Update the number of peaks variable
// 7) NewPeakTypeList = RemoveListItem(numNewPeaks, NewPeakTypeList)	Remove the appropriate item from the list of new peaks

// Re-doing and add
//	1) Add row to end of editwpi wave
//	2) Populate the new row with values from appropriate row of UndoInfo
//	3) Make a new peak wave, fill it with peak values, add it to the graph

Function MPF2_PeakEditCallback(pk,y0,a,x0,w1,w2)
	Variable pk,y0,a,x0,w1,w2

	String gname=WinName(0,1)
	Variable setNumber = GetSetNumberFromWinName(gname)
	
	Button MPF2_EditOrAddCancelButton,win=EditOrAddPeaksGraph#PLeft,disable=0	// ST: buttons need to be reset even if the user just clicked
	Button MPF2_AddOrEditDoneButton,win=EditOrAddPeaksGraph#PLeft,disable=0
	SetWindow EditOrAddPeaksGraph, userdata(MPF2_EditMouseMode) = "up"			// ST: reset edit mode
	EndManualPeakMode()															// ST: 200818 - remove tmpPeak in any case
	
	MPF2_AddOrEditUpdtUndoRedoBtn(setNumber)									// ST: will be updated again at the end if a peak was generated
	
	if (w1 == 0 && w2 == 0)	// happens if you click in the graph without dragging.
		return 0			// tells calling code to ignore this.
	endif
	
	String newType, setForAll
	if (pk == 0)
		ControlInfo/W=EditOrAddPeaksGraph#PLeft AddOrEdit_NewPeakTypeMenu
		newType = S_value
		if (CmpStr(newType, "Ask") == 0)
			Prompt newType, "Type for new peak", popup, MPF2_ListPeakTypeNames()
			Prompt setForAll, "Ask again next time?", popup, "Keep asking;Remember my choice;"
			DoPrompt "Choose type for new peak", newType, setForAll
			if (V_flag == 1)
				return 0
			endif
			if (CmpStr(setForAll, "Remember my choice") == 0)
				PopupMenu AddOrEdit_NewPeakTypeMenu ,win=EditOrAddPeaksGraph#PLeft ,popmatch=newType
			endif
		endif
	endif

	w1 = abs(w1)									// ST : support for two widths
	w2 = abs(w2)
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	DFREF EditStuffDFR = DFRpath:EditPeaksStuff

	SVAR YWvName = DFRpath:YWvName
	Wave Editwpi = EditStuffDFR:Editwpi
	Wave/T EditPeakList = EditStuffDFR:EditPeakList
	NVAR numNewPeaks = EditStuffDFR:numNewPeaks
	SVAR NewPeakTypeList = EditStuffDFR:NewPeakTypeList

	Wave UndoInfo = EditStuffDFR:UndoInfo			// col 0: 1=added, 0=edited; col 1: index into Editwpi; col 2,3,4,5,6: Editwpi values before editing
	NVAR UndoIndex = EditStuffDFR:UndoIndex			// points to current undo info; when < 0, no undo info available.
	UndoIndex += 1
	if (DimSize(UndoInfo, 0) <= UndoIndex)
		InsertPoints UndoIndex, 1, UndoInfo
		UndoIndex = DimSize(UndoInfo, 0)-1			// paranoia
	else
		UndoInfo[UndoIndex] = 0
		Redimension/N=(DimSize(UndoInfo, 0), -1) UndoInfo		// ST: off by one error fixed
	endif

	if (pk == 0)
		// finished creating a new peak
		Variable nPeaks = DimSize(Editwpi, 0)
		InsertPoints nPeaks, 1, Editwpi, EditPeakList

		UndoInfo[UndoIndex][0] = 1
		UndoInfo[UndoIndex][1] = nPeaks
		UndoInfo[UndoIndex][2] = y0					// don't need it for undo, but might for re-do
		UndoInfo[UndoIndex][3] = a
		UndoInfo[UndoIndex][4] = x0
		UndoInfo[UndoIndex][5] = w1
		UndoInfo[UndoIndex][6] = w2					// ST : support for two widths
		
		Editwpi[nPeaks][0] = y0
		Editwpi[nPeaks][1] = a
		Editwpi[nPeaks][2] = x0
		Editwpi[nPeaks][3] = w1
		Editwpi[nPeaks][4] = w2						// ST : support for two widths
		Variable lastPeakNumber=-1
		if (nPeaks > 0)
			String previousPeakName = EditPeakList[nPeaks-1]
			if (CmpStr(previousPeakName[0,7], "NewPeak ") == 0)
				sscanf previousPeakName, "NewPeak %d", lastPeakNumber
			endif
		endif
		EditPeakList[nPeaks] = "NewPeak "+num2str(lastPeakNumber+1)
		Make/O/N=200 EditStuffDFR:$(EditPeakList[nPeaks])
		Wave pkwave = EditStuffDFR:$(EditPeakList[nPeaks])
		CalcPeakFromEditwpi(pkwave, Editwpi, nPeaks)
		AppendToGraph/W=EditOrAddPeaksGraph pkwave
		ModifyGraph rgb($NameOfWave(pkwave))=(0,0,65535)
		NewPeakTypeList += newType+";"
		numNewPeaks += 1
	else
		// finished editing an existing peak
		NVAR EditPeakNumber = EditStuffDFR:EditPeakNumber
		SVAR editedPeaksList = EditStuffDFR:editedPeaksList
		pk = EditPeakNumber
		if (WhichListItem(num2str(pk), editedPeaksList) < 0)
			editedPeaksList += num2str(pk)+";"
		endif

		UndoInfo[UndoIndex][0] = 0
		UndoInfo[UndoIndex][1] = pk
		UndoInfo[UndoIndex][2] = Editwpi[pk][0]
		UndoInfo[UndoIndex][3] = Editwpi[pk][1]
		UndoInfo[UndoIndex][4] = Editwpi[pk][2]
		UndoInfo[UndoIndex][5] = Editwpi[pk][3]
		UndoInfo[UndoIndex][6] = Editwpi[pk][4]		

		Editwpi[pk][0] = y0
		Editwpi[pk][1] = a
		Editwpi[pk][2] = x0
		Editwpi[pk][3] = w1
		Editwpi[pk][4] = w2			// ST : support for two widths
		Wave pkwave = EditStuffDFR:$(EditPeakList[pk])
		CalcPeakFromEditwpi(pkwave, Editwpi, pk)
	endif
	
	MPF2_AddOrEditUpdtUndoRedoBtn(setNumber)
	
//	Button MPF2_EditOrAddCancelButton,win=EditOrAddPeaksGraph#PLeft,disable=0		// ST: called at the start instead
//	Button MPF2_AddOrEditDoneButton,win=EditOrAddPeaksGraph#PLeft,disable=0
//	EndManualPeakMode()
//	SetWindow EditOrAddPeaksGraph, userdata(MPF2_EditMouseMode) = "up"
	
	return 1
end

Function MPF2_EditOrAddPeaksUndo(setNumber)
	Variable setNumber

	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	DFREF EditDFR = DFRpath:EditPeaksStuff
	Wave/SDFR=EditDFR Editwpi
	Wave/T/SDFR=EditDFR EditPeakList
	NVAR numNewPeaks = EditDFR:numNewPeaks
	SVAR NewPeakTypeList = EditDFR:NewPeakTypeList

	Wave/SDFR=EditDFR UndoInfo				// col 0: 1=added, 0=edited; col 1: index into Editwpi; col 2,3,4,5: Editwpi values before editing
	NVAR UndoIndex	=EditDFR:UndoIndex		// points to current undo info; when < 0, no undo info available.
	
	if (UndoIndex < 0)
		return 0
	endif
	
	Variable objectIndex
	String peakWaveName

	// UndoIndex was last left pointing to the last added info, or to the next one to be used
	Variable undoAction = UndoInfo[UndoIndex][0]
	switch (undoAction)
		case 0:				// last action was editing a peak
			objectIndex = UndoInfo[UndoIndex][1]
			Make/D/N=5/O EditDFR:tempUndoInfoWave/WAVE=tempUndoInfoWave
			tempUndoInfoWave = Editwpi[objectIndex][p]			// save values we're about to undo
	
			peakWaveName = EditPeakList[objectIndex]
			Editwpi[objectIndex][]  = UndoInfo[UndoIndex][q+2]
			UndoInfo[UndoIndex][2,] = tempUndoInfoWave[q-2]		// save undone values for possible re-do
	
			Wave pkwave = EditDFR:$peakWaveName	
			CalcPeakFromEditwpi(pkwave, Editwpi, objectIndex)
			break;
		case 1:				// last action was adding a peak
			objectIndex = UndoInfo[UndoIndex][1]
			peakWaveName = EditPeakList[objectIndex]
			DeletePoints objectIndex, 1, Editwpi, EditPeakList
			if (DimSize(Editwpi, 0)==0)							// If columns dimension disappears problems will occur if peaks are added later
				Redimension /N=(0,5) Editwpi					// ST : support for two widths
			endif
			WAVE pkwave = EditDFR:$peakWaveName
			RemoveFromGraph/W=EditOrAddPeaksGraph $peakWaveName
			KillWaves pkwave
			numNewPeaks -= 1
			NewPeakTypeList = RemoveListItem(numNewPeaks, NewPeakTypeList)
			break;
		case 2:				// last action was removing one of the original peaks
		case 3:				// last action was removing a new peak (one added by dragging on the Add or Edit graph)
			if (undoAction == 2)
				Variable removedPeakNumber = UndoInfo[UndoIndex][1]
				NVAR numNewPeaks = EditDFR:numNewPeaks
				SVAR RemovePeakList = EditDFR:RemovePeakList
				String removedPeakName = "EditPeak "+num2str(removedPeakNumber)
				RemovePeakList = RemoveFromList(removedPeakName, RemovePeakList)
				Variable removedPeakIndex
				sscanf removedPeakName, "EditPeak %d", removedPeakIndex
				Variable i
				Variable numOldPeaks = DimSize(Editwpi, 0)-numNewPeaks
				for (i = 0; i < numOldPeaks; i += 1)
					Variable editPeakNumber
					sscanf EditPeakList[i], "EditPeak %d", editPeakNumber
					if (editPeakNumber > removedPeakIndex)
						break;
					endif
				endfor
				
				Variable editIndex = i
				
				InsertPoints editIndex, 1, Editwpi,EditPeakList
				Editwpi[editIndex][] = UndoInfo[UndoIndex][q+2]
				EditPeakList[editIndex] = removedPeakName
			else
				Variable newIndex = UndoInfo[UndoIndex][1]
				numOldPeaks = DimSize(Editwpi, 0)-numNewPeaks
				editIndex = numOldPeaks + newIndex
				InsertPoints editIndex, 1, Editwpi,EditPeakList
				Editwpi[editIndex][] = UndoInfo[UndoIndex][q+2]
				EditPeakList[editIndex] = "NewPeak "+num2str(newIndex)
				numNewPeaks += 1
			endif
			Make/O/N=200 EditDFR:$(EditPeakList[editIndex])
			Wave pkwave = EditDFR:$(EditPeakList[editIndex])
			CalcPeakFromEditwpi(pkwave, Editwpi, editIndex)
			AppendToGraph/W=EditOrAddPeaksGraph pkwave
			ModifyGraph rgb($NameOfWave(pkwave))=(0,0,65535)
			break;
	endswitch
	
	UndoIndex -= 1
end

Function MPF2_EditOrAddPeaksRedo(setNumber)
	Variable setNumber

	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	DFREF editDFR = DFRpath:EditPeaksStuff
	Wave/SDFR=editDFR Editwpi
	Wave/T/SDFR=editDFR EditPeakList
	NVAR numNewPeaks = editDFR:numNewPeaks
	SVAR NewPeakTypeList = editDFR:NewPeakTypeList

	Wave/SDFR=editDFR UndoInfo					// col 0: 1=added, 0=edited; col 1: index into Editwpi; col 2,3,4,5: Editwpi values before editing
	NVAR UndoIndex = editDFR:UndoIndex			// points to current undo info; when < 0, no undo info available.
	
	if (UndoIndex >= DimSize(UndoInfo, 0)-1)
		return 0
	endif
	
	UndoIndex += 1
	
	Variable objectIndex
	String peakWaveName

	// UndoIndex was last left pointing to the last added info, or to the next one to be used
	Variable undoAction = UndoInfo[UndoIndex][0]
	switch (undoAction)
		case 0:													// edited a peak
			objectIndex = UndoInfo[UndoIndex][1]
			Make/D/N=5/O editDFR:tempUndoInfoWave/WAVE=tempUndoInfoWave
			tempUndoInfoWave = Editwpi[objectIndex][p]			// save values we're about to redo
	
			peakWaveName = EditPeakList[objectIndex]
			Editwpi[objectIndex][] = UndoInfo[UndoIndex][q+2]
			UndoInfo[UndoIndex][2,] = tempUndoInfoWave[q-2]		// save redone values for possible undo
			
			Wave pkwave = EditDFR:$peakWaveName
			CalcPeakFromEditwpi(pkwave, Editwpi, objectIndex)
			break;
		case 1:													// added a new peak
			Variable nPeaks = DimSize(Editwpi, 0)
			InsertPoints nPeaks, 1, Editwpi, EditPeakList
	
			UndoInfo[UndoIndex][1] = nPeaks
			Editwpi[nPeaks][] = UndoInfo[UndoIndex][p+2]
			
			Variable lastPeakNumber = -1
			if (nPeaks > 0)										// ST: only if there are already peaks available
				String previousPeakName = EditPeakList[nPeaks-1]
				if (CmpStr(previousPeakName[0,7], "NewPeak ") == 0)
					sscanf previousPeakName, "NewPeak %d", lastPeakNumber
				endif
			endif
			
			EditPeakList[nPeaks] = "NewPeak "+num2str(lastPeakNumber+1)
			NewPeakTypeList += "Gauss;"
			
			Make/O/N=200 editDFR:$(EditPeakList[nPeaks])/WAVE=pkwave
			CalcPeakFromEditwpi(pkwave, Editwpi, nPeaks)
			AppendToGraph/W=EditOrAddPeaksGraph pkwave
			ModifyGraph rgb($NameOfWave(pkwave))=(0,0,65535)
			numNewPeaks += 1
			break;
		case 2:													// removed an original peak
		case 3:													// removed an added peak
			String peakName
			Variable peakNumber = UndoInfo[UndoIndex][1]
			Variable numOldPeaks = DimSize(Editwpi, 0)-numNewPeaks
			Variable i, editRow
			if (undoAction == 2)
				peakName = "EditPeak "+num2str(peakNumber)
				for (i = 0; i < numOldPeaks; i += 1)
					if (CmpStr(EditPeakList[i], peakName) == 0)
						break;
					endif
				endfor
			else
				peakName = "NewPeak "+num2str(peakNumber)
				for (i = numOldPeaks; i < DimSize(Editwpi, 0); i += 1)
					if (CmpStr(EditPeakList[i], peakName) == 0)
						break;
					endif
				endfor
			endif
			editRow = i
			DeletePoints editRow, 1, Editwpi, EditPeakList
			if (DimSize(Editwpi, 0)==0)							// If columns dimension disappears problems will occur if peaks are added later
				Redimension /N=(0,5) Editwpi					// ST : support for two widths
			endif
			RemoveFromGraph/W=EditOrAddPeaksGraph $peakName
			WAVE pkwave = editDFR:$peakName
			KillWaves pkwave
			if (undoAction == 2)
				SVAR RemovePeakList = editDFR:RemovePeakList
				RemovePeakList = RemoveFromList(peakName, RemovePeakList)
			else
				NewPeakTypeList = RemoveListItem(editRow-numOldPeaks, NewPeakTypeList)
				numNewPeaks -= 1
			endif
			break;
	endswitch
	
	Button MPF2_EditPeaksUndoButton,win=EditOrAddPeaksGraph#PLeft,disable=0
end

Static Function CalcPeakFromEditwpi(Wave pkwave, Wave Editwpi, Variable index)	// calculates a split peak exactly in the same manner as inside 'Manual Peak Adjust.ipf'
	Variable y0 = Editwpi[index][0]
	Variable a  = Editwpi[index][1]
	Variable x0 = Editwpi[index][2]
	Variable w1 = Editwpi[index][3]
	Variable w2 = Editwpi[index][4]												// ST : support for two widths
	
	Variable wcomb = (w1+w2)/2
	SetScale/I x x0-4*wcomb, x0+4*wcomb, pkwave
	
	pkwave = x < x0? y0+a*exp(-((x-x0)/w1)^2) : y0+a*exp(-((x-x0)/w2)^2)		// ST: create a split peak
End

//////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////// Constraints Functions ///////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// When constraints are included in the peak fit the coefficients indicies are globally numbered.  So if there is a baseline
// function is a constant then constraints are expressed in terms of K0.  If there are 2 peaks and one is gaussian (3 coefs)
// and one is Voigt (4 coefs) then they will be expressed in terms of K1-K3 and K4-K7.  To keep from having to renumber
// every time a peak is added or removed or a peak function changes indices will be saved in a local sense.  So the situation
// described above will be numbered locally as baseline: K0, Peak0: K0-K2, Peak1: K0-K3.  To get the full text wave with
// global indices as required by FuncFit use getGlobalConstraintsString(setNumber).
//
// The local constraint text wave is not FuncFit ready even if converted to global strings.  It contains key-value pairs.  Keys and 
// values are separated by ":", and key-value pairs are separated by ";".  Current Keys are "MIN[local coef name]:[number]", 
// "MAX[local coef name]:[number]" and "GENERAL:[locally indexed but otherwise FitFunc ready format constraint string]

Function resetPeakConstraints(setNumber, peakNumberP1)
	Variable setNumber, peakNumberP1
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	//// get the number of peaks
	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	Variable npeaks = waveExists(wpi) ? DimSize(wpi, 0) : 0
		
	Wave /T /Z constraintsTextWave = $(DFPath+":constraintsTextWave")
	if (!WaveExists(constraintsTextWave))
		Make /T /N=(npeaks+1) $(DFPath+":constraintsTextWave") 
		Wave /T constraintsTextWave = $(DFPath+":constraintsTextWave")    
	endif
	if (DimSize(constraintsTextWave, 0) < peakNumberP1+1)
		Redimension /N=(peakNumberP1+1) constraintsTextWave
	endif 
	
	constraintsTextWave[peakNumberP1] = ""
End

// peakNumberP1 means peak number plus 1.  Plus 1 because of the baseline function
// localCoefIndex is locally indexed.  Not used for general
// for no min set minVal=NaN; same for maxVal
Function setPeakConstraints(setNumber, peakNumberP1, localCoefIndex, [minVal, maxVal, general])
	Variable setNumber, peakNumberP1, localCoefIndex, minVal, maxVal
	String general
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	Variable i
	
	//// get the number of peaks
	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	Variable npeaks = waveExists(wpi) ? DimSize(wpi, 0) : 0
	
	//// if the peakNumberP1 is valid, make sure there is room for it in the constraintsWave - also make sure the constraintsTextWave exists!
	if (peakNumberP1 > npeaks)
		return -1
	endif
	Wave /T /Z constraintsTextWave = $(DFPath+":constraintsTextWave")
	if (!WaveExists(constraintsTextWave))
		Make /T /N=(npeaks+1) $(DFPath+":constraintsTextWave") 
		Wave /T constraintsTextWave = $(DFPath+":constraintsTextWave")    
	endif
	if (DimSize(constraintsTextWave, 0) < peakNumberP1+1)
		Redimension /N=(peakNumberP1+1) constraintsTextWave
	endif 
	
	//// get the current peak constraint string and work on it.
	String currConstraints = constraintsTextWave[peakNumberP1]

	NVAR MPF2_CoefListPrecision = $(DFPath+":MPF2_CoefListPrecision")
	String numberstr
	
	//// for each type see if it already exists for the given constraint.  If not, add it.  If so, replace it
	if (!ParamIsDefault(minVal))
		if (numType(minVal)==2)
			currConstraints = ReplaceStringByKey("MINK"+num2str(localCoefIndex), currConstraints, "")
		else
			sprintf numberstr, "%.*g", MPF2_CoefListPrecision, minVal
			currConstraints = ReplaceStringByKey("MINK"+num2str(localCoefIndex), currConstraints, numberstr)
		endif
	endif
	if (!ParamIsDefault(maxVal))
		if (numType(maxVal)==2)
			currConstraints = ReplaceStringByKey("MAXK"+num2str(localCoefIndex), currConstraints, "")
		else 
			sprintf numberstr, "%.*g", MPF2_CoefListPrecision, maxVal
			currConstraints = ReplaceStringByKey("MAXK"+num2str(localCoefIndex), currConstraints, numberstr)
		endif
	endif
	if (!ParamIsDefault(general))
		currConstraints = ReplaceStringByKey("GENERAL", currConstraints, general)
	endif
	//// replace the current constraint with the new one
	
	constraintsTextWave[peakNumberP1] = currConstraints
End

// localCoefIndex is locally indexed. Not applicable for type="General"
// type is a string - either "Min", "Max" or "General"
Function /S getPeakConstraints(setNumber, peakNumberP1, localCoefIndex, type)
	Variable setNumber, peakNumberP1, localCoefIndex
	String type
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	String ret="", keyStr=""
	
	Wave /T /Z constraintsTextWave = $(DFPath+":constraintsTextWave")
	if (WaveExists(constraintsTextWave) && DimSize(constraintsTextWave, 0)>peakNumberP1)
		strswitch (type)
			case "Min":
				keyStr = "MINK"+num2str(localCoefIndex)
				break
			case "Max":
				keyStr = "MAXK"+num2str(localCoefIndex)		
				break
			case "General":
				keyStr = "GENERAL"
				break
			default:
				break
		endswitch
		ret = StringByKey(keyStr, constraintsTextWave[peakNumberP1])
	endif
	return ret
End

Function removePeakConstraints(setNumber, peakNumberP1)
	Variable setNumber, peakNumberP1

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	Variable i
	
	Wave /T /Z constraintsTextWave = $(DFPath+":constraintsTextWave")
	if (waveExists(constraintsTextWave))
		DeletePoints peakNumberP1, 1, constraintsTextWave
	endif
End

Function insertPeakConstraints(setNumber, newPeakNumberP1)
	Variable setNumber, newPeakNumberP1

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	Variable i
	
	Wave /T /Z constraintsTextWave = $(DFPath+":constraintsTextWave")
	if (!waveExists(constraintsTextWave))
		Make /T /N=(newPeakNumberP1) $(DFPath+":constraintsTextWave")
		Wave /T constraintsTextWave = $(DFPath+":constraintsTextWave")		
	endif
	InsertPoints newPeakNumberP1, 1, constraintsTextWave
End 

/// Constraint data saved when Hierarchical container is closed.  Thus need to check the open containers when getting global constraints
Function /Wave getGlobalConstraintsWave(Variable setNumber, Variable doErrorAlerts, Variable & wasError)
		
	String utilStr, constraintsList=""
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	SVAR gname = $(DFpath+":GraphName")
	String listPanelName = gname+"#MultiPeak2Panel#P1"
	
	Variable i, j, aVal
	
	///// Update the constraint strings to reflect peaks open on the multipeak panel
	MPF2_RefreshConstraintStrings(setNumber)
	
	Wave nParamsSum = MPF2_GetNParamsForFuncs(setNumber)
	Variable nPeaks = DimSize(nParamsSum,0) // includes baseline
	
	Variable BaselineRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", "Baseline")
	String baselineStr = WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, BaselineRow)
	Variable doBaseLine = CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0
	if (doBaseLine)
		//// Get baseline coef min and maxs for each coefficient ////
		for (i=0; i<nParamsSum[0]; i+=1)
			utilStr = getPeakConstraints(setNumber, 0, i, "Min")
			if (strLen(utilStr)>0)
				constraintsList+="K"+num2str(i)+">"+utilStr+";"
			endif
			utilStr = getPeakConstraints(setNumber, 0, i, "Max")
			if (strLen(utilStr)>0)
				constraintsList+="K"+num2str(i)+"<"+utilStr+";"			
			endif					
		endfor	
	endif
	
	Variable iPeak
	for (iPeak=1; iPeak < nPeaks; iPeak+=1)	
		Variable nCoefs = nParamsSum[iPeak]-nParamsSum[iPeak-1]
		for (i=0; i<nCoefs; i+=1)
			utilStr = getPeakConstraints(setNumber, iPeak, i, "Min")
			if (strLen(utilStr)>0)
				constraintsList+="K"+num2str(i+nParamsSum[iPeak-1])+">"+utilStr+";"
			endif
			utilStr = getPeakConstraints(setNumber, iPeak, i, "Max")
			if (strLen(utilStr)>0)
				constraintsList+="K"+num2str(i+nParamsSum[iPeak-1])+"<"+utilStr+";"			
			endif					
		endfor
	endfor
	
	
	String interPeakExpressions = StrVarOrDefault(DFPath+":interPeakConstraints", "")
	if (strlen(interPeakExpressions) > 0)
		Variable isValid = MPF2_ValidateConstraint(setNumber, gname+"#MultiPeak2Panel", interPeakExpressions, doErrPanel=doErrorAlerts)
		wasError = !isValid
		if (!isValid)
			return ListToTextWave("", ";")		// ST: return a NULL wave here to not break wave calls
		endif
	endif

	Variable doEqualHeights = NumVarOrDefault(DFPath+":DoEqualHeightsContraint", 0)			// ST: 210219 - height constraint added
	Variable doEqualWidths = NumVarOrDefault(DFPath+":DoEqualWidthsContraint", 0)
	Variable doPairedLocations = NumVarOrDefault(DFPath+":DoPairedLocationConstraint", 0)
	Variable pairedLocationSep = NumVarOrDefault(DFPath+":PairedLocationDistance", 0)
		
	if (doPairedLocations)
		// These constraints are generated by code and assumed to be valid
		interPeakExpressions += MPF2_generatePairedLocationConstraints(setNumber, pairedLocationSep)
	endif
	if (doEqualWidths)
		// These constraints are generated by code and assumed to be valid
		interPeakExpressions += MPF2_GenerateEqualConstraints(setNumber,1)
	endif
	if (doEqualHeights)
		// These constraints are generated by code and assumed to be valid
		interPeakExpressions += MPF2_GenerateEqualConstraints(setNumber,2)
	endif

	if (strlen(interPeakExpressions) > 0)
		constraintsList += MPF2_AllPeaksToFitFuncStr(setNumber, interPeakExpressions)
	endif
	
	WAVE constraintsWave = ListToTextWave(constraintsList, ";")

	return constraintsWave
End

// for reporting purposes primarily
// peakNumberP1 is peak number + 1, allowing for baseline constraints to be expressed using index 0
// Returns 0 if it is not constrainted (or is out of bounds!), 1 if it is
// MPF2_RefreshConstraintStrings() should be called prior to calling this to make sure open HeirarchicalList containers are counted
Static Function /Wave MPF2_isConstrainedWave(setNumber)
	Variable setNumber

	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
		
	Variable wasError
	Wave /T constraints = getGlobalConstraintsWave(setNumber, 0, wasError)
	Variable nConstraints = DimSize(constraints, 0)
	Wave nConstraintsWave = MPF2_GetNParamsForFuncs(setNumber)
	Variable nPeaksP1 = DimSize(nConstraintsWave, 0)

	Make /Wave/Free/N=(nPeaksP1) ret

	//// Set up the wave of constraints
	Variable i, j
	for (i=0; i<nPeaksP1; i+=1)
		Variable nLocalConstraints = i==0 ? nConstraintsWave[0] : nConstraintsWave[i]-nConstraintsWave[i-1]
		ret[i] = NewFreeWave(16, nLocalConstraints)
	endfor
	
	String regExprStr = "[Kk]([0-9]+)(.*)"
	String substring1, substring2
	Variable k
	
	for (i=0; i<nConstraints; i+=1)
		String currConstraintString = constraints[i]
		do 
			SplitString /E=(regExprStr) currConstraintString, substring1, substring2
			currConstraintString = substring2
		
			if (strlen(substring1))		
				sscanf substring1, "%i", k
				Variable currPeak, currCoef = k
				for (j=0; j<nPeaksP1; j+=1)
					if (nConstraintsWave[j] > k)
						currPeak = j
						if (j==0)
							currCoef = k
						else 
							currCoef = k-(nConstraintsWave[j-1])
						endif
						
						Wave currWave = ret[currPeak]
						currWave[currCoef] = 1
						break
					endif
				endfor
			else						
				break
			endif
		
		while (1)
	endfor
	
	return ret
End

//// Modeled after MPF2_RefreshHoldStrings()
//// Only covers min and max.  
Static Function MPF2_RefreshConstraintStrings(setNumber)
	Variable setNumber
		
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	SVAR gname = $(DFpath+":GraphName")
	String listPanel = gname+"#MultiPeak2Panel#P1"

	Variable i, numitems, rownumber
	String children, minStr, maxStr

	rownumber = WMHL_GetRowNumberForItem(listPanel, "MPF2_PeakList", "Baseline")
	if (WMHL_RowIsOpen(listPanel, "MPF2_PeakList", rownumber))
		children = WMHL_ListChildRows(listPanel, "MPF2_PeakList", rownumber)
		numItems = ItemsInList(children)
		for (i = 0; i < numitems; i += 1)
			rownumber = str2num(StringFromList(i, children))

			minStr = WMHL_GetExtraColumnData(listPanel, "MPF2_PeakList", 3, rownumber)
			maxStr = WMHL_GetExtraColumnData(listPanel, "MPF2_PeakList", 5, rownumber)
			setPeakConstraints(setNumber, 0, i, minVal=str2num(minStr), maxVal=str2num(maxStr))	
		endfor
	endif

	Variable iPeak=0
	do
		String peakItem = "Peak "+num2str(iPeak)
		rownumber = WMHL_GetRowNumberForItem(listPanel, "MPF2_PeakList", peakItem)
		if (rownumber < 0)
			break;
		endif
		if (WMHL_RowIsOpen(listPanel, "MPF2_PeakList", rownumber))
			children = WMHL_ListChildRows(listPanel, "MPF2_PeakList", rownumber)
			numItems = ItemsInList(children)
			for (i = 0; i < numitems; i += 1)
				rownumber = str2num(StringFromList(i, children))

				minStr = WMHL_GetExtraColumnData(listPanel, "MPF2_PeakList", 3, rownumber)
				maxStr = WMHL_GetExtraColumnData(listPanel, "MPF2_PeakList", 5, rownumber)
				setPeakConstraints(setNumber, iPeak+1, i, minVal=str2num(minStr), maxVal=str2num(maxStr))	
			endfor
		endif
			
		iPeak += 1
	while(1)
End

// Global constraint syntax is simple: P#K#, where the number following P is the peak number (indexed from 0) and the number following the K is the coefficient number (from 0)
// Individual constraints are ";" separated.  Valid operators are "<", "<=", ">", ">="
// This function will translate a global string into the correct syntax for use with FitFunc  
Static Function /S MPF2_AllPeaksToFitFuncStr(setNumber, interPeakConstraintStr)
	Variable setNumber
	String interPeakConstraintStr
		
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	String ret=interPeakConstraintStr
	String currPeakString = interPeakConstraintStr
	String regExprStr = "([Pp|Bb][0-9|Ll]+[Kk][0-9]+)(.*)"
	String BLregExprStr = "([Bb][Ll][Kk][0-9]+)(.*)"
	
	Wave nParamsSum = MPF2_GetNParamsForFuncs(setNumber)
	
	Variable i
	String substring1, substring2

	Variable peakNum, coefNum
	String newVal
	
	do			// check for baseline coefs
		SplitString /E=(BLregExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		
		if (strlen(substring1))		
			sscanf substring1, "%*[Bb]%*[Ll]%*[kK]%i", coefNum
			newVal = "K"+num2str(coefNum)
			
			ret = ReplaceString (substring1, ret, newVal)
		else					
			break
		endif
	while(1)
	
	currPeakString = interPeakConstraintStr
	do			// check for peak coefs
		SplitString /E=(regExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		
		if (strlen(substring1))		
			sscanf substring1, "%*[pP]%i%*[kK]%i", peakNum, coefNum
			newVal = "K"+num2str(nParamsSum[peakNum]+coefNum)
			
			ret = ReplaceString (substring1, ret, newVal)
		else						
			break
		endif
	while(1)
	
	return ret
End

Static Function /S MPF2_StringKToPeakNotation(kString, MPStruct)
	String kString
	STRUCT MPFitInfoStruct &MPStruct

	Variable i, j
	
	Make /Free /N=(MPStruct.nPeaks+1) totalNCoefs
	
	/// get the total number of coefficients for each peak
	Variable doBaseLine = CmpStr(MPStruct.listOfFunctions[0], "None") != 0
	if (doBaseLine)
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(StringFromList(0, MPStruct.listOfFunctions)+BL_INFO_SUFFIX)
		totalNCoefs[0] = ItemsInList(blinfo(BLFuncInfo_ParamNames))
	else
		totalNCoefs[0] = 0
	endif
	
	for (i = 1; i <= MPStruct.nPeaks; i += 1)
		String peakItem = "Peak "+num2istr(i-1)
		
		FUNCREF MPF2_FuncInfoTemplate peakInfoFunc=$(StringFromList(i, MPStruct.listOfFunctions)+PEAK_INFO_SUFFIX)
		totalNCoefs[i] = totalNCoefs[i-1] + ItemsInList(peakInfoFunc(PeakFuncInfo_ParamNames))
	endfor
	
	String regExprStr = "( [Kk][0-9]+ )(.*)"
	
	Variable peakNum, coefNum
	String ParamNames, replacementStr 
	String currPeakString = kString, ret = kString
	String substring1, substring2
	
	do 			// do baseline
		SplitString /E=(regExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		
		if (strlen(substring1))
			sscanf substring1, " %*[kK]%i ", coefNum
			
			for (j=0; j<MPStruct.nPeaks+1; j+=1)
				if (totalNCoefs[j] > coefNum)
					if (j==0)
						FUNCREF MPF2_FuncInfoTemplate blinfo = $(StringFromList(0, MPStruct.listOfFunctions)+BL_INFO_SUFFIX)
						ParamNames = blinfo(BLFuncInfo_ParamNames)
						replacementStr = "Baseline "+StringFromList(coefNum, ParamNames)
					else
						FUNCREF MPF2_FuncInfoTemplate peakInfoFunc=$(StringFromList(j, MPStruct.listOfFunctions)+PEAK_INFO_SUFFIX)
						ParamNames = peakInfoFunc(PeakFuncInfo_ParamNames)
						replacementStr = " Peak "+num2str(j-1)+" "+StringFromList(coefNum-totalNCoefs[j-1], ParamNames)+" "
					endif
					break
				endif
			endfor
			
			if (strlen(replacementStr))
				ret = ReplaceString(substring1, ret, replacementStr)
			endif
		else
			break
		endif		
		
	while(1)	
	
	return ret
End

Static Function /S MPF2_interPeakToStringList(setNumber, interPeakConstraintStr)
	Variable setNumber
	String interPeakConstraintStr

	String ret = ""
	
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	SVAR gname = $(DFpath+":GraphName")
	
	String currPeakString = interPeakConstraintStr, substring1, substring2  
	String regExprStr = "([Pp][0-9]+[Kk][0-9]+)(.*)"
	String BLregExprStr = "([Bb][Ll][Kk][0-9]+)(.*)"
	
	Variable peakNum, coefNum, theRow
	String ParamNames
	
	do 			// do baseline
		SplitString /E=(BLregExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		
		if (strlen(substring1))
			sscanf substring1, "%*[Bb]%*[Ll]%*[kK]%i", coefNum
			
			Variable BaselineRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Baseline")
			String baselineStr = WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, BaselineRow)
			if (CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0)
				String BL_FuncName
				String BL_TypeName = MPF2_PeakOrBLTypeFromListString(baselineStr)
		
				FUNCREF MPF2_FuncInfoTemplate blinfo = $(BL_typename + BL_INFO_SUFFIX)
				ParamNames = blinfo(BLFuncInfo_ParamNames)
			
				ret=ReplaceStringByKey(substring1, ret, "Baseline, "+StringFromList(coefNum, ParamNames))
			endif
		else
			break
		endif
	while(1)
	
	currPeakString = interPeakConstraintStr
	do 			// do peaks
		SplitString /E=(regExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		
		if (strlen(substring1))
			sscanf substring1, "%*[pP]%i%*[kK]%i", peakNum, coefNum
			
			Wave coefs = $(DFpath+":'Peak "+num2istr(peakNum)+" Coefs'")		// ST: assign waves in the correct MPF folder
			theRow = WMHL_GetRowNumberForItem(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", "Peak "+num2istr(peakNum))
			String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(gname+"#MultiPeak2Panel#P1", "MPF2_PeakList", 0, theRow) )
		
			FUNCREF MPF2_FuncInfoTemplate infoFunc=$(PeakTypeName+PEAK_INFO_SUFFIX)
			ParamNames = infoFunc(PeakFuncInfo_ParamNames)
			
			ret=ReplaceStringByKey(substring1, ret, "Peak "+num2str(peakNum)+", "+StringFromList(coefNum, ParamNames))
		else
			break
		endif
	while(1)

	return ret
End

// Get a list of peak function info from the UI
Static Function /WAVE MPF2_GetNParamsForFuncs(setNumber)
	Variable setNumber

	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)

	Wave/Z wpi = DFRpath:W_AutoPeakInfo
	Variable nPeaks
	if (WaveExists(wpi))
		nPeaks =  DimSize(wpi, 0)
	else 
		nPeaks = 0
	endif
	
	Make /O/FREE/N=(nPeaks+1) ret
	
	SVAR gname = DFRpath:GraphName
	String listPanelName = gname+"#MultiPeak2Panel#P1"
	
	Variable nBLParams
	String ParamNameList
	String pwname
	Variable i
	
	Variable BaselineRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", "Baseline")
	String baselineStr = WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, BaselineRow)
	String listOfFunctions = MPF2_PeakOrBLTypeFromListString(baselineStr)+";"
	Variable doBaseLine = CmpStr(baselineStr, "None"+MENU_ARROW_STRING) != 0

	if (doBaseLine)
		FUNCREF MPF2_FuncInfoTemplate blinfo = $(StringFromList(0, listOfFunctions)+BL_INFO_SUFFIX)
		ret[0] = ItemsInList(blinfo(BLFuncInfo_ParamNames))
	else
		ret[0] = 0
	endif
	
	for (i = 1; i <= nPeaks; i += 1)
		String peakItem = "Peak "+num2istr(i-1)
		Variable theRow = WMHL_GetRowNumberForItem(listPanelName, "MPF2_PeakList", peakItem)
		String PeakTypeName = MPF2_PeakOrBLTypeFromListString( WMHL_GetExtraColumnData(listPanelName, "MPF2_PeakList", 0, theRow) )+PEAK_INFO_SUFFIX
		
		FUNCREF MPF2_FuncInfoTemplate peakInfoFunc=$PeakTypeName
		ret[i] = ret[i-1] + ItemsInList(peakInfoFunc(PeakFuncInfo_ParamNames))
	endfor

	return ret
End

Function MPF2_MakeExtraConstraintsPanel(Variable SetNumber)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)
	
	SVAR gname = $(DFpath+":GraphName")
	String MPF2PanelName = gname+"#MultiPeak2Panel"

	String NewPanelName = "MPF2_AdditionalConstraints_"+num2str(SetNumber)
	if (WinType(NewPanelName) == 7)
		DoWindow/F $NewPanelName
	else
		Variable/G $(dfPath+":DoEqualHeightsContraint") = NumVarOrDefault(dfPath+":DoEqualHeightsContraint", 0)
		NVAR DoEqualHeightsContraint = $(dfPath+":DoEqualHeightsContraint")
		Variable/G $(dfPath+":DoEqualWidthsContraint") = NumVarOrDefault(dfPath+":DoEqualWidthsContraint", 0)
		NVAR DoEqualWidthsContraint = $(dfPath+":DoEqualWidthsContraint")
		Variable/G $(dfPath+":DoPairedLocationConstraint") = NumVarOrDefault(dfPath+":DoPairedLocationConstraint", 0)
		NVAR DoPairedLocationConstraint = $(dfPath+":DoPairedLocationConstraint")
		Variable/G $(dfPath+":PairedLocationDistance") = NumVarOrDefault(dfPath+":PairedLocationDistance", 0)
		NVAR PairedLocationDistance = $(dfPath+":PairedLocationDistance")
		String/G $(dfPath+":interPeakConstraints") = StrVarOrDefault(dfPath+":interPeakConstraints", "")
		SVAR interPeakConstraints = $(dfPath+":interPeakConstraints")

		Variable factor = PanelResolution(NewpanelName)/ScreenResolution
		Variable totWidth = 360
		Variable totHeight = 480
		NewPanel/W=(100, 100, 100+totWidth, 100+totHeight)/K=1 as "Additional Constraints for Set "+num2str(SetNumber)		// ST: width reduced from 478 => 380 as constraints are in paragraphs now
		RenameWindow $S_name, $NewPanelName
		GetWindow $MPF2PanelName, wsize
		MoveWindow/W=$NewPanelName V_left +70, V_top + 90, V_left + 70 + totWidth*factor, V_top + 90 + totHeight*factor		// ST: width reduced further + make appear above MPF panel
		
		//TitleBox MPF2_ConstraintsExample,pos={6.00,10.00},size={162.00,13.00},title="Example: P1K0>P0K0; P2K1<P3K1;"
		//TitleBox MPF2_ConstraintsExample,fSize=10,frame=0
		
		TitleBox MPF2_InterPeakConstrTitle,pos={6.00,10.00},size={112.00,13.00},frame=0,title="\f01Inter-Peak Constraints:\f00\r(Example: P1K0>P0K0; P2K1<P3K1*2; P1K1=P2K1+1.5;)"		// ST 2.47: extended examples		
		TitleBox MPF2_ConstrIncreaseDecreasePeakNumTitle,pos={6.00,47.00},size={100,20.00},frame=0,title="Change Peak Numbers in Selected Text:"										// ST:	added buttons to shift all peak numbers
		Button MPF2_ConstrDecreasePeakNumButton,pos={totWidth-116,45},size={50.00,20.00},title="Lower",fsize=10,proc=MPF2_MoreConstraintsIncreaseDecreaseProc
		Button MPF2_ConstrIncreasePeakNumButton,pos={totWidth-56,45},size={50.00,20.00},title="Raise",fsize=10,proc=MPF2_MoreConstraintsIncreaseDecreaseProc
		
		DefineGuide UGH0={FT,70},UGH1={FB,-260}
		NewNotebook /F=1 /N=MPF2_ConstraintExpressions /W=(118,56,355,108)/FG=(FL,UGH0,FR,UGH1) /HOST=# 
		Notebook kwTopWin, defaultTab=36, autoSave= 1, magnification=100, showRuler=0, rulerUnits=1
		Notebook kwTopWin newRuler=Normal, justification=0, margins={0,0,349}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		Notebook kwTopWin text = ReplaceString(";",interPeakConstraints, "\r")												// ST 2.47: improve readability by aligning the text
		RenameWindow #,MPF2_ConstraintExpressions
		
		SetActiveSubwindow ##
		NewPanel/W=(58,185,473,330)/FG=(FL,UGH1,FR,FB)/HOST=# 
		ModifyPanel frameStyle=0
		CheckBox MPF2_AllHeightsEqualConstraint,pos={18.00,22.00},size={160.00,16.00},title="All Heights or Areas Equal (Coefficient K2)"
		CheckBox MPF2_AllHeightsEqualConstraint, Variable=DoEqualHeightsContraint, proc=MPF2_MoreExtraConstraintsCheckProc
		CheckBox MPF2_AllWidthsEqualConstraint,pos={18.00,41.00},size={160.00,16.00},title="All Widths Equal (Coefficient K1)"
		CheckBox MPF2_AllWidthsEqualConstraint, Variable=DoEqualWidthsContraint, proc=MPF2_MoreExtraConstraintsCheckProc
		CheckBox MPF2_PairedLocationsConstraint,pos={18.00,60.00},size={163.00,16.00},title="Paired Locations (Coefficient K0)"
		CheckBox MPF2_PairedLocationsConstraint, variable=DoPairedLocationConstraint, proc=MPF2_MoreExtraConstraintsCheckProc
		SetVariable MPF2_PairedLocationsSeparation,pos={230.00,58.00},bodywidth=60,size={110.00,16.00},title="Separation"	// ST 2.47: position adjusted
		SetVariable MPF2_PairedLocationsSeparation,value=PairedLocationDistance,limits={0,inf,0},proc=MPF2_MoreExtraConstraintsSetVarProc
		GroupBox MPF2_ExtraConstraintsGroup,pos={7.00,11.00},size={366.00,218.00}
		Button MPF2_MoreConstraintsDoneButton,pos={166.00,234.00},size={50.00,20.00},title="Done",proc=MPF2_MoreConstraintsDoneProc
		DefineGuide UGV0={FL,18},UGH0={FB,-42},UGV1={FR,-18},UGH1={FT,83}
		NewNotebook /F=1 /N=MPF2_MoreExtraConstraints/OPTS=8/W=(100,45,285,175)/FG=(UGV0,UGH1,UGV1,UGH0) /HOST=# 
		Notebook kwTopWin, defaultTab=36, autoSave= 1, magnification=100, showRuler=0, rulerUnits=1
		Notebook kwTopWin newRuler=Normal, justification=0, margins={0,0,301}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		RenameWindow #,MPF2_MoreExtraConstraints
		SetActiveSubwindow ##
		RenameWindow #,P0
		SetActiveSubwindow ##
		
		SetWindow $NewPanelName, hook(resizehook) = MPF2_MoreConstraintsResizeHook
		SetWindow $NewPanelName, sizelimit={totWidth*factor, totHeight*factor, inf, inf}									// ST: minimal width reduced
		SetWindow $NewPanelName, userdata(MPF2_DataSetNumber)=num2str(setnumber)
		SetWindow $NewPanelName, hook(extraConstraintsHook)=MPF2_ExtraConstraintsNotebookHook

		MPF2_MoreConstraintsControlProc(NewPanelName+"#P0")
	endif
end

static Function MPF2_MoreConstraintsControlProc(String panelName)
	String basePanelName = StringFromList(0, panelName, "#")
	Variable setNumber = str2num(GetUserData(basePanelName, "", "MPF2_DataSetNumber"))
	String expressions = ""
	ControlInfo/W=$(panelName) MPF2_AllHeightsEqualConstraint																// ST: 210219 - height constraint added
	if (V_value != 0)
		expressions += MPF2_GenerateEqualConstraints(setNumber,2)
	endif
	ControlInfo/W=$(panelName) MPF2_AllWidthsEqualConstraint
	if (V_value != 0)
		expressions += MPF2_GenerateEqualConstraints(setNumber,1)															// ST: 210219 - multipurpose constraints list generator
	endif
	ControlInfo/W=$(panelName) MPF2_PairedLocationsConstraint
	if (V_value != 0)
		ControlInfo/W=$(panelName) MPF2_PairedLocationsSeparation
		expressions += MPF2_generatePairedLocationConstraints(setNumber, V_value)
	endif
	String nb = basePanelName+"#P0#MPF2_MoreExtraConstraints" 
	Notebook $nb, selection={startOfFile, endOfFile}, text=""
	expressions = ReplaceString(";", expressions, "\r")
	Notebook $nb, text=expressions
end

Function MPF2_MoreExtraConstraintsCheckProc(struct WMCheckBoxAction & s) : CheckBoxControl
	if (s.eventCode == 2)		// mouse up
		MPF2_MoreConstraintsControlProc(s.win)
	endif
end

Function MPF2_MoreExtraConstraintsSetVarProc(struct WMSetVariableAction & s) : SetVariableControl
	if (s.eventCode == 1 || s.eventCode == 2 || s.eventCode == 3)		// mouse up, enter key, live update
		MPF2_MoreConstraintsControlProc(s.win)
	endif
end

Function MPF2_MoreConstraintsDoneProc(struct WMButtonAction & s) : ButtonControl

	if (s.eventCode == 2)		// mouse up
		String basewin = StringFromList(0, s.win, "#")
		KillWindow $basewin
	endif
end

Function MPF2_MoreConstraintsResizeHook(struct WMWinHookStruct & s)

	if (CmpStr(s.eventName, "resize") == 0)
		String basename = StringFromList(0, s.winName, "#")
		String subpanel = basename + "#P0"
		GetWindow $subpanel, wsize
		Variable panelwidth = V_right - V_left
		Variable panelhcenter = (V_right + V_left)/2
		ControlInfo/W=$subpanel MPF2_ExtraConstraintsGroup
		GroupBox MPF2_ExtraConstraintsGroup, win=$subpanel, size={panelwidth - 12, V_height}
		ControlInfo/W=$subpanel MPF2_MoreConstraintsDoneButton
		Variable bwidth = (V_right - V_left)
		Button MPF2_MoreConstraintsDoneButton, win=$subpanel, pos={panelhcenter - bwidth/2, V_top}
	endif
end

// Returns semicolon-separated list of constraint expressions
Function/S MPF2_generatePairedLocationConstraints(Variable SetNumber, Variable separation)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	Variable nPeaks
	if (WaveExists(wpi))
		nPeaks =  DimSize(wpi, 0)
	else 
		return ""
	endif
	
	String sepstr
	sprintf sepstr,"%.15g",separation
	String constraintsList = ""
	Variable i
	for (i = 1; i < nPeaks; i += 2)
		constraintsList += "P"+num2str(i)+"K0>P"+num2str(i-1)+"K0+"+sepstr+";"
		constraintsList += "P"+num2str(i)+"K0<P"+num2str(i-1)+"K0+"+sepstr+";"
	endfor
	
	return constraintsList
end

// Returns semicolon-separated list of constraint expressions
Function/S MPF2_GenerateEqualConstraints(Variable SetNumber, Variable whichCoef)					// ST: 210219 - converted into general constraint list generator
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)

	Wave/Z wpi = $(DFPath+":"+"W_AutoPeakInfo")
	Variable nPeaks
	if (WaveExists(wpi))
		nPeaks =  DimSize(wpi, 0)
	else 
		return ""
	endif
	
	whichCoef = round(whichCoef)																	// ST: 210219 - make sure we have a valid integer between 0 and 2
	if (whichCoef < 0 || whichCoef > 2)
		return ""
	endif
	
	String constraintsList = ""
	Variable i
	for (i = 1; i < nPeaks; i += 1)
		constraintsList += "P"+num2str(i)+"K"+num2str(whichCoef)+">P0K"+num2str(whichCoef)+";"
		constraintsList += "P"+num2str(i)+"K"+num2str(whichCoef)+"<P0K"+num2str(whichCoef)+";"
	endfor
	
	return constraintsList
end

Function MPF2_MoreConstraintsIncreaseDecreaseProc(struct WMButtonAction & s) : ButtonControl		// ST: function to shift the peak numbering up or down
	
	if (s.eventCode == 2)		// mouse up
		GetSelection notebook, $(s.win+"#MPF2_ConstraintExpressions"), 2
		String CurrentSelection = S_Selection
		
		GetSelection notebook, $(s.win+"#MPF2_ConstraintExpressions"), 1
		Variable selstartpara = V_startParagraph
		Variable selstartpos = V_startPos
		Variable selendpara = V_endParagraph
		Variable selendpos = V_endPos
		
		Notebook $(s.win+"#MPF2_ConstraintExpressions"), selection={startOfFile,(selstartpara, selstartpos)}
		GetSelection notebook, $(s.win+"#MPF2_ConstraintExpressions"), 2
		String BeforeSelection = S_Selection
		
		Notebook $(s.win+"#MPF2_ConstraintExpressions"), selection={(selendpara, selendpos),endOfFile}
		GetSelection notebook, $(s.win+"#MPF2_ConstraintExpressions"), 2
		String AfterSelection = S_Selection
		
		Notebook $(s.win+"#MPF2_ConstraintExpressions"), selection={startOfFile, endOfFile}
		GetSelection notebook, $(s.win+"#MPF2_ConstraintExpressions"), 2
		String FullConstraints = S_Selection	

		if (strlen(CurrentSelection) > 0)
			Variable setNumber = GetSetNumberFromWinName(s.win)
			String DFpath = MPF2_FolderPathFromSetNumber(setNumber)	
			Wave nPeaksNCoefs = MPF2_GetNParamsForFuncs(setNumber)
			Variable PeakNo = DimSize(nPeaksNCoefs,0)-1
			
			SVAR /Z interPeakString = $(DFPath+":interPeakConstraints")
			if (!SVAR_exists(interPeakString))
				String /G $(DFPath+":interPeakConstraints")
				SVAR interPeakString = $(DFPath+":interPeakConstraints")
			endif
			
			Variable NoDecrease = GrepString(CurrentSelection,"[pP]0")													// make sure the peak number cannot exceed the actual peak count
			Variable NoIncrease = GrepString(CurrentSelection,"[pP]"+num2str(PeakNo-1))
			
			String CheckOBPeaks = CurrentSelection																		// ST: 201126 - also check for out-of-bounds peak numbers (= higher numbers which do not exist)
			CheckOBPeaks = ReplaceString("P", CheckOBPeaks, ";")
			CheckOBPeaks = ReplaceString("p", CheckOBPeaks, ";")
			CheckOBPeaks = ReplaceString("K", CheckOBPeaks, ";")
			CheckOBPeaks = ReplaceString("k", CheckOBPeaks, ";")
			CheckOBPeaks = SortList(CheckOBPeaks,";",3)

			Variable MaxNo = str2num(StringFromList(0,CheckOBPeaks))
			if (numtype(MaxNo) == 0 && MaxNo > PeakNo-1)
				NoIncrease = 1
				PeakNo = MaxNo
			endif
			
			Variable i
			StrSwitch(s.ctrlName)
				case "MPF2_ConstrDecreasePeakNumButton":
					if (!NoDecrease)
						for (i = PeakNo; i > -1; i -= 1)																// ST: 201009 - start from the highest number
							CurrentSelection = ReplaceString("P"+num2str(i), CurrentSelection, "T"+num2str(i-1), 1)		// ST: 201009 - make sure numbers are not replaced twice by temporarily switching to another letter
							CurrentSelection = ReplaceString("p"+num2str(i), CurrentSelection, "t"+num2str(i-1), 1)
						endfor
					endif
				break
				case "MPF2_ConstrIncreasePeakNumButton":
					if (!NoIncrease)
						for (i = PeakNo; i > -1; i -= 1)
							CurrentSelection = ReplaceString("P"+num2str(i), CurrentSelection, "T"+num2str(i+1), 1)
							CurrentSelection = ReplaceString("p"+num2str(i), CurrentSelection, "t"+num2str(i+1), 1)
						endfor
					endif
				break
			EndSwitch
			
			CurrentSelection = ReplaceString("T", CurrentSelection, "P")												// ST: 201009 - switch back to 'p'
			CurrentSelection = ReplaceString("t", CurrentSelection, "p")
			
			FullConstraints = BeforeSelection+CurrentSelection+AfterSelection
			
			Variable origLength = strlen(StringFromList(ItemsInList(interPeakString)-1,interPeakString))				// ST: 201009 - check if the length of the last entry has changed to adjust the selection accordingly
			
			interPeakString = FullConstraints		// copy to interPeakString and sanitize
			interPeakString += ";"
			interPeakString = ReplaceString("\n", interPeakString, ";")
			interPeakString = ReplaceString("\r", interPeakString, ";")
			interPeakString = ReplaceString(" ", interPeakString, "")
			interPeakString = ReplaceString("\t", interPeakString, "")
			interPeakString = RemoveFromList("",interPeakString)
			
			Variable newLength = strlen(StringFromList(ItemsInList(interPeakString)-1,interPeakString))
			
			Notebook $(s.win+"#MPF2_ConstraintExpressions"), text=FullConstraints
		endif
		
		Notebook $(s.win+"#MPF2_ConstraintExpressions"), selection={(selstartpara, selstartpos),(selendpara, selendpos+(newLength-origLength))}, findText={"",1}
	endif
end

// Validate an interpeak constraint string.  Pop up an alert if there's a detectable problem.
// JW 190410 Cannot determine if you have entered something totally off-the-wall like "xxx;"
// ST 210501 Added a few more checks to catch things like "xxx;"
Function MPF2_ValidateConstraint(setNumber, win, interPeakConstraints, [doErrPanel])
	Variable setNumber
	String win, interPeakConstraints
	Variable doErrPanel
	
	if (ParamIsDefault(doErrPanel))
		doErrPanel = 1
	endif
	
	Wave nPeaksNCoefs = MPF2_GetNParamsForFuncs(setNumber)
	String DFpath = MPF2_FolderPathFromSetNumber(setNumber)	

	String constraintsStr = interPeakConstraints
		
	String errList = ""
	String keyList = ""
		
	String currPeakString, substring1, substring2, invalidPart
	String regExprStr = "([Pp][0-9]+[Kk][0-9]+)(.*)"
	String BLregExprStr = "([Bb][Ll][Kk][0-9]+)(.*)"
	String invalidExprStr = "([^+-/*^=><();[:digit:]]+)(.*)" 				// ST: 210501 - invalid expressions are everything other than the letters p,bl,k (will be checked for later), numbers or mathematical expressions
	
	Variable peakNum, coefNum, theRow
	Variable nChars = strlen(interPeakConstraints)
	Variable currChar = 0
	Variable i
	String ParamNames
	
	String vaildFunctions = RemoveFromList("x;y;z;t;p;q;r;s;i;e;",FunctionList("!MPF*",";","KIND:3,VALTYPE:1"))
	String reduced_constrains = constraintsStr
	for (i=0; i<ItemsInList(vaildFunctions); i++) 							// ST: 210501 - exclude functions from check
		reduced_constrains = ReplaceString(StringFromList(i,vaildFunctions),reduced_constrains,"")
	endfor
	
	currPeakString = reduced_constrains
	do 			// ST: 210501 - check for invalid characters
		SplitString /E=(invalidExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		if (GrepString(substring1,"(?<![a-zA-Z])[PpKkEe](?![a-zA-Z])"))		// ST: 210504 - is this a lonely e, p or k?
			continue
		endif
		if (GrepString(substring1,"(?<![a-zA-Z])[Bb][Ll][Kk](?![a-zA-Z])"))	// ST: 210504 - is this a lonely blk?
			continue
		endif
		currChar += strlen(substring1)
		if (strlen(substring1))
			errList += substring1+":> Invalid expression '"+substring1+"' found.;"
			if (FindListItem(substring1, keyList) == -1)
				keyList += substring1+";"
			endif
		else
			break
		endif
	while(1)
	
	for (i=0; i<ItemsInList(keyList); i++) 									// ST: 210501 - exclude invalid expressions from check
		reduced_constrains = ReplaceString(StringFromList(i,keyList),reduced_constrains,"")
	endfor
	currPeakString = reduced_constrains
	do 			// ST: 210501 - check for parameters without number
		SplitString /E=("([PpKk][^0-9])(.*)") currPeakString, substring1, substring2
		currPeakString = substring2
		currChar += strlen(substring1)
		
		if (strlen(substring1))
			invalidPart = reduced_constrains[0,strsearch(reduced_constrains,substring1,0)] 	// ST: 210501 - cut the string until the problematic part
			reduced_constrains = ReplaceString(invalidPart,reduced_constrains,"") 			// ST: 210504 - remove this section for the next round (to find multiple problematic coefficients)
			invalidPart = StringFromList(ItemsInList(invalidPart)-1,invalidPart) 			// ST: 210501 - extract element with problematic part (may be the full line if last letter is the problem)
			SplitString /E=("([PpKk])(.*)") substring1, substring1, substring2
			
			if (strlen(substring1))
				errList += invalidPart+":> Missing number after "+substring1+" in '"+invalidPart+"'.;"
				if (FindListItem(invalidPart, keyList) == -1)
					keyList += invalidPart+";"
				endif
			endif	
		else
			break
		endif
	while(1)

	currPeakString = constraintsStr
	do 			// do baseline
		SplitString /E=(BLregExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		currChar += strlen(substring1)
	
		if (strlen(substring1))
			sscanf substring1, "%*[Bb]%*[Ll]%*[kK]%i", coefNum
			
			if (coefNum >= nPeaksNCoefs[0])
				errList += substring1+":> Baseline coefficient number "+num2str(coefNum)+" is out of range.;"
				//if (!StringMatch(keyList, substring1+";"))
				if (FindListItem(substring1, keyList) == -1) 								// ST: 210504 - FindListItem is more robust here
					keyList += substring1+";"
				endif
			endif		
		else
			break
		endif
	while(1)
	
	currPeakString = constraintsStr
	do 			// do peaks
		SplitString /E=(regExprStr) currPeakString, substring1, substring2
		currPeakString = substring2
		currChar += strlen(substring1)
		
		if (strlen(substring1))
			sscanf substring1, "%*[pP]%i%*[kK]%i", peakNum, coefNum
		
			if (peakNum+1 >= DimSize(nPeaksNCoefs, 0))
				errList = ReplaceStringByKey(substring1,errList,"> There is no Peak "+num2str(peakNum)+".")
				if (!StringMatch(keyList, substring1+";"))
					keyList += substring1+";"
				endif
			elseif (coefNum >= (nPeaksNCoefs[peakNum+1]-nPeaksNCoefs[peakNum]))
				errList = ReplaceStringByKey(substring1,errList,"> Peak "+num2str(peakNum)+" coefficient number "+num2str(coefNum)+" is out of range.")
				//if (!StringMatch(keyList, substring1+";"))
				if (FindListItem(substring1, keyList) == -1) 								// ST: 210504 - FindListItem is more robust here
					keyList += substring1+";"
				endif
			endif
		else
			break
		endif
	while(1)
	
	if (currChar==0 && nChars!=0)
		KeyList += "All;"
		errList += "All:> Your constraints are in an invalid format.;"
	endif	
	
	if (strlen(errList))
		String errorString="", currKey=""
		for (i=0; i<ItemsInList(keyList); i+=1)
			currKey = StringFromList(i, keyList) 
			//constraintsStr = ReplaceString(currKey, constraintsStr, "\K(65535,0,0)"+currKey+"\K(0,0,0)")
			if (i>0)
				errorString += "\r"
			endif
			errorString += StringByKey(currKey, errList)
		endfor
		
		String /G $(DFpath+":MPF2InterPeakErrStr")
		SVAR interPeakErrStr = $(DFpath+":MPF2InterPeakErrStr")
		interPeakErrStr = errorString

		Variable middleX, middleY
		Variable height = 360 + ItemsInList(errorString,"\r") * 12											// ST: 201126 - increase the size of the panel depending on the number of errors
		Variable width = 300

		if (strlen(win))
			String panelName = ParseFilePath(1, win, "#", 1, 0)
			panelName = panelName[0, strlen(panelName)-2]	
		
			GetWindow $panelName wsize
			middleX = (V_left + V_right)/2
			middleY = (V_top + V_bottom)/2
		else
			Variable scrnLeft, scrnTop, scrnRight, scrnBottom, scrnWidth, scrnHeight
			if (CmpStr(IgorInfo(2), "Macintosh") == 0)
				String scrnInfo = StringByKey("SCREEN1", IgorInfo(0))
				Variable rectPos = strsearch(scrnInfo, "RECT=", 0)
				scrnInfo = scrnInfo[rectPos+5, strlen(scrnInfo)-1]
				sscanf scrnInfo, "%d,%d,%d,%d", scrnLeft, scrnTop, scrnRight, scrnBottom
				scrnWidth = scrnRight-scrnLeft
				scrnHeight = scrnBottom-scrnTop
			elseif (CmpStr(IgorInfo(2), "Windows") == 0)
				GetWindow kwFrameInner, wsize
				scrnWidth = V_right-V_left
				scrnHeight = V_bottom-V_top
			endif
			
			middleX = scrnWidth/2
			middleY = scrnHeight/2
		endif
		
		Variable panelFSize = 12
			
		if (doErrPanel)
			DoWindow/F InterPeakConstraintErrorPanel
			String NoteName = "InterPeakConstraintErrorPanel#ConstraintStringNote"
			if (V_flag == 0)		// Panel doesn't exist
				NewPanel /N=InterPeakConstraintErrorPanel /W=(middleX-width/2, middleY-height/2, middleX+width/2, middleY+height/2)/K=1 as "Inter-Peak Constraints Error"
				ModifyPanel /W=InterPeakConstraintErrorPanel ,fixedSize= 1 ,noEdit=1						// ST: 201126 - fix panel size
				
				TitleBox ConstraintStringTitle win=InterPeakConstraintErrorPanel, pos={10, 5}, size={width-20, 15}, title="Inter-Peak Constraints String:", fstyle=1, frame=0, fsize=panelFSize
				//TitleBox ConstraintString win=InterPeakConstraintErrorPanel, pos={10, 25}, size={width-20, 40}, title=constraintsStr, fsize=panelFSize, frame=5
				DefineGuide UGH0={FT,30},UGH1={FT,260}														// ST: 201126 - add a proper colored notebook to the error panel
				NewNotebook /F=1 /N=ConstraintStringNote /W=(100,50,350,100)/FG=(FL,UGH0,FR,UGH1) /HOST=# 
				Notebook $(NoteName) textRGB=(0,0,0), text = ReplaceString(";",constraintsStr, "\r")
				
				TitleBox ErrorsTitle win=InterPeakConstraintErrorPanel, pos={10, 270}, size={width-20, 15}, title="Errors:", fstyle=1, frame=0, fsize=panelFSize
				TitleBox Errors win=InterPeakConstraintErrorPanel, pos={10, 295}, size={width-20, 60}, variable=interPeakErrStr, fsize=panelFSize, frame=5

				Button OKButton win=InterPeakConstraintErrorPanel, pos={width/2-30, height-30}, size={60,20}, title="OK", proc=InterPeakErrorOK, fsize=panelFSize, fColor=(1,34817,52428)
				SetWindow InterPeakConstraintErrorPanel hook(MPF2_OK)=MPF2_OKProcedure
			else
				Notebook $(NoteName) selection={startOfFile, endOfFile}										// ST: 201126 - just update the notebook text
				Notebook $(NoteName) textRGB=(0,0,0), text = ReplaceString(";",constraintsStr, "\r")
				//TitleBox ConstraintString win=InterPeakConstraintErrorPanel, title=constraintsStr
			endif
			
			Notebook $(NoteName) selection={startOfFile,startOfFile}, findText={"",1}						// ST: 201126 - color all faulty keys in the notebook in red
			for (i=0; i<ItemsInList(keyList); i+=1)
				currKey = StringFromList(i, keyList)
				do																							// ST: 210504 - mark ALL expressions in the text
					Notebook $(NoteName) findText={currKey,1}, textRGB=(65535,0,0)
				while (V_flag == 1)
				Notebook $(NoteName) selection={startOfFile,startOfFile}, findText={"",1}					// ST: 210501 - re-select all text
			endfor
			Notebook $(NoteName) selection={startOfFile,startOfFile}, findText={StringFromList(0, keyList),1}
		endif
		
		return 0			
	else
		DoWindow/F InterPeakConstraintErrorPanel
		if (V_flag == 0)
			DoWindow /K InterPeakConstraintErrorPanel
		endif
	endif
	
	return 1
End	

Function MPF2_OKProcedure(s)
	STRUCT WMWinHookStruct &s
	Variable statusCode= 0
	
	strswitch( s.eventName )
		case "keyboard":
			if (s.keycode==13) // Carriage Return, or Enter Key
				DoWindow /K $(s.winName)
			endif
			break
	endswitch

	return statusCode
End

Function InterPeakErrorOK(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			DoWindow /K $(ba.win)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function UpdateMultiPeak2Panel(srcPanelName, setNumber)
	String srcPanelName
	Variable setNumber

	Variable MultiPeakPanelLocation = strsearch(srcPanelName, "#MultiPeak2Panel", 0)
	String panelName = srcPanelName[0, MultiPeakPanelLocation+15]
		
	String updatePanelStr = GetUserData(panelName, "", "MPF2_UPDATEPANELVERSION")
	if (!strlen(updatePanelStr) || str2num(updatePanelStr) < MPF2_UPDATEPANELVERSION)
		DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
		SVAR gname = DFRpath:GraphName		
		SVAR /Z interPeakString = DFRpath:interPeakConstraints
		
		if (SVAR_exists(interPeakString) && strlen(interPeakString)==0)										// ST: 201229 - copy inter-peak constraints from old MPF panels (Igor 6)
			String CheckPanel=WinRecreation(panelName + "#P3", 0)											// ST: 201229 - specifically look for sub-panel 'P3'
			if (StringMatch(CheckPanel,"*MPF2_InterPeakConstraints*"))										// ST: 201229 - check if notebook is available
				String notebookName = panelName + "#P3#MPF2_InterPeakConstraints"
				Notebook $(panelName + "#P3#MPF2_InterPeakConstraints"), selection={startOfFile, endOfFile}
				GetSelection notebook, $(panelName + "#P3#MPF2_InterPeakConstraints"), 2
				interPeakString = S_Selection[0, strlen(S_Selection)-1]
				interPeakString += ";"
				interPeakString = ReplaceString("\n", interPeakString, ";")
				interPeakString = ReplaceString("\r", interPeakString, ";")
				interPeakString = RemoveFromList("",interPeakString)
			endif
		endif
		
		Variable useCursorActivated = -1																	// ST: 201229 - copy the Use Cursors status from old MPF panels (Igor 6)
		ControlInfo/W=$(panelName)  MPF2_UserCursorsCheckbox												// ST: 201229 - get the checkbox status (the control is still in the main panel in old versions)
		if (V_Flag==2 && strlen(CsrInfo(A, gname)) > 0 && strlen(CsrInfo(B, gname)) > 0)
			useCursorActivated = V_Value
		endif
		
		KillWindow $srcPanelName
		DoUpdate
		
		NVAR /Z useCursors = DFRPath:MPF2_UserCursors														// ST: 201229 - write cursor status after killing the old panel (which resets the variable via hook)
		if (NVAR_exists(useCursors) && useCursorActivated > -1)
			useCursors = useCursorActivated
		endif
		
		MPF2_ResumeFitSet(setNumber)
	endif
End

Function MPF2_AskAndDoUpdate(Variable setNumber)
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
	SVAR gname = DFRpath:GraphName
	String updatePanelStr = GetUserData(gname+"#MultiPeak2Panel", "", "MPF2_UPDATEPANELVERSION")
	
	Variable lastUpdate = NumVarOrDefault("root:Packages:MultiPeakFit2:lastPanelUpdateNotification", 0)
	if (lastUpdate == MPF2_UPDATEPANELVERSION)	// ST: 200529 - just to make sure and prevent re-execution
		return 0
	endif
	
	if (!strlen(updatePanelStr) || str2num(updatePanelStr) < MPF2_UPDATEPANELVERSION)
		String alertmsg = "This Multipeak Fit panel was created by Multipeak Fit version " + updatePanelStr + ". "
		alertmsg += "It can be updated to the new version " + num2str(MPF2_UPDATEPANELVERSION) + ", but then may not work well with older versions of Multipeak Fit."
		alertmsg += "\r\rUpdate the panel?\rPress No to skip this update alltogether for the current experiment."
		DoAlert /T="Multipeak Fitting Panel Update" 1, alertmsg	
		if (V_flag == 1)
			UpdateMultiPeak2Panel(gname+"#MultiPeak2Panel", setNumber)
			Variable /G root:Packages:MultiPeakFit2:MPF2_PanelVersion = MPF2_UPDATEPANELVERSION
		else
			Variable /G root:Packages:MultiPeakFit2:lastPanelUpdateNotification = MPF2_UPDATEPANELVERSION	// ST: 200529 - remember that the user doesn't want to update this version
		endif
	endif
End

// Below function can be called inside background and peak functions to convey information to the user, like a failed calculation etc.
// The text box is reset to "" upon every update inside MPF2_AddPeaksToGraph(), MPF2_UpdateBaselineOnGraph() and MPF2_UpdateOnePeakOnGraph().

Function MPF2_DisplayStatusMessage(String Message, DFREF DFRpath)		// ST: updates the MPF2StatusDisplay text box in the current graph
	SVAR/Z gname = DFRpath:GraphName
	if (SVAR_Exists(gname))
		String AnnoList = AnnotationList(gname)
		if (WhichListItem("MPF2StatusDisplay",AnnoList) > -1)
			TextBox/W=$gname/C/N=MPF2StatusDisplay "\\Zr090\\K(1,4,52428)"+Message
		endif
	endif
End

Function MPF2_DisplayChiSqInfo(Variable setNumber)						// ST: 200906 - updates MPF2ChiSqDisplay to display the latest ChiSquare value
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setNumber)
	SVAR/Z gname = DFRpath:GraphName
	NVAR/Z ChiSq = DFRpath:MPF2_FitChiSq
	if (SVAR_Exists(gname))
		String AnnoList = AnnotationList(gname)
		if (WhichListItem("MPF2ChiSqDisplay",AnnoList) > -1)
			if (NVAR_Exists(ChiSq))
				TextBox/W=$gname/C/N=MPF2ChiSqDisplay "\\Zr090\\K(1,4,52428)Χ\\S2\\M\\Zr090 = " + num2str(ChiSq)
			else
				TextBox/W=$gname/C/N=MPF2ChiSqDisplay ""
			endif
		endif
	endif
End

//*******************************
// Functions for deleting MPF sets
//*******************************

Function  MPF2_CloseAllMPFWindows()
	NVAR/Z currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
	if (!NVAR_Exists(currentSetNumber))
		return -1
	endif
	Variable i
	for (i=1; i<currentSetNumber+1; i+=1)
		DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(i)
		if (DataFolderRefStatus(DFRpath))
			MPF2_CloseAllMPFWindowsForSet(i)
		endif
	endfor
End

Function  MPF2_CloseAllMPFWindowsForSet(Variable setNumber)		// ST: 200804 - closes all MPF related panels but not the main graph
	DFREF DFRpath = MPF2_FolderPathFromSetNumberDFR(setnumber)
	SVAR/Z gname = DFRpath:GraphName
	KillWindow/Z EditOrAddPeaksGraph
	if (SVAR_Exists(gname))
		KillWindow/Z $(gname+"#MultiPeak2Panel")
	endif
	KillWindow/Z $("MPF2_AdditionalConstraints_"+num2str(SetNumber))		
	KillWindow/Z $("MPF2_ResultsPanel_"+num2str(setNumber))
	KillWindow/Z $("MakeResultsGraph_Set_"+num2str(setNumber))
End

Function MPF2_DeleteHighestMPFSetFolder()									// ST: 200803 - deletes the MPF set folder with the currentSetNumber
	NVAR/Z currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
	if (NVAR_Exists(currentSetNumber))
		MPF2_DeleteRequestedMPFSet(currentSetNumber)
	endif
	return 0
End

Function MPF2_DeleteRequestedMPFSet(int requestedSetNumber)					// ST: 230608 - deletes the requested MPF set
	NVAR/Z currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
	if (!NVAR_Exists(currentSetNumber))
		return -1
	endif
	if (currentSetNumber < 1)
		Abort "No Multipeak Fit sets to delete."
	endif
	DFREF setPath = MPF2_FolderPathFromSetNumberDFR(requestedSetNumber)
	if (!DataFolderRefStatus(setPath))
		Abort "Multipeak Fit set "+num2str(requestedSetNumber)+" does not exist."
	endif
	
	DoAlert/T="Deleting Multipeak Fit set "+num2str(requestedSetNumber) 1, "Do you really want to delete fit set " + num2str(requestedSetNumber)+ "? This cannot be undone without reloading the experiment."
	if (V_Flag != 1)
		return -1
	endif
	MPF2_DeleteMPFSetFolder(requestedSetNumber)
	currentSetNumber = FindLowestValidSetNumber(currentSetNumber)
	updateMPFStarterPanelResume()
	return 0
End

static Function FindLowestValidSetNumber(int startNo)
	if (numtype(startNo) !=  0 || startNo < 1)
		return 0
	endif
	do
		DFREF setPath = MPF2_FolderPathFromSetNumberDFR(startNo)
		if (DataFolderRefStatus(setPath))
			break
		endif
		startNo--
	while(startNo > 0)
	return startNo
End

static Function updateMPFStarterPanelResume()								// ST: 230608 - makes sure the starter panel set number is updated
	if (WinType(GetStartPanelName()) != 7)
		return 0
	endif
	NVAR/Z currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
	if (!NVAR_Exists(currentSetNumber))
		return -1
	endif
	if (currentSetNumber == 0)
		rebuildStarterPanelinPlace()
	else
		ControlInfo/W=$GetStartPanelName(tab=1) MPF2_ResumeSetMenu
		Variable setnumber = str2num(S_value)
		Variable newSetNumber = FindLowestValidSetNumber(setnumber)			// ST: 230608 - if the set was selected in the resume part, make sure a lower set gets selected
		if (newSetNumber == 0)
			newSetNumber = FindLowestValidSetNumber(currentSetNumber)		// ST: 230608 - try to find a valid set at higher numbers
		endif
		
		PopupMenu MPF2_ResumeSetMenu		,win=$GetStartPanelName(tab=1), mode=1
		if (newSetNumber > 0)
			PopupMenu MPF2_ResumeSetMenu	,win=$GetStartPanelName(tab=1), popmatch=num2str(newSetNumber)
		endif
		Variable result = MPF2_PopulateResumeNBWithWaveNames(PanelName=GetStartPanelName(tab=1))
		Button MPF2_ResumeButton 			,win=$GetStartPanelName(tab=1), disable=(result ? 0 : 2)
		Button MPF2_RetrieveNewDataFolder	,win=$GetStartPanelName(tab=1), disable=(result ? 1 : 0)
		
		ControlInfo/W=$GetStartPanelName(tab=1) MPF2_DeleteSelectedSet
		if (V_flag)
			Button MPF2_DeleteSelectedSet	,win=$GetStartPanelName(tab=1), disable=(newSetNumber > 0 ? 0 : 1)
		endif
		ControlInfo/W=$GetStartPanelName(tab=1) MPF2_EditSetNotes
		if (V_flag)
			Button MPF2_EditSetNotes		,win=$GetStartPanelName(tab=1), disable=(newSetNumber > 0 ? 0 : 1)
		endif
	endif
End

Function MPF2_DeleteAllMPFSetFolders()							// ST: 200803 - deletes all MPF set folders to start fresh
	NVAR/Z currentSetNumber = root:Packages:MultiPeakFit2:currentSetNumber
	if (!NVAR_Exists(currentSetNumber))
		return -1
	endif
	if (currentSetNumber < 1)
		Abort "No Multipeak Fit sets to delete."
	endif
			
	DoAlert/T="Deleting ALL Multipeak Fit sets" 1, "Do you really want to delete everything? This cannot be undone without reloading the experiment."
	if (V_Flag != 1)
		return -1
	endif
	
	do
		MPF2_DeleteMPFSetFolder(currentSetNumber)
		currentSetNumber -= 1
	while (currentSetNumber > 0)
	
	if (WinType(GetStartPanelName()))							// ST: 200803 - make sure the starter panel is reset to a neutral state here
		rebuildStarterPanelinPlace()
	endif
End

Function MPF2_DeleteMPFSetFolder(Variable setNumber)
	DFREF saveDFR = GetDataFolderDFR()
	String FolderList = MPF2_FolderPathFromSetNumber(setNumber) + "CP;"		// ST: 230608 - CP folders need to be processed FIRST
	FolderList += MPF2_FolderPathFromSetNumber(setNumber)+";"
	
	Variable fnum, i, j
	for(fnum=0; fnum<itemsinlist(FolderList); fnum+=1)
		DFREF DFRpath = $StringFromList(fnum,FolderList)
		if (DataFolderRefStatus(DFRpath) != 0)
			SVAR gname = DFRpath:GraphName						// ST: first kill the related windows from the set
			KillWindow/Z $gname
			MPF2_CloseAllMPFWindowsForSet(setNumber)
			
			SetDataFolder DFRpath
			String ListOfWins=WinList("*",";","WIN:3")
			String ListOfWaves = WaveList("*",";","")			// ST: then remove all waves from all other windows they might be displayed
			for(i=0; i<itemsinlist(ListOfWins); i+=1)
				String CurrWin = StringFromList(i,ListOfWins)  
				for(j=0; j<itemsinlist(ListOfWaves); j+=1)
					String CurrWave = StringFromList(j,ListOfWaves)  
					CheckDisplayed/w=$CurrWin $CurrWave
					if(V_flag)
						if (WinType(CurrWin) == 1)
							RemoveFromGraph/W=$CurrWin $CurrWave
						elseif (WinType(CurrWin) == 2)
							RemoveFromTable/W=$CurrWin $CurrWave
						endif
					endif
				endfor
			endfor
			SetDataFolder saveDFR
			
			KillDataFolder/Z DFRpath							// ST: finally kill the folder
			if (V_Flag)
				Abort "Could not delete set folder " + num2str(setNumber) + " for some reason. Stopping..."
			endif
		endif
	endfor
End