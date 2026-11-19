library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library binary_to_bcd_lib;
use binary_to_bcd_lib.ctes_pkg.all;

package subtypes_pkg is
    subtype t_nibble is std_logic_vector(C_BITS_PER_NIBBLE - 1 downto 0);
end package subtypes_pkg;