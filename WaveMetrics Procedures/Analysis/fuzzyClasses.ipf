#pragma rtGlobals=1		// Use modern global access method.

// The following function finds two classes in inWave using fuzzy logic.  The results, the means and variances of both
// classes are stored in the variables Var1, Var2, mean1, mean2 and optionally printed in the history window.
//
// The function also generates two membership waves that are stored in the current data folder.
// The entry of each wave is the likelyhood that the corresponding entry in inWave belongs to
// the first or second classes respectively.
 
Function fuzzyClasses(inWave,quiet)
	Wave inWave
	Variable quiet

	Variable/G Var1, Var2		 
	Variable/G mean1,mean2
	Variable len=numPnts(inWave)
	Make/O/N=(len)	   membership1,membership2		// needs to be created in the original datafolder
	
	String curFolder=GetDataFolder(1)
	SetDataFolder root:
	
	Variable packExists=0
	if(DataFolderExists("Packages"))
		packExists=1
	else
		NewDataFolder/O/S Packages
	endif
	NewDataFolder/O/S Fuzzy
	
	Variable len2=2*len
	
	Make/O/N=(len)	   oldMembership1,oldMembership2	 
	Duplicate/O inWave,A
	Duplicate/O inWave,B
	Duplicate/O inWave,C
	Duplicate/O inWave,D
	
	// Get initial values for u (0's and 1's).
	Variable meanP=mean(inWave,-inf,inf)
	membership1= inWave < meanP ? 1:0
	membership2=membership1==1? 0:1
	
	Duplicate/O membership1,tmp,tmp2					// create tmp waves for intermediate calculations

	Variable epsilon=1e-9;
	Variable dif,i

	do
  		oldMembership1=membership1
  		oldMembership2=membership2
  
		  // Update parameters.
		  tmp=membership1^2
		  tmp2=tmp*inWave
		  mean1=sum(tmp2,-inf,inf) / sum(tmp,-inf,inf);
		  tmp=membership2^2
		  tmp2=tmp*inWave
		  mean2=sum(tmp2,-inf,inf) / sum(tmp,-inf,inf);
		  
		  tmp=membership1* (inWave-mean1)^2
		  Var1=sum(tmp,-inf,inf) / sum(membership1,-inf,inf);				// formerly called sigma1
		  tmp=membership2* (inWave-mean2)^2
		  Var2=sum(tmp,-inf,inf) / sum(membership2,-inf,inf);				// formerly called sigma2
			  
		  A=((inWave-mean1)^2 / Var1) ^ 2
		  B=((inWave-mean2)^2 / Var1) ^ 2
		  C=((inWave-mean1)^2 / Var2) ^ 2
		  D=((inWave-mean2)^2 / Var2) ^ 2
		
		  membership1=0
		  membership2=0
		  
		  for(i=0;i<len;i+=1)
		  	if(B[i]!=0)
		  		membership1[i]=1/ (A[i] / B[i]+1);
		  	endif
		 endfor
		  									 
		  for(i=0;i<len;i+=1)
		  	if(C[i]!=0)
		  		membership2[i]=1/(D[i] / C[i]+1);
		  	endif
		 endfor
		
		  // test estimage convergence
		  oldMembership1=abs(oldMembership1-membership1)
		  oldMembership2=abs(oldMembership2-membership2)
		  dif=(sum(oldMembership1,-inf,inf)+sum(oldMembership2,-inf,inf))/len2
	while (dif > epsilon)
	
	if(quiet==0)
		printf "Var1=%g\t\t Var2=%g\t\tmean1=%g\t\tmean2=%g\r",Var1,Var2,mean1,mean2
	endif
	
	KillDataFolder :
	if(packExists==0)
		KillDataFolder :
	endif	
	
	SetDataFolder curFolder
End
