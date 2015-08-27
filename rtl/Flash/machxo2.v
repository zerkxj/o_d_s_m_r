// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2002-2010 by Lattice Semiconductor Corporation
// --------------------------------------------------------------------
//
//
//                     Lattice Semiconductor Corporation
//                     5555 NE Moore Court
//                     Hillsboro, OR 97214
//                     U.S.A
//
//                     TEL: 1-800-Lattice (USA and Canada)
//                          408-826-6000 (other locations)
//
//                     web: http://www.latticesemi.com/
//                     email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
// Header files for MACHXO2 family
//
// --------------------------------------------------------------------

module AGEB2 (A1, A0, B1, B0, CI, GE);  //synthesis syn_black_box 
input  A1 ;
input  A0 ;
input  B1 ;
input  B0 ;
input  CI ;
output GE ;
endmodule

module ALEB2 (A1, A0, B1, B0, CI, LE);  //synthesis syn_black_box 
input  A1 ;
input  A0 ;
input  B1 ;
input  B0 ;
input  CI ;
output LE ;
endmodule

module AND2 (A, B, Z);  //synthesis syn_black_box
  input A ;
  input B ;
  output Z ;
endmodule

module  AND3  (A, B, C, Z);  //synthesis syn_black_box
  input A ;
  input B ;
  input C ;
  output Z ;
endmodule 

module  AND4  (A, B, C, D, Z);  //synthesis syn_black_box
  input A ;
  input B ;
  input C ;
  input D ;
  output Z ;
endmodule 

module  AND5  (A, B, C, D, E, Z);  //synthesis syn_black_box
  input A ;
  input B ;
  input C ;
  input D ;
  input E ;
  output Z ;
endmodule 

module ANEB2 (A1, A0, B1, B0, CI, NE);  //synthesis syn_black_box 
input  A1 ;
input  A0 ;
input  B1 ;
input  B0 ;
input  CI ;
output NE ;
endmodule

module BB (I, T, O, B);  //synthesis syn_black_box black_box_pad_pin="B"
input  I ;
input  T ;
output O ;
inout  B ;
endmodule 

module BBPD (I, T, O, B);  //synthesis syn_black_box black_box_pad_pin="B"
input  I ;
input  T ;
output O;
inout  B ;
endmodule

module BBPU (I, T, O, B);  //synthesis syn_black_box black_box_pad_pin="B"
input  I ;
input  T ;
output O;
inout  B ;
endmodule

module BBW (I, T, O, B);  //synthesis syn_black_box black_box_pad_pin="B"
input  I ;
input  T ;
output O;
inout  B ;
endmodule 

module CB2 (CI, PC1, PC0, CON, CO, NC1, NC0); //synthesis syn_black_box
  input  CI;
  input  PC1;
  input  PC0;
  input  CON;
  output CO;
  output NC1;
  output NC0;
endmodule

module CD2 (CI, PC1, PC0, CO, NC1, NC0);  //synthesis syn_black_box
input  CI ;
input  PC1 ;
input  PC0 ;
output CO ;
output NC1 ;
output NC0 ;
endmodule 

module CU2 (CI, PC1, PC0, CO, NC1, NC0);  //synthesis syn_black_box
input  CI ;
input  PC1 ;
input  PC0 ;
output CO ;
output NC1 ;
output NC0 ;
endmodule 

module FADD2B (A1, A0,  B1, B0, CI, 
       COUT, S1, S0);  //synthesis syn_black_box
input  A1, A0, B1, B0, CI;
output COUT, S1, S0;
endmodule

module FADSU2 (A1, A0, B1, B0, BCI, CON, BCO, S1, S0); //synthesis syn_black_box
  input  A1;
  input  A0;
  input  B1;
  input  B0;
  input  BCI;
  input  CON;
  output BCO;
  output S1;
  output S0;
endmodule

module FD1P3AX (D, SP, CK, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input CK ;
output Q ;
endmodule

module FD1P3AY (D, SP, CK, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input CK ;
output Q ;
endmodule

module FD1P3BX (D, SP, CK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input CK ;
input PD ;
output Q ;
endmodule

module FD1P3DX (D, SP, CK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input CK ;
input CD ;
output Q ;
endmodule

module FD1P3IX (D, SP, CK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input CK ;
input CD ;
output Q ;
endmodule

module FD1P3JX (D, SP, CK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input CK ;
input PD ;
output Q ;
endmodule

module FD1S1A (D, CK, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input CK ;
output Q ;
endmodule

module FD1S1AY (D, CK, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input CK ;
output Q ;
endmodule

module FD1S1B (D, CK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input CK ;
input PD ;
output Q ;
endmodule

module FD1S1D (D, CK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input CK ;
input CD ;
output Q ;
endmodule

module FD1S1I (D, CK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input CK ;
input CD ;
output Q ;
endmodule

module FD1S1J (D, CK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input CK ;
input PD ;
output Q ;
endmodule

module FD1S3AX (D, CK, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input  D ;
input  CK ;
output Q ;
endmodule

module FD1S3AY (D, CK, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input  D ;
input  CK ;
output Q ;
endmodule

module FD1S3BX (D, CK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input  D ;
input  CK ;
input  PD ;
output Q ;
endmodule

module FD1S3DX (D, CK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input  D ;
input  CK ;
input  CD ;
output Q ;
endmodule

module FD1S3IX (D, CK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input  D ;
input  CK ;
input  CD ;
output Q ;
endmodule

module FD1S3JX (D, CK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input  D ;
input  CK ;
input  PD ;
output Q ;
endmodule

module FL1P3AY (D1, D0, SP, CK, SD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D1 ;
input D0 ;
input SP ;
input CK ;
input SD ;
output Q ;
endmodule

module FL1P3AZ (D1, D0, SP, CK, SD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D1 ;
input D0 ;
input SP ;
input CK ;
input SD ;
output Q ;
endmodule

module FL1P3BX (D1, D0, SP, CK, SD, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D1 ;
input D0 ;
input SP ;
input CK ;
input SD ;
input PD ;
output Q ;
endmodule

module FL1P3DX (D1, D0, SP, CK, SD, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D1 ;
input D0 ;
input SP ;
input CK ;
input SD ;
input CD ;
output Q ;
endmodule

module FL1P3IY (D1, D0, SP, CK, SD, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D1 ;
input D0 ;
input SP ;
input CK ;
input SD ;
input CD ;
output Q ;
endmodule

module FL1P3JY (D1, D0, SP, CK, SD, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D1 ;
input D0 ;
input SP ;
input CK ;
input SD ;
input PD ;
output Q ;
endmodule

module FL1S1A (D0, D1, CK, SD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D0;
  input  D1;
  input  CK;
  input  SD;
  output Q;
endmodule

module FL1S1AY (D0, D1, CK, SD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D0;
  input  D1;
  input  CK;
  input  SD;
  output Q;
endmodule

module FL1S1B (D0, D1, CK, SD, PD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D0;
  input  D1;
  input  CK;
  input  SD;
  input  PD;
  output Q;
endmodule

module FL1S1D (D0, D1, CK, SD, CD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D0;
  input  D1;
  input  CK;
  input  SD;
  input  CD;
  output Q;
endmodule

module FL1S1I (D0, D1, CK, SD, CD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D0;
  input  D1;
  input  CK;
  input  SD;
  input  CD;
  output Q;
endmodule

module FL1S1J (D0, D1, CK, SD, PD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D0;
  input  D1;
  input  CK;
  input  SD;
  input  PD;
  output Q;
endmodule

module FL1S3AX (D1, D0, CK, SD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D1;
  input  D0;
  input  CK;
  input  SD;
  output Q;
endmodule

module FL1S3AY (D1, D0, CK, SD, Q); //synthesis syn_black_box
  parameter GSR = "ENABLED";
  input  D1;
  input  D0;
  input  CK;
  input  SD;
  output Q;
endmodule

module FSUB2B (A1, A0, B1, B0, BI, BOUT, S1, S0); //synthesis syn_black_box

  input  A1, A0, B1, B0, BI;
  output BOUT, S1, S0;
endmodule 

module GSR (GSR)  /* synthesis syn_black_box syn_noprune=1 */;
input GSR ;
endmodule

module IB (I, O);  //synthesis syn_black_box black_box_pad_pin="I"
input  I ;
output O ;
endmodule

module IBPD (I, O);  //synthesis syn_black_box black_box_pad_pin="I"
input  I ;
output O ;
endmodule

module IBPU (I, O);  //synthesis syn_black_box black_box_pad_pin="I"
input  I;
output O;
endmodule

module IFS1P3BX (D, SP, SCLK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SP;
input SCLK;
input PD;
output Q;
endmodule

module IFS1P3DX (D, SP, SCLK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SP;
input SCLK;
input CD;
output Q;
endmodule

module IFS1P3IX (D, SP, SCLK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SP;
input SCLK;
input CD;
output Q;
endmodule

module IFS1P3JX (D, SP, SCLK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SP;
input SCLK;
input PD;
output Q;
endmodule

module ILVDS (A, AN, Z); //synthesis syn_black_box black_box_pad_pin="A,AN"
  input  A;
  input  AN;
  output Z;
endmodule

module INV (A, Z);  //synthesis syn_black_box
input A;
output Z;
endmodule

module L6MUX21 (D0, D1, SD, Z);  //synthesis syn_black_box

input D0;
input D1;
input SD;
output Z;
endmodule

module LB2P3AX (D1, D0, CI, SP, CK, SD, CON, CO, Q1, Q0);  //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CON;
output CO, Q1, Q0;
endmodule

module LB2P3AY (D1, D0, CI, SP, CK, SD, CON, CO, Q1, Q0);  //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CON;
output CO, Q1, Q0;
endmodule

module LB2P3BX (D1, D0, CI, SP, CK, SD, PD, CON, CO, Q1, Q0);  //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, PD, CON;
output CO, Q1, Q0;
endmodule

module LB2P3DX (D1, D0, CI, SP, CK, SD, CD, CON, CO, Q1, Q0);  //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CD, CON;
output CO, Q1, Q0;
endmodule

module LB2P3IX (D1, D0, CI, SP, CK, SD, CD, CON, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CD, CON;
output CO, Q1, Q0;
endmodule

module LB2P3JX (D1, D0, CI, SP, CK, SD, PD, CON, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, PD, CON;
output CO, Q1, Q0;
endmodule

module LD2P3AX (D1, D0, CI, SP, CK, SD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD;
output CO, Q1, Q0;
endmodule

module LD2P3AY (D1, D0, CI, SP, CK, SD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD;
output CO, Q1, Q0;
endmodule

module LD2P3BX (D1, D0, CI, SP, CK, SD, PD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, PD;
output CO, Q1, Q0;
endmodule

module LD2P3DX (D1, D0, CI, SP, CK, SD, CD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CD;
output CO, Q1, Q0;
endmodule

module LD2P3IX (D1, D0, CI, SP, CK, SD, CD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CD;
output CO, Q1, Q0;
endmodule

module LD2P3JX (D1, D0, CI, SP, CK, SD, PD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, PD;
output CO, Q1, Q0;
endmodule

module LU2P3AX (D1, D0, CI, SP, CK, SD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD;
output CO, Q1, Q0;
endmodule

module LU2P3AY (D1, D0, CI, SP, CK, SD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD;
output CO, Q1, Q0;
endmodule

module LU2P3BX (D1, D0, CI, SP, CK, SD, PD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, PD;
output CO, Q1, Q0;
endmodule

module LU2P3DX (D1, D0, CI, SP, CK, SD, CD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CD;
output CO, Q1, Q0;
endmodule

module LU2P3IX (D1, D0, CI, SP, CK, SD, CD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, CD;
output CO, Q1, Q0;
endmodule

module LU2P3JX (D1, D0, CI, SP, CK, SD, PD, CO, Q1, Q0); //synthesis syn_black_box
  parameter GSR = "ENABLED";
input  D1, D0, CI, SP, CK, SD, PD;
output CO, Q1, Q0;
endmodule

module MULT2 (P1, P0, CO, A3, A2, A1, A0, B3, B2, B1, B0, CI); //synthesis syn_black_box
input  A3;
input  A2;
input  A1;
input  A0;
input  B3;
input  B2;
input  B1;
input  B0;
input  CI;
output P1; 
output P0; 
output CO; 
endmodule

module MUX161 (D15, D14, D13, D12, D11, D10, D9, D8, D7, D6, D5, D4, D3, D2, D1, D0, SD4, SD3, SD2, SD1, Z);  //synthesis syn_black_box
input D15;
input D14;
input D13;
input D12;
input D11;
input D10;
input D9;
input D8;
input D7;
input D6;
input D5;
input D4;
input D3;
input D2;
input D1;
input D0;
input SD4;
input SD3;
input SD2;
input SD1;
output Z;
endmodule

module MUX21 (D1, D0, SD, Z);  //synthesis syn_black_box

input D1;
input D0;
input SD;
output Z;
endmodule

module MUX321 (D31, D30, D29, D28, D27, D26, D25, D24, D23, D22, D21, D20, D19, D18, D17, D16, D15, D14, D13, D12, D11, D10, D9, D8, D7, D6, D5, D4, D3, D2, D1, D0, SD5, SD4, SD3, SD2, SD1, Z);  //synthesis syn_black_box
input D31;
input D30;
input D29;
input D28;
input D27;
input D26;
input D25;
input D24;
input D23;
input D22;
input D21;
input D20;
input D19;
input D18;
input D17;
input D16;
input D15;
input D14;
input D13;
input D12;
input D11;
input D10;
input D9;
input D8;
input D7;
input D6;
input D5;
input D4;
input D3;
input D2;
input D1;
input D0;
input SD5;
input SD4;
input SD3;
input SD2;
input SD1;
output Z;
endmodule

module MUX41 (D3, D2, D1, D0, SD2, SD1, Z);  //synthesis syn_black_box
input D3 ;
input D2 ;
input D1 ;
input D0 ;
input SD2 ;
input SD1 ;
output Z ;
endmodule

module MUX81 (D7, D6, D5, D4, D3, D2, D1, D0, SD3, SD2, SD1, Z);  //synthesis syn_black_box
input D7 ;
input D6 ;
input D5 ;
input D4 ;
input D3 ;
input D2 ;
input D1 ;
input D0 ;
input SD3 ;
input SD2 ;
input SD1 ;
output Z ;
endmodule

module ND2 (A, B, Z);  //synthesis syn_black_box
input  A ;
input  B ;
output Z ;
endmodule

module  ND3  (A, B, C, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
output Z ;
endmodule 

module  ND4  (A, B, C, D, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
input  D ;
output Z ;
endmodule 

module  ND5  (A, B, C, D, E, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
output Z ;
endmodule 

module NR2 (A, B, Z);  //synthesis syn_black_box
input  A ;
input  B ;
output Z ;
endmodule 

module NR3 (A, B, C, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
output Z ;
endmodule 

module NR4 (A, B, C, D, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
input  D ;
output Z ;
endmodule 

module NR5 (A, B, C, D, E, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
output Z ;
endmodule 

module OB (I, O);  //synthesis syn_black_box black_box_pad_pin="O"
input  I ;
output O ;
endmodule 

module OBCO (I, OT, OC);  //synthesis syn_black_box black_box_pad_pin="OT,OC"
input  I ;
output OT ;
output OC ;
endmodule 

module OBZ (I, T, O);  //synthesis syn_black_box black_box_pad_pin="O"
input I ;
input T ;
output O ;
endmodule 

module OBZPU (I, T, O);  //synthesis syn_black_box black_box_pad_pin="O"
input I ;
input T ;
output O ;
endmodule

module OFS1P3BX (D, SP, SCLK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input SCLK ;
input PD ;
output Q ;
endmodule

module OFS1P3DX (D, SP, SCLK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input SCLK ;
input CD ;
output Q ;
endmodule

module OFS1P3IX (D, SP, SCLK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input SCLK ;
input CD ;
output Q ;
endmodule

module OFS1P3JX (D, SP, SCLK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D ;
input SP ;
input SCLK ;
input PD ;
output Q ;
endmodule

module OLVDS (A, Z, ZN); //synthesis syn_black_box black_box_pad_pin="Z,ZN"
  input  A;
  output Z;
  output ZN;
endmodule

module OR2 (A, B, Z);  //synthesis syn_black_box
input  A ;
input  B ;
output Z ;
endmodule 

module OR3 (A, B, C, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
output Z ;
endmodule 

module OR4 (A, B, C, D, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
input  D ;
output Z ;
endmodule 

module OR5 (A, B, C, D, E, Z);  //synthesis syn_black_box
input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
output Z ;
endmodule 

module LUT4 (A, B, C, D, Z);  //synthesis syn_black_box

parameter  [15:0]init = 16'h0000 ;

input  A ;
input  B ;
input  C ;
input  D ;
output Z ;
endmodule

module LUT5 (Z, A, B, C, D, E);  //synthesis syn_black_box

parameter  [31:0]init = 32'h00000000 ;

input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
output Z ;
endmodule

module LUT6 (Z, A, B, C, D, E, F);  //synthesis syn_black_box

parameter  [63:0]init = 64'h0000000000000000 ;

input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
input  F ;
output Z ;
endmodule

module LUT7 (Z, A, B, C, D, E, F, G);  //synthesis syn_black_box

parameter  [127:0]init = 128'h00000000000000000000000000000000 ;

input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
input  F ;
input  G ;
output  Z ;
endmodule

module LUT8 (Z, A, B, C, D, E, F, G, H);  //synthesis syn_black_box

parameter  [255:0]init = 256'h0000000000000000000000000000000000000000000000000000000000000000;

input  A ;
input  B ;
input  C ;
input  D ;
input  E ;
input  F ;
input  G ;
input  H ;
output  Z ;
endmodule

module PFUMX (ALUT, BLUT, C0, Z);  //synthesis syn_black_box
input  ALUT ;
input  BLUT ;
input  C0 ;
output Z ;
endmodule

module PUR (PUR)/* synthesis syn_black_box syn_noprune=1 */;
  parameter RST_PULSE = 1;
  input PUR;
endmodule

module ROM128X1A ( AD6, AD5, AD4, AD3, AD2, AD1, AD0, DO0);  //synthesis syn_black_box

parameter [127:0] initval = 128'h00000000000000000000000000000000;

input AD6 ;
input AD5 ;
input AD4 ;
input AD3 ;
input AD2 ;
input AD1 ;
input AD0 ;
output DO0 ;
endmodule

module ROM16X1A ( AD3, AD2, AD1, AD0, DO0);  //synthesis syn_black_box

parameter [15:0] initval = 16'h0000;

input AD3 ;
input AD2 ;
input AD1 ;
input AD0 ;
output DO0 ;
endmodule

module ROM256X1A ( AD7, AD6, AD5, AD4, AD3, AD2, AD1, AD0, DO0);  //synthesis syn_black_box

parameter [255:0] initval = 256'h0000000000000000000000000000000000000000000000000000000000000000;

input AD7 ;
input AD6 ;
input AD5 ;
input AD4 ;
input AD3 ;
input AD2 ;
input AD1 ;
input AD0 ;
output DO0 ;
endmodule

module ROM32X1A ( AD4, AD3, AD2, AD1, AD0, DO0);  //synthesis syn_black_box

parameter [31:0] initval = 32'h00000000;

input AD4 ;
input AD3 ;
input AD2 ;
input AD1 ;
input AD0 ;
output DO0 ;
endmodule

module ROM64X1A ( AD5, AD4, AD3, AD2, AD1, AD0, DO0);  //synthesis syn_black_box

parameter [63:0] initval = 64'h0000000000000000;

input AD5 ;
input AD4 ;
input AD3 ;
input AD2 ;
input AD1 ;
input AD0 ;
output DO0 ;
endmodule

module CCU2D (
   CIN,
   A0, B0, C0, D0,
   A1, B1, C1, D1,
   S0, S1, COUT
);  //synthesis syn_black_box syn_unconnected_inputs  = "CIN"

input CIN;
input A0, B0, C0, D0;
input A1, B1, C1, D1;
output S0, S1, COUT;

parameter [15:0] INIT0 = 16'h0000;
parameter [15:0] INIT1 = 16'h0000;
parameter INJECT1_0 = "YES";
parameter INJECT1_1 = "YES";
endmodule

module VHI ( Z );  //synthesis syn_black_box
    output Z ;
endmodule 

module VLO ( Z );  //synthesis syn_black_box
    output Z ;
endmodule

module XNOR2 (A, B, Z);  //synthesis syn_black_box
  input  A ;
  input  B ;
  output Z;
endmodule 

module XNOR3 (A, B, C, Z);  //synthesis syn_black_box
  input  A ;
  input  B ;
  input  C ;
  output Z;
endmodule 

module XNOR4 (A, B, C, D, Z);  //synthesis syn_black_box
  input  A ;
  input  B ;
  input  C ;
  input  D ;
  output Z;
endmodule 

module XNOR5 (A, B, C, D, E, Z);  //synthesis syn_black_box
  input  A ;
  input  B ;
  input  C ;
  input  D ;
  input  E ;
  output Z;
endmodule 

module XOR11 ( A, B, C, D, E, F, G, H, I, J, K, Z);  //synthesis syn_black_box
  input  A ;
  input  B ;
  input  C ;
  input  D ;
  input  E ;
  input  F ;
  input  G ;
  input  H ;
  input  I ;
  input  J ;
  input  K ;
  output Z;
endmodule 

module XOR2 (A, B, Z);  //synthesis syn_black_box
input A ;
input B ;
output Z;
endmodule 

module XOR21 ( A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, Z); //synthesis syn_black_box 
  input  A ;
  input  B ;
  input  C ;
  input  D ;
  input  E ;
  input  F ;
  input  G ;
  input  H ;
  input  I ;
  input  J ;
  input  K ;
  input  L ;
  input  M ;
  input  N ;
  input  O ; 
  input  P ; 
  input  Q ; 
  input  R ; 
  input  S ; 
  input  T ; 
  input  U ; 
  output Z ;
endmodule 

module XOR3 (A, B, C, Z);  //synthesis syn_black_box
input A ;
input B ;
input C ;
output Z;
endmodule 

module XOR4 (A, B, C, D, Z);  //synthesis syn_black_box
input A ;
input B ;
input C ;
input D ;
output Z;
endmodule 

module XOR5 (A, B, C, D, E, Z);  //synthesis syn_black_box
input A ;
input B ;
input C ;
input D ;
input E ;
output Z;
endmodule 

module IFS1S1B (D, SCLK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SCLK;
input PD;
output Q;
endmodule

module IFS1S1D (D, SCLK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SCLK;
input CD;
output Q;
endmodule

module IFS1S1I (D, SCLK, CD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SCLK;
input CD;
output Q;
endmodule

module IFS1S1J (D, SCLK, PD, Q);  //synthesis syn_black_box

  parameter GSR = "ENABLED";

input D;
input SCLK;
input PD;
output Q;
endmodule

module DPR16X4C ( DI3, DI2, DI1, DI0, WAD3, WAD2, WAD1, WAD0, WRE, WCK,
                 RAD3, RAD2, RAD1, RAD0, DO3, DO2, DO1, DO0); //synthesis syn_black_box

  input DI3,DI2,DI1,DI0, WAD3,WAD2,WAD1,WAD0,WCK,WRE;
  input RAD3,RAD2,RAD1,RAD0;
  output DO3, DO2, DO1, DO0;

  parameter initval = "0x0000000000000000";
endmodule

module SPR16X4C (DI3, DI2, DI1, DI0, AD3, AD2, AD1, AD0, WRE, CK,
                 DO3, DO2, DO1, DO0);  //synthesis syn_black_box

  input DI3,DI2,DI1,DI0,AD3,AD2,AD1,AD0,CK,WRE;
  output DO3,DO2,DO1,DO0;

  parameter initval = "0x0000000000000000";
endmodule

module SGSR (GSR, CLK)  /* synthesis syn_black_box syn_noprune=1 */;
input GSR, CLK;
endmodule

module DP8KC (DIA8, DIA7, DIA6, DIA5, DIA4, DIA3, DIA2, DIA1, DIA0,
         ADA12, ADA11, ADA10, ADA9, ADA8, ADA7, ADA6, ADA5,
         ADA4, ADA3, ADA2, ADA1, ADA0,
         CEA, OCEA, CLKA, WEA, CSA2, CSA1, CSA0, RSTA,
         DIB8, DIB7, DIB6, DIB5, DIB4, DIB3, DIB2, DIB1, DIB0,
         ADB12, ADB11, ADB10, ADB9, ADB8, ADB7, ADB6, ADB5,
         ADB4, ADB3, ADB2, ADB1, ADB0,
         CEB, OCEB, CLKB, WEB, CSB2, CSB1, CSB0, RSTB,
         DOA8, DOA7, DOA6, DOA5, DOA4, DOA3, DOA2, DOA1, DOA0,
         DOB8, DOB7, DOB6, DOB5, DOB4, DOB3, DOB2, DOB1, DOB0); //synthesis syn_black_box

   parameter  DATA_WIDTH_A = 9;            //1, 2, 4, 9
   parameter  DATA_WIDTH_B = 9;            //1, 2, 4, 9
   parameter  REGMODE_A = "NOREG";          // "NOREG", "OUTREG"
   parameter  REGMODE_B = "NOREG";          // "NOREG", "OUTREG"
   parameter  CSDECODE_A = "0b000";
   parameter  CSDECODE_B = "0b000";
   parameter  WRITEMODE_A = "NORMAL";       // "NORMAL", "READBEFOREWRITE", "WRITETHROUGH"
   parameter  WRITEMODE_B = "NORMAL";       // "NORMAL", "READBEFOREWRITE", "WRITETHROUGH"
   parameter  GSR = "ENABLED";             // 
   parameter  RESETMODE = "SYNC";
   parameter  ASYNC_RESET_RELEASE = "SYNC";
   parameter  INIT_DATA = "STATIC";

parameter INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";

input    DIA8, DIA7, DIA6, DIA5, DIA4, DIA3, DIA2, DIA1, DIA0,
         ADA12, ADA11, ADA10, ADA9, ADA8, ADA7, ADA6, ADA5,
         ADA4,  ADA3,  ADA2, ADA1, ADA0,
         CEA, OCEA, CLKA, WEA, CSA2, CSA1, CSA0, RSTA,
         DIB8, DIB7, DIB6, DIB5, DIB4, DIB3, DIB2, DIB1, DIB0,
         ADB12, ADB11, ADB10, ADB9, ADB8, ADB7, ADB6, ADB5,
         ADB4,  ADB3,  ADB2, ADB1, ADB0,
         CEB, OCEB, CLKB, WEB, CSB2, CSB1, CSB0, RSTB;
output   DOA8, DOA7, DOA6, DOA5, DOA4, DOA3, DOA2, DOA1, DOA0,
         DOB8, DOB7, DOB6, DOB5, DOB4, DOB3, DOB2, DOB1, DOB0;
endmodule

module PDPW8KC (DI17, DI16, DI15, DI14, DI13, DI12, DI11, DI10, DI9,
         DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0,
         ADW8, ADW7, ADW6, ADW5, ADW4, ADW3, ADW2, ADW1, ADW0,
         BE1, BE0,
         CEW, CLKW, CSW2, CSW1, CSW0,
         ADR12, ADR11, ADR10, ADR9, ADR8, ADR7, ADR6, ADR5,
         ADR4,  ADR3,  ADR2, ADR1, ADR0,
         CER, OCER, CLKR, CSR2, CSR1, CSR0, RST,
         DO17, DO16, DO15, DO14, DO13, DO12, DO11, DO10, DO9,
         DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0); //synthesis syn_black_box,
   parameter  DATA_WIDTH_W = 18;
   parameter  DATA_WIDTH_R = 9;
   parameter  REGMODE = "NOREG";
   parameter  CSDECODE_W = "0b000";
   parameter  CSDECODE_R = "0b000";
   parameter  GSR = "ENABLED";
   parameter  RESETMODE = "SYNC";
   parameter  ASYNC_RESET_RELEASE = "SYNC";
   parameter  INIT_DATA = "STATIC";

parameter INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";

input    DI17, DI16, DI15, DI14, DI13, DI12, DI11, DI10, DI9,
         DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0,
         ADW8, ADW7, ADW6, ADW5, ADW4, ADW3, ADW2, ADW1, ADW0,
         BE1, BE0,
         CEW, CLKW, CSW2, CSW1, CSW0,
         ADR12, ADR11, ADR10, ADR9, ADR8, ADR7, ADR6, ADR5,
         ADR4,  ADR3,  ADR2, ADR1, ADR0,
         CER, OCER, CLKR, CSR2, CSR1, CSR0, RST;

output   DO17, DO16, DO15, DO14, DO13, DO12, DO11, DO10, DO9,
         DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0;
endmodule

module SP8KC (DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0,
         AD12, AD11, AD10, AD9, AD8, AD7, AD6, AD5,
         AD4, AD3, AD2, AD1, AD0,
         CE, OCE, CLK, WE, CS2, CS1, CS0, RST,
         DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0);  //synthesis syn_black_box

   parameter  DATA_WIDTH = 9;
   parameter  REGMODE = "NOREG";
   parameter  CSDECODE = "0b000";
   parameter  WRITEMODE = "NORMAL";
   parameter  GSR = "ENABLED";
   parameter  RESETMODE = "SYNC";
   parameter  ASYNC_RESET_RELEASE = "SYNC";
   parameter  INIT_DATA = "STATIC";

parameter INITVAL_00 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_01 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_02 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_03 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_04 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_05 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_06 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_07 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_10 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_11 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_12 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_13 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_14 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_15 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_16 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_17 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";
parameter INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000";

input    DI8, DI7, DI6, DI5, DI4, DI3, DI2, DI1, DI0,
         AD12, AD11, AD10, AD9, AD8, AD7, AD6, AD5,
         AD4,  AD3,  AD2, AD1, AD0,
         CE, OCE, CLK, WE, CS2, CS1, CS0, RST;

output   DO8, DO7, DO6, DO5, DO4, DO3, DO2, DO1, DO0;
endmodule

module FIFO8KB (DI0, DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8,
         DI9, DI10, DI11, DI12, DI13, DI14, DI15, DI16, DI17,
         CSW0, CSW1, CSR0, CSR1, WE, RE, ORE, CLKW, CLKR, RST, RPRST, FULLI, EMPTYI,
         DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8,
         DO9, DO10, DO11, DO12, DO13, DO14, DO15, DO16, DO17,
         EF, AEF, AFF, FF);  //synthesis syn_black_box

   parameter  DATA_WIDTH_W = 18;
   parameter  DATA_WIDTH_R = 18;
   parameter  REGMODE = "NOREG";
   parameter  RESETMODE = "ASYNC";
   parameter  ASYNC_RESET_RELEASE = "SYNC";
   parameter  CSDECODE_W = "0b00";
   parameter  CSDECODE_R = "0b00";
   parameter  AEPOINTER    = "0b00000000000000";
   parameter  AEPOINTER1   = "0b00000000000000";
   parameter  AFPOINTER    = "0b00000000000000";
   parameter  AFPOINTER1   = "0b00000000000000";
   parameter  FULLPOINTER  = "0b00000000000000";
   parameter  FULLPOINTER1 = "0b00000000000000";
   parameter  GSR = "DISABLED";

input    DI0, DI1, DI2, DI3, DI4, DI5, DI6, DI7, DI8,
         DI9, DI10, DI11, DI12, DI13, DI14, DI15, DI16, DI17,
         CSW0, CSW1, CSR0, CSR1, WE, RE, ORE, CLKW, CLKR, RST, RPRST, FULLI, EMPTYI;
output   DO0, DO1, DO2, DO3, DO4, DO5, DO6, DO7, DO8,
         DO9, DO10, DO11, DO12, DO13, DO14, DO15, DO16, DO17,
         EF, AEF, AFF, FF;
endmodule

module CLKDIVC (
   input    RST, CLKI, ALIGNWD,
   output   CDIV1, CDIVX ); //synthesis syn_black_box

   parameter  GSR = "DISABLED";
   parameter  DIV = "2.0";
endmodule

module DCMA (
   input    CLK0, CLK1, SEL,
   output   DCMOUT ); //synthesis syn_black_box
endmodule

module ECLKSYNCA (
   input    ECLKI, STOP,
   output   ECLKO ); //synthesis syn_black_box
endmodule

module ECLKBRIDGECS (
   input    CLK0, CLK1, SEL,
   output   ECSOUT ); //synthesis syn_black_box
endmodule

module DCCA (
   input    CLKI, CE,
   output   CLKO ); //synthesis syn_black_box
endmodule

module JTAGF (
   input    TCK, TMS, TDI, JTDO1, JTDO2,
   output   TDO, JTCK, JTDI, JSHIFT, JUPDATE, JRSTN,
            JCE1, JCE2, JRTI1, JRTI2 ); //synthesis syn_black_box

   parameter  ER1 = "ENABLED";
   parameter  ER2 = "ENABLED";
endmodule

module START (
   input    STARTCLK ); //synthesis syn_black_box syn_noprune=1
endmodule

module SEDFA (
   input    SEDSTDBY, SEDENABLE, SEDSTART, SEDFRCERR,
   output   SEDERR, SEDDONE, SEDINPROG, SEDCLKOUT ); //synthesis syn_black_box

   parameter SED_CLK_FREQ = "3.5";
   parameter CHECKALWAYS = "DISABLED";
   parameter DEV_DENSITY = "1200L";
endmodule

module SEDFB (
   output   SEDERR, SEDDONE, SEDINPROG, SEDCLKOUT ); //synthesis syn_black_box
endmodule

module IDDRXE (
   input    D, SCLK, RST,
   output   Q0, Q1 ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module IDDRX2E (
   input    D, ECLK, SCLK, RST, ALIGNWD,
   output   Q0, Q1, Q2, Q3 ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module IDDRX4B (
   input    D, ECLK, SCLK, RST, ALIGNWD,
   output   Q0, Q1, Q2, Q3, Q4, Q5, Q6, Q7 ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module IDDRDQSX1A (
   input    D, DQSR90, DDRCLKPOL, SCLK, RST,
   output   Q0, Q1 ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module IDDRX71A (
   input    D, ECLK, SCLK, RST, ALIGNWD,
   output   Q0, Q1, Q2, Q3, Q4, Q5, Q6 ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module ODDRXE (
   input    D0, D1, SCLK, RST,
   output   Q ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module ODDRX2E (
   input    D0, D1, D2, D3, ECLK, SCLK, RST,
   output   Q ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module ODDRX4B (
   input    D0, D1, D2, D3, D4, D5, D6, D7, ECLK, SCLK, RST,
   output   Q ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module ODDRDQSX1A (
   input    DQSW90, SCLK, D0, D1, RST,
   output   Q ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module ODDRX71A (
   input    ECLK, SCLK, D0, D1, D2, D3, D4, D5, D6, RST,
   output   Q ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
endmodule

module TDDRA (
   input    DQSW90, SCLK, TD, RST,
   output   TQ ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
   parameter DQSW90_INVERT = "DISABLED";
endmodule

module DQSBUFH (
   input    SCLK, DQSI, READ, READCLKSEL1, READCLKSEL0, RST, DQSDEL,
   output   DDRCLKPOL, DQSR90, DQSW90, DATAVALID, BURSTDET ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
   parameter DQS_LI_DEL_ADJ  = "PLUS";
   parameter DQS_LI_DEL_VAL = 0;
   parameter DQS_LO_DEL_ADJ = "PLUS";
   parameter DQS_LO_DEL_VAL = 0;
   parameter LPDDR = "DISABLED";
endmodule

module DQSDLLC (
   input    CLK, RST, UDDCNTLN, FREEZE,
   output   LOCK, DQSDEL ); //synthesis syn_black_box

   parameter GSR = "ENABLED";
   parameter DEL_ADJ = "PLUS";
   parameter DEL_VAL = 0;
   parameter LOCK_SENSITIVITY = "LOW";
   parameter FIN = "100.0";
   parameter FORCE_MAX_DELAY = "NO";
endmodule

module DELAYE (
   input    A,
   output   Z ); //synthesis syn_black_box

   parameter DEL_MODE = "USER_DEFINED";
   parameter DEL_VALUE = "DELAY0";
endmodule

module DELAYD (
   input    A, DEL4, DEL3, DEL2, DEL1, DEL0,
   output   Z ); //synthesis syn_black_box
endmodule

module DLLDELC (
   input    CLKI, DQSDEL,
   output   CLKO ); //synthesis syn_black_box

   parameter DEL_ADJ  = "PLUS";
   parameter DEL_VAL = 0;
endmodule

module CLKFBBUFA (
   input    A,
   output   Z ); //synthesis syn_black_box
endmodule

module PCNTR (
   input    CLK, USERTIMEOUT, USERSTDBY, CLRFLAG, CFGWAKE, CFGSTDBY,
   output   STDBY, STOP, SFLAG ); //synthesis syn_black_box

   parameter STDBYOPT = "USER_CFG";
   parameter TIMEOUT = "BYPASS";
   parameter WAKEUP = "USER";
   parameter POROFF = "FALSE";
   parameter BGOFF = "FALSE";
endmodule

module BCINRD (
   input    INRDENI ); //synthesis syn_black_box syn_noprune=1

   parameter BANKID = 0;
endmodule

module BCLVDSO (
   input    LVDSENI ); //synthesis syn_black_box syn_noprune=1
endmodule

module INRDB (
   input    D, E,
   output   Q ); //synthesis syn_black_box
endmodule

module LVDSOB (
   input    D, E,
   output   Q ); //synthesis syn_black_box
endmodule

module PG (
   input    D, E,
   output   Q ); //synthesis syn_black_box
endmodule

module EHXPLLJ (
   input    CLKI, CLKFB, PHASESEL1, PHASESEL0, PHASEDIR, PHASESTEP, 
            LOADREG, STDBY, PLLWAKESYNC, RST, RESETM, RESETC, RESETD, 
            ENCLKOP, ENCLKOS, ENCLKOS2, ENCLKOS3, PLLCLK, PLLRST, PLLSTB, PLLWE, 
            PLLDATI7, PLLDATI6, PLLDATI5, PLLDATI4, PLLDATI3, PLLDATI2, PLLDATI1, PLLDATI0, 
            PLLADDR4, PLLADDR3, PLLADDR2, PLLADDR1, PLLADDR0,
   output   CLKOP, CLKOS, CLKOS2, CLKOS3, LOCK, INTLOCK, REFCLK, 
            PLLDATO7, PLLDATO6, PLLDATO5, PLLDATO4, PLLDATO3, PLLDATO2, PLLDATO1, PLLDATO0, PLLACK, 
            DPHSRC, CLKINTFB ); //synthesis syn_black_box

   parameter CLKI_DIV = 1;
   parameter CLKFB_DIV = 1;
   parameter CLKOP_DIV = 8;
   parameter CLKOS_DIV = 8;
   parameter CLKOS2_DIV = 8;
   parameter CLKOS3_DIV = 8;
   parameter CLKOP_ENABLE = "ENABLED";
   parameter CLKOS_ENABLE = "ENABLED";
   parameter CLKOS2_ENABLE = "ENABLED";
   parameter CLKOS3_ENABLE = "ENABLED";
   parameter VCO_BYPASS_A0 = "DISABLED";
   parameter VCO_BYPASS_B0 = "DISABLED";
   parameter VCO_BYPASS_C0 = "DISABLED";
   parameter VCO_BYPASS_D0 = "DISABLED";
   parameter CLKOP_CPHASE = 0;
   parameter CLKOS_CPHASE = 0;
   parameter CLKOS2_CPHASE = 0;
   parameter CLKOS3_CPHASE = 0;
   parameter CLKOP_FPHASE = 0;
   parameter CLKOS_FPHASE = 0;
   parameter CLKOS2_FPHASE = 0;
   parameter CLKOS3_FPHASE = 0;
   parameter FEEDBK_PATH = "CLKOP";
   parameter FRACN_ENABLE = "DISABLED";
   parameter FRACN_DIV = 0;
   parameter CLKOP_TRIM_POL = "RISING";
   parameter CLKOP_TRIM_DELAY = 0;
   parameter CLKOS_TRIM_POL = "RISING";
   parameter CLKOS_TRIM_DELAY = 0;
   parameter PLL_USE_WB = "DISABLED";
   parameter PREDIVIDER_MUXA1 = 0;
   parameter PREDIVIDER_MUXB1 = 0;
   parameter PREDIVIDER_MUXC1 = 0;
   parameter PREDIVIDER_MUXD1 = 0;
   parameter OUTDIVIDER_MUXA2 = "DIVA";
   parameter OUTDIVIDER_MUXB2 = "DIVB";
   parameter OUTDIVIDER_MUXC2 = "DIVC";
   parameter OUTDIVIDER_MUXD2 = "DIVD";
   parameter PLL_LOCK_MODE = 0;
   parameter STDBY_ENABLE = "DISABLED";
   parameter DPHASE_SOURCE = "DISABLED";
   parameter PLLRST_ENA = "DISABLED";
   parameter MRST_ENA = "DISABLED";
   parameter DCRST_ENA = "DISABLED";
   parameter DDRST_ENA = "DISABLED";
   parameter INTFB_WAKE = "DISABLED";
endmodule

module PLLREFCS (
   input   CLK0, CLK1, SEL,
   output   PLLCSOUT ); //synthesis syn_black_box
endmodule

module OSCH (
   input    STDBY,
   output   OSC, SEDSTDBY ); //synthesis syn_black_box

   parameter NOM_FREQ = "2.08";
endmodule

module EFB (
   input  WBCLKI, WBRSTI, WBCYCI, WBSTBI, WBWEI,
          WBADRI7, WBADRI6, WBADRI5, WBADRI4, WBADRI3, WBADRI2, WBADRI1, WBADRI0,
          WBDATI7, WBDATI6, WBDATI5, WBDATI4, WBDATI3, WBDATI2, WBDATI1, WBDATI0,
          PLL0DATI7, PLL0DATI6, PLL0DATI5, PLL0DATI4, PLL0DATI3, PLL0DATI2, PLL0DATI1, PLL0DATI0, PLL0ACKI,
          PLL1DATI7, PLL1DATI6, PLL1DATI5, PLL1DATI4, PLL1DATI3, PLL1DATI2, PLL1DATI1, PLL1DATI0, PLL1ACKI,
          I2C1SCLI, I2C1SDAI, I2C2SCLI, I2C2SDAI,
          SPISCKI, SPIMISOI, SPIMOSII, SPISCSN,
          TCCLKI, TCRSTN, TCIC, UFMSN,
   output WBDATO7, WBDATO6, WBDATO5, WBDATO4, WBDATO3, WBDATO2, WBDATO1, WBDATO0, WBACKO,
          PLLCLKO, PLLRSTO, PLL0STBO, PLL1STBO, PLLWEO,
          PLLADRO4, PLLADRO3, PLLADRO2, PLLADRO1, PLLADRO0,
          PLLDATO7, PLLDATO6, PLLDATO5, PLLDATO4, PLLDATO3, PLLDATO2, PLLDATO1, PLLDATO0,
          I2C1SCLO, I2C1SCLOEN, I2C1SDAO, I2C1SDAOEN, I2C2SCLO, I2C2SCLOEN, I2C2SDAO, I2C2SDAOEN, I2C1IRQO, I2C2IRQO,
          SPISCKO, SPISCKEN, SPIMISOO, SPIMISOEN, SPIMOSIO, SPIMOSIEN,
          SPIMCSN0, SPIMCSN1, SPIMCSN2, SPIMCSN3, SPIMCSN4, SPIMCSN5, SPIMCSN6, SPIMCSN7, SPICSNEN, SPIIRQO,
          TCINT, TCOC, WBCUFMIRQ, CFGWAKE, CFGSTDBY ); //synthesis syn_black_box

   parameter EFB_I2C1= "DISABLED";
   parameter EFB_I2C2= "DISABLED";
   parameter EFB_SPI = "DISABLED";
   parameter EFB_TC = "DISABLED";
   parameter EFB_TC_PORTMODE = "NO_WB";
   parameter EFB_UFM = "DISABLED";
   parameter EFB_WB_CLK_FREQ = "50.0";

   parameter DEV_DENSITY = "1200L";
   parameter UFM_INIT_PAGES = 0;
   parameter UFM_INIT_START_PAGE = 0;
   parameter UFM_INIT_ALL_ZEROS = "ENABLED";
   parameter UFM_INIT_FILE_NAME = "NONE";
   parameter UFM_INIT_FILE_FORMAT = "HEX";

   parameter I2C1_ADDRESSING = "7BIT";
   parameter I2C2_ADDRESSING = "7BIT";
   parameter I2C1_SLAVE_ADDR = "0b1000001";
   parameter I2C2_SLAVE_ADDR = "0b1000010";
   parameter I2C1_BUS_PERF = "100kHz";
   parameter I2C2_BUS_PERF = "100kHz";
   parameter I2C1_CLK_DIVIDER = 1;
   parameter I2C2_CLK_DIVIDER = 1;
   parameter I2C1_GEN_CALL = "DISABLED";
   parameter I2C2_GEN_CALL = "DISABLED";
   parameter I2C1_WAKEUP = "DISABLED";
   parameter I2C2_WAKEUP = "DISABLED";

   parameter SPI_MODE = "SLAVE";
   parameter SPI_CLK_DIVIDER = 1;
   parameter SPI_LSB_FIRST = "DISABLED";
   parameter SPI_CLK_INV = "DISABLED";
   parameter SPI_PHASE_ADJ = "DISABLED";
   parameter SPI_SLAVE_HANDSHAKE = "DISABLED";
   parameter SPI_INTR_TXRDY = "DISABLED";
   parameter SPI_INTR_RXRDY = "DISABLED";
   parameter SPI_INTR_TXOVR = "DISABLED";
   parameter SPI_INTR_RXOVR = "DISABLED";
   parameter SPI_WAKEUP = "DISABLED";

   parameter TC_MODE = "CTCM";
   parameter TC_SCLK_SEL = "PCLOCK";
   parameter TC_CCLK_SEL = 1;
   parameter GSR = "ENABLED";
   parameter TC_TOP_SET = 65535;
   parameter TC_OCR_SET = 32767;
   parameter TC_OC_MODE = "TOGGLE";
   parameter TC_RESETN = "ENABLED";
   parameter TC_TOP_SEL = "ON";
   parameter TC_OV_INT = "OFF";
   parameter TC_OCR_INT = "OFF";
   parameter TC_ICR_INT = "OFF";
   parameter TC_OVERFLOW = "ENABLED";
   parameter TC_ICAPTURE = "DISABLED";
endmodule

module TSALL (
   input TSALL ); //synthesis syn_black_box syn_noprune=1
endmodule

