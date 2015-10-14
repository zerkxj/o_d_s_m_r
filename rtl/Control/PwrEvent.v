//******************************************************************************
// File name        : PwrEvent.v
// Module name      : PwrEvent
// Description      : This module determines Power-Event state transition.
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
//  Five Power-Event states are modified :
//  Event_PowerDown , Event_PowerFail , Event_SystemReset , Event_UpdatePwrSt ,
//  Event_SLP_S3n_UpChk
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`include "../Verilog/Includes/DefineODSTextMacro.v"

`ifdef SIMULATE_DESIGN
`define EvtTimer_T10        16'h0002
`define EvtTimer_T20        16'h0003
`define EvtTimer_T30        16'h0004
`define EvtTimer_T40        16'h0006
`define EvtTimer_T50        16'h0008
`define EvtTimer_T100       16'h0020
`define EvtTimer_T512       16'h0030
`define EvtTimer_T1000      16'h0040
`define EvtTimer_T1020      16'h0041
`define EvtTimer_T1030      16'h0042
`define EvtTimer_T1040      16'h0043
`define EvtTimer_T1050      16'h0044
`define EvtTimer_T2000      16'h0050
`define EvtTimer_T3000      16'h0060
`define EvtTimer_T4000      16'h0070
`define EvtTimer_T5000      16'h0080
`define EvtTimer_T6000      16'h0090    // 6  sec.
`define EvtTimer_T7000      16'h00A0    // 7  sec.
`define EvtTimer_T8000      16'h00B0
`define EvtTimer_T64000     16'h0100 // 64 sec. Frank 05072015 add this define
`else
`define EvtTimer_T10        16'h0010
`define EvtTimer_T20        16'h0020
`define EvtTimer_T30        16'h0030
`define EvtTimer_T40        16'h0040
`define EvtTimer_T50        16'h0050
`define EvtTimer_T100       16'h0064    // 100ms
`define EvtTimer_T512       16'h0200    // 512ms
`define EvtTimer_T1000      16'h03E7    // 1  sec.
`define EvtTimer_T1020      16'h0417   // 0x03E7 + 0x0020
`define EvtTimer_T1030      16'h0427   // 0x03E7 + 0x0030
`define EvtTimer_T1040      16'h0437   // 0x03E7 + 0x0040
`define EvtTimer_T1050      16'h0447   // 0x03E7 + 0x0050
`define EvtTimer_T2000      16'h07CF    // 2  sec.
`define EvtTimer_T3000      16'h0BB7    // 3  sec.
`define EvtTimer_T4000      16'h0F9F    // 4  sec.
`define EvtTimer_T5000      16'h1387    // 5  sec.
`define EvtTimer_T6000      16'h176F    // 6  sec.
`define EvtTimer_T7000      16'h1B57    // 7  sec.
`define EvtTimer_T8000      16'h1FFF    // 8  sec.
`define EvtTimer_T64000     16'hF9FF    // 64 sec.
`endif

`define PwrStateOk          1
`define PwrStateFail        0
`define PowerButtonPress    0
`define PowerButtonRls      1
`define CPUStateWorking     1
`define CPUStateSleep       0

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module PwrEvent (
    ResetN,
    CLK32768,
    Strobe1ms,
    PowerbuttonIn,
    PwrLastStateRdBit,
    SLP_S3n,
    ATX_PowerOK,
    ALL_PWRGD,
    BiosLed,
    bCPUWrWdtRegSig,
    PowerOff,

    PowerEvtState,
    PowerbuttonEvtOut,
    PS_ONn,
    bPwrSystemReset,
    bFlashPromReq,
    bRdPromCfg,
    bWrPromCfg,
    PwrLastStateWrBit,
    DbgP
);

//------------------------------------------------------------------------------
// Parameter declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// User defined parameter
//--------------------------------------------------------------------------
parameter CounterReset = 1'b0;
parameter CounterCount = 1'b1;

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
input           ResetN;
input           CLK32768 ;
input           Strobe1ms;
input           PowerbuttonIn;
input           PwrLastStateRdBit;
input           SLP_S3n;
input           ATX_PowerOK;
input           ALL_PWRGD;
input   [1:0]   BiosLed;
input   [4:0]   bCPUWrWdtRegSig;
input           PowerOff;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [3:0]   PowerEvtState;
output          PowerbuttonEvtOut;
output          PS_ONn;
output          bPwrSystemReset;
output          bFlashPromReq;
output          bRdPromCfg;
output          bWrPromCfg;
output          PwrLastStateWrBit;
output  [3:0]   DbgP;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            bBiosPostRdySig;

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
reg     [3:0]   PowerEvtState;
reg             PowerbuttonEvtOut;
reg             PS_ONn;
reg             bFlashPromReq;
reg             bRdPromCfg;
reg             bWrPromCfg;
reg             PwrLastStateWrBit;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [15:0]  CounterCnt;
reg             Strobe1ms_d0;
reg             CountState;
reg             CountState_N;
reg     [1:0]   BootUpRtyCnt;
reg             bFirstPwrUp;
reg     [1:0]   PrvBiosLed;
reg             bPwrFailUp;

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
// None

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
assign bPwrSystemReset = (`Event_SystemReset == PowerEvtState) ? 1'b1 : 1'b0;
assign DbgP = {SLP_S3n, PwrLastStateWrBit, CounterCnt[0], ATX_PowerOK};

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign bBiosPostRdySig = bCPUWrWdtRegSig[2];

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
    if(!ResetN)
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if(!ResetN) begin
        PowerEvtState <= #TD `Event_InitPowerUp;
        PowerbuttonEvtOut <= #TD `PowerButtonRls;
        PS_ONn <= #TD `PwrSW_Off;
        bFlashPromReq <= #TD `FALSE;
        bRdPromCfg <= #TD 1'b0;
        bWrPromCfg <= #TD 1'b0;
        PwrLastStateWrBit <= #TD `PwrStateOk;
    end else if(Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
                 case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                     `Event_InitPowerUp: begin // PwrEventState = 0x0
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         PS_ONn <= #TD `PwrSW_Off;
                         if(`EvtTimer_T100 > CounterCnt)
                             if(`EvtTimer_T20 == CounterCnt)
                                 bRdPromCfg <= #TD 1'b1;
                             else if(`EvtTimer_T30 == CounterCnt)
                                      bRdPromCfg <= #TD 1'b0;
                         else begin
                             PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                             if(`PwrStateOk == PwrLastStateRdBit) begin
                                 PowerEvtState <= #TD `Event_PowerStandBy;
                             else
                                 PowerEvtState <= #TD `Event_SLP_S3n;
                         end
                     end
                     `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                         PS_ONn <= #TD `PwrSW_Off;
                         if(`CPUStateWorking == SLP_S3n)
                             if(`FALSE == bFirstPwrUp)
                                 PowerEvtState <= #TD `Event_PowerStandBy;
                             else
                                 PowerEvtState <= #TD `Event_Reboot;
                         else
                             if(`EvtTimer_T1000 > CounterCnt)
                                 PowerbuttonEvtOut <= #TD `PowerButtonPress;
                             else if(`EvtTimer_T1000 <= CounterCnt && `EvtTimer_T2000 > CounterCnt)
                                      PowerbuttonEvtOut <= #TD `PowerButtonRls;
                                  else
                                      PowerbuttonEvtOut <= #TD `PowerButtonRls;
                     end
                     `Event_PowerStandBy: begin // PwrEventState = 0x1
                         PS_ONn <= #TD `PwrSW_Off;
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`PowerButtonRls == PowerbuttonIn)
                             if(2'b00 != BootUpRtyCnt)
                                 PowerEvtState <= #TD `Event_Reboot;
                         else if(`EvtTimer_T20 < CounterCnt)
                                  PowerEvtState <= #TD `Event_SLP_S3n_UpChk;
                     end
                     `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                         // the power button has been press, check the SLP_S3#
                         if(`EvtTimer_T1050 > CounterCnt) begin
                             PwrLastStateWrBit <= #TD `PwrStateFail;
                             bFlashPromReq <= #TD `TRUE;
                             if(`EvtTimer_T20 == CounterCnt)
                                 bWrPromCfg <= #TD 1'b1;
                             else if(`EvtTimer_T1020 == CounterCnt)
                                      bWrPromCfg <= #TD 1'b0;
                                  else if(`EvtTimer_T1030 == CounterCnt)
                                           bRdPromCfg <= #TD 1'b1;
                                       else if(`EvtTimer_T1040 == CounterCnt)
                                                bRdPromCfg <= #TD 1'b0;
                         end else if(`EvtTimer_T2000 < CounterCnt) begin
                                      PowerEvtState <= #TD `Event_PowerStandBy;
                                  end else begin
                                      bFlashPromReq <= #TD `FALSE;
                                      PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                                      if(`CPUStateWorking == SLP_S3n)
                                          PowerEvtState <= #TD `Event_Reboot;
                                  end
                     end
                     `Event_Reboot: begin // PwrEventState = 0x2
                         PS_ONn <= #TD `PwrSW_On;
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`EvtTimer_T5000 > CounterCnt)
                             if(PrvBiosLed != BiosLed)
                                 PowerEvtState <= #TD `Event_Wait2s;
                         else if(`FALSE == ATX_PowerOK)
                                  PowerEvtState <= #TD `Event_Wait2s;
                              else if(`HIGH == ALL_PWRGD)
                                       PowerEvtState <= #TD `Event_BiosPost_Wait;
                                   else
                                       PowerEvtState <= #TD `Event_Wait2s;
                     end
                     `Event_BiosPost_Wait: begin // PwrEventState = 0xC
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         PS_ONn <= #TD `PwrSW_On;
                         if(`TRUE == bBiosPostRdySig)
                             PowerEvtState <= #TD `Event_UpdatePwrSt;
                         else if(`EvtTimer_T64000 > CounterCnt)
                                  if(PrvBiosLed != BiosLed)
                                      PowerEvtState <= #TD `Event_Wait2s;
                              else
                                  PowerEvtState <= #TD `Event_Wait2s;
                     end
                     `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                         PS_ONn <= #TD `PwrSW_On;
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`EvtTimer_T1050 > CounterCnt ) begin
                             PwrLastStateWrBit <= #TD `PwrStateFail;
                             bFlashPromReq <= #TD `TRUE;
                             if(`EvtTimer_T20 == CounterCnt)
                                 bWrPromCfg <= #TD 1'b1;
                             else if(`EvtTimer_T1020 == CounterCnt)
                                      bWrPromCfg <= #TD 1'b0;
                                  else if(`EvtTimer_T1030 == CounterCnt)
                                           bRdPromCfg <= #TD 1'b1;
                                       else if(`EvtTimer_T1040 == CounterCnt)
                                                bRdPromCfg <= #TD 1'b0;
                         end else begin
                             bFlashPromReq <= #TD `FALSE;
                             PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                             if(`FALSE == ATX_PowerOK)
                                 PowerEvtState <= #TD `Event_Wait2s;
                             else if(`HIGH == ALL_PWRGD)
                                      PowerEvtState <= #TD `Event_SystemRun;
                                  else
                                      PowerEvtState <= #TD `Event_Wait2s;
                         end
                     end
                     `Event_SystemRun: begin // PwrEventState = 0x4
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         PS_ONn <= #TD `PwrSW_On;
                         if(PowerOff)
                             PowerEvtState <= #TD `Event_PowerDown;
                         else begin
                             case ({SLP_S3n, ATX_PowerOK})
                             2'b00: PowerEvtState <= #TD `Event_PowerFail;
                             2'b01: PowerEvtState <= #TD `Event_SystemReset;
                             2'b10: PowerEvtState <= #TD `Event_PowerFail;
                             2'b11: PowerEvtState <= #TD `Event_SystemRun;
                             endcase
                         end
                     end
                     `Event_SystemReset: begin // PwrEventState = 0x5
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`EvtTimer_T2000 > CounterCnt ) begin
                             PS_ONn <= #TD `PwrSW_On;
                             PwrLastStateWrBit <= #TD `PwrStateOk;
                             bFlashPromReq <= #TD `TRUE;
                             if(`EvtTimer_T20 == CounterCnt)
                                 bWrPromCfg <= #TD 1'b1;
                             else if(`EvtTimer_T1020 == CounterCnt)
                                      bWrPromCfg <= #TD 1'b0;
                                  else if(`EvtTimer_T1030 == CounterCnt)
                                           bRdPromCfg <= #TD 1'b1;
                                       else if(`EvtTimer_T1040 == CounterCnt)
                                                bRdPromCfg <= #TD 1'b0;
                         end else if(`EvtTimer_T2000 <= CounterCnt && `EvtTimer_T7000 > CounterCnt) begin
                                      bFlashPromReq <= #TD `FALSE;
                                      PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                                      PS_ONn <= #TD `PwrSW_Off;
                                      if(`CPUStateSleep != SLP_S3n)
                                          PowerEvtState <= #TD `Event_PowerCycle;
                                  end else
                                          PowerEvtState <= #TD `Event_Wait2s;
                     end
                     `Event_PowerCycle: begin // PwrEventState = 0x6
                         PS_ONn <= #TD `PwrSW_On;
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`EvtTimer_T3000  > CounterCnt) begin
                             if(`CPUStateWorking != SLP_S3n)
                                 PowerEvtState <= #TD `Event_Wait2s;
                         else
                             PowerEvtState <= #TD `Event_SystemRun;
                     end
                     `Event_PowerFail: begin // PwrEventState = 0x7
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`EvtTimer_T1050 > CounterCnt ) begin
                             PwrLastStateWrBit <= #TD `PwrStateFail;
                             PS_ONn <= #TD `PwrSW_On;
                             bFlashPromReq <= #TD `TRUE;
                             if(`EvtTimer_T20 >= CounterCnt)
                                 bWrPromCfg <= #TD 1'b1;
                             else if(`EvtTimer_T1020 == CounterCnt)
                                      bWrPromCfg <= #TD 1'b0;
                                  else if(`EvtTimer_T1030 == CounterCnt)
                                           bRdPromCfg <= #TD 1'b1;
                                       else if(`EvtTimer_T1040 == CounterCnt)
                                                bRdPromCfg <= #TD 1'b0;
                         end else if(`EvtTimer_T1050 <= CounterCnt && `EvtTimer_T5000 > CounterCnt) begin
                                      if(`TRUE == ATX_PowerOK)
                                          PowerEvtState <= #TD `Event_Wait2s;
                                      bFlashPromReq <= #TD `FALSE;
                                      PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                                  end else begin
                                      bFlashPromReq <= #TD `FALSE;
                                      PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                                      PowerEvtState <= #TD `Event_Wait2s;    //`Event_SLP_S3n;
                                  end
                     end
                     `Event_PowerDown: begin // PwrEventState = 0x9
                         if(`EvtTimer_T1050 > CounterCnt) begin
                             PowerbuttonEvtOut <= #TD `PowerButtonPress;  // push the power button to power off
                             PS_ONn <= #TD `PwrSW_On;
                             PwrLastStateWrBit <= #TD `PwrStateOk;
                             bFlashPromReq <= #TD `TRUE;
                             if(`EvtTimer_T20 == CounterCnt)
                                 bWrPromCfg <= #TD 1'b1;
                             else if(`EvtTimer_T1020 == CounterCnt)
                                      bWrPromCfg <= #TD 1'b0;
                                  else if(`EvtTimer_T1030 == CounterCnt)
                                           bRdPromCfg <= #TD 1'b1;
                                       else if(`EvtTimer_T1040 == CounterCnt)
                                                bRdPromCfg <= #TD 1'b0;
                         end else if(`EvtTimer_T1050 <= CounterCnt && `EvtTimer_T5000 > CounterCnt) begin
                                      bFlashPromReq <= #TD `FALSE;
                                      PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                                      PowerbuttonEvtOut <= #TD `PowerButtonPress;  // push the power button to power off
                                      PS_ONn <= #TD `PwrSW_On;
                                  end else if(`EvtTimer_T5000 <= CounterCnt && `EvtTimer_T6000 > CounterCnt) begin
                                               PowerbuttonEvtOut <= #TD `PowerButtonRls;  // push the power button to power off
                                               PS_ONn <= #TD `PwrSW_On;
                                           end else if(`EvtTimer_T6000 <= CounterCnt && `EvtTimer_T8000 > CounterCnt) begin
                                                         PowerbuttonEvtOut <= #TD `PowerButtonRls;  // push the power button to power off
                                                         PS_ONn <= #TD `PwrSW_Off;
                                                     end else begin
                                                         PS_ONn <= #TD `PwrSW_Off;
                                                         PowerbuttonEvtOut <= #TD `PowerButtonRls;  // push the power button to power off
                                                         PowerEvtState <= #TD `Event_Wait2s;
                                                     end
                     end                                             // end of Event_PowerDown
                     // wait for power button release
                     `Event_Wait2s: begin // PwrEventState = 0x8
                         PS_ONn <= #TD `PwrSW_Off;
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         if(`EvtTimer_T6000 < CounterCnt)
                             if(`FALSE == bPwrFailUp)
                                 PowerEvtState <= #TD `Event_PowerStandBy;    //`Event_SLP_S3n;
                             else
                                 PowerEvtState <= #TD `Event_SLP_S3n;       // make sure the SLP_S3n is high
                     end                                             // end of Event_Wait2s
                     default: begin
                         PowerbuttonEvtOut <= #TD `PowerButtonRls;
                         PS_ONn <= #TD `PwrSW_Off;
                         PowerEvtState <= #TD `Event_PowerStandBy;    //`Event_SLP_S3n;
                     end
                 endcase
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if(!ResetN) begin
        CountState_N <= #TD CounterReset;
        BootUpRtyCnt <= #TD 2'd0;
        bFirstPwrUp <= #TD `TRUE;
        PrvBiosLed <= #TD 2'd0;
        bPwrFailUp <= #TD `FALSE;
    end else if(Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
                 case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                     `Event_InitPowerUp: begin // PwrEventState = 0x0
                         BootUpRtyCnt <= #TD 0;
                         bPwrFailUp <= #TD `FALSE;
                         PrvBiosLed <= #TD BiosLed;
                         if(`EvtTimer_T100 > CounterCnt)
                             CountState_N <= #TD CounterCount;
                         else if(`PwrStateOk == PwrLastStateRdBit)
                                  bFirstPwrUp <= #TD `FALSE;
                              else
                                  bFirstPwrUp <= #TD `TRUE;
                         CountState_N <= #TD CounterReset;
                     end
                     `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                         bPwrFailUp <= #TD `FALSE;
                         if(`CPUStateWorking == SLP_S3n) begin
                             CountState_N <= #TD CounterReset;
                             PrvBiosLed <= #TD BiosLed;
                             if(`FALSE != bFirstPwrUp)
                                 bFirstPwrUp <= #TD `FALSE;
                         end else if(`EvtTimer_T1000 > CounterCnt )
                                      CountState_N <= #TD CounterCount;
                                  else if(`EvtTimer_T1000 <= CounterCnt && `EvtTimer_T2000 > CounterCnt)
                                           CountState_N <= #TD CounterCount;
                                       else
                                           CountState_N <= #TD CounterReset;
                     end
                     `Event_PowerStandBy: begin // PwrEventState = 0x1
                         PrvBiosLed <= #TD BiosLed;
                         bPwrFailUp <= #TD `FALSE;
                         if(`PowerButtonRls == PowerbuttonIn) begin
                             CountState_N <= #TD CounterReset;
                         end else begin
                             // press the power button
                             if(`EvtTimer_T20 > CounterCnt)
                                 CountState_N <= #TD CounterCount;
                             else
                                 CountState_N <= #TD CounterReset;
                             BootUpRtyCnt <= #TD 2'd0;
                         end
                     end
                     `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                         // the power button has been press, check the SLP_S3#
                         if(`EvtTimer_T1050 > CounterCnt)
                             CountState_N <= #TD CounterCount;
                         else if(`EvtTimer_T2000 < CounterCnt)
                                  CountState_N <= #TD CounterReset;
                              else if(`CPUStateWorking != SLP_S3n)
                                       CountState_N <= #TD CounterCount;
                                   else
                                       CountState_N <= #TD CounterReset;
                     end
                     `Event_Reboot: begin // PwrEventState = 0x2
                         if(`EvtTimer_T5000 > CounterCnt)
                             if(PrvBiosLed == BiosLed)
                                 CountState_N <= #TD CounterCount;
                             else begin
                                 PrvBiosLed <= #TD BiosLed;
                                 BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                 CountState_N <= #TD CounterReset;
                             end
                         else begin
                             if(`FALSE == ATX_PowerOK) begin
                                 bPwrFailUp <= #TD `TRUE;
                                 BootUpRtyCnt <= #TD 1;
                             end else if(`HIGH != ALL_PWRGD)
                                          if(`FALSE == bFirstPwrUp)
                                              BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                          else begin
                                              bFirstPwrUp <= #TD `FALSE;
                                              BootUpRtyCnt <= #TD 2'd1;
                                          end
                             CountState_N <= #TD CounterReset;
                         end
                     end
                     `Event_BiosPost_Wait: begin // PwrEventState = 0xC
                         if(`TRUE == bBiosPostRdySig)
                             CountState_N <= #TD CounterReset;
                         else if(`EvtTimer_T64000 > CounterCnt)
                                  if(PrvBiosLed == BiosLed)
                                      CountState_N <= #TD CounterCount;
                                  else begin
                                      PrvBiosLed <= #TD BiosLed;
                                      BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                      CountState_N <= #TD CounterReset;
                                  end
                              else begin
                                  BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                  CountState_N <= #TD CounterReset;
                              end
                     end
                     `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                         if(`EvtTimer_T1050 > CounterCnt)
                             CountState_N <= #TD CounterCount;
                         else begin
                             if(`FALSE == ATX_PowerOK) begin
                                 bPwrFailUp <= #TD `TRUE;
                                 BootUpRtyCnt <= #TD 2'd1;
                             end
                             CountState_N <= #TD CounterReset;
                         end
                     end
                     `Event_SystemRun: begin // PwrEventState = 0x4
                         BootUpRtyCnt <= #TD 2'd0;
                         CountState_N <= #TD CounterReset;
                     end
                     `Event_SystemReset: begin // PwrEventState = 0x5
                         if(`EvtTimer_T2000 > CounterCnt ) begin
                             CountState_N <= #TD CounterCount;
                         end else if(`EvtTimer_T2000 <= CounterCnt && `EvtTimer_T7000 > CounterCnt)
                                      if(`CPUStateSleep == SLP_S3n)
                                          CountState_N <= #TD CounterCount;
                                      else
                                          CountState_N <= #TD CounterReset;
                                  else
                                      CountState_N <= #TD CounterReset;
                     end
                     `Event_PowerCycle: begin // PwrEventState = 0x6
                         if(`EvtTimer_T3000  > CounterCnt)
                             if(`CPUStateWorking == SLP_S3n)
                                 CountState_N <= #TD CounterCount;
                             else begin
                                 BootUpRtyCnt <= #TD 2'd1;
                                 CountState_N <= #TD CounterReset;
                             end
                         else
                             CountState_N <= #TD CounterReset;
                     end
                     `Event_PowerFail: begin // PwrEventState = 0x7
                         if(`EvtTimer_T1050 > CounterCnt)
                             CountState_N <= #TD CounterCount;
                         else if(`EvtTimer_T1050 <= CounterCnt && `EvtTimer_T5000 > CounterCnt)
                                  if(`TRUE == ATX_PowerOK) begin
                                      // AC restored, reboot the system
                                      CountState_N <= #TD CounterReset;
                                      bPwrFailUp <= #TD `TRUE;
                                      BootUpRtyCnt <= #TD 2'd1;
                                  end
                              else
                                  CountState_N <= #TD CounterReset;
                     end
                     `Event_PowerDown: begin // PwrEventState = 0x9
                         if(`EvtTimer_T1050 > CounterCnt)
                             CountState_N <= #TD CounterCount;
                         else if(CounterCnt >= `EvtTimer_T8000)
                                  CountState_N <= #TD CounterReset;
                     end                                             // end of Event_PowerDown
                     // wait for power button release
                     `Event_Wait2s: begin // PwrEventState = 0x8
                         if(`EvtTimer_T6000 > CounterCnt)
                             CountState_N <= #TD CounterCount;
                         else begin
                             // over 2 sec.
                             CountState_N <= #TD CounterReset;
                             if(`FALSE != bPwrFailUp)
                                 bPwrFailUp <= #TD `FALSE;
                         end
                     end                                             // end of Event_Wait2s
                     default: begin
                         CountState_N <= #TD CounterReset;
                     end
                 endcase
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if(!ResetN) begin
        CounterCnt <= #TD 16'd0;
        CountState <= #TD CounterReset;
    end else if(!Strobe1ms_d0)
                 if(CountState_N != CountState) begin
                     if(CounterReset == CountState_N)
                         CounterCnt <= #TD 16'd0;
                     CountState <= #TD CountState_N;
                 end
             else if(CountState_N != CountState) begin
                      case (CountState_N)
                          CounterReset: CounterCnt <= #TD 16'd0;
                          CounterCount: CounterCnt <= #TD CounterCnt + 16'd1;
                      endcase
                      CountState <= #TD CountState_N;
                  end else
                      case (CountState)
                          CounterReset: CounterCnt <= #TD 16'd0;
                          CounterCount: CounterCnt <= #TD CounterCnt + 16'd1;
                      endcase
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if(!ResetN)
        Strobe1ms_d0 <= #TD 1'b0;
    else
        Strobe1ms_d0 <= #TD Strobe1ms;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
// None

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule // PwrEvent
