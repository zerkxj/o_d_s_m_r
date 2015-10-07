//******************************************************************************
// File name        : HwResetGenerate.v
// Module name      : HwResetGenerate
// Description      : This module generates H/W reset from RSM_RST_N rising
//                    HARD_nRESETi rising edges.
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`ifndef SIMULATE_DESIGN
  `define CLK33M_32K_DIV        16'h01F7
`else
  `define CLK33M_32K_DIV        16'h0001
`endif

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module HwResetGenerate (
    HARD_nRESETi,           // P3V3_AUX power on reset input
    MCLKi,                  // 33MHz input
    RSMRST_N,
    PLTRST_N,
    Reset1G,
    ResetOut_ox,            // From MR_Bsp, reset button pressed and retained 4 second, ResetOut_ox will be asserted.
    FM_PS_EN,

    CLK32KHz,               // 32.768KHz output from a divider
    InitResetn,             // 941us assert duration ( Low active ) from ( HARD_nRESETi & RSMRST_N ) rising edge
    MainResetN,             // MainResetN = InitResetn & PLTRST_N
    RST_CPU0_LVC3_N,        // Pin M14, to Circuit for fault trigger event ( back to CPLD )
    RST_PLTRST_BUF_N,       // Pin C15, to 07 gate buffer, then drive SIO6779, U5(PCA9548) and U57(EPM1270)
    RST_DLY_CPURST_LVC3,    // Pin G12, drive ProcHot circuit, During Reset assertion period, only allow CPU
                            //           ProcHot to be monitored, After reset de-assertion, CPU ProcHot and IR PWM
                            //           Hot signal are monitored.
    RST_PERST0_N,           // Pin L16, to 07 gate buffer, then drive J8 and J9 ( both are PCIe x8 slots )
    RST_BCM56842_N_R,       // Pin F16, to reset BCM56842
    RST_1G_N_R,
    SYS_RST_IN_SIO_N,
    RST_PCH_RSTBTN_N
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
input           HARD_nRESETi;
input           MCLKi;
input           RSMRST_N;
input           PLTRST_N;
input           Reset1G;
input           ResetOut_ox;
input           FM_PS_EN;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output          CLK32KHz;
output          InitResetn;
output          MainResetN;
output          RST_CPU0_LVC3_N;
output          RST_PLTRST_BUF_N;
output          RST_DLY_CPURST_LVC3;
output          RST_PERST0_N;
output          RST_BCM56842_N_R;
output          RST_1G_N_R;
output          SYS_RST_IN_SIO_N;
output          RST_PCH_RSTBTN_N;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            TwoHwSignalAND;

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
reg             CLK32KHz;
reg             InitResetn;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [4:0]   initCnt;
reg     [15:0]  divClk32K;

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
assign MainResetN = InitResetn & PLTRST_N;
assign RST_CPU0_LVC3_N = PLTRST_N;
assign RST_PLTRST_BUF_N = PLTRST_N;
assign RST_DLY_CPURST_LVC3 = PLTRST_N;
assign RST_PERST0_N = PLTRST_N;
assign RST_BCM56842_N_R = PLTRST_N;
assign RST_1G_N_R = (`PwrSW_On == FM_PS_EN) ? Reset1G : 1'bz; // Tri-state RST_1G_N_R  during S5 state
assign SYS_RST_IN_SIO_N = RST_PCH_RSTBTN_N;
assign RST_PCH_RSTBTN_N = (`PwrSW_On == FM_PS_EN) ? ResetOut_ox : 1'bz; //- ResetOut

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign TwoHwSignalAND = HARD_nRESETi & RSMRST_N; // Monitor these two rising edges

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
//  Frequency Divider : 33MHz --> 32.768KHz
always @ (posedge MCLKi or negedge TwoHwSignalAND) begin
    if (!TwoHwSignalAND)
        CLK32KHz <= #TD `HIGH;
    else if(divClk32K == 16'd0)
             CLK32KHz <= #TD ~CLK32KHz;
         else
             CLK32KHz <= #TD CLK32KHz;
end

//  InitResetn : 941us assert duration ( Low active ) from ( HARD_nRESETi & RSMRST_N ) rising edge
always @ (posedge CLK32KHz or negedge TwoHwSignalAND) begin
    if (!TwoHwSignalAND)
        InitResetn <= #TD 1'b0;
    else if (&initCnt)
             InitResetn <= #TD 1'b1;
         else
             InitResetn <= #TD 1'b0;
end

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge MCLKi or negedge TwoHwSignalAND) begin
    if (!TwoHwSignalAND)
        divClk32K <= #TD `CLK33M_32K_DIV;
    else if (divClk32K != 16'd0)
              divClk32K <= #TD divClk32K - 1;
         else if (CLK32KHz)
                  divClk32K <= #TD `CLK33M_32K_DIV - 1;
              else
                  divClk32K <= #TD `CLK33M_32K_DIV;
end

always @ (posedge CLK32KHz or negedge TwoHwSignalAND) begin
    if (!TwoHwSignalAND)
        initCnt <= #TD 5'h00;
    else
        initCnt <= #TD initCnt + 1;
end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
// None

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// None

endmodule // HwResetGenerate
