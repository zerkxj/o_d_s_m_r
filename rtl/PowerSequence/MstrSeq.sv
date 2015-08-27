//////////////////////////////////////////////////////////////////////////////
// File name        : MstrSeq.sv
// Module name      : MstrSeq
// Description      : This module controls Master power Sequence
// Hierarchy Up     : PwrSequence
// Hierarchy Down   : Counter
//////////////////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/PwrSeqPackage.sv"
`include "../Verilog/Includes/If_PwrSeq.sv"
`include "../Verilog/Includes/If_Pin.sv"   
`include "../Verilog/Includes/If_Debug.sv"

 module MstrSeq
 ( 
    If_Pin.master      pin,
    If_PwrSeq.master   pwrSeq,
    If_Debug.master    dbg 
); 
//////////////////////////////////////////////////////////////////////////////
// Condition to make the system go out of fault state
//////////////////////////////////////////////////////////////////////////////   
////////////////////////////////////////////////////////////////////////////// 
    enum logic [4:0] { st_fault         = 5'd0,
                       st_STBY          = 5'd1,
                       st_S3            = 5'd2,					   
                       st_off           = 5'd3,
                       st_PS            = 5'd4,
                       st_clkSlot       = 5'd5,                       
                       st_PCH           = 5'd6,
                       st_CPU_MEM       = 5'd7,
                       st_PWROK         = 5'd8,
                       st_SYSPWROK      = 5'd9,
                       st_CPUPWRGD      = 5'd10,
                       st_RESET         = 5'd11,                                              
                       st_done          = 5'd12,
                       st_shutDown      = 5'd13,
                       st_PCH_off       = 5'd14,
                       st_PS_off        = 5'd15   }  CurrentState,  NextState, CurrentState_dly; 
	localparam       maxCount = t_100ms;
    localparam       bitH     = logb2(maxCount);    
    logic            PwrEn;
    logic            fault;
    logic            cnt_done;      
    logic            allCPU_PwrGD;
    logic            allMEM_PwrGD;
    logic            allCPU_OFF;
    logic            allMEM_OFF;
    logic            allVCCP_PwrGD;	
    logic            P3v3Aux_PwrFLT ;    
    logic [bitH : 0] setCount;  
    logic            enableCnt;
    logic            cnt_doneX;
    logic            rstCnt_n; 	
    logic            P3v3Aux_pwrgd_dly ; 
	logic [3:0]      PWRGD_monitor;
    logic            rst_board_n; 
    logic            delay20ms_from_ps_on_rising ;
	logic            cpu_pwrgd;
	logic            psonpwrseq ;      
//////////////////////////////////////////////////////////////////////////////	
    assign PwrEn = !pin.ibmc_pson_n  & 
                    pin.cpu_validcfg & 
                   !pin.pch_prsnt_n  & 
                   !fault | pin.slpS3_n ;       // pin.slpS3_n will be determined by PCH After_G3 bit when restoring AC power from G3.	
    assign pwrSeq.goOut_fltSt = (CurrentState == st_fault) && !pin.dbgmode_n; 
//////////////////////////////////////////////////////////////////////////////    
// Current State
//////////////////////////////////////////////////////////////////////////////
    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
             if (  !pin.rst_n  )   CurrentState  <= st_STBY;
             else                  CurrentState  <= NextState;
    end      


    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
        
             if (  !pin.rst_n  )   CurrentState_dly  <= st_STBY;
             else                  CurrentState_dly  <= CurrentState;
    end      


    assign dbg.mstr_fsm = CurrentState;  
	
//////////////////////////////////////////////////////////////////////////////	
// NS = f( I, CS)
//////////////////////////////////////////////////////////////////////////////

    
    always_comb begin: set_nextState
    
      unique case( CurrentState )   

         st_fault    : if( pwrSeq.goOut_fltSt )       NextState = st_STBY;
                       else                           NextState = st_fault;
					   
         st_STBY     : if( fault )                    NextState = st_fault;
                       else if( pin.P3v3Aux_pwrgd )   NextState = st_off;  
                       else                           NextState = st_STBY;
								
         st_S3       : if( fault )                    NextState = st_fault;
                       else if( pin.slpS3_n )         NextState = st_off;
                       else                           NextState = st_S3;
								
         st_off      : if( fault )                    NextState = st_fault;
                       else if( PwrEn )               NextState = st_PS;				 
                       else                           NextState = st_off;

         st_PS       : if( pin.ps_pwrok )             NextState = st_clkSlot;
                       else if( !PwrEn )              NextState = st_PS_off;
                       else                           NextState = st_PS;
   
         st_clkSlot  : if( pin.pch_apwrok )           NextState = st_PCH;
                       else if( !PwrEn )              NextState = st_PS_off;
                       else                           NextState = st_clkSlot;
          

         st_PCH      : if( pwrSeq.PCH_PwrGD )         NextState = st_CPU_MEM;
                       else if( !PwrEn )              NextState = st_PCH_off;
                       else                           NextState = st_PCH;
                                                                                                             
         st_CPU_MEM  : if( pwrSeq.MEM_PwrGD && cnt_done && pin.xdp_pwrgd )
                                                      NextState = st_PWROK;                                
                       else if( !PwrEn )              NextState = st_shutDown;
				       else                           NextState = st_CPU_MEM;               

         st_PWROK    : if( pwrSeq.CPU_PwrGD && pin.xdp_syspwrok ) 
                                                      NextState = st_SYSPWROK;                         
                       else if( !PwrEn )              NextState = st_shutDown;
                       else                           NextState = st_PWROK;           

                                                                                   
         st_SYSPWROK : if( !PwrEn )                   NextState = st_shutDown;
                       else if( pin.pch_cpupwrgd )	  NextState = st_CPUPWRGD;
                       else                           NextState = st_SYSPWROK;

         st_CPUPWRGD : if( pin.pch_cpupwrgd )         NextState = st_RESET;
                       else if( !PwrEn )              NextState = st_shutDown;
                       else                           NextState = st_CPUPWRGD;
                                                                                   
         st_RESET    : if( pin.pch_pltrst_n && pin.xdp_rst_n )           
		                                              NextState = st_done;
                       else if( !PwrEn )              NextState = st_shutDown;
                       else if( !pin.slpS3_n )        NextState = st_shutDown;
                       else                           NextState = st_RESET; 
 
         st_done     : if ( !PwrEn )                  NextState = st_shutDown;  
                       else if( !pin.pch_pltrst_n )   NextState = st_RESET;					   
                       else                           NextState = st_done;         

         st_shutDown : if(!pwrSeq.CPU_PwrGD && (!pwrSeq.MEM_PwrGD | ( !pin.slpS3_n & pin.slpS4_n )) | fault)
                                                      NextState = st_PCH_off;
                       else if ( !pin.slpS3_n )       NextState = st_PCH_off;
                       else                           NextState = st_shutDown;

         st_PCH_off  : if( !pwrSeq.PCH_PwrGD )        NextState = st_PS_off;
                       else                           NextState = st_PCH_off;

         st_PS_off   : if( !pin.ps_pwrok && (!pin.slpS3_n & pin.slpS4_n) )
                                                      NextState = st_S3;
                       else if ( !pin.ps_pwrok && !pin.ibmc_pson_n && !pin.slpS3_n )
                                                      NextState = st_PS_off;
                       else if ( !pin.ps_pwrok )      NextState = st_off; 
                       else                           NextState = st_PS_off;
					   
         default     :                                NextState = st_STBY;                          
      endcase 
   end   


   assign fault  =  ( P3v3Aux_PwrFLT )     |          
                    ( pwrSeq.PCH_PwrFLT )  |
                    ( pwrSeq.CPU_PwrFLT )  |
                    ( pwrSeq.MEM_PwrFLT )    ;

   assign dbg.pwr_fault = fault;

//////////////////////////////////////////////////////////////////////////////  
// O = f( CS )
//////////////////////////////////////////////////////////////////////////////
    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
       if (  !pin.rst_n  ) begin            
                  
             
//-          pin.ps_en            <= LOW;  
             psonpwrseq           <= LOW ;  // Debug test 		   
			 
             pin.cpu_clken_n      <= LOW;                         
             
             pwrSeq.PCH_PwrMain   <= LOW;
             pwrSeq.MEM_PwrEN     <= LOW;
             pwrSeq.CPU_PwrEN     <= LOW;
             pin.pch_pwrok        <= LOW;             
             cpu_pwrgd            <= LOW;      
                     
             pin.pch_syspwrok     <= LOW;

             rst_board_n          <= LOW;
       end
       else begin         
             
//-          pin.ps_en            <= (CurrentState >= st_PS)  && (CurrentState < st_PS_off)   ?  HIGH : LOW;        
             psonpwrseq           <= (CurrentState >= st_PS)  && (CurrentState < st_PS_off)   ?  HIGH : LOW;
			 
             pin.cpu_clken_n      <= (CurrentState >= st_CPU_MEM)  && (CurrentState < st_PCH_off) ?  HIGH  : LOW;
           
             pwrSeq.PCH_PwrMain   <= (CurrentState >= st_PCH)      && (CurrentState < st_PCH_off)  ?  HIGH : LOW; 			 
            
			 pwrSeq.MEM_PwrEN     <= (CurrentState >= st_CPU_MEM)  && (CurrentState < st_shutDown) ? HIGH : (!pin.slpS4_n ? LOW : pwrSeq.MEM_PwrEN);
			    
			 
             pwrSeq.CPU_PwrEN     <= (CurrentState >= st_CPU_MEM)   && (CurrentState < st_shutDown) ?  HIGH : LOW;            

//-          pin.pch_pwrok        <= ((CurrentState >= st_PWROK)    && (CurrentState < st_PCH_off)  ) ?  HIGH : LOW;
             pin.pch_pwrok        <= ((CurrentState >= st_PWROK)    && (CurrentState < st_PCH_off) &&  pin.bcm_p1v_pg && pin.bcm_p1va_pg ) ?  HIGH : LOW;			 
            	
             cpu_pwrgd            <= pin.pch_cpupwrgd;
                     
             pin.pch_syspwrok     <= (CurrentState >=st_SYSPWROK)  && (CurrentState < st_shutDown) ?  HIGH : LOW;      
                                   
             
             rst_board_n          <=   (CurrentState == st_done) ? HIGH:LOW; 
       end
    end      
 
`ifdef  ONLY_PowerUp
assign pin.ps_en = psonpwrseq  ;                         // Frank 07152015 for testing
`else 
assign pin.ps_en = psonpwrseq  &  pin.psonfrompwrevent ; // Frank 07152015 for testing
`endif 
//////////////////////////////////////////////////////////////////////////////
   always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
      if (  !pin.rst_n  ) 
             pin.cpu0_pwrgd       <= LOW;  	 
      else 
             pin.cpu0_pwrgd       <= cpu_pwrgd     & !pin.cpu0_sktocc_n;        
   end 	  
//=========================================================================	  
	  
	  
// +------+------+------+-----+------+------+------+------+------+------+
// **** Required logic to perform logic and full power cycle through xdp
// +------+------+------+-----+------+------+------+------+------+------+
    logic  xdp_pwrgd_dly;

    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
        if (   !pin.rst_n      )  xdp_pwrgd_dly  <=  HIGH;                    
        else                      xdp_pwrgd_dly  <=  pin.xdp_pwrgd;    
    end    

// +------+------+------+----------+------+------+------+------+------+------+------+------+------+
// It is the logic required to perform time delays according to the current state with a single COUNTER
// +------+------+------+-----+------+------+------+------+------+------+------+------+------+
        
    assign rstCnt_n = !(CurrentState != CurrentState_dly);
    assign cnt_done =  rstCnt_n & cnt_doneX;

 //---------------------------------------------
    Counter #( .maxCount(maxCount) ) 
    Counter  
    (       .clk         ( pin.clk           ), 
            .rst_n       ( pin.rst_n         ),
             
            .rst_sync_n  (  rstCnt_n              ),
            .enable      (  rstCnt_n & enableCnt  ),
            .load        (!(rstCnt_n & enableCnt) ),
            .setCount    ( setCount               ),
             
            .done        ( cnt_doneX   ),
            .mem         (             )
    );

    always_comb 
    begin         
              case( CurrentState )   
                 
                  st_CPU_MEM       :   setCount = t_100ms [bitH:0];     
                
                                 
                  default          :   setCount = '1;
                                                
               endcase 
    end                                   

    assign   enableCnt = ( CurrentState == st_CPU_MEM ) ?  HIGH : LOW;                              
                      
////////////////////////////////////////////////////////////////////////////// 
// It is the logic required to check a P3V3Aux VR fault
//////////////////////////////////////////////////////////////////////////////  
// O = f( CS )
//////////////////////////////////////////////////////////////////////////////
    

    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
         if     (  !pin.rst_n  )  begin
                 P3v3Aux_pwrgd_dly  <=   LOW;      
         end
         else begin     
                 P3v3Aux_pwrgd_dly  <=   pin.P3v3Aux_pwrgd ;      
         end
    end 
    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
         if     (  !pin.rst_n  )  begin
                   P3v3Aux_PwrFLT      <=   LOW;     
         end 
		 else if(  !pin.P3v3Aux_pwrgd && P3v3Aux_pwrgd_dly  )  begin   
				   P3v3Aux_PwrFLT      <=   HIGH;        
		 end		  
         else if(  pwrSeq.goOut_fltSt ) begin     
                   P3v3Aux_PwrFLT      <=   LOW;    
         end
		 else      P3v3Aux_PwrFLT      <=   P3v3Aux_PwrFLT ;          
    end  
  
//////////////////////////////////////////////////////////////////////////////
// Debug : For Power state machine display.            
//////////////////////////////////////////////////////////////////////////////
assign pin.cpld_debug1 = pin.cpld_debug0 ? dbg.mstr_fsm[0] : pwrSeq.PCH_PwrFLT;
assign pin.cpld_debug2 = pin.cpld_debug0 ? dbg.mstr_fsm[1] : pwrSeq.CPU_PwrFLT;
assign pin.cpld_debug3 = pin.cpld_debug0 ? dbg.mstr_fsm[2] : dbg.pch_fsm[2];
assign pin.cpld_debug4 = pin.cpld_debug0 ? dbg.mstr_fsm[3] : P3v3Aux_PwrFLT ; 
////////////////////////////////////////////////////////////////////////////// 

//////////////////////////////////////////////////////////////////////////////
// Power Enable of BCM56842 Ethernet Switch           
//////////////////////////////////////////////////////////////////////////////

    GenCntr #( .maxCount(t_20ms)  ) 
     GenCntr                                        
    (
        .maxCount_out   (  delay20ms_from_ps_on_rising ), // output 1 when cnt == maxCount.   
        .counter_reg    (),                               // Need for Simulation 
        .clk_in         (  pin.clk     ),  
        .rst_L_in       (  pin.rst_n   ),		               
        .cnt_en_in      (  1'b1        ),	  
        .rst_sync_L_in  (  pin.ps_en   )
    );  	    

 assign pin.bcm_v1p0_en  = delay20ms_from_ps_on_rising ;
 assign pin.bcm_v1p0a_en = delay20ms_from_ps_on_rising ;  
 //////////////////////////////////////////////////////////////////////////////
 
 
endmodule //MstrSeq


