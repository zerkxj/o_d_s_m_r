//******************************************************************************
// File name        : ODS_MR.v
// Module name      : ODS_MR, top module of COB-G503
// Description      : PwrSequence, Reset Control,  Pwr/Reset Button control,
//                    Dual BIOS control, LPC decode
// Hierarchy Up     : ---
// Hierarchy Down   : PwrSequence
//                    Lpc
//                    BiosControl
//                    HwResetGererate
//                    Led7SegDecode
//                    StrobeGen
//                    BiosWatchDog
//******************************************************************************

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module ODS_MR (
    CLK_33K_SUSCLK_PLD_R2,  // In, 32.768KHz from PCH SUSCLK output.
    RST_RSMRST_N,           // In,

    // ----------------------------
    // PwrSeq control signals
    // ----------------------------
    FM_BMC_ONCTL_N,     // In, No BMC, use SIO_PS_ON_N that is an output from SIO
    FM_PS_EN,           // Out,
    PWRGD_PS_PWROK_3V3, // In,
    FM_SLPS3_N,         // In,
    FM_SLPS4_N,         // In,

    // ----------------------------
    // Clock enables
    // ----------------------------
    FM_PLD_CLK_EN,  // Out,

    // ----------------------------
    // Voltage regulator devices
    // ----------------------------
    PWRGD_P1V05_STBY_PCH_P1V0_AUX,  // In,
    PWRGD_P3V3_AUX,                 // In,
    FM_P1V5_PCH_EN,                 // Out,
    FM_VCC_MAIN_EN,                 // Out,
    PWRGD_P1V5_PCH,                 // In,
    PWRGD_P1V05_PCH,                // In,
    PVCCIN_CPU0_EN,                 // Out,
    PWRGD_PVCCIN_CPU0,              // In,
    FM_VPP_MEM_ABCD_EN,             // Out,
    PWRGD_PVPP_PVDDQ_AB,            // In,
    PWRGD_PVPP_PVDDQ_CD,            // In,
    BCM_V1P0_EN,                    // Out,
    BCM_V1P0A_EN,                   // Out,
    BCM_P1V_PG,                     // In,
    BCM_P1VA_PG,                    // In,

    // ----------------------------
    // Presence signals
    // ----------------------------
    FM_PCH_PRSNT_CO_N,          // In,
    FM_CPU0_SKTOCC_LVT3_N,      // In,
    FM_CPU0_BDX_PRSNT_LVT3_N,   // In,

    // ----------------------------
    // Miscellaneous signals
    // ----------------------------
    FM_THERMTRIP_CO_N,          // In,
    FM_LVC3_THERMTRIP_DLY,      // Out,
    IRQ_SML1_PMBUS_ALERT_BUF_N, // In, Always High signal input on G503
    IRQ_FAN_12V_GATE,           // Out, Reserved Output pin
    FM_CPU_ERR1_CO_N,           // In,
    FM_ERR1_DLY_N,              // Out,
    RST_PLTRST_DLY,             // Out, for pltrst_dly
    FM_PVTT_ABCD_EN,            // Out,

    // ----------------------------
    // Power good reset signals
    // ----------------------------
    PWRGD_P1V05_PCH_STBY_DLY,   // Out,
    PWRGD_PCH_PWROK_R,          // Out,
    PWRGD_SYS_PWROK_R,          // Out,
    PWRGD_CPUPWRGD,             // In,
    PWRGD_CPU0_LVC3_R,          // Out,

    // ----------------------------
    // Reset signals
    // ----------------------------
    RST_PLTRST_N,           // In,
    // Below Reset signals are not utilized by PwrSequence module.
    RST_CPU0_LVC3_N,        // Out, in HwResetGenerate module or directly assigned
    RST_PLTRST_BUF_N,       // Out, in HwResetGenerate module or directly assigned
    RST_DLY_CPURST_LVC3,    // Out, in HwResetGenerate module or directly assigned
    RST_PERST0_N,           // Out, in HwResetGenerate module or directly assigned
    FM_PERST_SRC_LVT3,      // In, PCIe Reset source select, reserved pin
    RST_PCIE_PCH_N,         // In, Input, from PCH GPIO19 output, reserved to gate control PCIe device reset signal
    RST_PCIE_CPU_N,         // In, Input, from PCH GPIO11 output, reserved to gate control PCIe device reset signal

    // ----------------------------
    // ITP interface
    // ----------------------------
    XDP_RST_CO_N,       // In,
    XDP_PWRGD_RST_N,    // In,
    XDP_CPU_SYSPWROK,   // In,

    // ----------------------------
    // CPLD debug hooks
    // ----------------------------
    FM_PLD_DEBUG_MODE_N,    // In,
    FM_PLD_DEBUG1,          // In,

    SPI_PCH_CS0_N,          // In, BiosCS# from PCH;
    BIOS_CS_N,              // Out, Chip Select to SPI Flash Memories
    BIOS_LED_N,             // Out, point current BIOS
    FM_SYS_SIO_PWRBTN_N,    // Out, (Debounced) Power Button output to SIO
    PWR_BTN_IN_N,           // In, Power Button input
    SYS_RST_IN_N,           // In, Reset Button input
    RST_PCH_RSTBTN_N,       // Out, Reset out to PCH
    RST_BCM56842_N_R,       // Out, Reset signal for BCM56842
    RST_1G_N_R,             // Out, Reset signal for I211
    RST_DME_N,              // Out, Reset Signal for DME
    UNLOCK_BIOS_ME,         // Out, for PCH ME unlock
    LAN_ACT_N,              // In, RJ45PActivity, LAN --> CPLD
    LAN_LINK1000_N,         // In, RJ45Speed1P, LAN --> CPLD
    LAN_LINK100_N,          // In, RJ45Speed2P, LAN --> CPLD
    CPLD_LAN_ACT_N,         // Out, RJ45RActivity,  CPLD --> RJ45 LED
    CPLD_LAN_LINK1000_N,    // Out, RJ45Speed1R, CPLD --> RJ45 LED
    CPLD_LAN_LINK100_N,     // Out, RJ45Speed2R,  CPLD --> RJ45 LED
    MCLK_FPGA,              // In, Main Clock input of 33Mhz
    LCLK_CPLD,              // In, Lpc bus clock
    LPC_FRAME_N,            // In,
    LPC_LAD,                // In/Out

    DualPs,                         // In,
    PSU_status,                     // In,
    BIOS_SEL,                       // In,
    GPIO15_FAN_Fail_N,              // In,
    FAN_PRSNT_N,                    // In,
    SYS_LEDG_N,                     // Out
    SYS_LEDR_N,                     // Out,
    PSU_Normal_N,                   // Out,
    PSU_Fail_N,                     // Out,
    LED7_digit,                     // Out,
    LED7_SEG,                       // Out,
    FAN_LEDR_N,                     // Out,
    FAN_LEDG_N,                     // Out,
    LED7_SEGDP,                     // Out,
    DMEControl,                     // Out,
    SYS_RST_IN_SIO_N,               // Out,
    CPLD_PCH_INT_N,                 // Out,
    PMB_CLK,                        // Out,
    FPGA_TXD_N,                     // Out,
    HARD_nRESETi,                   // In,
    CLK36864,                       // In,
    SIO_BEEP,                       // In,
    PMB_DATA,                       // In,
    FPGA_RXD_N,                     // In,
    DMEStatus,                      // In,
    DMEID,                          // In,
    DME_PWRGD,                      // In,
    DME_Absent,                     // In,
    FpgaGPIO,                       // In,
    PWRGD_VCCST3_3,                 // In,
    PWRGD_PVCCIO,                   // In,
    H_CPU0_MEMAB_MEMHOT_LVT3_N,     // In,
    H_CPU0_MEMCD_MEMHOT_LVT3_N,     // In,
    FM_MEM_THERM_EVENT_LVT3_N,      // In,
    FM_CPU0_FIVR_FAULT_LVT3_N,      // In,
    FM_CPU_ERR2_CO_N,               // In,
    FM_CPU0_THERMTRIP_LATCH_LVC3_N, // In,
    FM_CPU0_PROCHOT_LVT3_N,         // In,
    PCH_GPIO8,                      // In,
    PCH_GPIO25,                     // In,
    PCH_GPIO34                      // In,
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
input           CLK_33K_SUSCLK_PLD_R2;
input           RST_RSMRST_N;

// PwrSeq control signals
input           FM_BMC_ONCTL_N;
input           PWRGD_PS_PWROK_3V3;
input           FM_SLPS3_N;
input           FM_SLPS4_N;

// Voltage regulator devices
input           PWRGD_P1V05_STBY_PCH_P1V0_AUX;
input           PWRGD_P3V3_AUX;
input           PWRGD_P1V5_PCH;
input           PWRGD_P1V05_PCH;
input           PWRGD_PVCCIN_CPU0;
input           PWRGD_PVPP_PVDDQ_AB;
input           PWRGD_PVPP_PVDDQ_CD;
input           BCM_P1V_PG;
input           BCM_P1VA_PG;

// Presence signals
input           FM_PCH_PRSNT_CO_N;
input           FM_CPU0_SKTOCC_LVT3_N;
input           FM_CPU0_BDX_PRSNT_LVT3_N;

// Miscellaneous signals
input           FM_THERMTRIP_CO_N;
input           IRQ_SML1_PMBUS_ALERT_BUF_N;
input           FM_CPU_ERR1_CO_N;

// Power good reset signals
input           PWRGD_CPUPWRGD;

// Reset signals
input           RST_PLTRST_N;
input           FM_PERST_SRC_LVT3;
input           RST_PCIE_PCH_N;
input           RST_PCIE_CPU_N;

// ITP interface
input           XDP_RST_CO_N;
input           XDP_PWRGD_RST_N;
input           XDP_CPU_SYSPWROK;

// CPLD debug hooks
input           FM_PLD_DEBUG_MODE_N;
input           FM_PLD_DEBUG1;

input           SPI_PCH_CS0_N;
input           PWR_BTN_IN_N;
input           SYS_RST_IN_N;
input   [1:0]   LAN_ACT_N;
input   [1:0]   LAN_LINK1000_N;
input   [1:0]   LAN_LINK100_N;

input           MCLK_FPGA;
input           LCLK_CPLD;
input           LPC_FRAME_N;
inout   [3:0]   LPC_LAD;

input           DualPs;
input   [1:0]   PSU_status;
input           BIOS_SEL;
input           GPIO15_FAN_Fail_N;
input   [2:0]   FAN_PRSNT_N;
input           HARD_nRESETi;
input           CLK36864;
input           SIO_BEEP;
input           PMB_DATA;
input           FPGA_RXD_N;
input   [5:0]   DMEStatus;
input   [3:0]   DMEID;
input           DME_PWRGD;
input           DME_Absent;
input   [8:0]   FpgaGPIO;
input           PWRGD_VCCST3_3;
input           PWRGD_PVCCIO;
input           H_CPU0_MEMAB_MEMHOT_LVT3_N;
input           H_CPU0_MEMCD_MEMHOT_LVT3_N;
input           FM_MEM_THERM_EVENT_LVT3_N;
input           FM_CPU0_FIVR_FAULT_LVT3_N;
input           FM_CPU_ERR2_CO_N;
input           FM_CPU0_THERMTRIP_LATCH_LVC3_N;
input           FM_CPU0_PROCHOT_LVT3_N;
input           PCH_GPIO8;
input           PCH_GPIO25;
input           PCH_GPIO34;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
// PwrSeq control signals
output          FM_PS_EN;

// Clock enables
output          FM_PLD_CLK_EN;

// Voltage regulator devices
output          FM_P1V5_PCH_EN;
output          FM_VCC_MAIN_EN;
output          PVCCIN_CPU0_EN;
output          FM_VPP_MEM_ABCD_EN;
output          BCM_V1P0_EN;
output          BCM_V1P0A_EN;

// Miscellaneous signals
output          FM_LVC3_THERMTRIP_DLY;
output          IRQ_FAN_12V_GATE;
output          FM_ERR1_DLY_N;
output          RST_PLTRST_DLY;
output          FM_PVTT_ABCD_EN;

// Power good reset signals
output          PWRGD_P1V05_PCH_STBY_DLY;
output          PWRGD_PCH_PWROK_R;
output          PWRGD_SYS_PWROK_R;
output          PWRGD_CPU0_LVC3_R;

// Reset signals
output          RST_CPU0_LVC3_N;
output          RST_PLTRST_BUF_N;
output          RST_DLY_CPURST_LVC3;
output          RST_PERST0_N;

output  [1:0]   BIOS_CS_N;
output  [1:0]   BIOS_LED_N;
output          FM_SYS_SIO_PWRBTN_N;
output          RST_PCH_RSTBTN_N;
output          RST_BCM56842_N_R;
output          RST_1G_N_R;
output          RST_DME_N;
output          UNLOCK_BIOS_ME;
output  [1:0]   CPLD_LAN_ACT_N;
output  [1:0]   CPLD_LAN_LINK1000_N;
output  [1:0]   CPLD_LAN_LINK100_N;

output          SYS_LEDG_N;
output          SYS_LEDR_N;
output  [1:0]   PSU_Normal_N;
output  [1:0]   PSU_Fail_N;
output  [5:0]   LED7_digit;
output  [6:0]   LED7_SEG;
output          FAN_LEDR_N;
output          FAN_LEDG_N;
output          LED7_SEGDP;
output  [5:0]   DMEControl;
output          SYS_RST_IN_SIO_N;
output          CPLD_PCH_INT_N;
output          PMB_CLK;
output          FPGA_TXD_N;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            CLK32768;
wire            InitResetn;
wire            MainResetN;
wire            SystemOK;

wire            FM_PLD_DEBUG2;
wire            FM_PLD_DEBUG3;
wire            FM_PLD_DEBUG4;
wire            FM_PLD_DEBUG5;

wire            Wr;
wire    [7:0]   AddrReg;
wire    [7:0]   DataWr;
wire    [2:0]   BiosStatus;
wire            WriteBiosWD;
wire    [7:0]   BiosRegister;
wire    [7:0]   BiosPostData;

wire            CLK33M;

wire            Strobe1s;
wire            Strobe488us;
wire            Strobe1ms;
wire            Strobe16ms;
wire            Strobe125ms;
wire            Strobe125msec;
wire            Counter;
wire    [4:0]   x7SegSel;
wire    [7:0]   x7SegVal;

wire            BiosFinished;
wire            BiosPowerOff;
wire            ForceSwap;

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
// None

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
// Reset signals
assign RST_CPU0_LVC3_N = RST_PLTRST_N;
assign RST_PLTRST_BUF_N = RST_PLTRST_N;
assign RST_DLY_CPURST_LVC3 = RST_PLTRST_N;
assign RST_PERST0_N = RST_PLTRST_N;

assign BIOS_LED_N[0] = BiosStatus[2];
assign BIOS_LED_N[1] = ~BiosStatus[2];
assign FM_SYS_SIO_PWRBTN_N = PWR_BTN_IN_N; // PWR_BTN_IN_N is not controlled.
assign RST_PCH_RSTBTN_N = SYS_RST_IN_N; // SYS_RST_IN_N is not controlled.
assign RST_BCM56842_N_R = RST_PLTRST_N;
assign RST_1G_N_R = RST_PLTRST_N;
assign RST_DME_N = RST_PLTRST_N;
assign UNLOCK_BIOS_ME = 1'bz;
assign CPLD_LAN_ACT_N[0] = (2'b11 == {LAN_LINK1000_N[0], LAN_LINK100_N[0]}) ? 1'b1 : ~LAN_ACT_N[0];
assign CPLD_LAN_ACT_N[1] = (2'b11 == {LAN_LINK1000_N[1], LAN_LINK100_N[1]}) ? 1'b1 : ~LAN_ACT_N[1];
assign CPLD_LAN_LINK1000_N[0] = LAN_LINK100_N[0];
assign CPLD_LAN_LINK1000_N[1] = LAN_LINK100_N[1];
assign CPLD_LAN_LINK100_N[0] = LAN_LINK1000_N[0];
assign CPLD_LAN_LINK100_N[1] = LAN_LINK1000_N[1];

assign SYS_LEDG_N = 1'b1;
assign SYS_LEDR_N = 1'b1;
assign PSU_Normal_N = 2'b11;
assign PSU_Fail_N = 2'b11;
assign FAN_LEDR_N = 1'b1;
assign FAN_LEDG_N = 1'b1;
assign DMEControl = 6'h00;
assign SYS_RST_IN_SIO_N = 1'b1;
assign CPLD_PCH_INT_N         =  1'b1;
assign PMB_CLK = 1'b0;
assign FPGA_TXD_N = 1'b0;

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
// Module instantiation
//--------------------------------------------------------------------------
PwrSequence
    u_PwrSequence (.CLK_33K_SUSCLK_PLD_R2(CLK_33K_SUSCLK_PLD_R2),   // In
                   .RST_RSMRST_N(RST_RSMRST_N),                     // In
                   // ----------------------------
                   // PwrSeq control signals
                   // ----------------------------
                   .FM_BMC_ONCTL_N(FM_BMC_ONCTL_N),         // In
                   .FM_PS_EN(FM_PS_EN),                     // Out
                   .PWRGD_PS_PWROK_3V3(PWRGD_PS_PWROK_3V3), // In
                   .FM_SLPS3_N(FM_SLPS3_N),                 // In
                   .FM_SLPS4_N(FM_SLPS4_N),                 // In
                   // ----------------------------
                   // Clock enables
                   // ----------------------------
                   .FM_PLD_CLK_EN(FM_PLD_CLK_EN),   // Out
                   // ----------------------------
                   // Voltage regulator devices
                   // ----------------------------
                   .PWRGD_P1V05_STBY_PCH_P1V0_AUX(PWRGD_P1V05_STBY_PCH_P1V0_AUX),   // In
                   .PWRGD_P3V3_AUX(PWRGD_P3V3_AUX),                                 // In
                   .FM_P1V5_PCH_EN(FM_P1V5_PCH_EN),                                 // Out
                   .FM_VCC_MAIN_EN(FM_VCC_MAIN_EN),                                 // Out
                   .PWRGD_P1V5_PCH(PWRGD_P1V5_PCH),                                 // In
                   .PWRGD_P1V05_PCH(PWRGD_P1V05_PCH),                               // In
                   .PVCCIN_CPU0_EN(PVCCIN_CPU0_EN),                                 // Out
                   .PWRGD_PVCCIN_CPU0(PWRGD_PVCCIN_CPU0),                           // In
                   .FM_VPP_MEM_ABCD_EN(FM_VPP_MEM_ABCD_EN),                         // Out
                   .PWRGD_PVPP_PVDDQ_AB(PWRGD_PVPP_PVDDQ_AB),                       // In
                   .PWRGD_PVPP_PVDDQ_CD(PWRGD_PVPP_PVDDQ_CD),                       // In
                   .BCM_V1P0_EN(BCM_V1P0_EN),                                       // Out
                   .BCM_V1P0A_EN(BCM_V1P0A_EN),                                     // Out
                   .BCM_P1V_PG(BCM_P1V_PG),                                         // In
                   .BCM_P1VA_PG(BCM_P1VA_PG),                                       // In
                   // ----------------------------
                   // Presence signals
                   // ----------------------------
                   .FM_PCH_PRSNT_CO_N(FM_PCH_PRSNT_CO_N),               // In
                   .FM_CPU0_SKTOCC_LVT3_N(FM_CPU0_SKTOCC_LVT3_N),       // In
                   .FM_CPU0_BDX_PRSNT_LVT3_N(FM_CPU0_BDX_PRSNT_LVT3_N), // In
                   // ----------------------------
                   // Miscellaneous signals
                   // ----------------------------
                   .FM_THERMTRIP_CO_N(FM_THERMTRIP_CO_N),           // In
                   .FM_LVC3_THERMTRIP_DLY(FM_LVC3_THERMTRIP_DLY),   // Out
                   .IRQ_SML1_PMBUS_ALERT_BUF_N(1'b1),               // In,  IRQ_SML1_PMBUS_ALERT_BUF_N = 1
                   .IRQ_FAN_12V_GATE(),                             // Out, IRQ_FAN_12V_GATE :reserved pin
                   .FM_CPU_ERR1_CO_N(FM_CPU_ERR1_CO_N),             // In
                   .FM_ERR1_DLY_N(FM_ERR1_DLY_N),                   // Out
                   .RST_PLTRST_DLY(RST_PLTRST_DLY),                 // Out
                   .FM_PVTT_ABCD_EN(FM_PVTT_ABCD_EN),               // Out
                   // ----------------------------
                   // Power good signals
                   // ----------------------------
                   .PWRGD_P1V05_PCH_STBY_DLY(PWRGD_P1V05_PCH_STBY_DLY), // Out
                   .PWRGD_PCH_PWROK_R(PWRGD_PCH_PWROK_R),               // Out
                   .PWRGD_SYS_PWROK_R(PWRGD_SYS_PWROK_R),               // Out
                   .PWRGD_CPUPWRGD(PWRGD_CPUPWRGD),                     // In
                   .PWRGD_CPU0_LVC3_R(PWRGD_CPU0_LVC3_R),               // Out
                   // ----------------------------
                   // Reset signals
                   // ----------------------------
                   .RST_PLTRST_N(RST_PLTRST_N), // In
                   // ----------------------------
                   // ITP interface
                   // ----------------------------
                   .XDP_RST_CO_N(XDP_RST_CO_N),         // In
                   .XDP_PWRGD_RST_N(XDP_PWRGD_RST_N),   // In
                   .XDP_CPU_SYSPWROK(XDP_CPU_SYSPWROK), // In
                   // ----------------------------
                   // CPLD debug hooks
                   // ----------------------------
                   .FM_PLD_DEBUG_MODE_N(FM_PLD_DEBUG_MODE_N),   // In
                   .FM_PLD_DEBUG1(FM_PLD_DEBUG1),               // In
                   .FM_PLD_DEBUG2(FM_PLD_DEBUG2),               // Out
                   .FM_PLD_DEBUG3(FM_PLD_DEBUG3),               // Out
                   .FM_PLD_DEBUG4(FM_PLD_DEBUG4),               // Out
                   .FM_PLD_DEBUG5(FM_PLD_DEBUG5),               // Out
                   .PsonFromPwrEvent(1'b1));                    // In, Integration to MstrSeq.sv is not validated yet.

Lpc
    u_Lpc (.PciReset(RST_PLTRST_N),         // In, PCI Reset
           .LpcClock(CLK33M),            // In, 33 MHz Lpc (LPC Clock)
           .LpcFrame(LPC_FRAME_N),          // In, LPC Interface: Frame
           .LpcBus(LPC_LAD),                // In, LPC Interface: Data Bus
           .BiosStatus(BiosStatus),         // In, Bios status setup value
           .Wr(Wr),                         // Out, LPC register wtite
           .AddrReg(AddrReg),               // Out, register address
           .DataWr(DataWr),                 // Out, register write data
           .SystemOK(SystemOK),             // Out, System OK flag(software control)
           .x7SegSel(x7SegSel),             // Out, 7 Segment LED select
           .x7SegVal(x7SegVal),             // Out, 7 Segment LED value
           .WriteBiosWD(WriteBiosWD),       // Out, BIOS watch dog register write
           .BiosRegister(BiosRegister),     // Out, BIOS watch dog register
           .BiosPostData(BiosPostData));    // Out, 80 port data

ClockSource
    u_ClockSource (.HARD_nRESETi(RST_RSMRST_N), // In,
                   .LCLK_CPLD(LCLK_CPLD),       // In, 33MHz clock source from LPC
                   .MCLK_FPGA(MCLK_FPGA),       // In, 33MHz clock source from OSC
                   .Mclkx(CLK33M));             // Out, Clock Source output

BiosControl
    u_BiosControl (.ResetN(InitResetn),       // Power reset
                   .MainReset(!MainResetN),    // Power or Controller ICH10R Reset
                   .LpcClock(CLK33M),        // 33 MHz Lpc (Altera Clock)
                   .Write(Wr),                  // Write Access to CPLD registor
                   .BiosCS(SPI_PCH_CS0_N),      // ICH10 BIOS Chip Select (SPI Interface)
                   .BIOS_SEL(BIOS_SEL),         // BIOS SELECT  - Bios Select Jumper (default "1")
                   .SwapDisable(1'b0),          // Disable BIOS Swapping after Power Up
                   .ForceSwap(2'b00),           // BiosWD Occurred, Force BIOS Swap while power restart
                   .RegAddress(AddrReg),        // Address of the accessed Register
                   .DataWr(DataWr),             // Data to be written to CPLD Register
                   .BIOS(BIOS_CS_N),            // Chip Select to SPI Flash Memories
                   .BiosStatus(BiosStatus));    // BIOS status

HwResetGenerate
    u_HwResetGenerate (.HARD_nRESETi(RST_RSMRST_N), // In, P3V3_AUX power on reset input
                       .MCLKi(CLK33M),           // In, 33MHz input
                       .RSMRST_N(RST_RSMRST_N),     // In,
                       .PLTRST_N(RST_PLTRST_N),     // In,
                       .Reset1G(1'b1),              // In,
                       .ResetOut_ox(1'b1),          // In, From MR_Bsp, reset button pressed and retained 4 second, ResetOut_ox will be asserted.
                       .FM_PS_EN(FM_PS_EN),         // In,

                       .CLK32KHz(CLK32768),         // Out, 32.768KHz output from a divider
                       .InitResetn(InitResetn),     // Out, 941us assert duration ( Low active ) from ( HARD_nRESETi & RSMRST_N ) rising edge
                       .MainResetN(MainResetN),     // Out, MainResetN = InitResetn & PLTRST_N
                       .RST_CPU0_LVC3_N(),          // Out, Pin M14, to Circuit for fault trigger event ( back to CPLD )
                       .RST_PLTRST_BUF_N(),         // Out, Pin C15, to 07 gate buffer, then drive SIO6779, U5(PCA9548) and U57(EPM1270)
                       .RST_DLY_CPURST_LVC3(),      // Out, Pin G12, drive ProcHot circuit, During Reset assertion period, only allow CPU
                                                    //           ProcHot to be monitored, After reset de-assertion, CPU ProcHot and IR PWM
                                                    //           Hot signal are monitored.
                       .RST_PERST0_N(),             // Out, Pin L16, to 07 gate buffer, then drive J8 and J9 ( both are PCIe x8 slots )
                       .RST_BCM56842_N_R(),         // Out, Pin F16, to reset BCM56842
                       .RST_1G_N_R(),               // Out,
                       .SYS_RST_IN_SIO_N(),         // Out,
                       .RST_PCH_RSTBTN_N());        // Out,

Led7SegDecode
    u_Led7SegDecode (.ResetN(InitResetn),
                     .Mclk(CLK32768),
                     .ALL_PWRGD(PWRGD_CPUPWRGD),
                     .SystemOK(SystemOK),
                     .BiosFinished(BiosFinished),
                     .BiosPostData(BiosPostData),
                     .Strobe1ms(Strobe1ms),
                     .Strobe1s(Strobe1s),       // Single SlowClock Pulse @ 1 s
                     .Strobe125ms(Strobe125ms),    // Single SlowClock Pulse @ 125 ms
                     .BiosStatus(BiosStatus),
                     .x7SegSel(x7SegSel),
                     .x7SegVal(x7SegVal),

                     .PowerEvtState(4'h0),
                     .Led7En(LED7_digit),
                     .Led7Leg(LED7_SEG),

                     .FM_PLD_DEBUG2(FM_PLD_DEBUG2),  // FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode; from PwrSequence module
                     .FM_PLD_DEBUG3(FM_PLD_DEBUG3),
                     .FM_PLD_DEBUG4(FM_PLD_DEBUG4),
                     .FM_PLD_DEBUG5(FM_PLD_DEBUG5),
                     .PORT80_DP(LED7_SEGDP));

StrobeGen
  u_StrobeGen (.ResetN(InitResetn),             // In,
               .LpcClock(CLK33M),               // In, 33 MHz Lpc (Altera Clock)
               .SlowClock(CLK32768),            // In, Oscillator Clock 32,768 Hz
               .Strobe1s(Strobe1s),             // Out, Single SlowClock Pulse @ 1 s
               .Strobe488us(Strobe488us),       // Out, Single SlowClock Pulse @ 488 us
               .Strobe1ms(Strobe1ms),           // Out, Single SlowClock Pulse @ 1 ms
               .Strobe16ms(Strobe16ms),         // Out, Single SlowClock Pulse @ 16 ms
               .Strobe125ms(Strobe125ms),       // Out, Single SlowClock Pulse @ 125 ms
               .Strobe125msec(Strobe125msec),   // Out, Single LpcClock  Pulse @ 125 ms
               .Counter(Counter));              // Out, 15 bit Free run Counter on Slow Clock

BiosWatchDog
  u_BiosWatchDog (.Reset(InitResetn),               // In, Generated PowerUp Reset
                  .SlowClock(CLK32768),             // In, Oscillator Clock 32,768 Hz
                  .LpcClock(CLK33M),                // In, 33 MHz Lpc (Altera Clock)
                  .MainReset(MainResetN),           // In, Power or Controller ICH10R Reset
                  .PS_ONn(FM_PS_EN),                // In,
                  .DPx(),                           // Out,
                  .Strobe125msec(Strobe125msec),    // In, Single LpcClock  Pulse @ 125 ms
                  .WriteBiosWD(WriteBiosWD),        // In, CPU (BIOS) writes to BIOS WD Register (#1)
                  .BiosRegister(BiosRegister),      // In, Bios Watch Dog Control Register
                  .BiosFinished(BiosFinished),      // Out, Bios Has been finished
                  .BiosPowerOff(BiosPowerOff),      // Out, BiosWD Occurred, Force Power Off
                  .ForceSwap(ForceSwap));           // Out, BiosWD Occurred, Force BIOS Swap while power restart

endmodule  // end of ODS_MR,  top  module of this project
