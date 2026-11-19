library ieee;
use ieee.std_logic_1164.all;

library basys3_lib;
use basys3_lib.basys3_ctes_pkg.all;

package basys3_types_pkg is
    type t_display_chars is (
        CHAR_0, 
        CHAR_1, 
        CHAR_2,
        CHAR_3,
        CHAR_4,
        CHAR_5,
        CHAR_6,
        CHAR_7,
        CHAR_8,
        CHAR_9,
        CHAR_A,
        CHAR_B,
        CHAR_C,
        CHAR_D,
        CHAR_E,
        CHAR_F,
        CHAR_G,
        CHAR_H,
        CHAR_I,
        CHAR_J,
        CHAR_K,
        CHAR_L,
        CHAR_M,
        CHAR_N,
        CHAR_O,
        CHAR_P,
        CHAR_Q,
        CHAR_R,
        CHAR_S,
        CHAR_T,
        CHAR_U,
        CHAR_V,
        CHAR_W,
        CHAR_X,
        CHAR_Y,
        CHAR_Z,
        -- Segmentos individuales del display de 7 segmentos.
        -- Disposición estándar (a..g):
        --       aaa
        --      f   b
        --      f   b
        --       ggg
        --      e   c
        --      e   c
        --       ddd
        S_U,    -- superior        (a)
        S_UL,   -- superior izq.   (f)
        S_LL,   -- inferior izq.   (e)
        S_L,    -- inferior        (d)
        S_LR,   -- inferior der.   (c)
        S_UR,   -- superior der.   (b)
        S_M,    -- central         (g)
        -- Segmentos apagados
        S_OFF);

    type t_display_word is array (0 to c_n_display_elements - 1) of t_display_chars;

    subtype t_display_segment is std_logic_vector(0 to c_n_display_segments - 1);
end package basys3_types_pkg;