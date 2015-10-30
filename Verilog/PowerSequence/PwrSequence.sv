//////////////////////////////////////////////////////////////////////////////
// File name        : PwrSequence.sv
// Module name      : PwrSequence
// Description      : This module controls Power Sequence 
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : MstrSeq, CPU_Mem, PCH, Misc, ASW, 
//                  : LinkBlock, If_Debug, If_Pin, If_PwrSeq
//////////////////////////////////////////////////////////////////////////////
  
//- `default_nettype none
`include "../Verilog/Includes/If_PwrSeq.sv"
`include "../Verilog/Includes/If_Pin.sv"   
`include "../Verilog/Includes/If_Debug.sv"
//////////////////////////////////////////////////////////////////////////////
module PwrSequence 
(
    input   logic  CLK_33K_SUSCLK_PLD_R2,
    input   logic  RST_RSMRST_N, 


                // ----------------------------
                // PwrSeq control signals
                // ----------------------------             
    input   logic  FM_BMC_ONCTL_N,
    output  logic  FM_PS_EN,
    input   logic  PWRGD_PS_PWROK_3V3 ,
    input   logic  FM_SLPS3_N,
    input   logic  FM_SLPS4_N,

                // ----------------------------
                // Clock enables
                // ----------------------------             
    output  logic  FM_PLD_CLK_EN,

                // ----------------------------
                // Voltage regulator devices
                // ----------------------------
    input   logic  PWRGD_P1V05_STBY_PCH_P1V0_AUX,
    input   logic  PWRGD_P3V3_AUX , 	
    output  logic  FM_P1V5_PCH_EN,  
    output  logic  FM_VCC_MAIN_EN,
    input   logic  PWRGD_P1V5_PCH,
    input   logic  PWRGD_P1V05_PCH,	
    output  logic  PVCCIN_CPU0_EN, 
    input   logic  PWRGD_PVCCIN_CPU0,
    output  logic  FM_VPP_MEM_ABCD_EN,
    input   logic  PWRGD_PVPP_PVDDQ_AB,
    input   logic  PWRGD_PVPP_PVDDQ_CD, 
	
	output  logic  BCM_V1P0_EN,
	output  logic  BCM_V1P0A_EN,
    input   logic  BCM_P1V_PG,
	input   logic  BCM_P1VA_PG,
    
                // ----------------------------
                // Presence signals
                // ----------------------------             
    input   logic  FM_PCH_PRSNT_CO_N,
    input   logic  FM_CPU0_SKTOCC_LVT3_N,  
    input   logic  FM_CPU0_BDX_PRSNT_LVT3_N,
   
    
                // ----------------------------
                // Miscellaneous signals
                // ----------------------------             
    //- output  logic  FP_PWR_BTN_N, // Frank 06022015 mask

    input   logic  FM_THERMTRIP_CO_N,
    output  logic  FM_LVC3_THERMTRIP_DLY,	
    input   logic  IRQ_SML1_PMBUS_ALERT_BUF_N,
    output  logic  IRQ_FAN_12V_GATE,	
    input   logic  FM_CPU_ERR1_CO_N,
    output  logic  FM_ERR1_DLY_N,   
    output  logic  RST_PLTRST_DLY, // for pltrst_dly   
    output  logic  FM_PVTT_ABCD_EN, 
	
                // ----------------------------
                // Power good signals
                // ----------------------------       
    output  logic  PWRGD_P1V05_PCH_STBY_DLY,   
    output  logic  PWRGD_PCH_PWROK_R,    
    output  logic  PWRGD_SYS_PWROK_R,  
    input   logic  PWRGD_CPUPWRGD,
    output  logic  PWRGD_CPU0_LVC3_R,    
 

                // ----------------------------
                // Reset signals
                // ----------------------------             
    input   logic  RST_PLTRST_N, 
    
                // ----------------------------
                // ITP interface
                // ----------------------------             
    input  logic   XDP_RST_CO_N,
    input  logic   XDP_PWRGD_RST_N,
    input  logic   XDP_CPU_SYSPWROK,
        
                             	
                // ----------------------------
                // CPLD debug hooks
                // ----------------------------      
				
    input   logic   FM_PLD_DEBUG_MODE_N,
    input   logic   FM_PLD_DEBUG1, 
	
//  FM_PLD_DEBUG5/4/3/2 internal wires output from MstrSeq	
  	output  logic   FM_PLD_DEBUG2,    
    output  logic   FM_PLD_DEBUG3,
    output  logic   FM_PLD_DEBUG4,  
   	output  logic   FM_PLD_DEBUG5, 
	
	            // ----------------------------
                //  PsonFromPwrEvent 
                // ----------------------------		
          
    input   logic   PsonFromPwrEvent, 
	input   logic [3:0] PowerEvtState   // Frank 08132015 add
);

//////////////////////////////////////////////////////////////////////////////
 
// Interfaces
  
     If_PwrSeq     PwrSeq_bus ();  
     If_Pin        pin_bus ();  
     If_Debug      dbg_bus ();  

// link between the outside world and the digital logic in the CPLD
  
    LinkBlock LinkBlock ( .*, .pin(pin_bus) );  


 
// Miscelaneous and debug
  
     
   Misc     Misc     ( .pin(pin_bus) );

////////////////////////////////////////////////////////////////////////////// 
// Power Sequence
////////////////////////////////////////////////////////////////////////////// 
   MstrSeq  MstrSeq  (  .pin(pin_bus), .pwrSeq(PwrSeq_bus), .dbg(dbg_bus) );

   PCH      PCH      (  .pin(pin_bus), .pwrSeq(PwrSeq_bus), .dbg(dbg_bus) );              
	 
   ASW      ASW      (  .pin(pin_bus),                      .dbg(dbg_bus) ); 
	                                  
   CPU_Mem  CPU_Mem  (  .pin(pin_bus), .pwrSeq(PwrSeq_bus), .dbg(dbg_bus) );   
                  
                  
//////////////////////////////////////////////////////////////////////////////   
  
  
endmodule // PwrSequence

