///////////////////////////////////////////////////////////////////
// File name        : Lpc.v
// Module name      : Lpc
// Description      : This module is LPC Interface to CPLD, Slave mode
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : LpcDecoder, LpcControl, LpcRegs, LpcMux,
//                        WatchDog, BiosWatchDog, LedDisplay
///////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineODSTextMacro.v"
///////////////////////////////////////////////////////////////////
module Lpc (
    PciReset,   // PCI Reset
    LpcClock,   // 33 MHz Lpc (LPC Clock)
    LpcFrame,   // LPC Interface: Frame
    LpcBus,     // LPC Interface: Data Bus
    DataRd,     // register read data
    AddrReg,    // register address
    Wr,         // register write
    Rd,         // register read
    DataWr      // register write data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input           LpcFrame;
inout   [3:0]   LpcBus;
input   [7:0]   DataRd;
output  [7:0]   AddrReg;
output          Wr;
output          Rd;
output  [7:0]   DataWr;
///////////////////////////////////////////////////////////////////
wire    [15:0]  LpcBar;
wire            StartFlag;
wire            OpcodeValid;
wire    [3:1]   Fetch;
reg             Opcode;
reg             LpcAccess;
reg             Wr;
reg     [10:0]  State;
reg     [7:0]   AddrReg;
reg     [7:0]   DataWr;
///////////////////////////////////////////////////////////////////
assign LpcBar = `BAR;
assign StartFlag = (LpcBus == 4'h0) & (~LpcFrame);
assign OpcodeValid = (LpcBus[3:2] == 2'b00);
assign Fetch[1] = (LpcBus == LpcBar[15:12]) & LpcFrame;
assign Fetch[2] = (LpcBus == LpcBar[11:8]) & LpcFrame;
assign Fetch[3] = (LpcBus[3:1] == LpcBar[7:5]) & LpcFrame;

assign Rd = (Opcode == 1'b0);

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset) begin
        State       <= 0;
        Opcode      <= 0;
        LpcAccess   <= 0;
        Wr          <= 0;
        AddrReg     <= 0;
        DataWr      <= 0;
    end else begin
        State[0]        <= StartFlag;
        State[1]        <= State[0] & OpcodeValid;
        State[2]        <= State[1] & Fetch[1];
        State[3]        <= State[2] & Fetch[2];
        State[4]        <= State[3] & Fetch[3];
        State[5]        <= State[4];
        State[6]        <= State[5];
        State[10:7]     <= State[9:6];
        Opcode          <= State[0] ? LpcBus[1] : Opcode;
        LpcAccess       <= State[4] | LpcAccess & !State[10];
        Wr              <= LpcAccess &  Opcode & State[6];
        AddrReg[7:4]    <= State[3] ? LpcBus : AddrReg[7:4];
        AddrReg[3:0]    <= State[4] ? LpcBus : AddrReg[3:0];
        DataWr[7:4]     <= State[6] ? LpcBus : DataWr[7:4];
        DataWr[3:0]     <= State[5] ? LpcBus : DataWr[3:0];
  end
end
///////////////////////////////////////////////////////////////////
reg             OE;
reg     [3:0]   RegData;
wire            TAR;
wire            DataLow;
wire            DataHigh;
wire    [1:0]   OutputCode;
///////////////////////////////////////////////////////////////////
assign TAR = State[10];
assign DataLow = (!Opcode) & State[8];
assign DataHigh = (!Opcode) & State[9];
assign LpcBus = OE ? RegData : 4'hz;
assign OutputCode[0] = DataLow | TAR;
assign OutputCode[1] = DataHigh | TAR;
always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
      OE <= 1'b0;
    else
      OE <= Opcode ? (|State[9:8]) : ((|State[9:6]) & (~(|AddrReg[7:5])));
end

always @ (OutputCode or Opcode or DataRd) begin
    case (OutputCode)
        2'b00: RegData = 4'h0;
        2'b01: RegData = Opcode ? 4'h0 : DataRd[3:0];
        2'b10: RegData = Opcode ? 4'hF : DataRd[7:4];
        2'b11: RegData = 4'hF;
    endcase
end

///////////////////////////////////////////////////////////////////
endmodule
