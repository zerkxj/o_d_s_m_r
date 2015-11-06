///////////////////////////////////////////////////////////////////
// File name      : DualPower.v
// Module name    : DualPower
// Company        : Radware
// Project name   : ODS-LS
// Card name      : Yarkon
// Designer       : Fedor Haikin
// Creation Date  : 08.02.2011
// Status         : Under design
// Last modified  : 08.02.2011
// Version        : 1.0
// Description    : This module
// Hierarchy Up	  : ODSLS
// Hierarchy Down : 
// Card Release	  : 1.0
///////////////////////////////////////////////////////////////////

`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"

`define PSU1FAN_MiniFreq        12'h014     // 85Hz   <2000RPM
`define PSU1FAN_MaxiFreq        12'h0E0     // 220Hz  >6400RPM
`define PSULedOff               2'b11
`define PSULedRed               2'b10
`define PSULedGreen             2'b01
`define DualPS_Cfg              1'b1
`define PSUStatusOK             1'b1
`define PSUFAN_Good             1'b1
`define SW_Control              1'b1
`define SW_Led_Off              1'b1
`define PSUTach_Good            2'b00

module DualPower(
    ResetNi,
    SlowClock,              // 32768 Hz Clock
    PSU_FANIN,              // PSU FAN pulse
    PSUFan_StReg,           // Software write info
    PSU1_Tach_Low,          // high or low then minimum freq
    PSU1_Tach_High          // high or low then maximum freq
	);
///////////////////////////////////////////////////////////////////
input           ResetNi;
input           SlowClock;
input           PSU_FANIN;
input   [7:0]   PSUFan_StReg;
output          PSU1_Tach_Low;
output          PSU1_Tach_High;
///////////////////////////////////////////////////////////////////
wire            PSU1_Tach_Low;
wire            PSU1_Tach_High;
wire    [11:0]  FanClk;
///////////////////////////////////////////////////////////////////

assign PSU1_Tach_Low	= (`PSU1FAN_MiniFreq < FanClk) ? 1'b0 : 1'b1;
assign PSU1_Tach_High	= (`PSU1FAN_MaxiFreq < FanClk) ? 1'b1 : 1'b0;

FanPWM_detect f(
        .ResetNi			(ResetNi),
        .CLKi				(SlowClock),
        .Fan_In				(PSU_FANIN),
        .FanClk				(FanClk)
		);

endmodule
///////////////////////////////////////////////////////////////////

module	FanPWM_detect (
        ResetNi,
        CLKi,
        Fan_In,
        FanClk
		);
input       					ResetNi;		// reset i
input           				CLKi;           // 32.768K clock input
input                           Fan_In;         // PSU FAN Signal In
output  [11:0]                  FanClk;

reg     [11:0]                  FanClk;
reg     [11:0]                  FanClk0;
reg     [14:0]   				clk_cnt;
reg                             Fan_In0;
reg                             bMySec;
reg                             bNewSec;


	always @(posedge CLKi or negedge ResetNi)
    begin
        if(1'b0 == ResetNi)
        begin
            bMySec		= `LOW;
            Fan_In0     = 1'b0;
            FanClk      = 12'h000;
        end
        else
        begin
            if(bMySec != bNewSec)
            begin
                FanClk = FanClk0 >> 1;
                bMySec = bNewSec;
                Fan_In0= Fan_In;
                FanClk0= 0;
            end
            else
            begin
            	if(Fan_In0 != Fan_In)
            	begin
                	FanClk0= FanClk0 + 1;
                    Fan_In0 = Fan_In;
                end
            end
        end
    end

	always @(posedge CLKi or negedge ResetNi)
    begin
        if(1'b0 == ResetNi)
        begin
            bNewSec		= `LOW;
        end
        else
        begin
            if(15'h7FFF != clk_cnt) clk_cnt = clk_cnt + 1;
			else
            begin
				clk_cnt 	= 0;
	            bNewSec		= ~bNewSec;
            end
        end
    end
endmodule
