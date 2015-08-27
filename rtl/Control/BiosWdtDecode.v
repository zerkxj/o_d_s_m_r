//////////////////////////////////////////////////////////////////////////////
// File name        : BiosWdtDecode.v
// Module name      : BiosWdtDecode
// Description      : This module decodes BIOS WDT address and data in CPLD reg                
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : ---
////////////////////////////////////////////////////////////////////////////// 

module  BiosWdtDecode ( 
         MainResetN,
		 CLK32768,   
         Mclkx,		 
		 DevCs_En, 
		 DevAddr,
		 WrDev_Data,
		 
		 bCPUWrWdtRegSig
); 	
//////////////////////////////////////////////////////////////////////////	
input 	         MainResetN;
input	     	 CLK32768;  
input            Mclkx;                
input		     DevCs_En; 
input   [15:0]	 DevAddr;
input   [7:0]  	 WrDev_Data;
		 
output	[4:0]    bCPUWrWdtRegSig; 	
//////////////////////////////////////////////////////////////////////////
reg		[4:0]    bCPUWriteWdtSig;
reg              bCPUWdtAcsFlg; 

reg     [4:0]    bCPUWrWdtRegSig;
//////////////////////////////////////////////////////////////////////////

	always @(posedge CLK32768 or negedge MainResetN)
	begin
		if(1'b0 == MainResetN)
        begin
            bCPUWrWdtRegSig = 0;
        end
        else
        begin
            bCPUWrWdtRegSig = bCPUWriteWdtSig;
        end
    end

	always @(posedge Mclkx or negedge MainResetN)
	begin
		if(1'b0 == MainResetN)
        begin
            bCPUWriteWdtSig = 0;
            bCPUWdtAcsFlg = 0;
        end
        else
        begin
            if(!(1'b1 == DevCs_En && 16'h0801 == DevAddr)) bCPUWdtAcsFlg = 1'b0;
            else
            begin
	            if(1'b0 == bCPUWdtAcsFlg)
	            begin
                    if(8'h55 == WrDev_Data)      bCPUWriteWdtSig[0] = ~bCPUWriteWdtSig[0];
                    else if(8'h29 == WrDev_Data) bCPUWriteWdtSig[1] = ~bCPUWriteWdtSig[1];
                    else if(8'hFF == WrDev_Data) bCPUWriteWdtSig[2] = ~bCPUWriteWdtSig[2];
                    else if(8'hAA == WrDev_Data) bCPUWriteWdtSig[3] = ~bCPUWriteWdtSig[3];
                    else                         bCPUWriteWdtSig[4] = ~bCPUWriteWdtSig[4];
                    bCPUWdtAcsFlg = 1'b1;
	            end
            end
        end
    end
//////////////////////////////////////////////////////////////////////////

endmodule // BiosWdtDecode