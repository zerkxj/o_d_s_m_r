//******************************************************************************
// File name        : Led.v
// Module name      : Led
// Description      : System LED, FAN LED...
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`define PSULedOff 2'b11
`define PSULedRed 2'b10
`define PSULedGreen 2'b01

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module LED (
    SlowClock,              // In, Oscillator Clock 32,768 Hz
    Reset_N,                // In, reset
    Strobe16ms,             // In, Single SlowClock Pulse @ 16 ms
    Beep,                   // In, Fan Fail - 1, FanOK - 0; - has internal weak P/U
    FanLedCtrlReg,          // In, Fan LED control register
    FM_PS_EN,               // In,
    DualPS,                 // In, Dual power supply
    ALL_PWRGD,              // In,
    PSUFan_StReg,           // In, Power supply FAN status register
    ZippyStatus,            // In,
    SystemOK,               // In, System OK from regiser
    PowerSupplyOK,          // In,
    BiosStatusCurrent,      // In, current BIOS status
    PSU1_Tach_Low,          // In,
    PSU1_Tach_High,         // In,
    PActivity,              // In,
    Speed1P,                // In,
    Speed2P,                // In,

    SYS_LEDG_N,             // Out,
    SYS_LEDR_N,             // Out,
    BIOS_LED_N,             // Out, BIOS LED
    PSU_Normal_N,           // Out,
    PSU_Fail_N,             // Out,
    FAN_LEDG_N,             // Out,
    FAN_LEDR_N,             // Out,
    CPLD_LAN_LINK1000_N,    // Out, LAN LINK 1000 LED
    CPLD_LAN_LINK100_N,     // Out, LAN LINK 100 LED
    CPLD_LAN_ACT_N          // Out, LAN ACTIVE LED
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
input           SlowClock;
input           Reset_N;
input           Strobe16ms;
input           Beep;
input   [3:0]   FanLedCtrlReg;
input           FM_PS_EN;
input           DualPS;
input           ALL_PWRGD;
input   [7:0]   PSUFan_StReg;
input   [2:1]   ZippyStatus;
input           SystemOK;
input           PowerSupplyOK;
input           BiosStatusCurrent;
input           PSU1_Tach_Low;
input           PSU1_Tach_High;
input   [1:0]   PActivity;
input   [1:0]   Speed1P;
input   [1:0]   Speed2P;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output          SYS_LEDG_N;
output          SYS_LEDR_N;
output  [1:0]   BIOS_LED_N;
output  [1:0]   PSU_Normal_N;
output  [1:0]   PSU_Fail_N;
output          FAN_LEDG_N;
output          FAN_LEDR_N;
output  [1:0]   CPLD_LAN_LINK1000_N;
output  [1:0]   CPLD_LAN_LINK100_N;
output  [1:0]   CPLD_LAN_ACT_N;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            FanFail;
wire            FanOK;

wire    [1:0]   Speed1R;
wire    [1:0]   Speed2R;
wire    [1:0]   RActivity;

//--------------------------------------------------------------------------
// Reg declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational
//----------------------------------------------------------------------
//------------------------------------------------------------------
// Output
//------------------------------------------------------------------
assign SYS_LEDG_N = (FM_PS_EN == `PwrSW_On) ? SystemOK : 1'b1;
assign SYS_LEDR_N = (FM_PS_EN == `PwrSW_On) ? !SystemOK : 1'b1;
assign BIOS_LED_N[0] = BiosStatusCurrent;
assign BIOS_LED_N[1] = ~BiosStatusCurrent;
assign PSU_Normal_N = (FM_PS_EN == `PwrSW_On) ? PowerNormal : 2'b11;
assign PSU_Fail_N = (FM_PS_EN == `PwrSW_On) ? PowerFail : 2'b11;
assign FAN_LEDG_N = (FM_PS_EN == `PwrSW_On) ? FanFail : 1'b1;
assign FAN_LEDR_N = (FM_PS_EN == `PwrSW_On) ? FanOK : 1'b1;
assign CPLD_LAN_LINK1000_N = (FM_PS_EN == `PwrSW_On) ? Speed1R : 2'b11;
assign CPLD_LAN_LINK100_N = (FM_PS_EN == `PwrSW_On) ? Speed2R : 2'b11;
assign CPLD_LAN_ACT_N = (FM_PS_EN == `PwrSW_On) ? RActivity : 2'b11;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [2:1]   PowerNormal;
reg     [2:1]   PowerFail;

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
// None

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
// None

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
// None

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (DualPS or PSUFan_StReg[0] or PSUFan_StReg[4] or PSUFan_StReg[6] or
          ZippyStatus[1] or PowerSupplyOK or PSU1_Tach_Low or PSU1_Tach_High) begin
    if (DualPS)
        if (PSUFan_StReg[0])
            if (PSUFan_StReg[4])
                {PowerNormal[1], PowerFail[1]} = `PSULedOff;
            else if (!PSUFan_StReg[6])
                     {PowerNormal[1], PowerFail[1]} = `PSULedRed;
                 else if (!ZippyStatus[1])
                          {PowerNormal[1], PowerFail[1]} = `PSULedRed;
                      else
                          {PowerNormal[1], PowerFail[1]} = `PSULedGreen;
        else if (ZippyStatus[1])
                 {PowerNormal[1], PowerFail[1]} = `PSULedGreen;
             else
                 {PowerNormal[1], PowerFail[1]} = `PSULedRed;
    else if (PSUFan_StReg[0])
             if (PSUFan_StReg[4])
                 {PowerNormal[1], PowerFail[1]} = `PSULedOff;
             else if (!PSUFan_StReg[6])
                      {PowerNormal[1], PowerFail[1]} = `PSULedRed;
                  else if (!ZippyStatus[1])
                           {PowerNormal[1], PowerFail[1]} = `PSULedRed;
                       else
                           {PowerNormal[1], PowerFail[1]} = `PSULedGreen;
         else if (ZippyStatus[1])
                  {PowerNormal[1], PowerFail[1]} = `PSULedGreen;
              else if (!PowerSupplyOK)
                       {PowerNormal[1], PowerFail[1]} = `PSULedRed;
                   else if (PSUFan_StReg[6] && ({PSU1_Tach_Low, PSU1_Tach_High} == 2'b00))
                            {PowerNormal[1], PowerFail[1]} = `PSULedGreen;
                        else
                            {PowerNormal[1], PowerFail[1]} = `PSULedRed;
end

always @ (DualPS or PSUFan_StReg[0] or PSUFan_StReg[5] or PSUFan_StReg[7] or
          ZippyStatus[2]) begin
    if (!DualPS)
        if (!PSUFan_StReg[0])
            {PowerNormal[2], PowerFail[2]} = `PSULedOff;
        else if (!PSUFan_StReg[5])
                 {PowerNormal[2], PowerFail[2]} = `PSULedOff;
             else if (!PSUFan_StReg[7])
                      {PowerNormal[2], PowerFail[2]} = `PSULedRed;
                  else if (ZippyStatus[2])
                           {PowerNormal[2], PowerFail[2]} = `PSULedRed;
                       else
                           {PowerNormal[2], PowerFail[2]} = `PSULedGreen;
    else if (!PSUFan_StReg[0])
             if (!ZippyStatus[2])
                 {PowerNormal[2], PowerFail[2]} = `PSULedRed;
             else
                 {PowerNormal[2], PowerFail[2]} = `PSULedGreen;
         else if (PSUFan_StReg[5])
                  {PowerNormal[2], PowerFail[2]} = `PSULedOff;
              else if (!PSUFan_StReg[7])
                       {PowerNormal[2], PowerFail[2]} = `PSULedRed;
                   else if (!ZippyStatus[2])
                            {PowerNormal[2], PowerFail[2]} = `PSULedRed;
                        else
                            {PowerNormal[2], PowerFail[2]} = `PSULedGreen;
end


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
// None

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
FanLED
    u_FanLED (.SlowClock(SlowClock),            // In, Oscillator Clock 32,768 Hz
              .Reset_N(Reset_N),                // In, reset
              .Strobe16ms(Strobe16ms),          // In, Single SlowClock Pulse @ 16 ms
              .Beep(Beep),                      // In, Fan Fail - 1, FanOK - 0; - has internal weak P/U
              .FanLedCtrlReg(FanLedCtrlReg),    // In, Fan LED control register
              .FanFail(FanFail),                // Out, Fan Led indication
              .FanOK(FanOK));                   // Out, Fan Led indication

LanLED
    u_LanLED (.ALL_PWRGD(ALL_PWRGD),    // In, ALL POWER GOOD
              .PActivity(PActivity),    // In, ACT#      signal from LAN controller
              .Speed1P(Speed1P),        // In, LINK1000# signal from LAN controller
              .Speed2P(Speed2P),        // In, LINK100#  signal from LAN controller
              .Speed1R(Speed1R),        // Out, LINK1000# output to BiColor LED
              .Speed2R(Speed2R),        // Out, LINK100#  output to BiColor LED
              .RActivity(RActivity));   // Out, ACT#      output to LED

endmodule

