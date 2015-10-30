//////////////////////////////////////////////////////////////////////////////
// File name        : PCH.sv
// Module name      : PCH
// Description      : This module controls PCH FSM 
// Hierarchy Up     : PwrSequence
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/PwrSeqPackage.sv"
`include "../Verilog/Includes/If_PwrSeq.sv"
`include "../Verilog/Includes/If_Pin.sv"   
`include "../Verilog/Includes/If_Debug.sv"
//////////////////////////////////////////////////////////////////////////////
module PCH 
 (  
    If_Pin.pch     pin,          
    If_PwrSeq.pch  pwrSeq,
    If_Debug.pch   dbg        
 );
////////////////////////////////////////////////////////////////////////////// 
    enum logic [2:0] { st_fault      = 3'd0, 
                       st_off        = 3'd1, 
                       st_1v05_MAIN  = 3'd2,                  
                       st_1v5        = 3'd3,
                       st_done       = 3'd4, 
                       st_1v1_off    = 3'd5,
                       st_1v5_off    = 3'd6  }  CurrentState,  NextState; 

    logic  fault;
    logic  cnt_done;    

    assign dbg.pch_fsm = CurrentState;
//////////////////////////////////////////////////////////////////////////////   
// Current State
//////////////////////////////////////////////////////////////////////////////
    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
             if (  !pin.rst_n  )   CurrentState  <= st_off;
             else                  CurrentState  <= NextState;
    end      
//////////////////////////////////////////////////////////////////////////////
// NS = f( I, CS)
////////////////////////////////////////////////////////////////////////////// 
 always_comb begin: set_nextState
    
    unique case( CurrentState )

            
	  st_fault     : if( pwrSeq.goOut_fltSt )          NextState = st_off;
                     else                              NextState = st_fault;

      st_off       : if( fault )                       NextState = st_fault;
                     else if(  pwrSeq.PCH_PwrMain )    NextState = st_1v05_MAIN;
                     else                              NextState = st_off;

      st_1v05_MAIN : if( fault )                       NextState = st_fault;
                     else if( !pwrSeq.PCH_PwrMain)     NextState = st_1v5_off;
                     else if(  pin.mainP1v05_pwrgd )   NextState = st_1v5;
                     else                              NextState = st_1v05_MAIN;
            
      st_1v5       : if( fault )                       NextState = st_fault;
                     else if( !pwrSeq.PCH_PwrMain )    NextState = st_1v1_off;
                     else if(  pin.mainP1v5_pwrgd )    NextState = st_done;
                     else                              NextState = st_1v5;

      st_done      : if( fault )                       NextState = st_fault;
                     else if( !pwrSeq.PCH_PwrMain )    NextState = st_1v1_off;
                     else                              NextState = st_done;

      st_1v1_off   : if( fault )                       NextState = st_fault;
                     else if( !pin.mainP1v5_pwrgd )    NextState = st_1v5_off;
                     else                              NextState = st_1v1_off;

      st_1v5_off   : if( fault )                       NextState = st_fault;
                     else if( !pin.mainP1v05_pwrgd )   NextState = st_off;
                     else                              NextState = st_1v5_off;

      default     :  NextState = st_off;

    endcase 
 end      


   
//////////////////////////////////////////////////////////////////////////////
// O = f( CS )
////////////////////////////////////////////////////////////////////////////// 
    
    logic [1:0] PWRGD_monitor;  
    
    logic P1V5_EN      ; 
    logic P1V05_MAIN_EN; 


    always_ff @( posedge pin.clk or negedge pin.rst_n ) 
    begin     
         if (  !pin.rst_n  ) 
         begin                
                P1V5_EN            <= HIGH ;
                P1V05_MAIN_EN      <= LOW;
                    
                pwrSeq.PCH_PwrGD   <= LOW;
                pwrSeq.PCH_PwrFLT  <= LOW;

              
                PWRGD_monitor      <={LOW,LOW};  
                fault              <= LOW;
                    
         end
         else begin     

               P1V05_MAIN_EN     <= (CurrentState >= st_1v05_MAIN) && (CurrentState < st_1v5_off)  ? HIGH : LOW;
              
               P1V5_EN           <= (CurrentState >= st_1v5) && (CurrentState < st_1v1_off)  ? HIGH  : LOW;    
               
              
               pwrSeq.PCH_PwrGD  <= (CurrentState <= st_off  ) ? LOW  : ( 
                                    (CurrentState == st_done ) ? HIGH : 
                                    ((CurrentState > st_done  ) ? LOW : pwrSeq.PCH_PwrGD ) );     
                                                     
               pwrSeq.PCH_PwrFLT <= (CurrentState == st_fault) ? HIGH : LOW;         
				               
			   PWRGD_monitor     <= { pin.mainP1v05_pwrgd, pin.mainP1v5_pwrgd};
                                                                
          
				    
			   fault 	         <= ( P1V05_MAIN_EN && ( PWRGD_monitor[1] && !pin.mainP1v05_pwrgd ) ) ||
                                    ( P1V5_EN       && ( PWRGD_monitor[0] && !pin.mainP1v5_pwrgd  ) )     ;   
                          
         end
    end      
 
//////////////////////////////////////////////////////////////////////////////  
    assign pin.P1V5_en  =      P1V5_EN           ;  
    assign pin.mainP1v05_en  = P1V05_MAIN_EN     ; 


//////////////////////////////////////////////////////////////////////////////   
   /* genCntr #(  .maxCount(t19)  ) 
    FreeRunningCnt     
    (
        .maxCount_out   (  cnt_done     ),   // This is high when maxCount is reached   
       
        .clk_in         (  pin.clk          ),  
        .rst_L_in       (  pin.rst_n        ),		               
        .cnt_en_in      (  pwrSeq.PCH_PwrMain  ),	  
        .rst_sync_L_in  (  pwrSeq.PCH_PwrMain  )
    );  	
*/
//////////////////////////////////////////////////////////////////////////////
  

endmodule  // PCH
 