//////////////////////////////////////////////////////////////////////////////
// File name        : BiosControl.v
// Module name      : BiosControl
// Description      : This module determines BIOS Chip Select for dual BIOS
//                    sockets, indicates BIOS status
// Hierarchy Up     : ODS_MR
// Hierarchy Down   :
//////////////////////////////////////////////////////////////////////////////
module BiosControl (
    ResetN,         // Power reset
    MainReset,      // Power or Controller ICH10R Reset
    LpcClock,       // 33 MHz Lpc (Altera Clock)
    RstBiosFlg,     // In, Reset BIOS to BIOS0
    Write,          // Write Access to CPLD registor
    BiosCS,         // ICH10 BIOS Chip Select (SPI Interface)
    BIOS_SEL,       // BIOS SELECT  - Bios Select Jumper (default "1")
    SwapDisable,    // Disable BIOS Swapping after Power Up
    ForceSwap,      // BiosWD Occurred, Force BIOS Swap while power restart
    RegAddress,     // Address of the accessed Register
    DataWr,         // Data to be written to CPLD Register
    BIOS,           // Chip Select to SPI Flash Memories
    BiosStatus      // BIOS status
);
///////////////////////////////////////////////////////////////////
input           ResetN;
input           MainReset;
input           Write;
input           LpcClock;
input           RstBiosFlg;
input           BiosCS;
input           BIOS_SEL;
input           SwapDisable;
input   [1:0]   ForceSwap;
input   [7:0]   RegAddress;
input   [7:0]   DataWr;
output  [1:0]   BIOS;
output  [2:0]   BiosStatus;

///////////////////////////////////////////////////////////////////
wire            WriteReg;
///////////////////////////////////////////////////////////////////
reg             Start;
reg             SetNext;
reg     [1:0]   Edge;
reg             Current_Bios;
reg             Next_Bios;
reg             Active_Bios;

///////////////////////////////////////////////////////////////////
assign BIOS[0] = Active_Bios ? 1'b1 : BiosCS;
assign BIOS[1] = Active_Bios ? BiosCS : 1'b1;
assign BiosStatus = {Current_Bios, Next_Bios, Active_Bios};

///////////////////////////////////////////////////////////////////
assign WriteReg = Write & (RegAddress == 8'h04);
///////////////////////////////////////////////////////////////////
always @ (posedge LpcClock or negedge ResetN) begin
    if(!ResetN) begin
        Edge <= 2'h3;
        Start <= 1'b0;
        SetNext <= 1'b0;
        Current_Bios <= 1'b0;
        Next_Bios <= 1'b1;
        Active_Bios <= 1'b0;
    end else begin
        Edge <= {Edge[0], MainReset | SwapDisable};
        Start <= (Edge == 2'h1) & !SwapDisable | |ForceSwap;
        SetNext <= Start;
        Current_Bios <= (!BIOS_SEL | Start) ? Next_Bios : Current_Bios;
        Next_Bios <= SetNext ? !Current_Bios : WriteReg ? DataWr[1] : Next_Bios;
        Active_Bios <= SetNext ? Current_Bios : WriteReg ? DataWr[0] : Active_Bios;
    end
end

endmodule
