//////////////////////////////////////////////////////////////////////////////
// File name        : GenCntr.v
// Module name      : GenCntr
// Description      : This module works as a Generic counter 
// Hierarchy Up     : DelayLine , OneShotPulse , Debouncer2 , LinkBlock , ASW
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
//  This module implements a generic counter, user just need to provide the 
// number of clock cycles to count and the vector length of all internal 
// variables will be computed automatically by the module itself with the help
// of the logb2 function. 
//  When the module is out of reset and the counter_en input is asserted, the 
// internal counter starts to increment, for each clock cycle, from zero to 
// maxCount. When this last value is reached, the module assert a done output
// signal to indicate the event, the counter will not restart to zero until 
// its reset input is asserted.
//
//////////////////////////////////////////////////////////////////////////////
module GenCntr
#(
   //================= Parameters ==============
     parameter maxCount = 52     //number of clock cycles to count
)
(  //================= Outputs ================= 
     output wire  maxCount_out,  //It is high when max count has been reached 

   //================= Inputs =================
     input  wire  clk_in,          //Clock signal
     input  wire  cnt_en_in,	   //Counter enable 
     input  wire  rst_L_in,        //reset
     input  wire  rst_sync_L_in,   //synchronous reset
	  
     output reg   [logb2(maxCount) : 0]  counter_reg
);

//////////////////////////////////////////////////////////////////////////////
//Local functions
//////////////////////////////////////////////////////////////////////////////   
 function integer logb2 ( input integer size );
  begin
       for(logb2=-1; size>0; logb2=logb2+1) size = size >> 1;
  end
 endfunction

//////////////////////////////////////////////////////////////////////////////  	  
 	 
  always @ ( posedge clk_in or negedge rst_L_in ) 
   begin 
      if ( !rst_L_in )                  counter_reg   <= 0; 
      else if( !rst_sync_L_in )         counter_reg   <= 0; 
      else 
	   begin						
         if ( counter_reg == maxCount ) counter_reg   <= counter_reg;
         else if(cnt_en_in)             counter_reg   <= counter_reg + 1'b1;
         else                           counter_reg   <= counter_reg;
       end		   
   end      
//////////////////////////////////////////////////////////////////////////////	  
  
     assign maxCount_out = ( counter_reg == maxCount ) ? 1'b1 : 1'b0;
	  

	 
endmodule // GenCntr