//******************************************************************************
// File name        : LpcReg.v
// Module name      : LpcReg
// Description      : This module is LPC  register
// Hierarchy Up     : Lpc
// Hierarchy Down   : None
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None
`include "../Verilog/Includes/DefineODSTextMacro.v"

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module LpcReg (
    PciReset,       // In, reset
    LpcClock,       // In, 33 MHz Lpc (LPC Clock)
    Addr,           // In, register address
    Wr,             // In, write operation
    DataWrSW,       // In, write data from SW
    BiosStatus,     // In, BIOS status setup value
    IntReg,         // In, Interrupt register setup value
    FAN_PRSNT_N,    // In, FAN present status

    DataReg,        // Out, Register data
    SystemOK,       // Out, System OK flag(software control)
    x7SegSel,       // Out, 7 segment LED select
    x7SegVal,       // Out, 7 segment LED value
    BiosRegister,   // Out, BIOS watch dog register
    IntRegister,    // Out, Interrupt register
    FanLedCtrl,     // Out, Fan LED control register
    PSUFan_St,      // Out, PSU Fan state register
    SpecialCmdReg   // Out, SW controled power shutdown register
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
int loop;
int k;

//------------------------------------------------------------------------------
// Input/Output declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Input declaration
//--------------------------------------------------------------------------
input           PciReset;
input           LpcClock;
input   [7:0]   Addr;
input           Wr;
input   [7:0]   DataWrSW;
input   [2:0]   BiosStatus;
input   [6:4]   IntReg;
input   [2:0]   FAN_PRSNT_N;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [7:0]   DataReg [31:0];
output          SystemOK;
output  [4:0]   x7SegSel;
output  [7:0]   x7SegVal;
output  [7:0]   BiosRegister;
output  [7:0]   IntRegister;
output  [3:0]   FanLedCtrl;
output  [7:0]   PSUFan_St;
output  [7:0]   SpecialCmdReg;

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
reg     [7:0]   DataWr;
reg     [7:0]   DataWrHW    [31:0];

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
reg     [7:0]   DataReg [31:0];

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
function [7:0] ResetValue(input [7:0] addr,
                          input [2:0] BiosStatus);

    case (addr)
        8'h00: ResetValue = {`FPGAID_CODE , `VERSION_CODE};
        8'h01: ResetValue = 8'h55; // R/W ( for Offset 0x01 ~ 0x1F )
        8'h02: ResetValue = 8'hAA;
        8'h03: ResetValue = 8'h66;
        8'h04: ResetValue = {5'h00, BiosStatus};
        8'h05: ResetValue = 8'h77;
        8'h06: ResetValue = 8'h88;
        8'h07: ResetValue = 8'h44;
        8'h08: ResetValue = 8'hBB;
        8'h09: ResetValue = 8'h33;
        8'h0a: ResetValue = 8'hCC;
        8'h0b: ResetValue = 8'h22;
        8'h0c: ResetValue = 8'hDD;
        8'h0d: ResetValue = 8'h11;
        8'h0e: ResetValue = 8'hEE;
        8'h0f: ResetValue = 8'h00;
        8'h10: ResetValue = 8'hFF;
        8'h11: ResetValue = 8'h55;
        8'h12: ResetValue = 8'hAA;
        8'h13: ResetValue = 8'h66;
        8'h14: ResetValue = 8'h99;
        8'h15: ResetValue = 8'h77;
        8'h16: ResetValue = 8'h88;
        8'h17: ResetValue = 8'h44;
        8'h18: ResetValue = 8'hBB;
        8'h19: ResetValue = 8'h33;
        8'h1a: ResetValue = 8'hCC;
        8'h1b: ResetValue = 8'h22;
        8'h1c: ResetValue = 8'hDD;
        8'h1d: ResetValue = 8'h11;
        8'h1e: ResetValue = 8'hEE;
        8'h1f: ResetValue = 8'h5A;
        default: ResetValue = 8'h00;
    endcase

endfunction

function [7:0] DataMask(input [7:0] Addr,
                        input [7:0] DataWr,
                        input [7:0] DataReg);

    reg [7:0]   MaskWr;

    case (Addr)
        8'h00: MaskWr = 8'h00;
        8'h04: MaskWr = 8'h1B;
        8'h08: MaskWr = 8'h40;
        8'h09: MaskWr = 8'h7F;
        8'h0A: MaskWr = 8'hF1;
        8'h0B: MaskWr = 8'h1F;
        8'h0C: MaskWr = 8'h00;
        8'h0E: MaskWr = 8'h1F;
        8'h10: MaskWr = 8'h00;
        8'h11: MaskWr = 8'h01;
        8'h13: MaskWr = 8'h00;
        8'h19: MaskWr = 8'h00;
        8'h1E: MaskWr = 8'h30;
        default: MaskWr = 8'hFF;
    endcase

    DataMask = (MaskWr & DataWr) | ((~MaskWr) & DataReg);

endfunction

//------------------------------------------------------------------------------
// Main code
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Combinational circuit
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Output
//----------------------------------------------------------------------
assign SystemOK = DataReg[8][6];
assign x7SegSel = DataReg[14][4:0];
assign x7SegVal = DataReg[15];
assign BiosRegister = DataReg[1];
assign IntRegister = DataReg[9];
assign FanLedCtrl = DataReg[27][3:0];
assign PSUFan_St = DataReg[10];
assign SpecialCmdReg = DataReg[24];

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (Addr or DataWrSW or IntReg or FAN_PRSNT_N) begin
    case (Addr)
        8'h09: DataWr = {DataWrSW[7], IntReg, DataWrSW[3:0]};
        8'h0C: DataWr = {DataWrSW[7:4], FAN_PRSNT_N, (&FAN_PRSNT_N)};
        default: DataWr = DataWrSW;
    endcase
end

always @ (DataReg[k] or IntReg) begin
    for (loop=0; loop<32; loop=loop+1)
        case (loop)
            8'h09: DataWrHW[loop] = {DataReg[loop][7], IntReg,
                                     DataReg[loop][3:0]};
            default: DataWrHW[loop] = DataReg[loop];
        endcase
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
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        for (loop=0; loop<32; loop=loop+1)
            DataReg[loop] <= ResetValue(loop, BiosStatus);
    else
        for (loop=0; loop<32; loop=loop+1) begin
            if (Wr)
                if (Addr == loop)
                    DataReg[loop] <= DataMask(loop, DataWr, DataReg[loop]);
                else
                    DataReg[loop] <= DataWrHW[loop];
            else
                DataReg[loop] <= DataWrHW[loop];
        end
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

endmodule
