library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ctes_pkg.all;
use work.types_pkg.all;

--Declaración de arquitectura
architecture fu_comparator of functional_unit is

    --Quiénes son los inputs
    signal s_op_a, s_op_b : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_args         : std_logic_vector(C_OP_ARG_BW - 1 downto 0);

    --Quiénes son los outputs
    signal s_result : std_logic_vector(C_DATA_BW - 1 downto 0);

begin

    --Asignación
    s_op_a <= inputs.operand_a;
    s_op_b <= inputs.operand_b;
    s_args <= inputs.operation_args;

    -- Compara los operandos A y B y copia en result el mayor o el menor,
    -- interpretándolos como unsigned o signed según operation_args:
    --   00: unsigned, mayor   01: signed, mayor
    --   10: unsigned, menor   11: signed, menor
    p_comp : process(s_op_a, s_op_b, s_args)
    begin
        case s_args is
            when C_ARG_CMP_U_G =>
                if unsigned(s_op_a) >= unsigned(s_op_b) then
                    s_result <= s_op_a;
                else
                    s_result <= s_op_b;
                end if;
            when C_ARG_CMP_S_G =>
                if signed(s_op_a) >= signed(s_op_b) then
                    s_result <= s_op_a;
                else
                    s_result <= s_op_b;
                end if;
            when C_ARG_CMP_U_L =>
                if unsigned(s_op_a) <= unsigned(s_op_b) then
                    s_result <= s_op_a;
                else
                    s_result <= s_op_b;
                end if;
            when C_ARG_CMP_S_L =>
                if signed(s_op_a) <= signed(s_op_b) then
                    s_result <= s_op_a;
                else
                    s_result <= s_op_b;
                end if;
            when others =>
                s_result <= (others => '0');
        end case;
    end process p_comp;

    -- Conectamos las señales internas a las salidas
    outputs.result     <= s_result;
    -- Esta unidad no devuelve ningún error
    outputs.error_flag <= '0';
    outputs.error_code <= C_STATUS_OK;

end architecture fu_comparator;
