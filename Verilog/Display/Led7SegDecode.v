//******************************************************************************
// Filename        : osd_7seg.v
// Description     : The OSD 7 segment module
// Author          : Traveler Lu
// Created On      : Thu Oct 28 17:12:52 2013
// Last Modified By: .
// Last Modified On: .
//******************************************************************************
//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`include "../Verilog/Includes/DefineODSTextMacro.v"

`define Led7seg_En0 6'h01
`define Led7seg_En1 6'h02
`define Led7seg_En2 6'h04
`define Led7seg_En3 6'h08
`define Led7seg_En4 6'h10
`define Led7seg_En5 6'h20
`define Led7seg_DisAll 6'h00

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module Led7SegDecode (
    ResetN,
    Mclk,
    ALL_PWRGD,
    SystemOK,
    BiosFinished,
    BiosPostData,
    Strobe1ms,
    Strobe1s,       // Single SlowClock Pulse @ 1 s
    Strobe125ms,    // Single SlowClock Pulse @ 125 ms
    BiosStatus,
    x7SegSel,
    x7SegVal,

    PowerEvtState,
    Led7En,
    Led7Leg,

    FM_PLD_DEBUG2,  // FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode; from PwrSequence module
    FM_PLD_DEBUG3,
    FM_PLD_DEBUG4,
    FM_PLD_DEBUG5,
    PORT80_DP
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
input           Mclk;
input           ALL_PWRGD;
input           SystemOK;
input           BiosFinished;
input   [7:0]   BiosPostData;
input           Strobe1ms;
input           Strobe1s;
input           Strobe125ms;
input   [2:0]   BiosStatus;
input   [4:0]   x7SegSel;
input   [7:0]   x7SegVal;

input   [3:0]   PowerEvtState;

input FM_PLD_DEBUG2;  // FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode; from PwrSequence module
input FM_PLD_DEBUG3;
input FM_PLD_DEBUG4;
input FM_PLD_DEBUG5;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [5:0]   Led7En;
output  [6:0]   Led7Leg;

output PORT80_DP;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            SoftCtrlEn;
wire    [4:0]   CurrentBios;
wire    [4:0]   NextBios;
wire    [4:0]   ActiveBios;

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
reg     [5:0]   Led7En;
reg     [6:0]   Led7Leg;

reg             PORT80_DP;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [5:0]   Led7En_0;
reg     [2:0]   ByteLocx;
reg     [4:0]   OutVal;
reg     [4:0]   Digit0;
reg     [4:0]   Digit1;
reg     [4:0]   Digit2;
reg     [4:0]   Digit3;
reg     [4:0]   Digit4;
reg     [4:0]   Digit5;
reg             xStrobe1ms;
reg             bStrobe1ms;
reg     [4:0]   Digit2x;
reg     [4:0]   Digit3x;
reg     [1:0]   Modulate;
reg     [1:0]   Select;
reg             Flag;

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
assign SoftCtrlEn = x7SegSel[4];

assign CurrentBios = {4'h0, BiosStatus[2]};
assign NextBios = {4'h0, BiosStatus[1]};
assign ActiveBios = {4'h0, BiosStatus[0]};

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
always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        Led7En <= #TD `Led7seg_DisAll;
    else if (2'b10 == {xStrobe1ms, bStrobe1ms})
             Led7En <= #TD Led7En_0;
         else
             Led7En <= #TD Led7En;
end

//   g f e  d c b a
//0: 0 1 1  1 1 1 1
//1: 0 0 0  0 1 1 0
//2: 1 0 1  1 0 1 1
//3: 1 0 0  1 1 1 1
//4: 1 1 0  0 1 1 0
//5: 1 1 0  1 1 0 1
//6: 1 1 1  1 1 0 1
//7: 0 1 0  0 1 1 1
//8: 1 1 1  1 1 1 1
//9: 1 1 0  0 1 1 1
//A: 1 1 1  0 1 1 1
//B: 1 1 1  1 1 0 0
//C: 0 1 1  1 0 0 1
//D: 1 0 1  1 1 1 0
//E: 1 1 1  1 0 0 1
//F: 1 1 1  0 0 0 1
// : 0 0 0  0 0 0 0
//-: 1 0 0  0 0 0 0
//=: 1 0 0  1 0 0 0
//n: 1 0 1  0 1 0 0
//_: 0 0 0  1 0 0 0 default
always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        Led7Leg <= #TD 7'h7F;
    else if ({xStrobe1ms, bStrobe1ms} == 2'b10)
             case (OutVal)
                 5'h00: Led7Leg <= #TD 7'h3F;
                 5'h01: Led7Leg <= #TD 7'h06;
                 5'h02: Led7Leg <= #TD 7'h5B;
                 5'h03: Led7Leg <= #TD 7'h4F;
                 5'h04: Led7Leg <= #TD 7'h66;
                 5'h05: Led7Leg <= #TD 7'h6D;
                 5'h06: Led7Leg <= #TD 7'h7D;
                 5'h07: Led7Leg <= #TD 7'h27;
                 5'h08: Led7Leg <= #TD 7'h7F;
                 5'h09: Led7Leg <= #TD 7'h67;
                 5'h0A: Led7Leg <= #TD 7'h77;
                 5'h0B: Led7Leg <= #TD 7'h7C;
                 5'h0C: Led7Leg <= #TD 7'h39;
                 5'h0D: Led7Leg <= #TD 7'h5E;
                 5'h0E: Led7Leg <= #TD 7'h79;
                 5'h0F: Led7Leg <= #TD 7'h71;
                 5'h10: Led7Leg <= #TD 7'h00;
                 5'h11: Led7Leg <= #TD 7'h40;
                 5'h12: Led7Leg <= #TD 7'h48;
                 5'h13: Led7Leg <= #TD 7'h54;
                 default: Led7Leg <= #TD 7'h08;
             endcase
         else
             Led7Leg <= #TD Led7Leg;
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        PORT80_DP <= #TD 1'b0;
    else if ({xStrobe1ms, bStrobe1ms} == 2'b10)
             if (!SystemOK)
                 if (ALL_PWRGD) // ALL_PWRGD and not SystemOK (post system)
                     PORT80_DP <= #TD 1'b0;
                 else // Standby mode
                     PORT80_DP <= #TD 1'b1;
             else // 2'b11 = {ALL_PWRGD, SystemOK}
                 PORT80_DP <= #TD PORT80_DP;
         else
             PORT80_DP <= #TD PORT80_DP;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        Led7En_0 <= #TD `Led7seg_DisAll;
    else if ({xStrobe1ms, bStrobe1ms} == 2'b10)
             case(ByteLocx)
                 3'h0: Led7En_0 <= #TD `Led7seg_En0;
                 3'h1: Led7En_0 <= #TD `Led7seg_En1;
                 3'h2: Led7En_0 <= #TD `Led7seg_En2;
                 3'h3: Led7En_0 <= #TD `Led7seg_En3;
                 3'h4: Led7En_0 <= #TD `Led7seg_En4;
                 3'h5: Led7En_0 <= #TD `Led7seg_En5;
                 default: Led7En_0 <= #TD `Led7seg_DisAll;
             endcase
         else
             Led7En_0 <= #TD Led7En_0;
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        ByteLocx <= #TD 3'h0;
    else if ({xStrobe1ms, bStrobe1ms} == 2'b10)
             if (ByteLocx == 3'h5)
                 ByteLocx <= #TD 3'h0;
             else
                 ByteLocx <= #TD ByteLocx + 3'd1;
         else
             ByteLocx <= #TD ByteLocx;
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        OutVal <= #TD 5'h00;
    else if ({xStrobe1ms, bStrobe1ms} == 2'b10)
             case(ByteLocx)
                 3'h0: OutVal <= #TD Digit0;
                 3'h1: OutVal <= #TD Digit1;
                 3'h2: OutVal <= #TD Digit2;
                 3'h3: OutVal <= #TD Digit3;
                 3'h4: OutVal <= #TD Digit4;
                 3'h5: OutVal <= #TD Digit5;
                 default: OutVal <= #TD 5'h10;
             endcase
         else
             OutVal <= #TD OutVal;
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN) begin
        Digit0 <= #TD 5'h0;
        Digit1 <= #TD 5'h1;
        Digit2 <= #TD 5'h2;
        Digit3 <= #TD 5'h3;
        Digit4 <= #TD 5'h4;
        Digit5 <= #TD 5'h5;
    end else if ({xStrobe1ms, bStrobe1ms} == 2'b10)
                 if (SystemOK) // 2'b11 = {ALL_PWRGD, SystemOK}
                     if (SoftCtrlEn) begin
                         Digit0 <= #TD x7SegSel[0] ? {1'b0, x7SegVal[3:0]} : Digit0;
                         Digit1 <= #TD x7SegSel[0] ? {1'b0, x7SegVal[7:4]} : Digit1;
                         Digit2 <= #TD x7SegSel[1] ? {1'b0, x7SegVal[3:0]} : Digit2;
                         Digit3 <= #TD x7SegSel[1] ? {1'b0, x7SegVal[7:4]} : Digit3;
                         Digit4 <= #TD x7SegSel[2] ? {1'b0, x7SegVal[3:0]} : Digit4;
                         Digit5 <= #TD x7SegSel[2] ? {1'b0, x7SegVal[7:4]} : Digit5;
                     end else begin
                         Digit0 <= #TD {1'b0, PowerEvtState};
                         Digit1 <= #TD 5'h10;
                         Digit2 <= #TD Flag ? Digit2x : 5'h10;
                         Digit3 <= #TD Flag ? Digit3x : 5'h10;
                         Digit4 <= #TD {1'b0, BiosPostData[3:0]};
                         Digit5 <= #TD {1'b0, BiosPostData[7:4]};
                     end
                 else if (ALL_PWRGD) begin // ALL_PWRGD and not SystemOK (post system)
                          `ifndef DEBUG_PwrState
                          Digit0 <= #TD {1'b0, `VERSION_CODE};
                          Digit1 <= #TD {1'b0, `FPGAID_CODE};
                          `else
                          Digit0 <= #TD {1'b0, PowerEvtState};
                          Digit1 <= #TD {1'b0, FM_PLD_DEBUG5,FM_PLD_DEBUG4,FM_PLD_DEBUG3,FM_PLD_DEBUG2};
                          `endif
                          Digit2 <= #TD Flag ? Digit2x : 5'h10;
                          Digit3 <= #TD Flag ? Digit3x : 5'h10;
                          Digit4 <= #TD {1'b0, BiosPostData[3:0]};
                          Digit5 <= #TD {1'b0, BiosPostData[7:4]};
                      end else begin // Standby mode
                          `ifndef DEBUG_PwrState
                          Digit0 <= #TD {1'b0, `VERSION_CODE};
                          Digit1 <= #TD {1'b0, `FPGAID_CODE};
                          `else
                          Digit0 <= #TD {1'b0, PowerEvtState};
                          Digit1 <= #TD {1'b0, FM_PLD_DEBUG5,FM_PLD_DEBUG4,FM_PLD_DEBUG3,FM_PLD_DEBUG2};
                          `endif
                          Digit2 <= #TD Flag ? Digit2x : 5'h10;
                          Digit3 <= #TD Flag ? Digit3x : 5'h10;
                          Digit4 <= #TD {1'b0, PowerEvtState};
                          Digit5 <= #TD {1'b0, FM_PLD_DEBUG5,FM_PLD_DEBUG4,FM_PLD_DEBUG3,FM_PLD_DEBUG2};
                      end
             else begin
                 Digit0 <= #TD Digit0;
                 Digit1 <= #TD Digit1;
                 Digit2 <= #TD Digit2;
                 Digit3 <= #TD Digit3;
                 Digit4 <= #TD Digit4;
                 Digit5 <= #TD Digit5;
             end
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN) begin
        xStrobe1ms <= #TD `LOW;
        bStrobe1ms <= #TD `LOW;
    end else begin
        xStrobe1ms <= #TD Strobe1ms;
        bStrobe1ms <= #TD xStrobe1ms;
    end
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN) begin
        Digit2x <= #TD 5'h00;
        Digit3x <= #TD 5'h00;
    end else if (BiosFinished)
                 case(Select)
                     2'h0: begin
                         Digit2x <= #TD CurrentBios;
                         Digit3x <= #TD 5'h0C; // 'C'
                     end
                     2'h1: begin
                         Digit2x <= #TD NextBios;
                         Digit3x <= #TD 5'h13; // 'n'
                     end
                     2'h2: begin
                         Digit2x <= #TD ActiveBios;
                         Digit3x <= #TD 5'h0A; // 'A'
                     end
                     default: begin
                         Digit2x <= #TD 5'h09;
                         Digit3x <= #TD 5'h10; // ' '
                     end
                 endcase
             else begin
                 Digit2x <= #TD CurrentBios;
                 Digit3x <= #TD 5'h0B; // 'b'
             end

end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        Modulate <= #TD 2'h0;
    else if (Strobe125ms)
             Modulate <= #TD Modulate + 2'd1;
         else
             Modulate <= #TD Modulate;
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        Select <= #TD 2'h0;
    else if (Strobe1s)
             if (Select == 2'h2)
                 Select <= #TD 2'h0;
             else
                 Select <= #TD Select + 2'd1;
         else
             Select <= #TD Select;
end

always @ (posedge Mclk or negedge ResetN) begin
    if (!ResetN)
        Flag <= 1'b0;
    else if (BiosFinished)
             Flag <= #TD 1'b1;
         else if (Modulate != 2'h2)
                  Flag <= #TD 1'b1;
              else
                  Flag <= #TD 1'b0;

end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule // Led7segDecode
