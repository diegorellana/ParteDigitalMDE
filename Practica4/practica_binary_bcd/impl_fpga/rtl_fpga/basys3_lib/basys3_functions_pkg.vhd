library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library basys3_lib;
use basys3_lib.basys3_types_pkg.all;

package basys3_functions_pkg is

    function f_basys3_character_to_segments(input : t_display_chars) return t_display_segment;
    function f_basys3_nibble_to_char(input : std_logic_vector) return t_display_chars;

end package basys3_functions_pkg;

package body basys3_functions_pkg is

    -- Patrones de 7 segmentos para la Basys 3.
    -- Orden del vector: índice 0..6 = segmentos a,b,c,d,e,f,g (igual que seg[0..6] del XDC).
    -- Nivel activo BAJO: '0' = segmento encendido, '1' = apagado.
    -- El punto decimal (dp) NO va aquí (es una señal aparte).
    --
    --        aaa
    --       f   b
    --        ggg
    --       e   c
    --        ddd
    function f_basys3_character_to_segments(input : t_display_chars) return t_display_segment is
    begin
        case input is
            --                            abcdefg     segmentos encendidos
            when CHAR_0 => return "0000001";  -- a b c d e f
            when CHAR_1 => return "1001111";  -- b c
            when CHAR_2 => return "0010010";  -- a b d e g
            when CHAR_3 => return "0000110";  -- a b c d g
            when CHAR_4 => return "1001100";  -- b c f g
            when CHAR_5 => return "0100100";  -- a c d f g
            when CHAR_6 => return "0100000";  -- a c d e f g
            when CHAR_7 => return "0001111";  -- a b c
            when CHAR_8 => return "0000000";  -- a b c d e f g
            when CHAR_9 => return "0000100";  -- a b c d f g
            when CHAR_A => return "0001000";  -- a b c e f g
            when CHAR_B => return "1100000";  -- c d e f g   (b minúscula)
            when CHAR_C => return "0110001";  -- a d e f
            when CHAR_D => return "1000010";  -- b c d e g   (d minúscula)
            when CHAR_E => return "0110000";  -- a d e f g
            when CHAR_F => return "0111000";  -- a e f g
            when CHAR_G => return "0100001";  -- a c d e f
            when CHAR_H => return "1001000";  -- b c e f g
            when CHAR_I => return "1101111";  -- c
            when CHAR_J => return "1000011";  -- b c d e
            when CHAR_K => return "0011010";  -- '?': la K necesita diagonales, no representable
            when CHAR_L => return "1110001";  -- d e f
            when CHAR_M => return "0011010";  -- '?': la M necesita 4 trazos/diagonales, no representable
            when CHAR_N => return "1101010";  -- c e g     (n minúscula)
            when CHAR_O => return "1100010";  -- c d e g    (o minúscula, para no confundir con "0")
            when CHAR_P => return "0011000";  -- a b e f g
            when CHAR_Q => return "0001100";  -- a b c f g  (q minúscula)
            when CHAR_R => return "1111010";  -- e g       (r minúscula)
            when CHAR_S => return "0100100";  -- a c d f g  (idéntico al "5")
            when CHAR_T => return "1110000";  -- d e f g    (t minúscula)
            when CHAR_U => return "1000001";  -- b c d e f
            when CHAR_V => return "0011010";  -- '?': la V necesita diagonales, no representable
            when CHAR_W => return "0011010";  -- '?': la W necesita diagonales, no representable
            when CHAR_X => return "1001000";  -- b c e f g
            when CHAR_Y => return "1000100";  -- b c d f g  (y minúscula)
            when CHAR_Z => return "0010010";  -- a b d e g (igual que "2")
            -- Glifos de un único segmento encendido (para test/animaciones del display)
            when S_U    => return "0111111";  -- solo a (superior)
            when S_UL   => return "1111101";  -- solo f (superior izquierdo)
            when S_LL   => return "1111011";  -- solo e (inferior izquierdo)
            when S_L    => return "1110111";  -- solo d (inferior)
            when S_LR   => return "1101111";  -- solo c (inferior derecho)
            when S_UR   => return "1011111";  -- solo b (superior derecho)
            when S_M    => return "1111110";  -- solo g (central)
            -- Glifo vacío
            when S_OFF  => return "1111111"; -- todos los leds apagado
            when others => return "1111111";  -- (defensivo) glifo sin patrón: display apagado
        end case;

    end function f_basys3_character_to_segments;

    function f_basys3_nibble_to_char(input : std_logic_vector) return t_display_chars is
        variable v_natural : natural := to_integer(unsigned(input));
    begin
        case v_natural is
            when 0      => return CHAR_0;
            when 1      => return CHAR_1;
            when 2      => return CHAR_2;
            when 3      => return CHAR_3;
            when 4      => return CHAR_4;
            when 5      => return CHAR_5;
            when 6      => return CHAR_6;
            when 7      => return CHAR_7;
            when 8      => return CHAR_8;
            when 9      => return CHAR_9;
            when 10     => return CHAR_A;
            when 11     => return CHAR_B;
            when 12     => return CHAR_C;
            when 13     => return CHAR_D;
            when 14     => return CHAR_E;
            when 15     => return CHAR_F;
            when others => return CHAR_U; 
        end case;
    end function f_basys3_nibble_to_char;

end package body;