//////////////////////////////////////////////////////////////////////////////
// File name        : Counter.sv
// Module name      : Counter
// Description      : This module works as a binary counter
// Hierarchy Up     : MstrSeq
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
//   This module describes a binary counter that counts, when its enable input 
// is high, from zero to a max value in steps of one unit per each rise edge of
// the clk signal. The max value is specified in the "_if.setCount" input; 
// once the max value is reached by the counter a "done" flag is set to
// acknowledge this condition.    
//   The module has a synchronous reset input that clears the counter, but not 
// the max value which is set to all 1s from reset. The module also has a load
// signal to update the max value from the setCount input. The module will 
// ignore the load signal if enable is high.     
//   Note the module parameter will define the length of the internal register, 
// in such a way that it imposes a restriction on _if.setCount which can not be
// higher than the maxCount parameter.
//////////////////////////////////////////////////////////////////////////////

 module Counter
 #(                                                     // ================= Parameters ==============
       parameter maxCount = 52                          // maximum number of clock cycles to count;
 )                                                      // setCount should be smaller than this one.   
 (
                                                        // ================= Inputs =================
       input  logic  clk,                               // clock signal
       input  logic  rst_n,                             // reset

       input  logic  rst_sync_n,                        // synchronous reset
       input  logic  enable,                            // counter enable 
       input  logic  load,                              // load maxCount internal register	  
       input  logic  [logb2(maxCount) : 0] setCount,    //	      	 

                                                        // ================= Outputs =================   
       output logic  done,                              // It is high when max count has been reached       
       output logic  [logb2(maxCount) : 0] mem          // Current value of the counter
                                                        // unsigned maxCount-bits variable
 );
 
//////////////////////////////////////////////////////////////////////////////
// Returns the floor of the base 2 log of the "size" number, we use the return 
// value as the MSB bit in vector size definitions. e.g.; we need 4 bits for the
// number 13, we need a vector with an index from 3 to 0. 
//
// flogb2(from 8 to 15) = 3 
// flogb2(from 7 to 4 ) = 2
// flogb2(from 3 to 2 ) = 1   
//////////////////////////////////////////////////////////////////////////////
 
     function automatic int logb2 ( input int unsigned size );

         for( logb2 = -1; size > 0; logb2 = logb2 + 1 )  size = size >> 1;
             
     endfunction
   
//////////////////////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////////////////////   
// We often need latches simply to store bits of information; 
// save the value the counter need to reach to assert and output flag. 
//////////////////////////////////////////////////////////////////////////////
  
     var logic [logb2(maxCount) : 0] maxCount_mem;
    
//   always_latch begin : max_value
     always_ff @( posedge clk or negedge rst_n ) begin 
    
             if (     !rst_n          )   maxCount_mem   <= '1;            // fills all bits of maxCount_mem with 1 
             else if( load && !enable )   maxCount_mem   <= setCount; 
             else                         maxCount_mem   <=  maxCount_mem; 
     end      
	  
//////////////////////////////////////////////////////////////////////////////
// Increments the counter count in each clock cycle if the enable signal is asserted  	  
//////////////////////////////////////////////////////////////////////////////
	 
     always_ff @( posedge clk or negedge rst_n ) begin 
 
            if (       !rst_n      )              mem   <= '0; 
            else if(   !rst_sync_n )              mem   <= '0; 
            else begin
						
                  if (     mem == maxCount_mem )  mem   <= mem;
                  else if( enable              )  mem   <= mem + 1'b1;
                  else                            mem   <= mem;
            end		   
      end      

//////////////////////////////////////////////////////////////////////////////
// Assert done signal once the max count value is reached
//////////////////////////////////////////////////////////////////////////////	 
     assign done  =  (mem == maxCount_mem)  ?  1'b1 : 1'b0;
	  
////////////////////////////////////////////////////////////////////////////// 

 endmodule // Counter


