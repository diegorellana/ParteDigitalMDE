library ieee;
use ieee.std_logic_1164.all;

library basys3_lib;
use basys3_lib.basys3_ctes_pkg.all;
use basys3_lib.basys3_types_pkg.all;

package basys3_components_pkg is

    component debouncer is
    port (
        clk          : in std_logic;
        reset_n      : in std_logic;
        input_value  : in std_logic;
        output_value : out std_logic        
    );
    end component debouncer;

    component seven_segment_display_adapter is
    port (
        clk         : in std_logic;
        reset_n     : in std_logic;
        input_chars : in t_display_word;
        input_dots  : in std_logic_vector(0 to c_n_display_elements - 1);
        anodes      : out std_logic_vector(0 to c_n_display_elements - 1);
        segments    : out std_logic_vector(0 to c_n_display_segments - 1);
        dp          : out std_logic
    );    
    end component seven_segment_display_adapter;

end package basys3_components_pkg;
