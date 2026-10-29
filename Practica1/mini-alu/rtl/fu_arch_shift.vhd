library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ctes_pkg.all;
use work.types_pkg.all;

architecture fu_shifter of functional_unit is

    signal s_op_a, s_op_b : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_args         : std_logic_vector(C_OP_ARG_BW - 1 downto 0);

    signal s_result : std_logic_vector(C_DATA_BW - 1 downto 0);

begin

    s_op_a <= inputs.operand_a;
    s_op_b <= inputs.operand_b;
    s_args <= inputs.operation_args;

    -- Desplaza operand_a a la derecha o a la izquierda tantas posiciones como
    -- indique operand_b interpretado como entero sin signo.
    --  * Con unsigned, los huecos que quedan se rellenan con '0'
    --  * Con signed y desplazamiento a la derecha, se rellena con el bit de
    --    signo (MSB) para conservar el signo del número
    p_shift : process(s_op_a, s_op_b, s_args)
    begin
        case s_args is
            when C_ARG_SHR_U =>
                s_result <= std_logic_vector(shift_right(unsigned(s_op_a), to_integer(unsigned(s_op_b))));
            when C_ARG_SHR_S =>
                s_result <= std_logic_vector(shift_right(signed(s_op_a), to_integer(unsigned(s_op_b))));
            when C_ARG_SHL_U =>
                s_result <= std_logic_vector(shift_left(unsigned(s_op_a), to_integer(unsigned(s_op_b))));
            when C_ARG_SHL_S =>
                s_result <= std_logic_vector(shift_left(signed(s_op_a), to_integer(unsigned(s_op_b))));
            when others =>
                s_result <= (others => '0');
        end case;
    end process p_shift;

    -- Conectamos las señales internas a las salidas
    outputs.result     <= s_result;
    -- Esta unidad no devuelve ningún error
    outputs.error_flag <= '0';
    outputs.error_code <= C_STATUS_OK;

end architecture fu_shifter;
