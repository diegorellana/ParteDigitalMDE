--==============================================================================
-- tb_fifo_cronograma.vhd - reproduce el cronograma del enunciado (apartado 2.2).
--
-- FIFO de profundidad 2. Se meten las mismas entradas que en el cronograma,
-- ciclo a ciclo (ciclos 0 a 8), y en mitad de cada ciclo se comparan las
-- salidas y la ocupación con lo que pone el dibujo del enunciado.
--
-- Además vuelca una tabla con todo a sim/out/cronograma.txt para poder
-- compararla a ojo con la figura.
--
-- Se lanza desde sim/run:  vsim -c work.tb_fifo_cronograma -do "run -all"
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use std.env.all;

entity tb_fifo_cronograma is
end entity tb_fifo_cronograma;

architecture behavioral of tb_fifo_cronograma is

    constant C_DEPTH      : integer := 2;
    constant C_WIDTH      : integer := 16;
    constant C_CLK_PERIOD : time    := 10 ns;
    constant C_N_CICLOS   : integer := 9;

    type t_bits  is array (0 to C_N_CICLOS - 1) of std_logic;
    type t_datos is array (0 to C_N_CICLOS - 1) of std_logic_vector(C_WIDTH - 1 downto 0);
    type t_ints  is array (0 to C_N_CICLOS - 1) of integer;

    -- Entradas, copiadas del cronograma (ciclo 0 ... ciclo 8)
    constant C_WE   : t_bits  := ('0', '1', '1', '1', '0', '1', '0', '0', '0');
    constant C_DATA : t_datos := (x"0000", x"0011", x"0022", x"0033", x"0000",
                                  x"0044", x"0000", x"0000", x"0000");
    constant C_RE   : t_bits  := ('0', '0', '0', '0', '1', '1', '1', '1', '0');

    -- Salidas que tienen que salir en cada ciclo, también del cronograma.
    -- data_read solo se compara cuando read_valid = '1'.
    constant C_EXP_VALID : t_bits  := ('0', '0', '0', '0', '0', '1', '1', '1', '0');
    constant C_EXP_DATA  : t_datos := (x"0000", x"0000", x"0000", x"0000", x"0000",
                                       x"0011", x"0022", x"0044", x"0000");
    constant C_EXP_EMPTY : t_bits  := ('1', '1', '0', '0', '0', '0', '0', '1', '1');
    constant C_EXP_FULL  : t_bits  := ('0', '0', '0', '1', '1', '0', '0', '0', '0');
    constant C_EXP_OCUP  : t_ints  := (0, 0, 1, 2, 2, 1, 1, 0, 0);

    signal tb_clk           : std_logic := '0';
    signal tb_reset_n       : std_logic := '0';
    signal tb_write_enable  : std_logic := '0';
    signal tb_data_to_write : std_logic_vector(C_WIDTH - 1 downto 0) := (others => '0');
    signal tb_read_enable   : std_logic := '0';
    signal tb_data_read     : std_logic_vector(C_WIDTH - 1 downto 0);
    signal tb_read_valid    : std_logic;
    signal tb_empty         : std_logic;
    signal tb_full          : std_logic;

begin

    -- Reloj desde el principio; el reset se suelta antes de empezar los ciclos
    tb_clk <= not tb_clk after C_CLK_PERIOD / 2;

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

    p_cronograma : process
        -- La ocupación es una señal interna del DUT: la leo con un nombre
        -- externo de VHDL-2008 para poder comparar también esa fila.
        alias ocupacion is <<signal .tb_fifo_cronograma.dut.reg_data_counter : integer range 0 to C_DEPTH>>;

        file     f_out  : text open write_mode is "../out/cronograma.txt";
        variable v_line : line;
        variable v_errores : integer := 0;
        variable v_ok      : boolean;
    begin
        -- Reset durante unos ciclos y lo suelto a mitad de ciclo
        tb_reset_n <= '0';
        wait for 3 * C_CLK_PERIOD + C_CLK_PERIOD / 4;
        tb_reset_n <= '1';

        write(v_line, string'("ciclo | we data re | data_read read_valid empty full | ocupacion | ok"));
        writeline(f_out, v_line);

        for n in 0 to C_N_CICLOS - 1 loop
            -- Empieza el ciclo n en el flanco de subida: pongo sus entradas
            wait until rising_edge(tb_clk);
            tb_write_enable  <= C_WE(n);
            tb_data_to_write <= C_DATA(n);
            tb_read_enable   <= C_RE(n);

            -- A mitad de ciclo todo está estable: comparo con el cronograma
            wait for C_CLK_PERIOD / 2;
            v_ok := tb_read_valid = C_EXP_VALID(n)
                    and tb_empty = C_EXP_EMPTY(n)
                    and tb_full = C_EXP_FULL(n)
                    and ocupacion = C_EXP_OCUP(n)
                    and (C_EXP_VALID(n) = '0' or tb_data_read = C_EXP_DATA(n));
            if not v_ok then
                v_errores := v_errores + 1;
                report "El ciclo " & integer'image(n) & " no coincide con el cronograma" severity error;
            end if;

            write(v_line, integer'image(n) & "     | " &
                          std_logic'image(C_WE(n)) & " " & to_hstring(C_DATA(n)) & " " &
                          std_logic'image(C_RE(n)) & " | " &
                          to_hstring(tb_data_read) & "      " &
                          std_logic'image(tb_read_valid) & "        " &
                          std_logic'image(tb_empty) & "   " &
                          std_logic'image(tb_full) & "  | " &
                          integer'image(ocupacion) & "         | " &
                          boolean'image(v_ok));
            writeline(f_out, v_line);
        end loop;

        if v_errores = 0 then
            report "CRONOGRAMA OK: los 9 ciclos coinciden con el enunciado";
        else
            report "CRONOGRAMA CON " & integer'image(v_errores) & " CICLOS DISTINTOS" severity error;
        end if;
        finish;
    end process p_cronograma;

end architecture behavioral;
