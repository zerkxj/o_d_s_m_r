///////////////////////////////////////////////////////////////////
// File name      : GLANLED_2Port.v
// Module name    : GLANLED_2Port
// Company        : CASwell						
// Project name   : ODS-MR
// Card name      : Ethernet Daughter Board
// Designer       : Frank Hsu
// Creation Date  : May 8,2015
// Status         : Under design
// Last modified  : May 8,2015
//                : 
// Description    : This module controls the Giga Port Speed Leds Colour
// Hierarchy Up	  : 
// Hierarchy Down : 
// Card Release	  : 
///////////////////////////////////////////////////////////////////

module GLANLED_2Port(
	ALL_PWRGD,   // ALL POWER GOOD 
	PActivity,	 // ACT#      signal from LAN controller
	Speed1P,	 // LINK1000# signal from LAN controller
	Speed2P,  	 // LINK100#  signal from LAN controller
	Speed1R,  	 // LINK1000# output to BiColor LED
	Speed2R,  	 // LINK100#  output to BiColor LED
	RActivity    // ACT#      output to LED
);
input		  ALL_PWRGD;
input 	[1:0] PActivity;
input 	[1:0] Speed1P;
input 	[1:0] Speed2P;
output 	[1:0] Speed1R;
output 	[1:0] Speed2R;
output 	[1:0] RActivity;

//LinkSpeedLEDs describe the link type of the GigaPhy
//The table below gives the Link modes according to the SpeedLED status

//		|Speed1P:Speed2P| LinkMode    	 |Required LED Color|Speed1R:Speed2R|
//		|---------------|----------------|------------------|---------------|
//		|		00      | 1000BaseT Link |     Green        |		10      |
//		|		01      | 100BaseT Link  |     Orange       |		01      |
//		|		10      | 10BaseT Link   |     Orange       |		01      |
//		|		11      | NO Link        |     OFF          |		00      |
//		|---------------|----------------|------------------|---------------|

 //- assign Speed1R	  = ALL_PWRGD ? ~(Speed1P | Speed2P) : 2'b11;
 //- assign Speed2R	  = ALL_PWRGD ?  (Speed1P ^ Speed2P) : 2'b11;  

//  Revised True table  
//		|Speed1P:Speed2P| LinkMode    	 |Required LED Color|Speed1R:Speed2R|
//		|---------------|----------------|------------------|---------------|
//		|		00      | Not exist      |                  |		00      |
//		|		01      | 1000BaseT Link |     Green        |		10      |
//		|		10      | 100BaseT Link  |     Orange       |		01      |
//		|		11      | No LINK/10BaseT|     OFF          |		11      |
//		|---------------|----------------|------------------|---------------|        

  assign Speed1R[0]	  = ALL_PWRGD ?  Speed2P[0] : 1'b1;
  assign Speed2R[0]	  = ALL_PWRGD ?  Speed1P[0] : 1'b1;
  
  assign Speed1R[1]	  = ALL_PWRGD ?  Speed2P[1] : 1'b1;   
  assign Speed2R[1]	  = ALL_PWRGD ?  Speed1P[1] : 1'b1;
 
 //- assign Speed1R	  =  Speed1P ; for debugging only
 //- assign Speed2R	  =  Speed2P ; for debugging only 
 
 //assign RActivity = ALL_PWRGD ? ~PActivity : 8'hFF;
 assign RActivity[0] = !ALL_PWRGD ? 1'b1 : (2'b11 == {Speed1P[0], Speed2P[0]}) ? 1'b1 : ~PActivity[0];
 assign RActivity[1] = !ALL_PWRGD ? 1'b1 : (2'b11 == {Speed1P[1], Speed2P[1]}) ? 1'b1 : ~PActivity[1];
 
endmodule