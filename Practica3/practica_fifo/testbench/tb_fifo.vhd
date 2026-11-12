--==============================================================================
-- tb_fifo.vhd - banco de pruebas de la FIFO.
--
-- Es autocomprobado: p_checker lleva un modelo de la FIFO (una cola hecha con
-- un array y dos índices) y en cada flanco de subida compara empty, full,
-- read_valid y data_read del DUT con lo que diría el modelo. Así no hace
-- falta mirar las ondas a mano para saber si va bien.
--
-- p_stimuli hace los casos de la tabla de peticiones simultáneas (llena,
-- vacía, intermedio), un reset a mitad y luego un rato de peticiones
-- aleatorias. Al final dice cuántos errores ha habido.
--
-- La profundidad y el ancho son genéricos del banco, se pueden cambiar sin
-- tocar el código, por ejemplo:  vsim -gC_DEPTH=2 work.tb_fifo
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use std.env.all;

entity tb_fifo is
    generic (
        C_DEPTH : integer := 4;
        C_WIDTH : integer := 16
    );
end entity tb_fifo;

architecture behavioral of tb_fifo is

    constant C_RESET_WINDOW     : time := 100 ns;
    constant C_CLOCK_START_TIME : time := 200 ns;
    constant C_CLK_PERIOD       : time := 10 ns;

    -- Ciclos de la parte aleatoria
    constant C_RANDOM_CYCLES : integer := 5000;

    signal tb_clk     : std_logic := '0';
    signal tb_reset_n : std_logic := '0';

    signal tb_write_enable  : std_logic := '0';
    signal tb_data_to_write : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
    signal tb_read_enable   : std_logic := '0';
    signal tb_data_read     : std_logic_vector(C_WIDTH - 1 downto 0);
    signal tb_read_valid    : std_logic;
    signal tb_empty         : std_logic;
    signal tb_full          : std_logic;

    -- Lo pone p_stimuli al terminar, para que p_checker saque el resumen
    signal tb_done : boolean := false;

begin

    assert C_CLOCK_START_TIME > C_RESET_WINDOW report "El clock no tiene que generarse mientras la señal de reset está activa." severity failure;

    -- Generar clock (el reset lo lleva p_stimuli, porque hay uno a mitad)
    p_clock : process
    begin
        tb_clk <= '0';
        wait for C_CLOCK_START_TIME;
        loop
            tb_clk <= not tb_clk;
            wait for C_CLK_PERIOD / 2;
        end loop;
    end process p_clock;

    dut : entity work.fifo(rtl)
        generic map (
            gen_depth => C_DEPTH,
            gen_width => C_WIDTH
        )
        port map (
            clk           => tb_clk,
            reset_n       => tb_reset_n,
            write_enable  => tb_write_enable,
            data_to_write => tb_data_to_write,
            read_enable   => tb_read_enable,
            data_read     => tb_data_read,
            read_valid    => tb_read_valid,
            empty         => tb_empty,
            full          => tb_full
        );

    ----------------------------------------------------------------------------
    -- Estímulos. Todo se cambia justo después del flanco de subida, así el DUT
    -- lo ve estable en el flanco siguiente.
    ----------------------------------------------------------------------------
    p_stimuli : process

        -- Valor que se escribe: un contador, para que cada dato sea distinto y
        -- si sale uno desordenado se vea enseguida.
        variable v_data : integer := 1;

        variable v_seed1 : positive := 17;
        variable v_seed2 : positive := 42;
        variable v_rand  : real;

        -- Un ciclo con las peticiones que se le pasen
        procedure ciclo (we : std_logic; re : std_logic) is
        begin
            tb_write_enable  <= we;
            tb_read_enable   <= re;
            tb_data_to_write <= std_logic_vector(to_unsigned(v_data mod 2**C_WIDTH, C_WIDTH));
            if we = '1' then
                v_data := v_data + 1;
            end if;
            wait until rising_edge(tb_clk);
        end procedure ciclo;

        procedure escribir is
        begin
            ciclo('1', '0');
        end procedure escribir;

        procedure leer is
        begin
            ciclo('0', '1');
        end procedure leer;

        procedure nada is
        begin
            ciclo('0', '0');
        end procedure nada;

        procedure las_dos is
        begin
            ciclo('1', '1');
        end procedure las_dos;

    begin
        -- Reset inicial
        tb_reset_n <= '0';
        wait for C_RESET_WINDOW;
        tb_reset_n <= '1';
        wait until rising_edge(tb_clk);
        nada;

        report "Caso 1: leer con la FIFO vacía (se tiene que descartar)";
        leer;
        nada;

        report "Caso 2: llenar la FIFO y escribir una vez más (se descarta)";
        for i in 1 to C_DEPTH loop
            escribir;
        end loop;
        escribir;
        nada;

        report "Caso 3: escritura y lectura a la vez con la FIFO llena";
        las_dos;     -- se lee, la escritura se pierde
        las_dos;     -- ya no está llena: se hacen las dos
        nada;

        report "Caso 4: vaciar la FIFO y leer una vez más (se descarta)";
        for i in 1 to C_DEPTH loop
            leer;
        end loop;
        leer;
        nada;

        report "Caso 5: escritura y lectura a la vez con la FIFO vacía";
        las_dos;     -- se escribe, la lectura se pierde
        nada;

        report "Caso 6: escritura y lectura a la vez en un punto intermedio";
        escribir;
        for i in 1 to 2 * C_DEPTH loop
            las_dos; -- el contador no se mueve, los punteros dan vueltas
        end loop;
        nada;

        report "Caso 7: lecturas seguidas en ciclos consecutivos";
        for i in 1 to C_DEPTH loop
            escribir;
        end loop;
        for i in 1 to C_DEPTH + 1 loop
            leer;
        end loop;
        nada;

        report "Caso 8: reset con datos dentro (tiene que quedar vacía)";
        escribir;
        escribir;
        -- quito las peticiones antes del reset, si no la escritura se queda
        -- pedida y entra en el primer flanco después de soltar el reset
        tb_write_enable <= '0';
        tb_read_enable  <= '0';
        wait until falling_edge(tb_clk);
        tb_reset_n <= '0';
        wait for 3 * C_CLK_PERIOD;
        wait until falling_edge(tb_clk);
        tb_reset_n <= '1';
        wait until rising_edge(tb_clk);
        leer;        -- después del reset no puede salir nada
        nada;

        report "Caso 9: " & integer'image(C_RANDOM_CYCLES) & " ciclos de peticiones aleatorias";
        for i in 1 to C_RANDOM_CYCLES loop
            uniform(v_seed1, v_seed2, v_rand);
            -- cuatro combinaciones con la misma probabilidad
            if v_rand < 0.25 then
                nada;
            elsif v_rand < 0.5 then
                escribir;
            elsif v_rand < 0.75 then
                leer;
            else
                las_dos;
            end if;
        end loop;
        nada;
        nada;

        tb_done <= true;
        wait;
    end process p_stimuli;

    ----------------------------------------------------------------------------
    -- Comprobador. En cada flanco de subida mira las salidas que hay justo
    -- antes del flanco (lo que dejó el ciclo anterior) y luego avanza el modelo
    -- con las peticiones que el DUT ve en ese mismo flanco.
    ----------------------------------------------------------------------------
    p_checker : process

        type t_model is array (0 to C_DEPTH - 1) of std_logic_vector(C_WIDTH - 1 downto 0);
        variable v_mem   : t_model;
        variable v_wr    : integer range 0 to C_DEPTH - 1 := 0;
        variable v_rd    : integer range 0 to C_DEPTH - 1 := 0;
        variable v_count : integer range 0 to C_DEPTH := 0;

        -- Lo que debería salir por read_valid / data_read en el ciclo actual
        variable v_exp_valid : std_logic := '0';
        variable v_exp_data  : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');

        variable v_write_ok : boolean;
        variable v_read_ok  : boolean;

        variable v_errors : integer := 0;
        variable v_reads  : integer := 0;
        variable v_writes : integer := 0;
        variable v_lost_w : integer := 0;
        variable v_lost_r : integer := 0;

        procedure comprobar (cond : boolean; msg : string) is
        begin
            if not cond then
                v_errors := v_errors + 1;
                report msg & " (t = " & time'image(now) & ")" severity error;
            end if;
        end procedure comprobar;

    begin
        loop
            wait until rising_edge(tb_clk) or tb_done;
            exit when tb_done;

            if tb_reset_n = '0' then
                -- Con reset la FIFO se vacía; el contenido da igual
                v_wr := 0;
                v_rd := 0;
                v_count := 0;
                v_exp_valid := '0';
                comprobar(tb_empty = '1', "empty tiene que valer 1 durante el reset");
                comprobar(tb_read_valid = '0', "read_valid tiene que valer 0 durante el reset");
            else
                -- 1) Comprobar las salidas actuales
                comprobar((tb_empty = '1') = (v_count = 0),
                          "empty mal: ocupación " & integer'image(v_count));
                comprobar((tb_full = '1') = (v_count = C_DEPTH),
                          "full mal: ocupación " & integer'image(v_count));
                comprobar(tb_read_valid = v_exp_valid, "read_valid mal");
                if v_exp_valid = '1' then
                    comprobar(tb_data_read = v_exp_data,
                              "data_read mal: sale " & to_hstring(tb_data_read) &
                              " y debería ser " & to_hstring(v_exp_data));
                end if;

                -- 2) Qué se acepta en este flanco (según el estado de antes)
                v_write_ok := tb_write_enable = '1' and v_count < C_DEPTH;
                v_read_ok  := tb_read_enable = '1' and v_count > 0;

                if tb_write_enable = '1' and not v_write_ok then
                    v_lost_w := v_lost_w + 1;
                end if;
                if tb_read_enable = '1' and not v_read_ok then
                    v_lost_r := v_lost_r + 1;
                end if;

                -- 3) Avanzar el modelo. La lectura va antes que la escritura en
                -- el código, pero da igual: si la FIFO está vacía no se lee,
                -- así que nunca se lee lo que se escribe en el mismo flanco.
                v_exp_valid := '0';
                if v_read_ok then
                    v_exp_valid := '1';
                    v_exp_data  := v_mem(v_rd);
                    v_rd        := (v_rd + 1) mod C_DEPTH;
                    v_reads     := v_reads + 1;
                end if;
                if v_write_ok then
                    v_mem(v_wr) := tb_data_to_write;
                    v_wr        := (v_wr + 1) mod C_DEPTH;
                    v_writes    := v_writes + 1;
                end if;
                if v_write_ok and not v_read_ok then
                    v_count := v_count + 1;
                elsif v_read_ok and not v_write_ok then
                    v_count := v_count - 1;
                end if;
            end if;
        end loop;

        report "==================================================";
        report "FIFO depth = " & integer'image(C_DEPTH) & ", width = " & integer'image(C_WIDTH);
        report "Escrituras atendidas: " & integer'image(v_writes) &
               ", descartadas: " & integer'image(v_lost_w);
        report "Lecturas atendidas:   " & integer'image(v_reads) &
               ", descartadas: " & integer'image(v_lost_r);
        if v_errors = 0 then
            report "SIMULACION OK: 0 errores";
        else
            report "SIMULACION CON " & integer'image(v_errors) & " ERRORES" severity error;
        end if;
        report "==================================================";
        finish;
    end process p_checker;

end architecture behavioral;
