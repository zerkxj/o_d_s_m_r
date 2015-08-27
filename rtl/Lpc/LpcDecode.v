//////////////////////////////////////////////////////////////////////////////
// File name        : LpcDecode.v
// Module name      : LpcDecode
// Description      : This module decode LPC I/O read/write to CPLD with specific address and data                
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : DbusIO4 , CpldRegMap
//////////////////////////////////////////////////////////////////////////////  
`timescale 1 ns / 100 ps
//////////////////////////////////////////////////////////////////////////////
`define BAR_BITS 			15:8
`define BASE_ADDR 			8'h08 
`define BIOS_POST_PORT		16'h0080
`define OFFSET_BITS			7:0
`define OFFSET_LED_DAT		8'hAA
module LpcDecode ( 
   // Inputs
   ResetN,                    // PCH RST_PLTRST_N 
   lclk,                      // LPC 33MHz clock input 
   lframe_n,                  // LPC LFranme# signal 
   lad,                       // LPC LAD[3:0] signals         
   csr_dout,                  // CPLD's Internal register data ( byte ) that will be output via Lpc Ior command 
//=========================   
   DevCs_En,                  // Decode LPC I/O Read/write command with specific I/O BAR[15:8]   
   DevAddr,                   // IO Address [15:0]
   RdDev_En,                  // Decode LPC I/O Read  command with specific I/O BAR[15:8]
   WrDev_En,                  // Decode LPC I/O Write command with specific I/O BAR[15:8]
   WrDev_Data,                // I/O Write Data byte of the decoded I/O BAR[15:8] ports
   BiosPostData               // I/O Write Data byte of Port 80h             
   );
/////////////////////////////////////////////////////////////////////////////
input			ResetN;       // PCH RST_PLTRST_N
input			lclk;         // LPC 33MHz clock input 
input			lframe_n;     // LPC LFranme# signal 
inout  [3:0]	lad;          // LPC LAD[3:0] signals          
input  [7:0]	csr_dout;     // CPLD's Internal register data ( byte ) that will be output via Lpc Ior command
/////////////////////////////////////////////////////////////////////////////
output          DevCs_En;     // Decode LPC I/O Read/write command with specific I/O BAR[15:8]
output [15:0]	DevAddr;      // IO Address [15:0]
output			RdDev_En;     // Decode LPC I/O Read  command with specific I/O BAR[15:8]
output			WrDev_En;     // Decode LPC I/O Write command with specific I/O BAR[15:8]
output [7:0]	WrDev_Data;   // I/O Write Data byte of the decoded I/O BAR[15:8] ports
output [7:0]    BiosPostData; // I/O Write Data byte of Port 80h
/////////////////////////////////////////////////////////////////////////////
//FSM Parameter declaration
parameter		IDLE       = 3'h0;
parameter		CYC_TYPE   = 3'h1;
parameter		ADDR_PHASE = 3'h2;
parameter		DATA_IOW   = 3'h3;
parameter		TA_HOST    = 3'h4;
parameter		SYNC_SLV   = 3'h5;
parameter		DATA_IOR   = 3'h6;
parameter		TA_SLV     = 3'h7;
/////////////////////////////////////////////////////////////////////////////
reg    [2:0]	LpcNextState ;     
reg    [2:0]	LpcCurrentState;
reg    [1:0]	cyc_cntr;      // 2 bits cycle counter
reg 			io_wr;         // LPC CYCTYPE = 1:Iow  ; 0:Ior 
reg    [15:0]	io_addr;
reg    [7:0]	csr_din;
reg				lad_out_en;
reg    [3:0]	lad_out;
reg				csr_ren;
reg 			csr_wen;
reg				bios_post_wr;
reg    [7:0]   	BiosPostData;
reg    [15:0]	DevAddr;
/////////////////////////////////////////////////////////////////////////////
wire [3:0]      lad_in;
wire 			addr_hit;
wire			RdDev_En;
wire			WrDev_En;
wire [7:0]		WrDev_Data;
wire            DevCs_En;
/////////////////////////////////////////////////////////////////////////////
	initial
	begin
        BiosPostData		= 8'h00;
	end
//////////////////////////////////////////////////////////////////////  
	DbusIO4 DbusIO4(
		.eWBus		(lad_out_en),    // In
        .WBusDi     (lad_out),       // In[3:0]  
		.RBusDo		(lad_in),        // Out[3:0]     RBusDo   = DataBusx
		.DataBusx	(lad)            // Inout[3:0] , DataBusx = eWBus ? WBusDi : 4'hz 
	);
//////////////////////////////////////////////////////////////////////
    assign DevCs_En     = csr_ren | csr_wen;	
    assign RdDev_En 	= (addr_hit) ? csr_ren : 1'b0;
    assign WrDev_En 	= (addr_hit) ? csr_wen : 1'b0;
    assign WrDev_Data	= (addr_hit) ? csr_din : 8'hFF;
/////////////////////////////////////////////////////////////////////////////
	always @(posedge lclk or negedge ResetN)
	begin
    	if (!ResetN)
			DevAddr <= #1 16'hFFFF;
    	else
            if(addr_hit) DevAddr <= #1 io_addr;
	end
/////////////////////////////////////////////////////////////////////////////
//***************************************************************************
//                             1. Control FSM for LPC I/F
//                      Support I/O read/write operation only!!!
//***************************************************************************
	always @(posedge lclk or negedge ResetN)
	begin
    	if (!ResetN)
			LpcCurrentState <= #1 IDLE;  
    	else
			LpcCurrentState <= #1 LpcNextState ;   
	end

	always @(addr_hit or LpcCurrentState or cyc_cntr or io_wr or lad_in or lframe_n) 	
	begin    	
		case (LpcCurrentState) 
		IDLE:
		begin
	   		if (!lframe_n && (lad_in == 4'h0))   //START frame for MEM/IO/DMA supported.
				LpcNextState = CYC_TYPE; 
			else
				LpcNextState = IDLE;   
		end

		CYC_TYPE: 
		begin
			if (!lframe_n) 
			begin                              //long START phase
				if (lad_in == 4'h0)            //still START frame supported
					LpcNextState = CYC_TYPE;  
				else                           //other START cycle not supported.
					LpcNextState = IDLE;      
			end
			else
			begin                              //Cycle Type phase
				if (lad_in[3:2] == 2'b00)      //I/O read/write operation
					LpcNextState = ADDR_PHASE; 
				else                           //other operations not supported
					LpcNextState = IDLE;       
			end                                // else: !if(lframe_n == 1'b0)
		end                                    // case: CYC_TYPE

		ADDR_PHASE: 
		begin
			if (!lframe_n)                     //host abort
				LpcNextState  = IDLE;  
			else if (cyc_cntr == 2'b11)
			begin                              //16-bit address
	      		if (io_wr)                     //I/O write operation, jump to DATA phase
					LpcNextState  = DATA_IOW;  
	      		else                           //I/O write operation, jump to Turn-around phase.
					LpcNextState  = TA_HOST;   
	   		end
	   		else
	     		LpcNextState  = ADDR_PHASE; 
		end                                    // case: ADDR_PHASE

		DATA_IOW: 
		begin
			if (!lframe_n)                     //host abort
	     		LpcNextState  = IDLE;  
	   		else if (cyc_cntr == 2'b01)
	     		LpcNextState  = TA_HOST;  
	   		else
	     		LpcNextState  = DATA_IOW;  
		end

		TA_HOST:
		begin
			if (!lframe_n)                     //host abort
				LpcNextState  = IDLE;  
			else
			begin
	      		if (!addr_hit)                 //not targetting this device                
					LpcNextState  = IDLE; 
	      		else if (cyc_cntr == 2'b01)
					LpcNextState  = SYNC_SLV; 
	      		else
					LpcNextState  = TA_HOST;   
	   		end
		end                                    // case: TA_HOST

		SYNC_SLV: 
		begin
	   		if (!lframe_n)                     //host abort
	     		LpcNextState  = IDLE;  
	   		else if (io_wr)                    //I/O write operation
				LpcNextState  = TA_SLV;  
			else                               //I/O read operation
				LpcNextState  = DATA_IOR; 
		end

		DATA_IOR: 
		begin
			if (!lframe_n)                     //host abort
				LpcNextState  = IDLE;      
	   		else if (cyc_cntr == 2'b01)
	     		LpcNextState  = TA_SLV;   
	   		else
	     		LpcNextState  = DATA_IOR;  
		end

		TA_SLV: 
		begin
			LpcNextState  = IDLE;  
		end

		default: 
		begin
			LpcNextState  = IDLE; 
		end
		endcase                              // case(LpcCurrentState)
	end                                      // always@(addr_hit or LpcCurrentState or cyc_cntr or io_wr or lad_in or lframe_n)
/////////////////////////////////////////////////////////////////////////////
//***************************************************************************
//                           2. FSM Control & Output Signals
//***************************************************************************
	//1) 2-bit cycle counter.
	always@ (posedge lclk or negedge ResetN)
	begin
		if (!ResetN)
        begin
			cyc_cntr <= #1 2'b00;
        end
		else 
		begin
			case (LpcCurrentState) 
	   		ADDR_PHASE:
			begin
	      		cyc_cntr <= #1 cyc_cntr + 1;
	   		end

	   		TA_HOST,
			DATA_IOR, 
			DATA_IOW:
			begin
				if (cyc_cntr == 2'b01)
					cyc_cntr <= #1 2'b0;
	      		else
					cyc_cntr <= #1 cyc_cntr + 1;
	   		end
	   		default: cyc_cntr <= #1 2'b00;
	 		endcase                              // case(LpcCurrentState) 
		end
	end
/////////////////////////////////////////////////////////////////////////////
	//2) I/O Read/Write flag -- 1'b1: write;    1'b0: read;
	always@ (posedge lclk or negedge ResetN)
	begin
    	if (!ResetN)
			io_wr <= #1 1'b0;
// Modified by Frank 07312015
//-	else if (lframe_n && (lad_in[3:1] == 3'b001) && (LpcCurrentState == CYC_TYPE))  
//-		io_wr <= #1 1'b1;
		else if (lframe_n && (lad_in[3:2] == 2'b00) && (LpcCurrentState == CYC_TYPE))  
			io_wr <= #1 lad_in[1] ; 			
		else if ( LpcCurrentState == IDLE)  
			io_wr <= #1 1'b0; 			
	end 
	
/////////////////////////////////////////////////////////////////////////////
	//3) I/O address for the operation.
	always@ (posedge lclk or negedge ResetN)
	begin
		if (!ResetN)
			io_addr <= #1 16'hFFFF;
		else
		begin
			if (LpcCurrentState == IDLE) io_addr <= #1 16'hFFFF;  
			else if (LpcCurrentState == ADDR_PHASE)              
			begin
				case (cyc_cntr)                      //MSB first for ADDRESS
				2'b00: io_addr[15:12] <= #1 lad_in;
	   			2'b01: io_addr[11:8]  <= #1 lad_in;
				2'b10: io_addr[7:4]   <= #1 lad_in;
				2'b11: io_addr[3:0]   <= #1 lad_in;
				endcase                              // case(cyc_cntr)
            end
		end
	end                                              // always@ (posedge lclk or negedge ResetN)
/////////////////////////////////////////////////////////////////////////////
	//4) Base address hit flag, last till the end of the cycle.
	assign addr_hit = (IDLE == LpcCurrentState) ? 1'b0 : io_addr[`BAR_BITS] == `BASE_ADDR; 
/////////////////////////////////////////////////////////////////////////////
	//5) Data input for I/O write operation, and corresponding write read signal.
	always@ (posedge lclk or negedge ResetN)
	begin
		if (!ResetN)
		begin
	 		csr_wen <= #1 1'b0;
	 		csr_din <= #1 8'h0;
      	end
		else if ( LpcCurrentState == DATA_IOW)  
		begin
			if (cyc_cntr[0]) 
			begin
	    		csr_wen <= #1 addr_hit & io_wr;
	    		csr_din[7:4] <= #1 lad_in;
			end
	 		else 
			begin
				csr_wen <= #1 1'b0;
				csr_din[3:0] <= #1 lad_in;     //LSB first for DATA
			end
		end
		else
			csr_wen <= #1 1'b0;
	end                                       // always@ (posedge lclk or negedge ResetN)

	always@ (posedge lclk or negedge ResetN)
	begin
		if (!ResetN)
			csr_ren <= #1 1'b0;
		else if ((LpcCurrentState == TA_HOST) && ~cyc_cntr[0])  
			csr_ren <= #1 addr_hit & ~io_wr;
		else
			csr_ren <= #1 1'b0;
	end

	always@ (posedge lclk or negedge ResetN)
	begin
		if (!ResetN)
		begin
			bios_post_wr <= #1 1'b0;
	 		
            BiosPostData <= #1 8'h00;
		end
		else
		begin
			bios_post_wr <= #1 ( LpcCurrentState == DATA_IOW) & cyc_cntr[0] & (io_addr == `BIOS_POST_PORT); 
			BiosPostData <= #1 (bios_post_wr) ? csr_din : BiosPostData;
		end
	end
/////////////////////////////////////////////////////////////////////////////
	//6) data to be driven on lad[3:0] and lad driven enable.
	/*SYNC encoding
	4'h0: Read -- SYNC without error;
    4'h1~4'h4: Reserved;
    4'h5: Short Wait -- Max. 8-cycles;
    4'h6: Long Wait -- No limitation;
    4'h7~4'h8: Reserved;
    4'h9: Ready more. for DMA only;
    4'hA: error, to replace SERR#/IOCHK# signal;
    4'hB~4'hF: Reserved.
	*/
	always@ (posedge lclk or negedge ResetN)
	begin
		if (!ResetN)
		begin
			lad_out_en <= #1 1'b0;
			lad_out <= #1 4'h0;
		end
		else 
		begin
			case (LpcCurrentState) 
			TA_HOST: 
			begin
				lad_out_en <= #1 addr_hit & cyc_cntr[0];
				lad_out <= #1 4'h0;                      // ready -- SYNC without error.
			end

			SYNC_SLV: 
			begin
				if (~io_wr) 
				begin
					lad_out_en <= #1 addr_hit;
					lad_out <= #1 csr_dout[3:0];         //I/O read data -- first nibble
				end
				else 
				begin
		 			lad_out_en <= #1 addr_hit;
		 			lad_out <= #1 4'hF;                  //Slave turn around -- first cycle.
	      		end
			end

			DATA_IOR: 
			begin
				lad_out_en <= #1 addr_hit & ~io_wr;
				if (cyc_cntr[0] == 1'b0)
					lad_out <= #1 csr_dout[7:4];
				else                                    //Turn around -- first cycle.
					lad_out <= #1 4'hF;                 // drive LAD high for 1-cycle and then tri-state.
			end
			default: 
			begin
				lad_out_en <= #1 1'b0;
				lad_out <= #1 4'h0;
			end
			endcase                                    // case(LpcCurrentState)  
		end                                            // else: !if(!ResetN)
	end                                                // always@ (posedge lclk or negedge ResetN)
endmodule // LpcDecode 

