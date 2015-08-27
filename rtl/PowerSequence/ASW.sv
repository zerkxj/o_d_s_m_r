//////////////////////////////////////////////////////////////////////////////
// File name        : ASW.sv
// Module name      : ASW
// Description      : This module controls Acitve Sleep Well power Sequence
// Hierarchy Up     : PwrSequence
// Hierarchy Down   : GenCntr
//////////////////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/PwrSeqPackage.sv"
//- `include "../Verilog/Includes/If_PwrSeq.sv"
`include "../Verilog/Includes/If_Pin.sv"   
`include "../Verilog/Includes/If_Debug.sv"
    
 module ASW
 (
    If_Pin.asw       pin,            
 //-   If_PwrSeq.asw    pwrSeq,
    If_Debug.asw     dbg
);  


////////////////////////////////////////////////////////////////////////////// 
    enum logic [2:0] { st1_off       = 3'd0,   // change logic [1:0] to logic [2:0] for consistent with dbg.asw_fsm[2:0] for simulation
                       st1_t514      = 3'd1,
                       st1_Done      = 3'd2  }  CState,  NState; 

    logic  fault_asw;    
    logic  t514_done;  
	logic  stbyP1v05_en_n; 
    assign dbg.asw_fsm = CState;
//////////////////////////////////////////////////////////////////////////////
// Current State
//////////////////////////////////////////////////////////////////////////////

    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
             if (  !pin.rst_n  )   CState  <= st1_off;
             else                  CState  <= NState;
    end      
//////////////////////////////////////////////////////////////////////////////   
// NS = f( I, CS)
//////////////////////////////////////////////////////////////////////////////
    always_comb begin: set_nState_asw
    
         unique case( CState )

              st1_off      :  if(  pin.stbyP1v05_pwrgd )    	 NState = st1_t514;                            
                              else                               NState = st1_off;                  

              st1_t514     :  if(  t514_done  )             	 NState = st1_Done;                            
                              else                               NState = st1_t514;                  

              st1_Done 	   :  if( !pin.stbyP1v05_pwrgd )    	 NState = st1_off;                            
                              else                               NState = st1_Done;                  
                              
              default      :  NState = st1_off;              
              
         endcase 
   end      
//////////////////////////////////////////////////////////////////////////////   
// O = f( CS )
//////////////////////////////////////////////////////////////////////////////
    logic ASW_pwrgd_dly;

    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
         if (  !pin.rst_n  ) begin
              
                pin.pch_apwrok       <= LOW;
         end
         else begin     
                pin.pch_apwrok       <= (CState == st1_Done)  ? HIGH : LOW;//// para el m3
         end
    end          
    
//////////////////////////////////////////////////////////////////////////////
 
    GenCntr #(  .maxCount(t514)  ) 
	 GenCntr                              //- t514_Cnt  , Counter = 1ms   
    (
        .maxCount_out   (  t514_done   ), // This is high when maxCount is reached   
        .counter_reg    (),               // Add for simulation  
        .clk_in         (  pin.clk     ),  
        .rst_L_in       (  pin.rst_n   ),		               
        .cnt_en_in      (  CState == st1_t514 ),	                  
        .rst_sync_L_in  (  CState == st1_t514 )
    );  	
//////////////////////////////////////////////////////////////////////////////

 endmodule  // ASW
