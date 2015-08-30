//////////////////////////////////////////////////////////////////////////////
// File name        : DefineODSTextMacro.v
// Module name      : ---
// Description      : This is a defined text Macro for ODS-MR control modules
// Hierarchy Up     : ---
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
`ifndef GDEF_CNST
`define GDEF_CNST

//- `define SIMULATE_DESIGN     1     // Frank 05072015 unmask for test
//- `define ODS_USE_UART    	1     // Frank 05072015 unmask for test  
//- `define ODS_USE_I2C	    	1     // Frank 05072015 unmask for test

//- `define DEBUG_PwrState      1     // Frank 05072015 unmask for test , DEBUG_PwrState  in Led7SegDecode.v
//- `define ONLY_PowerUp        1     // Stage 1 , only PwrSequence 
//`define RdWrCpldReg           1     // Stage 2 , PwrSequence + LPC R/W Access 
`define DualBIOS                1     // Stage 3, Dual BIOS

`define BAR 16'h0800

`define TRUE			    1
`define FALSE			    0
`define HIGH			    1
`define LOW 			    0
`define LED_ON              1
`define LED_OFF             0
`define SIG_ON			    0
`define SIG_OFF 		    1
`define SW_ON			    0
`define SW_OFF			    1
`define RELAY_ON            1
`define RELAY_OFF           0

`define FPGAID_CODE			4'hF		//   FPGA PRJ ID code ,"F" for testing , "0" for normal 
`define VERSION_CODE	    4'h0		//   FPGA code version  
`define BUILD_YEAR	    	7'h0F		//   FPGA Build Time: Year
`define BUILD_MONTH	    	4'h7		//   FPGA Build Time: Month
`define BUILD_DAY			5'h0F		//   FPGA Build Time: Day

`define PwrSW_On            1
`define PwrSW_Off           0

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
`define CT_MemoryRead       0
`define CT_MemoryWrite      1
`define CT_IORead           2
`define CT_IOWrite          3
`define CT_DMARead          4
`define CT_DMAWrite         5
`define CT_BusMasterMemRead	6
`define CT_BusMasterMemWrite 7
`define CT_BusMasterIORead  8
`define CT_BusMasterIOWrite 9
`define CT_FirmwareMemRead  10
`define CT_FirmwareMemWrite 11

`define CLK33M_1SEC_DIV		24'hFBC51F 

//- `define OdsISFPromAddr		24'h0F_FE00 
`define PS_ONnDlyOn_Xms   12'h640       // 50ms
`define DbgDevAddr    16'h0000 
`define DbgWrDevData  8'hFF 
`define DbgWrDevEn    1'b0 
`define DbgRdDevEn    1'b0 
/*
`define I2CBUS_WRITE        1'b0
`define I2CBUS_READ         1'b1

`define I2CBUS_ClkCntBitHigh	3'h3
`define I2CBUS_ClkCntBitLow		3'h7

`define I2CBUS_ClkDataWbit  3'h0    // write data bit
`define I2CBUS_ClkDataRbit  3'h5    // read data bit
`define I2CBUS_ClkCntStop   3'h5
`define I2CBUS_ClkCntNext   3'h7

`define I2CBUS_Idle_Cnd     0
`define I2CBUS_Start_Cnd    1
`define I2CBUS_ReStart_Cnd  2
`define I2CBUS_NextSendDATA 3
`define I2CBUS_SendDATA     4
`define I2CBUS_SendACK      5
`define I2CBUS_RcvDATA      6
`define I2CBUS_RcvACK       7
`define I2CBUS_Chk_Stop_Cnd 8
`define I2CBUS_Stop_Cnd     9
`define I2CBUS_Access_Done  10

`define I2CMaster_Read		1
`define I2CMaster_Write     0
`define I2CSDA2Master    	1
`define I2CSDA2Slave     	0
*/

`endif
