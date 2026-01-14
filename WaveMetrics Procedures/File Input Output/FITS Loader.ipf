#pragma rtGlobals=2		// Use modern global access and logic ops
#pragma version=2.23

#include <Autosize Images>

// FITS Loader Version 2.2; For use with Igor Pro 6.3 or later
// Version 2.23, 230313
//		Fixed errors if you select "_none found_" from the Unload FITS menu.
//		Fixed errors if your file has keywords that are not legal variable names. Now those keywords
//			are patched up using CleanupName(). So, for instance, "DATE-OBS" loads into a variabl called "DATE_OBS".
// Version 2.22, 191122
//		Support non-standard SIMPLE  = T
// Version 2.21, 171218
//		Fixed number type bug when BITPIX = -64 (double)
// Version 2.2, 160329
//		Added ability to specify subset of BINTABLE fields if data size exceeds a usser set limit.
//		Also 64 bit integers are now supported but full support requres Igor Pro 7.
//		Read and display IMAGE extensions
// Version 2.14, 100316
//		Added MyCleanupFitsFolderName routine.
// Version 2.13, 081127
//		Fix endian problem on Intel Mac
//	Version 2.12
//		Fix for boolean variables.
//	Version 2.11:
//		Fix wave name conflict in BINTABLE load
//		Added support for ascii in BINTABLE.  
//	Version 2.1:
//		Support for multi-row BINTABLE extension.
//	Version 2.0:
//		Support for BINTABLE extension (but only kind where all data is packed into 1 row).
//		Eliminated keyword list in favor of reading ALL keywords into variables.
//	Version 2.0 (beta prior to 8-3):
//		Can now use the fits load routine as a subroutine in a user written procedure. See LoadOneFITS below.
//		Can now specify a list of keywords to suck out of the header. (removed 000807)
//		See FITS Loader Demo example experiment for examples of use including making movies.
//		This version does not create a menu item because the standard WMMenus.ipf file includes one in the
//			Data->Load Waves->Packages menu.  If you would like to have a menu that brings up the
//			panel, copy the commented-out Menu definition below into your procedure window and
//			remove the comment chars.
//	Version 1.02 differs from 1.01 in the use of the /K flag with NewPanel
//		This flag causes the need for 3.11B01.
//		Other changes made include changing of function names to avoid conflict with user names
//	Version 1.01 differs from 1.0 only in the use of FBinRead/B=2 to force bigendian
//		under Windows. This flag causes the need for 3.1.
//
//	This code is intended to be a starting point for a user supported astro package.
//	Documentation is provided in an example experiment named 'FITS Loader Demo'
//	Larry Hutchinson, WaveMetrics inc., 1-19-02

//Menu "Macros"
//	"FITS Loader Panel",CreateFITSLoader()
//End


Function CreateFITSLoader()
	DoWindow/F FITSPanel
	if( V_Flag != 0 )
		return 0
	endif
	

	WMDoFITSPanel()
end
	


Static Function WMLoadFITS()
	Variable doHeader= NumVarOrDefault("root:Packages:FITS:wantHeader",1)			// set true to put header(s) in a notebook
	Variable doHistory= NumVarOrDefault("root:Packages:FITS:wantHistory",0)			// set true to put HISTORY in the notebook
	Variable doComment= NumVarOrDefault("root:Packages:FITS:wantComments",0)		// ditto for COMMENT
	Variable doAutoDisp= NumVarOrDefault("root:Packages:FITS:wantAutoDisplay",0)	// true to display data
	Variable doInt2Float= NumVarOrDefault("root:Packages:FITS:promoteInts",1)		// true convert ints to floats
	Variable bigBytes= NumVarOrDefault("root:Packages:FITS:askifSize",0)				// if data exceeds this size, ask permission to load  
	Variable bigBTBytes= NumVarOrDefault("root:Packages:FITS:askifBTSize",0)				// if BINTABLE exceeds this size, ask permission to load  and provide options
	
	Variable refnum
	String path= StrVarOrDefault("root:Packages:FITS:thePath","")
	if( CmpStr(path,"_current_")==0 )
		Open/R/T="????" refnum
	else
		Open/R/P=$path/T="????" refnum
	endif
	if( refnum==0 )
		return 0
	endif
	
	FStatus refnum
	print "FITS Load from",S_fileName
	LoadOneFITS(refnum,S_fileName,doHeader,doHistory,doComment,doAutoDisp,doInt2Float,bigBytes,bigBTBytes)
	Close refnum
end

// LH100316: added this to fix file names that are too large to be used as a datafolder name.
// You can create your own algorithm (perhaps putting up a dialog for the user) by creating an Override function
// in your main procedure window. Execute DisplayHelpTopic "Function Overrides" for more info.
Static Function/S MyCleanupFitsFolderName(nameIn)
	String nameIn
	
	return CleanupName(nameIn,1)
End



// LH991101: rewrote to make this routine independent of the panel so it can be called as a
// subroutine from a user written procedure.
//
Function LoadOneFITS(refnum,dfName,doHeader,doHistory,doComment,doAutoDisp,doInt2Float,bigBytes,bigBTBytes)
	Variable refnum
	String dfName				// data folder name for results -- may be file name if desired
	Variable doHeader			// set true to put header(s) in a notebook
	Variable doHistory			// set true to put HISTORY in the notebook
	Variable doComment			// ditto for COMMENT
	Variable doAutoDisp			// true to display data
	Variable doInt2Float			// true convert ints to floats
	Variable bigBytes			// if data exceeds this size, ask permission to load 
	Variable bigBTBytes			// if BINTABLE exceeds this size, ask permission to load 
	
	Variable doLogNotebook= doHeader | doHistory | doComment

	FStatus refnum

	String s
	s= PadString("",80,0)
	FBinRead refnum,s
	Variable err= 0
	String errstr=""
	do
		if( CmpStr("SIMPLE  =                    T ",s[0,30]) != 0 && CmpStr("SIMPLE  = T ",s[0,11]) != 0 )
			errstr="doesn't begin with 'SIMPLE'"
			print s
			err= 1
			break
		endif
		if( mod(V_logEOF,2880) != 0 )
			errstr= "file size is not a multiple of 2880 bytes"
			DoAlert 1,"WARNING: "+errstr+"; Continue anyway?"
			if( V_Flag==2 )
				err= 2
			endif
			break;
		endif
	while(0)
	if( err )
		if( err==1 )
			Abort "Not a FITS file: "+errstr
		endif
		return err
	endif
	
	String nb = ""
	if( doLogNotebook )
		nb = CleanupName(dfName,0)
		NewNotebook/N=$nb/F=1/V=1/W=(5,40,623,337) 
		Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nb showRuler=0, rulerUnits=1, updating={1, 60}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,576}, spacing={0,0,0}, tabs={}, rulerDefaults={"Monaco",10,0,(0,0,0)}
		Notebook $nb ruler=Normal
	endif
	
	String dfSav= GetDataFolder(1)	
	dfName= MyCleanupFitsFolderName(dfName)
	NewDataFolder/O/S $dfName
	
	String/G NotebookName= nb			// save name for later kill
	Make/T/N=0 WindowNameList	// place for window name(s) for later kill
	
	NewDataFolder/O/S Primary
	
	//
	//	Load the primary data
	//
	do
		err= GetRequired(refnum,nb,doHeader,bigBytes,0)
		if( err )
			errstr= StrVarOrDefault("errorstr","problem reading required parameters")
			break
		endif

		err= GetOptional(refnum,nb, doHeader,doHistory,doComment)
		if( err )
			errstr= StrVarOrDefault("errorstr","problem reading optional parameters")
			break
		endif
		err= SetFPosToNextRecord(refnum)
		if( err )
			errstr= StrVarOrDefault("errorstr","unexpected end of file")
			break
		endif

		NVAR gSkipData= gSkipData
		NVAR gDataBytes= gDataBytes
		if( gDataBytes != 0 )
			if( gSkipData )
				FStatus refnum
				FSetPos refnum,min(V_filePos+gDataBytes,V_logEOF)
			else
				FBinRead/B=2 refnum,data
				WAVE data
				SetDataProperties(data,doInt2Float)
				if( doAutoDisp )
					AutoDisplayData(data)
					WindowNameList[numpnts(WindowNameList)]= {WinName(0, 1)}		// for later kill
				endif
			endif
			SetFPosToNextRecord(refnum)		// ignore error
		endif
	while(0)

	Variable extension= 0
	if( !err )
		do
			extension += 1
			FStatus refnum
			Variable exStart= V_filePos				// remember this so we can skip extensions we don't understand
			
			if( V_filePos ==  V_logEOF )
				break
			endif
			if( V_logEOF < (V_filePos+2880) )
				WM_FITSAppendNB(nb,num2str(V_logEOF-V_filePos)+" bytes unread")		// LH991101: used to print to history but that is too much clutter
				break
			endif
			
			WM_FITSAppendNB(nb,"\r*********** Begin Extension ************\r")
			NewDataFolder/O/S ::$"Extension"+num2str(extension)
			FBinRead refnum,s
			WM_FITSAppendNB(nb,s)

			if( CmpStr(s[0,8],"XTENSION=") != 0 )		// ok for extra records to exist after primary and extensions
				break
			endif
		
			String/G XTENSION=UnPadString( GetFitsString(s), 32 )
			if( strlen(XTENSION) == 0 )
				errstr= "XTENSION char string missing"
				err= 1
				break
			endif
			Variable isBinTable= CmpStr("BINTABLE",XTENSION) == 0
			Variable isImage= CmpStr("IMAGE",XTENSION) == 0
			Variable isTextTable= CmpStr("TABLE",XTENSION) == 0
	
			
			if( isBinTable )
				err= GetRequiredBinTable(refnum,nb,doHeader)	
			elseif( isImage )
				err= GetRequired(refnum,nb,doHeader,bigBytes,0)	//we do create a wave
			else
				err= GetRequired(refnum,nb,doHeader,bigBytes,1)	// 1 means we don't create a wave
			endif
			if( err  )
				break
			endif

			err= GetOptional(refnum,nb, doHeader,doHistory,doComment)
			if( err )
				errstr= StrVarOrDefault("errorstr","problem reading optional extension parameters")
				break
			endif
			SetFPosToNextRecord(refnum)		// ignore error

			if( Exists("PCOUNT") != 2 )
				errstr= "PCOUNT extension param missing"
				err= 1
				break
			endif
			if( Exists("GCOUNT") != 2 )
				errstr= "GCOUNT extension param missing"
				err= 1
				break
			endif
			NVAR GCOUNT,BITPIX
			NVAR gDataBytes					// doesn't include p or g count
			Variable pCountval= 0
			NVAR/Z PCOUNT					// apparently this can sometimes contain text, i.e., random
			if( NVAR_Exists(PCOUNT) )
				pCountval= PCOUNT
			endif
			
			gDataBytes= gDataBytes*8/abs(BITPIX)
			gDataBytes= abs(BITPIX)*GCOUNT*(pCountval+gDataBytes)/8

			FStatus refnum
			Variable exDataStart= V_filePos
			 
			if( isBinTable )
				err= ReadDataBinTable(refnum,errstr,bigBTBytes)
				if( err )
					WM_FITSAppendNB(nb,"***BINTABLE ERROR (did not load data): "+errstr)
					err= 0			// continue with the rest of the file
				endif
			endif
			 
			if( isImage )
				err= ReadDataImageExtension(refnum,errstr, doInt2Float, doAutoDisp,WindowNameList)
				if( err )
					WM_FITSAppendNB(nb,"***IMAGE EXTENSION ERROR (did not load data): "+errstr)
					err= 0			// continue with the rest of the file
				endif
			endif

			if( isTextTable  )
				WM_FITSAppendNB(nb,"***Start TABLE data***")
				NVAR NAXIS1,NAXIS2
				String ss= PadString("",NAXIS1,0x20)
				Variable j=1
				do
					if( j>NAXIS2)
						break
					endif
					FBinRead refnum,ss
					WM_FITSAppendNB(nb,ss)
					j+=1
				while(1)
				WM_FITSAppendNB(nb,"***End TABLE data***")
			endif
			FSetPos refnum,min(exDataStart+gDataBytes,V_logEOF)		// skip the data; do something with it later
			SetFPosToNextRecord(refnum)		// ignore error
		
		while(1)
	endif
	
	if( err )
		DoAlert 0, errstr
	endif
	
	
	SetDataFolder dfSav
	return err
end


Static Function ScaleIntData(d,bscale,bzero,blank,blankvalid)
	Variable d,bscale,bzero,blank,blankvalid
	
	if( blankvalid )
		if( d==blank )
			return NaN
		endif
	endif
	return d*bscale+bzero
end


Static Function SetDataProperties(data,doInt2Float)
	Wave data
	Variable doInt2Float
	
	Variable ndims= WaveDims(data)
	Variable i=1
	do
		if( i>ndims )
			break
		endif
		String ctype= StrVarOrDefault("CTYPE"+num2istr(i),"")
		Variable cref= NumVarOrDefault("CRPIX"+num2istr(i),1)-1
		Variable crval= NumVarOrDefault("CRVAL"+num2istr(i),0)
		Variable cdelt= NumVarOrDefault("CDELT"+num2istr(i),1)
		Variable d0= crval-cref*cdelt
		if( i==1 )
			SetScale/P x,d0,cdelt,ctype,data
		endif
		if( i==2 )
			SetScale/P y,d0,cdelt,ctype,data
		endif
		if( i==3 )
			SetScale/P z,d0,cdelt,ctype,data
		endif
		if( i==4 )
			SetScale/P t,d0,cdelt,ctype,data
		endif
		i+=1
	while(1)
	
	if( Exists("BUNIT")==2 )
		SetScale d,0,0,StrVarOrDefault("BUNIT",""),data
	endif
	
	NVAR BITPIX= BITPIX
	if( (BITPIX > 0) &&  doInt2Float )
		Variable bscale= NumVarOrDefault("BSCALE",1)
		Variable bzero= NumVarOrDefault("BZERO",0)
		Variable blank= NumVarOrDefault("BLANK",0)
		Variable blankvalid= Exists("BLANK")==2
		
		if( BITPIX==32 )
			Redimension/D $"data"		// need double precision to maintian all 32 bits
		else
			Redimension/S $"data"
		endif
		if( (bscale!=1) | (bzero!=0) | blankvalid )
			data=ScaleIntData(data,bscale,bzero,blank,blankvalid)
		endif
	endif
			
end

Static Function AutoDisplayData(data)
	Wave data
	
	Variable ndims= WaveDims(data)
	if( ndims > 1 )
		Display;AppendImage data
		if( DimSize(data, 2) > 3 )
			Variable/G curPlane
			ControlBar 22
			SetVariable setvarPlane,pos={9,2},size={90,17},proc=WM_FITSSetVarProcPlane,title="plane"
			SetVariable setvarPlane,format="%d"
			SetVariable setvarPlane,limits={0,DimSize(data, 2)-1,1},value= curPlane
		endif
		DoAutoSizeImage(0,1)
	else
		Display data
	endif
end



Static Function SetFPosToNextRecord(refnum)
	Variable refnum

	FStatus refnum
	Variable nextRec= ceil(V_filePos/2880)*2880
	if( nextRec != V_filePos )
		if( nextRec >= V_logEOF )
			String/G errorstr= "hit end of file"
			return 1
		endif
		FSetPos refnum,nextRec
	endif
	return 0
end	

Function WM_FITSAppendNB(nb,s)
	String nb
	String s
	
	if( strlen(nb) != 0 )
		Notebook $nb,text=s+"\r"
	endif
end

Static Function/S GetFitsString(s)
	String s

	String strVal
	Variable strValValid=0,sp1
	if( char2num(s[10]) == char2num("'") )
		strValValid= 1
		strVal= s[11,79]
		sp1= StrSearch(strVal,"'",0)
		if( sp1<0 )
			strValValid= 0
		else
			strVal= strVal[0,sp1-1]
		endif
	endif
	if( strValValid )
		return strVal
	else
		return ""
	endif
end
	


	
Static Function GetRequired(refnum,nb,doHeader,bigBytes,noWave)
	Variable refnum
	String nb
	Variable doHeader,bigBytes,noWave
	
	if( !doHeader )
		nb= ""
	endif
	
	String s= PadString("",80,0)
	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)

	Variable/G BITPIX
	if( CmpStr("BITPIX  = ",s[0,9]) != 0 )
		String/G errorstr= "BITPIX missing"
		return 1
	endif
	BITPIX= str2num(s[10,29])
	Variable numberType
	if( BITPIX== 8 )
		numberType= 8+0x40
	elseif( BITPIX== 16 )
		numberType= 0x10
	elseif( BITPIX== 32 )
		numberType= 0x20
	elseif( BITPIX== -32 )
		numberType= 2
	elseif( BITPIX== -64 )
		numberType= 4
	else
		String/G errorstr= "BITPIX bad value"
		return 1
	endif

	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	Variable/G NAXIS
	if( CmpStr("NAXIS   = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS missing"
		return 1
	endif
	NAXIS= str2num(s[10,29])
	Variable i=0
	Make/O/N=200 dims=0			// 199 is max possible NAXIS

	Variable/G gDataBytes= abs(BITPIX)/8
	Variable/G gSkipData=0
	if( NAXIS==0 )
		gSkipData= 1				// no primary data
		gDataBytes= 0
	endif

	do
		if( i>=NAXIS )
			break
		endif
		FBinRead refnum,s
		WM_FITSAppendNB(nb,s)
		String naname= "NAXIS"+num2istr(i+1)
		Variable/G $naname
		NVAR na= $naname
		if( CmpStr(PadString(naname,8,0x20)+"= ",s[0,9]) != 0 )
			String/G errorstr= naname+" missing"
			return 1
		endif
		na= str2num(s[10,29])
		dims[i]= na
		gDataBytes *= na
		i+=1
	while(1)
	Variable trueNDims= NAXIS
	if( (NAXIS > 0)  && (noWave==0) )
		i=NAXIS-1
		do
			if( i<0 )
				break
			endif
			if( dims[i]<=1 )
				dims[i]= 0
				trueNDims -= 1
			else
				break
			endif
			i-=1
		while(1)
		
		if( trueNDims > 4 )
			String/G errorstr= "NAXIS > 4 not supported at present time (could be done with data folders)"
			return 1
		endif
		if( gDataBytes > bigBytes )
			String s1
			sprintf s1,"load big data (%d)?",gDataBytes
			DoAlert 1,s1
			gSkipData= V_Flag!=1
		endif
		if( !gSkipData )
			Make/O/Y=(numberType)/N=(dims[0],dims[1],dims[2],dims[3]) data
		endif
	endif
	KillWaves dims

	return 0
end

Static Function KWCheck(kw,s8)
	String kw,s8
	
	return CmpStr(PadString(kw,8,0x20),s8) == 0
end

Static  Function/S StripTrail(s)
	String s
	
	Variable n= strlen(s)-1
	do
		if( (n<0) || (char2num(s[n])!=0x20) )
			break
		endif
		n-=1
	while(1)
	return s[0,n]
end




// read optional header stuff until END or error
// Reads all keywords into variables
//
Static Function GetOptional(refnum,nb, doHeader,doHistory, doComment)
	Variable refnum
	String nb
	Variable doHeader,doHistory,doComment
	
	
	String s= PadString("",80,0)
	String nbText=""
	do
		FStatus refnum
		if( (V_filePos+80) > V_logEOF )
			String/G errorstr= "hit end of file before END card"
			return 1
		endif
		FBinRead refnum,s
		if( CmpStr("HISTORY",s[0,6]) == 0 )
			if( doHistory )
				nbText += s+"\r"
			endif
			continue
		elseif( CmpStr("COMMENT",s[0,6]) == 0 )
			if( doComment )
				nbText += s+"\r"
			endif
			continue
		else
			if( doHeader )
				nbText += s+"\r"
			endif
		endif
		
		if( CmpStr("END ",s[0,3]) == 0 )		// this is how we exit; Very liberal
			break
		endif
		
		String kw=  StripTrail(s[0,7])
		String strVal
		Variable strValValid=0,sp1,sp2
		sp1= StrSearch(s,"'",10)
		if( sp1 >= 10 )
			sp2= StrSearch(s,"'",sp1+1)
			if( sp2 > 0 )
				strValValid= 1
				strVal= StripTrail(s[sp1+1,sp2-1])
			endif
		endif

		Variable val1= str2num(s[10,29])
		String stemp = s[29,29]
		if( numtype(val1) == 2 )        // NaN?
			if( CmpStr(stemp,"T") == 0 )
				val1= 1            // Boolean T
			elseif( CmpStr(stemp,"F") == 0 )
				val1= 0            // Boolean F
			endif
		endif
		Variable hasVal= CmpStr(s[8,9],"= ") == 0

		if( hasVal )
			kw = CleanupName(kw, 0)
			if( strValValid )
				String/G $kw= strVal
			else
				Variable/G $kw= val1
			endif
		endif
	while(1)

	if( (strlen(nb)!=0)  && (strlen(nbText)!=0) )
		Notebook $nb,text=nbText
	endif
		
	return 0
end



Static Function GetRequiredBinTable(refnum,nb,doHeader)
	Variable refnum
	String nb
	Variable doHeader
	
	if( !doHeader )
		nb= ""
	endif
	
	String s= PadString("",80,0)
	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)

	Variable tmp
	if( CmpStr("BITPIX  = ",s[0,9]) != 0 )
		String/G errorstr= "BITPIX missing"
		return 1
	endif
	tmp= str2num(s[10,29])
	if( tmp != 8 )
		String/G errorstr= "BITPIX not 8"
		return 1
	endif
	Variable/G BITPIX=8
	

	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	if( CmpStr("NAXIS   = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS missing"
		return 1
	endif
	tmp= str2num(s[10,29])
	if( tmp != 2 )
		String/G errorstr= "NAXIS not 2"
		return 1
	endif

	Variable/G gDataBytes= 1
	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	if( CmpStr("NAXIS1  = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS1  missing"
		return 1
	endif
	Variable/G NAXIS1= str2num(s[10,29])		// bytes per row
	gDataBytes *= NAXIS1

	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	if( CmpStr("NAXIS2  = ",s[0,9]) != 0 )
		String/G errorstr= "NAXIS2  missing"
		return 1
	endif
	Variable/G NAXIS2= str2num(s[10,29])		// rows
	gDataBytes *= NAXIS2

	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	if( CmpStr("PCOUNT  = ",s[0,9]) != 0 )
		String/G errorstr= "PCOUNT  missing"
		return 1
	endif
	Variable/G PCOUNT= str2num(s[10,29])		//Random parameter count 
	
	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	if( CmpStr("GCOUNT  = ",s[0,9]) != 0 )
		String/G errorstr= "GCOUNT  missing"
		return 1
	endif
	Variable/G GCOUNT= str2num(s[10,29])		//Group count
	
	FBinRead refnum,s
	WM_FITSAppendNB(nb,s)
	if( CmpStr("TFIELDS = ",s[0,9]) != 0 )
		String/G errorstr= "TFIELDS  missing"
		return 1
	endif
	Variable/G TFIELDS= str2num(s[10,29])		//Number of columns

	return 0
end


Static Function ReadDataImageExtension(refnum,errMessage, doInt2Float, doAutoDisp,WindowNameList)
	Variable refnum
	String &errMessage
	Variable doInt2Float, doAutoDisp
	WAVE/T WindowNameList
	
	WAVE/Z data
	if( !WAVEExists(data) )
		return 0					// user apparently declined to load (or error)
	endif
	

	FBinRead/B=2 refnum,data
	WAVE data
	SetDataProperties(data,doInt2Float)
	if( doAutoDisp )
		AutoDisplayData(data)
		WindowNameList[numpnts(WindowNameList)]= {WinName(0, 1)}		// for later kill
		AutoPositionWindow
	endif

	return 0
End



Static Function ReadDataBinTable(refnum,errMessage,bigBTBytes)
	Variable refnum
	String &errMessage
	Variable bigBTBytes

	NVAR NAXIS2
	if( NAXIS2 != 1 )
		NVAR NAXIS1
		if( (NAXIS1*NAXIS2) > bigBTBytes )
			return OptionReadDataBinTableMultirow(refnum,errMessage)
		else
			return ReadDataBinTableMultirow(refnum,errMessage)
		endif
	endif
	
	Variable i
	for(i=1;;i+=1)
		SVAR/Z tform= $"TFORM"+num2str(i)
		if( !SVAR_Exists(tform) )
			break
		endif
		Variable nType,numpnts,isAscii
		
		numpnts= ParseTFORM(tform,nType,isAscii)
		if( nType<0 )
			errMessage= "Don't know how to handle BINTABLE with tform= "+tform
			return 1
		endif
		if( numpnts==0 )		// null records are allowed
			continue
		endif
		
		
		String wname= "BTData"+num2str(i)
		Make/O/N=(numpnts)/Y=(nType) $wname
		WAVE data= $wname
		FBinRead/B=2 refnum,data

		SVAR/Z tdim= $"TDIM"+num2str(i)
		if( SVAR_Exists(tdim) )
			Variable dim1,dim2,err
			err= ParseTDIM(tdim,dim1,dim2)
			if( !err )
				Redimension/N=(dim1,dim2) data
				MatrixTranspose data
			endif
		
		endif
		SVAR/Z tunit= $"TUNIT"+num2str(i)
		if( SVAR_Exists(tunit) )
			SetScale d 0,0,tunit, data
		endif
		// swap if complex?, split mult cols?
		
	endfor
	
	return 0
end

// Returns number of bytes for a given number type
// See /Y flag for Make,Redimension
Static Function NumSize(ntype)
	Variable ntype
	
	Variable cmult= (ntype&0x01) ? 2 : 1;

	if( ntype&0x40 )
		return 1*cmult
	elseif( ntype &0x10 )
		return 2*cmult
	elseif( (ntype&0x20) || (ntype&0x02) )
		return 4*cmult
	elseif( (ntype&0x04)  ||  (ntype&0x80) )				// 0x80 is 64 bit int
		return 8*cmult
	else
		return -1
	endif
End


Static  Function ReadDataBinTableMultirow(refnum,errMessage)
	Variable refnum
	String &errMessage

	NVAR NAXIS1
	NVAR NAXIS2
	Variable emode= CmpStr( IgorInfo(4 ),"Intel")==0 ? 2 : 1;		// ASSUME: platforms other than Intel are big endian (need better indication). See Redimension's new /E flag for meaning of emode

	
	// read entire data into unsigned byte wave
	Make/B/U/N=(NAXIS1,NAXIS2) bindata
	if( !WaveExists(bindata) )
		errMessage= "not enough memory"
		return 1
	endif
	FBinRead refnum,bindata
	
	// disburse individual columns
	Variable i,colStart=0,colBytes
	for(i=1;;i+=1)
		SVAR/Z tform= $"TFORM"+num2str(i)
		if( !SVAR_Exists(tform) )
			break
		endif
		Variable nType,numpnts,isAscii=0
		
		numpnts= ParseTFORM(tform,nType,isAscii)
		if( nType<0 )
			errMessage= "Don't know how to handle BINTABLE with tform= "+tform
			return 1
		endif
		if( numpnts==0 )		// null records are allowed
			continue
		endif
		
		colBytes= numpnts*NumSize(nType)

		String wname= "BTData"+num2str(i)
		SVAR/Z ttype= $"TTYPE"+num2str(i)
		if( SVAR_Exists(ttype) )
			wname= StripTrail(ttype)
		endif
		if( CheckName(wname, 1) != 0 )
			wname= UniqueName(wname,1,0)
		endif
		
		Duplicate/O/R=[colStart,colStart+colBytes-1] bindata,$wname
		WAVE w= $wname
		if( !WaveExists(w) )
			errMessage= "not enough mem for extract"
			return 1
		endif

		if( isAscii )
			if( Convert2Text(w,1) )
				errMessage= "couldn't create text version"
				return 1
			endif
		else
			Redimension/E=(emode)/N=(NAXIS2,numpnts==1 ? 0 : numpnts)/Y=(nType) w
			SVAR/Z tunit= $"TUNIT"+num2str(i)
			if( SVAR_Exists(tunit) )
				if( Strlen( StripTrail(tunit) ) > 0 )
					SetScale d,0,0,StripTrail(tunit) w
				endif
			endif
		endif
		
		// Handle TDIM here?
		
		colStart += colBytes
		
	endfor
	
	KillWaves bindata
	
	return 0
end




Function CAButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if( ba.eventCode  == 2 ) // mouse up
		ControlInfo list0
		WAVE sw= $(S_DataFolder + "tfChecked")
		if( CmpStr(ba.ctrlName,"bSelect") == 0 )
			sw= sw|0x10
		else
			sw= sw&~0x10
		endif
	endif
	return 0
End

Function ContButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	if( ba.eventCode  == 2 )// mouse up
		KillWindow $ba.win
	endif
	return 0
End

Function GetTTYPEsToLoad(lw, sw)
	WAVE/T lw
	WAVE sw
	
	NewPanel /W=(150,50,485,449) /N=GetTTYPEsToLoadPanel
	ListBox list0,pos={12,11},size={216,364}
	ListBox list0,listWave=lw
	ListBox list0,selWave=sw
	Button bSelect,pos={243,26},size={79,21},proc=CAButtonProc,title="Select all"
	Button bDeSelect,pos={243,61},size={79,21},proc=CAButtonProc,title="Deselect all"
	Button cb,pos={243,350},size={74,20},proc=ContButtonProc,title="Continue"
	PauseForUser GetTTYPEsToLoadPanel

	sw= (sw&0x10) != 0		// convert to boolean
	return sum(sw)			// return number of selected items
End


// Called if data size exceeds user set value
Static  Function OptionReadDataBinTableMultirow(refnum,errMessage)
	Variable refnum
	String &errMessage

	Variable emode= CmpStr( IgorInfo(4 ),"Intel")==0 ? 2 : 1;		// ASSUME: platforms other than Intel are big endian (need better indication). See Redimension's new /E flag for meaning of emode

	NVAR TFIELDS
	Variable nFields= TFIELDS
	Variable i
	Make/O/T/N=(nFields) tfNames
	for(i=0;i<nFields;i+=1)
		SVAR tfn= $("TTYPE" + num2istr(i+1))
		tfNames[i]= tfn
	endfor
	Make/N=(nFields) tfChecked= 0x20+0x10							// Cell is a checkbox and is checked
	
	Variable ns= GetTTYPEsToLoad(tfNames, tfChecked)
	NVAR NAXIS1,NAXIS2
	Variable rowBytes= NAXIS1
	Variable nRows= NAXIS2
	Variable totData= rowBytes*nRows

//Print "OptionReadDataBinTableMultirow", ns
	FStatus   refnum
	Variable eod= V_filePos + totData
	if( ns == 0 )		// skip all?
		FSetPos refNum, eod
		return 0
	endif
	
	Make/FREE/N=(nFields) tfSizes,tfTypes,tfIsAscii
	Make/T/FREE/N=(nFields) wNames
	Variable nType,numpnts,isAscii=0
	for(i=0;i<nFields;i+=1)
		SVAR/Z tform= $"TFORM"+num2str(i+1)
		numpnts= ParseTFORM(tform,nType,isAscii)
		if( nType<0 )
			errMessage= "Don't know how to handle BINTABLE with tform= "+"TFORM"+num2istr(i+1)
			return 1
		endif
		tfSizes[i]= numpnts
		tfTypes[i]= nType
		tfIsAscii[i]= isAscii
	endfor

	// will be reading a subset of data into an unsigned byte wave
	Variable nominalChunkSize= 1E6
	Variable chunkRows= floor(nominalChunkSize/rowBytes)
	if( chunkRows > nRows )
		chunkRows= nRows
	endif
	
	Make/FREE/B/U/N=(rowBytes,chunkRows) bindata
	if( !WaveExists(bindata) )
		errMessage= "not enough memory"
		return 1
	endif

	Variable rowsRemaining= nRows
	Variable nRowsRead= 0
	Variable chunk,nChunks= ceil(totData/(rowBytes*chunkRows))


//To avoid needing to load all rows
NVAR/Z cLim= $"root:gChunkLimit"
if( NVAR_Exists(cLim) && cLim>0 && nChunks > cLim )
	nChunks= cLim
endif

	for(chunk=0;chunk<nChunks;chunk+=1)
		if( rowsRemaining < chunkRows )
			chunkRows= rowsRemaining
			Redimension/N=(rowBytes,chunkRows) bindata		// likely to happen on last chunk
		endif
		FBinRead refnum,bindata

		Variable colStart= 0, colBytes
		String wname

		for(i=0;i<nFields;i+=1)
			colBytes=  tfSizes[i]*NumSize(tfTypes[i])		// apparently this can be zero
			if( tfChecked[i] )
				if( chunk == 0 )
					wname= "BTData"+num2str(i+1)
					SVAR/Z ttype= $"TTYPE"+num2str(i+1)
					if( SVAR_Exists(ttype) )
						wname= StripTrail(ttype)
					endif
					if( CheckName(wname, 1) != 0 )
						wname= UniqueName(wname,1,0)
					endif
					wNames[i]= wname
					Duplicate/O/R=[colStart,colStart+colBytes-1] bindata,$wname
					WAVE w= $wname
					if( !WaveExists(w) )
						errMessage= "not enough mem for extract"
						return 1
					endif
				else				// append to waves made above
					WAVE w= $( wNames[i] )
					Duplicate/FREE/O/R=[colStart,colStart+colBytes-1] bindata,tempW
					Concatenate/NP {tempW}, w
				endif
			endif
			colStart += colBytes
		endfor
		nRowsRead += chunkRows
		rowsRemaining -= chunkRows
	endfor

	FSetPos refNum, eod		// just in case we did not read all of the data

	// now convert the waves to the proper type
	for(i=0;i<nFields;i+=1)
		if( tfChecked[i] )
			WAVE w= $(wNames[i])

			if( tfIsAscii[i] )
				if( Convert2Text(w,1) )
					errMessage= "couldn't create text version"
					return 1
				endif
			else
				Variable np= tfSizes[i]
				nType= tfTypes[i]
#if IgorVersion() >= 7
				Redimension/E=(emode)/N=(nRowsRead*np,0)/Y=(nType) w
#else
				if( nType == 0x80 )				// 64 bit int not available in IP6;  Read into unsigned 32 bit int wave with even point numbers being the high 32 bits and odd being the low
					Redimension/E=(emode)/N=(nRowsRead*2*np,0)/Y=(0x20|0x40) w
				else
					Redimension/E=(emode)/N=(nRowsRead*np,0)/Y=(nType) w
				endif
#endif
				if( np > 1 )
					Print "TODO: multiple columns in a single BINTABLE field"	//  probably redimension followed by transpose; can not find any sample data
				endif
				SVAR/Z tunit= $"TUNIT"+num2str(i+1)
				if( SVAR_Exists(tunit) )
					if( Strlen( StripTrail(tunit) ) > 0 )
						SetScale d,0,0,StripTrail(tunit) w
					endif
				endif
			endif
		endif
	endfor


	return 0
End




Static  Function ParseTFORM(tform,nType,isAscii)
	String tform
	Variable &nType
	Variable &isAscii
	
	Variable i,digit,num=0
	String s=""
	for(i=0;;i+=1)
		digit= char2num( tform[i]) - 48
		if( digit < 0 || digit > 9 )
			break
		endif
		num= num*10+digit
	endfor
	if( i==0 )
		num= 1		// missing repeat count is defined as 1
	endif

String ss= tform[i]
	strswitch(ss)
		case "A":
			isAscii= 1			// data is really text
		case "L":
		case "B":
			nType= 0x48		// unsigned byte
			break
		case "I":
			nType= 0x10		// signed 16 bit int
			break
		case "J":
			nType= 0x20		// signed 32 bit int
			break
		case "E":
			nType= 0x02		// 32 bit float
			break
		case "D":
			nType= 0x04		// 64 bit float
			break
		case "C":
			nType= 0x03		// 32 bit float complex
			break
		case "M":
			nType= 0x05		// 64 bit float complex
			break
		case "K":
			nType= 0x80		// 64 bit integer
			break
		default:						// Don't handle X,A,P yet
			nType= -1
	endswitch
	return num
end

// Kinda' special purpose for now
Static  Function ParseTDIM(tdim,dim1,dim2)
	String tdim
	Variable &dim1,&dim2
	
	Variable ddim1,ddim2
	
	sscanf tdim,"(%d,%d)",ddim1,ddim2		// BUG: sscanf can accept pass-by-ref but doesn't work
	dim1= ddim1
	dim2= ddim2
	return V_Flag!=2			// i.e., failed
end







Function CheckProcFitsGeneric(ctrlName,checked) // : CheckBoxControl
	String ctrlName
	Variable checked

	if( CmpStr(ctrlName,"checkHead") == 0 )
		Variable/G root:Packages:FITS:wantHeader= checked
	elseif( CmpStr(ctrlName,"checkHist") == 0 )
		Variable/G root:Packages:FITS:wantHistory= checked
	elseif( CmpStr(ctrlName,"checkCom") == 0 )
		Variable/G root:Packages:FITS:wantComments= checked
	elseif( CmpStr(ctrlName,"checkAutoDisp") == 0 )
		Variable/G root:Packages:FITS:wantAutoDisplay= checked
	elseif( CmpStr(ctrlName,"checkPromoteInts") == 0 )
		Variable/G root:Packages:FITS:promoteInts= checked
	endif
End

Function ButtonProcLoadFits(ctrlName)//  : ButtonControl
	String ctrlName

	WMLoadFITS()
End

Function WMDoFITSPanel()
	if( NumVarOrDefault("root:Packages:FITS:wantHeader",-1) == -1 )
		String dfSav= GetDataFolder(1)
		NewDataFolder/O/S root:Packages
		NewDataFolder/O/S FITS
		
		Variable/G wantHeader=1
		Variable/G wantHistory=0
		Variable/G wantComments=0
		Variable/G wantAutoDisplay= 1
		Variable/G promoteInts=0			// if true, then ints are converted floats
		Variable/G askifSize= 1e6			// ask if ok to load if data size is bigger than this
		Variable/G askifBTSize= 1e6			// ask if ok to load if data size is bigger than this
		
		String/G thePath= "_current_"
		SetDataFolder dfSav
	endif

	if( NumVarOrDefault("root:Packages:FITS:askifBTSize",-1) == -1 )
		Variable/G root:Packages:FITS:askifBTSize= 1e6			// Update old package with new variable needed in 2.2
	endif


	NewPanel/K=1 /W=(71,89,371,428)
	DoWindow/C FITSPanel
	CheckBox checkHead,pos={47,42},size={139,20},proc=CheckProcFitsGeneric,title="Include Header",value=1
	CheckBox checkHist,pos={47,59},size={139,20},proc=CheckProcFitsGeneric,title="Include History",value=0
	CheckBox checkCom,pos={47,75},size={139,20},proc=CheckProcFitsGeneric,title="Include Comments",value=0
	CheckBox checkAutoDisp,pos={47,107},size={139,20},proc=CheckProcFitsGeneric,title="Auto Display",value=1
	CheckBox checkPromoteInts,pos={47,91},size={139,20},proc=CheckProcFitsGeneric,title="Promote Ints",value=0
	SetVariable setvarAskSize,pos={47,127},size={216,17},title="Max autoload size"
	SetVariable setvarAskSize,format="%d"
	SetVariable setvarAskSize,limits={0,INF,100000},value= root:Packages:FITS:askifSize
	Button buttonLoad,pos={24,14},size={99,20},proc=ButtonProcLoadFits,title="Load FITS..."
	PopupMenu popupPath,pos={133,14},size={126,19},proc=WM_FITS_PathPopMenuProc,title="path"
	PopupMenu popupPath,mode=2,popvalue="_current_",value= #"\"_new_;_current_;\"+PathList(\"*\", \";\", \"\")"
	PopupMenu killpop,pos={24,290},size={98,20},proc=WM_FITS_KillMenuProc,title="Unload FITS"
	PopupMenu killpop,mode=0,value= #"WM_FITS_GetLoadedList()"
	SetVariable setvarAskBTSize,pos={47,156},size={216,15},title="Max BINTABLE autoload size"
	SetVariable setvarAskBTSize,format="%d"
	SetVariable setvarAskBTSize,limits={0,inf,100000},value= root:Packages:FITS:askifBTSize
EndMacro


Function WM_FITSSetVarProcPlane(ctrlName,varNum,varStr,varName) // : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	ModifyImage data,plane=varNum
End


Function WM_FITS_PathPopMenuProc(ctrlName,popNum,popStr) // : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if( CmpStr(popStr,"_new_") == 0 )
		popStr= ""
		Prompt popStr,"name for new path"
		DoPrompt "Get Path Name",popStr
		if( strlen(popStr)!=0 )
			NewPath /M="folder containing FITS files"/Q $popStr
			PopupMenu popupPath,mode=1,popvalue=popStr
		else
			SVAR cp= root:Packages:FITS:thePath
			PopupMenu popupPath,mode=1,popvalue=cp
			return 0								// exit if cancel
		endif
	endif

	String/G root:Packages:FITS:thePath= popStr
End

StrConstant nonefound = "_none found_"

Function WM_FITS_KillMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if (CmpStr(popStr, nonefound) == 0)
		return -1
	endif
	
	SVAR/Z nbName= root:$(popStr):NotebookName
	WAVE/T WindowNameList= root:$(popStr):WindowNameList
	
	if( !SVAR_Exists(nbName) )
		return 0		// should never happen
	endif
	
	if( strlen(nbName) != 0 )
		DoWindow/K $nbName
	endif
	Variable i, nwin= numpnts(WindowNameList)
	for(i=0;i<nwin;i+=1)
		DoWindow/K $(WindowNameList[i])
	endfor
	KillDataFolder root:$(popStr)
End

// returns list of data folders in root from loaded fits files
Function/S WM_FITS_GetLoadedList()	
	Variable i
	String dfList="",dfName
	for(i=0;;i+=1)
		dfName= GetIndexedObjName("root:",4,i )
		if( strlen(dfName) == 0 )
			break
		endif
		SVAR/Z nbName= root:$(dfName):NotebookName
		if( SVAR_Exists(nbName) )			// we take the existance of this string var as an indication that this df is from a fits load
			dfList += dfName+";"
		endif
	endfor
	if( strlen(dfList)==0 )
		return nonefound
	else
		return dfList
	endif
End


Static Function Convert2Text(w,useRow)
	WAVE w
	Variable useRow
	
	String s,swtxt= NameOfWave(w)+"_txt"
	Variable nrows= DimSize(w,0)
	Variable ncols= DimSize(w,1)
	
	Variable row,col
	Make/O/T/N=(useRow ? ncols : nrows) $swtxt
	WAVE/T wtxt= $swtxt
	if( !WaveExists(wtxt) )
		return 1
	endif
	if( useRow )
		for(col=0;col<ncols;col+=1)
			s= PadString("",nrows,0x20)
			for(row=0;row<nrows;row+=1)
				s[row]= num2char(w[row][col])
			endfor
			wtxt[col]= s	// StripTrail(s)
		endfor
	else
		for(row=0;row<nrows;row+=1)
			s= PadString("",ncols,0x20)
			for(col=0;col<ncols;col+=1)
				s[col]= num2char(w[row][col])
			endfor
			wtxt[row]= s	// StripTrail(s)
		endfor
	endif
	return 0
end