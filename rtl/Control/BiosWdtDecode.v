//******************************************************************************
// File name        : BiosWdtDecode.v
// Module name      : BiosWdtDecode
// Description      : This module decodes BIOS WDT address and data in CPLD reg
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//******************************************************************************


//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
// None

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module BiosWdtDecode (
    MainResetN,     // In,
    CLK32768,       // In,
    Mclkx,          // In,
    WriteBiosWD,    // In, BIOS watch dog register write
    WrDev_Data,     // In,

    bCPUWrWdtRegSig // Out,
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
input           MainResetN;
input           CLK32768;
input           Mclkx;
input           WriteBiosWD;
input   [7:0]   WrDev_Data;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [4:0]   bCPUWrWdtRegSig;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
// None

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
reg     [4:0]   bCPUWrWdtRegSig;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [4:0]   bCPUWriteWdtSig;
reg             bCPUWdtAcsFlg;

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
// None

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
// None

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
always @ (posedge CLK32768 or negedge MainResetN) begin
    if (!MainResetN)
        bCPUWrWdtRegSig <= #TD 5'd0;
    else
        bCPUWrWdtRegSig <= #TD bCPUWriteWdtSig;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge Mclkx or negedge MainResetN) begin
    if (!MainResetN)
        bCPUWriteWdtSig <= #TD 5'd0;
    else if (WriteBiosWD)
             if (!bCPUWdtAcsFlg)
                 case (WrDev_Data)
                     8'h55: bCPUWriteWdtSig <= #TD {bCPUWriteWdtSig[4:1] , (~bCPUWriteWdtSig[0])};
                     8'h29: bCPUWriteWdtSig <= #TD {bCPUWriteWdtSig[4:2] ,(~bCPUWriteWdtSig[1]), bCPUWriteWdtSig[0]};
                     8'hFF: bCPUWriteWdtSig <= #TD {bCPUWriteWdtSig[4:3] ,(~bCPUWriteWdtSig[2]), bCPUWriteWdtSig[1:0]};
                     8'hAA: bCPUWriteWdtSig <= #TD {bCPUWriteWdtSig[4] ,(~bCPUWriteWdtSig[3]), bCPUWriteWdtSig[2:0]};
                     default: bCPUWriteWdtSig <= #TD {(~bCPUWriteWdtSig[4]), bCPUWriteWdtSig[3:0]};
                 endcase
             else
                 bCPUWriteWdtSig <= #TD bCPUWriteWdtSig;
         else
             bCPUWriteWdtSig <= #TD bCPUWriteWdtSig;
end

always @ (posedge Mclkx or negedge MainResetN) begin
    if (!MainResetN)
        bCPUWdtAcsFlg <= #TD 1'b0;
    else if (!WriteBiosWD)
             bCPUWdtAcsFlg <= #TD 1'b0;
         else if (!bCPUWdtAcsFlg)
                  bCPUWdtAcsFlg <= #TD 1'b1;
              else
                  bCPUWdtAcsFlg <= #TD bCPUWdtAcsFlg;
end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule // BiosWdtDecode
