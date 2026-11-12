/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : W-2024.09-SP2
// Date      : Thu Nov  5 13:16:06 2026
/////////////////////////////////////////////////////////////


module spi_master ( clk, reset_n, tx_word, start_transaction, rx_word, 
        transaction_done, ready, cs_n, sck, mosi, miso );
  input [15:0] tx_word;
  output [15:0] rx_word;
  input clk, reset_n, start_transaction, miso;
  output transaction_done, ready, cs_n, sck, mosi;
  wire   reg_in_start_transaction, N63, N67, N86, N121, N122, N123, N130, N131,
         N132, N133, n1, n18, n19, n21, n38, n40, n41, n45, n46, n48, n50, n51,
         n53, n54, n57, n58, n62, n63, n64, n65, n66, n67, n68, n69, n70, n71,
         n72, n73, n74, n75, n76, n77, n78, n79, n80, n81, n82, n83, n84, n85,
         n86, n87, n89, n90, n91, n92, n93, n94, n95, n96, n97, n98, n99, n100,
         n101, n102, n103, n104, n105, n106, n107, n108, n109, n110, n111,
         n112, n113, n114, n115, n116, n117, n118, n119, n120, n121, n122,
         n123, n124, n125, n126, n127, n128, n129, n130, n131, n132, n133,
         n134, n135, n136, n137, n138, n139, n141, n142, n143, n144, n145,
         n146, n147, n148, n149, n150, n151, n152, n153, n154, n155, n156,
         n157, n158, n159, n160, n161, n162, n163, n164, n165, n166, n167,
         n168, n169, n170, n171, n172, n173, n174, n175, n176, n177, n178,
         n179, n180, n181, n182, n183, n184, n185, n186, n187, n188, n189,
         n190, n191, n192, n193, n194, n195, n196, n197, n198, n199, n200,
         n201, n202, n203, n204;
  wire   [2:0] reg_fsm;
  wire   [4:0] reg_half_counter;
  wire   [2:0] reg_tic_counter;

  FD2 reg_in_miso_reg ( .D(miso), .CP(clk), .CD(reset_n), .QN(n106) );
  FD2 reg_in_start_transaction_reg ( .D(start_transaction), .CP(clk), .CD(
        reset_n), .Q(reg_in_start_transaction) );
  FD2 \reg_in_tx_word_reg[15]  ( .D(tx_word[15]), .CP(clk), .CD(reset_n), .QN(
        n91) );
  FD2 \reg_in_tx_word_reg[14]  ( .D(tx_word[14]), .CP(clk), .CD(reset_n), .QN(
        n92) );
  FD2 \reg_in_tx_word_reg[13]  ( .D(tx_word[13]), .CP(clk), .CD(reset_n), .QN(
        n93) );
  FD2 \reg_in_tx_word_reg[12]  ( .D(tx_word[12]), .CP(clk), .CD(reset_n), .QN(
        n94) );
  FD2 \reg_in_tx_word_reg[11]  ( .D(tx_word[11]), .CP(clk), .CD(reset_n), .QN(
        n95) );
  FD2 \reg_in_tx_word_reg[10]  ( .D(tx_word[10]), .CP(clk), .CD(reset_n), .QN(
        n96) );
  FD2 \reg_in_tx_word_reg[9]  ( .D(tx_word[9]), .CP(clk), .CD(reset_n), .QN(
        n97) );
  FD2 \reg_in_tx_word_reg[8]  ( .D(tx_word[8]), .CP(clk), .CD(reset_n), .QN(
        n98) );
  FD2 \reg_in_tx_word_reg[7]  ( .D(tx_word[7]), .CP(clk), .CD(reset_n), .QN(
        n99) );
  FD2 \reg_in_tx_word_reg[6]  ( .D(tx_word[6]), .CP(clk), .CD(reset_n), .QN(
        n100) );
  FD2 \reg_in_tx_word_reg[5]  ( .D(tx_word[5]), .CP(clk), .CD(reset_n), .QN(
        n101) );
  FD2 \reg_in_tx_word_reg[4]  ( .D(tx_word[4]), .CP(clk), .CD(reset_n), .QN(
        n102) );
  FD2 \reg_in_tx_word_reg[3]  ( .D(tx_word[3]), .CP(clk), .CD(reset_n), .QN(
        n103) );
  FD2 \reg_in_tx_word_reg[2]  ( .D(tx_word[2]), .CP(clk), .CD(reset_n), .QN(
        n104) );
  FD2 \reg_in_tx_word_reg[1]  ( .D(tx_word[1]), .CP(clk), .CD(reset_n), .QN(
        n105) );
  FD2 \reg_in_tx_word_reg[0]  ( .D(tx_word[0]), .CP(clk), .CD(reset_n), .QN(
        n90) );
  FD2 \reg_half_counter_reg[0]  ( .D(n150), .CP(clk), .CD(reset_n), .Q(
        reg_half_counter[0]), .QN(n181) );
  FD2 \reg_fsm_reg[0]  ( .D(n148), .CP(clk), .CD(reset_n), .Q(reg_fsm[0]), 
        .QN(n154) );
  FD2 \reg_fsm_reg[2]  ( .D(n149), .CP(clk), .CD(reset_n), .Q(reg_fsm[2]), 
        .QN(n171) );
  FD2 \reg_fsm_reg[1]  ( .D(n147), .CP(clk), .CD(reset_n), .Q(reg_fsm[1]), 
        .QN(n194) );
  FD2 \reg_tx_word_reg[0]  ( .D(n139), .CP(clk), .CD(reset_n), .QN(n180) );
  FD2 \reg_tx_word_reg[15]  ( .D(n138), .CP(clk), .CD(reset_n), .QN(n179) );
  FD2 \reg_tx_word_reg[14]  ( .D(n137), .CP(clk), .CD(reset_n), .QN(n178) );
  FD2 \reg_tx_word_reg[13]  ( .D(n136), .CP(clk), .CD(reset_n), .QN(n162) );
  FD2 \reg_tx_word_reg[12]  ( .D(n135), .CP(clk), .CD(reset_n), .QN(n161) );
  FD2 \reg_tx_word_reg[11]  ( .D(n134), .CP(clk), .CD(reset_n), .QN(n177) );
  FD2 \reg_tx_word_reg[10]  ( .D(n133), .CP(clk), .CD(reset_n), .QN(n176) );
  FD2 \reg_tx_word_reg[9]  ( .D(n132), .CP(clk), .CD(reset_n), .QN(n160) );
  FD2 \reg_tx_word_reg[8]  ( .D(n131), .CP(clk), .CD(reset_n), .QN(n159) );
  FD2 \reg_tx_word_reg[7]  ( .D(n130), .CP(clk), .CD(reset_n), .QN(n175) );
  FD2 \reg_tx_word_reg[6]  ( .D(n129), .CP(clk), .CD(reset_n), .QN(n174) );
  FD2 \reg_tx_word_reg[5]  ( .D(n128), .CP(clk), .CD(reset_n), .QN(n158) );
  FD2 \reg_tx_word_reg[4]  ( .D(n127), .CP(clk), .CD(reset_n), .QN(n157) );
  FD2 \reg_tx_word_reg[3]  ( .D(n126), .CP(clk), .CD(reset_n), .QN(n156) );
  FD2 \reg_tx_word_reg[2]  ( .D(n125), .CP(clk), .CD(reset_n), .QN(n173) );
  FD2 \reg_tx_word_reg[1]  ( .D(n124), .CP(clk), .CD(reset_n), .QN(n155) );
  FD4 reg_out_ready_reg ( .D(n146), .CP(clk), .SD(reset_n), .Q(ready), .QN(
        n182) );
  FD2 reg_out_transaction_done_reg ( .D(n201), .CP(clk), .CD(reset_n), .Q(
        transaction_done) );
  FD4 reg_out_cs_n_reg ( .D(N63), .CP(clk), .SD(reset_n), .Q(cs_n) );
  FD2 \reg_tic_counter_reg[0]  ( .D(N121), .CP(clk), .CD(reset_n), .Q(
        reg_tic_counter[0]) );
  FD2 \reg_tic_counter_reg[1]  ( .D(N122), .CP(clk), .CD(reset_n), .Q(
        reg_tic_counter[1]), .QN(n183) );
  FD2 \reg_half_counter_reg[1]  ( .D(n145), .CP(clk), .CD(reset_n), .Q(
        reg_half_counter[1]), .QN(n153) );
  FD2 \reg_half_counter_reg[2]  ( .D(n144), .CP(clk), .CD(reset_n), .Q(
        reg_half_counter[2]), .QN(n170) );
  FD2 \reg_half_counter_reg[4]  ( .D(n142), .CP(clk), .CD(reset_n), .Q(
        reg_half_counter[4]), .QN(n184) );
  FD2 reg_out_mosi_reg ( .D(N86), .CP(clk), .CD(reset_n), .Q(mosi) );
  FD2 \reg_tic_counter_reg[2]  ( .D(N123), .CP(clk), .CD(reset_n), .QN(n141)
         );
  FD2 \reg_out_rx_word_reg[0]  ( .D(n123), .CP(clk), .CD(reset_n), .Q(
        rx_word[0]), .QN(n192) );
  FD2 \reg_out_rx_word_reg[1]  ( .D(n122), .CP(clk), .CD(reset_n), .Q(
        rx_word[1]), .QN(n169) );
  FD2 \reg_out_rx_word_reg[2]  ( .D(n121), .CP(clk), .CD(reset_n), .Q(
        rx_word[2]), .QN(n190) );
  FD2 \reg_out_rx_word_reg[3]  ( .D(n120), .CP(clk), .CD(reset_n), .Q(
        rx_word[3]), .QN(n168) );
  FD2 \reg_out_rx_word_reg[4]  ( .D(n119), .CP(clk), .CD(reset_n), .Q(
        rx_word[4]), .QN(n189) );
  FD2 \reg_out_rx_word_reg[5]  ( .D(n118), .CP(clk), .CD(reset_n), .Q(
        rx_word[5]), .QN(n167) );
  FD2 \reg_out_rx_word_reg[6]  ( .D(n117), .CP(clk), .CD(reset_n), .Q(
        rx_word[6]), .QN(n188) );
  FD2 \reg_out_rx_word_reg[7]  ( .D(n116), .CP(clk), .CD(reset_n), .Q(
        rx_word[7]), .QN(n166) );
  FD2 \reg_out_rx_word_reg[8]  ( .D(n115), .CP(clk), .CD(reset_n), .Q(
        rx_word[8]), .QN(n187) );
  FD2 \reg_out_rx_word_reg[9]  ( .D(n114), .CP(clk), .CD(reset_n), .Q(
        rx_word[9]), .QN(n165) );
  FD2 \reg_out_rx_word_reg[10]  ( .D(n113), .CP(clk), .CD(reset_n), .Q(
        rx_word[10]), .QN(n186) );
  FD2 \reg_out_rx_word_reg[11]  ( .D(n112), .CP(clk), .CD(reset_n), .Q(
        rx_word[11]), .QN(n164) );
  FD2 \reg_out_rx_word_reg[12]  ( .D(n111), .CP(clk), .CD(reset_n), .Q(
        rx_word[12]), .QN(n185) );
  FD2 \reg_out_rx_word_reg[13]  ( .D(n110), .CP(clk), .CD(reset_n), .Q(
        rx_word[13]), .QN(n163) );
  FD2 \reg_out_rx_word_reg[14]  ( .D(n109), .CP(clk), .CD(reset_n), .Q(
        rx_word[14]), .QN(n191) );
  FD2 \reg_out_rx_word_reg[15]  ( .D(n108), .CP(clk), .CD(reset_n), .Q(
        rx_word[15]), .QN(n107) );
  FD2 reg_out_sck_reg ( .D(N67), .CP(clk), .CD(reset_n), .Q(sck) );
  OR3 U70 ( .A(n54), .B(reg_fsm[2]), .C(n154), .Z(n51) );
  AN3 U123 ( .A(n154), .B(n171), .C(reg_fsm[1]), .Z(n19) );
  OR2 U125 ( .A(n50), .B(n48), .Z(N63) );
  OR3 U137 ( .A(reg_tic_counter[1]), .B(reg_tic_counter[0]), .C(n141), .Z(n62)
         );
  NR2I U36 ( .A(reg_tic_counter[1]), .B(reg_tic_counter[0]), .Z(n18) );
  EOI U58 ( .A(ready), .B(n45), .Z(n146) );
  ND2I U63 ( .A(reg_fsm[0]), .B(n50), .Z(n46) );
  ND2I U65 ( .A(n54), .B(reg_fsm[1]), .Z(n53) );
  EOI U66 ( .A(n154), .B(n54), .Z(n148) );
  ND2I U68 ( .A(n54), .B(reg_fsm[2]), .Z(n57) );
  ND2I U69 ( .A(n50), .B(n154), .Z(n38) );
  AO1P U71 ( .A(n48), .B(reg_in_start_transaction), .C(n58), .D(n50), .Z(n54)
         );
  NR4P U75 ( .A(n203), .B(n181), .C(n62), .D(n63), .Z(n58) );
  NR2I U81 ( .A(n69), .B(n202), .Z(N86) );
  NR2I U84 ( .A(n74), .B(n75), .Z(n73) );
  NR2I U91 ( .A(n78), .B(n79), .Z(n72) );
  NR2I U100 ( .A(n82), .B(n83), .Z(n81) );
  NR2I U108 ( .A(n84), .B(n85), .Z(n80) );
  ND2I U110 ( .A(reg_half_counter[2]), .B(reg_half_counter[1]), .Z(n66) );
  ND2I U112 ( .A(n153), .B(n170), .Z(n67) );
  ND2I U115 ( .A(reg_half_counter[1]), .B(n170), .Z(n77) );
  ND2I U118 ( .A(reg_half_counter[2]), .B(n153), .Z(n76) );
  NR2I U121 ( .A(reg_half_counter[0]), .B(n202), .Z(N67) );
  NR2I U126 ( .A(n171), .B(reg_fsm[1]), .Z(n50) );
  NR2I U132 ( .A(n89), .B(n40), .Z(N122) );
  EOI U133 ( .A(reg_tic_counter[0]), .B(n183), .Z(n89) );
  NR2I U135 ( .A(n40), .B(reg_tic_counter[0]), .Z(N121) );
  ND2I U136 ( .A(n68), .B(n62), .Z(n40) );
  NR2I U138 ( .A(reg_fsm[2]), .B(n48), .Z(n68) );
  NR2I U139 ( .A(reg_fsm[0]), .B(reg_fsm[1]), .Z(n48) );
  FD2 \reg_half_counter_reg[3]  ( .D(n143), .CP(clk), .CD(reset_n), .Q(
        reg_half_counter[3]), .QN(n200) );
  AO7 U140 ( .A(n200), .B(n66), .C(reg_half_counter[4]), .Z(n65) );
  OR2P U141 ( .A(n62), .B(n181), .Z(n172) );
  AN3 U142 ( .A(n193), .B(n40), .C(n68), .Z(n41) );
  OR3 U143 ( .A(n63), .B(n203), .C(n172), .Z(n193) );
  AO3 U144 ( .A(reg_fsm[0]), .B(reg_half_counter[4]), .C(n64), .D(n65), .Z(n63) );
  EON1 U145 ( .A(n181), .B(n40), .C(n181), .D(n41), .Z(n150) );
  AO4 U146 ( .A(n195), .B(n163), .C(n151), .D(n191), .Z(n109) );
  AO4 U147 ( .A(n195), .B(n185), .C(n151), .D(n163), .Z(n110) );
  AO4 U148 ( .A(n195), .B(n164), .C(n151), .D(n185), .Z(n111) );
  AO4 U149 ( .A(n195), .B(n186), .C(n151), .D(n164), .Z(n112) );
  AO4 U150 ( .A(n195), .B(n165), .C(n151), .D(n186), .Z(n113) );
  AO4 U151 ( .A(n195), .B(n187), .C(n151), .D(n165), .Z(n114) );
  AO4 U152 ( .A(n195), .B(n166), .C(n151), .D(n187), .Z(n115) );
  AO4 U153 ( .A(n195), .B(n188), .C(n151), .D(n166), .Z(n116) );
  AO4 U154 ( .A(n195), .B(n167), .C(n151), .D(n188), .Z(n117) );
  AO4 U155 ( .A(n195), .B(n189), .C(n151), .D(n167), .Z(n118) );
  AO4 U156 ( .A(n195), .B(n168), .C(n151), .D(n189), .Z(n119) );
  AO4 U157 ( .A(n195), .B(n190), .C(n151), .D(n168), .Z(n120) );
  AO4 U158 ( .A(n195), .B(n169), .C(n151), .D(n190), .Z(n121) );
  AO4 U159 ( .A(n195), .B(n192), .C(n151), .D(n169), .Z(n122) );
  AO4 U160 ( .A(n158), .B(n76), .C(n174), .D(n77), .Z(n74) );
  AO4 U161 ( .A(n175), .B(n67), .C(n157), .D(n66), .Z(n75) );
  AO4 U162 ( .A(n155), .B(n76), .C(n173), .D(n77), .Z(n78) );
  AO4 U163 ( .A(n156), .B(n67), .C(n180), .D(n66), .Z(n79) );
  AO4 U164 ( .A(n162), .B(n76), .C(n178), .D(n77), .Z(n82) );
  AO4 U165 ( .A(n179), .B(n67), .C(n161), .D(n66), .Z(n83) );
  AO4 U166 ( .A(n160), .B(n76), .C(n176), .D(n77), .Z(n84) );
  AO4 U167 ( .A(n177), .B(n67), .C(n159), .D(n66), .Z(n85) );
  IVDA U168 ( .A(n1), .Y(n151), .Z(n195) );
  IVDA U169 ( .A(n21), .Y(n152), .Z(n196) );
  AO7 U170 ( .A(n67), .B(reg_half_counter[3]), .C(reg_fsm[0]), .Z(n64) );
  AO3 U171 ( .A(reg_fsm[1]), .B(n51), .C(n202), .D(n53), .Z(n147) );
  AO3 U172 ( .A(n194), .B(n51), .C(n38), .D(n57), .Z(n149) );
  AN3 U173 ( .A(n48), .B(n171), .C(reg_in_start_transaction), .Z(n21) );
  AO2 U174 ( .A(n46), .B(n182), .C(ready), .D(n152), .Z(n45) );
  EON1 U175 ( .A(n184), .B(n40), .C(N133), .D(n41), .Z(n142) );
  EON1 U176 ( .A(n200), .B(n40), .C(N132), .D(n41), .Z(n143) );
  EON1 U177 ( .A(n170), .B(n40), .C(N131), .D(n41), .Z(n144) );
  EON1 U178 ( .A(n153), .B(n40), .C(N130), .D(n41), .Z(n145) );
  ND4 U179 ( .A(reg_half_counter[0]), .B(n141), .C(n18), .D(n19), .Z(n1) );
  AO4 U180 ( .A(n195), .B(n191), .C(n151), .D(n107), .Z(n108) );
  AO4 U181 ( .A(n106), .B(n195), .C(n151), .D(n192), .Z(n123) );
  AO4 U182 ( .A(n105), .B(n152), .C(n196), .D(n155), .Z(n124) );
  AO4 U183 ( .A(n104), .B(n152), .C(n196), .D(n173), .Z(n125) );
  AO4 U184 ( .A(n103), .B(n152), .C(n196), .D(n156), .Z(n126) );
  AO4 U185 ( .A(n102), .B(n152), .C(n196), .D(n157), .Z(n127) );
  AO4 U186 ( .A(n101), .B(n152), .C(n196), .D(n158), .Z(n128) );
  AO4 U187 ( .A(n100), .B(n152), .C(n196), .D(n174), .Z(n129) );
  AO4 U188 ( .A(n99), .B(n152), .C(n196), .D(n175), .Z(n130) );
  AO4 U189 ( .A(n98), .B(n152), .C(n196), .D(n159), .Z(n131) );
  AO4 U190 ( .A(n97), .B(n152), .C(n196), .D(n160), .Z(n132) );
  AO4 U191 ( .A(n96), .B(n152), .C(n196), .D(n176), .Z(n133) );
  AO4 U192 ( .A(n95), .B(n152), .C(n196), .D(n177), .Z(n134) );
  AO4 U193 ( .A(n94), .B(n152), .C(n196), .D(n161), .Z(n135) );
  AO4 U194 ( .A(n93), .B(n152), .C(n196), .D(n162), .Z(n136) );
  AO4 U195 ( .A(n92), .B(n152), .C(n196), .D(n178), .Z(n137) );
  AO4 U196 ( .A(n91), .B(n152), .C(n196), .D(n179), .Z(n138) );
  AO4 U197 ( .A(n90), .B(n152), .C(n196), .D(n180), .Z(n139) );
  AO7 U198 ( .A(n141), .B(n86), .C(n87), .Z(N123) );
  ND4 U199 ( .A(reg_tic_counter[1]), .B(reg_tic_counter[0]), .C(n204), .D(n141), .Z(n87) );
  AO6 U200 ( .A(n204), .B(n183), .C(N121), .Z(n86) );
  AO2 U201 ( .A(n70), .B(n184), .C(reg_half_counter[4]), .D(n71), .Z(n69) );
  AO4 U202 ( .A(n80), .B(n200), .C(reg_half_counter[3]), .D(n81), .Z(n70) );
  AO4 U203 ( .A(n72), .B(n200), .C(reg_half_counter[3]), .D(n73), .Z(n71) );
  EN U204 ( .A(reg_half_counter[1]), .B(n181), .Z(N130) );
  ND2 U205 ( .A(reg_half_counter[1]), .B(reg_half_counter[0]), .Z(n197) );
  EN U206 ( .A(reg_half_counter[2]), .B(n197), .Z(N131) );
  ND3 U207 ( .A(reg_half_counter[1]), .B(reg_half_counter[0]), .C(
        reg_half_counter[2]), .Z(n198) );
  EN U208 ( .A(reg_half_counter[3]), .B(n198), .Z(N132) );
  NR2 U209 ( .A(n198), .B(n200), .Z(n199) );
  EO U210 ( .A(reg_half_counter[4]), .B(n199), .Z(N133) );
  IVI U211 ( .A(n38), .Z(n201) );
  IVI U212 ( .A(n19), .Z(n202) );
  IVI U213 ( .A(n68), .Z(n203) );
  IVI U214 ( .A(n40), .Z(n204) );
endmodule

