//////////////////////////////////////////////////////////////////////////////
// File name		: LpcIorCpldReg.v
// Module name		: LpcIorCpldReg
// Description		: This module controls 8_bits IOR to CPLD Register via LPC 
// Company          : CASwell
// Project Name     : COB-G503 ( ODS-MR )
// Designer         : Frank Hsu
// Build Date       : June 29, 2015
// Last Modified    : June 29, 2015 
// Version          : 0.1  
// Hierarchy Up		: MR_Bsp
// Hierarchy Down	: ---
/////////////////////////////////////////////////////////////////////////////
// This module is retrieved from ods_bsp_G503.v ( renamed to MR_Bsp.v ) . 
// Original module name is CPURead_bsp. 
module LpcIorCpldReg (
	ResetN,
	Mclk,
	DevAddr,
	RdDev_En,
	InterruptRegister,		// Interrupt Control / Status Register
	WatchDogRegister,		// Watch Dog Control / Status Register
	BiosRegister,
	BiosStatus,
	SystemOK,
    //FanClk,
	DualPSCfgFlash,
    DualPSJump3,
	ZippyStatus,	
	BIOS_SEL,
    PSU1_Tach_Low,          // high or low then minimum freq
    PSU1_Tach_High,         // high or low then maximum freq
	PSUFan_StReg,
    FanTrayPresent,
	x7SegSel,
	x7SegVal,
    SpecialCmdReg,
    bFlashBusyN,
    FanLedCtrlReg,
    ResetDevReg,	
//=======================
	RdDev_Data
   );
/////////////////////////////////////////////////////////////////
input				ResetN;
input				Mclk;
input	[15:0]		DevAddr;
input				RdDev_En;
input	[6:0]		WatchDogRegister;
input	[5:0]		InterruptRegister;
input	[7:0]       BiosRegister;
input	[3:0]       BiosStatus;
input	            SystemOK;
//input   [11:0]  	FanClk;
input				DualPSCfgFlash;
input               DualPSJump3;
input	[1:0]		ZippyStatus;
input				BIOS_SEL;
input               PSU1_Tach_Low;
input               PSU1_Tach_High;
input	[7:0]       PSUFan_StReg;
input               FanTrayPresent;
input	[4:0]       x7SegSel;
input	[7:0]       x7SegVal;
input   [7:0]       SpecialCmdReg;
input               bFlashBusyN;
input	[3:0]		FanLedCtrlReg;
input   [5:0]       ResetDevReg;
/////////////////////////////////////////////////////////////////
output	[7:0]		RdDev_Data;
/////////////////////////////////////////////////////////////////
reg		[7:0]		RdDev_Data;
/////////////////////////////////////////////////////////////////
	initial
	begin
        RdDev_Data <= 8'hFF;
	end
/////////////////////////////////////////////////////////////////
	always @(negedge ResetN or posedge Mclk)
	begin
		if(1'b0 == ResetN)
		begin
	        RdDev_Data <= 8'hFF;
		end
		else
		begin
			if(`TRUE == RdDev_En)
            begin 
			   // Frank 06292015 modify , fully address decoding 
               //- if(!DevAddr[7])
			  if ( DevAddr[7:5] == 3'b000 ) 
               begin
				case (DevAddr[4:0])
				5'h00:	RdDev_Data <= {`FPGAID_CODE, `VERSION_CODE};
				5'h01:  RdDev_Data <= BiosRegister;
				5'h04:  RdDev_Data <= {4'h0, BiosStatus};
				5'h08:  RdDev_Data <= {DualPSCfgFlash, SystemOK, ZippyStatus, 2'b00, DualPSJump3, BIOS_SEL};
				5'h09:  RdDev_Data <= {1'b0, WatchDogRegister[5], InterruptRegister};
				5'h0A:  RdDev_Data <= {PSUFan_StReg[7:4], PSU1_Tach_Low, PSU1_Tach_High, 1'b0, PSUFan_StReg[0]};
				5'h0B:  RdDev_Data <= {InterruptRegister[2], WatchDogRegister};
				5'h0C:  RdDev_Data <= {7'h0, !FanTrayPresent};
				5'h0E:  RdDev_Data <= {3'h0, x7SegSel};
				5'h0F:  RdDev_Data <= x7SegVal;					
				5'h18:  RdDev_Data <= SpecialCmdReg;
				5'h19:	RdDev_Data <= {7'h00, bFlashBusyN};
				5'h1B:	RdDev_Data <= {4'h0, FanLedCtrlReg};
				5'h1E:	RdDev_Data <= {2'h0, ResetDevReg};
                default:	RdDev_Data <= 8'hFF;
                endcase
               end
            end
        end
    end
endmodule // LpcIorCpldReg