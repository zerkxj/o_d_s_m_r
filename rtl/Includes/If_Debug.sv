//////////////////////////////////////////////////////////////////////////////
// File name        : If_Debug.sv
// Module name      : ---
// Description      : This Interface retrieves FSM bits for debug display
// Hierarchy Up     : ---
// Hierarchy Down   : ---
//////////////////////////////////////////////////////////////////////////////
`ifndef   IF_DBG_H
`define   IF_DBG_H
//////////////////////////////////////////////////////////////////////////////   
  interface If_Debug;           
//////////////////////////////////////////////////////////////////////////////
            logic  pwr_fault;  
    
            logic  [2:0] asw_fsm;
            logic  [2:0] pch_fsm; 
            logic  [2:0] cpu_fsm;
            logic  [2:0] mem_fsm;			
            logic  [4:0] mstr_fsm;                        
  


       modport master 
       ( 
            output  pwr_fault, mstr_fsm,
  	
			input asw_fsm, pch_fsm, cpu_fsm, mem_fsm
       );                                    
                  
       modport asw 
       ( 
            output  asw_fsm
       );                                    

       modport pch 
       ( 
            output  pch_fsm
       );                             
          
                      
                    
          
        modport cpus 
       ( 
            output  cpu_fsm, mem_fsm
       );                     
                     
                                                         
   endinterface  // If_Debug
//////////////////////////////////////////////////////////////////////////////
`endif








