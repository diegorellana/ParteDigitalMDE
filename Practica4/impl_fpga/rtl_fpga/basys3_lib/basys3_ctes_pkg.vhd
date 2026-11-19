library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package basys3_ctes_pkg is

    constant c_clk_period         : time := 10 ns;
    constant c_debounce_time      : time := 100 ms;
    constant c_ssd_char_time      : time := 250 us;
    constant c_n_display_elements : integer := 4;
    constant c_n_display_segments : integer := 7;
    constant c_n_switches         : integer := 16;
    constant c_n_leds             : integer := 16;
    constant c_pmod_width         : integer := 8;

end package basys3_ctes_pkg;