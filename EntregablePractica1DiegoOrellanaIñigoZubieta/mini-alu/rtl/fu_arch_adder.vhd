library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ctes_pkg.all;
use work.types_pkg.all;

architecture fu_adder of functional_unit is

    signal s_op_a, s_op_b : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_args         : std_logic_vector(C_OP_ARG_BW - 1 downto 0);

    signal s_result     : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal s_error_flag : std_logic;
    signal s_error_code : std_logic_vector(C_ERROR_BW - 1 downto 0);

begin

    s_op_a <= inputs.operand_a;
    s_op_b <= inputs.operand_b;
    s_args <= inputs.operation_args;

    -- Calcula la suma de los operandos de entrada A y B cuando el argumento del 
    -- opcode indica que estos se interpretan como unsigned o signed.
    -- En caso de que el argumento no sea válido, la suma se deja en "todo ceros"
    p_suma : process(s_op_a, s_op_b, s_args)
    begin
        case s_args is
            when C_ARG_UNSIGNED =>
                s_result <= std_logic_vector(unsigned(s_op_a) + unsigned(s_op_b));
            when C_ARG_SIGNED =>
                s_result <= std_logic_vector(signed(s_op_a) + signed(s_op_b));
            when others => 
                s_result <= (others => '0');
        end case;
    end process p_suma;

    p_error_check : process(s_op_a, s_op_b, s_args, s_result)
    begin
        -- Asumimos inicialmente que no hay error.
        s_error_flag <= '0';
        s_error_code <= C_STATUS_OK;

        -- Analizamos sólo los casos que pueden generar un error.
        -- Los valores por defecto anteriores nos evitan analizar el resto
        -- de casos.
        
        case s_args is
            when C_ARG_UNSIGNED =>
                -- Truco: como los operandos son unsigned (positivos iguales o mayores que 0)
                -- una forma rápida de indentificar la condición de overflow es mirar si el
                -- resultado de la suma es menor que cualquiera de los operandos de entrada.
                -- Por simplicidad, tomaremos operand_a como referencia
                if (unsigned(s_result) < unsigned(s_op_a)) then
                    s_error_flag <= '1';
                    s_error_code <= C_ERROR_OVERFLOW;
                end if;
            when C_ARG_SIGNED =>
                -- Regla: con sumas entre números signed, las condiciones de overflow y underflow
                -- sólo ocurren cuando ambos operandos tienen el mismo signo
                --  * Si ambos operandos son iguales o mayores a cero (su bit mas significativo, 
                --    MSB, es '0'), entonces ocurre overflow cuando el resultado se interpreta como 
                --    un número negativo (su MSB es '1')
                --  * Si ambos operandos son negativos (su MSB es '1'), hay underflow cuando el 
                --    resultado se interpreta como positivo (su MSB es '0')
                
                -- Para determinar la polaridad del MSB de un std_logic_vector, podemos consultar su
                -- atributo high, que devuelve el mayor índice del vector

                if (s_op_a(s_op_a'high) = s_op_b(s_op_b'high)) then
                    -- Ambos operandos tienen el mismo signo, por lo que hay que analizar el
                    -- signo de la suma para confirmar o descartar un overflow o underflow

                    if (s_op_a(s_op_a'high) /= s_result(s_result'high)) then
                        -- El signo del primer operando no concuerda con el del resultdao, por lo que
                        --  * Hay overflow si el operando A es positivo
                        --  * Hay underflow si el operando A es negativo

                        s_error_flag <= '1';

                        if (s_op_a(s_op_a'high) = '1') then
                            -- El operando es negativo, por lo que ha ocurrido un underflow
                            s_error_code <= C_ERROR_UNDERFLOW;
                        else
                            -- El operando es positivo, por lo que ha ocurrido un overflow
                            s_error_code <= C_ERROR_OVERFLOW;
                        end if;
                    end if;
                end if;
            when others =>
                -- El sumador no admite otros argumentos
                s_error_flag <= '1';
                s_error_code <= C_ERROR_INVALID_ARGUMENT;
        end case;
    end process p_error_check;

    -- Conectamos las señales internas a las salidas
    outputs.result     <= s_result;
    outputs.error_flag <= s_error_flag;
    outputs.error_code <= s_error_code;

end architecture fu_adder;