//////////////////////////////////////////////////////////////////////////////
// File name        : DelayLine.sv
// Module name      : DelayLine
// Description      : This module works a delay line 
// Hierarchy Up     : Misc
// Hierarchy Down   : GenCntr ( Instantiation twice ) 
//////////////////////////////////////////////////////////////////////////////
// DelayLine module is useful to "delay" an input signal by a specific amount 
// of clock cycles. The user will see the output signal match the input signal
// but with a delay in terms of clock cycles. It doesn't mind the shape of the
// input signal. 
//////////////////////////////////////////////////////////////////////////////                    
// Constraints :
//  1) sig_in input must be at least 1 clock cycle width. 
//  2) delay has to be greater and equal to 4, it is due the implicit delay 
//     in the module.
//  3) The minimum time difference between two consecutive falling/rising edge 
//     in the input signal must be greater than "delay" which represent the 
//     amount of time the module has to delay the input. 
//
//    Imagine we don't meet this condition, as for example, we could have two 
//  consecutive falling edge in a time shorter than delay; in this conditions 
//  the output would be high when the second invalid input low transition is 
//  seen by the CPLD which will ignore that transition an keep the output high
//  until another low transition is present in the input after a time greater
//  than or equal to delay.   
//
//////////////////////////////////////////////////////////////////////////////
 module DelayLine 
 #(                                  // =========== Parameters ============
   parameter int unsigned delay = 12 // delay in terms of number of clk cycles
  )                                                
  (
      input  logic clk,              // clock
      input  logic rst_n,            // reset
      
      input  logic sig_in,           // input signal
      output logic sig_out           // delayed version of the input signal
   );
   
//////////////////////////////////////////////////////////////////////////////
// The internal processing will delay the output two clk units; we need to adjust inside the module.
//////////////////////////////////////////////////////////////////////////////

   localparam int unsigned true_delay = delay - 2;  
   
//////////////////////////////////////////////////////////////////////////////
// Local variables
//////////////////////////////////////////////////////////////////////////////
   enum logic [2:0]  { Reset       = 3'b000,
                       Low         = 3'b001,
                       High        = 3'b010,
                       InvalidLow  = 3'b011, 
                       InvalidHigh = 3'b100  } CurrentState, NextState; 
      
   var  logic  sig;      
   var  logic  sig_dly;      
   var  logic  cnt_en; 
   var  logic  cntL_done,  cntH_done;   
   var  logic  CntLow_run, CntHigh_run;  
   
//////////////////////////////////////////////////////////////////////////////
// Main FSM
//////////////////////////////////////////////////////////////////////////////
    
//////////////////////////////////////////////////////////////////////////////
// memory
//////////////////////////////////////////////////////////////////////////////

         always_ff @( posedge clk or negedge rst_n ) begin 
    
                   if (  !rst_n  )    CurrentState  <= Reset;
                   else               CurrentState  <= NextState;
          end      
		  
//////////////////////////////////////////////////////////////////////////////
// Set next state section
//////////////////////////////////////////////////////////////////////////////
      
always_comb 
 begin     
  case( CurrentState )          //- unique case( CurrentState )
     
    Reset       : if      ( !sig_in                 ) NextState = Low;
                  else                                NextState = High;

    Low         : if      (  sig_in && !CntHigh_run ) NextState = High;
                  else if (  sig_in &&  CntHigh_run ) NextState = InvalidHigh;
                  else                                NextState = Low;

    High        : if      ( !sig_in && !CntLow_run  ) NextState = Low;
                  else if ( !sig_in &&  CntLow_run  ) NextState = InvalidLow;
                  else                                NextState = High;

    InvalidLow  : if      (  sig_in && !CntLow_run  ) NextState = High;
                  else                                NextState = InvalidLow;

    InvalidHigh : if      ( !sig_in && !CntHigh_run ) NextState = Low;
                  else                                NextState = InvalidHigh;

                          
  endcase 
 end    
		 
//////////////////////////////////////////////////////////////////////////////
// Output = f( Current State, inputs )
//////////////////////////////////////////////////////////////////////////////
     
assign  sig  =  (CurrentState == Reset)       || 
                (CurrentState == Low)         ||
                (CurrentState == InvalidHigh) ?  1'b0 : 1'b1;                            
        
always_ff @( posedge clk or negedge rst_n )
      begin           
          if (  !rst_n  )       sig_dly  <= 1'b0; 
          else                  sig_dly  <= sig;
                  
      end      
      
assign cnt_en = (CurrentState != Reset) & (sig_in == sig) & (sig == sig_dly);

//////////////////////////////////////////////////////////////////////////////

   assign  sig_out = sig_dly ^ CntLow_run ^ CntHigh_run;


         

//////////////////////////////////////////////////////////////////////////////
// This FSM is used to run a counter each time a low to high transition is 
// detected in the input signal, the master FSM machine enable this FSM after
// the system is stable.
//////////////////////////////////////////////////////////////////////////////

 enum logic [1:0] { cntL_reset = 2'b00,
                    cntL_run   = 2'b01,
                    cntL_En    = 2'b10 } CurrentState_cntL,  NextState_cntL;

//////////////////////////////////////////////////////////////////////////////
// memory
//////////////////////////////////////////////////////////////////////////////
    
  always_ff @( posedge clk or negedge rst_n ) 
     begin 
          if ( !rst_n  )  CurrentState_cntL  <= cntL_En;
          else            CurrentState_cntL  <= NextState_cntL;
     end      
//////////////////////////////////////////////////////////////////////////////
// Set next state section
//////////////////////////////////////////////////////////////////////////////
     
 always_comb 
  begin     
     case( CurrentState_cntL )       //- unique case( CurrentState_cntL )
                      
        cntL_reset  : if  (  !sig && sig_dly )  NextState_cntL = cntL_run;
                      else                      NextState_cntL = cntL_reset;

        cntL_run    : if  (  cntL_done       )  NextState_cntL = cntL_reset;
                      else                      NextState_cntL = cntL_run;

        cntL_En     : if  (  cnt_en          )  NextState_cntL = cntL_reset;
                      else                      NextState_cntL = cntL_En;                                    
     endcase 
  end      
//////////////////////////////////////////////////////////////////////////////
// Output
//////////////////////////////////////////////////////////////////////////////
      
         assign CntLow_run  =  (CurrentState_cntL == cntL_run) ? 1'b1 : 1'b0; 
         
//////////////////////////////////////////////////////////////////////////////
// internal clock
//////////////////////////////////////////////////////////////////////////////
    
  GenCntr #( .maxCount(true_delay - 1)  ) 
   GenCntr0
    (
      .maxCount_out  (  cntL_done  ), // This is high when maxCount is reached   
      .clk_in        (  clk        ),  
      .rst_L_in      (  rst_n      ),		 
              
      .cnt_en_in     (  CntLow_run ),	  
      .rst_sync_L_in ( !cntL_done  ),
      .counter_reg   ( /*empty*/   )
    );  	
//////////////////////////////////////////////////////////////////////////////
     






//////////////////////////////////////////////////////////////////////////////
// This FSM is used to run a counter each time a low to high transition is 
// detected in the input signal, the master FSM machine enable this FSM after 
// the system is stable.
//////////////////////////////////////////////////////////////////////////////

 enum logic [1:0] { cntH_reset = 2'b00, 
                    cntH_run   = 2'b01, 
                    cntH_En    = 2'b10 } CurrentState_cntH,  NextState_cntH;
    
//////////////////////////////////////////////////////////////////////////////
// memory
//////////////////////////////////////////////////////////////////////////////
    
     always_ff @( posedge clk or negedge rst_n ) 
          begin 
               if (  !rst_n  )    CurrentState_cntH  <= cntH_En;
               else               CurrentState_cntH  <= NextState_cntH;
          end      
//////////////////////////////////////////////////////////////////////////////
// Set next state section   
//////////////////////////////////////////////////////////////////////////////
    
 always_comb 
  begin     
    case( CurrentState_cntH )    //- unique case( CurrentState_cntH )
                    
         cntH_reset  : if  (  sig && !sig_dly )  NextState_cntH = cntH_run;
                       else                      NextState_cntH = cntH_reset;

         cntH_run    : if  (  cntH_done       )  NextState_cntH = cntH_reset;
                       else                      NextState_cntH = cntH_run;

         cntH_En     : if  (  cnt_en          )  NextState_cntH = cntH_reset;
                       else                      NextState_cntH = cntH_En;
    endcase 
  end      
//////////////////////////////////////////////////////////////////////////////
// Output
//////////////////////////////////////////////////////////////////////////////
    
  assign CntHigh_run  = ( CurrentState_cntH == cntH_run ) ? 1'b1 : 1'b0; 

//////////////////////////////////////////////////////////////////////////////
// internal clock
//////////////////////////////////////////////////////////////////////////////

  GenCntr #( .maxCount(true_delay - 1)  )  // counter goes from 0 to delay-1
  GenCntr1
   (
       .maxCount_out  ( cntH_done  ), // This is high when maxCount is reached   
       .clk_in        ( clk        ),  
       .rst_L_in      ( rst_n      ),		 
          
       .cnt_en_in     ( CntHigh_run ),	               
       .rst_sync_L_in ( !cntH_done  ),
       .counter_reg   ( /*empty*/   )
    );  	
     

 endmodule // DelayLine 
