//////////////////////////////////////////////////////////////////////////////
// File name        : UFMRwPage.v
// Module name      : UFMRwPage
// Description      : This module R/W one page(16 bytes)of MXO2 UFM via a LPC-
//                    to-WISHBONE master             
// Hierarchy Up     : UFMRwPageDecode
// Hierarchy Down   : efb
////////////////////////////////////////////////////////////////////////////// 
//  Notes :    
//(1)efb.ipx ( Lattice IP and configuration code ) and efb.lpc must be located
//  in the same directory. efb.ipx needs to be included as a source in Lattice
//  Diamond PLD development tool. Double click efb.ipx could configure Lattice 
//  EFB ( Embedded Function Block, supports embedded hardened cores for PLL, 
//  I2C, SPI, Timer/Counter, UFM ( User Flash Memory ) via WISHBONE interface.)
//  Strongly recommend to use 7MHz from Internal clock for WISHBONE interface.//     
//(2)efb.v module will be automatically generated after the configuration 
//  (
//    automatically detect CPLD/FPGA device, 
//    manually select WISHBONE clock frequency 
//    manually initialize UFM pages with all_0 or specific data pattern 
//   )
//  in the same directory of efb.ipx in Lattice Diamond tool.     
//(3)efb Module Instantiation
//  Use original module name efb and instantiated name u1_efb.   
/////////////////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineEFBTextMacro.v" 
// Frank 06302015 modify module name // 
//- module UFM_WrRd(
module UFMRwPage (
       input rst_n ,          
       input  clk_i ,       //from embeded OSC(2.08M)oh Top level
      
	   input  Host_WrPage_End ,
	   input  UFM_Er_Cmd , 
	   input  UFM_Wr_Cmd ,
	   input  UFM_Rd_Cmd ,
	   
	   input  [7:0] Page_StAdrs ,
	   input  [7:0] Page_WrData ,	
	   input  [7:0] Page_Num ,         
	   output [7:0] Page_RdData ,
	   output [7:0] Rd_Dt_Addrs,
	   output [7:0] Wr_Dt_Addrs,
       output Page_DtRead_Strb,	 	   
	        	     
	   output Page_Wr_Cycle ,
	   output Page_Rd_Cycle , 
	   output Page_WrEnd_Strb,
	   output Page_RdEnd_Strb,	   
       output reg Erase_End_Strb          
       
       `ifdef UFM_SIM
       ,//input wb_ack_sim_i ,
       output [7:0] c_state_out
       `endif
       );  
       
       
//****  ER_EN_Strb .WR_EN_Strb .RD_EN_Strb
reg [1:0] UFM_Er_Cmd_Dly, UFM_Wr_Cmd_Dly, UFM_Rd_Cmd_Dly;
always @ (posedge clk_i or negedge rst_n) begin
		if(!rst_n) begin		    
		    UFM_Er_Cmd_Dly <= 0; 
		    UFM_Wr_Cmd_Dly <= 0;
		    UFM_Rd_Cmd_Dly <= 0;
		    end
		else begin
		    UFM_Er_Cmd_Dly <= {UFM_Er_Cmd_Dly[0], UFM_Er_Cmd}; 
		    UFM_Wr_Cmd_Dly <= {UFM_Wr_Cmd_Dly[0], UFM_Wr_Cmd}; 
		    UFM_Rd_Cmd_Dly <= {UFM_Rd_Cmd_Dly[0], UFM_Rd_Cmd}; 
		end	   
end

wire ER_EN_Strb = (UFM_Er_Cmd_Dly==2'b01); //b10);
wire WR_EN_Strb = (UFM_Wr_Cmd_Dly==2'b01); //b10);
wire RD_EN_Strb = (UFM_Rd_Cmd_Dly==2'b01); //b10);      
        
               

//***********************************************************************
//*                                                                     *
//* WISHBONE INTERFACE SIGNAL                                           *
//*                                                                     *
//***********************************************************************/
reg  [7:0] wb_dat_i ;
reg        wb_stb_i ;
wire       wb_cyc_i =  wb_stb_i ;
reg  [7:0] wb_adr_i ;
reg        wb_we_i  ;
wire [7:0] wb_dat_o ;
wire       wb_ack_o ;

reg  n_Page_Wr_Cyc, Page_Wr_Cyc ;
reg  n_Page_Rd_Cyc, Page_Rd_Cyc ;
reg  Page_RdEnd_Strb_r;
assign Page_Wr_Cycle = Page_Wr_Cyc;
assign Page_Rd_Cycle = Page_Rd_Cyc;
assign Page_RdEnd_Strb = Page_RdEnd_Strb_r;

reg UFM_wr_flag, UFM_rd_flag;
reg Wr_End_Strb, Rd_End_Strb;
assign Page_WrEnd_Strb = Wr_End_Strb;
always @ (posedge clk_i or negedge rst_n) begin
    if(!rst_n)
        UFM_wr_flag <= 0;
    else if(WR_EN_Strb) // || WRER_EN_Strb)
         UFM_wr_flag <= 1;
    else if(Wr_End_Strb)
         UFM_wr_flag <= 0;     
end  

always @ (posedge clk_i or negedge rst_n) begin  
    if(!rst_n)
        UFM_rd_flag <= 0;
    else if(RD_EN_Strb)
         UFM_rd_flag <= 1;
    else if(Rd_End_Strb)
         UFM_rd_flag <= 0;     
end 

reg UFM_erase_flag;
//reg Erase_End_Strb;
always @ (posedge clk_i or negedge rst_n) begin  
    if(!rst_n)
        UFM_erase_flag <= 0;
    else if(ER_EN_Strb) // || WRER_EN_Strb) // || 
         UFM_erase_flag <= 1;
    else if(Erase_End_Strb)
         UFM_erase_flag <= 0;     
end    

reg PageWr_Dt_flag, PageWr_Dt_strb;
always @ (posedge clk_i or negedge rst_n) begin  
    if(!rst_n)
        PageWr_Dt_flag <= 0;
    else if(PageWr_Dt_strb)
         PageWr_Dt_flag <= 1;
    else if(Wr_End_Strb)
         PageWr_Dt_flag <= 0;     
end

reg  [7:0] n_wb_dat_i ;
reg        n_wb_stb_i ;
reg  [7:0] n_wb_adr_i ;
reg        n_wb_we_i  ;

always @ (posedge clk_i or negedge rst_n)
  begin 
    if(!rst_n)
      begin 
         wb_dat_i <= 8'h00;
         wb_stb_i <= 1'b0 ;
         wb_adr_i <= 8'h00;
         wb_we_i  <= 1'b0;   
         Page_Wr_Cyc <= 1'b0;
         Page_Rd_Cyc <= 1'b0;
      end   
    else 
      begin 
         wb_dat_i <=  n_wb_dat_i;
         wb_stb_i <=  #0.1 n_wb_stb_i;
         wb_adr_i <=  n_wb_adr_i;
         wb_we_i  <=  n_wb_we_i ;
         Page_Wr_Cyc <= n_Page_Wr_Cyc;
         Page_Rd_Cyc <= n_Page_Rd_Cyc;
       end 
  end



//***********************************************************************
//* EFB Module Instantiation 
//***********************************************************************
// Frank 08212015 modify , restore efb module name 
efb u1_efb (
//- EFBWishbone EFBWishbone (
    .wb_clk_i(clk_i  ), 
	.wb_rst_i(!rst_n  ), .wb_cyc_i(wb_cyc_i ), .wb_stb_i(wb_stb_i  ), 
    .wb_we_i( wb_we_i), .wb_adr_i(wb_adr_i ), .wb_dat_i(wb_dat_i ), 
    .wb_dat_o( wb_dat_o),    
    .wb_ack_o(wb_ack_o ),   
    .wbc_ufm_irq( )
    );

//***********************************************************************
//*                                                                     *
//* Data Read and Write Register                                        *
//*                                                                     *
//***********************************************************************
reg  [7:0] Page_RdData_r;
assign Page_RdData = wb_dat_o; //131210.v01 Page_RdData_r;
wire Is_RDDt_Sts;
reg  [15:0] Rd_Dt_Cntr, Wr_Dt_Cntr;
wire [7:0] Page_RdNum = Page_Num;
wire Rd_Dt_CntrHit = (Rd_Dt_Cntr== (Page_RdNum*16-1) );
//;131210.v01 add for Dual Port RAM
assign Page_DtRead_Strb = //wb_stb_i & wb_ack_o & Page_Rd_Cyc;
                          Page_Rd_Cyc &  wb_ack_o & Is_RDDt_Sts; 
assign Rd_Dt_Addrs = Rd_Dt_Cntr[7:0];	
assign Wr_Dt_Addrs = Wr_Dt_Cntr[7:0];					  
always @ (posedge clk_i or negedge rst_n) begin   
       if(!rst_n) begin 
           Rd_Dt_Cntr <= 0;
           Page_RdData_r <= 0;
           end  
       else if(RD_EN_Strb)
           Rd_Dt_Cntr <= 0;
       else if(Page_DtRead_Strb) begin
           Rd_Dt_Cntr <= Rd_Dt_Cntr + 1;  
           Page_RdData_r <= wb_dat_o;
       end    
 end
 
 always @ (posedge clk_i or negedge rst_n) begin   
       if(!rst_n) begin 
           Wr_Dt_Cntr <= 0;
           end  
       else if(WR_EN_Strb)
           Wr_Dt_Cntr <= 0;
       else if(Page_Wr_Cyc & wb_ack_o) begin
           Wr_Dt_Cntr <= Wr_Dt_Cntr + 1; 
       end    
 end
 
 
 
  
// **********************************************************************
// *                                                                     *
// * Main State Machine of Wr/Rd UFM                                     *
// *                                                                     *
// ***********************************************************************
reg [7:0]   c_state ,n_state;
reg  n_efb_flag , efb_flag ;
reg  wait5us_tmr_en;//, wait5us_flag ; 
reg  n_count_en;
`ifdef UFM_SIM
wire  [7:0] c_state_out ; // Frank 06012015 add 
assign c_state_out = c_state;
`endif
assign Is_RDDt_Sts = (c_state==`RdPage_Dt_sts);

reg  Busy_Flag;
wire Is_RdBusyBy3_Sts;
assign Is_RdBusyBy3_Sts = (c_state==`RdBusy_By3_sts);
always @ (posedge clk_i or negedge rst_n) begin   
      if(!rst_n) begin 
          Busy_Flag <= 1;
          end         
      else if(Wr_End_Strb || Erase_End_Strb)    
          Busy_Flag <= 1;
      else if(wb_ack_o && Is_RdBusyBy3_Sts) begin //Page_Wr_Cyc &&  
          Busy_Flag <= wb_dat_o[4];
      end    
end

always @ (posedge clk_i or negedge rst_n) begin   
       if(!rst_n) begin 
           c_state  <= 8'h00;
           efb_flag <= 1'b0 ;
           end  
       else begin  
           c_state  <= n_state   ;
           efb_flag <= n_efb_flag;
           end  
end

reg [15:0] wait5us_tmr ;
`ifdef UFM_OSC
wire wait5us_tmr_hit = (wait5us_tmr==50) ;  // (1/10M) * 50 = 5 us
`else
     `ifdef UFM_SIM
wire wait5us_tmr_hit = (wait5us_tmr==50) ;  // (1/2.08M) * 100 = 200 us     
     `else
wire wait5us_tmr_hit = (wait5us_tmr==500) ;  // (1/2.08M) * 100 = 200 us
     `endif
`endif
always @ (posedge clk_i or negedge rst_n) begin   
       if(!rst_n) begin
           wait5us_tmr  <= 16'h0000;
           //wait5us_flag <= 1'b0; 
           end
       //else if(wait5us_tmr_en && !wait5us_flag)begin
       else if(wait5us_tmr_en)begin
       	   if(wait5us_tmr_hit)begin
       	   	   //wait5us_flag <= 1'b1;
       	   	   wait5us_tmr  <= 16'h0000;
       	   	   end
       	   else 
               wait5us_tmr <= wait5us_tmr + 1'b1;
           end    
       else 
           wait5us_tmr  <= 16'h0000;
end   
  
always @ ( * ) begin   
           n_efb_flag   =  1'b0 ; 
           n_state      = c_state ; 
           n_wb_dat_i = 8'h00;
           n_wb_stb_i = 1'b0 ;
           n_wb_adr_i = 8'h00;
           n_wb_we_i  = 1'b0;
           n_count_en = 1'b0; 
           wait5us_tmr_en = 1'b0;
           n_Page_Wr_Cyc = 1'b0; 
           n_Page_Rd_Cyc = 1'b0;    
           Page_RdEnd_Strb_r = 0;
           Wr_End_Strb = 0;
           Rd_End_Strb = 0;
           Erase_End_Strb = 0;
           PageWr_Dt_strb = 0; 
  
     case(c_state)     
     `idle_st : begin
           n_wb_dat_i =  8'h00;
           n_wb_stb_i =  1'b0 ;
           n_wb_adr_i =  8'h00;
           n_wb_we_i  =  1'b0;           
           n_wb_stb_i =  1'b0 ;
           wait5us_tmr_en = 0;
           if(RD_EN_Strb || WR_EN_Strb || ER_EN_Strb ) //UFM_wr_flag || WRER_EN_Strb)
              //n_state = `WboneRst_sts ;  //wishbone reset
               n_state = `WboneEn_sts;
           else
              n_state = c_state;    
           end  
     
     /*      
     `WboneRst_sts: begin //wishbone reset           
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = `ALL_ZERO ;
              n_wb_adr_i = `ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              wait5us_tmr_en = 1;
              n_state = `Wait5us_sts1;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          //CFGCR 0x70 : Control Reg
              n_wb_dat_i = 8'h40;          //CMD   0x40 : WISHBONE Reset;  
              n_wb_stb_i = `HIGH ; 
              n_state = c_state;  
              end
           end 
       
     `Wait5us_sts1: begin
      	   //if(wait5us_flag) begin wait5us_tmr_en
      	   if(wait5us_tmr_hit) begin 
      	   	  wait5us_tmr_en = 0;
      	      n_state = `WboneEn_sts; 
      	      end
      	   else begin
      	      wait5us_tmr_en = 1;
      	      n_state = c_state;   
      	      end
      	   end 
      */
      	   
     `WboneEn_sts: begin // Wishbone Interface Enable 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              //n_state = `Wait5us_sts2;
              n_state = `EnUFM_sts;
              end
           else begin
           	  //Wait5us_flag = 0;
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          //CFGCR 0x70 : Control Reg
              n_wb_dat_i = 8'h80;          //CMD   0x80 : WISHBONE Connection Enable;  
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
       end 	
     
     /*  
     `Wait5us_sts2: begin
      	   if(wait5us_tmr_hit) begin
      	   	  wait5us_tmr_en = 0;
      	      n_state = `EnUFM_sts;   //Enable UFM Interface
      	      end
      	   else begin
      	      wait5us_tmr_en = 1;
      	      n_state = c_state;   
      	      end
      	   end  
     */ 	   
      	   
     `EnUFM_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EnUFM_Op1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h74;          //CMD     0x74 : Enable UFM interface   
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 	                             
     
     `EnUFM_Op1_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EnUFM_Op2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h08;          //Operand 0x'08' 00 00    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
     
     `EnUFM_Op2_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EnUFM_Op3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x08 '00' 00    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `EnUFM_Op3_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `CloseFrm1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x08 00 '00'    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end
           
     `CloseFrm1_sts: begin //close frame
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `OpenFrm1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h00;             
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
      `OpenFrm1_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              if(UFM_erase_flag) begin                  
                  n_state = `EraseUFM_sts; end 
              else begin   
                   n_state = `SetPageAdrs_sts;
                  end
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h80;              
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end                  
           
     //Erase the UFM sector only. //0xCB 
     `EraseUFM_sts: begin //Erase UFM sector
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EraseUFM_Op1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'hCB;          //CMD     0xCB : Erase UFM interface   
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 	                             
     
     `EraseUFM_Op1_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EraseUFM_Op2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x'00' 00 00    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
     
     `EraseUFM_Op2_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EraseUFM_Op3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 '00' 00    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `EraseUFM_Op3_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              //n_state = `Wait5us_sts3; //CloseFrm1_sts;
              //n_state = `PollBusy_sts;
              n_state = `CloseFrm5_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 00 '00'    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end   
           
      //CloseFrm5_sts     
      `CloseFrm5_sts: begin //close frame
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `OpenFrm5_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h00;             
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
      `OpenFrm5_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              //if(Busy_Flag==1)
                   n_state = `PollBusy_sts;
              //else begin
              //	   if(UFM_wr_flag && !EraseUFM_flag)
              //	       n_state = `SetPageAdrs_sts;
              //	   else 
              //         n_state = `DisUFM_sts;
              //     end  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h80;              
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end              
     
     /*      
     `Wait5us_sts3: begin
      	   if(wait5us_tmr_hit) begin
      	   	  wait5us_tmr_en = 0;
      	      //n_state = `EraseUFM_sts;  //Erase UFM
      	      n_state = `SetPageAdrs_sts;  
      	      end
      	   else begin
      	      wait5us_tmr_en = 1;
      	      n_state = c_state;   
      	      end
      	   end       	   
      */	   
 
      /*
     `EraseUFM_sts: begin  //CMD(Hex)/ Operands(Hex): CB/ 00 00 00
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = `ALL_ZERO ;
              n_wb_adr_i = `ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EraseUFM_Op1_sts;
              end
           else begin                      //;Erase CFG sector           0x0E 04 00 00 
              n_efb_flag = `HIGH ;         //;Erase UFM sector           0x0E 08 00 00 
              n_wb_we_i =  `WRITE;         //;Erase UFM and CFG sectors	 0x0E 0C 00 00  
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h0E;          //CMD     0x0E ; 0xCB : Erase UFM;  
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end
           
     `EraseUFM_Op1_sts: begin  
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = `ALL_ZERO ;
              n_wb_adr_i = `ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EraseUFM_Op2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h04;          //Operand 0x'04' 00 00  
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `EraseUFM_Op2_sts: begin  
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = `ALL_ZERO ;
              n_wb_adr_i = `ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `EraseUFM_Op3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x04 '00' 00  
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `EraseUFM_Op3_sts: begin  
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = `ALL_ZERO ;
              n_wb_adr_i = `ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `Wait5us_sts4;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x04 00 '00'  
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `Wait5us_sts4: begin
      	   if(wait5us_tmr_hit) begin
      	   	  wait5us_tmr_en = 0;
      	      n_state = `SetPageAdrs_sts;  //Set UFM Page Address
      	      end
      	   else begin
      	      wait5us_tmr_en = 1;
      	      n_state = c_state;   
      	      end
      	   end 
      */
      	   
     `SetPageAdrs_sts: begin //Set UFM Page Address
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `SetPageAdrs_Op1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              
			  //;131211.v01 modify for Set PageStart_Addrs
			  //if(UFM_rd_flag) 
                  n_wb_dat_i = 8'hB4;          //CMD     0xB4 : Set UFM Page Address 
              //else begin
              //    n_wb_dat_i = 8'h47;          //CMD     0x47 : Init UFM Address to 0000
              //    end 
              
			  n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
       end 
       
     `SetPageAdrs_Op1_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `SetPageAdrs_Op2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x'00' 00 00    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end  
           
     `SetPageAdrs_Op2_sts: begin 
           if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `SetPageAdrs_Op3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 '00' 00    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `SetPageAdrs_Op3_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              
			  //;131211.v01 modify for Set PageStart_Addrs
			  //if(UFM_rd_flag)
                  n_state = `SetPageAdrs_Byte3_sts; 
              //else begin   
              //    n_state = `CloseFrm2_sts;
              //    end 
              
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 00 '00'    
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end     
           
     `SetPageAdrs_Byte3_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `SetPageAdrs_Byte2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h40;          //Operand 0x00 00 00    
              n_wb_stb_i = `HIGH ;         //Data    0x'40' 00 00 xx ; 14-bit page address
              n_state = c_state; 
              end
           end
           
     `SetPageAdrs_Byte2_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `SetPageAdrs_Byte1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 00 00    
              n_wb_stb_i = `HIGH ;         //Data    0x40 '00' 00 xx
              n_state = c_state; 
              end
           end 
           
     `SetPageAdrs_Byte1_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `SetPageAdrs_Byte0_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 00 00    
              n_wb_stb_i = `HIGH ;         //Data    0x40 00 '00' xx
              n_state = c_state; 
              end
           end                 
           
     `SetPageAdrs_Byte0_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              //n_state = `Wait5us_sts4;  
              n_state = `CloseFrm2_sts;
           end
           else begin           	  
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_StAdrs;          //Operand 0x00 00 00    
              n_wb_stb_i = `HIGH ;         //Data    0x40 00 00 'xx' ; 
              n_state = c_state; 
              end
           end                    
      
      `CloseFrm2_sts: begin //close frame
           if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `OpenFrm2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h00;             
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
      `OpenFrm2_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              
              if(UFM_rd_flag)
                 n_state = `RdPageDt_sts;  //rd data from page
              else if(UFM_wr_flag) begin
                 PageWr_Dt_strb = 1;
                 n_state = `WrDtPage_sts;  //wr data to page
                 end
              else 
                 n_state = c_state;      	     
      	      
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h80;              
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end             
           
      /*     
      `Wait5us_sts4: begin
      	   if(wait5us_tmr_hit) begin
      	   	  wait5us_tmr_en = 0;
      	      
      	      if(UFM_rd_flag)
                 n_state = `RdPageDt_sts;  //rd data from page
              else if(UFM_wr_flag)
                 n_state = `WrDtPage_sts;  //wr data to page
              else 
                 n_state = c_state;
                 
      	      end      	      
      	   else begin
      	      wait5us_tmr_en = 1;
      	      n_state = c_state;   
      	      end
      	   end
     */ 	          	   
     
     `WrDtPage_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_OP1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'hC9;          //Cmd     0xC9 : Write UFM page   
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end  
 
     `WrDtPage_OP1_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_OP2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x'00' 00 01    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end
           
     `WrDtPage_OP2_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_OP3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h00;          //Operand 0x00 '00' 01    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end 
           
     `WrDtPage_OP3_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
			  n_Page_Wr_Cyc = 1;
              n_state = `WrDtPage_Dt0_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'h01;          //Operand 0x00 00 '01'    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt0_sts: begin 
     	     n_Page_Wr_Cyc = 1;   
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data0    
              n_wb_stb_i = `HIGH ;                  
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt1_sts: begin 
     	     n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data1    
              n_wb_stb_i = `HIGH ;                      
              n_state = c_state; 
              end
           end 
           
     `WrDtPage_Dt2_sts: begin 
     	     n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data2    
              n_wb_stb_i = `HIGH ;        
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt3_sts: begin 
     	     n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt4_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data3    
              n_wb_stb_i = `HIGH ;     
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt4_sts: begin 
     	     n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt5_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data4    
              n_wb_stb_i = `HIGH ;       
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt5_sts: begin
     	     n_Page_Wr_Cyc = 1;  
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt6_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data5    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt6_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt7_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data7    
              n_wb_stb_i = `HIGH ;      
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt7_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt8_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data7    
              n_wb_stb_i = `HIGH ;    
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt8_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt9_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data8    
              n_wb_stb_i = `HIGH ;       
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt9_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt10_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data9    
              n_wb_stb_i = `HIGH ;     
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt10_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt11_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data10    
              n_wb_stb_i = `HIGH ;       
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt11_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt12_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data11    
              n_wb_stb_i = `HIGH ;    
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt12_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt13_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data12    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt13_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `WrDtPage_Dt14_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data13    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end  
           
     `WrDtPage_Dt14_sts: begin 
         n_Page_Wr_Cyc = 1; 
         if (wb_ack_o && efb_flag) begin
            n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
            n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
            n_wb_we_i =  `LOW ;
            n_wb_stb_i = `LOW ;
            n_efb_flag = `LOW ;
            n_count_en = `LOW ;
            n_state = `WrDtPage_Dt15_sts;
            end
         else begin
            n_efb_flag = `HIGH ;
            n_wb_we_i =  `WRITE;
            n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
            n_wb_dat_i = Page_WrData[7:0]; //Page Data14    
            n_wb_stb_i = `HIGH ;         
            n_state = c_state; 
            end
         end  
           
     `WrDtPage_Dt15_sts: begin 
           n_Page_Wr_Cyc = 1; 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              //Page_Wr_Cyc = 0;
              //n_state = `Wait5us_sts5;
              n_state = `CloseFrm3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;            //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = Page_WrData[7:0]; //Page Data15    
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end  
           
     `Wait5us_sts5: begin
      	   if(wait5us_tmr_hit) begin
      	   	  wait5us_tmr_en = 0;
      	      n_state = `WrNextPage_sts;  
      	      end
      	   else begin
      	      wait5us_tmr_en = 1;
      	      n_state = c_state;   
      	      end
      	   end
      	                                                                                                         
     `WrNextPage_sts: begin
     	     if(Host_WrPage_End) begin //End
     	          //Page_Wr_Cyc = 0;
     	          n_state = `CloseFrm3_sts; 
     	          //n_state = `DisUFM_sts;  //disable UFM interface access
     	          end
     	     else
     	          n_state = `WrDtPage_sts;
     	     end  
     	     
     `RdPageDt_sts: begin
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `RdPageDt_OP1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
              n_wb_dat_i = 8'hCA;          //Cmd     0xCA : Read UFM   
              n_wb_stb_i = `HIGH ;         
              n_state = c_state; 
              end
           end
           
     `RdPageDt_OP1_sts: begin
          if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
             n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
             n_wb_we_i =  `LOW ;
             n_wb_stb_i = `LOW ;
             n_efb_flag = `LOW ;
             n_count_en = `LOW ;
             n_state = `RdPageDt_OP2_sts;
             end
          else begin
             n_efb_flag = `HIGH ;
             n_wb_we_i =  `WRITE;
             n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
             n_wb_dat_i = 8'h10;          //Operand 0x'10' 00 xx ; read xx page data, after 0 dummy byte
             n_wb_stb_i = `HIGH ;         
             n_state = c_state; 
             end
          end 
          
     `RdPageDt_OP2_sts: begin
          if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
             n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
             n_wb_we_i =  `LOW ;
             n_wb_stb_i = `LOW ;
             n_efb_flag = `LOW ;
             n_count_en = `LOW ;
             n_state = `RdPageDt_OP3_sts;
             end
          else begin
             n_efb_flag = `HIGH ;
             n_wb_we_i =  `WRITE;
             n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
             n_wb_dat_i = 8'h00;          //Operand 0x10 '00' xx ; read xx page data, after 0 dummy byte
             n_wb_stb_i = `HIGH ;         
             n_state = c_state; 
             end
          end    
          
     `RdPageDt_OP3_sts: begin
          if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
             n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
             n_wb_we_i =  `LOW ;
             n_wb_stb_i = `LOW ;
             n_efb_flag = `LOW ;
             n_count_en = `LOW ;
             n_Page_Rd_Cyc = 1;
             n_state = `RdPage_Dt_sts;
             end
          else begin
             n_efb_flag = `HIGH ;
             n_wb_we_i =  `WRITE;
             n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data
             n_wb_dat_i = Page_RdNum;     //Operand 0x10 00 xx ; read xx page data, after 0 dummy byte
             n_wb_stb_i = `HIGH ;         
             n_state = c_state; 
             end
          end  
          
     `RdPage_Dt_sts: begin
     	    n_Page_Rd_Cyc = 1;
          if (wb_ack_o && efb_flag) begin
             n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
             n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
             n_wb_we_i =  `LOW ;
             n_wb_stb_i = `LOW ;
             n_efb_flag = `LOW ;
             n_count_en = `LOW ;
             //if(Host_RdPage_End)  
             if(Rd_Dt_CntrHit)    	          
     	            n_state = `CloseFrm3_sts;
             else
                  n_state = `RdPage_Dt_sts; 
             end
          else begin
             n_efb_flag = `HIGH ;
             n_wb_we_i =  `READ;
             n_wb_adr_i = 8'h73;            //CFGTXDR 0x73 : Receive Data
             //n_wb_dat_i = Page_RdNum;     
             n_wb_stb_i = `HIGH ;         
             n_state = c_state; 
             end
          end
          
      `CloseFrm3_sts: begin //close frame
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `OpenFrm3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h00;             
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
      `OpenFrm3_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              if(UFM_wr_flag)
                   n_state = `PollBusy_sts;
              else begin
                   n_state = `DisUFM_sts;
                   end  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h80;              
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end                             
          
     `DisUFM_sts: begin //Disable UFM Interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `DisUFM_Op1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h26;          //CMD     0x26 : Disable UFM Interface 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `DisUFM_Op1_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `DisUFM_Op2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h00;          //Operand      : 0x'00' 00 00 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `DisUFM_Op2_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `DisUFM_Op3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h00;          //Operand      : 0x00 '00' 00 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `DisUFM_Op3_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `NOP_sts;  //Null operation, Bypass
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h00;          //Operand      : 0x00 00 '00' 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end     
           
     `PollBusy_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `PollBusy_Op1_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h3C;          
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `PollBusy_Op1_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `PollBusy_Op2_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h00;          //Operand      : 0x'00' 00 00 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `PollBusy_Op2_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `PollBusy_Op3_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h00;          //Operand      : 0x00 '00' 00 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
     `PollBusy_Op3_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `RdBusy_By1_sts;  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              n_wb_dat_i = 8'h00;          //Operand      : 0x00 00 '00' 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
      `RdBusy_By1_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `RdBusy_By2_sts;  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `READ;
              n_wb_adr_i = 8'h73;          //CFGTXDR 0x71 : Transmit Data       
              //n_wb_dat_i = 8'h00;          //Operand      : 0x00 00 '00' 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end   
           
     `RdBusy_By2_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `RdBusy_By3_sts;  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `READ;
              n_wb_adr_i = 8'h73;          //CFGTXDR 0x71 : Transmit Data       
              //n_wb_dat_i = 8'h00;          //Operand      : 0x00 00 '00' 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end  
           
     `RdBusy_By3_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `RdBusy_By4_sts;  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `READ;
              n_wb_adr_i = 8'h73;          //CFGTXDR 0x71 : Transmit Data       
              //n_wb_dat_i = 8'h00;          //Operand      : 0x00 00 '00' 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end   
           
     `RdBusy_By4_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `CloseFrm4_sts;  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `READ;
              n_wb_adr_i = 8'h73;          //CFGTXDR 0x71 : Transmit Data       
              //n_wb_dat_i = 8'h00;          //Operand      : 0x00 00 '00' 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end         
           
     `CloseFrm4_sts: begin //close frame
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              n_state = `OpenFrm4_sts;
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h00;             
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end 
           
      `OpenFrm4_sts: begin //Enable UFM interface
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;
              if(Busy_Flag==1)
                   n_state = `PollBusy_sts;
              else begin
              	   if(UFM_erase_flag)
              	       n_state = `DisUFM_sts;
              	   else if(UFM_wr_flag && !PageWr_Dt_flag)
              	       n_state = `SetPageAdrs_sts;
              	   else 
                       n_state = `DisUFM_sts;
                   end  
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;          
              n_wb_dat_i = 8'h80;              
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end                                                 
           
     `NOP_sts: begin 
           if (wb_ack_o && efb_flag) begin
              n_wb_dat_i = wb_dat_i; //`ALL_ZERO ;
              n_wb_adr_i = wb_adr_i; //`ALL_ZERO ;
              n_wb_we_i =  `LOW ;
              n_wb_stb_i = `LOW ;
              n_efb_flag = `LOW ;
              n_count_en = `LOW ;       
              
              if(UFM_erase_flag)
                 n_state = `EraseEnd_sts;
              else if(UFM_wr_flag)
                 n_state = `WrEnd_sts;
              else if(UFM_rd_flag) begin 
              	 Page_RdEnd_Strb_r = 1;
                 n_state = `RdEnd_sts; end       
                      
              end
           else begin
              n_efb_flag = `HIGH ;
              n_wb_we_i =  `WRITE;
              n_wb_adr_i = 8'h70;             
              n_wb_dat_i = 8'h00; 
              //n_wb_adr_i = 8'h71;          //CFGTXDR 0x71 : Transmit Data       
              //n_wb_dat_i = 8'hFF;          //CMD     0xFF 
              n_wb_stb_i = `HIGH ; 
              n_state = c_state; 
              end
           end    
 
     `WrEnd_sts: begin             
           //if(UFM_wr_flag || UFM_rd_flag)
           //   n_state = `SetPageAdrs_sts; 
           //else
              Wr_End_Strb = 1;
              n_state = `idle_st;
           end
           
     `RdEnd_sts: begin             
           //if(UFM_wr_flag || UFM_rd_flag)
           //   n_state = `SetPageAdrs_sts; 
           //else
           
             n_state = `idle_st;
             Rd_End_Strb = 1;
           end 
           
     `EraseEnd_sts: begin             
           //if(UFM_wr_flag || UFM_rd_flag)
           //   n_state = `SetPageAdrs_sts; 
           //else
           
             n_state = `idle_st;
             Erase_End_Strb = 1;
           end 
                      
endcase
end


endmodule // UFMRwPage
