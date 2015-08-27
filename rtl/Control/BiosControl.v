//////////////////////////////////////////////////////////////////////////////
// File name        : BiosControl.v
// Module name      : BiosControl
// Description      : This module determines BIOS Chip Select for dual BIOS 
//                    sockets , indicates BIOS status and control SwapDisable       
// Hierarchy Up     : MR_Bsp
// Hierarchy Down   : OpenDrain
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
`include		"../Verilog/Control/OpenDrain.v"
///////////////////////////////////////////////////////////////////
module BiosControl(
    ResetN,
// When Merge SetBiosCS , remove SetBios0	
//-	SetBios0,				// Force to BIOS 0 after regular Power Off (Not BIOS WD)
	MainReset,				// Power or Controller ICH10R Reset , 
	LpcClock,				// 33 MHz Lpc (Altera Clock)
    RstBiosFlg,
	Write,					// Write Access to CPLD registor
	BiosCS,					// ICH10 BIOS Chip Select (SPI Interface)
	BIOS_SEL,          		// BIOS SELECT  - Bios Select Jumper (default "1")	
	ForceSwap,				// BiosWD Occurred, Force BIOS Swap while power restart
	RegAddress,				// Address of the accessed Register
	Data,					// Data to be written to CPLD Register
// Add merged SetBiosCS
    ALL_PWRGD, 
    SlowClock,
	Strobe125ms,	
// ====================		
	BIOS,					// Chip Select to SPI Flash Memories
	BiosLed,				// LED to point current BIOS	
    SwapDisable,			// Disable BIOS Swapping after Power Up
	BiosStatus				// Bios Status: Current, Next, Active
	);
///////////////////////////////////////////////////////////////////
input           ResetN;
input			MainReset, LpcClock, Write, BiosCS, BIOS_SEL; 
                //- ;, SwapDisable; SwapDisable redefined as an output pin when merging SetBiosCS
				//- SetBios0, when merging SetBiosCS  , remove SetBios0
input           RstBiosFlg;
input	[1:0]	ForceSwap;
input	[4:0]	RegAddress;
input	[7:0]	Data; 
input			ALL_PWRGD, SlowClock, Strobe125ms; 
output	[1:0]	BIOS, BiosLed;
output          SwapDisable ;    
output	[3:0]	BiosStatus;
 
///////////////////////////////////////////////////////////////////
reg				Current, Next, Active, Start, SetNext;
reg		[1:0]	Edge; 
reg		[6:0]	PowerSample; 
wire            SwapDisable;
wire			WriteReg = Write & (RegAddress == 5'h4);
///////////////////////////////////////////////////////////////////
assign			BiosStatus	= {Start, Current, Next, Active};
assign			BIOS[0]		= Active ? 1'b1	  : BiosCS;
assign			BIOS[1]		= Active ? BiosCS : 1'b1;  
///////////////////////////////////////////////////////////////////
	initial
	begin
        Current	= 1'b0;
        Next	= 1'b1;
        Active	= 1'b0;
        Start	= 1'b0;
        SetNext	= 1'b0;
		PowerSample	= 1'b0;
	end

always	@(posedge LpcClock or negedge ResetN)
  if(!ResetN)
    begin
      {Current, Next, Active}	<= 3'b010;
      Edge						<= 2'h3;
      Start						<= 0;
      SetNext					<= 0;
    end
  else
    if(RstBiosFlg)
    begin
      {Current, Next, Active}	<= 3'b010;
      Edge						<= 2'h3;
      Start						<= 0;
      SetNext					<= 0;
    end
    else
    begin
      Edge						<= {Edge[0], MainReset | SwapDisable};	   
      Start						<= (Edge == 2'h1) & !SwapDisable | |ForceSwap;  	   
      SetNext					<= Start;
///////////////////////////////////////////////////////////////////
      Current					<= !BIOS_SEL | Start ? Next : Current;
      Next						<= SetNext ? !Current : WriteReg ? Data[1] : Next;
      Active					<= SetNext ?  Current : WriteReg ? Data[0] : Active;
    end
///////////////////////////////////////////////////////////////////
OpenDrain #(.Width(2)) BiosShow  ({Current, !Current}, BiosLed);
///////////////////////////////////////////////////////////////////
// **************************************************************** 
////////////////////////// Merge SetBiosCS ////////////////////////
// ****************************************************************
always @ (posedge SlowClock or negedge ALL_PWRGD )
  if(!ALL_PWRGD)		    
    begin  
      PowerSample			<= 0;
    end
  else if(Strobe125ms)
    begin
      PowerSample			<= {PowerSample[5:0], ALL_PWRGD};
    end

assign	SwapDisable =  !PowerSample[6]; 

endmodule
///////////////////////////////////////////////////////////////////
