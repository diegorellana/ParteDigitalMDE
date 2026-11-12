library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ctes_pkg.all;
use work.types_pkg.all;

architecture fu_nibble_swap of functional_unit is

    signal s_op_a, s_op_b : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_args         : std_logic_vector(C_OP_ARG_BW - 1 downto 0);

    signal s_result     : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_error_flag : std_logic;
    signal s_error_code : std_logic_vector(C_ERROR_BW - 1 downto 0);

begin

    s_op_a <= inputs.operand_a;
    s_op_b <= inputs.operand_b;
    s_args <= inputs.operation_args;

    -- Ensambla el resultado juntando (con el operador &) un nibble de cada operando.
    -- Un nibble son 4 bits: el alto son los bits 7..4 y el bajo los bits 3..0
    --  * C_ARG_MALB: nibble alto de A con nibble bajo de B
    --  * C_ARG_MBLA: nibble alto de B con nibble bajo de A
    -- En caso de que el argumento no sea válido, el resultado se deja en "todo ceros"
    p_nibble_swap : process(s_op_a, s_op_b, s_args)
    begin
        case s_args is
            when C_ARG_MALB =>
                s_result <= s_op_a(7 downto 4) & s_op_b(3 downto 0);
            when C_ARG_MBLA =>
                s_result <= s_op_b(7 downto 4) & s_op_a(3 downto 0);
            when others =>
                s_result <= (others => '0');
        end case;
    end process p_nibble_swap;

    p_error_check : process(s_args)
    begin
        -- Asumimos inicialmente que no hay error.
        s_error_flag <= '0';
        s_error_code <= C_STATUS_OK;

        -- El único error posible es un argumento no válido
        case s_args is
            when C_ARG_MALB | C_ARG_MBLA =>
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

end architecture fu_nibble_swap;
