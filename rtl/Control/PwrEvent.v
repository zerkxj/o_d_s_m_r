//////////////////////////////////////////////////////////////////////////////
// File name        : PwrEvent.v
// Module name      : PwrEvent
// Description      : This module determines Power-Event state transition.                 
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
////////////////////////////////////////////////////////////////////////////// 
//  Notes : 
//  Use Lattice MXO2-2000 UFM to store two non-volatile bits. 
//  Lattice UFM write timing needs to erase UFM first .
//  Erasing MXO-2000 needs 500~900ms.
//  Programming a page ( 16 byte ) data to UFM needs around 0.2 ms.
//  Reading a page from UFM needs the time less than 1 ms.
//  Therefore , the timing for UFM write will be redefined.
//   Add four parameters : T1020 = T1000 + T20 = 0x03E7 + 0x0020
//                         T1030 = T1000 + T30 = 0x03E7 + 0x0030
//                         T1040 = T1000 + T40 = 0x03E7 + 0x0040 
//                         T1050 = T1000 + T50 = 0x03E7 + 0x0050 
//  For bWr_bRd pair, T20-T30_T40-T50 will be replaced by T20-T1020_T1030-T1040 
//  Five Power-Event states are modified :
//  Event_PowerDown , Event_PowerFail , Event_SystemReset , Event_UpdatePwrSt ,
//  Event_SLP_S3n_UpChk
//////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v"
//////////////////////////////////////////////////////////////////////////////
`ifdef SIMULATE_DESIGN
`define EvtTimer_T10        16'h0002
`define EvtTimer_T20        16'h0003
`define EvtTimer_T30        16'h0004
`define EvtTimer_T40        16'h0006
`define EvtTimer_T50        16'h0008
`define EvtTimer_T100       16'h0020
`define EvtTimer_T512       16'h0030
`define EvtTimer_T1000      16'h0040
// Frank 05292015 add ---start_0 ---
`define EvtTimer_T1020      16'h0041
`define EvtTimer_T1030      16'h0042
`define EvtTimer_T1040      16'h0043
`define EvtTimer_T1050      16'h0044
// Frank 05292015 add ---end_0   ---
`define EvtTimer_T2000      16'h0050
`define EvtTimer_T3000      16'h0060
`define EvtTimer_T4000      16'h0070
`define EvtTimer_T5000      16'h0080
`define EvtTimer_T6000      16'h0090    // 6  sec.
`define EvtTimer_T7000      16'h00A0    // 7  sec.
`define EvtTimer_T8000      16'h00B0 
`define EvtTimer_T64000     16'h0100 // 64 sec. Frank 05072015 add this define
`else
`define EvtTimer_T10        16'h0010
`define EvtTimer_T20        16'h0020
`define EvtTimer_T30        16'h0030
`define EvtTimer_T40        16'h0040
`define EvtTimer_T50        16'h0050
`define EvtTimer_T100       16'h0064    // 100ms
`define EvtTimer_T512       16'h0200    // 512ms
`define EvtTimer_T1000      16'h03E7    // 1  sec.
// Frank 05292015 add ---start_1 ---
`define EvtTimer_T1020      16'h0417   // 0x03E7 + 0x0020
`define EvtTimer_T1030      16'h0427   // 0x03E7 + 0x0030
`define EvtTimer_T1040      16'h0437   // 0x03E7 + 0x0040
`define EvtTimer_T1050      16'h0447   // 0x03E7 + 0x0050
// Frank 05292015 add ---end_1   ---
`define EvtTimer_T2000      16'h07CF    // 2  sec.
`define EvtTimer_T3000      16'h0BB7    // 3  sec.
`define EvtTimer_T4000      16'h0F9F    // 4  sec.
`define EvtTimer_T5000      16'h1387    // 5  sec.
`define EvtTimer_T6000      16'h176F    // 6  sec.
`define EvtTimer_T7000      16'h1B57    // 7  sec.
`define EvtTimer_T8000      16'h1FFF    // 8  sec.
`define EvtTimer_T64000     16'hF9FF    // 64 sec.
`endif

`define PwrStateOk          1
`define PwrStateFail        0
`define PowerButtonPress    0
`define PowerButtonRls      1
`define CPUStateWorking     1
`define CPUStateSleep       0


module PwrEvent (     
    ResetN,
    CLK32768, 
    Strobe1ms,
    PowerbuttonIn,
	PwrLastStateRdBit,
	SLP_S3n,
	ATX_PowerOK,
	ALL_PWRGD,
	BiosLed,
	bCPUWrWdtRegSig,
	PowerOff, 
//=====================================	
	PowerEvtState,
	PowerbuttonEvtOut,
	PS_ONn,
	bPwrSystemReset,
	bFlashPromReq,
	bRdPromCfg,
	bWrPromCfg,	
    PwrLastStateWrBit,
    DbgP
    ); 
//====================================
input				ResetN;
input				CLK32768 ;  
input               Strobe1ms;
input               PowerbuttonIn; 
input				PwrLastStateRdBit; 
input               SLP_S3n;
input               ATX_PowerOK; 	
input               ALL_PWRGD;
input   [1:0]       BiosLed;
input   [4:0]       bCPUWrWdtRegSig;
input               PowerOff;
//=====================================
output  [3:0]       PowerEvtState;
output              PowerbuttonEvtOut;
output              PS_ONn;
output              bPwrSystemReset;
output              bFlashPromReq;
output              bRdPromCfg;
output              bWrPromCfg;
output	            PwrLastStateWrBit;
output  [3:0]       DbgP;
//=====================================
reg     [3:0]       pState;
reg     [15:0]      CounterCnt;
reg                 bRdPromCfg;
reg                 bWrPromCfg;
reg		            PwrLastStateWrBit;
reg                 Strobe1ms_d0;
reg                 PS_ONn_x;
reg                 PowerbuttonEvtOut;
reg		            CountState;
reg		            CountState_N;
reg     [1:0]       BootUpRtyCnt;
reg                 bFirstPwrUp;
reg     [1:0]       PrvBiosLed;
reg					bFlashPromReq;
reg					bPwrFailUp;
//======================================
wire                PS_ONn;
wire                bBiosPostRdySig;
wire    [3:0]       PowerEvtState;
wire    [3:0]       DbgP;
wire                bPwrSystemReset;
//======================================
parameter           CounterReset = 1'b0;
parameter           CounterCount = 1'b1;
////////////////////////////////////////////////////////////////////
	initial
	begin
        pState      		= `Event_InitPowerUp;   
        bRdPromCfg  		= 0;
        bWrPromCfg  		= 0;
        PS_ONn_x    		= `PwrSW_Off;
        Strobe1ms_d0		= 0;
        PowerbuttonEvtOut	= `PowerButtonRls;
        PwrLastStateWrBit 	= `PwrStateOk;
        CountState  		= CounterReset;
        CountState_N		= CounterReset;
        BootUpRtyCnt        = 0;
        bFirstPwrUp         = `TRUE;
        PrvBiosLed          = 0;
        bFlashPromReq       = `FALSE;
        bPwrFailUp          = `FALSE;
	end
////////////////////////////////////////////////////////////////////
    assign DbgP[3]  = SLP_S3n;
    assign DbgP[2]  = PwrLastStateWrBit;
    assign DbgP[1]  = CounterCnt[0];
    assign DbgP[0]  = ATX_PowerOK;
////////////////////////////////////////////////////////////////////
    assign PowerEvtState	= pState;
    assign bPwrSystemReset	= (`Event_SystemReset == pState) ? 1'b1 : 1'b0;
    assign PS_ONn 			= PS_ONn_x;
    assign bBiosPostRdySig  = bCPUWrWdtRegSig[2];
////////////////////////////////////////////////////////////////////
	always @(posedge CLK32768 or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
	        pState      		= `Event_InitPowerUp;
	        PS_ONn_x    		= `PwrSW_Off;
	        bRdPromCfg  		= 0;
	        bWrPromCfg  		= 0;
	        PowerbuttonEvtOut	= `PowerButtonRls;
        	PwrLastStateWrBit	= `PwrStateOk;
            CountState_N		= CounterReset;
	        BootUpRtyCnt        = 0;
	        bFirstPwrUp         = `TRUE;
	        PrvBiosLed          = 0;
	        bFlashPromReq       = `FALSE;
        bPwrFailUp          	= `FALSE;
		end
		else
		begin
            if(1'b1 == Strobe1ms)                            // polling PwrEventState every 1ms after ResetN de-assertion 
            begin
        		case(pState)                                 // There are 13 PwrEventStates for polling cases 
// **************************************************************************				
            	`Event_InitPowerUp:                          // PwrEventState = 0x0   
            	begin
		    		PS_ONn_x			= `PwrSW_Off;
					BootUpRtyCnt		= 0;
			        bPwrFailUp          = `FALSE;
                	PrvBiosLed   		= BiosLed;
                	PowerbuttonEvtOut	= `PowerButtonRls;
                	if(`EvtTimer_T100 > CounterCnt)
                	begin
						if(`EvtTimer_T20 == CounterCnt)      bRdPromCfg = 1;
                    	else if(`EvtTimer_T30 == CounterCnt) bRdPromCfg = 0;
		            	CountState_N	= CounterCount;
                	end
                	else
					begin
                        PwrLastStateWrBit = PwrLastStateRdBit;
                		if(`PwrStateOk == PwrLastStateRdBit)
						begin
							bFirstPwrUp = `FALSE;
                    		pState 		= `Event_PowerStandBy;
                        end
                        else
                        begin
							bFirstPwrUp = `TRUE;
                    		pState 		= `Event_SLP_S3n;
                        end
			        	CountState_N	= CounterReset;
                	end
            	end
// **************************************************************************
            	`Event_SLP_S3n:                              // PwrEventState = 0xA
            	begin
					PS_ONn_x	= `PwrSW_Off;
			        bPwrFailUp  = `FALSE;
                	if(`CPUStateWorking == SLP_S3n)
                	begin
						CountState_N		= CounterReset;
                    	PrvBiosLed   		= BiosLed;
                    	if(`FALSE == bFirstPwrUp) pState = `Event_PowerStandBy;
                    	else
                    	begin
							bFirstPwrUp = `FALSE;
                        	pState 		= `Event_Reboot;
                    	end
                	end
					else
                	begin
                		if(`EvtTimer_T1000 > CounterCnt )
                		begin
                    		PowerbuttonEvtOut	= `PowerButtonPress;
							CountState_N		= CounterCount;
                    	end
                    	else if(`EvtTimer_T1000 <= CounterCnt && `EvtTimer_T2000 > CounterCnt)
                		begin
                    		PowerbuttonEvtOut	= `PowerButtonRls;
							CountState_N		= CounterCount;
                    	end
                    	else // if(`EvtTimer_T2000 <= CounterCnt)
						begin
                    		PowerbuttonEvtOut	= `PowerButtonRls;
				        	CountState_N		= CounterReset;
                		end
                	end
            	end
// **************************************************************************
				`Event_PowerStandBy:                         // PwrEventState = 0x1
            	begin
					PS_ONn_x			= `PwrSW_Off;
                	PowerbuttonEvtOut	= `PowerButtonRls;
                	PrvBiosLed			= BiosLed;
			        bPwrFailUp          = `FALSE;
                	if(`PowerButtonRls == PowerbuttonIn)
                	begin
			    		CountState_N		= CounterReset;
                    	if(2'b00 != BootUpRtyCnt) pState = `Event_Reboot;
                	end
                	else
                	begin
                		// press the power button
                		if(`EvtTimer_T20 > CounterCnt) CountState_N= CounterCount;
                    	else
                    	begin
			        		CountState_N= CounterReset;
							pState = `Event_SLP_S3n_UpChk;
                    	end
				    	BootUpRtyCnt      = 0;
                	end
            	end
// **************************************************************************
				`Event_SLP_S3n_UpChk:                        // PwrEventState = 0xB
            	begin
                	// the power button has been press, check the SLP_S3#
					// Frank 05292015 modify 
                    //- if(`EvtTimer_T100 > CounterCnt)
					if(`EvtTimer_T1050 > CounterCnt)
                	begin
                		PwrLastStateWrBit	= `PwrStateFail;
				        bFlashPromReq		= `TRUE;
					// Frank 05292015 modify 
					//-if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    //-else  if(`EvtTimer_T30 == CounterCnt) bWrPromCfg = 0;
                    //-else  if(`EvtTimer_T40 == CounterCnt) bRdPromCfg = 1;
                    //-else  if(`EvtTimer_T50 == CounterCnt) bRdPromCfg = 0;
						      if(`EvtTimer_T20 == CounterCnt)   bWrPromCfg = 1;
                    	else  if(`EvtTimer_T1020 == CounterCnt) bWrPromCfg = 0;
                    	else  if(`EvtTimer_T1030 == CounterCnt) bRdPromCfg = 1;
                    	else  if(`EvtTimer_T1040 == CounterCnt) bRdPromCfg = 0;
						CountState_N= CounterCount;
                    end
					// Frank 05292015 modify 
                	//- else if(`EvtTimer_T1000 < CounterCnt)
					else if(`EvtTimer_T2000 < CounterCnt)
					begin
			        	CountState_N	= CounterReset;
						pState			= `Event_PowerStandBy;
                    end
                    else // if(`EvtTimer_T100 <= CounterCnt && `EvtTimer_T1000 >= CounterCnt)
			// Frank 05292015 if(`EvtTimer_T1050 <= CounterCnt && `EvtTimer_T2000 >= CounterCnt)
                    begin
				        bFlashPromReq		= `FALSE;
                        PwrLastStateWrBit	= PwrLastStateRdBit;
						if(`CPUStateWorking != SLP_S3n) CountState_N= CounterCount;
                        else
						begin
				        	CountState_N= CounterReset;
							pState 		= `Event_Reboot;
                        end
                	end
            	end
// **************************************************************************
				`Event_Reboot:                               // PwrEventState = 0x2     
            	begin
					PS_ONn_x			= `PwrSW_On;
                	PowerbuttonEvtOut	= `PowerButtonRls;
                	if(`EvtTimer_T5000 > CounterCnt)
                	begin
                    	if(PrvBiosLed == BiosLed) CountState_N= CounterCount;
                    	else
                    	begin
			        		PrvBiosLed		= BiosLed;
							BootUpRtyCnt	= BootUpRtyCnt + 1;
							CountState_N	= CounterReset;
                        	pState 			= `Event_Wait2s;
                    	end
                	end
                	else // if(`EvtTimer_T5000 <= CounterCnt)
					begin
                    	if(`FALSE == ATX_PowerOK)
                    	begin
					        bPwrFailUp      = `TRUE;
							BootUpRtyCnt	= 1;
							pState 			= `Event_Wait2s;
                    	end
                    	else if(`HIGH == ALL_PWRGD) pState = `Event_BiosPost_Wait;
                    	else
						begin
							if(`FALSE == bFirstPwrUp) BootUpRtyCnt = BootUpRtyCnt + 1;
                        	else
                        	begin
								bFirstPwrUp = `FALSE;
								BootUpRtyCnt= 1;
                        	end
							pState = `Event_Wait2s;
                        end
				    	CountState_N = CounterReset;
                	end
				end
// **************************************************************************
				`Event_BiosPost_Wait:                        // PwrEventState = 0xC
            	begin
					PS_ONn_x			= `PwrSW_On;
                	PowerbuttonEvtOut	= `PowerButtonRls;
                    if(`TRUE == bBiosPostRdySig)
                    begin
                    	pState 			= `Event_UpdatePwrSt;
				    	CountState_N	= CounterReset;
                    end
                    else
                    begin
                		if(`EvtTimer_T64000 > CounterCnt)
                		begin
                    		if(PrvBiosLed == BiosLed) CountState_N= CounterCount;
                    		else
                    		begin
			        			PrvBiosLed		= BiosLed;
								BootUpRtyCnt	= BootUpRtyCnt + 1;
								CountState_N	= CounterReset;
                        		pState 			= `Event_Wait2s;
                    		end
                		end
                		else // if(`EvtTimer_T64000 <= CounterCnt)
						begin
							BootUpRtyCnt	= BootUpRtyCnt + 1;
				    		CountState_N	= CounterReset;
                        	pState 			= `Event_Wait2s;
                		end
                    end
				end
// **************************************************************************
				`Event_UpdatePwrSt:                          // PwrEventState = 0x3
            	begin
					PS_ONn_x			= `PwrSW_On;
                	PowerbuttonEvtOut	= `PowerButtonRls;
					// Frank 05292015 modify 
                	//- if(`EvtTimer_T512 > CounterCnt )
					if(`EvtTimer_T1050 > CounterCnt )
                	begin
                		PwrLastStateWrBit	= `PwrStateFail;
				        bFlashPromReq		= `TRUE;
						// Frank 05292015 modify 
						//- if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	//- else  if(`EvtTimer_T30 == CounterCnt) bWrPromCfg = 0;
                    	//- else  if(`EvtTimer_T40 == CounterCnt) bRdPromCfg = 1;
                    	//- else  if(`EvtTimer_T50 == CounterCnt) bRdPromCfg = 0; 
						if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	else  if(`EvtTimer_T1020 == CounterCnt) bWrPromCfg = 0;
                    	else  if(`EvtTimer_T1030 == CounterCnt) bRdPromCfg = 1;
                    	else  if(`EvtTimer_T1040 == CounterCnt) bRdPromCfg = 0; 
						CountState_N= CounterCount;
                	end
                	else // if(`EvtTimer_T512 <= CounterCnt)
					     // Frank 05292015 if(`EvtTimer_T1050 <= CounterCnt)
					begin
				        bFlashPromReq		= `FALSE;
                        PwrLastStateWrBit	= PwrLastStateRdBit;
	                    if(`FALSE == ATX_PowerOK)
	                    begin
					        bPwrFailUp      = `TRUE;
							BootUpRtyCnt	= 1;
							pState 			= `Event_Wait2s;
	                    end
	                    else
                        begin
							if(`HIGH == ALL_PWRGD) pState = `Event_SystemRun;
                    		else                   pState = `Event_Wait2s;
                        end
						CountState_N		= CounterReset;
                    end
            	end
// **************************************************************************
				`Event_SystemRun:                            // PwrEventState = 0x4
            	begin
					PS_ONn_x			= `PwrSW_On;
					BootUpRtyCnt		= 0;
                	PowerbuttonEvtOut	= `PowerButtonRls;
			    	CountState_N		= CounterReset;
                	if(PowerOff) pState = `Event_PowerDown;
                	else
                	begin
                		case ({SLP_S3n, ATX_PowerOK})
                		2'b00: pState		= `Event_PowerFail;
                		2'b01: pState		= `Event_SystemReset;
                		2'b10: pState		= `Event_PowerFail;
                		2'b11: pState       = `Event_SystemRun;
                		endcase
                	end
            	end
// **************************************************************************
				`Event_SystemReset:                          // PwrEventState = 0x5
            	begin
            		PowerbuttonEvtOut	= `PowerButtonRls;
					// Frank 05292015 modify 
                	//- if(`EvtTimer_T1000 > CounterCnt )
					if(`EvtTimer_T2000 > CounterCnt )
                	begin
						PS_ONn_x			= `PwrSW_On;
						PwrLastStateWrBit	= `PwrStateOk;
						CountState_N		= CounterCount;
				        bFlashPromReq		= `TRUE; 
						// Frank 05292015 modify 
						//- if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	//- else  if(`EvtTimer_T30 == CounterCnt) bWrPromCfg = 0;
                    	//- else  if(`EvtTimer_T40 == CounterCnt) bRdPromCfg = 1;
                    	//- else  if(`EvtTimer_T50 == CounterCnt) bRdPromCfg = 0;
						if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	else  if(`EvtTimer_T1020 == CounterCnt) bWrPromCfg = 0;
                    	else  if(`EvtTimer_T1030 == CounterCnt) bRdPromCfg = 1;
                    	else  if(`EvtTimer_T1040 == CounterCnt) bRdPromCfg = 0;
                	end
					// Frank 05292015 modify 
                	//- else if(`EvtTimer_T1000 <= CounterCnt && `EvtTimer_T7000 > CounterCnt)
					else if(`EvtTimer_T2000 <= CounterCnt && `EvtTimer_T7000 > CounterCnt)
                	begin
				        bFlashPromReq	= `FALSE;
                		PS_ONn_x		= `PwrSW_Off;
                        PwrLastStateWrBit = PwrLastStateRdBit;
						if(`CPUStateSleep == SLP_S3n) CountState_N	= CounterCount;
                    	else
                		begin
			        		CountState_N= CounterReset;
	                		pState  	= `Event_PowerCycle;
                    	end
                	end
                	else
					begin
						CountState_N	= CounterReset;
	                	pState			= `Event_Wait2s;
                	end
            	end
// **************************************************************************
				`Event_PowerCycle:                           // PwrEventState = 0x6
            	begin
		        	PS_ONn_x			= `PwrSW_On;
            		PowerbuttonEvtOut	= `PowerButtonRls;
            		if(`EvtTimer_T3000  > CounterCnt)
                	begin
						if(`CPUStateWorking == SLP_S3n) CountState_N= CounterCount;
                    	else
                		begin
							BootUpRtyCnt= 1;
			            	CountState_N= CounterReset;
	                		pState  	= `Event_Wait2s;
                		end
                	end
                	else
					begin
				    	CountState_N= CounterReset;
	                	pState		= `Event_SystemRun;
                	end
            	end
// **************************************************************************
				`Event_PowerFail:                            // PwrEventState = 0x7
            	begin
            		PowerbuttonEvtOut	= `PowerButtonRls;
					// Frank 05292015 modify 
                	//- if(`EvtTimer_T1000 > CounterCnt )
					if(`EvtTimer_T1050 > CounterCnt )
                	begin
                        // / *
                		PwrLastStateWrBit	= `PwrStateFail;
				        bFlashPromReq		= `TRUE;
						// Frank 05292015 modify 
						//- if(`EvtTimer_T20 >= CounterCnt) 	  bWrPromCfg = 1;
                    	//- else  if(`EvtTimer_T30 == CounterCnt) bWrPromCfg = 0;
                    	//- else  if(`EvtTimer_T40 == CounterCnt) bRdPromCfg = 1;
                    	//- else  if(`EvtTimer_T50 == CounterCnt) bRdPromCfg = 0;
						if(`EvtTimer_T20 >= CounterCnt) 	  bWrPromCfg = 1;
                    	else  if(`EvtTimer_T1020 == CounterCnt) bWrPromCfg = 0;
                    	else  if(`EvtTimer_T1030 == CounterCnt) bRdPromCfg = 1;
                    	else  if(`EvtTimer_T1040 == CounterCnt) bRdPromCfg = 0;
                        // * /
						CountState_N	= CounterCount;
				    	PS_ONn_x		= `PwrSW_On;
                	end 
					// Frank 05292015 modify 
					//- else if(`EvtTimer_T1000 <= CounterCnt && `EvtTimer_T5000 > CounterCnt)
                    else if(`EvtTimer_T1050 <= CounterCnt && `EvtTimer_T5000 > CounterCnt)
                    begin
				        bFlashPromReq	= `FALSE;
                        PwrLastStateWrBit= PwrLastStateRdBit;
                        if(`TRUE == ATX_PowerOK)
                        begin
                            // AC restored, reboot the system
							CountState_N	= CounterReset;
					        bPwrFailUp      = `TRUE;
							BootUpRtyCnt	= 1;
							pState			= `Event_Wait2s;
                        end
                    end
                	else // if(`EvtTimer_T5000 <= CounterCnt)
                	begin
				        bFlashPromReq	= `FALSE;
                        PwrLastStateWrBit= PwrLastStateRdBit;
						CountState_N	= CounterReset;
						pState			= `Event_Wait2s;	//`Event_SLP_S3n;
                	end
            	end                                              
// **************************************************************************
				`Event_PowerDown:                            // PwrEventState = 0x9     
            	begin
				    // Frank 05292015 modify 
					//- if(`EvtTimer_T1000 > CounterCnt)
					if(`EvtTimer_T1050 > CounterCnt)
					begin
	            		PowerbuttonEvtOut	= `PowerButtonPress;  // push the power button to power off
		        		PS_ONn_x			= `PwrSW_On;
						PwrLastStateWrBit	= `PwrStateOk;
						CountState_N		= CounterCount;
				        bFlashPromReq		= `TRUE;
						// Frank 05292015 modify 
						//- if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	//- else  if(`EvtTimer_T30 == CounterCnt) bWrPromCfg = 0;
                    	//- else  if(`EvtTimer_T40 == CounterCnt) bRdPromCfg = 1;
                    	//- else  if(`EvtTimer_T50 == CounterCnt) bRdPromCfg = 0;
						if(`EvtTimer_T20 == CounterCnt) 	  bWrPromCfg = 1;
                    	else  if(`EvtTimer_T1020 == CounterCnt) bWrPromCfg = 0;
                    	else  if(`EvtTimer_T1030 == CounterCnt) bRdPromCfg = 1;
                    	else  if(`EvtTimer_T1040 == CounterCnt) bRdPromCfg = 0;
                	end
					// Frank 05292015 modify 
                	//- else if(`EvtTimer_T1000 <= CounterCnt && `EvtTimer_T5000 > CounterCnt)
					else if(`EvtTimer_T1050 <= CounterCnt && `EvtTimer_T5000 > CounterCnt)
                	begin
				        bFlashPromReq		= `FALSE;
                        PwrLastStateWrBit	= PwrLastStateRdBit;
	            		PowerbuttonEvtOut	= `PowerButtonPress;  // push the power button to power off
		        		PS_ONn_x			= `PwrSW_On;
                	end
                	else if(`EvtTimer_T5000 <= CounterCnt && `EvtTimer_T6000 > CounterCnt)
                	begin
	            		PowerbuttonEvtOut	= `PowerButtonRls;  // push the power button to power off
		        		PS_ONn_x			= `PwrSW_On;
                	end
                	else if(`EvtTimer_T6000 <= CounterCnt && `EvtTimer_T8000 > CounterCnt)
                	begin
	            		PowerbuttonEvtOut	= `PowerButtonRls;  // push the power button to power off
		        		PS_ONn_x			= `PwrSW_Off;
                	end
                	else // if(`EvtTimer_T8000 <= CounterCnt)
					begin
	            		PowerbuttonEvtOut	= `PowerButtonRls;  // push the power button to power off
		        		PS_ONn_x			= `PwrSW_Off;
				    	CountState_N		= CounterReset;
	                	pState				= `Event_Wait2s;
                	end
            	end                                             // end of Event_PowerDown
// **************************************************************************
				// wait for power button release
				`Event_Wait2s:                                // PwrEventState = 0x8
            	begin
		    		PS_ONn_x		  = `PwrSW_Off;
                	PowerbuttonEvtOut = `PowerButtonRls;
                	if(`EvtTimer_T6000 > CounterCnt) CountState_N = CounterCount;
                	else
                	begin
                		// over 2 sec.
			        	CountState_N= CounterReset;
                        if(`FALSE == bPwrFailUp)
                			pState		= `Event_PowerStandBy;	//`Event_SLP_S3n;
                        else
                        begin
                            bPwrFailUp  = `FALSE;
                			pState		= `Event_SLP_S3n;       // make sure the SLP_S3n is high
                        end
                	end
            	end                                             // end of Event_Wait2s              
// **************************************************************************
				default:
            	begin
	        		PS_ONn_x    		= `PwrSW_Off;
                	PowerbuttonEvtOut	= `PowerButtonRls;
			    	CountState_N		= CounterReset;
					pState      		= `Event_PowerStandBy;	//`Event_SLP_S3n;
            	end
// **************************************************************************
				endcase  // pState
            end          // if(1'b1 == Strobe1ms) 
        end	             // if(1'b0 == ResetN) else , i.e. after ResetN de-assertion 
    end                  // always @(posedge CLK32768 or negedge ResetN)
////////////////////////////////////////////////////////////////////
	always @(posedge CLK32768 or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
            CounterCnt  = 0;
            CountState  = CounterReset;
		end
		else
		begin
            if(1'b0 == Strobe1ms_d0)
            begin
                if(CountState_N != CountState)
                begin
                    if(CounterReset == CountState_N) CounterCnt = 0;
                    CountState = CountState_N;
                end
            end
            else
            begin
                if(CountState_N != CountState)
                begin
                    case (CountState_N)
                    CounterReset:   CounterCnt = 0;
                    CounterCount:   CounterCnt = CounterCnt + 1;
                    endcase
                    CountState = CountState_N;
                end
                else
                begin
                    case (CountState)
                    CounterReset:   CounterCnt = 0;
                    CounterCount:   CounterCnt = CounterCnt + 1;
                    endcase
                end
            end
        end
    end
////////////////////////////////////////////////////////////////////
	always @(posedge CLK32768 or negedge ResetN)
	begin
		if(1'b0 == ResetN)
		begin
            Strobe1ms_d0  = 1'b0;
		end
		else
		begin
            Strobe1ms_d0 = Strobe1ms;
        end
    end
////////////////////////////////////////////////////////////////////
endmodule // PwrEvent
