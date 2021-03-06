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
`include "../Verilog/Includes/DefineODSTextMacro.v"

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module LpcReg (
    PciReset,           // In, reset
    LpcClock,           // In, 33 MHz Lpc (LPC Clock)
    Addr,               // In, register address
    Wr,                 // In, write operation
    Rd,                 // In, read operation
    DataWrSW,           // In, write data from SW
    BiosStatus,         // In, BIOS status setup value
    IntReg,             // In, Interrupt register setup value
    FAN_PRSNT_N,        // In, FAN present status
    BIOS_SEL,           // In, force select BIOS
    DME_PRSNT,          // In, DME present
    JP4,                // In, jumper 4, for future use
    PSU_status,         // In, power supply status
    Dual_Supply,        // In, Dual Supply status, save in SPI FLASH
    FlashAccess,        // In, Flash access(R/W)
    WatchDogOccurred,   // In, occurr watch dog reset
    WatchDogIREQ,       // In, watch dog interrupt request
    DMEStatus,          // In, DME status

    BiosWDReg,      // Out, BIOS watch dog register
    LBCF,           // Out, Lock BIOS Chip Flag
    SystemOK,       // Out, System OK flag(software control)
    IntRegister,    // Out, Interrupt register
    PSUFan_St,      // Out, PSU Fan state register
    WatchDogReg,    // Out, Watch Dog register
    x7SegSel,       // Out, 7 segment LED select
    x7SegVal,       // Out, 7 segment LED value
    DMEControl,     // Out, DME Control
    SpecialCmdReg,  // Out, SW controled power shutdown register
    FanLedCtrl,     // Out, Fan LED control register
    DataReg         // Out, Register data
);

//------------------------------------------------------------------------------
// Parameter declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// User defined parameter
//--------------------------------------------------------------------------
parameter CARD_TYPE = `NCC;

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
input           Rd;
input   [7:0]   DataWrSW;
input   [2:0]   BiosStatus;
input   [6:4]   IntReg;
input   [2:0]   FAN_PRSNT_N;
input           BIOS_SEL;
input           DME_PRSNT;
input           JP4;
input   [5:4]   PSU_status;
input           Dual_Supply;
input           FlashAccess;
input           WatchDogOccurred;
input           WatchDogIREQ;
input   [5:0]   DMEStatus;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [7:0]   BiosWDReg;
output          LBCF;
output          SystemOK;
output  [7:0]   IntRegister;
output  [7:0]   PSUFan_St;
output  [7:0]   WatchDogReg;
output  [4:0]   x7SegSel;
output  [7:0]   x7SegVal;
output  [5:0]   DMEControl;
output  [7:0]   SpecialCmdReg;
output  [3:0]   FanLedCtrl;
output  [7:0]   DataReg [31:0];

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            RdClrRegWDC; // read clear Watch Dog Control register

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
                          input [2:0] BiosStatus,
                          input BIOS_SEL,
                          input JP4,
                          input [5:4] PSU_status,
                          input Dual_Supply,
                          input DME_PRSNT,
                          input [5:0] DMEStatus);

    case (addr)
        8'h00: ResetValue = {`FPGAID_CODE , `VERSION_CODE};
        8'h01: ResetValue = 8'hAA; // R/W ( for Offset 0x01 ~ 0x1F )
        8'h02: ResetValue = 8'hAA;
        8'h03: ResetValue = 8'h66;
        8'h04: ResetValue = {5'h00, BiosStatus};
        8'h05: ResetValue = 8'h77;
        8'h06: ResetValue = 8'h88;
        8'h07: ResetValue = 8'h44;
        8'h08: ResetValue = {Dual_Supply, 1'b0, PSU_status, 2'h0, JP4,
                             BIOS_SEL};
        8'h09: ResetValue = 8'h00;
        8'h0A: ResetValue = 8'hC0;
        8'h0B: ResetValue = 8'h00;
        8'h0C: ResetValue = 8'h00;
        8'h0D: ResetValue = 8'h11;
        8'h0E: ResetValue = 8'h00;
        8'h0F: ResetValue = 8'h00;
        8'h10: ResetValue = {3'h0, CARD_TYPE, DME_PRSNT};
        8'h11: ResetValue = 8'h00;
        8'h12: ResetValue = 8'h00;
        8'h13: ResetValue = {2'h0, DMEStatus};
        8'h14: ResetValue = 8'h99;
        8'h15: ResetValue = 8'h77;
        8'h16: ResetValue = 8'h88;
        8'h17: ResetValue = 8'h44;
        8'h18: ResetValue = 8'h00;
        8'h19: ResetValue = 8'h01;
        8'h1A: ResetValue = 8'hCC;
        8'h1B: ResetValue = 8'h00;
        8'h1C: ResetValue = 8'hDD;
        8'h1D: ResetValue = 8'h11;
        8'h1E: ResetValue = 8'h00;
        8'h1F: ResetValue = 8'h5A;
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
        8'h12: MaskWr = 8'h3F;
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
assign BiosWDReg = DataReg[1];
assign LBCF = DataReg[4][4];
assign SystemOK = DataReg[8][6];
assign IntRegister = DataReg[9];
assign PSUFan_St = DataReg[10];
assign WatchDogReg = DataReg[11];
assign x7SegSel = DataReg[14][4:0];
assign x7SegVal = DataReg[15];
assign DMEControl = DataReg[18][5:0];
assign SpecialCmdReg = DataReg[24];
assign FanLedCtrl = DataReg[27][3:0];

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign RdClrRegWDC = Rd & (Addr == 8'h0B);

always @ (Addr or DataWrSW or IntReg or DataReg[k] or WatchDogOccurred or
          RdClrRegWDC or WatchDogIREQ or FAN_PRSNT_N) begin
    case (Addr)
        8'h09: DataWr = {DataWrSW[7], IntReg, DataWrSW[3:0]};
        8'h0B: DataWr = {DataReg[9][2], (WatchDogOccurred & (!RdClrRegWDC)),
                         WatchDogIREQ, DataWrSW[4:0]};
        8'h0C: DataWr = {DataWrSW[7:3], ~FAN_PRSNT_N};
        default: DataWr = DataWrSW;
    endcase
end

always @ (DataReg[k] or Dual_Supply or PSU_status or JP4 or BIOS_SEL or IntReg
          or WatchDogOccurred or RdClrRegWDC or WatchDogIREQ or FAN_PRSNT_N or
          DMEStatus or FlashAccess) begin
    for (loop=0; loop<32; loop=loop+1)
        case (loop)
            8'h08: DataWrHW[loop] = {Dual_Supply, DataReg[loop][6],
                                     (~PSU_status), DataReg[loop][3:2], JP4,
                                     BIOS_SEL};
            8'h09: DataWrHW[loop] = {DataReg[loop][7], IntReg,
                                     DataReg[loop][3:0]};
            8'h0B: DataWrHW[loop] = {DataReg[9][2],
                                     (WatchDogOccurred & (!RdClrRegWDC)),
                                     WatchDogIREQ, DataReg[loop][4:0]};
            8'h0C: DataWrHW[loop] = {DataReg[loop][7:3], ~FAN_PRSNT_N};
            8'h13: DataWrHW[loop] = {2'h0, DMEStatus};
            8'h19: DataWrHW[loop] = {7'h00, FlashAccess};
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
            DataReg[loop] <= #TD ResetValue(loop,
                                            BiosStatus,
                                            BIOS_SEL,
                                            JP4,
                                            PSU_status,
                                            Dual_Supply,
                                            DME_PRSNT,
                                            DMEStatus);
    else
        for (loop=0; loop<32; loop=loop+1) begin
            if (Wr)
                if (Addr == loop)
                    DataReg[loop] <= #TD DataMask(loop, DataWr, DataReg[loop]);
                else
                    DataReg[loop] <= #TD DataWrHW[loop];
            else
                DataReg[loop] <= #TD DataWrHW[loop];
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
