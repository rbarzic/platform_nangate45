// 
// ******************************************************************************
// *                                                                            *
// *                   Copyright (C) 2004-2010, Nangate Inc.                    *
// *                           All rights reserved.                             *
// *                                                                            *
// * Nangate and the Nangate logo are trademarks of Nangate Inc.                *
// *                                                                            *
// * All trademarks, logos, software marks, and trade names (collectively the   *
// * "Marks") in this program are proprietary to Nangate or other respective    *
// * owners that have granted Nangate the right and license to use such Marks.  *
// * You are not permitted to use the Marks without the prior written consent   *
// * of Nangate or such third party that may own the Marks.                     *
// *                                                                            *
// * This file has been provided pursuant to a License Agreement containing     *
// * restrictions on its use. This file contains valuable trade secrets and     *
// * proprietary information of Nangate Inc., and is protected by U.S. and      *
// * international laws and/or treaties.                                        *
// *                                                                            *
// * The copyright notice(s) in this file does not indicate actual or intended  *
// * publication of this file.                                                  *
// *                                                                            *
// *      NGLibraryCharacterizer, Development_version - build 201012062042      *
// *                                                                            *
// ******************************************************************************
// 
// * Default delays
//   * comb. path delay        : 0.1
//   * seq. path delay         : 0.1
//   * delay cells             : 0.1
//   * timing checks           : 0.1
// 
// * NTC Setup
//   * Export NTC sections     : true
//   * Combine setup / hold    : true
//   * Combine recovery/removal: true
// 
// * Extras
//   * Export `celldefine      : false
//   * Export `timescale       : -
// 


module CLKBUF_X2 (A, Z);
  input A;
  output Z;

  buf(Z, A);

 `ifndef NO_SPECIFY
  specify
    (A => Z) = (0.1, 0.1);
 endspecify
`endif

endmodule



primitive \seq_CLKGATETST_X2  (IQ, nextstate, CK, NOTIFIER);
  output IQ;
  input nextstate;
  input CK;
  input NOTIFIER;
  reg IQ;

  table
// nextstate          CK    NOTIFIER     : @IQ :          IQ
           0           0           ?       : ? :           0;
           1           0           ?       : ? :           1;
           *           ?           ?       : ? :           -; // Ignore all edges on nextstate
           ?           1           ?       : ? :           -; // Ignore non-triggering clock edge
           ?           ?           *       : ? :           x; // Any NOTIFIER change
  endtable
endprimitive

module CLKGATETST_X2 (CK, E, SE, GCK);
  input CK;
  input E;
  input SE;
  output GCK;
  reg NOTIFIER;

   wire IQ,IQn;
   wire nextstate;
   
   
  `ifdef NTC
    and(GCK, IQ, CK_d);
    \seq_CLKGATETST_X2 (IQ, nextstate, CK_d, NOTIFIER);
    not(IQn, IQ);
    or(nextstate, E_d, SE_d);

  `else
    and(GCK, IQ, CK);
    \seq_CLKGATETST_X2 (IQ, nextstate, CK, NOTIFIER);
    not(IQn, IQ);
    or(nextstate, E, SE);

  `endif

 `ifndef NO_SPECIFY
  specify
    if((E == 1'b0) && (SE == 1'b0)) (negedge CK => (GCK +: 1'b0)) = (0.1, 0.1);
    if((E == 1'b0) && (SE == 1'b1)) (CK => GCK) = (0.1, 0.1);
    if((E == 1'b1) && (SE == 1'b0)) (CK => GCK) = (0.1, 0.1);
    if((E == 1'b1) && (SE == 1'b1)) (CK => GCK) = (0.1, 0.1);
    `ifdef NTC
      $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER, , ,CK_d, E_d);
      $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER, , ,CK_d, SE_d);
      $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER, , ,CK_d, E_d);
      $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER, , ,CK_d, SE_d);
      $width(negedge CK, 0.1, 0, NOTIFIER);
    `else
      $setuphold(posedge CK, negedge E, 0.1, 0.1, NOTIFIER);
      $setuphold(posedge CK, negedge SE, 0.1, 0.1, NOTIFIER);
      $setuphold(posedge CK, posedge E, 0.1, 0.1, NOTIFIER);
      $setuphold(posedge CK, posedge SE, 0.1, 0.1, NOTIFIER);
      $width(negedge CK, 0.1, 0, NOTIFIER);
    `endif
 endspecify
`endif

endmodule







//
// End of file
//
