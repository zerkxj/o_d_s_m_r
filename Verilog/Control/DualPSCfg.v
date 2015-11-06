//******************************************************************************
// File name        : DualPSCfg.v
// Module name      : DualPSCfg
// Description      : This module configures PSU
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//******************************************************************************
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
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
`timescale 1 ns / 100 ps

`include "../Verilog/Includes/DefineODSTextMacro.v"

`ifdef SIMULATE_DESIGN
`define EvtTimer_T20        16'h0020
`define EvtTimer_T30        16'h0030
`define EvtTimer_T40        16'h0040
`define EvtTimer_T50        16'h0050
`define EvtTimer_T100       16'h0064    // 100ms
`define EvtTimer_T1020      16'h0041
`define EvtTimer_T1030      16'h0042
`define EvtTimer_T1040      16'h0043
`define EvtTimer_T1050      16'h0044
`else
`define EvtTimer_T20        16'h0020
`define EvtTimer_T30        16'h0030
`define EvtTimer_T40        16'h0040
`define EvtTimer_T50        16'h0050
`define EvtTimer_T100       16'h0064    // 100ms
`define EvtTimer_T1020      16'h0417    // 0x03E7 + 0x0020
`define EvtTimer_T1030      16'h0427    // 0x03E7 + 0x0030
`define EvtTimer_T1040      16'h0437    // 0x03E7 + 0x0040
`define EvtTimer_T1050      16'h0447    // 0x03E7 + 0x0050
`endif

`define DualPSCfg 1
`define SinglePSCfg 0

`define HostCmdWrPsCfg 7'h50
`define HostCmdRdPsCfg 8'hB0

`define Event_PsCfgIdle 0
`define Event_PsCfgWrite 1
`define Event_PsCfgRead 2

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module DualPSCfg (
    ResetN,         // In,
    CLK32768,       // In,
    Strobe1ms,      // In,
    SpecialCmdReg,  // In,
    bPromBusy,      // In,
    DualPSCfgRdBit, // In,

    bFlashPromReq,  // Out,
    bRdPromCfg,     // Out,
    bWrPromCfg,     // Out,
    DualPSCfgWrBit, // Out,
    DbgP            // Out,
);

//------------------------------------------------------------------------------
// Parameter declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// User defined parameter
//--------------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Standard parameter
//--------------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Local parameter
//--------------------------------------------------------------------------
// time delay, flip-flop output assignment delay for simulation waveform trace
localparam TD = 1;

//------------------------------------------------------------------------------
// Variable declaration
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Input/Output declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Input declaration
//--------------------------------------------------------------------------
//======================================
input           ResetN;
input           CLK32768;
input           Strobe1ms;
input   [7:0]   SpecialCmdReg;
input           bPromBusy;
input           DualPSCfgRdBit;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output          bFlashPromReq;
output          bRdPromCfg;
output          bWrPromCfg;
output          DualPSCfgWrBit;
output  [2:0]   DbgP;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Reg declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational
//----------------------------------------------------------------------
//------------------------------------------------------------------
// Output
//------------------------------------------------------------------
// None

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
// None

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// Sequential
//----------------------------------------------------------------------
//------------------------------------------------------------------
// Output
//------------------------------------------------------------------
reg             bFlashPromReq;
reg             bRdPromCfg;
reg             bWrPromCfg;
reg             DualPSCfgWrBit;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [7:0]   SpecialCmdReg_o;
reg             CountState_N;
reg     [7:0]   CounterCnt;
reg             CountState;
reg             Strobe1ms_d0;

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
reg     [3:0]   pState;

//------------------------------------------------------------------------------
// Task/Function description and included task/function description
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Main code
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Combinational circuit
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Output
//----------------------------------------------------------------------
assign DbgP = pState;

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Sequential circuit
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Output
//----------------------------------------------------------------------
always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bFlashPromReq <= #TD `FALSE;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgIdle: bFlashPromReq <= #TD `FALSE;

                 `Event_PsCfgWrite: begin
                     if (CounterCnt < `EvtTimer_T1050)
                         bFlashPromReq <= #TD `TRUE;
                     else
                         bFlashPromReq <= #TD `FALSE;
                 end

                 `Event_PsCfgRead: begin
                     if (CounterCnt < `EvtTimer_T100)
                         bFlashPromReq <= #TD `TRUE;
                     else
                         bFlashPromReq <= #TD `FALSE;
                 end

                 default: bFlashPromReq <= #TD bFlashPromReq;
             endcase
         else
             bFlashPromReq <= #TD bFlashPromReq;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bRdPromCfg <= #TD 1'b0;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgWrite: begin
                     if (CounterCnt < `EvtTimer_T1050)
                         if (CounterCnt == `EvtTimer_T1030)
                             bRdPromCfg <= #TD 1'b1;
                         else if (CounterCnt == `EvtTimer_T1040)
                                  bRdPromCfg <= #TD 1'b0;
                              else
                                  bRdPromCfg <= #TD bRdPromCfg;
                     else
                         bRdPromCfg <= #TD bRdPromCfg;
                 end

                 `Event_PsCfgRead: begin
                     if (CounterCnt < `EvtTimer_T100)
                         if (`EvtTimer_T20 == CounterCnt)
                             bRdPromCfg <= #TD 1'b1;
                         else if (`EvtTimer_T30 == CounterCnt)
                                  bRdPromCfg <= #TD 1'b0;
                              else
                                  bRdPromCfg <= #TD bRdPromCfg;
                     else
                         bRdPromCfg <= #TD bRdPromCfg;
                 end

                 default: bRdPromCfg <= #TD bRdPromCfg;
             endcase
         else
             bRdPromCfg <= #TD bRdPromCfg;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bWrPromCfg <= #TD 1'b0;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgWrite: begin
                     if (CounterCnt < `EvtTimer_T1050)
                         if (CounterCnt == `EvtTimer_T20)
                             bWrPromCfg <= #TD 1'b1;
                         else if (CounterCnt == `EvtTimer_T1020)
                                  bWrPromCfg <= #TD 1'b0;
                              else
                                  bWrPromCfg <= #TD bWrPromCfg;
                     else
                         bWrPromCfg <= #TD bWrPromCfg;
                 end

                 default: bWrPromCfg <= #TD bWrPromCfg;
             endcase
         else
             bWrPromCfg <= #TD bWrPromCfg;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        DualPSCfgWrBit <= #TD `SinglePSCfg;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgIdle: begin
                     if (bPromBusy)
                         DualPSCfgWrBit <= #TD DualPSCfgWrBit;
                     else if (SpecialCmdReg_o == SpecialCmdReg)
                              DualPSCfgWrBit <= #TD DualPSCfgRdBit;
                          else if (SpecialCmdReg == `HostCmdRdPsCfg)
                                   DualPSCfgWrBit <= #TD DualPSCfgWrBit;
                               else if (SpecialCmdReg[7:1] == `HostCmdWrPsCfg)
                                        DualPSCfgWrBit <= #TD DualPSCfgWrBit;
                                    else
                                        DualPSCfgWrBit <= #TD DualPSCfgRdBit;
                 end

                 `Event_PsCfgWrite: begin
                     if (CounterCnt < `EvtTimer_T1050)
                         DualPSCfgWrBit <= #TD !SpecialCmdReg[0];
                     else
                         DualPSCfgWrBit <= #TD DualPSCfgRdBit;
                 end

                 `Event_PsCfgRead: begin
                     if (CounterCnt < `EvtTimer_T100)
                         DualPSCfgWrBit <= #TD DualPSCfgWrBit;
                     else
                         DualPSCfgWrBit <= #TD DualPSCfgRdBit;
                 end

                 default: DualPSCfgWrBit <= #TD DualPSCfgWrBit;
             endcase
         else
             DualPSCfgWrBit <= #TD DualPSCfgWrBit;
end


//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        SpecialCmdReg_o = 8'd0;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgIdle: begin
                     if (bPromBusy)
                         SpecialCmdReg_o = SpecialCmdReg_o;
                     else if (SpecialCmdReg == `HostCmdRdPsCfg)
                              SpecialCmdReg_o = SpecialCmdReg_o;
                          else if (SpecialCmdReg[7:1] == `HostCmdWrPsCfg)
                                   SpecialCmdReg_o = SpecialCmdReg_o;
                               else
                                   SpecialCmdReg_o = SpecialCmdReg;
                 end

                 `Event_PsCfgWrite: SpecialCmdReg_o = SpecialCmdReg;

                 `Event_PsCfgRead: SpecialCmdReg_o = SpecialCmdReg;

                 default: SpecialCmdReg_o = SpecialCmdReg_o;
             endcase
         else
             SpecialCmdReg_o = SpecialCmdReg_o;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        CountState_N <= #TD 1'b0;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgIdle: CountState_N <= #TD 1'b0;

                 `Event_PsCfgWrite: begin
                     if (CounterCnt < `EvtTimer_T1050)
                         CountState_N <= #TD 1'b1;
                     else
                         CountState_N <= #TD 1'b0;
                 end

                 `Event_PsCfgRead: begin
                     if (CounterCnt < `EvtTimer_T100)
                         CountState_N <= #TD 1'b1;
                     else
                         CountState_N <= #TD 1'b0;
                 end

                 default: CountState_N <= #TD 1'b0;
             endcase
         else
             CountState_N <= #TD CountState_N ;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        CounterCnt <= #TD 8'd0;
    else if (!Strobe1ms_d0)
             if (CountState_N != CountState)
                 if (!CountState_N)
                     CounterCnt <= #TD 8'd0;
                 else
                     CounterCnt <= #TD CounterCnt;
             else
                 CounterCnt <= #TD CounterCnt;
         else
             case (CountState_N)
                 1'b0: CounterCnt <= #TD 8'd0;
                 1'b1: CounterCnt <= #TD CounterCnt + 1;
             endcase
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        CountState <= #TD 1'b0;
    else
        CountState <= #TD CountState_N;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        Strobe1ms_d0 <= #TD 1'b0;
    else
        Strobe1ms_d0 <= #TD Strobe1ms;
end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        pState <= #TD `Event_PsCfgIdle;
    else if (Strobe1ms)
             case (pState)
                 `Event_PsCfgIdle: begin
                     if (bPromBusy)
                         pState <= #TD `Event_PsCfgIdle;
                     else if (SpecialCmdReg_o == SpecialCmdReg)
                              pState <= #TD `Event_PsCfgIdle;
                          else if (SpecialCmdReg == `HostCmdRdPsCfg)
                                   pState <= #TD `Event_PsCfgRead;
                               else if (SpecialCmdReg[7:1] == `HostCmdWrPsCfg)
                                        pState <= #TD `Event_PsCfgWrite;
                                    else
                                        pState <= #TD `Event_PsCfgIdle;
                 end

                 `Event_PsCfgWrite: begin
                     if (CounterCnt < `EvtTimer_T1050)
                         pState <= #TD pState;
                     else
                         pState <= #TD `Event_PsCfgIdle;
                 end

                 `Event_PsCfgRead: begin
                     if (CounterCnt < `EvtTimer_T100)
                         pState <= pState;
                     else
                         pState <= #TD `Event_PsCfgIdle;
                 end

                 default: pState <= #TD `Event_PsCfgIdle;
             endcase
         else
             pState <= #TD pState;
end

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule // DualPSCfg
