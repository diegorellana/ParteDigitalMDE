library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ctes_pkg.all;
use work.types_pkg.all;


--Declaración de arquitectura
architecture fu_substracter of functional_unit is

    --Quiénes son los inputs
    signal s_op_a, s_op_b : std_logic_vector(C_DATA_BW -1 downto 0);    -- operandos de ancho C_DATA_BW que vienen incluidos en pkg
    signal s_args         : std_logic_vector(C_OP_ARG_BW - 1 downto 0); -- args se usa en shifter pero se tienen que declarar en todas

    --Quiénes son los outputs
    signal s_result     : std_logic_vector(C_DATA_BW - 1 downto 0);     -- resultado de resta
    signal s_error_flag : std_logic;                                    -- error flag
    signal s_error_code : std_logic_vector(C_ERROR_BW -1 downto 0);     -- codigo de error de ancho C_ERROR_BW
    
begin

    --Asignación
    s_op_a <= inputs.operand_a; 
    s_op_b <= inputs.operand_b;
    s_args <= inputs.operation_args;

    -- Calcula la resta de los operandos de entrada A y B cuando el argumento del 
    -- opcode indica que estos se interpretan como unsigned o signed.
    -- En caso de que el argumento no sea válido, la resta se deja en "todo ceros"

    p_resta : process(s_op_a, s_op_b, s_args)
    begin
        case s_args is
            when C_ARG_UNSIGNED =>
                s_result <= std_logic_vector(unsigned(s_op_a) - unsigned(s_op_b));
            when C_ARG_SIGNED =>
                s_result <= std_logic_vector(signed(s_op_a) - signed(s_op_b));
            when others =>
                s_result <= (others => '0');
        end case;
    end process p_resta;

    p_error_check : process (s_op_a, s_op_b, s_args, s_result)
    begin
    --Asumimos que inicialmente no hay error
    s_error_flag <= '0';
    s_error_code <= C_STATUS_OK;

    -- Analizamos sólo los casos que pueden generar un error.
        -- Los valores por defecto anteriores nos evitan analizar el resto
        -- de casos.
        
        case s_args is
            when C_ARG_UNSIGNED =>
                -- Truco: como los operandos son unsigned (positivos iguales o mayores que 0)
                -- una forma rápida de indentificar la condición de overflow es mirar si el
                -- resultado de la resta es mayor que cualquiera de los operandos de entrada.
                -- Por simplicidad, tomaremos operand_a como referencia
                if (unsigned(s_result) > unsigned(s_op_a)) then
                    s_error_flag <= '1';
                    s_error_code <= C_ERROR_UNDERFLOW;
                end if;
            when C_ARG_SIGNED =>
            -- Solo hay overflow/underflow si los operandos tienen signo DISTINTO
            if (s_op_a(s_op_a'high) /= s_op_b(s_op_b'high)) then
                -- El signo del resultado debería coincidir con el de A
                if (s_op_a(s_op_a'high) /= s_result(s_result'high)) then
                    s_error_flag <= '1';
                    if (s_op_a(s_op_a'high) = '1') then
                        s_error_code <= C_ERROR_UNDERFLOW;  -- A negativo, B positivo
                    else
                        s_error_code <= C_ERROR_OVERFLOW;   -- A positivo, B negativo
                    end if;
                end if;
            end if;

        when others =>
            s_error_flag <= '1';
            s_error_code <= C_ERROR_INVALID_ARGUMENT;
    end case;
end process p_error_check;

    -- Conectamos las señales internas a las salidas
    outputs.result     <= s_result;
    outputs.error_flag <= s_error_flag;
    outputs.error_code <= s_error_code;

end architecture fu_substracter;