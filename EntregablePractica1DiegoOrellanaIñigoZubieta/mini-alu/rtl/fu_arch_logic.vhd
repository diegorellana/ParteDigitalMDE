library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ctes_pkg.all;
use work.types_pkg.all;

architecture fu_logic of functional_unit is

    signal s_op_a, s_op_b : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_args         : std_logic_vector(C_OP_ARG_BW - 1 downto 0);

    signal s_result     : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_error_flag : std_logic;
    signal s_error_code : std_logic_vector(C_ERROR_BW - 1 downto 0);

begin

    s_op_a <= inputs.operand_a;
    s_op_b <= inputs.operand_b;
    s_args <= inputs.operation_args;

    -- Calcula la operación AND, OR o XOR bit a bit entre los operandos A y B
    -- según el argumento del opcode.
    -- En caso de que el argumento no sea válido, el resultado se deja en "todo ceros"
    p_logic : process(s_op_a, s_op_b, s_args)
    begin
        case s_args is
            when C_ARG_AND =>
                s_result <= s_op_a and s_op_b;
            when C_ARG_OR =>
                s_result <= s_op_a or s_op_b;
            when C_ARG_XOR =>
                s_result <= s_op_a xor s_op_b;
            when others =>
                s_result <= (others => '0');
        end case;
    end process p_logic;

    p_error_check : process(s_args)
    begin
        -- Asumimos inicialmente que no hay error.
        s_error_flag <= '0';
        s_error_code <= C_STATUS_OK;

        -- El único error posible es un argumento no válido
        case s_args is
            when C_ARG_AND | C_ARG_OR | C_ARG_XOR =>
                null;
            when others =>
                s_error_flag <= '1';
                s_error_code <= C_ERROR_INVALID_ARGUMENT;
        end case;
    end process p_error_check;

    -- Conectamos las señales internas a las salidas
    outputs.result     <= s_result;
    outputs.error_flag <= s_error_flag;
    outputs.error_code <= s_error_code;

end architecture fu_logic;
