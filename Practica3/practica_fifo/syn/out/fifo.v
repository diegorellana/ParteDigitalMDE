/////////////////////////////////////////////////////////////
// Created by: Synopsys DC Expert(TM) in wire load mode
// Version   : W-2024.09-SP2
// Date      : Thu Nov 12 12:40:50 2026
/////////////////////////////////////////////////////////////


module fifo ( clk, reset_n, write_enable, data_to_write, read_enable, 
        data_read, read_valid, empty, full );
  input [15:0] data_to_write;
  output [15:0] data_read;
  input clk, reset_n, write_enable, read_enable;
  output read_valid, empty, full;
  wire   N11, N12, \reg_data_counter[1] , \reg_data_counter[0] ,
         \reg_write_pointer[1] , \reg_write_pointer[0] , \reg_array[0][15] ,
         \reg_array[0][14] , \reg_array[0][13] , \reg_array[0][12] ,
         \reg_array[0][11] , \reg_array[0][10] , \reg_array[0][9] ,
         \reg_array[0][8] , \reg_array[0][7] , \reg_array[0][6] ,
         \reg_array[0][5] , \reg_array[0][4] , \reg_array[0][3] ,
         \reg_array[0][2] , \reg_array[0][1] , \reg_array[0][0] ,
         \reg_array[1][15] , \reg_array[1][14] , \reg_array[1][13] ,
         \reg_array[1][12] , \reg_array[1][11] , \reg_array[1][10] ,
         \reg_array[1][9] , \reg_array[1][8] , \reg_array[1][7] ,
         \reg_array[1][6] , \reg_array[1][5] , \reg_array[1][4] ,
         \reg_array[1][3] , \reg_array[1][2] , \reg_array[1][1] ,
         \reg_array[1][0] , \reg_array[2][15] , \reg_array[2][14] ,
         \reg_array[2][13] , \reg_array[2][12] , \reg_array[2][11] ,
         \reg_array[2][10] , \reg_array[2][9] , \reg_array[2][8] ,
         \reg_array[2][7] , \reg_array[2][6] , \reg_array[2][5] ,
         \reg_array[2][4] , \reg_array[2][3] , \reg_array[2][2] ,
         \reg_array[2][1] , \reg_array[2][0] , \reg_array[3][15] ,
         \reg_array[3][14] , \reg_array[3][13] , \reg_array[3][12] ,
         \reg_array[3][11] , \reg_array[3][10] , \reg_array[3][9] ,
         \reg_array[3][8] , \reg_array[3][7] , \reg_array[3][6] ,
         \reg_array[3][5] , \reg_array[3][4] , \reg_array[3][3] ,
         \reg_array[3][2] , \reg_array[3][1] , \reg_array[3][0] , N50, N51,
         N52, N53, N54, N55, N56, N57, N58, N59, N60, N61, N62, N63, N64, N65,
         n9, n11, n12, n13, n16, n33, n37, n39, n40, n42, n45, n47, n49, n50,
         n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63, n64,
         n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77, n78,
         n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91, n92,
         n93, n94, n95, n96, n97, n98, n99, n100, n101, n102, n103, n104, n105,
         n106, n107, n108, n109, n110, n111, n112, n113, n114, n115, n116,
         n117, n118, n119, n120, n121, n122, n123, n124, n125, n126, n127,
         n128, n131, n132, n133, n134, n135, n136, n137, n138, n139, n140,
         n141, n142, n143, n144, n145, n146, n147, n148, n149, n150, n151,
         n152, n153, n154, n155, n156, n157, n158, n159, n160, n161, n162,
         n163, n164, n165, n166, n167, n168, n169, n170, n171, n172, n173,
         n174, n175, n176, n177, n178, n179, n180, n181, n182, n183, n184,
         n185, n186, n187, n188, n189, n190, n191, n192, n193, n194, n195,
         n196, n197, n198, n199, n200, n201, n202, n203, n204, n205, n206,
         n207, n208, n209, n210, n211, n212, n213, n214, n215, n216, n217,
         n218, n221, n222, n223, n224, n225, n226, n227, n228, n229, n230,
         n231, n232, n233, n234, n235, n236, n237, n238, n239, n240, n241,
         n242, n243, n244, n245, n246, n247, n248, n249, n250, n251, n252,
         n253, n254, n255, n256, n257, n258, n259, n260, n261, n262, n263,
         n264, n265, n266, n267, n268, n269, n270, n271, n272, n273, n274,
         n275, n276, n277, n278, n279, n280, n281, n282, n283, n284, n285,
         n286, n287, n288, n289, n290, n291, n292, n293, n294, n295, n296,
         n297, n298, n299, n300, n301, n302;

  FD2 \reg_data_counter_reg[0]  ( .D(n218), .CP(clk), .CD(reset_n), .Q(
        \reg_data_counter[0] ), .QN(n221) );
  FD2 \reg_read_pointer_reg[0]  ( .D(n150), .CP(clk), .CD(reset_n), .Q(N11), 
        .QN(n267) );
  FD2 \reg_read_pointer_reg[1]  ( .D(n149), .CP(clk), .CD(reset_n), .Q(N12), 
        .QN(n266) );
  FD2 \reg_data_counter_reg[1]  ( .D(n216), .CP(clk), .CD(reset_n), .Q(
        \reg_data_counter[1] ), .QN(n224) );
  FD2 \reg_data_counter_reg[2]  ( .D(n217), .CP(clk), .CD(reset_n), .QN(n151)
         );
  FD2 \reg_write_pointer_reg[1]  ( .D(n147), .CP(clk), .CD(reset_n), .Q(
        \reg_write_pointer[1] ), .QN(n226) );
  FD1 \reg_array_reg[0][15]  ( .D(n215), .CP(clk), .Q(\reg_array[0][15] ), 
        .QN(n49) );
  FD1 \reg_array_reg[0][14]  ( .D(n214), .CP(clk), .Q(\reg_array[0][14] ), 
        .QN(n50) );
  FD1 \reg_array_reg[0][13]  ( .D(n213), .CP(clk), .Q(\reg_array[0][13] ), 
        .QN(n51) );
  FD1 \reg_array_reg[0][12]  ( .D(n212), .CP(clk), .Q(\reg_array[0][12] ), 
        .QN(n52) );
  FD1 \reg_array_reg[0][11]  ( .D(n211), .CP(clk), .Q(\reg_array[0][11] ), 
        .QN(n53) );
  FD1 \reg_array_reg[0][10]  ( .D(n210), .CP(clk), .Q(\reg_array[0][10] ), 
        .QN(n54) );
  FD1 \reg_array_reg[0][9]  ( .D(n209), .CP(clk), .Q(\reg_array[0][9] ), .QN(
        n55) );
  FD1 \reg_array_reg[0][8]  ( .D(n208), .CP(clk), .Q(\reg_array[0][8] ), .QN(
        n56) );
  FD1 \reg_array_reg[0][7]  ( .D(n207), .CP(clk), .Q(\reg_array[0][7] ), .QN(
        n57) );
  FD1 \reg_array_reg[0][6]  ( .D(n206), .CP(clk), .Q(\reg_array[0][6] ), .QN(
        n58) );
  FD1 \reg_array_reg[0][5]  ( .D(n205), .CP(clk), .Q(\reg_array[0][5] ), .QN(
        n59) );
  FD1 \reg_array_reg[0][4]  ( .D(n204), .CP(clk), .Q(\reg_array[0][4] ), .QN(
        n60) );
  FD1 \reg_array_reg[0][3]  ( .D(n203), .CP(clk), .Q(\reg_array[0][3] ), .QN(
        n61) );
  FD1 \reg_array_reg[0][2]  ( .D(n202), .CP(clk), .Q(\reg_array[0][2] ), .QN(
        n62) );
  FD1 \reg_array_reg[0][1]  ( .D(n201), .CP(clk), .Q(\reg_array[0][1] ), .QN(
        n63) );
  FD1 \reg_array_reg[0][0]  ( .D(n200), .CP(clk), .Q(\reg_array[0][0] ), .QN(
        n64) );
  FD1 \reg_array_reg[1][15]  ( .D(n199), .CP(clk), .Q(\reg_array[1][15] ), 
        .QN(n65) );
  FD1 \reg_array_reg[1][14]  ( .D(n198), .CP(clk), .Q(\reg_array[1][14] ), 
        .QN(n66) );
  FD1 \reg_array_reg[1][13]  ( .D(n197), .CP(clk), .Q(\reg_array[1][13] ), 
        .QN(n67) );
  FD1 \reg_array_reg[1][12]  ( .D(n196), .CP(clk), .Q(\reg_array[1][12] ), 
        .QN(n68) );
  FD1 \reg_array_reg[1][11]  ( .D(n195), .CP(clk), .Q(\reg_array[1][11] ), 
        .QN(n69) );
  FD1 \reg_array_reg[1][10]  ( .D(n194), .CP(clk), .Q(\reg_array[1][10] ), 
        .QN(n70) );
  FD1 \reg_array_reg[1][9]  ( .D(n193), .CP(clk), .Q(\reg_array[1][9] ), .QN(
        n71) );
  FD1 \reg_array_reg[1][8]  ( .D(n192), .CP(clk), .Q(\reg_array[1][8] ), .QN(
        n72) );
  FD1 \reg_array_reg[1][7]  ( .D(n191), .CP(clk), .Q(\reg_array[1][7] ), .QN(
        n73) );
  FD1 \reg_array_reg[1][6]  ( .D(n190), .CP(clk), .Q(\reg_array[1][6] ), .QN(
        n74) );
  FD1 \reg_array_reg[1][5]  ( .D(n189), .CP(clk), .Q(\reg_array[1][5] ), .QN(
        n75) );
  FD1 \reg_array_reg[1][4]  ( .D(n188), .CP(clk), .Q(\reg_array[1][4] ), .QN(
        n76) );
  FD1 \reg_array_reg[1][3]  ( .D(n187), .CP(clk), .Q(\reg_array[1][3] ), .QN(
        n77) );
  FD1 \reg_array_reg[1][2]  ( .D(n186), .CP(clk), .Q(\reg_array[1][2] ), .QN(
        n78) );
  FD1 \reg_array_reg[1][1]  ( .D(n185), .CP(clk), .Q(\reg_array[1][1] ), .QN(
        n79) );
  FD1 \reg_array_reg[1][0]  ( .D(n184), .CP(clk), .Q(\reg_array[1][0] ), .QN(
        n80) );
  FD1 \reg_array_reg[2][15]  ( .D(n183), .CP(clk), .Q(\reg_array[2][15] ), 
        .QN(n81) );
  FD1 \reg_array_reg[2][14]  ( .D(n182), .CP(clk), .Q(\reg_array[2][14] ), 
        .QN(n82) );
  FD1 \reg_array_reg[2][13]  ( .D(n181), .CP(clk), .Q(\reg_array[2][13] ), 
        .QN(n83) );
  FD1 \reg_array_reg[2][12]  ( .D(n180), .CP(clk), .Q(\reg_array[2][12] ), 
        .QN(n84) );
  FD1 \reg_array_reg[2][11]  ( .D(n179), .CP(clk), .Q(\reg_array[2][11] ), 
        .QN(n85) );
  FD1 \reg_array_reg[2][10]  ( .D(n178), .CP(clk), .Q(\reg_array[2][10] ), 
        .QN(n86) );
  FD1 \reg_array_reg[2][9]  ( .D(n177), .CP(clk), .Q(\reg_array[2][9] ), .QN(
        n87) );
  FD1 \reg_array_reg[2][8]  ( .D(n176), .CP(clk), .Q(\reg_array[2][8] ), .QN(
        n88) );
  FD1 \reg_array_reg[2][7]  ( .D(n175), .CP(clk), .Q(\reg_array[2][7] ), .QN(
        n89) );
  FD1 \reg_array_reg[2][6]  ( .D(n174), .CP(clk), .Q(\reg_array[2][6] ), .QN(
        n90) );
  FD1 \reg_array_reg[2][5]  ( .D(n173), .CP(clk), .Q(\reg_array[2][5] ), .QN(
        n91) );
  FD1 \reg_array_reg[2][4]  ( .D(n172), .CP(clk), .Q(\reg_array[2][4] ), .QN(
        n92) );
  FD1 \reg_array_reg[2][3]  ( .D(n171), .CP(clk), .Q(\reg_array[2][3] ), .QN(
        n93) );
  FD1 \reg_array_reg[2][2]  ( .D(n170), .CP(clk), .Q(\reg_array[2][2] ), .QN(
        n94) );
  FD1 \reg_array_reg[2][1]  ( .D(n169), .CP(clk), .Q(\reg_array[2][1] ), .QN(
        n95) );
  FD1 \reg_array_reg[2][0]  ( .D(n168), .CP(clk), .Q(\reg_array[2][0] ), .QN(
        n96) );
  FD1 \reg_array_reg[3][15]  ( .D(n167), .CP(clk), .Q(\reg_array[3][15] ), 
        .QN(n97) );
  FD1 \reg_array_reg[3][14]  ( .D(n166), .CP(clk), .Q(\reg_array[3][14] ), 
        .QN(n98) );
  FD1 \reg_array_reg[3][13]  ( .D(n165), .CP(clk), .Q(\reg_array[3][13] ), 
        .QN(n99) );
  FD1 \reg_array_reg[3][12]  ( .D(n164), .CP(clk), .Q(\reg_array[3][12] ), 
        .QN(n100) );
  FD1 \reg_array_reg[3][11]  ( .D(n163), .CP(clk), .Q(\reg_array[3][11] ), 
        .QN(n101) );
  FD1 \reg_array_reg[3][10]  ( .D(n162), .CP(clk), .Q(\reg_array[3][10] ), 
        .QN(n102) );
  FD1 \reg_array_reg[3][9]  ( .D(n161), .CP(clk), .Q(\reg_array[3][9] ), .QN(
        n103) );
  FD1 \reg_array_reg[3][8]  ( .D(n160), .CP(clk), .Q(\reg_array[3][8] ), .QN(
        n104) );
  FD1 \reg_array_reg[3][7]  ( .D(n159), .CP(clk), .Q(\reg_array[3][7] ), .QN(
        n105) );
  FD1 \reg_array_reg[3][6]  ( .D(n158), .CP(clk), .Q(\reg_array[3][6] ), .QN(
        n106) );
  FD1 \reg_array_reg[3][5]  ( .D(n157), .CP(clk), .Q(\reg_array[3][5] ), .QN(
        n107) );
  FD1 \reg_array_reg[3][4]  ( .D(n156), .CP(clk), .Q(\reg_array[3][4] ), .QN(
        n108) );
  FD1 \reg_array_reg[3][3]  ( .D(n155), .CP(clk), .Q(\reg_array[3][3] ), .QN(
        n109) );
  FD1 \reg_array_reg[3][2]  ( .D(n154), .CP(clk), .Q(\reg_array[3][2] ), .QN(
        n110) );
  FD1 \reg_array_reg[3][1]  ( .D(n153), .CP(clk), .Q(\reg_array[3][1] ), .QN(
        n111) );
  FD1 \reg_array_reg[3][0]  ( .D(n152), .CP(clk), .Q(\reg_array[3][0] ), .QN(
        n112) );
  FD1 \reg_data_read_reg[15]  ( .D(n146), .CP(clk), .Q(data_read[15]), .QN(
        n128) );
  FD1 \reg_data_read_reg[14]  ( .D(n145), .CP(clk), .Q(data_read[14]), .QN(
        n127) );
  FD1 \reg_data_read_reg[13]  ( .D(n144), .CP(clk), .Q(data_read[13]), .QN(
        n126) );
  FD1 \reg_data_read_reg[12]  ( .D(n143), .CP(clk), .Q(data_read[12]), .QN(
        n125) );
  FD1 \reg_data_read_reg[11]  ( .D(n142), .CP(clk), .Q(data_read[11]), .QN(
        n124) );
  FD1 \reg_data_read_reg[10]  ( .D(n141), .CP(clk), .Q(data_read[10]), .QN(
        n123) );
  FD1 \reg_data_read_reg[9]  ( .D(n140), .CP(clk), .Q(data_read[9]), .QN(n122)
         );
  FD1 \reg_data_read_reg[8]  ( .D(n139), .CP(clk), .Q(data_read[8]), .QN(n121)
         );
  FD1 \reg_data_read_reg[7]  ( .D(n138), .CP(clk), .Q(data_read[7]), .QN(n120)
         );
  FD1 \reg_data_read_reg[6]  ( .D(n137), .CP(clk), .Q(data_read[6]), .QN(n119)
         );
  FD1 \reg_data_read_reg[5]  ( .D(n136), .CP(clk), .Q(data_read[5]), .QN(n118)
         );
  FD1 \reg_data_read_reg[4]  ( .D(n135), .CP(clk), .Q(data_read[4]), .QN(n117)
         );
  FD1 \reg_data_read_reg[3]  ( .D(n134), .CP(clk), .Q(data_read[3]), .QN(n116)
         );
  FD1 \reg_data_read_reg[2]  ( .D(n133), .CP(clk), .Q(data_read[2]), .QN(n115)
         );
  FD1 \reg_data_read_reg[1]  ( .D(n132), .CP(clk), .Q(data_read[1]), .QN(n114)
         );
  FD1 \reg_data_read_reg[0]  ( .D(n131), .CP(clk), .Q(data_read[0]), .QN(n113)
         );
  FD2 reg_read_valid_reg ( .D(n281), .CP(clk), .CD(reset_n), .Q(read_valid) );
  AN3 U129 ( .A(n272), .B(n224), .C(n151), .Z(empty) );
  ENI U4 ( .A(\reg_write_pointer[0] ), .B(n12), .Z(n148) );
  EOI U5 ( .A(n13), .B(n266), .Z(n149) );
  ND2I U6 ( .A(n280), .B(N11), .Z(n13) );
  ENI U8 ( .A(n267), .B(n280), .Z(n150) );
  ND2I U26 ( .A(n9), .B(\reg_write_pointer[1] ), .Z(n16) );
  ND2I U62 ( .A(n9), .B(n226), .Z(n11) );
  NR2I U64 ( .A(n302), .B(n12), .Z(n9) );
  ENI U100 ( .A(\reg_data_counter[1] ), .B(n39), .Z(n216) );
  ND2I U101 ( .A(n40), .B(n282), .Z(n39) );
  ENI U102 ( .A(n273), .B(n42), .Z(n40) );
  ND2I U104 ( .A(n42), .B(n273), .Z(n45) );
  ENI U107 ( .A(n47), .B(n273), .Z(n218) );
  ND2I U110 ( .A(write_enable), .B(n151), .Z(n12) );
  FD2 \reg_write_pointer_reg[0]  ( .D(n148), .CP(clk), .CD(reset_n), .Q(
        \reg_write_pointer[0] ), .QN(n302) );
  NR2I U133 ( .A(n12), .B(n281), .Z(n42) );
  AO6 U134 ( .A(n12), .B(n280), .C(n42), .Z(n47) );
  OR2P U135 ( .A(n301), .B(empty), .Z(n223) );
  AO4 U136 ( .A(n224), .B(n45), .C(n151), .D(n227), .Z(n217) );
  AN3 U137 ( .A(n282), .B(n224), .C(n221), .Z(n227) );
  IVDA U138 ( .A(n284), .Z(n278) );
  IVDA U139 ( .A(n284), .Z(n279) );
  IVDA U140 ( .A(n283), .Z(n276) );
  IVDA U141 ( .A(n283), .Z(n277) );
  IVDA U142 ( .A(n11), .Y(n222), .Z(n274) );
  IVDA U143 ( .A(n16), .Y(n225), .Z(n275) );
  AO7 U144 ( .A(n9), .B(n226), .C(n274), .Z(n147) );
  IVDA U145 ( .A(n260), .Z(n269) );
  OR3 U146 ( .A(n12), .B(\reg_write_pointer[0] ), .C(n226), .Z(n228) );
  IVI U147 ( .A(n228), .Z(n33) );
  OR3 U148 ( .A(\reg_write_pointer[0] ), .B(\reg_write_pointer[1] ), .C(n12), 
        .Z(n229) );
  IVI U149 ( .A(n229), .Z(n37) );
  AO4 U150 ( .A(n33), .B(n96), .C(n300), .D(n278), .Z(n168) );
  AO4 U151 ( .A(n33), .B(n95), .C(n299), .D(n279), .Z(n169) );
  AO4 U152 ( .A(n33), .B(n94), .C(n298), .D(n278), .Z(n170) );
  AO4 U153 ( .A(n33), .B(n93), .C(n297), .D(n279), .Z(n171) );
  AO4 U154 ( .A(n33), .B(n92), .C(n296), .D(n278), .Z(n172) );
  AO4 U155 ( .A(n33), .B(n91), .C(n295), .D(n279), .Z(n173) );
  AO4 U156 ( .A(n33), .B(n90), .C(n294), .D(n278), .Z(n174) );
  AO4 U157 ( .A(n33), .B(n89), .C(n293), .D(n279), .Z(n175) );
  AO4 U158 ( .A(n33), .B(n88), .C(n292), .D(n278), .Z(n176) );
  AO4 U159 ( .A(n33), .B(n87), .C(n291), .D(n279), .Z(n177) );
  AO4 U160 ( .A(n33), .B(n86), .C(n290), .D(n278), .Z(n178) );
  AO4 U161 ( .A(n33), .B(n85), .C(n289), .D(n279), .Z(n179) );
  AO4 U162 ( .A(n33), .B(n84), .C(n288), .D(n278), .Z(n180) );
  AO4 U163 ( .A(n33), .B(n83), .C(n287), .D(n279), .Z(n181) );
  AO4 U164 ( .A(n33), .B(n82), .C(n286), .D(n278), .Z(n182) );
  AO4 U165 ( .A(n33), .B(n81), .C(n285), .D(n279), .Z(n183) );
  AO4 U166 ( .A(n37), .B(n64), .C(n300), .D(n276), .Z(n200) );
  AO4 U167 ( .A(n37), .B(n63), .C(n299), .D(n277), .Z(n201) );
  AO4 U168 ( .A(n37), .B(n62), .C(n298), .D(n276), .Z(n202) );
  AO4 U169 ( .A(n37), .B(n61), .C(n297), .D(n277), .Z(n203) );
  AO4 U170 ( .A(n37), .B(n60), .C(n296), .D(n276), .Z(n204) );
  AO4 U171 ( .A(n37), .B(n59), .C(n295), .D(n277), .Z(n205) );
  AO4 U172 ( .A(n37), .B(n58), .C(n294), .D(n276), .Z(n206) );
  AO4 U173 ( .A(n37), .B(n57), .C(n293), .D(n277), .Z(n207) );
  AO4 U174 ( .A(n37), .B(n56), .C(n292), .D(n276), .Z(n208) );
  AO4 U175 ( .A(n37), .B(n55), .C(n291), .D(n277), .Z(n209) );
  AO4 U176 ( .A(n37), .B(n54), .C(n290), .D(n276), .Z(n210) );
  AO4 U177 ( .A(n37), .B(n53), .C(n289), .D(n277), .Z(n211) );
  AO4 U178 ( .A(n37), .B(n52), .C(n288), .D(n276), .Z(n212) );
  AO4 U179 ( .A(n37), .B(n51), .C(n287), .D(n277), .Z(n213) );
  AO4 U180 ( .A(n37), .B(n50), .C(n286), .D(n276), .Z(n214) );
  AO4 U181 ( .A(n37), .B(n49), .C(n285), .D(n277), .Z(n215) );
  AO4 U182 ( .A(n222), .B(n80), .C(n300), .D(n274), .Z(n184) );
  AO4 U183 ( .A(n222), .B(n79), .C(n299), .D(n274), .Z(n185) );
  AO4 U184 ( .A(n222), .B(n78), .C(n298), .D(n274), .Z(n186) );
  AO4 U185 ( .A(n222), .B(n77), .C(n297), .D(n274), .Z(n187) );
  AO4 U186 ( .A(n222), .B(n76), .C(n296), .D(n274), .Z(n188) );
  AO4 U187 ( .A(n222), .B(n75), .C(n295), .D(n274), .Z(n189) );
  AO4 U188 ( .A(n222), .B(n74), .C(n294), .D(n274), .Z(n190) );
  AO4 U189 ( .A(n222), .B(n73), .C(n293), .D(n274), .Z(n191) );
  AO4 U190 ( .A(n222), .B(n72), .C(n292), .D(n274), .Z(n192) );
  AO4 U191 ( .A(n222), .B(n71), .C(n291), .D(n274), .Z(n193) );
  AO4 U192 ( .A(n222), .B(n70), .C(n290), .D(n274), .Z(n194) );
  AO4 U193 ( .A(n222), .B(n69), .C(n289), .D(n274), .Z(n195) );
  AO4 U194 ( .A(n222), .B(n68), .C(n288), .D(n274), .Z(n196) );
  AO4 U195 ( .A(n222), .B(n67), .C(n287), .D(n274), .Z(n197) );
  AO4 U196 ( .A(n222), .B(n66), .C(n286), .D(n274), .Z(n198) );
  AO4 U197 ( .A(n222), .B(n65), .C(n285), .D(n274), .Z(n199) );
  AO4 U198 ( .A(n225), .B(n112), .C(n275), .D(n300), .Z(n152) );
  AO4 U199 ( .A(n225), .B(n111), .C(n275), .D(n299), .Z(n153) );
  AO4 U200 ( .A(n225), .B(n110), .C(n275), .D(n298), .Z(n154) );
  AO4 U201 ( .A(n225), .B(n109), .C(n275), .D(n297), .Z(n155) );
  AO4 U202 ( .A(n225), .B(n108), .C(n275), .D(n296), .Z(n156) );
  AO4 U203 ( .A(n225), .B(n107), .C(n275), .D(n295), .Z(n157) );
  AO4 U204 ( .A(n225), .B(n106), .C(n275), .D(n294), .Z(n158) );
  AO4 U205 ( .A(n225), .B(n105), .C(n275), .D(n293), .Z(n159) );
  AO4 U206 ( .A(n225), .B(n104), .C(n275), .D(n292), .Z(n160) );
  AO4 U207 ( .A(n225), .B(n103), .C(n275), .D(n291), .Z(n161) );
  AO4 U208 ( .A(n225), .B(n102), .C(n275), .D(n290), .Z(n162) );
  AO4 U209 ( .A(n225), .B(n101), .C(n275), .D(n289), .Z(n163) );
  AO4 U210 ( .A(n225), .B(n100), .C(n275), .D(n288), .Z(n164) );
  AO4 U211 ( .A(n225), .B(n99), .C(n275), .D(n287), .Z(n165) );
  AO4 U212 ( .A(n225), .B(n98), .C(n275), .D(n286), .Z(n166) );
  AO4 U213 ( .A(n225), .B(n97), .C(n275), .D(n285), .Z(n167) );
  EON1 U214 ( .A(n126), .B(n280), .C(N52), .D(n281), .Z(n144) );
  EON1 U215 ( .A(n127), .B(n280), .C(N51), .D(n281), .Z(n145) );
  EON1 U216 ( .A(n128), .B(n280), .C(N50), .D(n281), .Z(n146) );
  IVDA U217 ( .A(n262), .Z(n271) );
  IVDA U218 ( .A(n261), .Z(n268) );
  IVDA U219 ( .A(n263), .Z(n270) );
  AO2 U220 ( .A(\reg_array[2][0] ), .B(n268), .C(\reg_array[3][0] ), .D(n269), 
        .Z(n231) );
  AO2 U221 ( .A(\reg_array[0][0] ), .B(n270), .C(\reg_array[1][0] ), .D(n271), 
        .Z(n230) );
  ND2 U222 ( .A(n231), .B(n230), .Z(N65) );
  AO2 U223 ( .A(\reg_array[2][1] ), .B(n268), .C(\reg_array[3][1] ), .D(n269), 
        .Z(n233) );
  AO2 U224 ( .A(\reg_array[0][1] ), .B(n270), .C(\reg_array[1][1] ), .D(n271), 
        .Z(n232) );
  ND2 U225 ( .A(n233), .B(n232), .Z(N64) );
  AO2 U226 ( .A(\reg_array[2][2] ), .B(n268), .C(\reg_array[3][2] ), .D(n269), 
        .Z(n235) );
  AO2 U227 ( .A(\reg_array[0][2] ), .B(n270), .C(\reg_array[1][2] ), .D(n271), 
        .Z(n234) );
  ND2 U228 ( .A(n235), .B(n234), .Z(N63) );
  AO2 U229 ( .A(\reg_array[2][3] ), .B(n268), .C(\reg_array[3][3] ), .D(n269), 
        .Z(n237) );
  AO2 U230 ( .A(\reg_array[0][3] ), .B(n270), .C(\reg_array[1][3] ), .D(n271), 
        .Z(n236) );
  ND2 U231 ( .A(n237), .B(n236), .Z(N62) );
  AO2 U232 ( .A(\reg_array[2][4] ), .B(n268), .C(\reg_array[3][4] ), .D(n269), 
        .Z(n239) );
  AO2 U233 ( .A(\reg_array[0][4] ), .B(n270), .C(\reg_array[1][4] ), .D(n271), 
        .Z(n238) );
  ND2 U234 ( .A(n239), .B(n238), .Z(N61) );
  AO2 U235 ( .A(\reg_array[2][5] ), .B(n268), .C(\reg_array[3][5] ), .D(n269), 
        .Z(n241) );
  AO2 U236 ( .A(\reg_array[0][5] ), .B(n270), .C(\reg_array[1][5] ), .D(n271), 
        .Z(n240) );
  ND2 U237 ( .A(n241), .B(n240), .Z(N60) );
  AO2 U238 ( .A(\reg_array[2][6] ), .B(n268), .C(\reg_array[3][6] ), .D(n269), 
        .Z(n243) );
  AO2 U239 ( .A(\reg_array[0][6] ), .B(n270), .C(\reg_array[1][6] ), .D(n271), 
        .Z(n242) );
  ND2 U240 ( .A(n243), .B(n242), .Z(N59) );
  AO2 U241 ( .A(\reg_array[2][7] ), .B(n268), .C(\reg_array[3][7] ), .D(n269), 
        .Z(n245) );
  AO2 U242 ( .A(\reg_array[0][7] ), .B(n270), .C(\reg_array[1][7] ), .D(n271), 
        .Z(n244) );
  ND2 U243 ( .A(n245), .B(n244), .Z(N58) );
  AO2 U244 ( .A(\reg_array[2][8] ), .B(n268), .C(\reg_array[3][8] ), .D(n269), 
        .Z(n247) );
  AO2 U245 ( .A(\reg_array[0][8] ), .B(n270), .C(\reg_array[1][8] ), .D(n271), 
        .Z(n246) );
  ND2 U246 ( .A(n247), .B(n246), .Z(N57) );
  AO2 U247 ( .A(\reg_array[2][9] ), .B(n268), .C(\reg_array[3][9] ), .D(n269), 
        .Z(n249) );
  AO2 U248 ( .A(\reg_array[0][9] ), .B(n270), .C(\reg_array[1][9] ), .D(n271), 
        .Z(n248) );
  ND2 U249 ( .A(n249), .B(n248), .Z(N56) );
  AO2 U250 ( .A(\reg_array[2][10] ), .B(n268), .C(\reg_array[3][10] ), .D(n269), .Z(n251) );
  AO2 U251 ( .A(\reg_array[0][10] ), .B(n270), .C(\reg_array[1][10] ), .D(n271), .Z(n250) );
  ND2 U252 ( .A(n251), .B(n250), .Z(N55) );
  AO2 U253 ( .A(\reg_array[2][11] ), .B(n268), .C(\reg_array[3][11] ), .D(n269), .Z(n253) );
  AO2 U254 ( .A(\reg_array[0][11] ), .B(n270), .C(\reg_array[1][11] ), .D(n271), .Z(n252) );
  ND2 U255 ( .A(n253), .B(n252), .Z(N54) );
  AO2 U256 ( .A(\reg_array[2][12] ), .B(n268), .C(\reg_array[3][12] ), .D(n269), .Z(n255) );
  AO2 U257 ( .A(\reg_array[0][12] ), .B(n270), .C(\reg_array[1][12] ), .D(n271), .Z(n254) );
  ND2 U258 ( .A(n255), .B(n254), .Z(N53) );
  AO2 U259 ( .A(\reg_array[2][13] ), .B(n268), .C(\reg_array[3][13] ), .D(n269), .Z(n257) );
  AO2 U260 ( .A(\reg_array[0][13] ), .B(n270), .C(\reg_array[1][13] ), .D(n271), .Z(n256) );
  ND2 U261 ( .A(n257), .B(n256), .Z(N52) );
  AO2 U262 ( .A(\reg_array[2][14] ), .B(n268), .C(\reg_array[3][14] ), .D(n269), .Z(n259) );
  AO2 U263 ( .A(\reg_array[0][14] ), .B(n270), .C(\reg_array[1][14] ), .D(n271), .Z(n258) );
  ND2 U264 ( .A(n259), .B(n258), .Z(N51) );
  AO2 U265 ( .A(\reg_array[2][15] ), .B(n268), .C(\reg_array[3][15] ), .D(n269), .Z(n265) );
  AO2 U266 ( .A(\reg_array[0][15] ), .B(n270), .C(\reg_array[1][15] ), .D(n271), .Z(n264) );
  ND2 U267 ( .A(n265), .B(n264), .Z(N50) );
  NR2I U268 ( .A(n266), .B(N11), .Z(n261) );
  NR2I U269 ( .A(n266), .B(n267), .Z(n260) );
  NR2I U270 ( .A(N11), .B(N12), .Z(n263) );
  NR2I U271 ( .A(n267), .B(N12), .Z(n262) );
  EON1 U272 ( .A(n113), .B(n280), .C(N65), .D(n280), .Z(n131) );
  EON1 U273 ( .A(n114), .B(n280), .C(N64), .D(n280), .Z(n132) );
  EON1 U274 ( .A(n115), .B(n280), .C(N63), .D(n281), .Z(n133) );
  EON1 U275 ( .A(n116), .B(n281), .C(N62), .D(n280), .Z(n134) );
  EON1 U276 ( .A(n117), .B(n281), .C(N61), .D(n280), .Z(n135) );
  EON1 U277 ( .A(n118), .B(n280), .C(N60), .D(n280), .Z(n136) );
  EON1 U278 ( .A(n119), .B(n280), .C(N59), .D(n281), .Z(n137) );
  EON1 U279 ( .A(n120), .B(n280), .C(N58), .D(n281), .Z(n138) );
  EON1 U280 ( .A(n121), .B(n280), .C(N57), .D(n280), .Z(n139) );
  EON1 U281 ( .A(n122), .B(n280), .C(N56), .D(n280), .Z(n140) );
  EON1 U282 ( .A(n123), .B(n280), .C(N55), .D(n280), .Z(n141) );
  EON1 U283 ( .A(n124), .B(n280), .C(N54), .D(n280), .Z(n142) );
  EON1 U284 ( .A(n125), .B(n280), .C(N53), .D(n280), .Z(n143) );
  IVI U285 ( .A(\reg_data_counter[0] ), .Z(n272) );
  IVI U286 ( .A(n272), .Z(n273) );
  IVP U287 ( .A(n223), .Z(n280) );
  IVI U288 ( .A(n223), .Z(n281) );
  NR3 U289 ( .A(n151), .B(\reg_data_counter[1] ), .C(n273), .Z(full) );
  IVI U290 ( .A(n47), .Z(n282) );
  IVI U291 ( .A(n37), .Z(n283) );
  IVI U292 ( .A(n33), .Z(n284) );
  IVI U293 ( .A(data_to_write[15]), .Z(n285) );
  IVI U294 ( .A(data_to_write[14]), .Z(n286) );
  IVI U295 ( .A(data_to_write[13]), .Z(n287) );
  IVI U296 ( .A(data_to_write[12]), .Z(n288) );
  IVI U297 ( .A(data_to_write[11]), .Z(n289) );
  IVI U298 ( .A(data_to_write[10]), .Z(n290) );
  IVI U299 ( .A(data_to_write[9]), .Z(n291) );
  IVI U300 ( .A(data_to_write[8]), .Z(n292) );
  IVI U301 ( .A(data_to_write[7]), .Z(n293) );
  IVI U302 ( .A(data_to_write[6]), .Z(n294) );
  IVI U303 ( .A(data_to_write[5]), .Z(n295) );
  IVI U304 ( .A(data_to_write[4]), .Z(n296) );
  IVI U305 ( .A(data_to_write[3]), .Z(n297) );
  IVI U306 ( .A(data_to_write[2]), .Z(n298) );
  IVI U307 ( .A(data_to_write[1]), .Z(n299) );
  IVI U308 ( .A(data_to_write[0]), .Z(n300) );
  IVI U309 ( .A(read_enable), .Z(n301) );
endmodule

