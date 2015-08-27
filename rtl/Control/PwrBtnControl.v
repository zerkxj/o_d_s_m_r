//////////////////////////////////////////////////////////////////////////////
// File name        : PwrBtnControl.v
// Module name      : PwrBtnControl
// Description      : This module control Power Btuuon timing                 
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
////////////////////////////////////////////////////////////////////////////// 
//
module  PwrBtnControl (
         InitResetN,
		 Strobe125ms,		 
		 PWR_BTN_IN_N,
		 PWRGD_PS_PWROK_3V3,
		 FM_PS_EN,
		 PowerEvtState,
		 PowerButtonOut_ox, 
		 PowerbuttonEvtOut,
		 RstBiosFlg, 
         FM_SYS_SIO_PWRBTN_N	 
);    
input         InitResetN;
input         Strobe125ms;
input	      PWR_BTN_IN_N;
input	      PWRGD_PS_PWROK_3V3;
input	      FM_PS_EN;
input	[3:0] PowerEvtState;
input	      PowerButtonOut_ox;    // From MR_Bsp.ButtonControl.Button::StrobeOut ( in ButtonControl.v file )
input	      PowerbuttonEvtOut;    // From PwrEvent
///////////////////////////////////////////////////////////////////////////
output	      RstBiosFlg;           // To MR_Bsp.BiosControl 
output        FM_SYS_SIO_PWRBTN_N;  // Output to SIO 
///////////////////////////////////////////////////////////////////////////							  
reg     [9:0] PowerButtonInBuf;
///////////////////////////////////////////////////////////////////////////
    assign FM_SYS_SIO_PWRBTN_N = PowerButtonOut_ox & PowerbuttonEvtOut; 
    assign RstBiosFlg 		= (PWRGD_PS_PWROK_3V3) ? 1'b0 :	 
							  ((`Event_PowerStandBy == PowerEvtState) && (1'b0 == PWR_BTN_IN_N )) ? 1'b1 :
							  ((1'b0 == PowerButtonInBuf[9]) && (`PwrSW_Off == FM_PS_EN)) ? 1'b1 : 1'b0;	
///////////////////////////////////////////////////////////////////////////	 
	always @(posedge Strobe125ms or negedge InitResetN)
	begin
		if(1'b0 == InitResetN)
            PowerButtonInBuf = 10'h00;
        else	
		    PowerButtonInBuf = {PowerButtonInBuf[8:0], PWR_BTN_IN_N };
    end
///////////////////////////////////////////////////////////////////////////
endmodule // PwrBtnControl