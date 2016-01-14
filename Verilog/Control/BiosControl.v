//******************************************************************************
// File name        : BiosControl.v
// Module name      : BiosControl
// Description      : This module determines BIOS Chip Select for dual BIOS
//                    sockets, indicates BIOS status
// Hierarchy Up     : ODS_MR
// Hierarchy Down   :
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module BiosControl (
    ResetN,             // In, Power reset
    MainReset,          // In, Power or Controller ICH10R Reset
    LpcClock,           // In, 33 MHz Lpc (Altera Clock)
    CLK32768,           // In, 32.768 KHZ clock
    RstBiosFlg,         // In, In, Reset BIOS to BIOS0
    WrBiosStsReg,       // In, Write BIOS status registor
    NextBiosSW,         // In, Next BIOS from SW configuration
    ActiveBiosSW,       // In, Active BIOS from SW configuration
    BiosWatchDogReset,  // In, BIOS watch dog reset
    LBCF,               // In, Lock BIOS Chip Flag
    ALL_PWRGD,          // In, all power good
    Strobe125ms,        // In, 125ms strobe signal
    BiosCS,             // In, ICH10 BIOS Chip Select (SPI Interface)
    BIOS_SEL,           // In, BIOS SELECT  - Bios Select Jumper (default "1")
    ForceSwap,          // In, BiosWD Occurred, Force BIOS Swap while power restart


    BIOS,           // Out, Chip Select to SPI Flash Memories
    BiosStatus      // Out, BIOS status
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
// None

//------------------------------------------------------------------------------
// Input/Output declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Input declaration
//--------------------------------------------------------------------------
input           ResetN;
input           MainReset;
input           LpcClock;
input           CLK32768;
input           RstBiosFlg;
input           WrBiosStsReg;
input           NextBiosSW;
input           ActiveBiosSW;
input           BiosWatchDogReset;
input           LBCF;
input           ALL_PWRGD;
input           Strobe125ms;
input           BiosCS;
input           BIOS_SEL;
input   [1:0]   ForceSwap;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [1:0]   BIOS;
output  [2:0]   BiosStatus;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            SwapDisable;

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
// None

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
// None

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg             Start;
reg             SetNext;
reg     [1:0]   Edge;
reg             Current_Bios;
reg             Next_Bios;
reg             Active_Bios;
reg     [6:0]   PowerSample;

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Task/Function description and included task/function description
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Main code
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Combinational circuit
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Output
//----------------------------------------------------------------------
assign BIOS[0] = Active_Bios ? 1'b1 : BiosCS;
assign BIOS[1] = Active_Bios ? BiosCS : 1'b1;
assign BiosStatus = {Current_Bios, Next_Bios, Active_Bios};

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign SwapDisable = !PowerSample[6];

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
// None

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge LpcClock or negedge ResetN) begin
    if (!ResetN) begin
        Start <= #TD 1'b0;
        SetNext <= #TD 1'b0;
        Edge <= #TD 2'h3;
        Current_Bios <= #TD 1'b0;
        Next_Bios <= #TD 1'b1;
        Active_Bios <= #TD 1'b0;
    end else if (RstBiosFlg) begin
                 Start <= #TD 1'b0;
                 SetNext <= #TD 1'b0;
                 Edge <= #TD 2'h3;
                 Current_Bios <= #TD LBCF ? Current_Bios : 1'b0;
                 Next_Bios <= #TD LBCF ? Next_Bios : 1'b1;
                 Active_Bios <= #TD LBCF ? Active_Bios : 1'b0;
             end else begin
                 Start <= #TD (Edge == 2'h1) & !SwapDisable | |ForceSwap;
                 SetNext <= #TD Start;
                 Edge <= #TD {Edge[0], MainReset | SwapDisable};
                 Current_Bios <= #TD (!BIOS_SEL | Start) ?
                                         BiosWatchDogReset ? (!Current_Bios) :
                                                             LBCF ? Current_Bios :
                                                                    Next_Bios :
                                         Current_Bios;
                 Next_Bios <= #TD SetNext ? !Current_Bios :
                                            WrBiosStsReg ? NextBiosSW : Next_Bios;
                 Active_Bios <= #TD SetNext ? Current_Bios :
                                              WrBiosStsReg ? ActiveBiosSW : Active_Bios;
             end
end

always @ (posedge CLK32768 or negedge ALL_PWRGD) begin
    if (!ALL_PWRGD)
        PowerSample <= #TD 7'h00;
    else if (Strobe125ms)
             PowerSample <= #TD {PowerSample[5:0], ALL_PWRGD};
         else
             PowerSample <= #TD PowerSample; 
end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule
