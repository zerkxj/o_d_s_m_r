//////////////////////////////////////////////////////////////////////////////
// File name        : OffLEDwhenPwrOff.v
// Module name      : OffLEDwhenPwrOff
// Description      : This module turns off LEDs when PSU is not turned on yet               
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////  

//////////////////////////////////////////////////////////////////////////////
/////  Turn Off LEDs when PSU is not turned on yet.
/////////////////////////////////////////////////////////////////////////////
module OffLEDwhenPwrOff ( 
	    FM_PS_EN , 
	    SysLedG_ox ,
	    SysLedR_ox ,
	    PowerNormal_ox,
		PowerFail_ox,
		FanFail_ox,
		FanOK_ox,
		RJ45Speed1R_ox,
		RJ45Speed2R_ox,
		RJ45RActivity_ox,
		
		SYS_LEDG_N,
		SYS_LEDR_N,
		PSU_Normal_N,
		PSU_Fail_N,
		FAN_LEDR_N,
		FAN_LEDG_N,
		CPLD_LAN_LINK1000_N,
		CPLD_LAN_LINK100_N,
		CPLD_LAN_ACT_N	
	    
	);
input       FM_PS_EN ;
input       SysLedG_ox ;
input       SysLedR_ox ;
input [1:0] PowerNormal_ox;
input [1:0]	PowerFail_ox;
input		FanFail_ox;
input		FanOK_ox;
input [1:0]	RJ45Speed1R_ox;
input [1:0]	RJ45Speed2R_ox;
input [1:0]	RJ45RActivity_ox;

output		 SYS_LEDG_N;
output		 SYS_LEDR_N;
output [1:0] PSU_Normal_N;
output [1:0] PSU_Fail_N;
output		 FAN_LEDR_N;
output		 FAN_LEDG_N;
output [1:0] CPLD_LAN_LINK1000_N;
output [1:0] CPLD_LAN_LINK100_N;
output [1:0] CPLD_LAN_ACT_N;	
		
	// ------------------------------------------------
    assign SYS_LEDG_N     = (`PwrSW_On == FM_PS_EN ) ? SysLedG_ox     : 1'b1;  //- SysLedG , 
    assign SYS_LEDR_N     = (`PwrSW_On == FM_PS_EN ) ? SysLedR_ox     : 1'b1;  //- SysLedR  
    assign PSU_Normal_N   = (`PwrSW_On == FM_PS_EN ) ? PowerNormal_ox : 2'b11; //- PowerNormal 
    assign PSU_Fail_N     = (`PwrSW_On == FM_PS_EN)  ? PowerFail_ox   : 2'b11; //- PowerFail 
    assign FAN_LEDR_N 	  = (`PwrSW_On == FM_PS_EN)  ? FanFail_ox     : 1'b1;  //-FanFail	
    assign FAN_LEDG_N     = (`PwrSW_On == FM_PS_EN)  ? FanOK_ox       : 1'b1;  //-FanOK			
    
	assign CPLD_LAN_LINK1000_N 	= (`PwrSW_On == FM_PS_EN) ? RJ45Speed1R_ox	 : 2'b11 ; //-: 8'hFF; RJ45Speed1R 
	assign CPLD_LAN_LINK100_N   = (`PwrSW_On == FM_PS_EN) ? RJ45Speed2R_ox	 : 2'b11 ; //-: 8'hFF; RJ45Speed2R	 
	assign CPLD_LAN_ACT_N       = (`PwrSW_On == FM_PS_EN) ? RJ45RActivity_ox : 2'b11 ; //-: 8'hFF; RJ45RActivity  
	//----------------------------------------------------------------------
endmodule // OffLEDwhenPwrOff





