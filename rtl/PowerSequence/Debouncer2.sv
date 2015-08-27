//////////////////////////////////////////////////////////////////////////////
// File name        : Debouncer2.sv
// Module name      : Debouncer2
// Description      : This module works as a debouncer 
// Hierarchy Up     : LinkBlock
// Hierarchy Down   : GenCntr
//////////////////////////////////////////////////////////////////////////////
//   This module implements a debouncer, user just needs to provide the number
// of clock cycles to generate a new clock that feeds a synchronizer. The number    
// of cycles is the period of a new clock that feeds the synchronizer.
//   The synchronizer acts as a debouncer taking a sample every certain time  
// avoiding signal variations under that time. 
//
//////////////////////////////////////////////////////////////////////////////
module Debouncer2
#(
   //================= Parameters ==============
     parameter maxCount = 660    // number of clock cycles to count
                                 // 660 -> 20 ms with 33Khz clock
 )
(input clk,input deb_en,input rst_n,input in_put, output out_put);
//////////////////////////////////////////////////////////////////////////////
reg 	synchronized ;
reg 	a ;
wire 	pulse ;
//////////////////////////////////////////////////////////////////////////////
// Synchronizer
//////////////////////////////////////////////////////////////////////////////
always@ ( posedge clk, negedge rst_n ) 
 begin
   if ( !rst_n ) 
      begin
      synchronized <= 1'b0;
      a <= 1'b0;
      end 
   else if ( pulse ) 
      begin
      a <= in_put;   
      synchronized <= a ;     
      end
 end

assign out_put = synchronized ;

//////////////////////////////////////////////////////////////////////////////
// Clock pulse for the synchronizer
//////////////////////////////////////////////////////////////////////////////
 
    GenCntr #(  .maxCount(maxCount)  ) 
    GenCntr     
    (
        .maxCount_out   (  pulse	),     // It is high when cnt == maxCount.   
        .counter_reg    (),                // Add  for  simulation 
        .clk_in         (  clk   	),  
        .rst_L_in       (  rst_n    ),		               
        .cnt_en_in      (  deb_en   ),	  
        .rst_sync_L_in  (  !pulse 	)
    ); 
        

endmodule  // Debouncer2