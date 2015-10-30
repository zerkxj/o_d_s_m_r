//////////////////////////////////////////////////////////////////////////////
// File name        : PwrSeqPackage.sv
// Module name      : ---
// Description      : This SV package contains parameters and functions for 
//                    Power Sequence 
// Hierarchy Up     : --- 
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
`ifndef PKG_H // if the already-compiled flag is not set...
`define PKG_H // set the flag

//////////////////////////////////////////////////////////////////////////////
  package PwrSeqPackage;   
//////////////////////////////////////////////////////////////////////////////
// These constants takes into account a 33Khz reference clock
//////////////////////////////////////////////////////////////////////////////
      parameter  bit [31:0] t_200ms  =  32'd6667;
      parameter  bit [31:0] t_100ms  =  32'd3334;
      parameter  bit [31:0] t_20ms   =  32'd660;	  
      parameter  bit [31:0] t_10ms   =  32'd334;
      parameter  bit [31:0] t_4ms    =  32'd134;
      parameter  bit [31:0] t_3ms    =  32'd100;
      parameter  bit [31:0] t_2ms    =  32'd67;      
      parameter  bit [31:0] t_1p8ms  =  32'd60;            
      parameter  bit [31:0] t_1ms    =  32'd34;            

      parameter  bit [31:0] t_400us  =  32'd14;      
      parameter  bit [31:0] t_300us  =  32'd10;
      parameter  bit [31:0] t_90us   =  32'd3;
      parameter  bit [31:0] t_60us   =  32'd2;      
      parameter  bit [31:0] t_30us   =  32'd1;      

      localparam bit [31:0] t15    =  t_1p8ms;                      
      localparam bit [31:0] t18    =  t_100ms;                  
      localparam bit [31:0] t19    =  t_90us;                  
      localparam bit [31:0] t33    =  t_10ms;                  
      localparam bit [31:0] t34    =  t_1ms;                 
      localparam bit [31:0] t514   =  t_1ms;           
      localparam bit [31:0] t570   =  t_1ms;           
      localparam bit [31:0] t573   =  t_100ms;                 
      localparam bit [31:0] t1001  =  t_60us;                 
//////////////////////////////////////////////////////////////////////////////  
      parameter   ZERO      = 0;      
      parameter   ONE       = 1;            
      parameter   TWO       = 2;            
      parameter   THREE     = 3;            
      parameter   FOUR      = 4;            
      parameter   FIVE      = 5;            
      parameter   SIX       = 6;            
      parameter   SEVEN     = 7;            
      parameter   EIGTH     = 8;            
      parameter   NINE      = 9;            
      parameter   TEN       = 10;            
      parameter   ELEVEN    = 11;            
      parameter   TWELVE    = 12;            
      parameter   THIRTEEN  = 13;            

      parameter   [0:0] HIGH  = 1'b1;      
      parameter   [0:0] LOW   = 1'b0;      
      parameter   [0:0] HighZ = 1'bZ;      

//////////////////////////////////////////////////////////////////////////////
//   
// Returns the floor of the base 2 log of the "size" number, we use the return 
// value as the MSB bit in vector size definitions. e.g.; we need 4 bits for the
// number 13, we need a vector with an index from 3 to 0. 
//
// flogb2(from 8 to 15) = 3 
// flogb2(from 7 to 4 ) = 2
// flogb2(from 3 to 2 ) = 1   
//  
//////////////////////////////////////////////////////////////////////////////   
     function automatic int logb2 ( input int unsigned size );

         for( logb2 = -1; size > 0; logb2 = logb2 + 1 )  size = size >> 1;
             
     endfunction
//////////////////////////////////////////////////////////////////////////////

     function automatic [31:0] maskState( input int unsigned idx_high, input int unsigned idx_low );

         maskState = '0;
         
         for( int index = idx_low; index <= idx_high; index ++)  maskState[index] = 1'b1;
             
     endfunction
//////////////////////////////////////////////////////////////////////////////
  endpackage
//////////////////////////////////////////////////////////////////////////////
  import PwrSeqPackage::*; // import package into $unit
  
`endif

