//////////////////////////////////////////////////////////////////////////////
// File name        : HwResetGenerate.v
// Module name      : HwResetGenerate
// Description      : This module generates H/W reset from RSM_RST_N rising 
//                    HARD_nRESETi rising edges. 
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
//
// 

`ifndef SIMULATE_DESIGN
`define CLK33M_32K_DIV		16'h01F7
`else
`define CLK33M_32K_DIV		16'h0001
`endif

 
module HwResetGenerate ( 

    // Inputs
    HARD_nRESETi,         // P3V3_AUX power on reset input  
    MCLKi,                // 33MHz input
    RSMRST_N ,        
	PLTRST_N , 
	Reset1G  , 
	ResetOut_ox ,         // From MR_Bsp , reset button pressed and retained 4 second , ResetOut_ox will be asserted.
	FM_PS_EN , 
	// outputs 
    CLK32KHz,             // 32.768KHz output from a divider  
    InitResetn,           // 941us assert duration ( Low active ) from ( HARD_nRESETi & RSMRST_N ) rising edge 
	MainResetN,           // MainResetN = InitResetn & PLTRST_N 
	RST_CPU0_LVC3_N,      // Pin M14 , to Circuit for fault trigger event ( back to CPLD ) 
	RST_PLTRST_BUF_N,     // Pin C15 , to 07 gate buffer , then drive SIO6779 , U5(PCA9548) and U57(EPM1270)
	RST_DLY_CPURST_LVC3,  // Pin G12 , drive ProcHot circuit , During Reset assertion period , only allow CPU 
	                      //           ProcHot to be monitored, After reset de-assertion , CPU ProcHot and IR PWM
                          //           Hot signal are monitored.
    RST_PERST0_N,         // Pin L16 , to 07 gate buffer , then drive J8 and J9 ( both are PCIe x8 slots )
	RST_BCM56842_N_R,     // Pin F16 , to reset BCM56842 
	RST_1G_N_R,
	SYS_RST_IN_SIO_N , 
    RST_PCH_RSTBTN_N 
   
    );


input				HARD_nRESETi;
input				MCLKi;
input               RSMRST_N ;        
input           	PLTRST_N ; 
input               Reset1G  ;
input               ResetOut_ox ;
input               FM_PS_EN ; 

output				CLK32KHz;
output				InitResetn; 
output              MainResetN;
output              RST_CPU0_LVC3_N;
output              RST_PLTRST_BUF_N;
output              RST_DLY_CPURST_LVC3;
output              RST_PERST0_N; 
output              RST_BCM56842_N_R;
output              RST_1G_N_R ; 
output              SYS_RST_IN_SIO_N ; 
output              RST_PCH_RSTBTN_N ;     


reg     [15:0]      divClk32K;
reg     [4:0]       initCnt;
reg					CLK32KHz;
reg                 InitResetn;

wire                TwoHwSignalAND ;
wire                RST_PCH_RSTBTN_N  ;  
 
////////////////////////////////////////////////////////////////////////////////////////////
assign  TwoHwSignalAND      = HARD_nRESETi & RSMRST_N ;  // Monitor these two rising edges 

assign  RST_CPU0_LVC3_N     = PLTRST_N ;  // Pin M14 , to Circuit for fault trigger event ( back to CPLD )
assign  RST_PLTRST_BUF_N    = PLTRST_N ;  // Pin C15 , to 07 gate buffer , then drive SIO6779 , U5(PCA9548) and U57(EPM1270)
assign  RST_DLY_CPURST_LVC3 = PLTRST_N ;  // Pin G12 , drive ProcHot circuit , During Reset assertion period , only allow CPU 
                                          //           ProcHot to be monitored, After reset de-assertion , CPU ProcHot and IR PWM
                                          //           Hot signal are monitored.											   
assign  RST_PERST0_N        = PLTRST_N ;  // Pin L16 , to 07 gate buffer , then drive J8 and J9 ( both are PCIe x8 slots )
assign  RST_BCM56842_N_R    = PLTRST_N ; 


assign  MainResetN          = InitResetn & PLTRST_N ; 

assign  RST_1G_N_R	        = (`PwrSW_On == FM_PS_EN) ? Reset1G : 1'bz;  // Tri-state RST_1G_N_R  during S5 state  	 
assign  RST_PCH_RSTBTN_N    = (`PwrSW_On == FM_PS_EN) ? ResetOut_ox : 1'bz; //- ResetOut  
assign  SYS_RST_IN_SIO_N    = RST_PCH_RSTBTN_N  ;     

///////////////////////////////////////////////////////////////////////////////////////
	initial
	begin
        divClk32K	= `CLK33M_32K_DIV;
        InitResetn	= 1'b1;
        CLK32KHz	= `HIGH;
        initCnt		= 0;
	end
//////////////////////////////////////////////////////////////////////////////////////////////////
//  InitResetn : 941us assert duration ( Low active ) from ( HARD_nRESETi & RSMRST_N ) rising edge
//////////////////////////////////////////////////////////////////////////////////////////////////
	always @(posedge CLK32KHz or negedge TwoHwSignalAND ) 
    begin
		if(1'b0 == TwoHwSignalAND )
        begin
			InitResetn	= 1'b0;
            initCnt		= 5'h00;
        end
        else
        begin
	    	if(5'h1F == initCnt) InitResetn = 1'b1;
	        else
			begin
                InitResetn = 1'b0;
				initCnt    = initCnt + 1;
	        end
        end
    end
/////////////////////////////////////////////////////////////////////////////
//  Frequency Divider : 33MHz --> 32.768KHz 	
////////////////////////////////////////////////////////////////////////////
    always @( posedge MCLKi or negedge TwoHwSignalAND ) 
    begin
		if(1'b0 == TwoHwSignalAND )
        begin
			CLK32KHz	= `HIGH;
            divClk32K	= `CLK33M_32K_DIV;
        end
        else
        begin
            if(0 != divClk32K) divClk32K = divClk32K - 1;
            else
            begin
                if(1'b1 == CLK32KHz)
                begin
                	divClk32K	= `CLK33M_32K_DIV - 1;
					CLK32KHz	= 1'b0;
                end
                else
                begin
                	divClk32K	= `CLK33M_32K_DIV;
					CLK32KHz	= 1'b1;
                end
            end
        end
    end

endmodule // HwResetGenerate
