//////////////////////////////////////////////////////////////////////////////
// File name        : DualPSCfg.v
// Module name      : DualPSCfg
// Description      : This module configures PSU                   
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
////////////////////////////////////////////////////////////////////////////// 
//  Notes :  
//  Use Lattice MXO2-2000 UFM to store two non-volatile bits. 
//  Lattice UFM write timing needs to erase UFM first .
//  Erasing MXO-2000 needs 500~900ms.
//  Programming a page ( 16 byte ) data to UFM needs around 0.2 ms.
//  Reading a page from UFM needs the time less than 1 ms.
//  Therefore , the timing for UFM write will be redefined.
//   Add four parameters : T1020 = T1000 + T20 = 0x03E7 + 0x0020
//                         T1030 = T1000 + T30 = 0x03E7 + 0x0030
//                         T1040 = T1000 + T40 = 0x03E7 + 0x0040 
//                         T1050 = T1000 + T50 = 0x03E7 + 0x0050 
//  For bWr_bRd pair, T20-T30_T40-T50 will be replaced by T20-T1020_T1030-T1040 
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"
//////////////////////////////////////////////////////////////////////////////
`ifdef SIMULATE_DESIGN
`define EvtTimer_T20        16'h0020
`define EvtTimer_T30        16'h0030
`define EvtTimer_T40        16'h0040
`define EvtTimer_T50        16'h0050
`define EvtTimer_T100       16'h0064    // 100ms
// Frank 05292015 add ---start_0 ---
`define EvtTimer_T1020      16'h0041
`define EvtTimer_T1030      16'h0042
`define EvtTimer_T1040      16'h0043
`define EvtTimer_T1050      16'h0044
// Frank 05292015 add ---end_0   ---
`else
`define EvtTimer_T20        16'h0020
`define EvtTimer_T30        16'h0030
`define EvtTimer_T40        16'h0040
`define EvtTimer_T50        16'h0050
`define EvtTimer_T100       16'h0064    // 100ms
// Frank 05292015 add ---start_1 ---
`define EvtTimer_T1020      16'h0417   // 0x03E7 + 0x0020
`define EvtTimer_T1030      16'h0427   // 0x03E7 + 0x0030
`define EvtTimer_T1040      16'h0437   // 0x03E7 + 0x0040
`define EvtTimer_T1050      16'h0447   // 0x03E7 + 0x0050
// Frank 05292015 add ---end_1   ---
`endif

`define DualPSCfg           1
`define SinglePSCfg         0

`define HostCmdWrPsCfg		7'h50
`define HostCmdRdPsCfg		8'hB0

`define Event_PsCfgIdle		0
`define Event_PsCfgWrite	1
`define Event_PsCfgRead		2
//////////////////////////////////////////////////////////////////////////////
module DualPSCfg (
    ResetN,
    CLK32768, 
    Strobe1ms,
    SpecialCmdReg,
	bPromBusy,
	DualPSCfgRdBit,
    bFlashPromReq,    
	bRdPromCfg,    
	bWrPromCfg,
    DualPSCfgWrBit,
    DbgP
    );
//======================================
input				ResetN;
input				CLK32768; 
input               Strobe1ms;
input   [7:0]       SpecialCmdReg;
input               bPromBusy;
input				DualPSCfgRdBit;
//======================================
output              bFlashPromReq;
output              bRdPromCfg;
output              bWrPromCfg;
output	            DualPSCfgWrBit;
output  [2:0]       DbgP;
//======================================
reg                 bRdPromCfg;
reg                 bWrPromCfg;
reg                 Strobe1ms_d0;
reg		            CountState;
reg		            CountState_N;
reg                 DualPSCfgWrBit;
reg					bFlashPromReq;
reg     [3:0]       pState;
reg     [7:0]       CounterCnt;
reg     [7:0]       SpecialCmdReg_o;
//======================================
wire    [2:0]       DbgP;
//======================================
parameter           CounterReset= 1'b0;
parameter           CounterCount= 1'b1;
//////////////////////////////////////////////////////////////////////////////
	initial
	begin
        pState      		= `Event_InitPowerUp;
        bRdPromCfg  		= 0;
        bWrPromCfg  		= 0;
        Strobe1ms_d0		= 0;
        DualPSCfgWrBit		= `SinglePSCfg;
        CountState  		= CounterReset;
        CountState_N		= CounterReset;
        bFlashPromReq       = `FALSE;
	end
//////////////////////////////////////////////////////////////////////////////
    assign DbgP  = pState;
//////////////////////////////////////////////////////////////////////////////
	always @(posedge CLK32768 or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
	        pState      		= `Event_PsCfgIdle;
            CountState_N		= CounterReset;
	        bRdPromCfg  		= 0;
	        bWrPromCfg  		= 0;
            DualPSCfgWrBit		= `SinglePSCfg;
	        bFlashPromReq       = `FALSE;
		end
		else
		begin
            if(1'b1 == Strobe1ms)
            begin
        		case(pState)
            	`Event_PsCfgIdle:
            	begin
			    	CountState_N	= CounterReset;
				    bFlashPromReq	= `FALSE;

					if(bPromBusy) pState	= `Event_PsCfgIdle;
                    else if(SpecialCmdReg_o == SpecialCmdReg)
                    begin
	                    SpecialCmdReg_o = SpecialCmdReg;
                        DualPSCfgWrBit	= DualPSCfgRdBit;
						pState			= `Event_PsCfgIdle;
                    end
                    else
                    begin
                    	if(`HostCmdRdPsCfg == SpecialCmdReg) pState = `Event_PsCfgRead;
                    	else if(`HostCmdWrPsCfg == SpecialCmdReg[7:1]) pState = `Event_PsCfgWrite;
                        else
                    	begin
	                    	SpecialCmdReg_o = SpecialCmdReg;
                        	DualPSCfgWrBit	= DualPSCfgRdBit;
							pState			= `Event_PsCfgIdle;
                        end
                    end
            	end

				`Event_PsCfgWrite:
                begin
                    SpecialCmdReg_o     = SpecialCmdReg;
					// Frank 05292015 modify 
                	//- if(`EvtTimer_T100 > CounterCnt )
					if(`EvtTimer_T1050 > CounterCnt )
                	begin
				        bFlashPromReq	= `TRUE;
			            DualPSCfgWrBit	= !SpecialCmdReg[0];
						// Frank 05292015 modify 
						//- if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	//- else  if(`EvtTimer_T30 == CounterCnt) bWrPromCfg = 0;
                    	//- else  if(`EvtTimer_T40 == CounterCnt) bRdPromCfg = 1;
                    	//- else  if(`EvtTimer_T50 == CounterCnt) bRdPromCfg = 0;
						      if(`EvtTimer_T20 == CounterCnt)   bWrPromCfg = 1;
                    	else  if(`EvtTimer_T1020 == CounterCnt) bWrPromCfg = 0;
                    	else  if(`EvtTimer_T1030 == CounterCnt) bRdPromCfg = 1;
                    	else  if(`EvtTimer_T1040 == CounterCnt) bRdPromCfg = 0;
						CountState_N	= CounterCount;
                	end
                	else // if(`EvtTimer_T100 <= CounterCnt)
                	begin
				        bFlashPromReq	= `FALSE;
                        DualPSCfgWrBit	= DualPSCfgRdBit;
						CountState_N	= CounterReset;
						pState			= `Event_PsCfgIdle;
                	end
                end

				`Event_PsCfgRead:
                begin
                    SpecialCmdReg_o     = SpecialCmdReg;
                	if(`EvtTimer_T100 > CounterCnt )
                	begin
				        bFlashPromReq	= `TRUE;
						if(`EvtTimer_T20 == CounterCnt) 	  bRdPromCfg = 1;
                    	else  if(`EvtTimer_T30 == CounterCnt) bRdPromCfg = 0;
						CountState_N	= CounterCount;
                	end
                	else // if(`EvtTimer_T100 <= CounterCnt)
                	begin
				        bFlashPromReq	= `FALSE;
                        DualPSCfgWrBit	= DualPSCfgRdBit;
						CountState_N	= CounterReset;
						pState			= `Event_PsCfgIdle;
                	end
                end

				default:
                begin
			    	CountState_N		= CounterReset;
					pState      		= `Event_PsCfgIdle;
            	end

				endcase // pState
            end // if(1'b1 == Strobe1ms) else
        end	// if(1'b0 == ResetN) else
    end
//////////////////////////////////////////////////////////////////////////////
	always @(posedge CLK32768 or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
            CounterCnt  = 0;
            CountState  = CounterReset;
		end
		else
		begin
            if(1'b0 == Strobe1ms_d0)
            begin
                if(CountState_N != CountState)
                begin
                    if(CounterReset == CountState_N) CounterCnt = 0;
                    CountState = CountState_N;
                end
            end
            else
            begin
                if(CountState_N != CountState)
                begin
                    case (CountState_N)
                    CounterReset:   CounterCnt = 0;
                    CounterCount:   CounterCnt = CounterCnt + 1;
                    endcase
                    CountState = CountState_N;
                end
                else
                begin
                    case (CountState)
                    CounterReset:   CounterCnt = 0;
                    CounterCount:   CounterCnt = CounterCnt + 1;
                    endcase
                end
            end
        end
    end
//////////////////////////////////////////////////////////////////////////////
	always @(posedge CLK32768 or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
            Strobe1ms_d0  = 1'b0;
		end
		else
		begin
            Strobe1ms_d0 = Strobe1ms;
        end
    end
//////////////////////////////////////////////////////////////////////////////
endmodule // DualPSCfg
