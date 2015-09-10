///////////////////////////////////////////////////////////////////
// File name        : LpcDecoder.v
// Module name      : LpcDecoder
// Description      : This module is LPC Address Decoder
// Hierarchy Up     : Lpc
// Hierarchy Down   : ---
///////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineODSTextMacro.v"
///////////////////////////////////////////////////////////////////
module LpcDecoder (
    PciReset,   // PCI Reset
    LpcClock,   // 33 MHz Lpc (LPC Clock)
    LpcFrame,   // LPC Interface: Frame
    LpcBus,     // LPC Interface: DataWr Bus
    Opcode,     // LPC operation (0 - Read, 1 - Write)
    Wr,         // Write Access to CPLD registers
    Rd,         // Read  Access to CPLD registers
    AddrReg,    // Address of the accessed Register
    DataWr,     // DataWr to be written to register
    StateOut    // Decoding Status
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input           LpcFrame;
input   [3:0]   LpcBus;
output          Opcode;
output          Wr;
output          Rd;
output  [7:0]   AddrReg;
output  [7:0]   DataWr;
output  [10:6]  StateOut;
///////////////////////////////////////////////////////////////////
wire    [15:0]  LpcBar; // 32 Ports BAR
wire            StartFlag;
wire            OpcodeValid;
wire    [3:1]   Fetch;
///////////////////////////////////////////////////////////////////
reg             Opcode;
reg             LpcAccess;
reg             Wr;
reg     [7:0]   AddrReg;
reg     [7:0]   DataWr;
reg     [10:0]  State;
///////////////////////////////////////////////////////////////////
assign Rd = (Opcode == 1'b0);
assign StateOut = State[10:6];
///////////////////////////////////////////////////////////////////
assign LpcBar = `BAR;
assign StartFlag = (LpcBus == 4'h0) & (~LpcFrame);
assign OpcodeValid = (LpcBus[3:2] == 2'b00); // IO Read/Wr (0/2)
assign Fetch[1] = (LpcBus == LpcBar[15:12]) & LpcFrame;
assign Fetch[2] = (LpcBus == LpcBar[11:8]) & LpcFrame;
assign Fetch[3] = (LpcBus[3:1] == LpcBar[7:5]) & LpcFrame;
///////////////////////////////////////////////////////////////////
always @ (posedge LpcClock or negedge PciReset) begin
    if(!PciReset) begin
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
        LpcAccess       <= State[4] | LpcAccess & (!State[10]);
        Wr              <= LpcAccess &  Opcode & State[6];
        AddrReg[7:4]    <= State[3] ? LpcBus : AddrReg[7:4];
        AddrReg[3:0]    <= State[4] ? LpcBus : AddrReg[3:0];
        DataWr[7:4]     <= State[6] ? LpcBus : DataWr[7:4];
        DataWr[3:0]     <= State[5] ? LpcBus : DataWr[3:0];
     end
end

endmodule
