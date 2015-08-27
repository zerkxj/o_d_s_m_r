//////////////////////////////////////////////////////////////////////////////
// File name        : Misc.sv
// Module name      : Misc
// Description      : For any logic not related to the power/reset sequence
// Hierarchy Up     : PwrSequence
// Hierarchy Down   : DelayLine ( Twice )  , OneShotPulse
//////////////////////////////////////////////////////////////////////////////

`include "../Verilog/Includes/PwrSeqPackage.sv"
`include "../Verilog/Includes/If_Pin.sv"   

 module Misc
 (
    If_Pin.misc  pin
 );


//////////////////////////////////////////////////////////////////////////////

 
////////////////////////////////////////////////////////////////////////////// 
OneShotPulse #(  .pulseWidth(t_100ms/t_1ms) )        
 OneShotPulse                                  // rename FanCtrl
 ( 
  .clk        ( pin.clk          ), 
  .rst_n      ( pin.rst_n        ), 
  .trigger_n  ( pin.irq_alert_n  ),
  .pulse      ( pin.irq_fan_gate ),
  .extCnt_done( pin.cnt1ms_done )// this signal comes from a free running clock
 );    

////////////////////////////////////////////////////////////////////////////// 
   /* logic thermtrip_n;
    
    delayLine  #(  .delay(t_300us)  )
    ThermTripDelay
    (
         .clk(      pin.clk         ),  // clock
         .rst_n(    pin.rst_n       ),  // reset      
         .sig_in(   pin.thermtrip_n ),  // input signal
         .sig_out(      thermtrip_n )   // delayed version of the input signal
    );
  */  
    // Frank 06052015 add for Intel  MayanCity CPLD Rev2.10 suggests.	
    // ------------====================== 
   logic thermtrip_dly_n;
    
    DelayLine  #(  .delay(t_400us/4)  )
    ThermTripDelay
    (
         .clk(      pin.clk          ), // clock
         .rst_n(    pin.rst_n        ), // reset      
         .sig_in(   pin.thermtrip_n  ), // input signal
         .sig_out(  thermtrip_dly_n  )  // delayed version of the input signal
    );
    //  ------------====================== 	
    assign pin.thermtrip_dly = !pin.thermtrip_n;
//////////////////////////////////////////////////////////////////////////////
  
 
  /*  delayLine  #(  .delay(t_400us)  )
    Err1Delay
    (
         .clk(      pin.clk         ),  // clock
         .rst_n(    pin.rst_n       ),  // reset      
         .sig_in(   pin.err1_n      ),  // input signal
         .sig_out(  pin.err1_dly_n  )   // delayed version of the input signal
    );
*/
assign pin.err1_dly_n = pin.err1_n;

////////////////////////////////////////////////////////////////////////////// 
   var logic pltrst_dly_n;
    
    DelayLine  #(  .delay(t_2ms)  )
    PLTrstDelay
    (
         .clk(      pin.clk          ),  // clock
         .rst_n(    pin.rst_n        ),  // reset      
         .sig_in(   pin.pch_pltrst_n ),  // input signal
         .sig_out(  pltrst_dly_n     )   // delayed version of the input signal
    );

	// Frank 06052015 modify , Intel MayanCity CPLD Rev2.10 suggests.	
    //- assign  pin.throttle_sys = !pltrst_dly_n;
    assign  pin.throttle_sys = !(pltrst_dly_n & pin.pch_pltrst_n);
         
 endmodule  // Misc


