//////////////////////////////////////////////////////////////////////////////
// File name        : UFMRwPageDecode.v
// Module name      : UFMRwPageDecode
// Description      : This module R/W one page(16 bytes)of MXO2 UFM via a LPC-
//                    to-WISHBONE master            
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : UFMRwPage , sync
////////////////////////////////////////////////////////////////////////////// 
//  Notes :  
//  (1) Only lowest 32bits data of this UFM page are accessed.
//  (2) Use internal 7MHz clock for WISHBONE
//  (3) Lattice MXO2-2000 UFM write timing needs to erase UFM first .
//      Erasing MXO-2000 needs 500~900ms.
//      Programming a page ( 16 byte ) data to UFM needs around 0.2 ms.
//      Reading a page from UFM needs the time less than 1 ms.
//
/////////////////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/DefineEFBTextMacro.v" 
// Frank 06302015 rename file and module to UFMRwPage.v and UFMRwPage
//- `include "efb_define_def.v" 
//- module UFM_RW_Top(
module UFMRwPageDecode ( 
       //; *** system clock and reset
		input         CLK_i,		//This clock use for wishbone clock, so it should same as config in EFB of wishbone frequency
		input         nRst,
	   //; *** Enable signal
	    // Frank 06012015 modify -- Start --- 
	    // Original input signal are changed to internal wire assignments
        // Use new active high input events. bWrPromCfg and bRdPromCfg.  
//-	    input		  	wr_en_n,	//write ufm when falling edge
//-		input			rd_en_n,	//read ufm when falling edge 
		input bWrPromCfg,
		input bRdPromCfg, 
		//UFB cstate output for debug
	//-	output [2:0]	cstate_out,
       //; *** SGPIO Bus
		input [31:0]	ufm_data_in,
		output [31:0]	ufm_data_out
   
       // *** for simulation
	   `ifdef SIM_MODE	   

       `endif
       );
	   
// Frank 06012015 add -- start --
   wire wr_en_n;
   wire rd_en_n;
   assign wr_en_n = !bWrPromCfg ; //Inversion of input , to get a falling edge trigger event
   assign rd_en_n = !bRdPromCfg ; //Inversion of input , to get a falling edge trigger event
// Frank 06012015 add -- end   --

reg	[31:0]	ufm_data_out;
//////////////////////////////////////////////////////      
//             XO2 embeded OSC                      // 
//////////////////////////////////////////////////////
`ifdef XO2_OSC
wire osc_clk; // <44.3Mhz , simulation UFM W/R ok
wire Inner_Clk = osc_clk;
//- wire Inner_Clk = CLK_i;
defparam OSCH_inst.NOM_FREQ = "7.00"; //"2.08";// This is the default frequency

//defparam OSCH_inst.NOM_FREQ = "24.18";
OSCH OSCH_inst( 
     .STDBY(1'b0), // 0=Enabled, 1=Disabled
     // also Disabled with Bandgap=OFF
     .OSC(osc_clk),
     .SEDSTDBY()
     );
`endif

//*** Enable posedge detect   
//reg [1:0] wr_dly, rd_dly;
reg	 WrStrb, RdStrb, wren_clr, rden_clr;
wire wren_rstn = nRst & !wren_clr;
always @(negedge wr_en_n or negedge wren_rstn) begin
       if (~wren_rstn) 	 
	        WrStrb <= 1'b0;
	   else 
	        WrStrb <= 1'b1;
end	

wire rden_rstn = nRst & !rden_clr;
always @(negedge rd_en_n or negedge rden_rstn) begin
       if (~rden_rstn) 	 
	        RdStrb <= 1'b0;
	   else 
	        RdStrb <= 1'b1;
end		
wire	WrStrb_sync,RdStrb_sync;
sync wr_sync (
				.data_in	(WrStrb), 
				.data_out	(WrStrb_sync), 
				.sync_clk	(Inner_Clk), 
				.sync_clk_en(1'b1), 
				.sync_rst_n	(nRst)
			);
sync rd_sync (
				.data_in	(RdStrb), 
				.data_out	(RdStrb_sync), 
				.sync_clk	(Inner_Clk), 
				.sync_clk_en(1'b1), 
				.sync_rst_n	(nRst)
			);
		
//wire	WrStrb	=	(wr_dly == 2'b01)?	1'b1 : 1'b0;
//wire	RdStrb	=	(rd_dly == 2'b01)?	1'b1 : 1'b0;

// *****************************************
//|  Main State Machine of Barcode W/R Flow |
// *****************************************
reg [2:0] C_State;
reg [7:0] UFM_Page_Num;
reg		  nbusy_sig,UFM_Er_Cmd, UFM_Wr_Cmd, UFM_Rd_Cmd;
reg [7:0] UFM_Page_StAdrs;
//assign Rd_Security = ~BarCode_Enable;   //0x25 bit[5] = '0'
//wire Page_Er_Cycle = (C_State==`Erase_UFM_Sts);
always @(negedge Inner_Clk or negedge nRst) begin
       if (~nRst) begin	       
		   UFM_Page_StAdrs <= 8'h01;
		   UFM_Page_Num <= 8'h00;
		   nbusy_sig <= 1'b1;
		   UFM_Er_Cmd <= 1'b0;
		   UFM_Wr_Cmd <= 1'b0;
		   UFM_Rd_Cmd <= 1'b0;
		   rden_clr	  <= 1'b0;
		   wren_clr	  <= 1'b0;
		   //C_State <= `Idle_Sts;
		   C_State <= `StandBy_Sts;
           end 		   
	   else begin
	        case(C_State) 
                  `StandBy_Sts:begin 
				            //nbusy_sig  <= 1'b1;         //ready
							UFM_Page_StAdrs <= 8'h01;
							UFM_Page_Num <= 8'h01;
							rden_clr	  <= 1'b0;
							wren_clr	  <= 1'b0;
							if (RdStrb_sync) begin
							     nbusy_sig  <= 1'b0;    //busy
							     UFM_Rd_Cmd <= 1'b1;
								 //UFM_Page_Num <= `UFM_BarCode_PageNum; //8'h01;
								 C_State <= `Read_UFM_Sts;
								 rden_clr	  <= 1'b1;
                                 end
				            else if (WrStrb_sync) begin 
							     nbusy_sig  <= 1'b0;    //busy
							     UFM_Er_Cmd <= 1'b1;
								 C_State <= `Erase_UFM_Sts; 
								 wren_clr	  <= 1'b1;
							     end
							else begin
								UFM_Page_StAdrs <= 8'h01;
								nbusy_sig <= 1'b1;		//ready
								UFM_Er_Cmd <= 1'b0;
								UFM_Wr_Cmd <= 1'b0;
								UFM_Rd_Cmd <= 1'b0;
								C_State <= `StandBy_Sts;
								end
						 
							end

                  `Erase_UFM_Sts:begin 
				            nbusy_sig  <= 1'b0;        //busy	
							rden_clr	  <= 1'b0;
							wren_clr	  <= 1'b1;
				            if (Erase_End_Strb) begin 
							    //nbusy_sig  <= 1'b1;    //ready
							    UFM_Er_Cmd <= 1'b0;
								UFM_Wr_Cmd <= 1'b1;
								UFM_Page_StAdrs <= 8'h01; 
								UFM_Page_Num <= `UFM_BarCode_PageNum;
								C_State <= `Write_UFM_Sts; //`StandBy_Sts;
							    end
							end	

                  `Write_UFM_Sts:begin 
				            nbusy_sig  <= 1'b0;        //busy
                            UFM_Wr_Cmd <= 1'b1;
							rden_clr	  <= 1'b0;
							wren_clr	  <= 1'b0;
				            if (Page_WrEnd_Strb) begin 
							    UFM_Wr_Cmd <= 1'b0;
							    if (UFM_Page_Num >1) begin
								     //nbusy_sig  <= 1'b1;    //ready
									 UFM_Page_StAdrs <= UFM_Page_StAdrs + 1;
									 UFM_Page_Num <= UFM_Page_Num - 1;
							         //UFM_Wr_Cmd <= 1'b0;
								     //C_State <= `StandBy_Sts;
								     end 
								else begin
							         nbusy_sig  <= 1'b1;    //ready
							         UFM_Wr_Cmd <= 1'b0;
									 
								     C_State <= `StandBy_Sts; // --- `Write_UFM_delay; 
									 end                                                                                                  
							    end
							end	

                  `Read_UFM_Sts:begin 
				            nbusy_sig  <= 1'b0;        //busy		
							rden_clr	  <= 1'b1;
							wren_clr	  <= 1'b0;
				            if (Page_RdEnd_Strb) begin 
							    nbusy_sig  <= 1'b1;    //ready
							    UFM_Rd_Cmd <= 1'b0;
								C_State <= `StandBy_Sts; //--- `Read_UFM_delay; 
							    end
							end	

          	      default: C_State <= `StandBy_Sts;  
	           endcase 
	      end 
end	  			  

//////////////////////////////////////////////////////      
//             Sub-Modules                          // 
//////////////////////////////////////////////////////
wire Page_Wr_Cycle,Page_Rd_Cycle;
reg  [7:0] UFM_Page_WrData;
wire [7:0] UFM_Page_RdData, UFM_Rd_Dt_Addrs, UFM_Wr_Dt_Addrs;
wire Page_WrEnd_Strb, Page_RdEnd_Strb, Erase_End_Strb;		   

reg	[31:0]	ufm_wr_data;
always @(posedge WrStrb_sync or negedge nRst) begin
       if (~nRst) 	 
	        ufm_wr_data <= 32'b0;
	   else 
	        ufm_wr_data <= ufm_data_in;
end	

always @(*) begin  //'=' blocking for Combinational Logic
	     case(UFM_Wr_Dt_Addrs)
	          8'h0 : UFM_Page_WrData = ufm_wr_data[7:0];   
	          8'h1 : UFM_Page_WrData = ufm_wr_data[15:8];   
	          8'h2 : UFM_Page_WrData = ufm_wr_data[23:16];   
	          8'h3 : UFM_Page_WrData = ufm_wr_data[31:24];   
  	        default: UFM_Page_WrData = 8'h0;   
	     endcase                                                                
end

always @(negedge Inner_Clk) begin  //'=' blocking for Combinational Logic
	if	(Page_Rd_Cycle == 1'b1) begin
	     case(UFM_Rd_Dt_Addrs)
	          8'h0 : ufm_data_out[7:0] 		<= UFM_Page_RdData;   
	          8'h1 : ufm_data_out[15:8] 	<= UFM_Page_RdData;   
	          8'h2 : ufm_data_out[23:16] 	<= UFM_Page_RdData;   
	          8'h3 : ufm_data_out[31:24] 	<= UFM_Page_RdData;   
  	        default: ufm_data_out <= ufm_data_out;   
	     endcase
	end
	else
		ufm_data_out	<=	ufm_data_out;
end

// Frank 06302015 modify module name 
//-UFM_WrRd UFM_WrRd_U1(
UFMRwPage UFMRwPage(
         .rst_n(nRst),   
         .clk_i(Inner_Clk) , 
	     .Host_WrPage_End(1'b1) ,	     
		 .UFM_Er_Cmd(UFM_Er_Cmd),
		 .UFM_Wr_Cmd(UFM_Wr_Cmd), 
	     .UFM_Rd_Cmd(UFM_Rd_Cmd),
		 
	     .Page_StAdrs(UFM_Page_StAdrs), //UFM_Page_StAdrs) ,
	     .Page_WrData(UFM_Page_WrData), 
	     .Page_Num(UFM_Page_Num),  //UFM_Page_RdNum) ,     
	     .Page_RdData(UFM_Page_RdData) ,
		 .Rd_Dt_Addrs(UFM_Rd_Dt_Addrs),
		 .Wr_Dt_Addrs(UFM_Wr_Dt_Addrs),
		 
	     
	     .Page_Wr_Cycle(Page_Wr_Cycle) ,
	     .Page_Rd_Cycle(Page_Rd_Cycle) ,
		 .Page_WrEnd_Strb(Page_WrEnd_Strb),
	     .Page_RdEnd_Strb(Page_RdEnd_Strb),
		 .Erase_End_Strb(Erase_End_Strb)
         );  
      

 
endmodule 
//; ------------------------ EOF ----------------------        