-- =============================================================================
-- tb_top_mini_alu.vhd - banco de pruebas de la mini-ALU.
--
-- Los estímulos no están escritos en el código: se leen de un fichero de texto
-- en sim/in. Cada caso de prueba ocupa siete líneas, una por valor:
--
--      operand_a, operand_b, operation_code, operation_args,
--      y los tres valores que se esperan: result, error_flag, error_code
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- textio es la librería estándar para leer y escribir ficheros de texto.
use std.textio.all;
-- env contiene las funciones para terminar limpiamente la simulación
use std.env.all;

use work.ctes_pkg.all;

-- La entidad del testbench no tiene puertos ni de entrada ni de salida.
entity tb_top_mini_alu is
end entity tb_top_mini_alu;

architecture banco of tb_top_mini_alu is

    -- Nombre del archivo que contiene los estímulos y salidas esperadas
    constant C_FICHERO_ESTIMULOS : string := "../in/estimulos.txt";

    -- El diseño de top_mini_alu es puramente combinacional: un cambio en las entradas
    -- se propaga a la salida en ciclos delta, no en tiempo físico. 
    -- Añadimos una espera tras cada asignación para simular el paso de tiempo
    -- y poder analizar los cambios en el Waveform del simulador.
    constant C_ESPERA : time := 1 ms;

    -- Entradas del diseño bajo prueba
    signal tb_operand_a      : std_logic_vector(C_DATA_BW - 1 downto 0)    := (others => '0');
    signal tb_operand_b      : std_logic_vector(C_DATA_BW - 1 downto 0)    := (others => '0');
    signal tb_operation_code : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := (others => '0');
    signal tb_operation_args : std_logic_vector(C_OP_ARG_BW - 1 downto 0)  := (others => '0');

    -- Salidas del diseño bajo prueba
    signal tb_result     : std_logic_vector(C_DATA_BW - 1 downto 0);
    signal tb_error_flag : std_logic;
    signal tb_error_code : std_logic_vector(C_ERROR_BW - 1 downto 0);

begin

    -- -------------------------------------------------------------------------
    -- Diseño bajo prueba (DUT)
    -- -------------------------------------------------------------------------
    dut : entity work.top_mini_alu(top_alu_arch)
        port map (
            operand_a      => tb_operand_a,
            operand_b      => tb_operand_b,
            operation_code => tb_operation_code,
            operation_args => tb_operation_args,
            result         => tb_result,
            error_flag     => tb_error_flag,
            error_code     => tb_error_code
        );

    -- -------------------------------------------------------------------------
    -- Estímulos y comprobación
    --      Abre el archivo de estímulos, lee y asigna las entradas al DUT,
    --      avanza el tiempo y comprueba las salidas.
    -- -------------------------------------------------------------------------
    p_estimulos : process

        -- El fichero se abre al arrancar la simulación y se cierra al acabar.
        file f_estimulos : text open read_mode is C_FICHERO_ESTIMULOS;

        variable v_linea : line;

        -- Los operandos y el resultado se leen del fichero como enteros con
        -- signo. El mod se queda con los bits de menos peso, que es la
        -- representación binaria que va al puerto.
        variable v_int : integer;

        -- Valores que se aplican a las entradas
        variable v_op_a : std_logic_vector(C_DATA_BW - 1 downto 0);
        variable v_op_b : std_logic_vector(C_DATA_BW - 1 downto 0);
        variable v_code : std_logic_vector(C_OP_CODE_BW - 1 downto 0);
        variable v_args : std_logic_vector(C_OP_ARG_BW - 1 downto 0);

        -- Valores que se esperan en las salidas
        variable v_esp_result : std_logic_vector(C_DATA_BW - 1 downto 0);
        variable v_esp_flag   : std_logic;
        variable v_esp_code   : std_logic_vector(C_ERROR_BW - 1 downto 0);

        variable v_num_caso : natural := 0;

    begin

        while not endfile(f_estimulos) loop

            -- Se lee una línea. Si está en blanco o empieza por #, se descarta
            -- y se vuelve a empezar.
            readline(f_estimulos, v_linea);
            next when v_linea.all'length = 0 or v_linea.all(1) = '#';

            -- Si no era un comentario, es el primer valor del caso, y detrás
            -- vienen las otras seis líneas.
            read(v_linea, v_int);
            v_op_a := std_logic_vector(to_unsigned(v_int mod 2**C_DATA_BW, C_DATA_BW));

            readline(f_estimulos, v_linea);   read(v_linea, v_int);
            v_op_b := std_logic_vector(to_unsigned(v_int mod 2**C_DATA_BW, C_DATA_BW));

            readline(f_estimulos, v_linea);   read(v_linea, v_code);
            readline(f_estimulos, v_linea);   read(v_linea, v_args);

            readline(f_estimulos, v_linea);   read(v_linea, v_int);
            v_esp_result := std_logic_vector(to_unsigned(v_int mod 2**C_DATA_BW, C_DATA_BW));

            readline(f_estimulos, v_linea);   read(v_linea, v_esp_flag);
            readline(f_estimulos, v_linea);   read(v_linea, v_esp_code);

            v_num_caso := v_num_caso + 1;

            -- Aplicar el estímulo
            tb_operand_a      <= v_op_a;
            tb_operand_b      <= v_op_b;
            tb_operation_code <= v_code;
            tb_operation_args <= v_args;

            wait for C_ESPERA;

            -- Comprobar las tres salidas
            assert tb_result = v_esp_result
                report "Caso " & integer'image(v_num_caso) & ": se esperaba result = " &
                       to_string(v_esp_result) & " y se ha obtenido " & to_string(tb_result)
                severity error;

            assert tb_error_flag = v_esp_flag
                report "Caso " & integer'image(v_num_caso) & ": se esperaba error_flag = " &
                       to_string(v_esp_flag) & " y se ha obtenido " & to_string(tb_error_flag)
                severity error;

            assert tb_error_code = v_esp_code
                report "Caso " & integer'image(v_num_caso) & ": se esperaba error_code = " &
                       to_string(v_esp_code) & " y se ha obtenido " & to_string(tb_error_code)
                severity error;

            wait for C_ESPERA;

        end loop;

        report "Casos comprobados: " & integer'image(v_num_caso) severity note;

        -- Fin de los estímulos. Terminamos la simulación.
        -- Hay varias formas de hacerlo:

        -- -------------------------------------------------------------------------
        -- Método clásico pre-VHDL 2008: provocar un error con una severidad lo 
        -- suficientemente alta como para parar la simulación
        -- -------------------------------------------------------------------------

        -- assert false report "Simulación completa" severity failure;

        -- -------------------------------------------------------------------------
        -- Pausar la simulación sin cerrar el simulador: útil para analizar cómo ha 
        -- quedado el waveform. Definido en std.env.stop en VHDL 2008 y posteriores.
        -- -------------------------------------------------------------------------

        stop;

        -- -------------------------------------------------------------------------
        -- Pausar y cerrar el simulador. Cierra Questa al ejecutarse. Definido en 
        -- std.env.finish en VHDL 2008 y posteriores.
        -- -------------------------------------------------------------------------

        -- finish;


    end process p_estimulos;

end architecture banco;
