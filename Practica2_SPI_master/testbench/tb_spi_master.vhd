--==============================================================================
-- tb_spi_master.vhd - banco de pruebas del SPI maestro.
--
-- El banco emula al esclavo y comprueba los dos sentidos de la comunicación:
-- que mosi reproduce tx_word y que rx_word recoge lo que el esclavo emitió
-- por miso.
--
-- Toda la secuencia de una transacción está empaquetada en el procedimiento
-- realizar_transaccion, de modo que añadir un caso de prueba es añadir una
-- línea al proceso de estímulos.
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.env.all;

use work.ctes_pkg.all;

entity tb_spi_master is
end entity tb_spi_master;

architecture behavioral of tb_spi_master is

    constant C_RESET_WINDOW     : time := 100 ns;
    constant C_CLOCK_START_TIME : time := 200 ns;
    constant C_CLK_PERIOD         : time := 10 ns;

    -- Tiempo maximo que se espera a que el DUT reaccione. Es algo mas que una
    -- transaccion entera, asi que ninguna espera legitima lo alcanza: si se
    -- agota, el DUT se ha quedado colgado y no tiene sentido seguir.
    constant C_GUARDA : time :=
        (TRANSACTION_BW + 4) * CLOCK_TICS_PER_SCK * C_CLK_PERIOD;

    signal tb_clk     : std_logic := '0';
    signal tb_reset_n : std_logic := '0';

    signal tb_tx_word           : std_logic_vector(TRANSACTION_BW - 1 downto 0)
                                  := (others => '0');
    signal tb_start_transaction : std_logic := '0';
    signal tb_rx_word           : std_logic_vector(TRANSACTION_BW - 1 downto 0);
    signal tb_transaction_done  : std_logic;
    signal tb_ready             : std_logic;

    signal tb_cs_n : std_logic;
    signal tb_sck  : std_logic;
    signal tb_mosi : std_logic;
    signal tb_miso : std_logic := '0';

begin

    assert C_CLOCK_START_TIME > C_RESET_WINDOW report "El clock no tiene que generarse mientras la señal de reset está activa." severity failure;

    -- Generar reset
    p_reset_n : process
    begin
        -- Al principio, reset_n activo
        tb_reset_n <= '0';
        -- Esperar el tiempo C_RESET_WINDOW
        wait for C_RESET_WINDOW;
        tb_reset_n <= '1';
        -- El proceso termina aquí
        wait;
    end process p_reset_n;

    -- Generar clock
    p_clock : process
    begin
        -- Al principio, la señal de reloj está a '0'
        tb_clk <= '0';
        -- Esperar el tiempo C_CLOCK_START_TIME
        wait for C_CLOCK_START_TIME;
        loop
            tb_clk <= not tb_clk;
            wait for C_CLK_PERIOD / 2;
        end loop;
    end process p_clock;

    dut : entity work.spi_master(rtl)
        port map (
            clk               => tb_clk,
            reset_n           => tb_reset_n,
            tx_word           => tb_tx_word,
            start_transaction => tb_start_transaction,
            rx_word           => tb_rx_word,
            transaction_done  => tb_transaction_done,
            ready             => tb_ready,
            cs_n              => tb_cs_n,
            sck               => tb_sck,
            mosi              => tb_mosi,
            miso              => tb_miso
        );

    p_estimulos : process
        --------------------------------------------------------------------------
        -- Ejecuta una transacción completa y comprueba el resultado.
        --
        -- Va declarado dentro del proceso, y no en la arquitectura, porque un
        -- subprograma solo puede mover una señal si el driver pertenece a un
        -- proceso. Declarado fuera, el compilador lo rechaza con "Cannot drive
        -- signal ... from procedure".
        --------------------------------------------------------------------------
        procedure realizar_transaccion (
            constant palabra_del_maestro_hacia_el_esclavo : in std_logic_vector(TRANSACTION_BW - 1 downto 0);
            constant palabra_del_esclavo_hacia_el_maestro : in std_logic_vector(TRANSACTION_BW - 1 downto 0)
        ) is
            -- Aquí se reconstruye, bit a bit, lo que el DUT saca por mosi.
            variable palabra_observada : std_logic_vector(TRANSACTION_BW - 1 downto 0);
            -- Marca de tiempo con la que se miden los tiempos de guarda.
            variable v_inicio_espera : time;
        begin
            -- 0. Engancharse al reloj antes de tocar nada, para que la
            --    petición salga alineada con un flanco.
            wait until rising_edge(tb_clk);

            report "Comienza una transacción SPI, con M-S = 0x"
                   & to_hstring(palabra_del_maestro_hacia_el_esclavo)
                   & " y S-M = 0x"
                   & to_hstring(palabra_del_esclavo_hacia_el_maestro)
                severity note;

            -- 1. La petición dura un único ciclo de clk, con la palabra ya
            --    presente en tx_word.
            tb_tx_word           <= palabra_del_maestro_hacia_el_esclavo;
            tb_start_transaction <= '1';
            wait until rising_edge(tb_clk);
            tb_start_transaction <= '0';

            -- 2. La trama. En cada periodo de sck el esclavo emite su bit en el
            --    flanco de subida y muestrea el del maestro en el de bajada. El
            --    bucle va de MSB a LSB porque SPI transmite primero el bit más
            --    significativo.
            --
            --    Cada espera que depende de una señal del DUT lleva tiempo de
            --    guarda. Sin él, un diseño que no genera sck deja la simulación
            --    colgada para siempre y no se sabe por qué.
            for i in TRANSACTION_BW - 1 downto 0 loop
                v_inicio_espera := now;
                wait until rising_edge(tb_sck) for C_GUARDA;
                assert now - v_inicio_espera < C_GUARDA
                    report "El DUT no genera el flanco de subida de sck del bit "
                           & integer'image(i)
                    severity failure;
                tb_miso <= palabra_del_esclavo_hacia_el_maestro(i);

                v_inicio_espera := now;
                wait until falling_edge(tb_sck) for C_GUARDA;
                assert now - v_inicio_espera < C_GUARDA
                    report "El DUT no genera el flanco de bajada de sck del bit "
                           & integer'image(i)
                    severity failure;
                palabra_observada(i) := tb_mosi;
            end loop;

            tb_miso <= '0';

            -- 3. El pulso de transaction_done es el instante en que rx_word vale.
            v_inicio_espera := now;
            wait until rising_edge(tb_transaction_done) for C_GUARDA;
            assert now - v_inicio_espera < C_GUARDA
                report "El DUT no levanta transaction_done al acabar la trama"
                severity failure;

            assert palabra_observada = palabra_del_maestro_hacia_el_esclavo
                report "mosi no reproduce tx_word: se esperaba "
                       & to_hstring(palabra_del_maestro_hacia_el_esclavo)
                       & " y se observó " & to_hstring(palabra_observada)
                severity warning;

            assert tb_rx_word = palabra_del_esclavo_hacia_el_maestro
                report "rx_word no recoge lo que emitió el esclavo: se esperaba "
                       & to_hstring(palabra_del_esclavo_hacia_el_maestro)
                       & " y se leyó " & to_hstring(tb_rx_word)
                severity warning;

            -- 4. No se devuelve el control hasta que el maestro admite otra
            --    petición.
            v_inicio_espera := now;
            wait until tb_ready = '1' for C_GUARDA;
            assert now - v_inicio_espera < C_GUARDA
                report "El DUT no vuelve a ready después de la transacción"
                severity failure;
        end procedure realizar_transaccion;
    begin
        wait until tb_reset_n = '1';
        wait until rising_edge(tb_clk);

        realizar_transaccion(x"1234", x"5678");
        realizar_transaccion(x"0000", x"FFFF");
        realizar_transaccion(x"AAAA", x"5555");
        realizar_transaccion(x"8000", x"0001");

        report "Simulación completa";
        stop;
        wait;
    end process p_estimulos;

end architecture behavioral;
