//////////////////////////////////////////////////////////////////////////////
// File name        : OneShotPulse.sv
// Module name      : OneShotPulse
// Description      : This module generates one shot pulse 
// Hierarchy Up     : Misc
// Hierarchy Down   : GenCntr
//////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
//  This module generates a high pulse for each falling edge transition in the
// trigger input. The pulse width is defined by the number of clock cycles 
// specified in the parameter. In the case of a second falling edge transition 
// takes place in the input when the module is driving a pulse, it will be 
// ignored.    
//////////////////////////////////////////////////////////////////////////////   
//  Notes :     
//  This module has an internal clock cycles counter to define the width of 
// the pulse; we can specify any number for it, however, we can also make use 
// of an external clock counter done signal to enable our internal clock 
// counter. This let us to reduce the length of the internal counter and use 
// the external one as a reference not just for this module but also for any 
// other outside. 
//////////////////////////////////////////////////////////////////////////////

 module OneShotPulse
 #(                             // ============= Parameters =============
    parameter int unsigned pulseWidth = 12 
                      	// pulse width in terms of a number of clock cycles
 )
 (
    input  logic  clk,         // cpld clock
    input  logic  rst_n,       // cpld reset
      
    input  logic  trigger_n,   // one shot pulse trigger 
    output logic  pulse,       // pulse in response to trigger
 
    input  logic  extCnt_done  // this signal comes from a free running clock
                               // which assert its done output each 1msec
 );
 
//////////////////////////////////////////////////////////////////////////////

   enum logic { s0 = 1'b0, s1 = 1'b1 } CurrentState, NextState; 
      
   var  logic   cnt_enable;
   var  logic   cnt_done;   
//////////////////////////////////////////////////////////////////////////////
// FSM memory
//////////////////////////////////////////////////////////////////////////////
   always_ff @( posedge clk or negedge rst_n ) begin 
    
             if (  !rst_n  )   CurrentState  <= s0;
             else              CurrentState  <= NextState;
   end      

//////////////////////////////////////////////////////////////////////////////
// Set next state section
//////////////////////////////////////////////////////////////////////////////
   always_comb 
   begin     
             case( CurrentState )        //- unique case( CurrentState ) 
                      
                   s0 :   if( !trigger_n )              NextState = s1;
                          else                          NextState = s0;
                          
                   s1 :   if( trigger_n && cnt_done )   NextState = s0;
                          else                          NextState = s1;
             endcase 
   end      

//////////////////////////////////////////////////////////////////////////////
// Output = f( Current State, inputs )
//////////////////////////////////////////////////////////////////////////////
 always_ff @( posedge clk or negedge rst_n ) 
  begin    
    if (  !rst_n  )     
                                                                pulse = 1'b0;       
    else 
	 begin           
       if     ( CurrentState == s0 )                            pulse = 1'b0;
       else if( CurrentState == s1 && !cnt_done )               pulse = 1'b1;
       else if( CurrentState == s1 &&  cnt_done && !trigger_n ) pulse = 1'b0;
       else                                                     pulse = pulse;
     end       
  end      

   
   assign cnt_enable = ( CurrentState == s1 ) ? 1'b1 : 1'b0;  
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// internal clock cycle counter
//////////////////////////////////////////////////////////////////////////////
 GenCntr #( .maxCount ( pulseWidth )  ) 
  GenCntr     
   (
     .maxCount_out  ( cnt_done ),   // This is high when maxCount is reached   
     .clk_in        ( clk      ),  
     .rst_L_in      ( rst_n    ),		 
              
     .cnt_en_in     ( cnt_enable && extCnt_done ),	  
     .rst_sync_L_in ( cnt_enable ),
       
     .counter_reg()
   );  	
//////////////////////////////////////////////////////////////////////////////


 endmodule // OneShotPulse


