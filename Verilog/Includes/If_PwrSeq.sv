//////////////////////////////////////////////////////////////////////////////
// File name        : If_PwrSeq.sv
// Module name      : ---
// Description      : This interface define Power Good/Fault/En logics for fsm
// Hierarchy Up     : --- 
// Hierarchy Down   : --- 
//////////////////////////////////////////////////////////////////////////////
`ifndef   IF_PWRSEQ_H
`define   IF_PWRSEQ_H
//////////////////////////////////////////////////////////////////////////////   

   interface If_PwrSeq;


       logic  PCH_PwrMain;
       logic  PCH_PwrGD;
       logic  PCH_PwrFLT;     

       logic  goOut_fltSt;

       logic  CPU_PwrGD; 
       logic  CPU_PwrFLT;
       logic  CPU_PwrEN; 
       
       logic  MEM_PwrGD; 
       logic  MEM_PwrFLT;
       logic  MEM_PwrEN;        
                                         
                     
       modport master ( 
                          input  PCH_PwrGD,     CPU_PwrGD,   MEM_PwrGD, 
                                 PCH_PwrFLT,    CPU_PwrFLT,  MEM_PwrFLT, 
                         output  PCH_PwrMain,   CPU_PwrEN,   MEM_PwrEN,   
                                 goOut_fltSt               
                       );                                    
                                                               
       modport pch  (   
                         output  PCH_PwrGD, 
                                 PCH_PwrFLT,  
                         input   PCH_PwrMain,   goOut_fltSt  
                     ); 	 
	   
       modport cpus (   
                         output  CPU_PwrGD,  MEM_PwrGD,  
                                 CPU_PwrFLT, MEM_PwrFLT,
                         input   CPU_PwrEN,  MEM_PwrEN,  goOut_fltSt  
                     );
                    
                                                         
   endinterface // If_PwrSeq

//////////////////////////////////////////////////////////////////////////////
`endif