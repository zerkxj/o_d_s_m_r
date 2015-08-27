//                              -*- Mode: Verilog -*-
// Filename        : osd_7seg.v
// Description     : The OSD 7 segment module
// Author          : Traveler Lu
// Created On      : Thu Oct 28 17:12:52 2013
// Last Modified By: .
// Last Modified On: .
//-----------------------------------------------------------------------------
// Copyright (c) by PortWell (Taiwan) Ltd. This model is the confidential and
// proprietary property of PortWell Ltd. And the possession or use of this
// file requires a written license from PortWell (Taiwan) Ltd.
//-----------------------------------------------------------------------------
// Update Count    : 0
// Status          : Unknown, Use with caution!
//
// Updata History  :
// Version     Date        Author      Description
//   0.1   2013-10-28    Traveler Lu   Initial design
//   0.2   2015-06-30    Frank Hsu     Rename file and module to Led7SegDecode.v and Led7SegDecode
//                                     This decoder decodes address ( 6 7SegLed with three pairs ) 
//                                     and displays data.  

`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"
/*
`define Led7seg_En0			6'h3E
`define Led7seg_En1			6'h3D
`define Led7seg_En2			6'h3B
`define Led7seg_En3			6'h37
`define Led7seg_En4			6'h2F
`define Led7seg_En5			6'h1F
`define Led7seg_DisAll		6'h3F
*/
`define Led7seg_En0			6'h01
`define Led7seg_En1			6'h02
`define Led7seg_En2			6'h04
`define Led7seg_En3			6'h08
`define Led7seg_En4			6'h10
`define Led7seg_En5			6'h20
`define Led7seg_DisAll		6'h00

`ifndef SIMULATE_DESIGN
`define LedDelayCnt         15'h4073
`else
`define LedDelayCnt         15'h000F
`endif

// Frank 06302015 modify 
//- module osd_7seg (
module Led7SegDecode (
    // Inputs
    ResetN,
    Mclk,
    ALL_PWRGD,
    SystemOK,
    BiosFinished,
    BiosPostData,
    Strobe1ms,
	Strobe1s,				// Single SlowClock Pulse @ 1 s
	Strobe125ms,			// Single SlowClock Pulse @ 125 ms
    BiosStatus,
    x7SegSel,
    x7SegVal,
    
    PowerEvtState,
    Led7En,
    Led7Leg,
   
	
	FM_PLD_DEBUG2,   // FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode ; from PwrSequence module 
	FM_PLD_DEBUG3,      
	FM_PLD_DEBUG4,      
	FM_PLD_DEBUG5,
    PORT80_DP	
    );


input				ResetN;
input				Mclk;
input               ALL_PWRGD;
input               SystemOK;
input               BiosFinished;
input   [7:0]       BiosPostData;
input               Strobe1ms;
input               Strobe1s;
input               Strobe125ms;
input   [3:0]       BiosStatus;
input   [4:0]       x7SegSel;
input   [7:0]       x7SegVal;

input   [3:0]       PowerEvtState;
output  [5:0]       Led7En;
output  [6:0]       Led7Leg;


input FM_PLD_DEBUG2;  // FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode ; from PwrSequence module     
input FM_PLD_DEBUG3;    
input FM_PLD_DEBUG4;   
input FM_PLD_DEBUG5;  
output PORT80_DP ;   
reg    PORT80_DP ;
	  

reg		[6:0]       Led7Leg;
reg		[5:0]       Led7En;
reg		[5:0]       Led7En_0;
reg     [4:0]       OutVal;
reg     [2:0]       ByteLocx;
wire                SoftCtrlEn;
reg     [4:0]       Digit0;
reg     [4:0]       Digit1;
reg     [4:0]       Digit2;
reg     [4:0]       Digit3;
reg     [4:0]       Digit4;
reg     [4:0]       Digit5;
reg                 xStrobe1ms;
reg                 bStrobe1ms;
wire	[4:0]		CurrentBios = {4'h0, BiosStatus[2]};
wire	[4:0]		NextBios    = {4'h0, BiosStatus[1]};
wire	[4:0]		ActiveBios  = {4'h0, BiosStatus[0]};
reg		[4:0]		Digit2x, Digit3x;
reg		[1:0]		Modulate, Select;
reg					Flag;

	

	initial
	begin
        Led7En		= 6'h3F;
        Led7En_0	= 6'h3F;
        Led7Leg		= 7'h7F;
        ByteLocx    = 3'h0;
        OutVal      = 5'h0F;
        Digit0      = 0;
        Digit1      = 0;
        Digit2      = 0;
        Digit3      = 0;
        Digit4      = 0;
        Digit5      = 0;
        xStrobe1ms  = 0;
        bStrobe1ms  = 0;
		PORT80_DP   = 0; // Frank 06082015 add
	end


	///////////////////////////////////////////////////////////////////
	always	@(posedge Mclk)
	begin
    	if(Strobe125ms)	Modulate	<= Modulate + 1'b1;
    	if(Strobe1s)	Select		<= (Select == 2'h2) ? 2'h0 : Select + 1'b1;
    	Flag						<= BiosFinished | !BiosFinished & (Modulate != 2'h2);
    	if(BiosFinished)
    		case(Select)
        	2'h0	:	Digit3x		<= 5'h0C;   // 'C'
        	2'h1	:	Digit3x		<= 5'h13;   // 'n'
        	2'h2	:	Digit3x		<= 5'h0A;   // 'A'
        	default	:	Digit3x		<= 5'h10;   // ' '
      		endcase
    	else			Digit3x		<= 5'h0B;   // 'b'
    	if(BiosFinished)
    		case(Select)
        	2'h0	:	Digit2x		<= CurrentBios;
        	2'h1	:	Digit2x		<= NextBios;
        	2'h2	:	Digit2x		<= ActiveBios;
        	default	:	Digit2x		<= 5'h10;
      	endcase
		else			Digit2x		<= CurrentBios;
	end
	///////////////////////////////////////////////////////////////////

	always @(posedge Mclk or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
        	Led7Leg		= 7'h7F;
	        Led7En		= `Led7seg_DisAll;
		end
        else
        begin
            //   g f e  d c b a
            //0: 0 1 1  1 1 1 1
            //1: 0 0 0  0 1 1 0
            //2: 1 0 1  1 0 1 1
            //3: 1 0 0  1 1 1 1
            //4: 1 1 0  0 1 1 0
            //5: 1 1 0  1 1 0 1
            //6: 1 1 1  1 1 0 1
            //7: 0 1 0  0 1 1 1
            //8: 1 1 1  1 1 1 1
            //9: 1 1 0  0 1 1 1
            //A: 1 1 1  0 1 1 1
            //B: 1 1 1  1 1 0 0
            //C: 0 1 1  1 0 0 1
            //D: 1 0 1  1 1 1 0
            //E: 1 1 1  1 0 0 1
            //F: 1 1 1  0 0 0 1
            if(2'b10 == {xStrobe1ms, bStrobe1ms})
            begin
            	case (OutVal)
            	5'h00: Led7Leg   = 7'h3F;
            	5'h01: Led7Leg   = 7'h06;
            	5'h02: Led7Leg   = 7'h5B;
            	5'h03: Led7Leg   = 7'h4F;
            	5'h04: Led7Leg   = 7'h66;
            	5'h05: Led7Leg   = 7'h6D;
            	5'h06: Led7Leg   = 7'h7D;
            	5'h07: Led7Leg   = 7'h27;
            	5'h08: Led7Leg   = 7'h7F;
            	5'h09: Led7Leg   = 7'h67;
            	5'h0A: Led7Leg   = 7'h77;
            	5'h0B: Led7Leg   = 7'h7C;
            	5'h0C: Led7Leg   = 7'h39;
            	5'h0D: Led7Leg   = 7'h5E;
            	5'h0E: Led7Leg   = 7'h79;
            	5'h0F: Led7Leg   = 7'h71;
            	5'h10: Led7Leg   = 7'h00;   // ' '
            	5'h11: Led7Leg   = 7'h40;   // '-'
            	5'h12: Led7Leg   = 7'h48;   // '='
            	5'h13: Led7Leg   = 7'h54;   // 'n'
            	endcase
	        	Led7En		= Led7En_0;
            end
        end
	end

	always @(posedge Mclk or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
	        Led7En_0	= `Led7seg_DisAll;
	        ByteLocx    = 3'h0;
            OutVal      = 5'h00;
		end
		else
		begin
            if(2'b10 == {xStrobe1ms, bStrobe1ms})
            begin
            	case(ByteLocx)
                3'h0:
                begin
                	Led7En_0    = `Led7seg_En0;
		        	OutVal      = Digit0;
                end

                3'h1:
                begin
                	Led7En_0    = `Led7seg_En1;
		        	OutVal      = Digit1;
                end

                3'h2:
                begin
                	Led7En_0    = `Led7seg_En2;
		        	OutVal      = Digit2;
                end

                3'h3:
                begin
                	Led7En_0    = `Led7seg_En3;
		        	OutVal      = Digit3;
                end

                3'h4:
                begin
                	Led7En_0    = `Led7seg_En4;
		        	OutVal      = Digit4;
                end

                3'h5:
                begin
                	Led7En_0    = `Led7seg_En5;
		        	OutVal      = Digit5;
                end

                default:
                begin
                	Led7En_0    = `Led7seg_DisAll;
		        	OutVal      = 5'h10;
                end
                endcase

                if(3'h5 != ByteLocx)	ByteLocx = ByteLocx + 1;
                else    			ByteLocx = 0;
            end
        end
    end

    assign SoftCtrlEn = x7SegSel[4];

	always @(posedge Mclk or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
	        Digit0      = 0;
	        Digit1      = 0;
	        Digit2      = 0;
	        Digit3      = 0;
	        Digit4      = 0;
	        Digit5      = 0;
			PORT80_DP   = 0; // Frank 06082015 add
		end
        else
        begin
        	if(2'b10 == {xStrobe1ms, bStrobe1ms})
            begin
                if(SystemOK)
                begin
            		if(`TRUE == SoftCtrlEn)
            		begin
                		if(`TRUE == x7SegSel[0])
                		begin
                    		Digit0  = {1'b0, x7SegVal[3:0]};
                    		Digit1  = {1'b0, x7SegVal[7:4]};
                		end
                		if(`TRUE == x7SegSel[1])
                		begin
                    		Digit2  = {1'b0, x7SegVal[3:0]};
                    		Digit3  = {1'b0, x7SegVal[7:4]};
                		end
                		if(`TRUE == x7SegSel[2])
                		begin
                    		Digit4  = {1'b0, x7SegVal[3:0]};
                    		Digit5  = {1'b0, x7SegVal[7:4]};
                		end
                    end
                    /*
                    else
                    begin
            			Digit0  = {1'b0, PowerEvtState};
                		Digit1  = 5'h10;
            			Digit2  = Flag ? Digit2x : 5'h10;
                		Digit3  = Flag ? Digit3x : 5'h10;
            			Digit4  = {1'b0, BiosPostData[3:0]};
                		Digit5  = {1'b0, BiosPostData[7:4]};
                    end
                    */
            	end		// 2'b11 = {ALL_PWRGD, SystemOK}
                else
                begin
                    if(ALL_PWRGD)
            		begin
						`ifndef DEBUG_PwrState   
            			Digit0  = {1'b0, `VERSION_CODE};
                		Digit1  = {1'b0, `FPGAID_CODE};
                        `else
            			Digit0  = {1'b0, PowerEvtState};  					    
						Digit1  = {1'b0, FM_PLD_DEBUG5,FM_PLD_DEBUG4,FM_PLD_DEBUG3,FM_PLD_DEBUG2};	
                	    //-	Digit1  = 5'h10;
            			//Digit1  = {1'b0, BiosStatus};
                        `endif
            			Digit2  = Flag ? Digit2x : 5'h10;
                		Digit3  = Flag ? Digit3x : 5'h10;
            			Digit4  = {1'b0, BiosPostData[3:0]};
                		Digit5  = {1'b0, BiosPostData[7:4]};
						PORT80_DP = 1'b0 ; // Frank 06082015 add 
            		end     // ALL_PWRGD and not SystemOK (post system)
                    else
            		begin
						`ifndef DEBUG_PwrState
            			Digit0  = {1'b0, `VERSION_CODE};
                		Digit1  = {1'b0, `FPGAID_CODE};
                        `else
            			Digit0  = {1'b0, PowerEvtState};
						Digit1  = {1'b0, FM_PLD_DEBUG5,FM_PLD_DEBUG4,FM_PLD_DEBUG3,FM_PLD_DEBUG2};	
                		//- Digit1  = 5'h10;
            			//Digit1  = {1'b0, BiosStatus};
                        `endif
            			Digit2  = Flag ? Digit2x : 5'h10;
                		Digit3  = Flag ? Digit3x : 5'h10;
            			Digit4  = {1'b0, PowerEvtState};
						// Frank 06082015 modify 
                		//- Digit5  = 5'h10;
						Digit5  = {1'b0, FM_PLD_DEBUG5,FM_PLD_DEBUG4,FM_PLD_DEBUG3,FM_PLD_DEBUG2};
						PORT80_DP = 1'b1 ; // Frank 06082015 add 
						
						
            		end     // Standby mode
                end
            end
        end
	end

	always @(posedge Mclk or negedge ResetN)
	begin
		if(1'b0 == ResetN)
            bStrobe1ms	= `LOW;
		else
        	bStrobe1ms	= xStrobe1ms;
    end

	always @(posedge Mclk or negedge ResetN)
	begin
		if(1'b0 == ResetN)
            xStrobe1ms	= `LOW;
		else
            xStrobe1ms	= Strobe1ms;
    end

endmodule // Led7segDecode
