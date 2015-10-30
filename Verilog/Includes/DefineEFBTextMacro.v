//////////////////////////////////////////////////////////////////////////////
// File name        : DefineEFBTextMacro.v
// Module name      : ---
// Description      : This is a defined text Macro for accessing Lattice EFB 
// Hierarchy Up     : ---
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////

//; for Simulation
//`define UFM_SIM
//- `define UFM_SIM // Frank 06012015 add 
//; test sub-module
`define LOCAL_BUS
`define XO2_OSC

`define UFM_BarCode_PageNum   8'h01  //2014/03/10 add 

////////////////////////////////////////////////////////////////////////
//    Local bus Register define
////////////////////////////////////////////////////////////////////////
`define UFM_Cmd_Addrs         8'h00
`define UFM_PageSt_Addrs      8'h01
`define UFM_PageWrData_Addrs  8'h02
`define UFM_PageRdNum_Addrs   8'h02

// ----------------------------------------------------
// Define states of the Barcode Write/Read state machine
// ----------------------------------------------------
`define  Idle_Sts             3'd0 
`define  Read_Security_Sts    3'd1 
`define  StandBy_Sts          3'd2
`define  Erase_UFM_Sts        3'd3 
`define  Write_UFM_Sts    	  3'd4 
`define  Read_UFM_Sts     	  3'd5 

// ***********************************************************************
// *                                                                     *
// * EFB REGISTER SET                                                    *
// *                                                                     *
// *********************************************************************** 
`define MICO_EFB_I2C_CR		  8'h40 //4a
`define MICO_EFB_I2C_CMDR	  8'h41 //4b
`define MICO_EFB_I2C_BLOR	  8'h42 //4c
`define MICO_EFB_I2C_BHIR	  8'h43 //4d
`define MICO_EFB_I2C_TXDR	  8'h44 //4e
`define MICO_EFB_I2C_SR		  8'h45 //4f
`define MICO_EFB_I2C_GCDR	  8'h46 //50
`define MICO_EFB_I2C_RXDR	  8'h47 //51
`define MICO_EFB_I2C_IRQSR	  8'h48 //52
`define MICO_EFB_I2C_IRQENR	  8'h49 //53

`define MICO_EFB_SPI_CR0	  8'h54 
`define MICO_EFB_SPI_CR1	  8'h55 
`define MICO_EFB_SPI_CR2	  8'h56 
`define MICO_EFB_SPI_BR		  8'h57 
`define MICO_EFB_SPI_CSR	  8'h58 
`define MICO_EFB_SPI_TXDR	  8'h59 
`define MICO_EFB_SPI_SR		  8'h5a 
`define MICO_EFB_SPI_RXDR	  8'h5b 
`define MICO_EFB_SPI_IRQSR	  8'h5c 
`define MICO_EFB_SPI_IRQENR	  8'h5d 

`define MICO_EFB_TIMER_CR0			8'h5E 
`define MICO_EFB_TIMER_CR1			8'h5F 
`define MICO_EFB_TIMER_TOP_SET_LO	8'h60 
`define MICO_EFB_TIMER_TOP_SET_HI	8'h61 
`define MICO_EFB_TIMER_OCR_SET_LO	8'h62 
`define MICO_EFB_TIMER_OCR_SET_HI	8'h63 
`define MICO_EFB_TIMER_CR2			8'h64 
`define MICO_EFB_TIMER_CNT_SR_LO	8'h65 
`define MICO_EFB_TIMER_CNT_SR_HI	8'h66 
`define MICO_EFB_TIMER_TOP_SR_LO	8'h67 
`define MICO_EFB_TIMER_TOP_SR_HI	8'h68 
`define MICO_EFB_TIMER_OCR_SR_LO	8'h69 
`define MICO_EFB_TIMER_OCR_SR_HI	8'h6A 
`define MICO_EFB_TIMER_ICR_SR_LO	8'h6B 
`define MICO_EFB_TIMER_ICR_SR_HI	8'h6C 
`define MICO_EFB_TIMER_SR			8'h6D 
`define MICO_EFB_TIMER_IRQSR		8'h6E 
`define MICO_EFB_TIMER_IRQENR		8'h6F 
 
// ***********************************************************************
// *                                                                     *
// * EFB SPI CONTROLLER PHYSICAL DEVICE SPECIFIC INFORMATION             *
// *                                                                     *
// ***********************************************************************
// Control Register 1 Bit Masks
`define MICO_EFB_SPI_CR1_SPE			8'h80 
`define MICO_EFB_SPI_CR1_WKUPEN			8'h40 
// Control Register 2 Bit Masks
`define MICO_EFB_SPI_CR2_LSBF			8'h01 
`define MICO_EFB_SPI_CR2_CPHA			8'h02 
`define MICO_EFB_SPI_CR2_CPOL			8'h04 
`define MICO_EFB_SPI_CR2_SFSEL_NORMAL	8'h00 
`define MICO_EFB_SPI_CR2_SFSEL_LATTICE	8'h08 
`define MICO_EFB_SPI_CR2_SRME			8'h20 
`define MICO_EFB_SPI_CR2_MCSH			8'h40 
`define MICO_EFB_SPI_CR2_MSTR			8'h80 
// Status Register Bit Masks
`define MICO_EFB_SPI_SR_TIP			    8'h80 
`define MICO_EFB_SPI_SR_TRDY		    8'h10 
`define MICO_EFB_SPI_SR_RRDY			8'h08 
`define MICO_EFB_SPI_SR_TOE				8'h04 
`define MICO_EFB_SPI_SR_ROE				8'h02 
`define MICO_EFB_SPI_SR_MDF				8'h01 

// ***********************************************************************
// *                                                                     *
// * EFB I2C CONTROLLER PHYSICAL DEVICE SPECIFIC INFORMATION             *
// *                                                                     *
// ***********************************************************************
// Control Register Bit Masks
`define MICO_EFB_I2C_CR_I2CEN		 8'h80 
`define MICO_EFB_I2C_CR_GCEN		 8'h40 
`define MICO_EFB_I2C_CR_WKUPEN		 8'h20 
// Status Register Bit Masks
`define MICO_EFB_I2C_SR_TIP			 8'h80 
`define MICO_EFB_I2C_SR_BUSY		 8'h40 
`define MICO_EFB_I2C_SR_RARC		 8'h20 
`define MICO_EFB_I2C_SR_SRW			 8'h10 
`define MICO_EFB_I2C_SR_ARBL		 8'h08 
`define MICO_EFB_I2C_SR_TRRDY		 8'h04 
`define MICO_EFB_I2C_SR_TROE		 8'h02 
`define MICO_EFB_I2C_SR_HGC			 8'h01 
// Command Register Bit Masks 
`define MICO_EFB_I2C_CMDR_STA		 8'h80 
`define MICO_EFB_I2C_CMDR_STO		 8'h40 
`define MICO_EFB_I2C_CMDR_RD		 8'h20 
`define MICO_EFB_I2C_CMDR_WR		 8'h10 
`define MICO_EFB_I2C_CMDR_NACK		 8'h08 
`define MICO_EFB_I2C_CMDR_CKSDIS	 8'h04 

// ***********************************************************************
// *                                                                     *
// * EFB I2C USER DEFINE                                                 *
// *                                                                     *
// ***********************************************************************
`define MICO_EFB_I2C_TRANSMISSION_DONE	    8'h00 
`define MICO_EFB_I2C_TRANSMISSION_ONGOING   8'h80 
`define MICO_EFB_I2C_FREE                   8'h00 
`define MICO_EFB_I2C_BUSY                   8'h40 
`define MICO_EFB_I2C_ACK_NOT_RCVD		    8'h20 
`define MICO_EFB_I2C_ACK_RCVD			    8'h00 
`define MICO_EFB_I2C_ARB_LOST			    8'h08 
`define MICO_EFB_I2C_ARB_NOT_LOST		    8'h00 
`define MICO_EFB_I2C_DATA_READY			    8'h04 

// ***********************************************************************
// *                                                                     *
// * EFB TIMER PHYSICAL DEVICE SPECIFIC INFORMATION                      *
// *                                                                     *
// ***********************************************************************
// Control Register 0
`define MICO_EFB_TIMER_RSTN_MASK		   8'h80 
`define MICO_EFB_TIMER_GSRN_MASK		   8'h40 
`define MICO_EFB_TIMER_GSRN_ENABLE		   8'h40 
`define MICO_EFB_TIMER_GSRN_DISABLE		   8'h00 
`define MICO_EFB_TIMER_CCLK_MASK		   8'h38 
`define MICO_EFB_TIMER_CCLK_DIV_0		   8'h00 
`define MICO_EFB_TIMER_CCLK_DIV_1		   8'h08 
`define MICO_EFB_TIMER_CCLK_DIV_8		   8'h10 
`define MICO_EFB_TIMER_CCLK_DIV_64		   8'h18 
`define MICO_EFB_TIMER_CCLK_DIV_256		   8'h20 
`define MICO_EFB_TIMER_CCLK_DIV_1024	   8'h28 
`define MICO_EFB_TIMER_SCLK_MASK		   8'h07 
`define MICO_EFB_TIMER_SCLK_CIB_RE		   8'h00 
`define MICO_EFB_TIMER_SCLK_OSC_RE		   8'h02 
`define MICO_EFB_TIMER_SCLK_CIB_FE		   8'h04 
`define MICO_EFB_TIMER_SCLK_OSC_FE		   8'h06 
// Control Register 1
`define MICO_EFB_TIMER_TOP_SEL_MASK		   8'h80 
`define MICO_EFB_TIMER_TOP_MAX			   8'h00 
`define MICO_EFB_TIMER_TOP_USER_SELECT	   8'h10 
`define MICO_EFB_TIMER_OC_MODE_MASK		   8'h0C 
`define MICO_EFB_TIMER_OC_MODE_STATIC_ZERO 8'h00 
`define MICO_EFB_TIMER_OC_MODE_TOGGLE	   8'h04 
`define MICO_EFB_TIMER_OC_MODE_CLEAR	   8'h08 
`define MICO_EFB_TIMER_OC_MODE_SET		   8'h0C 
`define MICO_EFB_TIMER_MODE_MASK		   8'h03 
`define MICO_EFB_TIMER_MODE_WATCHDOG	   8'h00 
`define MICO_EFB_TIMER_MODE_CTC			   8'h01 
`define MICO_EFB_TIMER_MODE_FAST_PWM	   8'h02 
`define MICO_EFB_TIMER_MODE_TRUE_PWM	   8'h03 
// Control Register 2
`define MICO_EFB_TIMER_OC_FORCE			   8'h04 
`define MICO_EFB_TIMER_CNT_RESET		   8'h02 
`define MICO_EFB_TIMER_CNT_PAUSE		   8'h01 
// Status Register
`define MICO_EFB_TIMER_SR_OVERFLOW		   8'h01 
`define MICO_EFB_TIMER_SR_COMPARE_MATCH	   8'h02 
`define MICO_EFB_TIMER_SR_CAPTURE		   8'h04  

`define CFGCR     8'h70  
`define CFGTXDR   8'h71  
`define CFGSR     8'h72  
`define CFGRXDR   8'h73  
`define CFGIRQ    8'h74  
`define CFGIRQEN  8'h75 

// ***********************************************************************
// *                                                                     *
// * PULI SPECIFIC                                                       *
// *                                                                     *
// *********************************************************************** 
`define ALL_ZERO     8'h00 
`define READ         1'b0  
`define READ         1'b0  
//- `define HIGH         1'b1   // Remove for already defined in DefineODSTextMacro.v
`define WRITE        1'b1  
//- `define LOW          1'b0   // Remove for already defined in DefineODSTextMacro.v
`define READ_STATUS  1'b0  
`define READ_DATA    1'b0  
 
// ***********************************************************************
// *                                                                     *
// * State Machine Variables                                             *
// *                                                                     *
// ***********************************************************************
`define idle_st                7'd00     
`define WboneRst_sts	       7'd01    
`define Wait5us_sts1	       7'd02    
`define WboneEn_sts	           7'd03    
`define Wait5us_sts2           7'd04    
`define EraseUFM_sts	       7'd05    
`define EraseUFM_Op1_sts	   7'd06    
`define EraseUFM_Op2_sts	   7'd07    
`define EraseUFM_Op3_sts	   7'd08    
`define Wait5us_sts3	       7'd09    
`define EnUFM_sts  	           7'd10    
`define EnUFM_Op1_sts	       7'd11    
`define EnUFM_Op2_sts          7'd12    
`define EnUFM_Op3_sts          7'd13    
`define Wait5us_sts4           7'd14    
`define SetPageAdrs_sts        7'd15    
`define SetPageAdrs_Op1_sts    7'd16    
`define SetPageAdrs_Op2_sts    7'd17    
`define SetPageAdrs_Op3_sts    7'd18    
`define SetPageAdrs_Byte3_sts  7'd19    
`define SetPageAdrs_Byte2_sts  7'd20    
`define SetPageAdrs_Byte1_sts  7'd21    
`define SetPageAdrs_Byte0_sts  7'd22    
`define WrDtPage_sts           7'd23    
`define WrDtPage_OP1_sts       7'd24    
`define WrDtPage_OP2_sts       7'd25    
`define WrDtPage_OP3_sts       7'd26    
`define WrDtPage_Dt0_sts       7'd27    
`define WrDtPage_Dt1_sts       7'd28    
`define WrDtPage_Dt2_sts       7'd29    
`define WrDtPage_Dt3_sts       7'd30    
`define WrDtPage_Dt4_sts       7'd31    
`define WrDtPage_Dt5_sts       7'd32    
`define WrDtPage_Dt6_sts       7'd33    
`define WrDtPage_Dt7_sts       7'd34    
`define WrDtPage_Dt8_sts       7'd35    
`define WrDtPage_Dt9_sts       7'd36    
`define WrDtPage_Dt10_sts      7'd37    
`define WrDtPage_Dt11_sts      7'd38    
`define WrDtPage_Dt12_sts      7'd39    
`define WrDtPage_Dt13_sts      7'd40    
`define WrDtPage_Dt14_sts      7'd41    
`define WrDtPage_Dt15_sts      7'd42    
`define Wait5us_sts5           7'd43    
`define WrNextPage_sts         7'd44    
`define DisUFM_sts             7'd45    
`define DisUFM_Op1_sts         7'd46    
`define DisUFM_Op2_sts         7'd47    
`define DisUFM_Op3_sts         7'd48    
`define NOP_sts                7'd49    
`define WrEnd_sts              7'd50 

`define RdPageDt_sts           7'd51 
`define RdPageDt_OP1_sts       7'd52 
`define RdPageDt_OP2_sts       7'd53 
`define RdPageDt_OP3_sts       7'd54 
`define RdPage_Dt_sts          7'd55
`define RdEnd_sts              7'd56
   
`define CloseFrm1_sts          7'd60
`define OpenFrm1_sts           7'd61
`define CloseFrm2_sts          7'd62
`define OpenFrm2_sts           7'd63
`define CloseFrm3_sts          7'd64
`define OpenFrm3_sts           7'd65
`define CloseFrm4_sts          7'd66
`define OpenFrm4_sts           7'd67
`define CloseFrm5_sts          7'd68
`define OpenFrm5_sts           7'd69

`define PollBusy_sts           7'd70
`define PollBusy_Op1_sts       7'd71
`define PollBusy_Op2_sts       7'd72
`define PollBusy_Op3_sts       7'd73
`define RdBusy_By1_sts         7'd74
`define RdBusy_By2_sts         7'd75
`define RdBusy_By3_sts         7'd76
`define RdBusy_By4_sts         7'd77

`define EraseEnd_sts           7'd80
