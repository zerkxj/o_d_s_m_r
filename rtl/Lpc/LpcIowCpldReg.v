//////////////////////////////////////////////////////////////////////////////
// File name		: LpcIowCpldReg.v
// Module name		: LpcIowCpldReg
// Description		: This module controls 8_bits IOW to CPLD Register via LPC 
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
// Original module name is CPUWrite_bsp.  
//
module LpcIowCpldReg (
	ResetN,
    MainResetN,
	Mclk,
	DevAddr,
	WrDev_En,
	WrDev_Data,    
    ALL_PWRGD,
//=======================
	SystemOK,
	BiosRegister,
	PSUFan_StReg,
	x7SegSel,
	x7SegVal,
    SpecialCmdReg,
    FanLedCtrlReg, 		
	ResetDevReg
   );
/////////////////////////////////////////////////////////////////
input				ResetN;
input               MainResetN;
input				Mclk;
input	[15:0]		DevAddr;
input				WrDev_En;
input	[7:0]		WrDev_Data;
input               ALL_PWRGD;
/////////////////////////////////////////////////////////////////
output              SystemOK;
output  [7:0]       BiosRegister;
output	[7:0]       PSUFan_StReg;
output	[4:0]       x7SegSel;
output	[7:0]       x7SegVal;
output  [7:0]       SpecialCmdReg;
output	[3:0]		FanLedCtrlReg;
output  [5:0]       ResetDevReg;
/////////////////////////////////////////////////////////////////
reg		[7:0]       BiosRegister;
reg		       		SystemOK;
reg		[7:0]       PSUFan_StReg;
reg		[4:0]       x7SegSel;
reg		[7:0]       x7SegVal;
reg     [5:0]       ResetDevReg;
reg		[7:0]		SpecialCmdReg;
reg		[3:0]		FanLedCtrlReg;
/////////////////////////////////////////////////////////////////
	initial
	begin
        BiosRegister	= 8'hAA;
        SystemOK		= 1'b0;
        PSUFan_StReg	= 8'hC0;
        SpecialCmdReg	= 8'h00;
        x7SegSel		= 5'h00;
        x7SegVal		= 8'h00;
        ResetDevReg     = 6'h00;
        FanLedCtrlReg   = 4'h0;
	
	end
/////////////////////////////////////////////////////////////////
	always @(negedge MainResetN or posedge Mclk)
	begin
		if(1'b0 == MainResetN)
		begin
	        FanLedCtrlReg   = 4'h0;
		end
		else
		begin
			if(`TRUE == WrDev_En)
            begin
                if(11'h040 == DevAddr[15:5])
                begin
					case (DevAddr[4:0])
					5'h1B:	FanLedCtrlReg	= WrDev_Data[3:0];
                	endcase
                end
            end
        end
    end
/////////////////////////////////////////////////////////////////	
	always @(negedge ResetN or posedge Mclk)
	begin
		if(1'b0 == ResetN)
		begin
	        BiosRegister	= 8'hAA;
	        SystemOK		= 1'b0;
	        PSUFan_StReg	= 8'hC0;
	        SpecialCmdReg	= 8'h00;
	        x7SegSel		= 5'h00;
	        x7SegVal		= 8'h00;
            ResetDevReg     = 6'h00; 		
		end
		else
		begin
            if(!ALL_PWRGD)
            begin
                SystemOK 			= 1'b0;
                SpecialCmdReg		= 8'h00;
		        BiosRegister		= 8'hAA;
            end
            else if(!MainResetN)
			begin
				SystemOK			= 1'b0;
                SpecialCmdReg		= 8'h00;
            end
			else if(`TRUE == WrDev_En)
            begin                
                if(11'h040 == DevAddr[15:5])
                begin
					case (DevAddr[4:0])
					5'h01:		BiosRegister	= WrDev_Data;
					//5'h04:	refer to BiosControl module
					5'h08:		SystemOK		= WrDev_Data[6];
					//5'h09:	refer to InterruptControl module
					5'h0A:		PSUFan_StReg	= WrDev_Data;
					//5'h0B:	refer to WatchDog module
					5'h0E:		x7SegSel		= WrDev_Data[4:0];
					5'h0F:		x7SegVal		= WrDev_Data;			
					5'h18:		SpecialCmdReg	= WrDev_Data;
					5'h1E:		ResetDevReg		= WrDev_Data[5:0];
                	endcase
                end
            end
        end
    end
/////////////////////////////////////////////////////////////////
endmodule // LpcIowCpldReg 