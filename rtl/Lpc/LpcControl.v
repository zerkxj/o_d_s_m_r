///////////////////////////////////////////////////////////////////
// File name        : LpcControl.v
// Module name      : LpcControl
// Description      : This module controls output data to LPC bus
// Hierarchy Up     : Lpc
// Hierarchy Down   : ---
///////////////////////////////////////////////////////////////////
module LpcControl (
    PciReset,   // PCI Reset
    LpcClock,   // 33 MHz Lpc (LPC Clock)
    Opcode,     // LPC operation (0 - Read, 1 - Write)
    AddrReg,    // Address of the accessed Register
    State,      // Decoding Status
    DataRd,     // Multiplexed Data
    LpcBus      // LPC Address Data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input           Opcode;
input   [7:0]   AddrReg;
input   [10:6]  State;
input   [7:0]   DataRd;
output  [3:0]   LpcBus;
///////////////////////////////////////////////////////////////////
reg             OE;
reg     [3:0]   RegData;
///////////////////////////////////////////////////////////////////
wire            TAR;
wire            DataLow;
wire            DataHigh;
wire    [1:0]   OutputCode;
///////////////////////////////////////////////////////////////////
assign LpcBus = OE ? RegData : 4'hz;
///////////////////////////////////////////////////////////////////
assign TAR = State[10];
assign DataLow = (~Opcode) & State[8];
assign DataHigh = (~Opcode) & State[9];
assign OutputCode[0] = DataLow | TAR;
assign OutputCode[1] = DataHigh | TAR;

///////////////////////////////////////////////////////////////////
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

endmodule
