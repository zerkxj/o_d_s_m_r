/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.3.0.109 */
/* Module Version: 1.2 */
/* C:\lscc\diamond\3.3_x64\ispfpga\bin\nt64\scuba.exe -w -n efb -lang verilog -synth synplify -bus_exp 7 -bb -type efb -arch xo2c00 -freq 7 -ufm -ufm_ebr 638 -mem_size 1 -ufm_0 -wb -dev 1200 -u  */
/* Thu Jan 15 10:37:34 2015 */


`timescale 1 ns / 1 ps 
// Frank 06302015 renames module to EFBWishbone

module EFBWishbone (wb_clk_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_we_i, wb_adr_i, 
//- module efb (wb_clk_i, wb_rst_i, wb_cyc_i, wb_stb_i, wb_we_i, wb_adr_i, 
    wb_dat_i, wb_dat_o, wb_ack_o, wbc_ufm_irq)/* synthesis NGD_DRC_MASK=1 */;
    input wire wb_clk_i;
    input wire wb_rst_i;
    input wire wb_cyc_i;
    input wire wb_stb_i;
    input wire wb_we_i;
    input wire [7:0] wb_adr_i;
    input wire [7:0] wb_dat_i;
    output wire [7:0] wb_dat_o;
    output wire wb_ack_o;
    output wire wbc_ufm_irq;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));
// Rename all 52 occurrences of EFBInst_0 to EFB for simulation 
    defparam EFB.UFM_INIT_FILE_FORMAT = "HEX" ;
    defparam EFB.UFM_INIT_FILE_NAME = "NONE" ;
    defparam EFB.UFM_INIT_ALL_ZEROS = "ENABLED" ;
    defparam EFB.UFM_INIT_START_PAGE = 638 ;
    defparam EFB.UFM_INIT_PAGES = 1 ;
    defparam EFB.DEV_DENSITY = "1200U" ;
    defparam EFB.EFB_UFM = "ENABLED" ;
    defparam EFB.TC_ICAPTURE = "DISABLED" ;
    defparam EFB.TC_OVERFLOW = "DISABLED" ;
    defparam EFB.TC_ICR_INT = "OFF" ;
    defparam EFB.TC_OCR_INT = "OFF" ;
    defparam EFB.TC_OV_INT = "OFF" ;
    defparam EFB.TC_TOP_SEL = "OFF" ;
    defparam EFB.TC_RESETN = "ENABLED" ;
    defparam EFB.TC_OC_MODE = "TOGGLE" ;
    defparam EFB.TC_OCR_SET = 32767 ;
    defparam EFB.TC_TOP_SET = 65535 ;
    defparam EFB.GSR = "ENABLED" ;
    defparam EFB.TC_CCLK_SEL = 1 ;
    defparam EFB.TC_MODE = "CTCM" ;
    defparam EFB.TC_SCLK_SEL = "PCLOCK" ;
    defparam EFB.EFB_TC_PORTMODE = "WB" ;
    defparam EFB.EFB_TC = "DISABLED" ;
    defparam EFB.SPI_WAKEUP = "DISABLED" ;
    defparam EFB.SPI_INTR_RXOVR = "DISABLED" ;
    defparam EFB.SPI_INTR_TXOVR = "DISABLED" ;
    defparam EFB.SPI_INTR_RXRDY = "DISABLED" ;
    defparam EFB.SPI_INTR_TXRDY = "DISABLED" ;
    defparam EFB.SPI_SLAVE_HANDSHAKE = "DISABLED" ;
    defparam EFB.SPI_PHASE_ADJ = "DISABLED" ;
    defparam EFB.SPI_CLK_INV = "DISABLED" ;
    defparam EFB.SPI_LSB_FIRST = "DISABLED" ;
    defparam EFB.SPI_CLK_DIVIDER = 1 ;
    defparam EFB.SPI_MODE = "MASTER" ;
    defparam EFB.EFB_SPI = "DISABLED" ;
    defparam EFB.I2C2_WAKEUP = "DISABLED" ;
    defparam EFB.I2C2_GEN_CALL = "DISABLED" ;
    defparam EFB.I2C2_CLK_DIVIDER = 1 ;
    defparam EFB.I2C2_BUS_PERF = "100kHz" ;
    defparam EFB.I2C2_SLAVE_ADDR = "0b1000010" ;
    defparam EFB.I2C2_ADDRESSING = "7BIT" ;
    defparam EFB.EFB_I2C2 = "DISABLED" ;
    defparam EFB.I2C1_WAKEUP = "DISABLED" ;
    defparam EFB.I2C1_GEN_CALL = "DISABLED" ;
    defparam EFB.I2C1_CLK_DIVIDER = 1 ;
    defparam EFB.I2C1_BUS_PERF = "100kHz" ;
    defparam EFB.I2C1_SLAVE_ADDR = "0b1000001" ;
    defparam EFB.I2C1_ADDRESSING = "7BIT" ;
    defparam EFB.EFB_I2C1 = "DISABLED" ;
	// Frank 06012015 modify 
    //- defparam EFB.EFB_WB_CLK_FREQ = "7.0" ; 
	defparam EFB.EFB_WB_CLK_FREQ = "33.0" ;  // Input clock for UFM_WrRd is 33MHz 
	
	// Frank 06302015 modify instance name to EFB 
	EFB EFB(.WBCLKI(wb_clk_i), .WBRSTI(wb_rst_i), .WBCYCI(wb_cyc_i), 
    //- EFB EFB (.WBCLKI(wb_clk_i), .WBRSTI(wb_rst_i), .WBCYCI(wb_cyc_i), 
        .WBSTBI(wb_stb_i), .WBWEI(wb_we_i), .WBADRI7(wb_adr_i[7]), .WBADRI6(wb_adr_i[6]), 
        .WBADRI5(wb_adr_i[5]), .WBADRI4(wb_adr_i[4]), .WBADRI3(wb_adr_i[3]), 
        .WBADRI2(wb_adr_i[2]), .WBADRI1(wb_adr_i[1]), .WBADRI0(wb_adr_i[0]), 
        .WBDATI7(wb_dat_i[7]), .WBDATI6(wb_dat_i[6]), .WBDATI5(wb_dat_i[5]), 
        .WBDATI4(wb_dat_i[4]), .WBDATI3(wb_dat_i[3]), .WBDATI2(wb_dat_i[2]), 
        .WBDATI1(wb_dat_i[1]), .WBDATI0(wb_dat_i[0]), .PLL0DATI7(scuba_vlo), 
        .PLL0DATI6(scuba_vlo), .PLL0DATI5(scuba_vlo), .PLL0DATI4(scuba_vlo), 
        .PLL0DATI3(scuba_vlo), .PLL0DATI2(scuba_vlo), .PLL0DATI1(scuba_vlo), 
        .PLL0DATI0(scuba_vlo), .PLL0ACKI(scuba_vlo), .PLL1DATI7(scuba_vlo), 
        .PLL1DATI6(scuba_vlo), .PLL1DATI5(scuba_vlo), .PLL1DATI4(scuba_vlo), 
        .PLL1DATI3(scuba_vlo), .PLL1DATI2(scuba_vlo), .PLL1DATI1(scuba_vlo), 
        .PLL1DATI0(scuba_vlo), .PLL1ACKI(scuba_vlo), .I2C1SCLI(scuba_vlo), 
        .I2C1SDAI(scuba_vlo), .I2C2SCLI(scuba_vlo), .I2C2SDAI(scuba_vlo), 
        .SPISCKI(scuba_vlo), .SPIMISOI(scuba_vlo), .SPIMOSII(scuba_vlo), 
        .SPISCSN(scuba_vlo), .TCCLKI(scuba_vlo), .TCRSTN(scuba_vlo), .TCIC(scuba_vlo), 
        .UFMSN(scuba_vhi), .WBDATO7(wb_dat_o[7]), .WBDATO6(wb_dat_o[6]), 
        .WBDATO5(wb_dat_o[5]), .WBDATO4(wb_dat_o[4]), .WBDATO3(wb_dat_o[3]), 
        .WBDATO2(wb_dat_o[2]), .WBDATO1(wb_dat_o[1]), .WBDATO0(wb_dat_o[0]), 
        .WBACKO(wb_ack_o), .PLLCLKO(), .PLLRSTO(), .PLL0STBO(), .PLL1STBO(), 
        .PLLWEO(), .PLLADRO4(), .PLLADRO3(), .PLLADRO2(), .PLLADRO1(), .PLLADRO0(), 
        .PLLDATO7(), .PLLDATO6(), .PLLDATO5(), .PLLDATO4(), .PLLDATO3(), 
        .PLLDATO2(), .PLLDATO1(), .PLLDATO0(), .I2C1SCLO(), .I2C1SCLOEN(), 
        .I2C1SDAO(), .I2C1SDAOEN(), .I2C2SCLO(), .I2C2SCLOEN(), .I2C2SDAO(), 
        .I2C2SDAOEN(), .I2C1IRQO(), .I2C2IRQO(), .SPISCKO(), .SPISCKEN(), 
        .SPIMISOO(), .SPIMISOEN(), .SPIMOSIO(), .SPIMOSIEN(), .SPIMCSN7(), 
        .SPIMCSN6(), .SPIMCSN5(), .SPIMCSN4(), .SPIMCSN3(), .SPIMCSN2(), 
        .SPIMCSN1(), .SPIMCSN0(), .SPICSNEN(), .SPIIRQO(), .TCINT(), .TCOC(), 
        .WBCUFMIRQ(wbc_ufm_irq), .CFGWAKE(), .CFGSTDBY());



    // exemplar begin
    // exemplar end

endmodule  // EFBWishbone
