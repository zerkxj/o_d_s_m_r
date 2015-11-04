//////////////////////////////////////////////////////////////////////////////
// File name        : sync.v
// Module name      : sync
// Description      : This module synchronizes data_in with sync_clk             
// Hierarchy Up     : UFMRwPageDecode
// Hierarchy Down   : ---
////////////////////////////////////////////////////////////////////////////// 
`timescale 1 ns / 1 ns
module sync (	
	data_in,
	data_out,
	sync_clk,
	sync_clk_en,
	sync_rst_n
	); 
input	      data_in;
output		  data_out;
input		  sync_clk;
input		  sync_clk_en;
input		  sync_rst_n;
reg    [1:0]  data_sync; 
assign data_out = data_sync[1];
always @ (posedge sync_clk or negedge sync_rst_n)
  begin
    if (~sync_rst_n)
      data_sync <= 2'b0;	
    else if (sync_clk_en)
      begin
        data_sync[1]	<= data_sync[0];
        data_sync[0]	<= data_in;
      end
  end
endmodule  // sync


