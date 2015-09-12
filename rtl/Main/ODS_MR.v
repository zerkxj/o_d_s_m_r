//////////////////////////////////////////////////////////////////////////////
// File name        : ODS_MR.v
// Module name      : ODS_MR, top module of COB-G503
// Description      : PwrSequence, Reset Control,  Pwr/Reset Button control,
//                    Dual BIOS control, LPC decode
// Hierarchy Up     : ---
// Hierarchy Down   : PwrSequence
//                    Lpc
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"
//////////////////////////////////////////////////////////////////////////////
//
//(1) Stage 1 : powersequence
//(2) Stage 2 : LPC register read/write
//(3) Stage 3 : dual BIOS
//
//////////////////////////////////////////////////////////////////////////////
module ODS_MR (
    CLK_33K_SUSCLK_PLD_R2,  //  32.768KHz from PCH SUSCLK output.
    RST_RSMRST_N,
    // ----------------------------
    // PwrSeq control signals
    // ----------------------------
    FM_BMC_ONCTL_N, // No BMC, use SIO_PS_ON_N that is an output from SIO
    FM_PS_EN,
    PWRGD_PS_PWROK_3V3,
    FM_SLPS3_N,
    FM_SLPS4_N,
    // ----------------------------
    // Clock enables
    // ----------------------------
    FM_PLD_CLK_EN,
    // ----------------------------
    // Voltage regulator devices
    // ----------------------------
    PWRGD_P1V05_STBY_PCH_P1V0_AUX,
    PWRGD_P3V3_AUX,
    FM_P1V5_PCH_EN,
    FM_VCC_MAIN_EN,
    PWRGD_P1V5_PCH,
    PWRGD_P1V05_PCH,
    PVCCIN_CPU0_EN,
    PWRGD_PVCCIN_CPU0,
    FM_VPP_MEM_ABCD_EN,
    PWRGD_PVPP_PVDDQ_AB,
    PWRGD_PVPP_PVDDQ_CD,
    BCM_V1P0_EN,
    BCM_V1P0A_EN,
    BCM_P1V_PG,
    BCM_P1VA_PG,
    // ----------------------------
    // Presence signals
    // ----------------------------
    FM_PCH_PRSNT_CO_N,
    FM_CPU0_SKTOCC_LVT3_N,
    FM_CPU0_BDX_PRSNT_LVT3_N,
    // ----------------------------
    // Miscellaneous signals
    // ----------------------------
    FM_THERMTRIP_CO_N,
    FM_LVC3_THERMTRIP_DLY,
    IRQ_SML1_PMBUS_ALERT_BUF_N, //  Always High signal input on G503
    IRQ_FAN_12V_GATE,           //  Reserved Output pin
    FM_CPU_ERR1_CO_N,
    FM_ERR1_DLY_N,
    RST_PLTRST_DLY,             // for pltrst_dly
    FM_PVTT_ABCD_EN,
    // ----------------------------
    // Power good reset signals
    // ----------------------------
    PWRGD_P1V05_PCH_STBY_DLY,
    PWRGD_PCH_PWROK_R,
    PWRGD_SYS_PWROK_R,
    PWRGD_CPUPWRGD,
    PWRGD_CPU0_LVC3_R,
    // ----------------------------
    // Reset signals
    // ----------------------------
    RST_PLTRST_N,
// Below Reset signals are not utilized by PwrSequence module.
//////////////////////////////////////////////////////////////////////////////
    RST_CPU0_LVC3_N,        // in HwResetGenerate module or directly assigned
    RST_PLTRST_BUF_N,       // in HwResetGenerate module or directly assigned
    RST_DLY_CPURST_LVC3,    // in HwResetGenerate module or directly assigned
    RST_PERST0_N,           // in HwResetGenerate module or directly assigned
    FM_PERST_SRC_LVT3,      // PCIe Reset source select, reserved pin
    RST_PCIE_PCH_N,         // Input, from PCH GPIO19 output, reserved to gate control PCIe device reset signal
    RST_PCIE_CPU_N,         // Input, from PCH GPIO11 output, reserved to gate control PCIe device reset signal
//////////////////////////////////////////////////////////////////////////////
    // ----------------------------
    // ITP interface
    // ----------------------------
    XDP_RST_CO_N,
    XDP_PWRGD_RST_N,
    XDP_CPU_SYSPWROK,
    // ----------------------------
    // CPLD debug hooks
    // ----------------------------
    FM_PLD_DEBUG_MODE_N,
    FM_PLD_DEBUG1,

    SPI_PCH_CS0_N,          // BiosCS# from PCH;
    BIOS_CS_N,              // Chip Select to SPI Flash Memories
    BIOS_LED_N,             // point current BIOS
    FM_SYS_SIO_PWRBTN_N,    // (Debounced) Power Button output to SIO
    PWR_BTN_IN_N,           // Power Button input
    SYS_RST_IN_N,           // Reset Button input
    RST_PCH_RSTBTN_N,       // Reset out to PCH
    RST_BCM56842_N_R,       // Reset signal for BCM56842
    RST_1G_N_R,             // Reset signal for I211
    RST_DME_N,              // Reset Signal for DME
    UNLOCK_BIOS_ME,         // for PCH ME unlock
    LAN_ACT_N,              // RJ45PActivity, LAN --> CPLD
    LAN_LINK1000_N,         // RJ45Speed1P, LAN --> CPLD
    LAN_LINK100_N,          // RJ45Speed2P, LAN --> CPLD
    CPLD_LAN_LINK1000_N,    // RJ45Speed1R, CPLD --> RJ45 LED
    CPLD_LAN_LINK100_N,     // RJ45Speed2R,  CPLD --> RJ45 LED
    MCLK_FPGA,  // Main Clock input of 33Mhz
    LCLK_CPLD,
    LPC_FRAME_N,
    LPC_LAD,
    CPLD_LAN_ACT_N  // RJ45RActivity,  CPLD --> RJ45 LED
);

//--------------- PwrSequence pin declaration ----------------
input           CLK_33K_SUSCLK_PLD_R2;
input           RST_RSMRST_N;
// ----------------------------
// PwrSeq control signals
// ----------------------------
input           FM_BMC_ONCTL_N;
output          FM_PS_EN;
input           PWRGD_PS_PWROK_3V3;
input           FM_SLPS3_N;
input           FM_SLPS4_N;
// ----------------------------
// Clock enables
// ----------------------------
output          FM_PLD_CLK_EN;
// ----------------------------
// Voltage regulator devices
// ----------------------------
input           PWRGD_P1V05_STBY_PCH_P1V0_AUX;
input           PWRGD_P3V3_AUX;
output          FM_P1V5_PCH_EN;
output          FM_VCC_MAIN_EN;
input           PWRGD_P1V5_PCH;
input           PWRGD_P1V05_PCH;
output          PVCCIN_CPU0_EN;
input           PWRGD_PVCCIN_CPU0;
output          FM_VPP_MEM_ABCD_EN;
input           PWRGD_PVPP_PVDDQ_AB;
input           PWRGD_PVPP_PVDDQ_CD;
output          BCM_V1P0_EN;
output          BCM_V1P0A_EN;
input           BCM_P1V_PG;
input           BCM_P1VA_PG;
// ----------------------------
// Presence signals
// ----------------------------
input           FM_PCH_PRSNT_CO_N;
input           FM_CPU0_SKTOCC_LVT3_N;
input           FM_CPU0_BDX_PRSNT_LVT3_N;
// ----------------------------
// Miscellaneous signals
// ----------------------------
input           FM_THERMTRIP_CO_N;
output          FM_LVC3_THERMTRIP_DLY;
input           IRQ_SML1_PMBUS_ALERT_BUF_N;
output          IRQ_FAN_12V_GATE;
input           FM_CPU_ERR1_CO_N;
output          FM_ERR1_DLY_N;
output          RST_PLTRST_DLY;
output          FM_PVTT_ABCD_EN;
// ----------------------------
// Power good reset signals
// ----------------------------
output          PWRGD_P1V05_PCH_STBY_DLY;
output          PWRGD_PCH_PWROK_R;
output          PWRGD_SYS_PWROK_R;
input           PWRGD_CPUPWRGD;
output          PWRGD_CPU0_LVC3_R;
// ----------------------------
// Reset signals
// ----------------------------
input           RST_PLTRST_N;
output          RST_CPU0_LVC3_N;
output          RST_PLTRST_BUF_N;
output          RST_DLY_CPURST_LVC3;
output          RST_PERST0_N;
input           FM_PERST_SRC_LVT3;
input           RST_PCIE_PCH_N;
input           RST_PCIE_CPU_N;
// ----------------------------
// ITP interface
// ----------------------------
input           XDP_RST_CO_N;
input           XDP_PWRGD_RST_N;
input           XDP_CPU_SYSPWROK;
// ----------------------------
// CPLD debug hooks
// ----------------------------
input           FM_PLD_DEBUG_MODE_N;
input           FM_PLD_DEBUG1;
// ----------------------------

output  [1:0]   BIOS_CS_N;
input           SPI_PCH_CS0_N;          // BiosCS# from PCH
output  [1:0]   BIOS_LED_N;
output          FM_SYS_SIO_PWRBTN_N;
output          RST_PCH_RSTBTN_N;
input           SYS_RST_IN_N;
input           PWR_BTN_IN_N;           //  PowerButtonIn;
input   [1:0]   LAN_ACT_N;              //  RJ45PActivity;
input   [1:0]   LAN_LINK1000_N;         //  RJ45Speed1P;
input   [1:0]   LAN_LINK100_N;          //  RJ45Speed2P;
output  [1:0]   CPLD_LAN_LINK1000_N;    //  RJ45Speed1R;
output  [1:0]   CPLD_LAN_LINK100_N;     //  RJ45Speed2R;
output  [1:0]   CPLD_LAN_ACT_N;         //  RJ45RActivity;
output          RST_BCM56842_N_R;
output          RST_1G_N_R;
output          RST_DME_N;
output          UNLOCK_BIOS_ME;

input           MCLK_FPGA;      // 33MHz
input           LCLK_CPLD;      // LPC bus clock
input           LPC_FRAME_N;
inout   [3:0]   LPC_LAD;
////////////////////////////////////////////////////////////////////////////
wire            FM_PLD_DEBUG2;
wire            FM_PLD_DEBUG3;
wire            FM_PLD_DEBUG4;
wire            FM_PLD_DEBUG5;

wire            Next_Bios_latch;
wire            Next_Bios;
wire            Active_Bios;

////////////////////////////////////////////////////////////////////////////
/////         Module Instantiation
////////////////////////////////////////////////////////////////////////////
PwrSequence
    u_PwrSequence (.CLK_33K_SUSCLK_PLD_R2           (CLK_33K_SUSCLK_PLD_R2),            // In
                   .RST_RSMRST_N                    (RST_RSMRST_N),                     // In
                   // ----------------------------
                   // PwrSeq control signals
                   // ----------------------------
                   .FM_BMC_ONCTL_N                  (FM_BMC_ONCTL_N),                   // In
                   .FM_PS_EN                        (FM_PS_EN),                         // Out
                   .PWRGD_PS_PWROK_3V3              (PWRGD_PS_PWROK_3V3),               // In
                   .FM_SLPS3_N                      (FM_SLPS3_N),                       // In
                   .FM_SLPS4_N                      (FM_SLPS4_N),                       // In
                   // ----------------------------
                   // Clock enables
                   // ----------------------------
                   .FM_PLD_CLK_EN                   (FM_PLD_CLK_EN),                    // Out
                   // ----------------------------
                   // Voltage regulator devices
                   // ----------------------------
                   .PWRGD_P1V05_STBY_PCH_P1V0_AUX   (PWRGD_P1V05_STBY_PCH_P1V0_AUX),    // In
                   .PWRGD_P3V3_AUX                  (PWRGD_P3V3_AUX),                   // In
                   .FM_P1V5_PCH_EN                  (FM_P1V5_PCH_EN),                   // Out
                   .FM_VCC_MAIN_EN                  (FM_VCC_MAIN_EN),                   // Out
                   .PWRGD_P1V5_PCH                  (PWRGD_P1V5_PCH),                   // In
                   .PWRGD_P1V05_PCH                 (PWRGD_P1V05_PCH),                  // In
                   .PVCCIN_CPU0_EN                  (PVCCIN_CPU0_EN),                   // Out
                   .PWRGD_PVCCIN_CPU0               (PWRGD_PVCCIN_CPU0),                // In
                   .FM_VPP_MEM_ABCD_EN              (FM_VPP_MEM_ABCD_EN),               // Out
                   .PWRGD_PVPP_PVDDQ_AB             (PWRGD_PVPP_PVDDQ_AB),              // In
                   .PWRGD_PVPP_PVDDQ_CD             (PWRGD_PVPP_PVDDQ_CD),              // In
                   .BCM_V1P0_EN                     (BCM_V1P0_EN),                      // Out
                   .BCM_V1P0A_EN                    (BCM_V1P0A_EN),                     // Out
                   .BCM_P1V_PG                      (BCM_P1V_PG),                       // In
                   .BCM_P1VA_PG                     (BCM_P1VA_PG),                      // In
                   // ----------------------------
                   // Presence signals
                   // ----------------------------
                   .FM_PCH_PRSNT_CO_N               (FM_PCH_PRSNT_CO_N),                // In
                   .FM_CPU0_SKTOCC_LVT3_N           (FM_CPU0_SKTOCC_LVT3_N),            // In
                   .FM_CPU0_BDX_PRSNT_LVT3_N        (FM_CPU0_BDX_PRSNT_LVT3_N),         // In
                   // ----------------------------
                   // Miscellaneous signals
                   // ----------------------------
                   .FM_THERMTRIP_CO_N               (FM_THERMTRIP_CO_N),                // In
                   .FM_LVC3_THERMTRIP_DLY           (FM_LVC3_THERMTRIP_DLY),            // Out
                   .IRQ_SML1_PMBUS_ALERT_BUF_N      (1'b1),                             // In,  IRQ_SML1_PMBUS_ALERT_BUF_N = 1
                   .IRQ_FAN_12V_GATE                (),                                 // Out, IRQ_FAN_12V_GATE :reserved pin
                   .FM_CPU_ERR1_CO_N                (FM_CPU_ERR1_CO_N),                 // In
                   .FM_ERR1_DLY_N                   (FM_ERR1_DLY_N),                    // Out
                   .RST_PLTRST_DLY                  (RST_PLTRST_DLY),                   // Out
                   .FM_PVTT_ABCD_EN                 (FM_PVTT_ABCD_EN),                  // Out
                   // ----------------------------
                   // Power good signals
                   // ----------------------------
                   .PWRGD_P1V05_PCH_STBY_DLY        (PWRGD_P1V05_PCH_STBY_DLY),         // Out
                   .PWRGD_PCH_PWROK_R               (PWRGD_PCH_PWROK_R),                // Out
                   .PWRGD_SYS_PWROK_R               (PWRGD_SYS_PWROK_R),                // Out
                   .PWRGD_CPUPWRGD                  (PWRGD_CPUPWRGD),                   // In
                   .PWRGD_CPU0_LVC3_R               (PWRGD_CPU0_LVC3_R),                // Out
                   // ----------------------------
                   // Reset signals
                   // ----------------------------
                   .RST_PLTRST_N                    (RST_PLTRST_N),                     // In
                   // ----------------------------
                   // ITP interface
                   // ----------------------------
                   .XDP_RST_CO_N                    (XDP_RST_CO_N),                     // In
                   .XDP_PWRGD_RST_N                 (XDP_PWRGD_RST_N),                  // In
                   .XDP_CPU_SYSPWROK                (XDP_CPU_SYSPWROK),                 // In
                   // ----------------------------
                   // CPLD debug hooks
                   // ----------------------------
                   .FM_PLD_DEBUG_MODE_N             (FM_PLD_DEBUG_MODE_N),              // In
                   .FM_PLD_DEBUG1                   (FM_PLD_DEBUG1),                    // In
                   .FM_PLD_DEBUG2                   (FM_PLD_DEBUG2),                    // Out
                   .FM_PLD_DEBUG3                   (FM_PLD_DEBUG3),                    // Out
                   .FM_PLD_DEBUG4                   (FM_PLD_DEBUG4),                    // Out
                   .FM_PLD_DEBUG5                   (FM_PLD_DEBUG5),                    // Out
                   .PsonFromPwrEvent                (PsonFromPwrEvent));                // In, Integration to MstrSeq.sv is not validated yet.

assign  FM_SYS_SIO_PWRBTN_N    =  PWR_BTN_IN_N;     // PWR_BTN_IN_N is not controlled.
assign  RST_PCH_RSTBTN_N       =  SYS_RST_IN_N;     // SYS_RST_IN_N is not controlled.
//assign  BIOS_CS_N[0]           =  Active_Bios ? 1'b1 : 1'b0;
//assign  BIOS_CS_N[1]           =  Active_Bios ? 1'b0 : 1'b1;
assign  BIOS_LED_N[0]          =  1'b0;
assign  BIOS_LED_N[1]          =  1'b1;
assign  RST_PLTRST_BUF_N       =  RST_PLTRST_N;
assign  RST_PERST0_N           =  RST_PLTRST_N;
assign  RST_BCM56842_N_R       =  RST_PLTRST_N;
assign  RST_CPU0_LVC3_N        =  RST_PLTRST_N;
assign  RST_DLY_CPURST_LVC3    =  RST_PLTRST_N;
assign  RST_1G_N_R             =  RST_PLTRST_N;
assign  RST_DME_N              =  RST_PLTRST_N;
assign  CPLD_LAN_LINK1000_N[0] =  LAN_LINK100_N[0];
assign  CPLD_LAN_LINK100_N[0]  =  LAN_LINK1000_N[0];
assign  CPLD_LAN_LINK1000_N[1] =  LAN_LINK100_N[1];
assign  CPLD_LAN_LINK100_N[1]  =  LAN_LINK1000_N[1];
assign  CPLD_LAN_ACT_N[0]      =  2'b11 == {LAN_LINK1000_N[0], LAN_LINK100_N[0]} ? 1'b1 : ~LAN_ACT_N[0];
assign  CPLD_LAN_ACT_N[1]      =  2'b11 == {LAN_LINK1000_N[1], LAN_LINK100_N[1]} ? 1'b1 : ~LAN_ACT_N[1];
assign  UNLOCK_BIOS_ME         =  1'bz;
assign  CPLD_PCH_INT_N         =  1'b1;

Lpc
    u_Lpc (.PciReset(RST_PLTRST_N),             // PCI Reset
           .LpcClock(MCLK_FPGA),                // 33 MHz Lpc (LPC Clock)
           .LpcFrame(LPC_FRAME_N),              // LPC Interface: Frame
           .LpcBus(LPC_LAD),                    // LPC Interface: Data Bus
           .Next_Bios_latch(Next_Bios_latch),   // Next BIOS number after reset
           .Next_Bios(Next_Bios),               // Next BIOS number after reset
           .Active_Bios(Active_Bios));          // BIOS number of current active

BiosControl
    u_BiosControl (.PciReset(RST_PLTRST_N),             // reset
                   .Pwr_ok(PWRGD_PS_PWROK_3V3),         // power is available
                   .Next_Bios(Next_Bios),               // Next BIOS number after reset
                   .Active_Bios(Active_Bios),           // BIOS current active
                   .Next_Bios_latch(Next_Bios_latch),   // Next BIOS number after reset
                   .BIOS_CS_N(BIOS_CS_N));               // BIOS chip select

endmodule  // end of ODS_MR,  top  module of this project
