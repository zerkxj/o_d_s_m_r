///////////////////////////////////////////////////////////////////
// File name        : LpcReg.v
// Module name      : LpcReg
// Description      : This module is LPC  register
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : None
///////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineODSTextMacro.v"
///////////////////////////////////////////////////////////////////
module LpcReg (
    PciReset,   // PCI Reset
    LpcClock,   // 33 MHz Lpc (LPC Clock)
    Addr,       // register address
    Rd,         // read operation
    Wr,         // write operation
    DataWr,     // write data
    DataRd      // read data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input   [7:0]   Addr;
input           Rd;
input           Wr;
input   [7:0]   DataWr;
output  [7:0]   DataRd;
///////////////////////////////////////////////////////////////////
reg     [7:0]   DataRd;
reg     [7:0]   reg_00, reg_01, reg_02, reg_03, reg_04, reg_05, reg_06,
                reg_07, reg_08, reg_09, reg_0a, reg_0b, reg_0c, reg_0d,
                reg_0e, reg_0f, reg_10, reg_11, reg_12, reg_13, reg_14,
                reg_15, reg_16, reg_17, reg_18, reg_19, reg_1a, reg_1b,
                reg_1c, reg_1d, reg_1e, reg_1f;
///////////////////////////////////////////////////////////////////

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset)
        DataRd <= 8'hFF;
    else if (Rd) begin
            case (Addr)
                8'h00: DataRd <= reg_00;
                8'h01: DataRd <= reg_01;
                8'h02: DataRd <= reg_02;
                8'h03: DataRd <= reg_03;
                8'h04: DataRd <= reg_04;
                8'h05: DataRd <= reg_05;
                8'h06: DataRd <= reg_06;
                8'h07: DataRd <= reg_07;
                8'h08: DataRd <= reg_08;
                8'h09: DataRd <= reg_09;
                8'h0A: DataRd <= reg_0a;
                8'h0B: DataRd <= reg_0b;
                8'h0C: DataRd <= reg_0c;
                8'h0D: DataRd <= reg_0d;
                8'h0E: DataRd <= reg_0e;
                8'h0F: DataRd <= reg_0f;
                8'h10: DataRd <= reg_10;
                8'h11: DataRd <= reg_11;
                8'h12: DataRd <= reg_12;
                8'h13: DataRd <= reg_13;
                8'h14: DataRd <= reg_14;
                8'h15: DataRd <= reg_15;
                8'h16: DataRd <= reg_16;
                8'h17: DataRd <= reg_17;
                8'h18: DataRd <= reg_18;
                8'h19: DataRd <= reg_19;
                8'h1A: DataRd <= reg_1a;
                8'h1B: DataRd <= reg_1b;
                8'h1C: DataRd <= reg_1c;
                8'h1D: DataRd <= reg_1d;
                8'h1E: DataRd <= reg_1e;
                8'h1F: DataRd <= reg_1f;
                default: DataRd <= 8'hFF;
            endcase
         end else
                DataRd <= DataRd;
end

always @ (posedge LpcClock or negedge PciReset) begin
    if (!PciReset) begin
        reg_00 <= {`FPGAID_CODE , `VERSION_CODE};
        reg_01 <= 8'h55;                           // R/W ( for Offset 0x01 ~ 0x1F )
        reg_02 <= 8'hAA;
        reg_03 <= 8'h66;
        reg_04 <= 8'h00;
        reg_05 <= 8'h77;
        reg_06 <= 8'h88;
        reg_07 <= 8'h44;
        reg_08 <= 8'hBB;
        reg_09 <= 8'h33;
        reg_0a <= 8'hCC;
        reg_0b <= 8'h22;
        reg_0c <= 8'hDD;
        reg_0d <= 8'h11;
        reg_0e <= 8'hEE;
        reg_0f <= 8'h00;
        reg_10 <= 8'hFF;
        reg_11 <= 8'h55;
        reg_12 <= 8'hAA;
        reg_13 <= 8'h66;
        reg_14 <= 8'h99;
        reg_15 <= 8'h77;
        reg_16 <= 8'h88;
        reg_17 <= 8'h44;
        reg_18 <= 8'hBB;
        reg_19 <= 8'h33;
        reg_1a <= 8'hCC;
        reg_1b <= 8'h22;
        reg_1c <= 8'hDD;
        reg_1d <= 8'h11;
        reg_1e <= 8'hEE;
        reg_1f <= 8'h5A;
    end else if (Wr) begin
                case (Addr)
                    8'h00: reg_00 <= DataWr;
                    8'h01: reg_01 <= DataWr;
                    8'h02: reg_02 <= DataWr;
                    8'h03: reg_03 <= DataWr;
                    8'h04: reg_04 <= DataWr;
                    8'h05: reg_05 <= DataWr;
                    8'h06: reg_06 <= DataWr;
                    8'h07: reg_07 <= DataWr;
                    8'h08: reg_08 <= DataWr;
                    8'h09: reg_09 <= DataWr;
                    8'h0A: reg_0a <= DataWr;
                    8'h0B: reg_0b <= DataWr;
                    8'h0C: reg_0c <= DataWr;
                    8'h0D: reg_0d <= DataWr;
                    8'h0E: reg_0e <= DataWr;
                    8'h0F: reg_0f <= DataWr;
                    8'h10: reg_10 <= DataWr;
                    8'h11: reg_11 <= DataWr;
                    8'h12: reg_12 <= DataWr;
                    8'h13: reg_13 <= DataWr;
                    8'h14: reg_14 <= DataWr;
                    8'h15: reg_15 <= DataWr;
                    8'h16: reg_16 <= DataWr;
                    8'h17: reg_17 <= DataWr;
                    8'h18: reg_18 <= DataWr;
                    8'h19: reg_19 <= DataWr;
                    8'h1A: reg_1a <= DataWr;
                    8'h1B: reg_1b <= DataWr;
                    8'h1C: reg_1c <= DataWr;
                    8'h1D: reg_1d <= DataWr;
                    8'h1E: reg_1e <= DataWr;
                    8'h1F: reg_1f <= DataWr;
                    default: begin
                        reg_00 <= reg_00;
                        reg_01 <= reg_01;
                        reg_02 <= reg_02;
                        reg_03 <= reg_03;
                        reg_04 <= reg_04;
                        reg_05 <= reg_05;
                        reg_06 <= reg_06;
                        reg_07 <= reg_07;
                        reg_08 <= reg_08;
                        reg_09 <= reg_09;
                        reg_0a <= reg_0a;
                        reg_0b <= reg_0b;
                        reg_0c <= reg_0c;
                        reg_0d <= reg_0d;
                        reg_0e <= reg_0e;
                        reg_0f <= reg_0f;
                        reg_10 <= reg_10;
                        reg_11 <= reg_11;
                        reg_12 <= reg_12;
                        reg_13 <= reg_13;
                        reg_14 <= reg_14;
                        reg_15 <= reg_15;
                        reg_16 <= reg_16;
                        reg_17 <= reg_17;
                        reg_18 <= reg_18;
                        reg_19 <= reg_19;
                        reg_1a <= reg_1a;
                        reg_1b <= reg_1b;
                        reg_1c <= reg_1c;
                        reg_1d <= reg_1d;
                        reg_1e <= reg_1e;
                        reg_1f <= reg_1f;
                    end
                endcase
             end else begin
                reg_00 <= reg_00;
                reg_01 <= reg_01;
                reg_02 <= reg_02;
                reg_03 <= reg_03;
                reg_04 <= reg_04;
                reg_05 <= reg_05;
                reg_06 <= reg_06;
                reg_07 <= reg_07;
                reg_08 <= reg_08;
                reg_09 <= reg_09;
                reg_0a <= reg_0a;
                reg_0b <= reg_0b;
                reg_0c <= reg_0c;
                reg_0d <= reg_0d;
                reg_0e <= reg_0e;
                reg_0f <= reg_0f;
                reg_10 <= reg_10;
                reg_11 <= reg_11;
                reg_12 <= reg_12;
                reg_13 <= reg_13;
                reg_14 <= reg_14;
                reg_15 <= reg_15;
                reg_16 <= reg_16;
                reg_17 <= reg_17;
                reg_18 <= reg_18;
                reg_19 <= reg_19;
                reg_1a <= reg_1a;
                reg_1b <= reg_1b;
                reg_1c <= reg_1c;
                reg_1d <= reg_1d;
                reg_1e <= reg_1e;
                reg_1f <= reg_1f;
             end
end

endmodule
