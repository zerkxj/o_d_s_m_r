//////////////////////////////////////////////////////////////////////////////
// File name        : BiosControl.v
// Module name      : BiosControl
// Description      : This module determines BIOS Chip Select for dual BIOS
//                    sockets, indicates BIOS status
// Hierarchy Up     : ODS_MR
// Hierarchy Down   :
//////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
`include        "../Verilog/Control/OpenDrain.v"
///////////////////////////////////////////////////////////////////
module BiosControl (
    PciReset,           // reset
    Pwr_ok,             // power is available
    Next_Bios,          // Next BIOS number after reset
    Active_Bios,        // BIOS current active
    SPI_PCH_CS0_N,      // BIOS chip select from PCH
    Next_Bios_latch,    // Next BIOS number after reset
    BIOS_CS_N           // BIOS chip select
);
///////////////////////////////////////////////////////////////////
input           PciReset;
input           Pwr_ok;
input           Next_Bios;
input           Active_Bios;
input           SPI_PCH_CS0_N;
output          Next_Bios_latch;
output  [1:0]   BIOS_CS_N;

///////////////////////////////////////////////////////////////////
reg             Next_Bios_latch;

///////////////////////////////////////////////////////////////////
assign BIOS_CS_N[0] = Active_Bios ? 1'b1 : SPI_PCH_CS0_N;
assign BIOS_CS_N[1] = Active_Bios ? SPI_PCH_CS0_N : 1'b1;
//assign BIOS_CS_N[0] = SPI_PCH_CS0_N;
//assign BIOS_CS_N[1] = 1'b1;
///////////////////////////////////////////////////////////////////
always @ (PciReset) begin
    if ((!PciReset) & (!Pwr_ok))
        Next_Bios_latch <= 1'b0;
    else if (PciReset)
             Next_Bios_latch <= Next_Bios;
         else
             Next_Bios_latch <= Next_Bios_latch;
end

endmodule
