//////////////////////////////////////////////////////////////////////////////
// File name        : If_Pin.sv
// Module name      : ---
// Description      : This interface defines all signals for PwrSequence module
// Hierarchy Up     : --- 
// Hierarchy Down   : --- 
//////////////////////////////////////////////////////////////////////////////
`ifndef   IF_PIN_H
`define   IF_PIN_H
//////////////////////////////////////////////////////////////////////////////   

  interface If_Pin ;
//////////////////////////////////////////////////////////////////////////////     
            logic  clk;
            logic  rst_n;

                // ----------------------------
                // PwrSeq control signals
                // ----------------------------             
            logic  ibmc_pson_n;
            logic  ps_en;
            logic  ps_pwrok;
            logic  slpS3_n;
            logic  slpS4_n;     
			
                // ----------------------------
                // Clock enables
                // ----------------------------             
            logic  cpu_clken_n;

     			// ----------------------------
                // Voltage regulator devices
                // ----------------------------             
           
            logic  stbyP1v05_pwrgd;
            logic  P3v3Aux_pwrgd ;   
		
            logic  P1V5_en;
         
            logic  mainP1v05_en;
            logic  mainP1v5_pwrgd;
            logic  mainP1v05_pwrgd;			
			
	        logic  pvccin_cpu0_en;	
	        logic  vccin_cpu0_pwrgd;
	 
			
	        logic  vpp_mem_abcd_en;
	        logic  pvpp_vddq_ab_pwrgd;
	        logic  pvpp_vddq_cd_pwrgd;			
	          
			logic  bcm_v1p0_en;
	        logic  bcm_v1p0a_en;
            logic  bcm_p1v_pg;
	        logic  bcm_p1va_pg; 
			
                // ----------------------------
                // Presence signals
                // ----------------------------             
            logic  pch_prsnt_n;
            logic  cpu0_sktocc_n;
     
            logic  cpu_validcfg; // Not a physical pin		
	        logic  cpu0_sktid_n;
	  

   
                // ----------------------------
                // Miscellaneous signals
                // ----------------------------             
          //-  logic  pwrbtn_n;  Frank 06032015 mask 
            logic  thermtrip_n;
            logic  thermtrip_dly;    
            logic  irq_alert_n;
            logic  irq_fan_gate;
            logic  err1_n;
            logic  err1_dly_n;
            
            logic  throttle_sys;     
            logic  cnt1ms_done; 	 // Not a physical pin       
	        logic  vtt_abcd_en;
           
                // ----------------------------
                // Power good signals
                // ----------------------------       
            logic  pch_apwrok;   
            logic  pch_pwrok;    
            logic  pch_syspwrok; 
            logic  pch_cpupwrgd;      
            logic  cpu0_pwrgd;
       

                // ----------------------------
                // Reset signals
                // ----------------------------             
            logic  pch_pltrst_n;
	
                // ----------------------------
                // ITP interface
                // ----------------------------             
            logic  xdp_rst_n;
            logic  xdp_pwrgd;
       
            logic  xdp_syspwrok;
        
                // ----------------------------
                // CPLD debug hooks
                // ----------------------------                          
            logic  dbgmode_n;
       
            logic  cpld_debug0;			
	
            logic  cpld_debug1;
			logic  cpld_debug2;
			logic  cpld_debug3;
            logic  cpld_debug4;                                                  
                // ----------------------------  

                // ----------------------------
                //  PsonFromPwrEvent 
                // ----------------------------				
			logic  psonfrompwrevent ; 	
			logic  [3:0] powerevtstate ;  // Frank 08132015 add 
                // ---------------------------- 
				
       modport phy 
       ( 
            output	clk, rst_n,            
                    ibmc_pson_n, ps_pwrok, slpS3_n, slpS4_n,  
                    pch_prsnt_n, cpu0_sktocc_n,  cpu0_sktid_n, 
                    pch_cpupwrgd,
                    xdp_rst_n, xdp_pwrgd, xdp_syspwrok,               
                    dbgmode_n,               
                    stbyP1v05_pwrgd,                                  
                    pvpp_vddq_ab_pwrgd, pvpp_vddq_cd_pwrgd, P3v3Aux_pwrgd,  
                    vccin_cpu0_pwrgd, mainP1v5_pwrgd, mainP1v05_pwrgd, 
                    pch_pltrst_n, thermtrip_n, irq_alert_n, err1_n,      
                   	cpld_debug0, 
		            cnt1ms_done,     // not a physical pin	 
                    bcm_p1v_pg,   bcm_p1va_pg,
   		  		    psonfrompwrevent,    // Not a physical pin  
					powerevtstate ,      // Frank 08132015 add 
					
            input   ps_en, cpu_clken_n,  //- pwrbtn_n, Frank 06032015 mask
                    pch_apwrok,  pch_syspwrok,                      
                    cpu0_pwrgd,            
                    pch_pwrok,                      
                    P1V5_en, mainP1v05_en, pvccin_cpu0_en, vpp_mem_abcd_en,                   
                    vtt_abcd_en, 					 
                    thermtrip_dly, irq_fan_gate, err1_dly_n, throttle_sys,
					cpld_debug1, cpld_debug2, cpld_debug3, cpld_debug4, // Not physical pins 
					bcm_v1p0_en, bcm_v1p0a_en
       );                                           
                       

       modport master 
       ( 
            input   clk, rst_n, 
                    ibmc_pson_n, ps_pwrok, slpS3_n, slpS4_n, pch_apwrok, 
                    pch_prsnt_n, cpu0_sktocc_n,  cpu_validcfg,  
                    pch_cpupwrgd, pch_pltrst_n, 
					xdp_rst_n, xdp_pwrgd,xdp_syspwrok, 
		            dbgmode_n,
		            stbyP1v05_pwrgd, P3v3Aux_pwrgd , 
		            cpld_debug0,	
                    bcm_p1v_pg,  bcm_p1va_pg, 					
			        psonfrompwrevent,         // Not a physical pin 
					powerevtstate ,      // Frank 08132015 add 
            output  ps_en, cpu_clken_n,  //- pwrbtn_n, Frank 06032015 mask 
                    pch_pwrok, pch_syspwrok,                     
                    cpu0_pwrgd,
					cpld_debug1, cpld_debug2, cpld_debug3, cpld_debug4, // Not physical pins 
                    bcm_v1p0_en,bcm_v1p0a_en           
	        

		
       );                                    


       modport cpus
       ( 
            input   clk, rst_n, slpS3_n, cpu0_sktocc_n, cpu0_sktid_n,
        			pvpp_vddq_ab_pwrgd, pvpp_vddq_cd_pwrgd, vccin_cpu0_pwrgd, 
                   				
            output  cpu_validcfg, pvccin_cpu0_en,  vpp_mem_abcd_en, 			       
                    vtt_abcd_en 
       );                                    
                  
       modport asw 
       ( 
            input   clk, rst_n, 
                    stbyP1v05_pwrgd,
					
            output  pch_apwrok
       );                                    

       modport pch 
       ( 
            input   clk, rst_n,           
                    mainP1v5_pwrgd, mainP1v05_pwrgd, ps_en, slpS3_n,              
           
            output  P1V5_en,  mainP1v05_en           
       );                   
      
                                                   
       modport misc 
       ( 
            input   clk, rst_n, 
                    cnt1ms_done,   pch_pltrst_n,
                    thermtrip_n,   irq_alert_n,  err1_n,
                    pch_syspwrok,
					
            output  thermtrip_dly, irq_fan_gate, err1_dly_n, throttle_sys
       );                        
                                                         
   endinterface // If_Pin
   
//////////////////////////////////////////////////////////////////////////////

`endif