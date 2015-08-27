//////////////////////////////////////////////////////////////////////////////
// File name      	: CpldRegMap.v
// Module name    	: CpldRegMap
// Description      : This module defines a generic register map for R/W               
// Hierarchy Up     : LpcDecode
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////  
//
/////////////////////////////////////////////////////////////////////////////
//  For Stage 2 test  , Only  focus  on LPC I/O R/W test.
//  CPLD Register with 0x00 address is R/O byte that contain {`FPGAID_CODE , `VERSION_CODE} data. 
//  CPLD Registers ranged from 0x01 to 0x1F will be R/W registers with initial values defined in CpldRegMap.v
//  Define RdWrCpldReg to launch stage 2 test that only has PwrSequence,LpcDecode, CpldRegMap and ClockSource modules are instantiated at top module.
/////////////////////////////////////////////////////////////////////////////
//  
///////////////////////////////////////////////////////////////////
//	Register Map in Lattice CPLD accessed via LPC I/O R/W        //
///////////////////////////////////////////////////////////////////
// Addr Offset   	  Register Name						  Access
///////////////////////////////////////////////////////////////////
//   0x00          CPLD hardware version			        RO
//   0x01~0x1F     Generic Registers    					R/W
//
// Notes : offset 0x01 and ox04 registers will be overwritten by BIOS during POST. 
//         Offset ox01 is for BIOS Watchdog Control
//         Offset 0x04 is BIOS status register.
//         These two registers will be accessed by BIOS during POST. 
///////////////////////////////////////////////////////////////////
module	CpldRegMap(	               
    MainResetN,            // PCH RST_PLTRST_N 
	Mclk,                  // LPC 33MHz clock input   
	DevAddr,               // IO Address [15:0]
	RdDev_En,              // Decode LPC I/O Read  command with specific I/O BAR[15:8]
	WrDev_En,              // Decode LPC I/O Write command with specific I/O BAR[15:8]
	WrDev_Data,            // I/O Write Data byte of the decoded I/O BAR[15:8] ports
//===========================
    RdDev_Data             // CPLD's Internal register data ( byte ) that will be output via Lpc Ior command
);
///////////////////////////////////////////////////////////////////
input               MainResetN;            // PCH RST_PLTRST_N 
input               Mclk;                  // LPC 33MHz clock input   
input 	[15:0]      DevAddr;               // IO Address [15:0]
input 	            RdDev_En;              // Decode LPC I/O Read  command with specific I/O BAR[15:8]
input 	            WrDev_En;              // Decode LPC I/O Write command with specific I/O BAR[15:8]
input 	[7:0]       WrDev_Data;            // I/O Write Data byte of the decoded I/O BAR[15:8] ports
output  [7:0]       RdDev_Data ;           // CPLD's Internal register data ( byte ) that will be output via Lpc Ior command
///////////////////////////////////////////////////////////////////
reg     [7:0]       LoopRd, LoopWr;        // Byte count index for for_loop Ior/Iow assignment 
reg	    [7:0]		RegisterData[31:0];    // CPLD internal registers
reg		[7:0]		RdDev_Data; 
///////////////////////////////////////////////////////////////////
//  Ior CPLD register data byte via Lpc
///////////////////////////////////////////////////////////////////                		
always@(posedge Mclk or negedge MainResetN ) 
begin
  if (!MainResetN) 
     RdDev_Data <= 8'hFF ;
   else  
   begin 
    if ( ( RdDev_En == `TRUE ) && ( DevAddr[7:0] > 8'h1F ) ) 
          RdDev_Data <= 8'hFF ;  
	else 
    for(LoopRd = 0; LoopRd <= 31; LoopRd = LoopRd + 1)
     if ( ( `TRUE == RdDev_En ) && ( DevAddr[7:5] == 3'b000 ) && ( LoopRd[4:0] == DevAddr[4:0] ) )
          RdDev_Data <= RegisterData[LoopRd] ;   
   end	 
end
///////////////////////////////////////////////////////////////////
//  Iow Data to CPLD Register via Lpc
///////////////////////////////////////////////////////////////////
always	@(posedge Mclk or negedge MainResetN)
begin 
 if(!MainResetN)
   for(LoopWr = 0; LoopWr <= 31; LoopWr = LoopWr + 1)
        RegisterData[LoopWr] <= ResetValue(LoopWr);	      // Initialize registers during Reset Assertion period
 else  
  for(LoopWr = 1; LoopWr <= 31; LoopWr = LoopWr + 1)
   if ( ( WrDev_En == `TRUE ) && ( DevAddr[7:5] == 3'b000 ) && ( LoopWr[4:0] == DevAddr[4:0] ) ) 
        RegisterData[LoopWr] <= WrDev_Data ;	  
end
///////////////////////////////////////////////////////////////////
/// Initialize CPLD registers with data in ResetValue function 
/// during PCIe Reset assertion period
///////////////////////////////////////////////////////////////////
function	[7:0]	ResetValue(input [4:0] N);   
  begin
    case	(N)
	5'h00   :   ResetValue = {`FPGAID_CODE , `VERSION_CODE} ; // R/O byte , defined in DefineODSTextMacro.v
    5'h01	:	ResetValue = 8'h55;                           // R/W ( for Offset 0x01 ~ 0x1F )
    5'h02	:	ResetValue = 8'hAA;
    5'h03	:	ResetValue = 8'h66;
    5'h04	:	ResetValue = 8'h99;
	5'h05	:	ResetValue = 8'h77; 
    5'h06	:	ResetValue = 8'h88;
    5'h07	:	ResetValue = 8'h44;
    5'h08	:	ResetValue = 8'hBB;
	5'h09	:	ResetValue = 8'h33; 
    5'h0A	:	ResetValue = 8'hCC;
    5'h0B	:	ResetValue = 8'h22;
    5'h0C	:	ResetValue = 8'hDD;
	5'h0D	:	ResetValue = 8'h11; 
    5'h0E	:	ResetValue = 8'hEE;
    5'h0F	:	ResetValue = 8'h00;
    5'h10	:	ResetValue = 8'hFF;
	5'h11	:	ResetValue = 8'h55; 
    5'h12	:	ResetValue = 8'hAA;
    5'h13	:	ResetValue = 8'h66;
    5'h14	:	ResetValue = 8'h99;
	5'h15	:	ResetValue = 8'h77; 
    5'h16	:	ResetValue = 8'h88;
    5'h17	:	ResetValue = 8'h44;
    5'h18	:	ResetValue = 8'hBB;
	5'h19	:	ResetValue = 8'h33; 
    5'h1A	:	ResetValue = 8'hCC;
    5'h1B	:	ResetValue = 8'h22;
    5'h1C	:	ResetValue = 8'hDD;
	5'h1D	:	ResetValue = 8'h11; 
    5'h1E	:	ResetValue = 8'hEE;
    5'h1F	:	ResetValue = 8'h5A;    
    default	:	ResetValue = 8'h00;
    endcase
  end
/////////////////////////////////////////////////////////////////// 
endfunction
///////////////////////////////////////////////////////////////////
endmodule // CpldRegMap