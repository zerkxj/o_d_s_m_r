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
//  Add Seven parameters : T1020 = T1000 + T20 = 0x03E7 + 0x0020
//                         T1030 = T1000 + T30 = 0x03E7 + 0x0030
//                         T1040 = T1000 + T40 = 0x03E7 + 0x0040
//                         T1050 = T1000 + T50 = 0x03E7 + 0x0050
//                         T1060 = T1000 + T60 = 0x03E7 + 0x0060
//                         T1070 = T1000 + T70 = 0x03E7 + 0x0070
//                         T1080 = T1000 + T80 = 0x03E7 + 0x0080
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
`define EvtTimer_T1060      16'h0045   
`define EvtTimer_T1070      16'h0046   
`define EvtTimer_T1080      16'h0047
`define EvtTimer_T2000      16'h0050
`define EvtTimer_T3000      16'h0060
`define EvtTimer_T4000      16'h0070
`define EvtTimer_T5000      16'h0080
`define EvtTimer_T6000      16'h0090    // 6  sec.
`define EvtTimer_T7000      16'h00A0    // 7  sec.
`define EvtTimer_T8000      16'h00B0
`define EvtTimer_T64000     16'h0100    // 64 sec.
`else
`define EvtTimer_T10        16'h0010    // 16ms
`define EvtTimer_T20        16'h0020    // 32ms
`define EvtTimer_T30        16'h0030    // 48ms
`define EvtTimer_T40        16'h0040    // 64ms
`define EvtTimer_T50        16'h0050    // 80ms
`define EvtTimer_T100       16'h0064    // 100ms
`define EvtTimer_T512       16'h0200    // 512ms
`define EvtTimer_T1000      16'h03E7    // 1  sec.
`define EvtTimer_T1020      16'h0407    // 0x03E7 + 0x0020 , 1032ms
`define EvtTimer_T1030      16'h0417    // 0x03E7 + 0x0030 , 1048ms
`define EvtTimer_T1040      16'h0427    // 0x03E7 + 0x0040 , 1064ms
`define EvtTimer_T1050      16'h0437    // 0x03E7 + 0x0050 , 1080ms
`define EvtTimer_T1060      16'h0447    // 0x03E7 + 0x0060 , 1096ms
`define EvtTimer_T1070      16'h0457    // 0x03E7 + 0x0070 , 1112ms
`define EvtTimer_T1080      16'h0467    // 0x03E7 + 0x0080 , 1128ms
`define EvtTimer_T2000      16'h07CF    // 2  sec.
`define EvtTimer_T3000      16'h0BB7    // 3  sec.
`define EvtTimer_T4000      16'h0F9F    // 4  sec.
`define EvtTimer_T5000      16'h1387    // 5  sec.
`define EvtTimer_T6000      16'h176F    // 6  sec.
`define EvtTimer_T7000      16'h1B57    // 7  sec.
`define EvtTimer_T8000      16'h1F3F    // 8  sec.
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
    ResetN,             // In, Reset signal
    CLK32768,           // In, 32.768 KHz clock
    Strobe1ms,          // In, 1ms Slow clock pulse
    PowerbuttonIn,      // In, Power button input
    PwrLastStateRdBit,  // In, Power last state read from flash
    SLP_S3n,            // In,
    ATX_PowerOK,        // In, 3V3 Power OK
    ALL_PWRGD,          // In, CPU Power Good
    BiosLed,            // In, BIOS LED
    bCPUWrWdtRegSig,    // In,
    BiosPowerOff,       // In, BiosWD Occurred, Force Power Off
    Shutdown,           // In, SW shutdown command

    PowerEvtState,      // Out, Power event state
    PowerbuttonEvtOut,  // Out, Power button event
    PS_ONn,             // Out, Power supply enable
    bPwrSystemReset,    // Out,
    bFlashPromReq,      // Out,
    bRdPromCfg,         // Out,
    bWrPromCfg,         // Out,
    PwrLastStateWrBit,  // Out, Power last state write bit
    DbgP                // Out,
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
input           BiosPowerOff;
input           Shutdown;

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
wire            bEnterBiosSetUpMenu;

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
reg             CountState_N;
reg     [1:0]   BootUpRtyCnt;
reg             bFirstPwrUp;
reg     [1:0]   PrvBiosLed;
reg             bPwrFailUp;
reg     [15:0]  CounterCnt;
reg             CountState;
reg             Strobe1ms_d0;

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
assign bPwrSystemReset = (PowerEvtState == `Event_SystemReset) ? 1'b1 : 1'b0;
assign DbgP = {SLP_S3n, PwrLastStateWrBit, CounterCnt[0], ATX_PowerOK};

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign bBiosPostRdySig = bCPUWrWdtRegSig[2];
assign bEnterBiosSetUpMenu = bCPUWrWdtRegSig[1];

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
        PowerEvtState <= #TD `Event_InitPowerUp;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: begin // PwrEventState = 0x0
                     if (CounterCnt < `EvtTimer_T100)
                         PowerEvtState <= #TD PowerEvtState;
                     else if (PwrLastStateRdBit == `PwrStateOk)
                              PowerEvtState <= #TD `Event_PowerStandBy;
                          else
                              PowerEvtState <= #TD `Event_SLP_S3n;
                 end
                 `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                     if (SLP_S3n == `CPUStateWorking)
                         if (!bFirstPwrUp)
                             PowerEvtState <= #TD `Event_PowerStandBy;
                         else
                             PowerEvtState <= #TD `Event_Reboot;
                     else
                         PowerEvtState <= #TD PowerEvtState;
                 end
                 `Event_PowerStandBy: begin // PwrEventState = 0x1
                     if (PowerbuttonIn == `PowerButtonRls)
                         if (BootUpRtyCnt != 2'b00)
                             PowerEvtState <= #TD `Event_Reboot;
                         else
                             PowerEvtState <= #TD PowerEvtState;
                     else if (CounterCnt < `EvtTimer_T20)
                              PowerEvtState <= #TD PowerEvtState;
                          else
                              PowerEvtState <= #TD `Event_SLP_S3n_UpChk;
                 end
                 `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                     // the power button has been press, check the SLP_S3#
                     if (CounterCnt < `EvtTimer_T1050)
                         PowerEvtState <= #TD PowerEvtState;
                     else if (CounterCnt >= `EvtTimer_T1050 && CounterCnt <= `EvtTimer_T2000)
                              if (SLP_S3n != `CPUStateWorking)
                                  PowerEvtState <= #TD PowerEvtState;
                              else
                                  PowerEvtState <= #TD `Event_Reboot;
                          else
                              PowerEvtState <= #TD `Event_PowerStandBy;
                          
                 end
                 `Event_Reboot: begin // PwrEventState = 0x2
                     if (CounterCnt < `EvtTimer_T5000)
                         if (PrvBiosLed == BiosLed)
                             PowerEvtState <= #TD PowerEvtState;
                         else
                             PowerEvtState <= #TD `Event_Wait2s;
                     else if (!ATX_PowerOK)
                              PowerEvtState <= #TD `Event_Wait2s;
                          else if (ALL_PWRGD)
                                   PowerEvtState <= #TD `Event_BiosPost_Wait;
                               else
                                   PowerEvtState <= #TD `Event_Wait2s;
                 end
                 `Event_BiosPost_Wait: begin // PwrEventState = 0xC
                     if (bBiosPostRdySig)
                         PowerEvtState <= #TD `Event_UpdatePwrSt;
                     else if (bEnterBiosSetUpMenu)
                              PowerEvtState <= #TD PowerEvtState;
                          else if (CounterCnt < `EvtTimer_T64000)
                                   if (PrvBiosLed == BiosLed)
                                       if (!SLP_S3n)
                                           if (!PowerbuttonIn)
                                               PowerEvtState <= #TD `Event_SystemReset;
                                           else
                                               PowerEvtState <= #TD `Event_Wait2s;
                                       else if (BiosPowerOff)
                                                PowerEvtState <= #TD `Event_Wait2s;
                                            else
                                                PowerEvtState <= #TD PowerEvtState;
                                   else
                                       PowerEvtState <= #TD `Event_Wait2s;
                               else
                                   PowerEvtState <= #TD `Event_Wait2s;
                 end
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                     if (CounterCnt < `EvtTimer_T1050)
                         PowerEvtState <= #TD PowerEvtState;
                     else if (!ATX_PowerOK)
                              PowerEvtState <= #TD `Event_Wait2s;
                          else if (ALL_PWRGD)
                                   PowerEvtState <= #TD `Event_SystemRun;
                               else
                                   PowerEvtState <= #TD `Event_Wait2s;
                 end
                 `Event_SystemRun: begin // PwrEventState = 0x4
                     if (Shutdown)
                         PowerEvtState <= #TD `Event_PowerDown;
                     else if (BiosPowerOff)
                              PowerEvtState <= #TD `Event_Wait2s;
                          else
                              case ({SLP_S3n, ATX_PowerOK})
                                  2'b00: PowerEvtState <= #TD `Event_SystemReset;
                                  2'b01: PowerEvtState <= #TD `Event_SystemReset;
                                  2'b10: PowerEvtState <= #TD `Event_PowerFail;
                                  2'b11: PowerEvtState <= #TD `Event_SystemRun;
                              endcase
                 end
                 `Event_SystemReset: begin // PwrEventState = 0x5
                     if (CounterCnt < `EvtTimer_T1050)
                         PowerEvtState <= #TD PowerEvtState;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T7000))
                              if (SLP_S3n == `CPUStateSleep)
                                  if (!PowerbuttonIn)
                                      PowerEvtState <= #TD `Event_Wait2s;
                                  else
                                      PowerEvtState <= #TD PowerEvtState;
                              else
                                  PowerEvtState <= #TD `Event_PowerCycle;
                          else
                              PowerEvtState <= #TD `Event_Wait2s;
                 end
                 `Event_PowerCycle: begin // PwrEventState = 0x6
                     if (CounterCnt < `EvtTimer_T3000)
                         if (SLP_S3n == `CPUStateWorking)
                             PowerEvtState <= #TD PowerEvtState;
                         else
                             PowerEvtState <= #TD `Event_Wait2s;
                     else
                         PowerEvtState <= #TD `Event_SystemRun;
                 end
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         PowerEvtState <= #TD PowerEvtState;
                     else if ((CounterCnt >= `EvtTimer_T2000) && (CounterCnt < `EvtTimer_T5000))
                              if (ATX_PowerOK)
                                  PowerEvtState <= #TD `Event_Wait2s;
                              else
                                  PowerEvtState <= #TD PowerEvtState;
                          else
                              PowerEvtState <= #TD `Event_Wait2s;    //`Event_SLP_S3n;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         PowerEvtState <= #TD PowerEvtState;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T5000)) begin
                              PowerEvtState <= #TD PowerEvtState;
                          end else if ((CounterCnt >= `EvtTimer_T5000) && (CounterCnt < `EvtTimer_T6000)) begin
                                       PowerEvtState <= #TD PowerEvtState;
                                   end else if ((CounterCnt >= `EvtTimer_T6000) && (CounterCnt < `EvtTimer_T8000)) begin
                                                 PowerEvtState <= #TD PowerEvtState;
                                             end else begin
                                                 PowerEvtState <= #TD `Event_Wait2s;
                                             end
                 end
                 // wait for power button release
                 `Event_Wait2s: begin // PwrEventState = 0x8
                     if (CounterCnt <`EvtTimer_T6000)
                         PowerEvtState <= #TD PowerEvtState;
                     else if (!bPwrFailUp)
                              PowerEvtState <= #TD `Event_PowerStandBy;
                          else
                              PowerEvtState <= #TD `Event_SLP_S3n;
                 end
                 default: PowerEvtState <= #TD `Event_PowerStandBy;
             endcase
         else
             PowerEvtState <= #TD PowerEvtState;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        PowerbuttonEvtOut <= #TD `PowerButtonRls;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x0
                     
                 `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                     if (SLP_S3n == `CPUStateWorking) begin
                         PowerbuttonEvtOut <= #TD PowerbuttonEvtOut;
                     end else if (CounterCnt < `EvtTimer_T1000)
                                  PowerbuttonEvtOut <= #TD `PowerButtonPress;
                              else if ((CounterCnt >= `EvtTimer_T1000) && (CounterCnt < `EvtTimer_T2000))
                                       PowerbuttonEvtOut <= #TD `PowerButtonRls;
                                   else
                                       PowerbuttonEvtOut <= #TD `PowerButtonRls;
                 end
                 `Event_PowerStandBy: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x1
                 `Event_SLP_S3n_UpChk: PowerbuttonEvtOut <= #TD PowerbuttonEvtOut; // PwrEventState = 0xB
                 `Event_Reboot: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x2
                 `Event_BiosPost_Wait: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0xC
                 `Event_UpdatePwrSt: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x3
                 `Event_SystemRun: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x4
                 `Event_SystemReset: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x5
                 `Event_PowerCycle: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x6
                 `Event_PowerFail: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x7
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         PowerbuttonEvtOut <= #TD `PowerButtonPress;  // push the power button to power off
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T5000))
                              PowerbuttonEvtOut <= #TD `PowerButtonPress;  // push the power button to power off
                          else if ((CounterCnt >= `EvtTimer_T5000) && (CounterCnt < `EvtTimer_T6000))
                                   PowerbuttonEvtOut <= #TD `PowerButtonRls;  // push the power button to power off
                               else if ((CounterCnt >= `EvtTimer_T6000) && (CounterCnt < `EvtTimer_T8000))
                                        PowerbuttonEvtOut <= #TD `PowerButtonRls;  // push the power button to power off
                                    else
                                        PowerbuttonEvtOut <= #TD `PowerButtonRls;  // push the power button to power off
                 end
                 // wait for power button release
                 `Event_Wait2s: PowerbuttonEvtOut <= #TD `PowerButtonRls; // PwrEventState = 0x8
                 default: PowerbuttonEvtOut <= #TD `PowerButtonRls;
             endcase
         else
             PowerbuttonEvtOut <= #TD PowerbuttonEvtOut;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        PS_ONn <= #TD `PwrSW_Off;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: PS_ONn <= #TD `PwrSW_Off; // PwrEventState = 0x0
                 `Event_SLP_S3n: PS_ONn <= #TD `PwrSW_Off; // PwrEventState <= #TD 0xA
                 `Event_PowerStandBy: PS_ONn <= #TD `PwrSW_Off; // PwrEventState = 0x1
                 `Event_SLP_S3n_UpChk: PS_ONn <= #TD PS_ONn; // PwrEventState = 0xB
                 `Event_Reboot: PS_ONn <= #TD `PwrSW_On; // PwrEventState = 0x2
                 `Event_BiosPost_Wait: PS_ONn <= #TD `PwrSW_On; // PwrEventState = 0xC
                 `Event_UpdatePwrSt: PS_ONn <= #TD `PwrSW_On; // PwrEventState = 0x3
                 `Event_SystemRun: PS_ONn <= #TD `PwrSW_On; // PwrEventState = 0x4
                 `Event_SystemReset: begin // PwrEventState = 0x5
                     if (CounterCnt < `EvtTimer_T1050)
                         PS_ONn <= #TD `PwrSW_On;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T7000))
                              PS_ONn <= #TD `PwrSW_Off;
                          else
                              PS_ONn <= #TD PS_ONn;
                 end
                 `Event_PowerCycle: PS_ONn <= #TD `PwrSW_On; // PwrEventState = 0x6
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         PS_ONn <= #TD `PwrSW_On;
                     else
                         PS_ONn <= #TD PS_ONn;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         PS_ONn <= #TD `PwrSW_On;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T5000))
                              PS_ONn <= #TD `PwrSW_On;
                          else if ((CounterCnt >= `EvtTimer_T5000) && (CounterCnt < `EvtTimer_T6000))
                                   PS_ONn <= #TD `PwrSW_On;
                               else if ((CounterCnt >= `EvtTimer_T6000) && (CounterCnt < `EvtTimer_T8000))
                                         PS_ONn <= #TD `PwrSW_Off;
                                     else
                                         PS_ONn <= #TD `PwrSW_Off;
                                     
                 end
                 // wait for power button release
                 `Event_Wait2s: PS_ONn <= #TD `PwrSW_Off; // PwrEventState = 0x8
                 default: PS_ONn <= #TD `PwrSW_Off;
             endcase
         else
             PS_ONn <= #TD PS_ONn;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bFlashPromReq <= #TD 1'b0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                     // the power button has been press, check the SLP_S3#
                     if (CounterCnt < `EvtTimer_T1050)
                         bFlashPromReq <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt <= `EvtTimer_T2000))
                              bFlashPromReq <= #TD 1'b0;
                          else
                              bFlashPromReq <= #TD bFlashPromReq;
                 end
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                     if (CounterCnt < `EvtTimer_T1050)
                         bFlashPromReq <= #TD 1'b1;
                     else
                         bFlashPromReq <= #TD 1'b0;
                 end
                 `Event_SystemReset: begin // PwrEventState = 0x5
                     if (CounterCnt < `EvtTimer_T1050)
                         bFlashPromReq <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T7000))
                              bFlashPromReq <= #TD 1'b0;
                          else
                              bFlashPromReq <= #TD bFlashPromReq;
                 end
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         if (CounterCnt < `EvtTimer_T40)
                             bFlashPromReq <= #TD bFlashPromReq;
                         else if ((CounterCnt >= `EvtTimer_T40) && (CounterCnt < `EvtTimer_T1060))
                                  if (!PwrLastStateRdBit)
                                      bFlashPromReq <= #TD bFlashPromReq;
                                  else 
                                      bFlashPromReq <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T2000) && (CounterCnt < `EvtTimer_T5000))
                              bFlashPromReq <= #TD 1'b0;
                          else
                              bFlashPromReq <= #TD 1'b0;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         bFlashPromReq <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T5000))
                              bFlashPromReq <= #TD 1'b0;
                          else
                              bFlashPromReq <= #TD bFlashPromReq;
                 end
                 default: bFlashPromReq <= #TD bFlashPromReq;
             endcase
         else
             bFlashPromReq <= #TD bFlashPromReq;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bRdPromCfg <= #TD 1'b0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: begin // PwrEventState = 0x0
                     if (CounterCnt < `EvtTimer_T100)
                         if (CounterCnt == `EvtTimer_T20)
                             bRdPromCfg <= #TD 1'b1;
                         else if (CounterCnt == `EvtTimer_T30)
                                  bRdPromCfg <= #TD 1'b0;
                              else
                                  bRdPromCfg <= #TD bRdPromCfg;
                     else
                         bRdPromCfg <= #TD bRdPromCfg;
                 end
                 `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                     // the power button has been press, check the SLP_S3#
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
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
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
                 `Event_SystemReset: begin // PwrEventState = 0x5
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
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         if (CounterCnt == `EvtTimer_T20)
                             bRdPromCfg <= #TD 1'b1;
                         else if (CounterCnt == `EvtTimer_T30)
                                  bRdPromCfg <= #TD 1'b0;
                              else if (CounterCnt == `EvtTimer_T1070)
                                       bRdPromCfg <= #TD 1'b1;
                                   else if (CounterCnt == `EvtTimer_T1080)
                                            bRdPromCfg <= #TD 1'b0;
                                        else
                                            bRdPromCfg <= #TD bRdPromCfg;
                     else
                         bRdPromCfg <= #TD bRdPromCfg;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
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
                 default: bRdPromCfg <= #TD bRdPromCfg;
             endcase
         else
             bRdPromCfg <= #TD bRdPromCfg;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bWrPromCfg <= #TD 1'b0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                     // the power button has been press, check the SLP_S3#
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
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
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
                 `Event_SystemReset: begin // PwrEventState = 0x5
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
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         if (CounterCnt == `EvtTimer_T50)
                             bWrPromCfg <= #TD 1'b1;
                         else if (CounterCnt == `EvtTimer_T1050)
                                  bWrPromCfg <= #TD 1'b0;
                              else
                                  bWrPromCfg <= #TD bWrPromCfg;
                     else
                         bWrPromCfg <= #TD bWrPromCfg;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         if (CounterCnt == `EvtTimer_T20)
                             bWrPromCfg <= #TD 1'b1;
                         else if (CounterCnt == `EvtTimer_T1020)
                                  bWrPromCfg <= #TD 1'b0;
                              else
                                  bWrPromCfg <= #TD bWrPromCfg;
                     else
                         bWrPromCfg <= #TD bWrPromCfg;
                 end                                             // end of Event_PowerDown
                 default: bWrPromCfg <= #TD bWrPromCfg;
             endcase
         else
             bWrPromCfg <= #TD bWrPromCfg;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        PwrLastStateWrBit <= #TD `PwrStateOk;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: begin // PwrEventState = 0x0
                     if (CounterCnt < `EvtTimer_T100)
                         PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                     else
                         PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                 end
                 `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                     // the power button has been press, check the SLP_S3#
                     if (CounterCnt < `EvtTimer_T1050)
                         PwrLastStateWrBit <= #TD `PwrStateFail;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt <= `EvtTimer_T2000))
                              PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                          else
                              PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                 end
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                     if (CounterCnt < `EvtTimer_T1050)
                         PwrLastStateWrBit <= #TD `PwrStateFail;
                     else
                         PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                 end
                 `Event_SystemReset: begin // PwrEventState = 0x5
                     if (CounterCnt < `EvtTimer_T1050)
                         PwrLastStateWrBit <= #TD `PwrStateOk;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T7000))
                              PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                          else
                              PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                 end
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         if (CounterCnt < `EvtTimer_T40)
                             PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                         else if ((CounterCnt >= `EvtTimer_T40) && (CounterCnt < `EvtTimer_T1060))
                                  if (!PwrLastStateRdBit)
                                      PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                                  else
                                      PwrLastStateWrBit <= #TD `PwrStateFail;
                              else
                                  PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                     else if ((CounterCnt >= `EvtTimer_T2000) && (CounterCnt < `EvtTimer_T5000))
                              PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                          else
                              PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         PwrLastStateWrBit <= #TD `PwrStateOk;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T5000))
                              PwrLastStateWrBit <= #TD PwrLastStateRdBit;
                          else
                              PwrLastStateWrBit <= #TD PwrLastStateWrBit;
                 end
                 default: PwrLastStateWrBit <= #TD PwrLastStateWrBit;
             endcase
         else
             PwrLastStateWrBit <= #TD PwrLastStateWrBit;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        CountState_N <= #TD 1'b0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: begin // PwrEventState = 0x0
                     if (CounterCnt < `EvtTimer_T100)
                         CountState_N <= #TD 1'b1;
                     else
                         CountState_N <= #TD 1'b0;
                 end
                 `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                     if (SLP_S3n == `CPUStateWorking)
                         CountState_N <= #TD 1'b0;
                     else if (CounterCnt < `EvtTimer_T1000)
                              CountState_N <= #TD 1'b1;
                          else if ((CounterCnt >= `EvtTimer_T1000) && (CounterCnt < `EvtTimer_T2000))
                                   CountState_N <= #TD 1'b1;
                               else
                                   CountState_N <= #TD 1'b0;
                 end
                 `Event_PowerStandBy: begin // PwrEventState = 0x1
                     if (PowerbuttonIn == `PowerButtonRls)
                         CountState_N <= #TD 1'b0;
                     else if (CounterCnt < `EvtTimer_T20) // press the power button
                              CountState_N <= #TD 1'b1;
                          else
                              CountState_N <= #TD 1'b0;
                 end
                 `Event_SLP_S3n_UpChk: begin // PwrEventState = 0xB
                     // the power button has been press, check the SLP_S3#
                     if (CounterCnt < `EvtTimer_T1050)
                         CountState_N <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt <= `EvtTimer_T2000))
                              if (SLP_S3n != `CPUStateWorking)
                                  CountState_N <= #TD 1'b1;
                              else
                                  CountState_N <= #TD 1'b0;
                          else
                              CountState_N <= #TD 1'b0;
                 end
                 `Event_Reboot: begin // PwrEventState = 0x2
                     if (CounterCnt < `EvtTimer_T5000)
                         if (PrvBiosLed == BiosLed)
                             CountState_N <= #TD 1'b1;
                         else
                             CountState_N <= #TD 1'b0;
                     else
                         CountState_N <= #TD 1'b0;
                 end
                 `Event_BiosPost_Wait: begin // PwrEventState = 0xC
                     if (bBiosPostRdySig)
                         CountState_N <= #TD 1'b0;
                     else if (bEnterBiosSetUpMenu)
                              CountState_N <= #TD 1'b0;
                          else if (CounterCnt < `EvtTimer_T64000)
                                   if (PrvBiosLed == BiosLed)
                                       if (!SLP_S3n)
                                           if (PowerbuttonIn == `PowerButtonPress)
                                               CountState_N <= #TD 1'b0;
                                           else
                                               CountState_N <= #TD 1'b0;
                                       else if (BiosPowerOff)
                                                CountState_N <= #TD 1'b0;
                                            else
                                                CountState_N <= #TD 1'b1;
                                   else
                                       CountState_N <= #TD 1'b0;
                               else
                                   CountState_N <= #TD 1'b0;
                 end
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                     if (CounterCnt < `EvtTimer_T1050)
                         CountState_N <= #TD 1'b1;
                     else
                         CountState_N <= #TD 1'b0;
                 end
                 `Event_SystemRun: CountState_N <= #TD 1'b0; // PwrEventState = 0x4
                 `Event_SystemReset: begin // PwrEventState = 0x5
                     if (CounterCnt < `EvtTimer_T1050)
                         CountState_N <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T1050) && (CounterCnt < `EvtTimer_T7000))
                              if (SLP_S3n == `CPUStateSleep)
                                  if (PowerbuttonIn == `PowerButtonPress)
                                      CountState_N <= #TD 1'b0;
                                  else
                                      CountState_N <= #TD 1'b1;
                              else
                                  CountState_N <= #TD 1'b0;
                          else
                              CountState_N <= #TD 1'b0;
                 end
                 `Event_PowerCycle: begin // PwrEventState = 0x6
                     if (CounterCnt < `EvtTimer_T3000)
                         if (SLP_S3n == `CPUStateWorking)
                             CountState_N <= #TD 1'b1;
                         else
                             CountState_N <= #TD 1'b0;
                     else
                         CountState_N <= #TD 1'b0;
                 end
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         CountState_N <= #TD 1'b1;
                     else if ((CounterCnt >= `EvtTimer_T2000) && (CounterCnt < `EvtTimer_T5000))
                              if (ATX_PowerOK) // AC restored, reboot the system
                                  CountState_N <= #TD 1'b0;
                              else
                                  CountState_N <= #TD CountState_N;
                          else
                              CountState_N <= #TD 1'b0;
                 end
                 `Event_PowerDown: begin // PwrEventState = 0x9
                     if (CounterCnt < `EvtTimer_T1050)
                         CountState_N <= #TD 1'b1;
                     else if (CounterCnt <= `EvtTimer_T8000)
                              CountState_N <= #TD CountState_N;
                          else
                              CountState_N <= #TD 1'b0;
                 end
                 // wait for power button release
                 `Event_Wait2s: begin // PwrEventState = 0x8
                     if (CounterCnt < `EvtTimer_T6000)
                         CountState_N <= #TD 1'b1;
                     else // over 2 sec.
                         CountState_N <= #TD 1'b0;
                 end
                 default: CountState_N <= #TD 1'b0;
             endcase
         else
             CountState_N <= #TD CountState_N;
end
                         
always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        BootUpRtyCnt <= #TD 2'd0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: BootUpRtyCnt <= #TD 2'd0; // PwrEventState = 0x0
                 `Event_PowerStandBy: begin // PwrEventState = 0x1
                     if (PowerbuttonIn == `PowerButtonRls)
                         BootUpRtyCnt <= #TD BootUpRtyCnt;
                     else
                         BootUpRtyCnt <= #TD 2'd0;
                 end
                 `Event_Reboot: begin // PwrEventState = 0x2
                     if (CounterCnt < `EvtTimer_T5000)
                         if (PrvBiosLed == BiosLed)
                             BootUpRtyCnt <= #TD BootUpRtyCnt;
                         else
                             BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                     else if (!ATX_PowerOK)
                              BootUpRtyCnt <= #TD 2'd1;
                          else if (ALL_PWRGD)
                                   BootUpRtyCnt <= #TD BootUpRtyCnt;
                               else if (!bFirstPwrUp)
                                        BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                    else
                                        BootUpRtyCnt <= #TD 2'd1;
                 end
                 `Event_BiosPost_Wait: begin // PwrEventState = 0xC
                     if (bBiosPostRdySig)
                         BootUpRtyCnt <= #TD BootUpRtyCnt;
                     else if (bEnterBiosSetUpMenu)
                              BootUpRtyCnt <= #TD BootUpRtyCnt;
                          else if (CounterCnt < `EvtTimer_T64000)
                                   if (PrvBiosLed == BiosLed)
                                       if (!SLP_S3n)
                                         if (PowerbuttonIn == `PowerButtonPress)
                                             BootUpRtyCnt <= #TD 2'd0;
                                         else
                                             BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                       else if (BiosPowerOff)
                                                BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                                            else
                                                BootUpRtyCnt <= #TD BootUpRtyCnt;
                                   else
                                       BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                               else
                                   BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                 end
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                     if (CounterCnt < `EvtTimer_T1050)
                         BootUpRtyCnt <= #TD BootUpRtyCnt;
                     else if (!ATX_PowerOK)
                              BootUpRtyCnt <= #TD 2'd1;
                          else
                              BootUpRtyCnt <= #TD BootUpRtyCnt;
                 end
                 `Event_SystemRun: begin
                     if (Shutdown)
                         BootUpRtyCnt <= #TD 2'd0; // PwrEventState = 0x4
                     else if (BiosPowerOff)
                              BootUpRtyCnt <= #TD BootUpRtyCnt + 2'd1;
                          else
                              BootUpRtyCnt <= #TD 2'd0; // PwrEventState = 0x4
                 end
                 `Event_PowerCycle: begin // PwrEventState = 0x6
                    if (CounterCnt < `EvtTimer_T3000)
                        if (`CPUStateWorking == SLP_S3n)
                            BootUpRtyCnt <= #TD BootUpRtyCnt;
                        else
                            BootUpRtyCnt <= #TD 2'd1;
                    else
                        BootUpRtyCnt <= #TD BootUpRtyCnt;
                end
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         BootUpRtyCnt <= #TD BootUpRtyCnt;
                     else if ((CounterCnt >= `EvtTimer_T2000) && (CounterCnt < `EvtTimer_T5000))
                              if (ATX_PowerOK) // AC restored, reboot the system
                                  BootUpRtyCnt <= #TD 2'd1;
                              else
                                  BootUpRtyCnt <= #TD BootUpRtyCnt;
                          else
                              BootUpRtyCnt <= #TD BootUpRtyCnt;
                 end
                 default: BootUpRtyCnt <= #TD BootUpRtyCnt;
             endcase
         else
             BootUpRtyCnt <= #TD BootUpRtyCnt;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bFirstPwrUp <= #TD 1'b1;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: begin // PwrEventState = 0x0
                     if (CounterCnt < `EvtTimer_T100)
                         bFirstPwrUp <= #TD bFirstPwrUp;
                     else if (PwrLastStateRdBit == `PwrStateOk)
                              bFirstPwrUp <= #TD 1'b0;
                          else
                              bFirstPwrUp <= #TD 1'b1;
                 end
                 `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                     if (SLP_S3n == `CPUStateWorking)
                         if (!bFirstPwrUp)
                             bFirstPwrUp <= #TD bFirstPwrUp;
                         else
                             bFirstPwrUp <= #TD 1'b0;
                     else
                         bFirstPwrUp <= #TD bFirstPwrUp;
                 end
                 `Event_Reboot: begin // PwrEventState = 0x2
                     if (CounterCnt < `EvtTimer_T5000)
                         bFirstPwrUp <= #TD bFirstPwrUp;
                     else if (!ATX_PowerOK)
                              bFirstPwrUp <= #TD bFirstPwrUp;
                          else if (ALL_PWRGD)
                                   bFirstPwrUp <= #TD bFirstPwrUp;
                               else if (!bFirstPwrUp)
                                        bFirstPwrUp <= #TD bFirstPwrUp;
                                    else
                                        bFirstPwrUp <= #TD 1'b0;
                 end
                 default: bFirstPwrUp <= #TD bFirstPwrUp;
             endcase
         else
             bFirstPwrUp <= #TD bFirstPwrUp;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        PrvBiosLed <= #TD 2'd0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: PrvBiosLed <= #TD BiosLed; // PwrEventState = 0x0
                 `Event_SLP_S3n: begin // PwrEventState <= #TD 0xA
                     if (SLP_S3n == `CPUStateWorking)
                         PrvBiosLed <= #TD BiosLed;
                     else
                         PrvBiosLed <= #TD PrvBiosLed;
                 end
                 `Event_PowerStandBy: PrvBiosLed <= #TD BiosLed; // PwrEventState = 0x1
                 `Event_Reboot: begin // PwrEventState = 0x2
                     if (CounterCnt < `EvtTimer_T5000)
                         if (PrvBiosLed == BiosLed)
                             PrvBiosLed <= #TD PrvBiosLed;
                         else
                             PrvBiosLed <= #TD BiosLed;
                     else
                         PrvBiosLed <= #TD PrvBiosLed;
                 end
                 `Event_BiosPost_Wait: begin // PwrEventState = 0xC
                     if (bBiosPostRdySig)
                         PrvBiosLed <= #TD PrvBiosLed;
                     else if (bEnterBiosSetUpMenu)
                              PrvBiosLed <= #TD PrvBiosLed;
                          else if (CounterCnt < `EvtTimer_T64000)
                                   if (PrvBiosLed == BiosLed)
                                       PrvBiosLed <= #TD PrvBiosLed;
                                   else
                                       PrvBiosLed <= #TD BiosLed;
                               else
                                   PrvBiosLed <= #TD PrvBiosLed;
                 end
                 default: PrvBiosLed <= #TD PrvBiosLed;
             endcase
         else
             PrvBiosLed <= #TD PrvBiosLed;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        bPwrFailUp <= #TD 1'b0;
    else if (Strobe1ms) // polling PwrEventState every 1ms after ResetN de-assertion
             case (PowerEvtState) // There are 13 PwrEventStates for polling cases
                 `Event_InitPowerUp: bPwrFailUp <= #TD 1'b0; // PwrEventState = 0x0
                 `Event_SLP_S3n: bPwrFailUp <= #TD 1'b0; // PwrEventState <= #TD 0xA
                 `Event_PowerStandBy: bPwrFailUp <= #TD 1'b0; // PwrEventState = 0x1
                 `Event_Reboot: begin // PwrEventState = 0x2
                     if (CounterCnt < `EvtTimer_T5000)
                         bPwrFailUp <= #TD bPwrFailUp;
                     else if (!ATX_PowerOK)
                              bPwrFailUp <= #TD 1'b1;
                          else
                              bPwrFailUp <= #TD bPwrFailUp;
                 end
                 `Event_UpdatePwrSt: begin // PwrEventState = 0x3
                     if (CounterCnt < `EvtTimer_T1050)
                         bPwrFailUp <= #TD bPwrFailUp;
                     else if (!ATX_PowerOK)
                              bPwrFailUp <= #TD 1'b1;
                          else
                              bPwrFailUp <= #TD bPwrFailUp;
                 end
                 `Event_PowerFail: begin // PwrEventState = 0x7
                     if (CounterCnt < `EvtTimer_T2000)
                         bPwrFailUp <= #TD bPwrFailUp;
                     else if ((CounterCnt > `EvtTimer_T2000) && (CounterCnt < `EvtTimer_T5000))
                              if (ATX_PowerOK) // AC restored, reboot the system
                                  bPwrFailUp <= #TD 1'b1;
                              else
                                  bPwrFailUp <= #TD bPwrFailUp;
                          else
                              bPwrFailUp <= #TD bPwrFailUp;
                 end
                 // wait for power button release
                 `Event_Wait2s: begin // PwrEventState = 0x8
                     if (CounterCnt < `EvtTimer_T6000)
                         bPwrFailUp <= #TD bPwrFailUp;
                     else if (!bPwrFailUp) // over 2 sec.
                              bPwrFailUp <= #TD bPwrFailUp;
                          else
                              bPwrFailUp <= #TD 1'b0;
                 end
                 default: bPwrFailUp <= #TD bPwrFailUp;
             endcase
         else
             bPwrFailUp <= #TD bPwrFailUp;
end

always @ (posedge CLK32768 or negedge ResetN) begin
    if (!ResetN)
        CounterCnt <= #TD 16'd0;
    else if (!Strobe1ms_d0)
             if (CountState)
                 if (!CountState_N)
                     CounterCnt <= #TD 16'd0;
                 else
                     CounterCnt <= #TD CounterCnt;
             else
                 CounterCnt <= #TD CounterCnt;
         else if (CountState_N)
                  CounterCnt <= #TD CounterCnt + 16'd1;
              else
                  CounterCnt <= #TD 16'd0;
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
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule // PwrEvent
