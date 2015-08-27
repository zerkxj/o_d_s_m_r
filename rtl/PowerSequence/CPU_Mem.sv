//////////////////////////////////////////////////////////////////////////////
// File name        : CPU_Mem.sv
// Module name      : CPU_Mem
// Description      : This module controls CPU and Mem FSM
// Hierarchy Up     : PwrSequence
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
`include "../Verilog/Includes/PwrSeqPackage.sv"
`include "../Verilog/Includes/If_PwrSeq.sv"
`include "../Verilog/Includes/If_Pin.sv"   
`include "../Verilog/Includes/If_Debug.sv" 
//////////////////////////////////////////////////////////////////////////////
 module CPU_Mem 
 (  
    If_Pin.cpus     pin,
    If_Debug.cpus   dbg,	
    If_PwrSeq.cpus  pwrSeq
 );
//////////////////////////////////////////////////////////////////////////////
// Local variables
//////////////////////////////////////////////////////////////////////////////
   logic  VCCIN_EN, 
          PVPP_VDDQ_EN;
          
   logic  PWRGD_VCCIN, 
          PWRGD_PVPP_VDDQ; 
//////////////////////////////////////////////////////////////////////////////
// CPU FSM 
//////////////////////////////////////////////////////////////////////////////	
 
    enum logic [2:0] { st_cpufault    = 3'd0, 
                       st_cpuOff      = 3'd1, 
                       st_VCCIN       = 3'd2, 
                       st_cpuDone     = 3'd3, 
                       st_cpuShutDown = 3'd4   }  C2State,  N2State; 
          

    logic  fault_cpu;

    assign dbg.cpu_fsm[1:0] = C2State [1:0];
	 
    assign dbg.cpu_fsm [2] = VCCIN_EN;
////////////////////////////////////////////////////////////////////////////// 
// Current State
////////////////////////////////////////////////////////////////////////////// 
    always_ff @( posedge pin.clk or negedge pin.rst_n )  
        begin
             if (  !pin.rst_n  )   C2State  <= st_cpuOff;
             else                  C2State  <= N2State;
        end    
   
//////////////////////////////////////////////////////////////////////////////
// NS = f( I, CS )
////////////////////////////////////////////////////////////////////////////// 
    always_comb begin: set_nextState_cpu
    
      unique case( C2State )
           
		st_cpufault    : if( pwrSeq.goOut_fltSt )      N2State = st_cpuOff;
                         else                          N2State = st_cpufault;

        st_cpuOff      : if( fault_cpu )               N2State = st_cpufault;
                         else if( pwrSeq.CPU_PwrEN && PWRGD_PVPP_VDDQ ) 
						                               N2State = st_VCCIN;
                         else                          N2State = st_cpuOff;

        st_VCCIN       : if( fault_cpu )               N2State = st_cpufault;
                         else if( !pwrSeq.CPU_PwrEN )  N2State = st_cpuShutDown;
                         else if(  PWRGD_VCCIN )  	   N2State = st_cpuDone;
                         else                          N2State = st_VCCIN;

        st_cpuDone     : if( fault_cpu )               N2State = st_cpufault;
                         else if( !pwrSeq.CPU_PwrEN )  N2State = st_cpuShutDown;
                         else                          N2State = st_cpuDone;
						 
        st_cpuShutDown : if( fault_cpu )               N2State = st_cpufault;
                         else if( !PWRGD_VCCIN )       N2State = st_cpuOff;
                         else                          N2State = st_cpuShutDown;

        default        :                               N2State = st_cpuOff;                            
                                 
      endcase 
   end      

//////////////////////////////////////////////////////////////////////////////
// O = f( CS )
////////////////////////////////////////////////////////////////////////////// 
    logic  PWRGD_monitor_cpu;

    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
         if (  !pin.rst_n  ) 
         begin             
                VCCIN_EN           <= LOW;

                    
                pwrSeq.CPU_PwrGD   <= LOW;
                pwrSeq.CPU_PwrFLT  <= LOW;

                PWRGD_monitor_cpu  <= LOW;
                fault_cpu          <= LOW;                  
         end
         else begin     

               VCCIN_EN            <=  (C2State >= st_VCCIN) && (C2State < st_cpuShutDown) ? HIGH : LOW;
               
               pwrSeq.CPU_PwrGD    <=  (C2State <= st_cpuOff  )  ?  LOW  : ( 
                                       (C2State == st_cpuDone )  ?  HIGH :   pwrSeq.CPU_PwrGD );
									   
               pwrSeq.CPU_PwrFLT   <=  (C2State == st_cpufault)  ?  HIGH : LOW; 
                                       
                                       
               PWRGD_monitor_cpu   <=   PWRGD_VCCIN  ;

               fault_cpu           <= ( VCCIN_EN && ( PWRGD_monitor_cpu && !PWRGD_VCCIN ) );
         end
    end      
	
	  assign pin.pvccin_cpu0_en     = ( VCCIN_EN  && !pin.cpu0_sktocc_n ) ?  HIGH : LOW;
	  
		
	  
	  assign pin.vtt_abcd_en     	= ( VCCIN_EN  && !pin.cpu0_sktocc_n ) ?  HIGH : LOW;
	 
	 
 
/////////////////////////////////////////////////////////////////////////////  
   
   
assign PWRGD_VCCIN =  pwrSeq.CPU_PwrEN ?  ( pin.vccin_cpu0_pwrgd |  pin.cpu0_sktocc_n ) :                                                   
                                          ( pin.vccin_cpu0_pwrgd & !pin.cpu0_sktocc_n ) ;
                                                   
//////////////////////////////////////////////////////////////////////////////
// Mem FSM 	
//////////////////////////////////////////////////////////////////////////////
  
assign pin.vpp_mem_abcd_en = (PVPP_VDDQ_EN && !pin.cpu0_sktocc_n) ? HIGH : LOW;	 
	 
	 
assign PWRGD_PVPP_VDDQ =  pwrSeq.MEM_PwrEN ? ( pin.pvpp_vddq_ab_pwrgd |  pin.cpu0_sktocc_n ) & 
                                             ( pin.pvpp_vddq_cd_pwrgd |  pin.cpu0_sktocc_n )   :                                                
                                             ( pin.pvpp_vddq_ab_pwrgd & !pin.cpu0_sktocc_n ) | 
                                             ( pin.pvpp_vddq_cd_pwrgd & !pin.cpu0_sktocc_n )   ;                                     
                                                   									  
  
////////////////////////////////////////////////////////////////////////////// 
 
    enum logic [2:0] { st_mfault        = 3'd0, 
                       st_mOff          = 3'd1, 
                       st_VDDQ_VTT      = 3'd2, 
                       st_mDone         = 3'd3, 
                       st_mShutDown     = 3'd4   }  CState,  NState;           

    logic  fault_mem;
	
	assign dbg.mem_fsm [2] = PWRGD_PVPP_VDDQ;
	
	assign dbg.mem_fsm[1:0] = CState [1:0]; 
//////////////////////////////////////////////////////////////////////////////
// Current State
//////////////////////////////////////////////////////////////////////////////
    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
             if (  !pin.rst_n  )   CState  <= st_mOff;
             else              CState  <= NState;
    end      
   
      
//////////////////////////////////////////////////////////////////////////////   
// NS = f( I, CS )
//////////////////////////////////////////////////////////////////////////////
 always_comb begin: set_nextState_mem
    
  unique case( CState )

    st_mfault    : if( pwrSeq.goOut_fltSt )       NState = st_mOff;
                   else                           NState = st_mfault;

    st_mOff      : if( fault_mem )                NState = st_mfault;
                   else if( pwrSeq.MEM_PwrEN )    NState = st_VDDQ_VTT;
                   else                           NState = st_mOff;

    st_VDDQ_VTT  : if( fault_mem )                NState = st_mfault;
                   else if( !pwrSeq.MEM_PwrEN )   NState = st_mShutDown;
                   else if( PWRGD_PVPP_VDDQ )     NState = st_mDone;
                   else                           NState = st_VDDQ_VTT;

    st_mDone     : if( fault_mem )                NState = st_mfault;
                   else if( !pwrSeq.MEM_PwrEN )   NState = st_mShutDown;
                   else                           NState = st_mDone;

    st_mShutDown : if( fault_mem )                NState = st_mfault;
                   else if( !PWRGD_PVPP_VDDQ )    NState = st_mOff;
                   else                           NState = st_mShutDown;

    default      :                                NState = st_mOff;                            
                                 
  endcase 
 end      

//////////////////////////////////////////////////////////////////////////////
// O = f( CS )
//////////////////////////////////////////////////////////////////////////////
    logic  PWRGD_monitor_mem;

    always_ff @( posedge pin.clk or negedge pin.rst_n ) begin 
    
         if (  !pin.rst_n  ) 
         begin             
                PVPP_VDDQ_EN       <= LOW;

                    
                pwrSeq.MEM_PwrGD   <= LOW;
                pwrSeq.MEM_PwrFLT  <= LOW;

                PWRGD_monitor_mem  <= 1'b0;
                fault_mem          <= LOW;                  
         end
         else begin     

               PVPP_VDDQ_EN        <= (CState >= st_VDDQ_VTT) && (CState < st_mShutDown) ? HIGH : LOW;

               
               pwrSeq.MEM_PwrGD    <= (CState <= st_mOff  )  ?  LOW  : ( 
                                      (CState == st_mDone )  ?  HIGH :   pwrSeq.MEM_PwrGD );
              
                                       
                                       
               PWRGD_monitor_mem   <=   PWRGD_PVPP_VDDQ ;

               //fault_mem           <=  ( PVPP_VDDQ_EN      &&  (PWRGD_monitor_mem && !PWRGD_PVPP_VDDQ)     )  ;
         end
    end 								  

//////////////////////////////////////////////////////////////////////////////                
 

//////////////////////////////////////////////////////////////////////////////  
// The processor can have two different kind of cores; 1) HSW and 2)BDW, 
// but it is not allowed to mix them in a single system.
// This function signals the wrong condition by returning a 1.
// 
//  --- evolution --> HSW : ID = 
//  --- evolution --> BDW : ID = 0 
//////////////////////////////////////////////////////////////////////////////

    logic [1:0] cpu_Prsnt_n;  
    logic       SysConfig;
    logic       valid_SysConfg;
    logic       allHSW, 
                allBDW;    
        
    assign      cpu_Prsnt_n = {  1, 
                                 pin.cpu0_sktocc_n };       								 
    always_comb 
    begin     
          case( cpu_Prsnt_n ) 
                2'b10:    SysConfig = 1;
                2'b00:    SysConfig = 1;
                default:  SysConfig = 0;              
                
          endcase             
    end   
    
	  
///////////////////////////////////////////////////////////////////////////    
// Proc_ID ( CPU pin AB48 , here :cpu0_sktid_n ) 
//                     : output 1 when Haswell-EP CPU , 
//                       output 0 for future CPU ( Broadwell-EP ) 
///////////////////////////////////////////////////////////////////////////
    assign allHSW   =  pin.cpu0_sktid_n;      
    assign allBDW   = ~(pin.cpu0_sktid_n & !pin.cpu0_sktocc_n); 
	
    assign pin.cpu_validcfg  =  SysConfig  &  (allHSW | allBDW);  
// This output pin is only connected to one input of mstrSeq module. No output externally. 
 

 endmodule // CPU_Mem
