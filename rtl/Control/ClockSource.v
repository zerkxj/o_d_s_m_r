//////////////////////////////////////////////////////////////////////////////
// File name        : ClockSource.v
// Module name      : ClockSource
// Description      : This module makes a 33MHz clock source for other modules               
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////  
//- include "../Verilog/Includes/DefineODSTextMacro.v"
//////////////////////////////////////////////////////////////////////////////

 module ClockSource (
        HARD_nRESETi ,      
		LCLK_CPLD ,        // 33MHz clock source from LPC
		MCLK_FPGA ,        // 33MHz clock source from OSC
		Mclkx              // Clock Source output          
	);
///////////////////////////////////////////////////////////////////
//   When LPC clock source , LCLK_CPLD , is not ready , Mclkx will be assigned to OSC clock , MCLK_FPGA .
//   Once LCLK_CPLD is ready , Mclkx will be assigned to LCLK_CPLD for clock synchronization concern.
//   

input   HARD_nRESETi;
input   LCLK_CPLD;
input   MCLK_FPGA;

output  Mclkx ;


reg     [3:0]       LpcClkCnt_0;
reg     [3:0]       LpcClkCnt_1;
reg     [3:0]       LpcClkCnt_2;
reg     [3:0]       ChkClkCnt;
reg                 bLpcClkOff;

    
	assign Mclkx 		= bLpcClkOff ? MCLK_FPGA : LCLK_CPLD ; // - Mclk : lclk; Frank 06092015    
	
    always @(negedge HARD_nRESETi or posedge LCLK_CPLD )  
    begin
		if(1'b0 == HARD_nRESETi)
            LpcClkCnt_0	= 4'h0;
        else
            LpcClkCnt_0 = LpcClkCnt_0 + 1;
    end

    always @(negedge HARD_nRESETi or posedge MCLK_FPGA ) 
    begin
		if(1'b0 == HARD_nRESETi)
            LpcClkCnt_1	= 4'h0;
        else
            LpcClkCnt_1 = LpcClkCnt_0;
    end

    always @(negedge HARD_nRESETi or posedge MCLK_FPGA )  
    begin
		if(1'b0 == HARD_nRESETi)
        begin
			bLpcClkOff = `FALSE;
            ChkClkCnt  = 4'h0;
            LpcClkCnt_2= 0;
        end
        else
        begin
            if(LpcClkCnt_2 != LpcClkCnt_1)
            begin
            	LpcClkCnt_2 = LpcClkCnt_1;
            	//if(4'h0 != ChkClkCnt) ChkClkCnt = ChkClkCnt - 1;
	            ChkClkCnt   = 4'h0;
				bLpcClkOff	= `FALSE;
            end
            else
            begin
            	if(4'hF == ChkClkCnt)
					bLpcClkOff	= `TRUE;
                else
					ChkClkCnt = ChkClkCnt + 1;
            end
        end
    end
	
endmodule // ClockSource