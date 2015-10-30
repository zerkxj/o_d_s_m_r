//////////////////////////////////////////////////////////////////////////////
// File name        : MR_Bsp.v
// Module name      : MR_Bsp
// Description      : This module ( Board Support Package ) designs some main features.                
// Hierarchy Up     : ODS_MR
// Hierarchy Down   : FanLED , ResetControl , BiosControl , ButtonControl , BiosWatchDog ,
//                    DualPower , Interrupt , Led7SegDecode , LpcIorCpldReg ,
//                    LpcIowCpldReg , WatchDog
//////////////////////////////////////////////////////////////////////////////   
`timescale 1 ns / 100 ps
`include "../Verilog/Includes/DefineODSTextMacro.v" 
module MR_Bsp (
	ResetN,
	Mclk,
	DevAddr,
	WrDev_En,
	WrDev_Data,
	RdDev_En,
	RdDev_Data,
    BiosPostData,
    SpecialCmdReg,
    bFlashBusyN,
    DevCs_En,
    RstBiosFlg,
    PS_ONn,
    PSU_FANIN,
	MONITOR_BEEP,			//Fan Fail - 1, FanOK - 0; - has internal weak P/U
	FanState,				//Fan Fail - 1, FanOK - 0; - has internal weak P/U
    FanPresences,           //Fan Presence 1 2 3
	FanFail,				//Fan Led indication
	FanOK,					//Fan Led indication	
	ALL_PWRGD,          	// ALL POWER GOOD internal LED:	0-Off, 1-ON
	CLK32KHz,	
    Strobe1s,
    Strobe1ms,
    Strobe16ms,
    Strobe125ms,
	Strobe125msec,	
	Reset1G,
	SysReset,				// Reset Button
	PowerButtonIn,			// Power Button input 
	PowerButtonOut,			// Debounced Power Button
	ResetOut,				// Active Wide Strobe 4s after  the button pushed
	MainResetN,				// Power or Controller ICH10R Reset
	PowerSupplyOK,			// Power Supply OK from Power connector
	DualPSCfgFlash,			// Internal Flash - points to Dual Power Supply if "1"
    DualPSJump3,            // Board Jumper - points to Dual Power Supply if "1"
	ZippyStatus,			// Dual Power Supply Status
	SysLedG,				// System LED: Green Anode
	SysLedR,				// System LED: Green Cathode
	PowerNormal,			// Power LED active "1/0" Green/Red Control
	PowerFail,				// Power LED active "0/1" Green/Red Control
    InterruptD,
    BiosCS,
    BIOS_SEL,
	BIOS,					// Chip Select to SPI Flash Memories
	BiosLed,				// LED to point current BIOS
    PowerOff,
    PowerEvtState,
	Led7En,
    Led7Leg,
	SystemOK,	
    BspDbgP,	
	FM_PLD_DEBUG2,    // FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode ; from PwrSequence module
	FM_PLD_DEBUG3,  
	FM_PLD_DEBUG4,  
	FM_PLD_DEBUG5,
    PORT80_DP         // Port80 7Seg DP LED   	
   );

input				ResetN;
output				Reset1G;
input				Mclk;
input	[15:0]		DevAddr;
input				WrDev_En;
input	[7:0]		WrDev_Data;
input				RdDev_En;
output	[7:0]		RdDev_Data;
input   [7:0]       BiosPostData;
output  [7:0]		SpecialCmdReg;
input               bFlashBusyN;
input               DevCs_En;
input               RstBiosFlg;
input               PS_ONn;
input               PSU_FANIN;
input				MONITOR_BEEP;		//Fan Fail - 1, FanOK - 0; - has internal weak P/U
input               FanState;           //Fan Fail - 1, FanOK - 0; - has internal weak P/U
input   [2:0]       FanPresences;
output				FanFail;			//Fan Led indication
output				FanOK;				//Fan Led indication
input               CLK32KHz;
///////////////////////////////////////////////////////////////////
input				ALL_PWRGD ;        // Origin it is an output wire , now, change to a input one 
input				PowerSupplyOK, DualPSCfgFlash;
input               DualPSJump3;
input	[1:0]		ZippyStatus;
output				SysLedG, SysLedR;
output	[1:0]		PowerNormal, PowerFail;	// Right, Left
input				MainResetN;				// Power or Controller ICH10R Reset
input				Strobe1s, Strobe1ms, Strobe16ms, Strobe125ms;
input               Strobe125msec;
input				SysReset, PowerButtonIn;
output				PowerButtonOut, ResetOut;
output				InterruptD;
input               BiosCS;
input               BIOS_SEL;
output	[1:0]		BIOS, BiosLed;
output				PowerOff;
input   [3:0]       PowerEvtState;
output  [5:0]       Led7En;
output  [6:0]       Led7Leg;
output              SystemOK;
output  [3:0]       BspDbgP; 
input               FM_PLD_DEBUG2;  
input               FM_PLD_DEBUG3;  
input               FM_PLD_DEBUG4;  
input               FM_PLD_DEBUG5;   
output              PORT80_DP; 
///////////////////////////////////////////////////////////////////
reg		[2:1]		Edge;
reg					SwapBios;
///////////////////////////////////////////////////////////////////
wire                PORT80_DP;		
wire	[7:0]		RdDev_Data;
wire	[7:0]       BiosRegister;
wire	[7:0]       PSUFan_StReg;
wire            	PSU1_Tach_Low;
wire            	PSU1_Tach_High;
wire	[4:0]       x7SegSel;
wire	[7:0]       x7SegVal;
wire    [5:0]       Led7En;
wire    [6:0]       Led7Leg;
wire	[6:0]		WatchDogRegister;
wire				WatchDogReset;
wire	[2:0]		ClearInterrupt;
wire	[5:0]		InterruptRegister;
wire				InterruptD;
wire                WriteBiosWD;
wire				BiosFinished, BiosPowerOff, ForceSwap;
wire	[1:0]		BIOS, BiosLed;
wire	[3:0]		BiosStatus;
wire                SetBios0;
wire				SystemOK;
wire				SysLedG, SysLedR;
wire	[1:0]		PowerNormal, PowerFail;	// Right, Left
wire	[3:0]		Interrupt;
wire				PowerButtonOut, ResetOut;
wire                SwapDisable;
wire    [5:0]       ResetDevReg;
wire    [7:0]		SpecialCmdReg;
wire	[3:0]		FanLedCtrlReg;
wire				FanFail;			//Fan Led indication
wire				FanOK;				//Fan Led indication
wire				Reset1G;
wire    [3:0]       BspDbgP;
wire                PowerOff;
wire				Shutdown;
wire	[1:0]       bwdtDPx;
///////////////////////////////////////////////////////////////////    
	assign BspDbgP[0] = BiosPowerOff;   // 
	assign BspDbgP[1] = Shutdown;		// 
	assign BspDbgP[2] = SwapBios; 	    // 
	assign BspDbgP[3] = SwapDisable ;   // 
	assign WriteBiosWD	= (1'b0 == DevCs_En) ? 1'b0 : (WrDev_En & (DevAddr[4:0] == 5'h01));
	assign PowerOff		= BiosPowerOff | Shutdown;
    assign Shutdown 	= Edge[1];
///////////////////////////////////////////////////////////////////
	always @(posedge Mclk or negedge MainResetN)
    begin
  		if(!MainResetN)
    	begin
      		Edge			<= 0;
      		SwapBios		<= 0;
		end
		else
		begin
			Edge			<= {Edge[1], SpecialCmdReg == "S"};
			SwapBios		<= Edge == 2'h1;
		end
    end
///////////////////////////////////////////////////////////////////
	ButtonControl ButtonControl(
		.MainReset			(ResetN),			// In , Power or Controller ICH10R Reset
		.SlowClock			(CLK32KHz),			// In , Oscillator Clock 32,768 Hz
		.Strobe1s			(Strobe1s),			// In , Single SlowClock Pulse @ 1s
		.Strobe16ms			(Strobe16ms),		// In , Single SlowClock Pulse @ 16 ms
		.Strobe125ms		(Strobe125ms),		// In , Single SlowClock Pulse @ 125 ms
		.SysReset			(SysReset),			// In , Reset Button
		.PowerButtonIn		(PowerButtonIn),	// In , Power Button
		.WatchDogReset		(WatchDogReset),	// In , System Watch Dog Reset Request , From MR_Bsp.WatchDog
		.Interrupt			(Interrupt),		// Out[3:0] , Power & Reset Interrupts and Button release
		.PowerButtonOut		(PowerButtonOut),	// Out , Debounced Power Button
		.ResetOut			(ResetOut)			// Out , Active Wide Strobe 4s after  the button pushed
	); // ButtonControl
///////////////////////////////////////////////////////////////////
    DualPower DualPower(
		.ResetNi			(ResetN),			// In , Generated PowerUp Reset
		.SlowClock			(CLK32KHz),			// In , Oscillator Clock 32,768 Hz       
		.PowerSupplyOK		(PowerSupplyOK),	// In , Power Supply OK from Power connector
		.DualPS				(DualPSCfgFlash),	// In , Board Jumper - points to Dual Power Supply if "1"
		.ZippyStatus		(ZippyStatus),		// In[2:1] , Dual Power Supply Status
        .PSU_FANIN          (PSU_FANIN),        // In , PSU FAN pulse info
		.PSUFan_StReg		(PSUFan_StReg),     // In[7:0] , Software write info
		.PSU1_Tach_Low		(PSU1_Tach_Low),    // Out , high or low then minimum freq
		.PSU1_Tach_High		(PSU1_Tach_High),   // Out , high or low then maximum freq
		.SystemOK			(!SystemOK),		// In , System Status: SystemOK
		.SysLedG			(SysLedG),			// Out , System LED: Green Anode
		.SysLedR			(SysLedR),			// Out , System LED: Green Cathode
		.PowerNormal		(PowerNormal),		// Out[2:1] , Power LED active "1/0" Green/Red Control
		.PowerFail			(PowerFail)			// Out[2:1] , Power LED active "0/1" Green/Red Control
	); // DualPower
///////////////////////////////////////////////////////////////////
	InterruptControl InterruptControl(
		.PciReset			(MainResetN),		// In , PCI Reset
		.LpcClock			(Mclk),				// In , 33 MHz Lpc
		.Write				(WrDev_En),			// In , Write Access to CPLD registers
		.WatchDogIREQ		(WatchDogRegister[5]),// In , Watch Dog Interrupt Request
		.RegAddress			(DevAddr[4:0]),		// In[4:0] , Address of the accessed Register
		.Data				(WrDev_Data),		// In[7:0] , Data to be written to register
		.Interrupt			(Interrupt),		// In[3:0] , Power & Reset Interrupts and Button release
		.ClearInterrupt		(ClearInterrupt),	// Out[6:4] , Clear Interrups: WatchDog, Reset, Power
		.InterruptRegister	(InterruptRegister),// Out[5:0] , Interrupt Control / Status Register
		.InterruptD			(InterruptD)		// Out , Interrupt Request to CPU
	); // InterruptControl
///////////////////////////////////////////////////////////////////	
	BiosControl BiosControl(	    
		.ResetN				(ResetN),			// In , Generated PowerUp Reset
		.ALL_PWRGD          (ALL_PWRGD),        // In , add for merging SetBiosCS 	
		.SlowClock          (CLK32KHz),         // In , add for merging SetBiosCS 
		.Strobe125ms        (Strobe125ms),      // In , add for merging SetBiosCS	
		.MainReset			(!MainResetN),		// In , Power or Controller ICH10R Reset 	
		.LpcClock			(Mclk),				// In , 33 MHz Lpc (Altera Clock)
        .RstBiosFlg         (RstBiosFlg),       // In , Reset BIOS to BIOS0
		.Write				(WrDev_En),			// In , Write Access to CPLD registor
		.BiosCS				(BiosCS),			// In , ICH10 BIOS Chip Select (SPI Interface)
		.BIOS_SEL			(BIOS_SEL),         // In , BIOS SELECT  - Bios Select Jumper (default "1")
		.SwapDisable		(SwapDisable),		// Out , when merge SetBiosCS , In , Disable BIOS Swapping after Power Up
		.ForceSwap			({ForceSwap, SwapBios}), // In[1:0] , BiosWD Occurred, Force BIOS Swap while power restart
		.RegAddress			(DevAddr[4:0]),		// In[4:0] , Address of the accessed Register
		.Data				(WrDev_Data),		// In[7:0] , Data to be written to CPLD Register 
		.BIOS				(BIOS),				// Out[1:0] , Chip Select to SPI Flash Memories
		.BiosLed			(BiosLed),			// Out[1:0] , LED to point current BIOS      
		.BiosStatus			(BiosStatus)		// Out[3:0] , Bios Status: Current, Next, Active
	); // BiosControl
///////////////////////////////////////////////////////////////////
	BiosWatchDog BiosWatchDog(
		.Reset				(ResetN),			// In , Generated PowerUp Reset
		.SlowClock			(CLK32KHz),			// In , Oscillator Clock 32,768 Hz
		.LpcClock			(Mclk),				// In , 33 MHz Lpc (Altera Clock)
		.MainReset			(MainResetN),		// In , Power or Controller ICH10R Reset
    	.PS_ONn				(PS_ONn),           // In 
		.Strobe125msec		(Strobe125msec),	// In , Single LpcClock  Pulse @ 125 ms
        .DPx                (bwdtDPx),          // Out[1:0] 
		.WriteBiosWD		(WriteBiosWD),		// In , CPU (BIOS) writes to BIOS WD Register (#1)
		.BiosRegister		(BiosRegister),		// In[7:0] , Bios Watch Dog Control Register
		.BiosFinished		(BiosFinished),		// Out , Bios Has been finished
		.BiosPowerOff		(BiosPowerOff),		// Out , BiosWD Occurred, Force Power Off
		.ForceSwap			(ForceSwap)			// Out , BiosWD Occurred, Force BIOS Swap while power restart
	);  // BiosWatchDog
///////////////////////////////////////////////////////////////////
	WatchDog WatchDog(
		.PciReset			(MainResetN),		// In , PCI Reset
		.LpcClock			(Mclk),				// In , 33 MHz Lpc
		.Strobe125msec		(Strobe125msec),	// In , Single LpcClock  Pulse @ 125 ms
		.Write				(WrDev_En),			// In , Write Access to CPLD registers
		.Read				(RdDev_En),			// In , Read  Access to CPLD registers
       
		.ClearInterrupt		(ClearInterrupt),	// In[2:0] , Clear Interrups: WatchDog, Reset, Power
		.RegAddress			(DevAddr[4:0]),		// In[4:0] , Address of the accessed Register
		.Data				(WrDev_Data),		// In[7:0] , Data to be written to register
		.WatchDogRegister	(WatchDogRegister),	// Out[6:0] , Watch Dog Control / Status Register
		.WatchDogReset		(WatchDogReset)		// Out , System Watch Dog Reset Request
	); //WatchDog 
/////////////////////////////////////////////////////////////////// 
	LpcIorCpldReg LpcIorCpldReg( 
		.ResetN				(ResetN),           // In
		.Mclk				(Mclk),             // In
		.DevAddr			(DevAddr),          // In[15:0]
		.RdDev_En			(RdDev_En),         // In
		.RdDev_Data     	(RdDev_Data),       // Out[7:0]
		.WatchDogRegister	(WatchDogRegister),	// In[6:0] , Watch Dog Control / Status Register
		.InterruptRegister	(InterruptRegister),// In[5:0] , Interrupt Control / Status Register
		.BiosRegister		(BiosRegister),     // In[7:0]  
		.BiosStatus			(BiosStatus),       // In[3:0]
		.SystemOK			(SystemOK),         // In       
		.DualPSCfgFlash		(DualPSCfgFlash),   // In
        .DualPSJump3        (DualPSJump3),      // In 
		.ZippyStatus		(~ZippyStatus),     // In[1:0] , Power supply status 0: OK, 1: Fail		
		.BIOS_SEL			(BIOS_SEL),         // In
		.PSU1_Tach_Low		(PSU1_Tach_Low),    // In , high or low then minimum freq
		.PSU1_Tach_High		(PSU1_Tach_High),   // In , high or low then maximum freq
		.PSUFan_StReg		(PSUFan_StReg),     // In[7:0]          
        .FanTrayPresent     (|FanPresences),    // In 
		.x7SegSel			(x7SegSel),         // In[4:0]
		.x7SegVal           (x7SegVal),	        // In[7:0]  
        .SpecialCmdReg		(SpecialCmdReg),    // In[7:0] 
        .bFlashBusyN        (bFlashBusyN),      // In
        .FanLedCtrlReg      (FanLedCtrlReg),    // In[3:0] 
		.ResetDevReg        (ResetDevReg)       // In[5:0]
	); // LpcIorCpldReg
///////////////////////////////////////////////////////////////////	
	LpcIowCpldReg  LpcIowCpldReg( 
		.ResetN				(ResetN),           // In  
		.MainResetN			(MainResetN),		// In , Power or Controller ICH10R Reset
		.Mclk				(Mclk),             // In
		.DevAddr			(DevAddr),          // In[16:0]
		.WrDev_En			(WrDev_En),         // In  
		.WrDev_Data     	(WrDev_Data),       // In[7:0]
        .ALL_PWRGD          (ALL_PWRGD),        // In 
		
		.SystemOK			(SystemOK),         // Out
		.BiosRegister		(BiosRegister),     // Out[7:0] 
		.PSUFan_StReg		(PSUFan_StReg),     // Out[7:0]
		.x7SegSel			(x7SegSel),         // Out[4:0] 
		.x7SegVal           (x7SegVal),         // Out[7:0]
        .SpecialCmdReg		(SpecialCmdReg),    // Out[7:0]
        .FanLedCtrlReg      (FanLedCtrlReg), 	// Out[3:0]
        .ResetDevReg        (ResetDevReg)       // out[5:0]
	); // LpcIowCpldReg
///////////////////////////////////////////////////////////////////
	ResetControl ResetControl(
		.MainReset			(MainResetN),		// In , Power or PCH Reset
		.PciReset			(MainResetN),		// In , PCI Reset
		.ResetRegister		(ResetDevReg),		// In[5:0] , Peripheral Reset:  Phy1G,	
		.Reset1G			(Reset1G)			// Out , Reset Phy 1G		
	); // ResetControl
///////////////////////////////////////////////////////////////////
	Led7SegDecode Led7SegDecode(
    	.ResetN				(ResetN),           // In
    	.Mclk				(CLK32KHz),         // In 
		.ALL_PWRGD			(ALL_PWRGD),        // In , Drive LED: 0-Off, 1-ON
		.SystemOK			(SystemOK),			// In , System Status: SystemOK
        .BiosFinished       (BiosFinished),     // In 
        .BiosPostData       (BiosPostData),     // In[7:0]
		.Strobe1ms			(Strobe1ms),		// In , Single SlowClock Pulse @ 1 ms
		.Strobe1s			(Strobe1s),			// In , Single SlowClock Pulse @ 1 s
		.Strobe125ms		(Strobe125ms),		// In , Single SlowClock Pulse @ 125 ms
        .BiosStatus         (BiosStatus),       // In[3:0]
    	.x7SegSel			(x7SegSel),         // In[4:0]  
    	.x7SegVal			(x7SegVal),         // In[7:0]      
        .PowerEvtState      (PowerEvtState),    // In[3:0]
    	.Led7En				(Led7En),           // Out[5:0]
    	.Led7Leg			(Led7Leg),          // Out[6:0] 	    
	    .FM_PLD_DEBUG2      (FM_PLD_DEBUG2),    // In , FM_PLD_DEBUG[5:2] to MR_Bsp.Led7SegDecode ; from PwrSequence module
		.FM_PLD_DEBUG3      (FM_PLD_DEBUG3),    // In
		.FM_PLD_DEBUG4      (FM_PLD_DEBUG4),    // In
		.FM_PLD_DEBUG5      (FM_PLD_DEBUG5),  	// In         
	   	.PORT80_DP          (PORT80_DP)         // Out , Drive 7Seg LEDs' DP LED
    );  // Led7SegDecode
///////////////////////////////////////////////////////////////////
	FanLED FanLED(
		.SlowClock			(CLK32KHz),			// In , Oscillator Clock 32,768 Hz
		.Strobe16ms			(Strobe16ms),		// In , Single SlowClock Pulse @ 16 ms
		.Beep				(FanState),			// In , Fan Fail - 1, FanOK - 0
        .FanLedCtrlReg      (FanLedCtrlReg),    // In[3:0] 
		.FanFail			(FanFail),			// Out , Fan Led indication
		.FanOK				(FanOK)				// Out
	); // FanLED
///////////////////////////////////////////////////////////////////
endmodule // MR_Bsp 
