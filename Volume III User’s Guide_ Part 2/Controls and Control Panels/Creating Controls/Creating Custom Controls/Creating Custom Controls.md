# Creating Custom Controls

Chapter III-14 — Controls and Control Panels
III-424
Creating Checkbox Controls
The CheckBox creates or modifies a checkbox or a radio button.
CheckBox controls automatically size themselves in both height and width. They can optionally be con-
nected to a global variable.
For an example of using checkbox controls as radio buttons, see the reference documentation for the Check-
Box operation.
The user-defined action procedure that you will need to write for CheckBoxes must have the following form:
Function CheckProc(cba) : CheckBoxControl
STRUCT WMCheckboxAction &cba
switch(cba.eventCode)
case 2:
// Mouse up
Variable checked = cba.checked
break
case -1:
// Control being killed
break
endswitch
return 0
End
The checked structure member is set to the new checkbox value:; 0 or 1.
You often do not need an action procedure for a checkbox because you can read the state of the checkbox 
with the ControlInfo operation.
You can create custom checkboxes by following steps similar to those for custom buttons (see Custom 
Button Control Example on page III-422), except that the picture has six states side-by-side instead of three. 
The checkbox states are:
Creating Custom Controls 
The CustomControl operation creates or modifies a custom control, all aspects of which are completely 
defined by the programmer. See the CustomControl operation on page V-134 for a complete description.
The examples in this section are also available in the Custom Controls demo experiment. Choose 
FileExample ExperimentsFeature Demos 2Custom Control Demo.
What you can create with a CustomControl can be fairly simple such as this counter that increments when 
you click on it.
Image Order
Control State
Left
Deselected enabled.
Deselected enabled and clicked down (about to be selected).
Deselected disabled.
Selected enabled.
Selected enabled and clicked down (about to be deselected).
Right
Selected disabled.

Chapter III-14 — Controls and Control Panels
III-425
 
Four clicks later: 
The following code implements the counter custom control using the kCCE_frame event. In the panel, click 
on the number to increment the counter; also try clicking and then dragging outside the control.
static constant kCCE_mouseup= 2
static constant kCCE_frame= 12
// PNG: width= 280, height= 49
Picture Numbers0to9
ASCII85Begin
M,6r;%14!\!!!!.8Ou6I!!!$:!!!!R#Qau+!00#^OT5@]&TgHDFAm*iFE_/6AH5;7DfQssEc39jTBQ
=U"5QO:5u`*!m@2jnj"La,mA^'a?hQ[Z.[.,Kgd(1o5*(PSO8oS[GX%3u'11dTl)fII/"f-?Jq*no#
Qb>Y+UBKXKHQpQ&qYW88I,Ctm(`:C^]$4<ePf>Y(L\U!R2N7CEAn![N1I+[hTtr.VepqSG4R-;/+$3
IJE.V(>s0B@E@"n"ET+@5J9n_E:qeR_8:Fl?m1=DM;mu.AEj!)]K4CUuCa4T=W)#(SE>uH[A4\;IG/
e]FqJ4u,2`*p=N5sc@qLD5bH89>gIBdF-1i6SF28oH@"3c2m)bDr&,UB$]i]/0bA.=qbR2#\-D9E?O
2>3D>`($p(Kn)F8aF@)LYiXn[h2K):5@^kF?94)j*1Xtq1U2oFZmY.te?0G)EQ%5,RVT-c)DVa+%mP
%+bS*_hN$hC*8uCJuIWqTHJR.U?32`_B)(g_8e#*YXa>=faEdJsF]6iJlrQ@QAX7huJUmXj8:PBTb2
Y:DYf*Sci'Q"3_;@RDQA:A/([2sO8r$hW)\B$XBGASJ:6OpC+GL<FjVfeNm20U<l<9J%cndX3'HP+k
R.IV?U>ns*_;Zt[]6G6"Rb-*'Nm-E8]LXXXo7Ub>A**7Bm5cS*">HbQ&_RhmUe]$iu@T?Cci:e-_`k
sE+H.GRSMT(9to;IZuH`T4%Yt<jF$+W?Yh6Q*_`C4sGig=L@DKoT%.H=#e_H"QEeeBVNTWBSMYr3dj
O=T%d&4kT9#cWPHS>kAG;3=or2(IK*IBF$^qK,+m0NSDK_!+e0#3fAI>HfKa<sk0641u\W@r+Y:$.i
i$grCPR#&6,;+>nTs_IKS6XcYR)A$fJiC6Z_d2S!$R>_ZH+[<p:JI0ub]\BhE(0RP@((KTRTGo;#SY
LT^9;D7X#km%UV20?$RS"FZoIF!(`FY-iL?n$%#o;-Wj(\PaBS6ZRQe@:kC>%ULrhTWLNM=n@fUbRp
SKkLe\kJ)Sd]u7!?pRJk-!XL[/MZX'"n4?a?JIKO0k'KUm1IZ+roB=:Bq'$&E<#$Krp%p,E"4sI>[-
0F#^ff5SN':2fO)LNC?L4(2ga=!aLm8)tVbGAM?L`l^=$D_YP7Z(sOFs)BL5er5G95p3?m%hM^lSr'
*E^O@8=u6hL`L$mPcq!Bl-iHuGA6hiip%`cFjl9>W?'E-&5T%Y.]i2A@1i%p8XJ5[khb:&"JXYSC\r
10Ss8<Ye;S^"Nc0%-DFouAiPQ9OemnR!"sHH$JKt@!"d0E"'M(P%:`p'15_10`!<nVt"TALQ>PF8WL
Z:#f!!!!j78?7R6=>B
ASCII85End
End
Structure CC_CounterInfo
Int32 theCount
// current frame of 10 frame sequence of numbers in 
EndStructure
Function MyCC_CounterFunc(s)
STRUCT WMCustomControlAction &s
STRUCT CC_CounterInfo info
if( s.eventCode==kCCE_frame )
StructGet/S info,s.userdata
s.curFrame= mod(info.theCount+(s.curFrame!=0),10)
elseif( s.eventCode==kCCE_mouseup )
StructGet/S info,s.userdata
info.theCount= mod(info.theCount+1,10)
StructPut/S info,s.userdata
// will be written out to control
endif
return 0
End
Window Panel0() : Panel
PauseUpdate; Silent 1
// building window...
NewPanel /W=(69,93,271,252)
CustomControl cc2,pos={82,46},proc=MyCC_CounterFunc,picture= 
{ProcGlobal#Numbers0to9,10}
EndMacro
