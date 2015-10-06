///////////////////////////////////////////////////////////////////
// File name        : LpcReg.v
// Module name      : LpcReg
// Description      : This module is LPC  register
// Hierarchy Up     : Lpc
// Hierarchy Down   : None
///////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineODSTextMacro.v"
///////////////////////////////////////////////////////////////////
module LpcReg (
    PciReset,       // reset
    LpcClock,       // 33 MHz Lpc (LPC Clock)
    Addr,           // register address
    Wr,             // write operation
    DataWr,         // write data
    BiosStatus,      // BIOS status setup value
    DataReg         // Register data
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           LpcClock;
input   [7:0]   Addr;
input           Wr;
input   [7:0]   DataWr;
input   [2:0]   BiosStatus;
output  [7:0]   DataReg [31:0];

///////////////////////////////////////////////////////////////////
int loop;
///////////////////////////////////////////////////////////////////
reg     [7:0]   DataReg [31:0];

///////////////////////////////////////////////////////////////////
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
                    DataReg[loop] <= DataReg[loop];
            else
                DataReg[loop] <= DataReg[loop];
        end
end

///////////////////////////////////////////////////////////////////
function [7:0] ResetValue(input [7:0] addr,
                          input [2:0] BiosStatus);

    case (addr)
        8'h00: ResetValue = {`FPGAID_CODE , `VERSION_CODE};
        8'h01: ResetValue = 8'h55;                           // R/W ( for Offset 0x01 ~ 0x1F )
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

endmodule
