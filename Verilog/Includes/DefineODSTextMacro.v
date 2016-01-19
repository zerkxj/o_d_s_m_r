//////////////////////////////////////////////////////////////////////////////
// File name        : DefineODSTextMacro.v
// Module name      : ---
// Description      : This is a defined text Macro for ODS-MR control modules
// Hierarchy Up     : ---
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
`ifndef GDEF_CNST
`define GDEF_CNST

//`define SIMULATE_DESIGN 1
//`define ODS_USE_UART    1
//`define ODS_USE_I2C     1
//`define DEBUG_PwrState 1

`define BAR 16'h0800
`define BAR80 16'h0080
`define Port80 1'b1

`define TRUE        1
`define FALSE       0
`define HIGH        1
`define LOW         0
`define LED_ON      1
`define LED_OFF     0
`define SIG_ON      0
`define SIG_OFF     1
`define SW_ON       0
`define SW_OFF      1
`define RELAY_ON    1
`define RELAY_OFF   0

`define FPGAID_CODE     4'hC
`define VERSION_CODE    4'h0
`define BUILD_YEAR      7'h0F
`define BUILD_MONTH     4'h7
`define BUILD_DAY       5'h0F

`define PwrSW_On        1
`define PwrSW_Off       0

`define NCC 4'h1
`define NETCOP_MR4L 4'h2

`define Event_InitPowerUp   0
`define Event_PowerStandBy  1
`define Event_Reboot        2
`define Event_UpdatePwrSt   3
`define Event_SystemRun     4
`define Event_SystemReset   5
`define Event_PowerCycle    6
`define Event_PowerFail     7
`define Event_Wait2s        8
`define Event_PowerDown     9
`define Event_SLP_S3n       10
`define Event_SLP_S3n_UpChk 11
`define Event_BiosPost_Wait 12

// LPC Cycle Type definition
`define CT_MemoryRead           0
`define CT_MemoryWrite          1
`define CT_IORead               2
`define CT_IOWrite              3
`define CT_DMARead              4
`define CT_DMAWrite             5
`define CT_BusMasterMemRead     6
`define CT_BusMasterMemWrite    7
`define CT_BusMasterIORead      8
`define CT_BusMasterIOWrite     9
`define CT_FirmwareMemRead      10
`define CT_FirmwareMemWrite     11

`define CLK33M_1SEC_DIV 24'hFBC51F 

//`define OdsISFPromAddr        24'h0F_FE00 
`define PS_ONnDlyOn_Xms 12'h640       // 50ms
`define DbgDevAddr      16'h0000 
`define DbgWrDevData    8'hFF 
`define DbgWrDevEn      1'b0 
`define DbgRdDevEn      1'b0 

`endif
