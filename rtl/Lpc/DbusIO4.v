// Frank 06302015 renames file and module to DbusIO4.v and DbusIO4
// Mask  dbusIO1  module.

//- module	dbusIO4 (eWBus, WBusDi, RBusDo, DataBusx); 
module	DbusIO4 (eWBus, WBusDi, RBusDo, DataBusx);
input			eWBus;
input	[3:0]	WBusDi;
output	[3:0]	RBusDo;
inout	[3:0]	DataBusx;

wire	[3:0]	RBusDo;
wire	[3:0]	a;
wire	[3:0]	b;

    assign DataBusx = (1'b1 == eWBus) ? a : 4'hZ;
    assign RBusDo  = b;
    assign b = DataBusx;
    assign a = WBusDi;
endmodule


