///////////////////////////////////////////////////////////////////
// File name        : LpcMux.v
// Module name      : LpcMux
// Description      : This module is Data Multiplexer to LPC Read
// Hierarchy Up     : Lpc
// Hierarchy Down   : ---
///////////////////////////////////////////////////////////////////
////////////    LPC Bus CPLD Internal Memory Map    ///////////////
///////////////////////////////////////////////////////////////////
// Offset(H/B)        Name                                  Access
///////////////////////////////////////////////////////////////////
//   0    0x00    CPLD hardware version                RO
//   1    0x01    BIOS Watch Dog Control Register                R/W
//   2    0x02
//   3    0x03
//   4    0x04
//   5    0x05
//   6    0x06
//   7    0x07
//   8    0x08
//   9    0x09
//  10    0x0A
//  11    0x0B
//  12    0x0C
//  13    0x0D
//  14    0x0E    Seven Segment Digit Select Register            R/W
//  15    0x0F    Seven Segment Display Data Register            R/W
//  16    0x10
//  17    0x11
//  18    0x12
//  19    0x13
//  20    0x14
//  21    0x15
//  22    0x16
//  23    0x17
//  24    0x18
//  25    0x19
//  26    0x1A
//  27    0x1B
//  28    0x1C
//  29    0x1D
//  30    0x1E
//  31    0X1f    Not used
///////////////////////////////////////////////////////////////////
module LpcMux (
    PciReset,       // PCI Reset
    LpcClock,       // 33 MHz Lpc (LPC Clock)
    AddrReg,        // Address of the accessed Register
    DataReg,        // Register data
    BiosStatus,     // BIOS status
    DataRd          // Output Multiplexed Data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input   [7:0]   AddrReg;
input   [7:0]   DataReg [31:0];
input   [2:0]   BiosStatus;
output  [7:0]   DataRd;
///////////////////////////////////////////////////////////////////
int k;
///////////////////////////////////////////////////////////////////
reg     [7:0]   Mux;
reg     [7:0]   DataRd;
///////////////////////////////////////////////////////////////////
always @ (AddrReg or BiosStatus or DataReg[k]) begin
    if (AddrReg < 32)
        if (AddrReg == 8'h04)
            Mux = {5'h00, BiosStatus};
        else
            Mux = DataReg[AddrReg];
    else
        Mux = 8'h00;
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        DataRd <= 8'h00;
    else
        DataRd <= Mux;
end

endmodule
