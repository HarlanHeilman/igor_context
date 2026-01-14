#pragma rtGlobals=2		 
 
#include <Graph Utility Procs>
#include <Image Calibration Panels>
#include <Image Common>
#include <Image Contrast>
#include <Image Edge Panel>
#include <Image Grayscale Filters>
#include <Image Histogram Panel>
#include <Image Line Profile>
#include <Image Morphology Panel>
#include <Image Particle Panel>
#include <Image Range Adjust>
#include <Image ROI>
#include <Image Rotate>
#include <Image Threshold Panel>
#include <RemoveBackground>
#include <Marquee2Mask>
#include <ImageTransformPanel>
#include <Image Normalization>
#include <CopyImageSubset>
#include <colorizer>
#include <ImageStats Panel>
#include <wienerFilterImage>
#include <ImageSlider>
#include <3DWaveDisplay>
#include <loadFolderImages>
#include <MovieFromStack>
#include <Image Saver>

Menu "ImageProcs"
	help={"This menu gives you access to various Image Processing panels"}
	"ROI...",						WMCreateImageROIPanel();
	"Stats...",						WMSetupImageStatsPanel();
	"Threshold...",					WMCreateImageThresholdGraph();
	"Edge Detection...",				WMCreateImageEdgePanel();
	"Image Morphology...",			WMCreateImageMorphPanel();
	"Image Histograms...",			WMCreateImageHistPanel();
	"Image Contrast...",				WMCreateImageContrastGraph();
	"Image Range..."	,				WMCreateImageRangeGraph();
	"Convolution Filtering...",		WMCreateImageFilterPanel();
	"Image Line Profiles...",			WMCreateImageLineProfileGraph();
	"Particle Analysis...", 			WMCreateImageParticlePanel();
	"Remove Background...",			WMRemoveBackgroundPanel();
	"Image Transformations...",		ImageTransformPanel();
	"Image Normalization...",		WMNormalizationPanel();
	"Rotate...",						WMCreateImageRotatePanel();
	"Colorize",						CreateColorizerPanel();
	"-",
	"Spatial Calibration...", 			WMCalibration() ;
	"Spatial Measurements...",  		WMSpatialMeasurements();
	"-",
	"Add Slider",					WMAppend3DImageSlider();
	"3D Wave Display",				WM_init3Sliders();
	"Create Movie From Stack...",	WM_MakeStackMovie();
	"-",
	"Load Folder Images...",			loadFolderImagePanel();
	"-",
	"IP Tutorial",					WMOpenTutorial()
End

Function WMOpenTutorial()
	doAlert 2, "The Tutorial is in another experiment.  Do you want to save the current experiment before switching to the tutorial?"
	if(V_Flag==3)		// user hits cancel.
		return 0
	endif
	
	if(V_Flag==1)		// ok to save the experiment
		SaveExperiment
	endif
	
	Execute/P "NEWEXPERIMENT "
	Execute/P "LOADFILE :Learning Aids:Tutorials:Image Processing Tutorial.pxp"		// 12JUL04
End

Function CreateImageProcessingPanel()

	DoWindow/F ImageStrip
	if( V_Flag==1 )
		return 0
	endif
	ImageStripCreate()
end


Function ImStrpButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
//	if( CmpStr(ctrlName,"ImStrpTiffLoad")==0 )
//		if( Exists("WMCreateTiffLoader") )
//			Execute "WMCreateTiffLoader()"
//		else
//			DoAlert 0,"TIFF Loader package not loaded. Use #include (printed to history)."
//			Print "#include <TIFF Loader>"
//		endif
//	endif
//	
//	if( CmpStr(ctrlName,"ImStrpTiffSave")==0 )
//		if( Exists("WMCreateTiffSaver") )
//			Execute "WMCreateTiffSaver()"
//		else
//			DoAlert 0,"TIFF Save package not loaded. Use #include (printed to history)."
//			Print "#include <TIFF Saver>"
//		endif
//	endif

	if( CmpStr(ctrlName,"ImStrpImageRange")==0 )
		if( Exists("WMCreateImageRangeGraph") )
			Execute "WMCreateImageRangeGraph()"
		else
			DoAlert 0,"Image Range package not loaded. Use #include (printed to history)."
			Print "#include <Image Range Adjust>"
		endif
	endif

	if( CmpStr(ctrlName,"ImStrpContrast")==0 )
		if( Exists("WMCreateImageContrastGraph") )
			Execute "WMCreateImageContrastGraph()"
		else
			DoAlert 0,"Image Contrast package not loaded. Use #include (printed to history)."
			Print "#include <Image Contrast>"
		endif
	endif

	if( CmpStr(ctrlName,"ImStrpLinePro")==0 )
		if( Exists("WMCreateImageLineProfileGraph") )
			Execute "WMCreateImageLineProfileGraph()"
		else
			DoAlert 0,"Image Line Profile package not loaded. Use #include (printed to history)."
			Print "#include <Image Line Profile>"
		endif
	endif
 
	if( CmpStr(ctrlName,"ImStrpHist")==0 )
		if( Exists("WMCreateImageHistPanel") )
			Execute "WMCreateImageHistPanel()"
		else
			DoAlert 0,"Image Histogram package not loaded. Use #include (printed to history)."
			Print "#include <Image Histogram Panel>"
		endif
	endif

	if( CmpStr(ctrlName,"ImStrpFilter")==0 )
		if( Exists("WMCreateImageFilterPanel") )
			Execute "WMCreateImageFilterPanel()"
		else
			DoAlert 0,"Image Filter package not loaded. Use #include (printed to history)."
			Print "#include <Image Grayscale Filters>"
		endif
	endif

	if( CmpStr(ctrlName,"ImStrpROI")==0 )
		if( Exists("WMCreateImageROIPanel") )
			Execute "WMCreateImageROIPanel()"
		else
			DoAlert 0,"Image ROI package not loaded. Use #include (printed to history)."
			Print "#include <Image Processing ROI>"
		endif
	endif
	if( CmpStr(ctrlName,"ImStrpMorph")==0 )
		if( Exists("WMCreateImageMorphPanel") )
			Execute "WMCreateImageMorphPanel()"
		else
			DoAlert 0,"Image Morphology package not loaded. Use #include (printed to history)."
			Print "#include <Image Morphology Panel>"
		endif
	endif
	if( CmpStr(ctrlName,"ImStrpEdge")==0 )
		if( Exists("WMCreateImageEdgePanel") )
			Execute "WMCreateImageEdgePanel()"
		else
			DoAlert 0,"Image Edge package not loaded. Use #include (printed to history)."
			Print "#include <Image Edge Panel>"
		endif
	endif
	if( CmpStr(ctrlName,"ImStrpThresh")==0 )
		if( Exists("WMCreateImageThresholdGraph") )
			Execute "WMCreateImageThresholdGraph()"
		else
			DoAlert 0,"Image Threshold package not loaded. Use #include (printed to history)."
			Print "#include <Image Threshold Panel>"
		endif
	endif
	if( CmpStr(ctrlName,"ImStrpRotate")==0 )
		if( Exists("WMCreateImageRotatePanel") )
			Execute "WMCreateImageRotatePanel()"
		else
			DoAlert 0,"Image Rotate package not loaded. Use #include (printed to history)."
			Print "#include <Image Rotate Panel>"
		endif
	endif
	if( CmpStr(ctrlName,"ImStrpPart")==0 )
		if( Exists("WMCreateImageParticlePanel") )
			Execute "WMCreateImageParticlePanel()"
		else
			DoAlert 0,"Image Rotate package not loaded. Use #include (printed to history)."
			Print "#include <Image Particle Panel>"
		endif
	endif
	if( CmpStr(ctrlName,"ImCalibrateButton")==0 )
		if( Exists("WMCalibration") )
			Execute "WMCalibration()"
		else
			DoAlert 0,"Image Calibration package not loaded. Use #include (printed to history)."
			Print "#include <Image Calibration Panels>"
		endif
	endif
	if( CmpStr(ctrlName,"ImMeasureButton")==0 )
		if( Exists("WMSpatialMeasurements") )
			Execute "WMSpatialMeasurements()"
		else
			DoAlert 0,"Image Calibration package not loaded. Use #include (printed to history)."
			Print "#include <Image Calibration Panels>"
		endif
	endif
End

Function ImageStripCreate()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(319,52,462,417)
	DoWindow/C ImageStrip
	SetDrawLayer UserBack
	Button ImStrpTiffLoad,pos={13,8},size={106,20},proc=ImStrpButtonProc,title="Tiff Load"
	Button ImStrpTiffSave,pos={13,28},size={106,20},proc=ImStrpButtonProc,title="Tiff Save"
	Button ImStrpImageRange,pos={13,60},size={106,20},proc=ImStrpButtonProc,title="Image Range"
	Button ImStrpContrast,pos={13,80},size={106,20},proc=ImStrpButtonProc,title="Contrast Adjust"
	Button ImStrpHist,pos={13,195},size={106,20},proc=ImStrpButtonProc,title="Histogram"
	Button ImStrpFilter,pos={13,215},size={106,20},proc=ImStrpButtonProc,title="Filter"
	Button ImStrpROI,pos={13,167},size={106,20},proc=ImStrpButtonProc,title="ROI"
	Button ImStrpROI,help={"Click to draw or edit a Region Of Interest in top image. When finished, click here again."}
	Button ImStrpLinePro,pos={13,137},size={106,20},proc=ImStrpButtonProc,title="Line Profile"
	Button ImStrpMorph,pos={13,235},size={106,20},proc=ImStrpButtonProc,title="Morphology"
	Button ImStrpEdge,pos={13,255},size={106,20},proc=ImStrpButtonProc,title="Edge Detect"
	Button ImStrpThresh,pos={13,275},size={106,20},proc=ImStrpButtonProc,title="Threshold"
	Button ImStrpRotate,pos={13,108},size={106,20},proc=ImStrpButtonProc,title="Rotate"
	Button ImStrpPart,pos={13,295},size={106,20},proc=ImStrpButtonProc,title="Particles"
	Button ImCalibrateButton,pos={13,315},size={106,20},proc=ImStrpButtonProc,title="Calibrate"
	Button ImMeasureButton,pos={13,335},size={106,20},proc=ImStrpButtonProc,title="Measure"
EndMacro
