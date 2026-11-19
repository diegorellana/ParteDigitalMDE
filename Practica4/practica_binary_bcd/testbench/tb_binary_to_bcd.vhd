--==============================================================================
-- tb_binary_to_bcd.vhd - banco de pruebas de binary_to_bcd.
--
-- Fases del estímulo:
--   1. El cronograma de la sección 3.5 del enunciado: 7 y 42 seguidos, un
--      ciclo sin valid_in y luego 999.
--   2. Todos los valores de 14 bits, de 0 a 2**14 - 1, uno por ciclo. Los
--      que pasan de 9999 tienen que salir saturados a 9999.
--   3. 3000 valores pseudoaleatorios con huecos en valid_in, para comprobar
--      que valid_out sigue alineado con bcd_out.
--
-- Comprobaciones:
--   - Cada vez que valid_out = '1', bcd_out tiene que ser la conversión del
--     siguiente valor enviado (en el mismo orden en que entraron).
--   - El número de resultados tiene que ser igual al de peticiones.
--   - La latencia (ciclos entre valid_in y valid_out) tiene que ser
--     (unos de gen_pipeline) + 2.
--
-- g_pipeline permite probar otras configuraciones desde Questa:
--   vsim -voptargs=+acc -gg_pipeline=10101010101010 work.tb_binary_to_bcd
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library binary_to_bcd_lib;
use binary_to_bcd_lib.ctes_pkg.all;
use binary_to_bcd_lib.functions_pkg.all;

entity tb_binary_to_bcd is
    generic (
        g_pipeline : std_logic_vector(C_BINARY_BW - 1 downto 0) := C_PIPELINE
    );
end entity tb_binary_to_bcd;

architecture tb of tb_binary_to_bcd is

    constant c_clk_period : time := 10 ns;

    constant c_latencia_esperada : integer := f_count_ones_in_vector(g_pipeline) + 2;

    -- Número de peticiones de cada fase
    constant c_n_fase1 : integer := 3;
    constant c_n_fase2 : integer := 2**C_BINARY_BW;
    constant c_n_fase3 : integer := 3000;
    constant c_n_total : integer := c_n_fase1 + c_n_fase2 + c_n_fase3;

    signal tb_clk       : std_logic := '0';
    signal tb_reset_n   : std_logic := '0';
    signal tb_binary_in : std_logic_vector(C_BINARY_BW - 1 downto 0) := (others => '0');
    signal tb_valid_in  : std_logic := '0';
    signal tb_bcd_out   : std_logic_vector(C_BCD_BW - 1 downto 0);
    signal tb_valid_out : std_logic;

    signal tb_fin_estimulos : boolean := false;

    -- Valor que se envía en la petición número k (empezando en 0).
    -- El comprobador usa la misma función para saber qué tiene que salir.
    function f_estimulo(k : integer) return integer is
    begin
        if k = 0 then
            return 7;
        elsif k = 1 then
            return 42;
        elsif k = 2 then
            return 999;
        elsif k < c_n_fase1 + c_n_fase2 then
            return k - c_n_fase1;
        else
            return ((k - c_n_fase1 - c_n_fase2) * 7919 + 1234) mod 2**C_BINARY_BW;
        end if;
    end function f_estimulo;

    -- Modelo de referencia: saturación y conversión a BCD con divisiones
    -- (en el testbench se puede, no se sintetiza).
    function f_bcd_esperado(valor : integer) return std_logic_vector is
        variable v_valor : integer := valor;
        variable v_bcd   : std_logic_vector(C_BCD_BW - 1 downto 0);
    begin
        if v_valor > C_MAX_BINARY_VALUE then
            v_valor := C_MAX_BINARY_VALUE;
        end if;
        for I in 0 to C_DECIMAL_DIGITS - 1 loop
            v_bcd((I + 1) * C_BITS_PER_NIBBLE - 1 downto I * C_BITS_PER_NIBBLE) :=
                std_logic_vector(to_unsigned(v_valor mod 10, C_BITS_PER_NIBBLE));
            v_valor := v_valor / 10;
        end loop;
        return v_bcd;
    end function f_bcd_esperado;

    -- Para escribir el BCD en los mensajes como "0042"
    function f_bcd_a_texto(bcd : std_logic_vector(C_BCD_BW - 1 downto 0)) return string is
        variable v_texto : string(1 to C_DECIMAL_DIGITS);
        variable v_digito : integer;
    begin
        for I in 0 to C_DECIMAL_DIGITS - 1 loop
            v_digito := to_integer(unsigned(bcd((I + 1) * C_BITS_PER_NIBBLE - 1 downto I * C_BITS_PER_NIBBLE)));
            if v_digito <= 9 then
                v_texto(C_DECIMAL_DIGITS - I) := character'val(character'pos('0') + v_digito);
            else
                v_texto(C_DECIMAL_DIGITS - I) := '?';
            end if;
        end loop;
        return v_texto;
    end function f_bcd_a_texto;

begin

    tb_clk <= not tb_clk after c_clk_period / 2;

    dut : entity work.binary_to_bcd
        generic map (
            gen_binary_bw        => C_BINARY_BW,
            gen_bcd_bw           => C_BCD_BW,
            gen_max_binary_value => C_MAX_BINARY_VALUE,
            gen_pipeline         => g_pipeline
        )
        port map (
            clk       => tb_clk,
            reset_n   => tb_reset_n,
            binary_in => tb_binary_in,
            valid_in  => tb_valid_in,
            bcd_out   => tb_bcd_out,
            valid_out => tb_valid_out
        );

    ---------------------------------------------------------------------------
    -- Estímulos
    ---------------------------------------------------------------------------
    p_estimulos : process
        -- Una petición de conversión durante un ciclo
        procedure enviar(k : integer) is
        begin
            tb_binary_in <= std_logic_vector(to_unsigned(f_estimulo(k), C_BINARY_BW));
            tb_valid_in  <= '1';
            wait until rising_edge(tb_clk);
        end procedure enviar;

        -- Ciclos sin petición. binary_in se pone a un valor cualquiera para
        -- comprobar que no se convierte nada si valid_in = '0'.
        procedure esperar(n : integer) is
        begin
            tb_binary_in <= (others => '1');
            tb_valid_in  <= '0';
            for I in 1 to n loop
                wait until rising_edge(tb_clk);
            end loop;
        end procedure esperar;

        variable k : integer := 0;
    begin
        -- Reset
        tb_reset_n <= '0';
        esperar(3);
        tb_reset_n <= '1';
        esperar(2);

        -- Fase 1: cronograma del enunciado
        report "Fase 1: cronograma del enunciado (7, 42, -, 999)";
        enviar(0);
        enviar(1);
        esperar(1);
        enviar(2);
        k := c_n_fase1;
        esperar(c_latencia_esperada + 3);

        -- Fase 2: todos los valores, uno por ciclo
        report "Fase 2: valores de 0 a " & integer'image(c_n_fase2 - 1);
        while k < c_n_fase1 + c_n_fase2 loop
            enviar(k);
            k := k + 1;
        end loop;
        esperar(c_latencia_esperada + 3);

        -- Fase 3: valores con huecos de 0, 1 o 2 ciclos entre peticiones
        report "Fase 3: " & integer'image(c_n_fase3) & " valores con huecos en valid_in";
        while k < c_n_total loop
            enviar(k);
            esperar(k mod 3);
            k := k + 1;
        end loop;

        esperar(c_latencia_esperada + 5);
        tb_fin_estimulos <= true;
        wait;
    end process p_estimulos;

    ---------------------------------------------------------------------------
    -- Comprobación de resultados y de latencia
    ---------------------------------------------------------------------------
    p_comprobacion : process
        variable v_n_resultados : integer := 0;
        variable v_n_errores    : integer := 0;
        variable v_ciclo        : integer := 0;
        variable v_ciclo_valid_in  : integer := -1;
        variable v_ciclo_valid_out : integer := -1;
        variable v_esperado     : std_logic_vector(C_BCD_BW - 1 downto 0);
    begin
        wait until rising_edge(tb_clk);
        v_ciclo := v_ciclo + 1;

        -- Primer valid_in y primer valid_out, para medir la latencia
        if tb_valid_in = '1' and v_ciclo_valid_in < 0 then
            v_ciclo_valid_in := v_ciclo;
        end if;

        if tb_valid_out = '1' then
            if v_ciclo_valid_out < 0 then
                v_ciclo_valid_out := v_ciclo;
                assert v_ciclo_valid_out - v_ciclo_valid_in = c_latencia_esperada
                    report "Latencia incorrecta: " &
                           integer'image(v_ciclo_valid_out - v_ciclo_valid_in) &
                           " ciclos, se esperaban " & integer'image(c_latencia_esperada)
                    severity error;
                report "Latencia medida: " &
                       integer'image(v_ciclo_valid_out - v_ciclo_valid_in) & " ciclos";
            end if;

            if v_n_resultados >= c_n_total then
                report "valid_out = '1' sin petición pendiente" severity error;
                v_n_errores := v_n_errores + 1;
            else
                v_esperado := f_bcd_esperado(f_estimulo(v_n_resultados));
                if tb_bcd_out /= v_esperado then
                    v_n_errores := v_n_errores + 1;
                    report "Error en el resultado " & integer'image(v_n_resultados) &
                           ": entrada " & integer'image(f_estimulo(v_n_resultados)) &
                           ", bcd_out = " & f_bcd_a_texto(tb_bcd_out) &
                           ", esperado " & f_bcd_a_texto(v_esperado)
                        severity error;
                end if;
                -- Los tres primeros, para ver el cronograma en el transcript
                if v_n_resultados < c_n_fase1 then
                    report "Entrada " & integer'image(f_estimulo(v_n_resultados)) &
                           " -> bcd_out = " & f_bcd_a_texto(tb_bcd_out);
                end if;
            end if;
            v_n_resultados := v_n_resultados + 1;
        end if;

        if tb_fin_estimulos then
            assert v_n_resultados = c_n_total
                report "Se esperaban " & integer'image(c_n_total) &
                       " resultados y han salido " & integer'image(v_n_resultados)
                severity error;
            if v_n_errores = 0 and v_n_resultados = c_n_total then
                report "SIMULACION CORRECTA: " & integer'image(v_n_resultados) &
                       " conversiones sin errores";
            else
                report "SIMULACION CON ERRORES: " & integer'image(v_n_errores) &
                       " errores" severity error;
            end if;
            std.env.stop;
            wait;
        end if;
    end process p_comprobacion;

end architecture tb;
