//////////////////////////////////////////////////////////////////////////////
// File name        : DMEInit.v
// Module name      : DMEInit
// Description      : This module initializes DME interface
// Hierarchy Up     : ODS_MR 
// Hierarchy Down   : --- 
//////////////////////////////////////////////////////////////////////////////	

module  DMEInit ( 
	     PWRGD_PS_PWROK_3V3 , 
	     RST_PLTRST_N ,
//-		 DME_PWRGD    , 
         DME_Absent   , 
		 DMEID        ,
		 DMEStatus    ,
		
         RST_DME_N    ,
		 DMEControl       	
		
	);  
	
   input          PWRGD_PS_PWROK_3V3 ;  
   input 	      RST_PLTRST_N  ;  
//-   input 	  DME_PWRGD     ;    // Will be moved to PwrSequence.MstrSeq in the future
   input          DME_Absent    ;    // high : DME absent ,  Low : DME exist
   input 	[3:0] DMEID         ;  
   input 	[5:0] DMEStatus     ; 
		
   output         RST_DME_N     ;  
   output 	[5:0] DMEControl    ; 

   assign   RST_DME_N       =  RST_PLTRST_N  ;
   assign   DMEControl[0]   =  PWRGD_PS_PWROK_3V3 ;
   assign   DMEControl[1]   =  0   ;
   assign   DMEControl[2]   =  0   ;
   assign   DMEControl[3]   =  0   ;
   
   
endmodule //  DMEInit