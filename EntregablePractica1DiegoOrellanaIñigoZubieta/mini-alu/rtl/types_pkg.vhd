library ieee;
use ieee.std_logic_1164.all;

use work.ctes_pkg.all;

package types_pkg is

    type fu_inputs is record
        operand_a      : std_logic_vector(C_DATA_BW - 1 downto 0);
        operand_b      : std_logic_vector(C_DATA_BW - 1 downto 0);
        operation_args : std_logic_vector(C_OP_ARG_BW - 1 downto 0);
    end record;

    type fu_outputs is record
        result     : std_logic_vector(C_DATA_BW - 1 downto 0);
        error_flag : std_logic;
        error_code : std_logic_vector(C_ERROR_BW - 1 downto 0);
    end record;
end package types_pkg;