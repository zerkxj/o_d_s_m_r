//////////////////////////////////////////////////////////////////////////////
// File name        : LinkBlock.sv
// Module name      : LinkBlock
// Description      : This module defines Linkage between External pins to 
//                    Internal logic
// Hierarchy Up     : PwrSequence
// Hierarchy Down   : Debouncer2 , GenCntr
//////////////////////////////////////////////////////////////////////////////  
`include "../Verilog/Includes/If_Pin.sv"   
`include "../Verilog/Includes/PwrSeqPackage.sv"

module LinkBlock
(         
    If_Pin.phy  pin,
     
     
    input   logic  CLK_33K_SUSCLK_PLD_R2,
    input   logic  RST_RSMRST_N,

                // ----------------------------
                // PwrSeq control signals
                // ----------------------------             
    input   logic  FM_BMC_ONCTL_N,
    output  logic  FM_PS_EN,
    input   logic  PWRGD_PS_PWROK_3V3,
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
    input   logic  PWRGD_P3V3_AUX,	
    
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
    input	logic  FM_CPU0_BDX_PRSNT_LVT3_N,
   
    
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
    output  logic  RST_PLTRST_DLY,	
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
	
    output  logic   FM_PLD_DEBUG2, // Output from MstrSeq module pin.cpld_debug1,    
    output  logic   FM_PLD_DEBUG3,
    output  logic   FM_PLD_DEBUG4,  
   	output  logic   FM_PLD_DEBUG5, 
	
	            // ----------------------------
                //  PsonFromPwrEvent 
                // ----------------------------		
          
    input   logic   PsonFromPwrEvent
);
    
	 
 // +++------------------- +++ ------------------- +++ ------------------- +++ ------------------- +++
 // +++------------------- +++ ------------------- +++ ------------------- +++ ------------------- +++
 
    assign  pin.clk    =  CLK_33K_SUSCLK_PLD_R2 ;
    assign  pin.rst_n  =  RST_RSMRST_N ;
	

 // +++------------------- +++ ------------------- +++ ------------------- +++ ------------------- +++
 // Free running counter: its done output is high for a clock period each time maxCount is reached
 // +++------------------- +++ ------------------- +++ ------------------- +++ ------------------- +++
    logic  cnt1ms_done;

    GenCntr #( .maxCount(t_1ms)  ) 
     GenCntr                                  // FreeRunningCnt     
    (
        .maxCount_out   (  cnt1ms_done ),     // It is high when cnt == maxCount.   
        .counter_reg    () ,                  // Add for simulation  
        .clk_in         (  pin.clk     ),  
        .rst_L_in       (  pin.rst_n   ),		               
        .cnt_en_in      (  1'b1        ),	  
        .rst_sync_L_in  ( !cnt1ms_done )
    );  	    

    assign pin.cnt1ms_done = cnt1ms_done;
 // +++------------------- +++ ------------------- +++ ------------------- +++ ------------------- +++


                // ----------------------------
                // PwrSeq control signals
                // ----------------------------             
    assign  pin.ibmc_pson_n       	=  FM_BMC_ONCTL_N;

    assign  FM_PS_EN              	=  pin.ps_en;
    assign  pin.ps_pwrok          	=  PWRGD_PS_PWROK_3V3;
  
    assign  pin.slpS3_n           	=  FM_SLPS3_N;
    assign  pin.slpS4_n           	=  FM_SLPS4_N;    
        
                // ----------------------------
                // Clock enables
                // ----------------------------             
    assign  FM_PLD_CLK_EN     	 	=  pin.cpu_clken_n ;

	            // ----------------------------
                // Voltage regulator devices
                // ----------------------------           

    assign  pin.stbyP1v05_pwrgd   	=  PWRGD_P1V05_STBY_PCH_P1V0_AUX; 
    assign  pin.P3v3Aux_pwrgd       =  PWRGD_P3V3_AUX ; 	   
	assign  FM_P1V5_PCH_EN 	    	=  pin.P1V5_en; 	
	assign  FM_VCC_MAIN_EN        	=  pin.mainP1v05_en ; 
	assign  pin.mainP1v5_pwrgd    	=  PWRGD_P1V5_PCH;
    assign  pin.mainP1v05_pwrgd   	=  PWRGD_P1V05_PCH; 	
    assign  PVCCIN_CPU0_EN         	=  pin.pvccin_cpu0_en;  	
    assign  pin.vccin_cpu0_pwrgd   	=  PWRGD_PVCCIN_CPU0; 
    assign  FM_VPP_MEM_ABCD_EN     	=  pin.vpp_mem_abcd_en;
    assign  pin.pvpp_vddq_ab_pwrgd 	=  PWRGD_PVPP_PVDDQ_AB;
    assign  pin.pvpp_vddq_cd_pwrgd 	=  PWRGD_PVPP_PVDDQ_CD;	
      
      
    assign  BCM_V1P0_EN             =  pin.bcm_v1p0_en;
	assign  BCM_V1P0A_EN            =  pin.bcm_v1p0a_en;
    assign  pin.bcm_p1v_pg          =  BCM_P1V_PG;
	assign  pin.bcm_p1va_pg         =  BCM_P1VA_PG;
   
      
	 
    
	        

        
                // ----------------------------
                // Presence signals
                // ----------------------------             
    assign  pin.pch_prsnt_n    		=  FM_PCH_PRSNT_CO_N;
    assign  pin.cpu0_sktocc_n  		=  FM_CPU0_SKTOCC_LVT3_N; 	
    assign  pin.cpu0_sktid_n   		=  FM_CPU0_BDX_PRSNT_LVT3_N;
    

                // ----------------------------
                // Miscellaneous signals
                // ----------------------------                
    //- assign  FP_PWR_BTN_N            	=  pin.pwrbtn_n ? HighZ : LOW; // Frank 06022015 mask 
    
    assign  pin.thermtrip_n        	=  FM_THERMTRIP_CO_N;
	assign  FM_LVC3_THERMTRIP_DLY  	=  pin.thermtrip_dly; 
    assign  pin.irq_alert_n        	=  IRQ_SML1_PMBUS_ALERT_BUF_N;
	assign  IRQ_FAN_12V_GATE      	=  pin.irq_fan_gate;  
    assign  pin.err1_n             	=  FM_CPU_ERR1_CO_N;              
    assign  FM_ERR1_DLY_N          	=  pin.err1_dly_n  ? HighZ : LOW; 
    assign  RST_PLTRST_DLY       	=  pin.throttle_sys;    
    assign  FM_PVTT_ABCD_EN         =  pin.vtt_abcd_en;
         
                // ----------------------------
                // Power good signals
                // ----------------------------                       
   assign  PWRGD_P1V05_PCH_STBY_DLY =  pin.pch_apwrok;
   assign  PWRGD_PCH_PWROK_R      	=  pin.pch_pwrok;
   assign  PWRGD_SYS_PWROK_R  		=  pin.pch_syspwrok;     
   assign  pin.pch_cpupwrgd       	=  PWRGD_CPUPWRGD;  
   assign  PWRGD_CPU0_LVC3_R  		=  pin.cpu0_pwrgd;

                // ----------------------------
                // Reset signals
                // ----------------------------       
    assign  pin.pch_pltrst_n       	=  RST_PLTRST_N;
// Frank 07092015 move to other module
    
                // ----------------------------
                // ITP interface
                // ----------------------------                       
    assign  pin.xdp_rst_n    		=  XDP_RST_CO_N;
    assign  pin.xdp_pwrgd    		=  XDP_PWRGD_RST_N;  
    assign  pin.xdp_syspwrok 		=  XDP_CPU_SYSPWROK;
	

///////////////////////////////////////////////////////////////////////////// 
// CPLD debug hooks
/////////////////////////////////////////////////////////////////////////////
   
  wire DBGMODE_N;

  
    Debouncer2  #( .maxCount(2) ) Debouncer2  // 20 ms with 33Khz clock without enable signal
    ( 
        .clk(pin.clk), .rst_n(pin.rst_n), .in_put(FM_PLD_DEBUG_MODE_N), .out_put(DBGMODE_N), .deb_en(pin.cnt1ms_done)
    );

    assign  pin.dbgmode_n       =  DBGMODE_N;

/////////////////////////////////////////////////////////////////////////////                     


    assign  pin.cpld_debug0 =  FM_PLD_DEBUG1   ;    
	assign  FM_PLD_DEBUG2   =  pin.cpld_debug1 ;     
    assign  FM_PLD_DEBUG3   =  pin.cpld_debug2 ;  
    assign  FM_PLD_DEBUG4   =  pin.cpld_debug3 ;  
   	assign  FM_PLD_DEBUG5   =  pin.cpld_debug4 ;   
	
/////////////////////////////////////////////////////////////////////////////
         	
          
    assign  pin.psonfrompwrevent =  PsonFromPwrEvent ;  	


endmodule  // LinkBlock
