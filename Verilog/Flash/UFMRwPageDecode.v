//******************************************************************************
// File name        : UFMRwPageDecode.v
// Module name      : UFMRwPageDecode
// Description      : This module R/W one page(16 bytes)of MXO2 UFM via a LPC-
//                    to-WISHBONE master
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : UFMRwPage, sync
//******************************************************************************
//  Notes :
//  (1) Only lowest 32bits data of this UFM page are accessed.
//  (2) Use internal 7MHz clock for WISHBONE
//  (3) Lattice MXO2-2000 UFM write timing needs to erase UFM first .
//      Erasing MXO-2000 needs 500~900ms.
//      Programming a page ( 16 byte ) data to UFM needs around 0.2 ms.
//      Reading a page from UFM needs the time less than 1 ms.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// Macro define or include file
//------------------------------------------------------------------------------
`include "../Verilog/Includes/DefineEFBTextMacro.v"

//------------------------------------------------------------------------------
// Module declaration
//------------------------------------------------------------------------------
module UFMRwPageDecode (
    // system clock and reset
    CLK_i,          // In, use for wishbone clock, so it should same as config in EFB of wishbone frequency
    rst_n,          // In,
    bWrPromCfg,     // In,
    bRdPromCfg,     // In,
    ufm_data_in,    // In,

    ufm_data_out    // Out,
    // for simulation
    `ifdef SIM_MODE

    `endif
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
input           CLK_i;
input           rst_n;
input           bWrPromCfg;
input           bRdPromCfg;
input   [31:0]  ufm_data_in;

//--------------------------------------------------------------------------
// Output declaration
//--------------------------------------------------------------------------
output  [31:0]  ufm_data_out;

//------------------------------------------------------------------------------
// Signal declaration
//------------------------------------------------------------------------------
//--------------------------------------------------------------------------
// Wire declaration
//--------------------------------------------------------------------------
//----------------------------------------------------------------------
// Combinational, module connection
//----------------------------------------------------------------------
wire            wr_en_n;
wire            rd_en_n;

wire            wren_rstn;
wire            rden_rstn;

wire            WrStrb_sync;
wire            RdStrb_sync;

wire            Page_Wr_Cycle;
wire            Page_Rd_Cycle;
wire    [7:0]   UFM_Page_RdData;
wire    [7:0]   UFM_Rd_Dt_Addrs;
wire    [7:0]   UFM_Wr_Dt_Addrs;
wire            Page_WrEnd_Strb;
wire            Page_RdEnd_Strb;
wire            Erase_End_Strb;

wire            Inner_Clk;
`ifdef XO2_OSC
wire            osc_clk;
`endif

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
reg     [7:0]   UFM_Page_WrData;

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
reg     [31:0]  ufm_data_out;

//------------------------------------------------------------------
// Internal signal
//------------------------------------------------------------------
reg     [31:0]  ufm_wr_data;

reg             WrStrb;
reg             RdStrb;

reg             wren_clr;
reg             rden_clr;

reg     [7:0]   UFM_Page_Num;
reg             nbusy_sig;
reg             UFM_Er_Cmd;
reg             UFM_Wr_Cmd;
reg             UFM_Rd_Cmd;
reg     [7:0]   UFM_Page_StAdrs;

//------------------------------------------------------------------
// FSM
//------------------------------------------------------------------
reg     [2:0]   C_State;

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
// None

//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
assign wr_en_n = !bWrPromCfg; //Inversion of input, to get a falling edge trigger event
assign rd_en_n = !bRdPromCfg; //Inversion of input, to get a falling edge trigger event

assign wren_rstn = rst_n & !wren_clr;
assign rden_rstn = rst_n & !rden_clr;

always @ (UFM_Wr_Dt_Addrs or ufm_wr_data) begin
    case(UFM_Wr_Dt_Addrs)
        8'h0: UFM_Page_WrData = ufm_wr_data[7:0];
        8'h1: UFM_Page_WrData = ufm_wr_data[15:8];
        8'h2: UFM_Page_WrData = ufm_wr_data[23:16];
        8'h3: UFM_Page_WrData = ufm_wr_data[31:24];
        default: UFM_Page_WrData = 8'h0;
    endcase
end

`ifdef XO2_OSC
assign Inner_Clk = osc_clk;
`else
assign Inner_Clk = CLK_i;
`endif

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
always @ (negedge Inner_Clk) begin
    if (Page_Rd_Cycle)
        case(UFM_Rd_Dt_Addrs)
            8'h0: ufm_data_out <= #TD {ufm_data_out[31:8], UFM_Page_RdData};
            8'h1: ufm_data_out <= #TD {ufm_data_out[31:16], UFM_Page_RdData, ufm_data_out[7:0]};
            8'h2: ufm_data_out <= #TD {ufm_data_out[31:24], UFM_Page_RdData, ufm_data_out[15:0]};
            8'h3: ufm_data_out <= #TD {UFM_Page_RdData, ufm_data_out[23:0]};
            default: ufm_data_out <= #TD ufm_data_out;
        endcase
    else
        ufm_data_out <= #TD ufm_data_out;
end


//----------------------------------------------------------------------
// Internal signal
//----------------------------------------------------------------------
always @ (posedge WrStrb_sync or negedge rst_n) begin
    if (!rst_n)
        ufm_wr_data <= #TD 32'b0;
    else
        ufm_wr_data <= #TD ufm_data_in;
end

always @ (negedge wr_en_n or negedge wren_rstn) begin
    if (!wren_rstn)
        WrStrb <= #TD 1'b0;
    else
        WrStrb <= #TD 1'b1;
end
always @ (negedge rd_en_n or negedge rden_rstn) begin
    if (!rden_rstn)
        RdStrb <= #TD 1'b0;
    else
        RdStrb <= #TD 1'b1;
end

always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        wren_clr <= #TD 1'b0;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    wren_clr <= #TD 1'b0;
                else if (WrStrb_sync)
                         wren_clr <= #TD 1'b1;
                     else
                         wren_clr <= #TD 1'b0;
            end

            `Erase_UFM_Sts: wren_clr <= #TD 1'b1;

            `Write_UFM_Sts: wren_clr <= #TD 1'b0;

            `Read_UFM_Sts: wren_clr <= #TD 1'b0;

            default: wren_clr <= #TD wren_clr;
        endcase
end
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        rden_clr <= #TD 1'b0;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    rden_clr <= #TD 1'b1;
                else
                    rden_clr <= #TD 1'b0;
            end

            `Erase_UFM_Sts: rden_clr <= #TD 1'b0;

            `Write_UFM_Sts: rden_clr <= #TD 1'b0;

            `Read_UFM_Sts: rden_clr <= #TD 1'b1;

            default: rden_clr <= #TD rden_clr;
        endcase
end

always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        UFM_Page_Num <= #TD 8'h00;
    else
        case (C_State)
            `StandBy_Sts: UFM_Page_Num <= #TD 8'h01;

            `Erase_UFM_Sts: begin
                if (Erase_End_Strb)
                    UFM_Page_Num <= #TD `UFM_BarCode_PageNum;
                else
                    UFM_Page_Num <= #TD UFM_Page_Num;
            end

            `Write_UFM_Sts: begin
                if (Page_WrEnd_Strb)
                    if (UFM_Page_Num > 1)
                        UFM_Page_Num <= #TD UFM_Page_Num - 1;
                    else
                        UFM_Page_Num <= #TD UFM_Page_Num;
                else
                    UFM_Page_Num <= #TD UFM_Page_Num;
            end

            default: UFM_Page_Num <= #TD UFM_Page_Num;
        endcase
end
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        nbusy_sig <= #TD 1'b1;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    nbusy_sig <= #TD 1'b0; //busy
                else if (WrStrb_sync)
                         nbusy_sig <= #TD 1'b0; //busy
                     else
                         nbusy_sig <= #TD 1'b1; //ready
            end

            `Erase_UFM_Sts: nbusy_sig <= #TD 1'b0; //busy

            `Write_UFM_Sts: begin
                if (Page_WrEnd_Strb)
                    if (UFM_Page_Num > 1)
                        nbusy_sig <= #TD 1'b0; //busy
                    else
                        nbusy_sig <= #TD 1'b1; //ready
                else
                    nbusy_sig <= #TD 1'b0; //busy
            end

            `Read_UFM_Sts: begin
                if (Page_RdEnd_Strb)
                    nbusy_sig <= #TD 1'b1; //ready
                else
                    nbusy_sig <= #TD 1'b0; //busy
            end

            default: nbusy_sig <= #TD nbusy_sig;
        endcase
end
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        UFM_Er_Cmd <= #TD 1'b0;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    UFM_Er_Cmd <= #TD UFM_Er_Cmd;
                else if (WrStrb_sync)
                         UFM_Er_Cmd <= #TD 1'b1;
                     else
                         UFM_Er_Cmd <= #TD 1'b0;
            end

            `Erase_UFM_Sts: begin
                if (Erase_End_Strb)
                    UFM_Er_Cmd <= #TD 1'b0;
                else
                    UFM_Er_Cmd <= #TD UFM_Er_Cmd;
            end

            default: UFM_Er_Cmd <= #TD UFM_Er_Cmd;
        endcase
end
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        UFM_Wr_Cmd <= #TD 1'b0;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    UFM_Wr_Cmd <= #TD UFM_Wr_Cmd;
                else if (WrStrb_sync)
                         UFM_Wr_Cmd <= #TD UFM_Wr_Cmd;
                     else
                         UFM_Wr_Cmd <= #TD 1'b0;
            end

            `Erase_UFM_Sts: begin
                if (Erase_End_Strb)
                    UFM_Wr_Cmd <= #TD 1'b1;
                else
                    UFM_Wr_Cmd <= #TD UFM_Wr_Cmd;
            end

            `Write_UFM_Sts: begin
                if (Page_WrEnd_Strb)
                    UFM_Wr_Cmd <= #TD 1'b0;
                else
                    UFM_Wr_Cmd <= #TD 1'b1;
            end

            default: UFM_Wr_Cmd <= #TD UFM_Wr_Cmd;
        endcase
end
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        UFM_Rd_Cmd <= #TD 1'b0;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    UFM_Rd_Cmd <= #TD 1'b1;
                else if (WrStrb_sync)
                         UFM_Rd_Cmd <= #TD UFM_Rd_Cmd;
                     else
                         UFM_Rd_Cmd <= #TD 1'b0;
            end

            `Read_UFM_Sts: begin
                if (Page_RdEnd_Strb)
                    UFM_Rd_Cmd <= #TD 1'b0;
                else
                    UFM_Rd_Cmd <= #TD UFM_Rd_Cmd;
            end

            default: UFM_Rd_Cmd <= #TD UFM_Rd_Cmd;
        endcase
end
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        UFM_Page_StAdrs <= #TD 8'h01;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    UFM_Page_StAdrs <= #TD 8'h01;
                else if (WrStrb_sync)
                         UFM_Page_StAdrs <= #TD 8'h01;
                     else
                         UFM_Page_StAdrs <= #TD 8'h01;
            end

            `Erase_UFM_Sts: begin
                if (Erase_End_Strb)
                    UFM_Page_StAdrs <= #TD 8'h01;
                else
                    UFM_Page_StAdrs <= #TD UFM_Page_StAdrs;
            end

            `Write_UFM_Sts: begin
                if (Page_WrEnd_Strb)
                    if (UFM_Page_Num > 1)
                        UFM_Page_StAdrs <= #TD UFM_Page_StAdrs + 1;
                    else
                        UFM_Page_StAdrs <= #TD UFM_Page_StAdrs;
                else
                    UFM_Page_StAdrs <= #TD UFM_Page_StAdrs;
            end

            default: UFM_Page_StAdrs <= #TD UFM_Page_StAdrs;
        endcase
end

//----------------------------------------------------------------------
// FSM
//----------------------------------------------------------------------
always @ (negedge Inner_Clk or negedge rst_n) begin
    if (!rst_n)
        C_State <= #TD `StandBy_Sts;
    else
        case (C_State)
            `StandBy_Sts: begin
                if (RdStrb_sync)
                    C_State <= #TD `Read_UFM_Sts;
                else if (WrStrb_sync)
                         C_State <= #TD `Erase_UFM_Sts;
                     else
                         C_State <= #TD `StandBy_Sts;
            end

            `Erase_UFM_Sts: begin
                if (Erase_End_Strb)
                    C_State <= #TD `Write_UFM_Sts;
                else
                    C_State <= #TD C_State;
            end

            `Write_UFM_Sts: begin
                if (Page_WrEnd_Strb)
                    if (UFM_Page_Num > 1)
                        C_State <= #TD C_State;
                    else
                        C_State <= #TD `StandBy_Sts;
                else
                    C_State <= #TD C_State;
            end

            `Read_UFM_Sts: begin
                if (Page_RdEnd_Strb)
                    C_State <= #TD `StandBy_Sts;
                else
                    C_State <= #TD C_State;
            end

            default: C_State <= #TD `StandBy_Sts;
        endcase
end

//--------------------------------------------------------------------------
// Module instantiation
//--------------------------------------------------------------------------
// XO2 embeded OSC
`ifdef XO2_OSC
defparam OSCH_inst.NOM_FREQ = "7.00";
OSCH
    OSCH_inst(.STDBY(1'b0), // 0=Enabled, 1=Disabled
              // also Disabled with Bandgap=OFF
              .OSC(osc_clk),
              .SEDSTDBY());
`endif

sync
    wr_sync (.data_in(WrStrb),
             .data_out(WrStrb_sync),
             .sync_clk(Inner_Clk),
             .sync_clk_en(1'b1),
             .sync_rst_n(rst_n));
sync
    rd_sync (.data_in(RdStrb),
             .data_out(RdStrb_sync),
             .sync_clk(Inner_Clk),
             .sync_clk_en(1'b1),
             .sync_rst_n(rst_n));

UFMRwPage
    UFMRwPage (.rst_n(rst_n),
               .clk_i(Inner_Clk),
               .Host_WrPage_End(1'b1),
               .UFM_Er_Cmd(UFM_Er_Cmd),
               .UFM_Wr_Cmd(UFM_Wr_Cmd),
               .UFM_Rd_Cmd(UFM_Rd_Cmd),

               .Page_StAdrs(UFM_Page_StAdrs),
               .Page_WrData(UFM_Page_WrData),
               .Page_Num(UFM_Page_Num),
               .Page_RdData(UFM_Page_RdData),
               .Rd_Dt_Addrs(UFM_Rd_Dt_Addrs),
               .Wr_Dt_Addrs(UFM_Wr_Dt_Addrs),

               .Page_Wr_Cycle(Page_Wr_Cycle),
               .Page_Rd_Cycle(Page_Rd_Cycle),
               .Page_WrEnd_Strb(Page_WrEnd_Strb),
               .Page_RdEnd_Strb(Page_RdEnd_Strb),
               .Erase_End_Strb(Erase_End_Strb));

endmodule // UFMRwPageDecode
