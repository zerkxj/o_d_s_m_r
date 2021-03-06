//////////////////////////////////////////////////////////////////////////////
// File name        : ResetControl.v
// Module name      : ResetControl
// Description      : This module decodes reset register bit to related reset signal control                 
// Hierarchy Up     : MR_Bsp
// Hierarchy Down   : --- 
////////////////////////////////////////////////////////////////////////////// 
//  Reset Register Bit :
//      Bit5 :  for Reset10G ( = !ResetRegister[5] & MainReset ) signal control , not used in G503
//      Bit4 :  for Reset1G  signal control 
//      Bit3 :  for ResetDB  ( = !ResetRegister[3] & PciReset )  signal control , not used in G503 
///////////////////////////////////////////////////////////////////
module ResetControl(
	MainReset,				// Power or Controller ICH10R Reset
	PciReset,				// PCI Reset
	ResetRegister,			// Peripheral Reset:  Phy1G,
///////////////////////////////////////////////////////////////////
	Reset1G 				// Reset Phy 1G
	);
///////////////////////////////////////////////////////////////////
input			MainReset, PciReset;
input	[5:0]	ResetRegister;
output			Reset1G; 
///////////////////////////////////////////////////////////////////

assign			Reset1G			= !ResetRegister[4] & MainReset;
///////////////////////////////////////////////////////////////////
endmodule
///////////////////////////////////////////////////////////////////
