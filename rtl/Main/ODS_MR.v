//////////////////////////////////////////////////////////////////////////////
// File name        : ODS_MR.v
// Module name      : ODS_MR, top module of COB-G503
// Description      : PwrSequence, Reset Control,  Pwr/Reset Button control,
//                    Dual BIOS control, LPC decode, 7Seg LED decode.
// Hierarchy Up     : ---
// Hierarchy Down   : PwrSequence
//                    Lpc
//                    LpcReg
//                    UFMRwPageDecode
//                    MR_Bsp
//                    HwResetGenerate
//                    GLANLED_2Port
//                    DualPSCfg
//                    PwrEvent
//                    StrobeGen
//                    ClockSource
//                    OffLEDwhenPwrOff
//                    BiosWdtDecode
//                    PwrBtnControl
//                    DMEInit
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"
//////////////////////////////////////////////////////////////////////////////
//
//(1) Stage 1 :
//    if define ONLY_PowerUp, Only PwrSequence module will be instantiated with some additional assignments
//    if No definition of ONLY_PowerUp, all modules will be instantiated.
//(2) Stage 2 :
//    if define RdWrCpldReg, only PwrSequence,LpcDecode, CpldRegMap and ClockSource will be instantiated with some additional assignments
//    Once RdWrCpldReg is defined, ONLY_PowerUp will be defined,too.
//
//////////////////////////////////////////////////////////////////////////////
// ***** ifdef_4 ************************************************************
`ifdef  DualBIOS            // Stage 3, Dual BIOS
`define ONLY_PowerUp    1   // Original definition has been moved to DefineODSTextMacro.v
`define RdWrCpldReg     1   // Original definition has been moved to DefineODSTextMacro.v
`endif
// ***** End of ifdef_4 *****************************************************
//////////////////////////////////////////////////////////////////////////////
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
// ===============================================================
// ***** ifdef_1 ************************************************************
`ifdef ONLY_PowerUp
// Only PwrSequence module will be instantiated with some additional assignments
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
// ***** ifdef_5 ************************************************************
`ifdef RdWrCpldReg
    MCLK_FPGA,  // Main Clock input of 33Mhz
    LCLK_CPLD,
    LPC_FRAME_N,
    LPC_LAD,
`endif
// ***** End of ifdef_5 *****************************************************
    CPLD_LAN_ACT_N  // RJ45RActivity,  CPLD --> RJ45 LED
// ***** else of ifdef_1 ****************************************************
`else
//  All modules will be instantiated
    HARD_nRESETi,
    MCLK_FPGA,      // Main Clock input of 33Mhz
    CLK36864,       // CLK1843K2,  change name to CLK36864
    LCLK_CPLD,
//-    lreset_n,
    LPC_FRAME_N,
    LPC_LAD,
    RST_1G_N_R,
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
    DualPS,                 // Board Jumper - points to Dual Power Supply if "1"
    PSU_status,             // Dual Power Supply Status, Normal: 1, Fail: 0
    SYS_LEDG_N,             // System LED: Green Anode
    SYS_LEDR_N,             // System LED: Green Cathode
    PSU_Normal_N,           // Power LED active "1/0" Green/Red Control
    PSU_Fail_N,             // Power LED active "0/1" Green/Red Control
    SYS_RST_IN_N,           // Reset Button input
    PWR_BTN_IN_N,           // Power Button input
    FM_SYS_SIO_PWRBTN_N,    // (Debounced) Power Button output to SIO
    RST_PCH_RSTBTN_N,       // Reset button out to PCH,  Active Wide Strobe 4s after reset button pressed
    SYS_RST_IN_SIO_N,       // pass through of RST_PCH_RSTBTN_N
    CPLD_PCH_INT_N,         // InterruptD, change name to CPLD_PCH_INT_N
    SPI_PCH_CS0_N,          // BIOSCS# from PCH
    BIOS_SEL,
    BIOS_CS_N,              // Chip Select to SPI Flash Memories
    BIOS_LED_N,             // LED to point current BIOS
    LED7_digit,             // 7Seg LED enable pins, Verilog_[5:0] = sch_[6:1]
    LED7_SEG,               // 7Seg LED pins, LED7_SEGA=SEG[0],..., SEGG=SEG[6]
    SIO_BEEP,               // SIO_BEEP
    GPIO15_FAN_Fail_N,      // Fan Fail - 1, FanOK - 0; - has internal weak P/U
    FAN_PRSNT_N,            // FanPresences,  //Fan Presence 1 2 3
    FAN_LEDR_N,             // Fan Led indication
    FAN_LEDG_N,             // Fan Led indication
///////////////////////////////////////////////////////////////////
// LEDS RJ45
// change name as below 6 groups of pins :
    LAN_ACT_N,              // RJ45PActivity, LAN --> CPLD
    LAN_LINK1000_N,         // RJ45Speed1P,   LAN --> CPLD
    LAN_LINK100_N,          // RJ45Speed2P,   LAN --> CPLD
    CPLD_LAN_LINK1000_N,    // RJ45Speed1R,   CPLD --> RJ45 LED
    CPLD_LAN_LINK100_N,     // RJ45Speed2R,   CPLD --> RJ45 LED
    CPLD_LAN_ACT_N,         // RJ45RActivity, CPLD --> RJ45 LED
////////////////////////////////////////////////////////////////////
// changed name to PMB_CLK and PMB_DATA
// Could be hard core Via WISHBONE or I2C master via master core
// Reserved for PM BUS
////////////////////////////////////////////////////////////////////
    PMB_CLK,
    PMB_DATA,
    FPGA_TXD_N,
    FPGA_RXD_N,
    LED7_SEGDP,         // For PwrSequence state machine display
    RST_BCM56842_N_R,   // output
// DME Interface
    DMEStatus,          // input [5:0]
    DMEControl,         // output [5:0]
    DMEID,              // input [3:0]
    DME_PWRGD,          // input, Need to included into ALL_PWRGD, PwrSequence
    DME_Absent,         // input High DME is absent; high : DME exists.
    RST_DME_N,          // Output
//  === Below pins are not coded yet ===
    FpgaGPIO,                       // inout [8:0]
    UNLOCK_BIOS_ME,                 // output,  AUD_AZA_ADO, dual BIOS control for ME update
    PWRGD_VCCST3_3,                 // input
    PWRGD_PVCCIO,                   // input
    H_CPU0_MEMAB_MEMHOT_LVT3_N,     // input
    H_CPU0_MEMCD_MEMHOT_LVT3_N,     // input
    FM_MEM_THERM_EVENT_LVT3_N,      // input
    FM_CPU0_FIVR_FAULT_LVT3_N,      // input
    FM_CPU_ERR2_CO_N,               // input
    FM_CPU0_THERMTRIP_LATCH_LVC3_N, // input
    FM_CPU0_PROCHOT_LVT3_N,         // input
    PCH_GPIO8,                      // input
    PCH_GPIO25,                     // input
    PCH_GPIO34                      // input
`endif
// ***** End of ifdef_1 *****************************************************
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
// ---------------PwrSequence pin declaration ends -----
////////////////////////////////////////////////////////////////////////
// ***** ifdef_2 ************************************************************
`ifdef ONLY_PowerUp
// Only PwrSequence module will be instantiated with some additional assignments
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
// ***** ifdef_6 ************************************************************
`ifdef RdWrCpldReg
input           MCLK_FPGA;      // 33MHz
input           LCLK_CPLD;      // LPC bus clock
input           LPC_FRAME_N;
inout   [3:0]   LPC_LAD;
`endif
// ***** End of ifdef_6 *****************************************************
//
// ***** else of ifdef_2 ****************************************************
`else
// All modules will be instantiated
input           HARD_nRESETi;           // hardware reset
input           MCLK_FPGA;              // 33MHz
input           CLK36864;
input           LCLK_CPLD;              // LPC bus clock
//- input       lreset_n;               // LPC bus reset signal, = RST_PLTRST_N
input           LPC_FRAME_N;
inout   [3:0]   LPC_LAD;
output          RST_1G_N_R;
input           DualPS;
input   [1:0]   PSU_status;             // ZippyStatus;
output          SYS_LEDG_N;
output          SYS_LEDR_N;
output  [1:0]   PSU_Normal_N;
output  [1:0]   PSU_Fail_N;
input           SYS_RST_IN_N;           // Reset button inputs
input           PWR_BTN_IN_N;           // Power button inputs
output          FM_SYS_SIO_PWRBTN_N;    // PowerButtonOut to SIO
output          RST_PCH_RSTBTN_N;       // Reset button out to PCH
output          SYS_RST_IN_SIO_N;       // same as RST_PCH_RSTBTN_N
output          CPLD_PCH_INT_N;         // InterruptD
input           SPI_PCH_CS0_N;          // BiosCS# from PCH
input           BIOS_SEL;
output  [1:0]   BIOS_CS_N;
output  [1:0]   BIOS_LED_N;
output  [5:0]   LED7_digit;             // Led7En;
output  [6:0]   LED7_SEG;               // Led7Leg;
input           SIO_BEEP;
input           GPIO15_FAN_Fail_N;      // FanState;  Fan Fail - 1, FanOK - 0; - has internal weak P/U
input   [2:0]   FAN_PRSNT_N;            // FanPresences
output          FAN_LEDR_N;             // FanFail,Fan Led indication
output          FAN_LEDG_N;             // FanOK,     Fan Led indication
//LEDS RJ45
// change name as below 6 groups of pins
input   [1:0]   LAN_ACT_N;              // RJ45PActivity;
input   [1:0]   LAN_LINK1000_N;         // RJ45Speed1P;
input   [1:0]   LAN_LINK100_N;          // RJ45Speed2P;
output  [1:0]   CPLD_LAN_LINK1000_N;    // RJ45Speed1R;
output  [1:0]   CPLD_LAN_LINK100_N;     // RJ45Speed2R;
output  [1:0]   CPLD_LAN_ACT_N;         // RJ45RActivity;
output          PMB_CLK;                // I2C0_SCL;
inout           PMB_DATA;               // I2C0_SDA;
output          FPGA_TXD_N;             // UART_TX;
input           FPGA_RXD_N;             // UART_RX;
////////////////////////////////////////////////////////////////////////////////
// LED7_SEGDP output pin, High : turn on LED DP of 7Seg of Port80
//                          Low : Turn off LED DP of 7Seg of Port80
// During PLTRST# assertion period, LED7_SEGDP will be "high", after de-assertion of
// of PLTRST#, it will be low.
///////////////////////////////////////////////////////////////////////////////
output          LED7_SEGDP;
output          RST_BCM56842_N_R;
////////////////////////////////////////////////////////////////////////////
input   [5:0]   DMEStatus;        //
output  [5:0]   DMEControl;       //
input   [3:0]   DMEID;            //
input           DME_PWRGD;        //
input           DME_Absent;       //
output          RST_DME_N;        //
// =============================================================
// *************************************************************
//  Below pins are not coded yet ===
inout   [8:0]   FpgaGPIO;                       //
output          UNLOCK_BIOS_ME;                 // AUD_AZA_ADO, dual BIOS control for ME update
input           PWRGD_VCCST3_3;                 // reserved
input           PWRGD_PVCCIO;                   // reserved
input           H_CPU0_MEMAB_MEMHOT_LVT3_N;     //
input           H_CPU0_MEMCD_MEMHOT_LVT3_N;     //
input           FM_MEM_THERM_EVENT_LVT3_N;      //
input           FM_CPU0_FIVR_FAULT_LVT3_N;      //
input           FM_CPU_ERR2_CO_N;               //
input           FM_CPU0_THERMTRIP_LATCH_LVC3_N; //
input           FM_CPU0_PROCHOT_LVT3_N;         //
input           PCH_GPIO8;                      //
input           PCH_GPIO25;                     //
input           PCH_GPIO34;                     //
// =============================================================
// *************************************************************
`endif
// ***** End of ifdef_2 *****************************************************
////////////////////////////////////////////////////////////////
wire            FM_PLD_DEBUG2;
wire            FM_PLD_DEBUG3;
wire            FM_PLD_DEBUG4;
wire            FM_PLD_DEBUG5;
// ***** ifdef_7 ************************************************************
`ifdef RdWrCpldReg
wire            DevCs_En;
wire            RdDev_En;
wire            WrDev_En;
wire    [7:0]   WrDev_Data;
wire    [7:0]   RdDev_Data_b;
wire    [15:0]  DevAddr;
wire            Mclkx;
`endif
// ***** End of ifdef_7 *****************************************************
`ifdef DualBIOS
wire            Active_Bios;
`endif
// ***** ifndef_n1 **********************************************************
`ifndef ONLY_PowerUp
// All modules will be instantiated
wire            LED7_SEGDP;
wire            DevCs_En;
wire            RdDev_En;
wire            WrDev_En;
wire    [7:0]   WrDev_Data;
wire    [7:0]   RdDev_Data_b;
wire    [15:0]  DevAddr;
wire            CLK32768;               // Generated 32.768KHz
wire    [5:0]   LED7_digit;             // Led7En;
wire    [6:0]   LED7_SEG;               // Led7Leg;
wire            FAN_LEDR_N;             // FanFail; Fan Led indication
wire            FAN_LEDG_N;             // FanOK;  Fan Led indication
wire            FanFail_ox;             // Fan Led indication
wire            FanOK_ox;               // Fan Led indication
wire            Strobe1s;
wire            Strobe1ms;
wire            Strobe16ms;
wire            Strobe125ms;
wire            Strobe488us;
wire    [14:0]  CounterStrobe;
wire            Strobe125msec;
wire            CPLD_PCH_INT_N;         // InterruptD;
wire    [1:0]   BIOS_CS_N;
wire    [1:0]   BIOS_LED_N;
wire            SYS_LEDG_N;
wire            SYS_LEDR_N;
wire    [1:0]   PSU_Normal_N;           // PowerNormal; Right
wire    [1:0]   PSU_Fail_N;             // PowerFail; Left
wire            SysLedG_ox;
wire            SysLedR_ox;
wire    [1:0]   PowerNormal_ox;         // Right
wire    [1:0]   PowerFail_ox;           // Left
wire            FM_SYS_SIO_PWRBTN_N;    // PowerButtonOut
wire    [1:0]   CPLD_LAN_LINK1000_N;    // RJ45Speed1R;
wire    [1:0]   RJ45Speed1R_ox;
wire    [1:0]   CPLD_LAN_LINK100_N;     // RJ45Speed2R;
wire    [1:0]   RJ45Speed2R_ox;
wire    [1:0]   CPLD_LAN_ACT_N;         // RJ45RActivity;
wire    [1:0]   RJ45RActivity_ox;
//-----------------------------------
wire            MainResetN;
wire            Reset1G_ox;
wire            FM_PS_EN;               // "High Active", needs an external inverter to drive PSU PS_ON_N signal
wire            InitResetN;
wire            PwrLastStateWrBit;
wire    [31:0]  odsRdCfgData;
wire    [7:0]   BiosPostData;
wire    [3:0]   PowerEvtState;
wire            bRdIntFlashPwrEvtCfg;
wire            bWrIntFlashPwrEvtCfg;
wire            bPowerEvtFlashReq;
wire            bPwrSystemReset;
wire    [3:0]   LPC_LAD;
wire            FPGA_TXD_N;
wire            UART_CTS;
wire            PMB_CLK;
wire            PMB_DATA;
wire            bRdIntFlashDualPsCfg;
wire            bWrIntFlashDualPsCfg;
wire            bDualPSFlashReq;
wire    [2:0]   PsDbgP;
wire            DualPSCfgWrBit;
wire    [7:0]   SpecialCmdReg;
wire            PowerbuttonEvtOut;
wire            PowerButtonOut_ox;
wire            ResetOut_ox;
wire            PowerOff;
wire            SystemOK;
wire    [3:0]   BspDbgP;
wire    [3:0]   EvpDbgP;
wire            RstBiosFlg;
wire            Mclkx;
wire    [4:0]   bCPUWrWdtRegSig;        // From BiosWdtDecode to PwrEvent
                                        // reg --> wire, bit[3] for Iow0x0801 with 0xAA
                                        //                bit[2] for Iow0x0801 with 0xFF
                                        //                bit[1] for Iow0x0801 with 0x29
                                        //                bit[0] for Iow0x0801 with 0x55
                                        //                bit[4] for Iow0x0801 with other data
                                        // Once get Iow0x0801 command, bCPUWrWdtRegSig[4:0] will be its inverse of previous state.
wire            PsonFromPwrEvent;       // to PwrSequence.MstrSeq,High Active
`endif
// ***** End of ifndef_n1 ***************************************************
////////////////////////////////////////////////////////////////////////////
/////
/////         Module Instantiation
/////
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
////////////////////////////////////////////////////////////////////////////
// ***** ifdef_3 ************************************************************
`ifdef ONLY_PowerUp
// Only PwrSequence module will be instantiated with some additional assignments
assign  FM_SYS_SIO_PWRBTN_N    =  PWR_BTN_IN_N;     // PWR_BTN_IN_N is not controlled.
assign  RST_PCH_RSTBTN_N       =  SYS_RST_IN_N;     // SYS_RST_IN_N is not controlled.
assign  BIOS_CS_N[0]           =  Active_Bios ? 1'b1 : 1'b0;
assign  BIOS_CS_N[1]           =  Active_Bios ? 1'b0 : 1'b1;
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
// ***** ifdef_8 ************************************************************
`ifdef RdWrCpldReg
/////////////////////////////////////////////////////////////////////////////
//  For Stage 2 test, Only  focus  on LPC I/O R/W test.
//  CPLD Register with 0x00 address is R/O byte that contain {`FPGAID_CODE, `VERSION_CODE} data.
//  CPLD Registers ranged from 0x01 to 0x1F will be R/W registers with initial values defined in CpldRegMap.v
//  Define RdWrCpldReg to launch stage 2 test that only has PwrSequence,LpcDecode, CpldRegMap and ClockSource modules are instantiated at top module.
/////////////////////////////////////////////////////////////////////////////
wire    [7:0]       DataRd;
wire    [7:0]       AddrReg;
wire                WrReg;
wire                RdReg;
wire    [7:0]       DataWr;

Lpc
    u_Lpc (.PciReset    (RST_PLTRST_N), // PCI Reset
           .LpcClock    (Mclkx),        // 33 MHz Lpc (LPC Clock)
           .LpcFrame    (LPC_FRAME_N),  // LPC Interface: Frame
           .LpcBus      (LPC_LAD),      // LPC Interface: Data Bus
           .DataRd      (DataRd),       // register read data
           .AddrReg     (AddrReg),      // register address
           .Wr          (WrReg),        // register write
           .Rd          (RdReg),        // register read
           .DataWr      (DataWr));      // register write data
/////////////////////////////////////////////////////////////////
LpcReg
    u_LpcReg (.rst_n        (RST_PLTRST_N),         // PCI Reset
              .LpcClock     (Mclkx),                // 33 MHz Lpc (LPC Clock)
              .Addr         (AddrReg),              // register address
              .Rd           (RdReg),                // read operation
              .Wr           (WrReg),                // write operation
              .DataWr       (DataWr),               // write data
              .DataRd       (DataRd),               // read data
              .Pwr_ok       (PWRGD_PS_PWROK_3V3),   // Power is ok
              .Active_Bios  (Active_Bios));         // Provide access to required BIOS chip
/////////////////////////////////////////////////////////////////
ClockSource
    u_ClockSource (.HARD_nRESETi    (RST_RSMRST_N), // In    Frank 07242015 replace (HARD_nRESETi) with (RST_RSMRST_N),
                   .LCLK_CPLD       (LCLK_CPLD),    // In
                   .MCLK_FPGA       (MCLK_FPGA),    // In
                   .Mclkx           (Mclkx));       // Out
/////////////////////////////////////////////////////////////////
`endif
// ***** End of ifdef_8 *****************************************************
//
// ***** else of ifdef_3 ****************************************************
`else
// All modules will be instantiated
////////////////////////////////////////////////////////////////////////////
OffLEDwhenPwrOff
    u_OffLEDwhenPwrOff (.FM_PS_EN               (FM_PS_EN),             // In
                        .SysLedG_ox             (SysLedG_ox),           // In
                        .SysLedR_ox             (SysLedR_ox),           // In
                        .PowerNormal_ox         (PowerNormal_ox),       // In[1:0]
                        .PowerFail_ox           (PowerFail_ox),         // In[1:0]
                        .FanFail_ox             (FanFail_ox),           // In
                        .FanOK_ox               (FanOK_ox),             // In
                        .RJ45Speed1R_ox         (RJ45Speed1R_ox),       // In[1:0]
                        .RJ45Speed2R_ox         (RJ45Speed2R_ox),       // In[1:0]
                        .RJ45RActivity_ox       (RJ45RActivity_ox),     // In[1:0]
                        .SYS_LEDG_N             (SYS_LEDG_N),           // Out
                        .SYS_LEDR_N             (SYS_LEDR_N),           // Out
                        .PSU_Normal_N           (PSU_Normal_N),         // Out[1:0]
                        .PSU_Fail_N             (PSU_Fail_N),           // Out[1:0]
                        .FAN_LEDR_N             (FAN_LEDR_N),           // Out
                        .FAN_LEDG_N             (FAN_LEDG_N),           // Out
                        .CPLD_LAN_LINK1000_N    (CPLD_LAN_LINK1000_N),  // Out[1:0]
                        .CPLD_LAN_LINK100_N     (CPLD_LAN_LINK100_N),   // Out[1:0]
                        .CPLD_LAN_ACT_N         (CPLD_LAN_ACT_N));      // Out[1:0]
/////////////////////////////////////////////////////////////////////////////
BiosWdtDecode
    u_BiosWdtDecode (.MainResetN        (MainResetN),       // In
                     .CLK32768          (CLK32768),         // In
                     .Mclkx             (Mclkx),            // In
                     .DevCs_En          (DevCs_En),         // In
                     .DevAddr           (DevAddr),          // In[15:0]
                     .WrDev_Data        (WrDev_Data),       // In[7:0]
                     .bCPUWrWdtRegSig   (bCPUWrWdtRegSig)); // Out[4:0]
/////////////////////////////////////////////////////////////////////////////
LpcDecode
    u_LpcDecode (.ResetN        (RST_PLTRST_N),     // In
                 .lclk          (Mclkx),            // In   33MHz
                 .lframe_n      (LPC_FRAME_N),      // In
                 .lad           (LPC_LAD),          // Inout[3:0]
                 .csr_dout      (RdDev_Data_b),     // In[7:0]
                 .DevCs_En      (DevCs_En),         // Out
                 .DevAddr       (DevAddr),          // Out[15:0]
                 .RdDev_En      (RdDev_En),         // Out
                 .WrDev_En      (WrDev_En),         // Out
                 .WrDev_Data    (WrDev_Data),       // Out[7:0]
                 .BiosPostData  (BiosPostData));    // Out[7:0]
////////////////////////////////////////////////////////////////////////////
PwrBtnControl
    u_PwrBtnControl (.InitResetN            (InitResetN),           // In
                     .Strobe125ms           (Strobe125ms),          // In
                     .PWR_BTN_IN_N          (PWR_BTN_IN_N),         // In
                     .PWRGD_PS_PWROK_3V3    (PWRGD_PS_PWROK_3V3),   // In
                     .FM_PS_EN              (FM_PS_EN),             // In
                     .PowerEvtState         (PowerEvtState),        // In[3:0], From PwrEvent
                     .PowerButtonOut_ox     (PowerButtonOut_ox),    // In, From MR_Bsp.ButtonControl.Button::StrobeOut ( in ButtonControl.v file )
                     .PowerbuttonEvtOut     (PowerbuttonEvtOut),    // In, From PwrEvent
                     .RstBiosFlg            (RstBiosFlg),           // Out, to MR_Bsp.BiosControl
                     .FM_SYS_SIO_PWRBTN_N   (FM_SYS_SIO_PWRBTN_N)); // Out, to SIO
//////////////////////////////////////////////////////////////////////////
GLANLED_2Port
    u_GLANLED_2Port (.ALL_PWRGD (PWRGD_CPUPWRGD),       // In,
                     .PActivity (LAN_ACT_N),            // In[1:0],  (RJ45PActivity),
                     .Speed1P   (LAN_LINK1000_N),       // In[1:0],  (RJ45Speed1P),
                     .Speed2P   (LAN_LINK100_N),        // In[1:0],  (RJ45Speed2P),
                     .Speed1R   (RJ45Speed1R_ox),       // Out[1:0]
                     .Speed2R   (RJ45Speed2R_ox),       // Out[1:0]
                     .RActivity (RJ45RActivity_ox));    // Out[1:0]
///////////////////////////////////////////////////////////////////////////
MR_Bsp
    u_MR_Bsp (.ResetN           (InitResetN),                                               // In
              .Mclk             (Mclkx),                                                    // In
              .DevAddr          ((11'h040 == DevAddr[15:5]) ? DevAddr : `DbgDevAddr),       // In[15:0],  bIORWBsp = (11'h040 == DevAddr[15:5]), 0x0800 ~ 0x081F
              .WrDev_En         ((11'h040 == DevAddr[15:5]) ? WrDev_En : `DbgWrDevEn),      // In
              .WrDev_Data       ((11'h040 == DevAddr[15:5]) ? WrDev_Data : `DbgWrDevData),  // In[7:0]
              .RdDev_En         ((11'h040 == DevAddr[15:5]) ? RdDev_En : `DbgRdDevEn),      // In
              .RdDev_Data       (RdDev_Data_b),                                             // Out[7:0]
              .BiosPostData     (BiosPostData),                                             // In[7:0]
              .SpecialCmdReg    (SpecialCmdReg),                                            // Out[7:0]
              .bFlashBusyN      (!(bDualPSFlashReq | bPowerEvtFlashReq)),                   // In, to MR_Bsp.LpcIorCpldReg
              .DevCs_En         (DevCs_En),                                                 // In
              .RstBiosFlg       (RstBiosFlg),                                               // In
              .PS_ONn           (FM_PS_EN),                                                 // In, from PwrSequence Module
              .PSU_FANIN        (1'b1),                                                     // In,
              .MONITOR_BEEP     (SIO_BEEP),                                                 // In,
              .FanState         (GPIO15_FAN_Fail_N),                                        // In, Fan Fail - 1, FanOK - 0
              .FanPresences     (FAN_PRSNT_N),                                              // In[2:0]
              .FanFail          (FanFail_ox),                                               // Out, Fan Led indication
              .FanOK            (FanOK_ox),                                                 // Out, Fan Led indication
              .Reset1G          (Reset1G_ox),                                               // Out
              .ALL_PWRGD        (PWRGD_CPUPWRGD),                                           // In, ALL POWER GOOD internal LED: 0-Off, 1-ON;
              .CLK32KHz         (CLK32768),                                                 // In
              .Strobe1s         (Strobe1s),                                                 // In, Single SlowClock Pulse @ 1 s
              .Strobe1ms        (Strobe1ms),                                                // In, Single SlowClock Pulse @ 1 ms
              .Strobe16ms       (Strobe16ms),                                               // In, Single SlowClock Pulse @ 16 ms
              .Strobe125ms      (Strobe125ms),                                              // In, Single SlowClock Pulse @ 125 ms
              .Strobe125msec    (Strobe125msec),                                            // In, Sync with
              .MainResetN       (MainResetN),                                               // In
              .SysReset         (SYS_RST_IN_N),                                             // In, Reset Button input
              .PowerButtonIn    (PWR_BTN_IN_N),                                             // In, Power Button input
              .PowerButtonOut   (PowerButtonOut_ox),                                        // out, (Debounced) Power Button out
              .ResetOut         (ResetOut_ox),                                              // out, Active Wide Strobe 4s after  reset button pressed
              .PowerSupplyOK    (PWRGD_PS_PWROK_3V3),                                       // In, Power Supply OK from Power connector
              .DualPSCfgFlash   (odsRdCfgData[1]),                                          // In, Internal Flash - points to Dual Power Supply if "1", DualPSCfgRdBit = odsRdCfgData[1];
              .DualPSJump3      (DualPS),                                                   // In, Board Jumper - points to Dual Power Supply if "1"
              .ZippyStatus      (PSU_status),                                               // In[1:0], Dual Power Supply Status, Normal: 1, Fail: 0
              .SysLedG          (SysLedG_ox),                                               // Out, System LED: Green Anode
              .SysLedR          (SysLedR_ox),                                               // Out, System LED: Green Cathode
              .PowerNormal      (PowerNormal_ox),                                           // Out[1:0], Power LED active "1/0" Green/Red Control
              .PowerFail        (PowerFail_ox),                                             // Out[1:0], Power LED active "0/1" Green/Red Control
              .InterruptD       (CPLD_PCH_INT_N),                                           // Out, Interrupt Request to CPU,
              .BiosCS           (SPI_PCH_CS0_N),                                            // In, BiosCS# from PCH
              .BIOS_SEL         (BIOS_SEL),                                                 // In
              .BIOS             (BIOS_CS_N),                                                // Out[1:0], Chip Select to SPI Flash Memories
              .BiosLed          (BIOS_LED_N),                                               // Out[1:0], LED to point current BIOS
              .PowerOff         (PowerOff),                                                 // Out
              .PowerEvtState    (PowerEvtState),                                            // In
              .Led7En           (LED7_digit),                                               // Out[5:0],
              .Led7Leg          (LED7_SEG),                                                 // Out[6:0],
              .SystemOK         (SystemOK),                                                 // Out, System Status: SystemOK, it will go high after BIOS issues command
              .BspDbgP          (BspDbgP),                                                  // Out[3:0]
              .FM_PLD_DEBUG2    (FM_PLD_DEBUG2),                                            // In, add FM_PLD_DEBUG[5:2]  for 7Seg LED display
              .FM_PLD_DEBUG3    (FM_PLD_DEBUG3),                                            // In, input to MR_Bsp.Led7SegDecode, Output from PwrSequence module
              .FM_PLD_DEBUG4    (FM_PLD_DEBUG4),                                            // In
              .FM_PLD_DEBUG5    (FM_PLD_DEBUG5),                                            // In
              .PORT80_DP        (LED7_SEGDP));                                              // In, 7Seg LED Decimal Point, turn "ON"  if ( SystemOK == 0 ) && ( ALL_PWRGD == 0 )
                                                                                            //   turn "OFF" if ( SystemOK == 0 ) && ( ALL_PWRGD == 1 )
/////////////////////////////////////////////////////////////////////////
UFMRwPageDecode
    u_UFMRwPageDecode (.nRst            (InitResetN),                                        // In
                       .CLK_i           (Mclkx),                                             // In
                       .bRdPromCfg      (bRdIntFlashPwrEvtCfg | bRdIntFlashDualPsCfg),       // In
                       .bWrPromCfg      (bWrIntFlashPwrEvtCfg | bWrIntFlashDualPsCfg),       // In
                       .ufm_data_in     ({30'h3FFFFFFF, DualPSCfgWrBit, PwrLastStateWrBit}), // In[31:0], wData
                       .ufm_data_out    (odsRdCfgData));                                     // Out[31:0],rData
/////////////////////////////////////////////////////////////////////////
DualPSCfg
    u_DualPSCfg (.ResetN            (InitResetN),           // In
                 .CLK32768          (CLK32768),             // In
                 .Strobe1ms         (Strobe1ms),            // In
                 .SpecialCmdReg     (SpecialCmdReg),        // In[7:0]
                 .bPromBusy         (bPowerEvtFlashReq),    // In
                 .DualPSCfgRdBit    (odsRdCfgData[1]),      // In,  DualPSCfgRdBit = odsRdCfgData[1]
                 .bFlashPromReq     (bDualPSFlashReq),      // Out
                 .bRdPromCfg        (bRdIntFlashDualPsCfg), // Out
                 .bWrPromCfg        (bWrIntFlashDualPsCfg), // Out
                 .DualPSCfgWrBit    (DualPSCfgWrBit),       // Out
                 .DbgP              (PsDbgP));              // Out[2:0]
//////////////////////////////////////////////////////////////////////////////
PwrEvent
    u_PwrEvent (.ResetN             (InitResetN),           // In
                .CLK32768           (CLK32768),             // In
                .Strobe1ms          (Strobe1ms),            // In
                .PowerbuttonIn      (PWR_BTN_IN_N),         // In
                .PwrLastStateRdBit  (odsRdCfgData[0]),      // In, PwrLastStateRdBit = odsRdCfgData[0];
                .SLP_S3n            (FM_SLPS3_N),           // In
                .ATX_PowerOK        (PWRGD_PS_PWROK_3V3),   // In
                .ALL_PWRGD          (PWRGD_CPUPWRGD),       // In,
                .BiosLed            (BIOS_LED_N),           // In[1:0], LED to point current BIOS
                .bCPUWrWdtRegSig    (bCPUWrWdtRegSig),      // In[4:0], CPU write BiosWDT value flag
                .PowerOff           (PowerOff),             // In
                .PowerEvtState      (PowerEvtState),        // Out[3:0], to PwrBtnControl and MR_Bsp.Led7SegDecode
                .PowerbuttonEvtOut  (PowerbuttonEvtOut),    // Out, to PwrBtnControl
                .PS_ONn             (PsonFromPwrEvent),     // Out to PwrSequence.MstrSeq,
                .bPwrSystemReset    (bPwrSystemReset),      // Out, no connection yet
                .bFlashPromReq      (bPowerEvtFlashReq),    // Out, to DualPSCfg, !(bDualPSFlashReq | bPowerEvtFlashReq) to MR_Bsp.LpcIorCpldReg::bFlashBusyN
                .bRdPromCfg         (bRdIntFlashPwrEvtCfg), // Out
                .bWrPromCfg         (bWrIntFlashPwrEvtCfg), // Out
                .PwrLastStateWrBit  (PwrLastStateWrBit),    // Out
                .DbgP               (EvpDbgP));             // Out[3:0]
///////////////////////////////////////////////////////////////////////////
HwResetGenerate
    u_HwResetGenerate (.HARD_nRESETi        (RST_RSMRST_N),         // In  Frank 07242015 replace (HARD_nRESETi) with (RST_RSMRST_N),
                       .MCLKi               (Mclkx),                // In  33MHz
                       .RSMRST_N            (RST_RSMRST_N),         // In
                       .PLTRST_N            (RST_PLTRST_N),         // In
                       .Reset1G             (Reset1G_ox),           // In
                       .ResetOut_ox         (ResetOut_ox),          // In, Reset btn pressed and retained 4 seconds, then it will be asserted . from MR_Bsp
                       .FM_PS_EN            (FM_PS_EN),             // In
                       .CLK32KHz            (CLK32768),             // Out
                       .InitResetn          (InitResetN),           // Out
                       .MainResetN          (MainResetN),           // Out
                       .RST_CPU0_LVC3_N     (RST_CPU0_LVC3_N),      // Out
                       .RST_PLTRST_BUF_N    (RST_PLTRST_BUF_N),     // Out
                       .RST_DLY_CPURST_LVC3 (RST_DLY_CPURST_LVC3),  // Out
                       .RST_PERST0_N        (RST_PERST0_N),         // Out
                       .RST_BCM56842_N_R    (RST_BCM56842_N_R),     // Out
                       .RST_1G_N_R          (RST_1G_N_R),           // Out
                       .SYS_RST_IN_SIO_N    (SYS_RST_IN_SIO_N),     // Out
                       .RST_PCH_RSTBTN_N    (RST_PCH_RSTBTN_N));    // Out
////////////////////////////////////////////////////////////////////////////
StrobeGen
    u_StrobeGen (.ResetN        (InitResetN),       // In
                 .LpcClock      (Mclkx),            // In, 33 MHz Lpc
                 .SlowClock     (CLK32768),         // In, Oscillator Clock 32,768 Hz
                 .Strobe1s      (Strobe1s),         // Out, Single SlowClock Pulse @ 1 s
                 .Strobe488us   (Strobe488us),      // Out, Single SlowClock Pulse @ 488 us
                 .Strobe1ms     (Strobe1ms),        // Out, Single SlowClock Pulse @ 1 ms
                 .Strobe16ms    (Strobe16ms),       // Out, Single SlowClock Pulse @ 16 ms
                 .Strobe125ms   (Strobe125ms),      // Out, Single SlowClock Pulse @ 125 ms
                 .Strobe125msec (Strobe125msec),    // Out, Single LpcClock  Pulse @ 125 ms
                 .Counter       (CounterStrobe));   // Out[14:0], 15 bit Free run Counter on Slow Clock
////////////////////////////////////////////////////////////////////////////
ClockSource
    u_ClockSource (.HARD_nRESETi    (RST_RSMRST_N), // In    Frank 07242015 replace (HARD_nRESETi) with (RST_RSMRST_N),
                   .LCLK_CPLD       (LCLK_CPLD),    // In
                   .MCLK_FPGA       (MCLK_FPGA),    // In
                   .Mclkx           (Mclkx));       // Out
////////////////////////////////////////////////////////////////////////////
DMEInit
    u_DMEInit (.PWRGD_PS_PWROK_3V3  (PWRGD_PS_PWROK_3V3),   // In
               .RST_PLTRST_N        (RST_PLTRST_N),         // In
//               .DME_PWRGD         (DME_PWRGD),            // In, One of ALL_PWRGD, Will be moved to PwrSequence.MstrSeq in the future.
               .DME_Absent          (DME_Absent),           // In
               .DMEID               (DMEID),                // In[3:0]
               .DMEStatus           (DMEStatus),            // In[5:0]
               .RST_DME_N           (RST_DME_N),            // Out
               .DMEControl          (DMEControl));          // Out [5:0]
/////////////////////////////////////////////////////////////////////////////
`endif
// ***** End of ifdef_3 *****************************************************
endmodule  // end of ODS_MR,  top  module of this project
