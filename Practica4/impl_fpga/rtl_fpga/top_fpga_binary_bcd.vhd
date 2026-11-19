library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library basys3_lib;
use basys3_lib.basys3_ctes_pkg.all;
use basys3_lib.basys3_types_pkg.all;
use basys3_lib.basys3_components_pkg.all;
use basys3_lib.basys3_functions_pkg.all;

library binary_to_bcd_lib;
use binary_to_bcd_lib.ctes_pkg.all;

entity top_fpga_binary_bcd is
    port (
        clk   : in std_logic;
        btnC  : in std_logic; -- Servirá como reset_n
        sw    : in std_logic_vector(c_n_switches - 1 downto 0);
        btnU  : in std_logic; -- Servira como valid_in 
        -- LEDS
        led   : out std_logic_vector(c_n_leds - 1 downto 0);
        -- Display de 7 segmentos
        seg   : out std_logic_vector(0 to c_n_display_segments - 1);
        dp    : out std_logic;
        an    : out std_logic_vector(0 to c_n_display_elements - 1)
    );
end entity top_fpga_binary_bcd;

architecture rtl of top_fpga_binary_bcd is

    signal s_reset_n  : std_logic;
    signal s_valid_in : std_logic;
    signal s_switch_values : std_logic_vector(c_n_switches - 1 downto 0);

    signal s_binary_to_bcd_binary_in : std_logic_vector(C_BINARY_BW - 1 downto 0);
    signal s_binary_to_bcd_valid_out : std_logic;
    signal s_binary_to_bcd_bcd_out : std_logic_vector(C_BCD_BW - 1 downto 0);

    signal reg_input_chars : t_display_word;
    constant c_input_dots : std_logic_vector(0 to c_n_display_elements - 1) := (others => '0');
begin

    s_reset_n <= not btnC;
    s_valid_in <= btnU;

    -- Instanciar debouncers para los switches de entrada
    generate_switch_debouncer : for I in sw'range generate
        -- La definición de debouncer viene en el package 
        -- basys3_lib.basys3_components_pkg.all;
        u_debouncer : debouncer
            port map (
                clk => clk,
                reset_n => s_reset_n,
                input_value => sw(I),
                output_value => s_switch_values(I)
            );
    end generate generate_switch_debouncer;

    led <= s_switch_values;

    s_binary_to_bcd_binary_in <= std_logic_vector(resize(unsigned(s_switch_values), s_binary_to_bcd_binary_in'length));

    -- Instanciar binary_to_bcd
    -- binary_to_bcd está compilado en la librería work
    u_binary_to_bcd : entity work.binary_to_bcd
        generic map (
            gen_binary_bw        => C_BINARY_BW,
            gen_max_binary_value => C_MAX_BINARY_VALUE,
            gen_bcd_bw           => C_BCD_BW,
            gen_pipeline         => C_PIPELINE
        )
        port map (
            clk       => clk,
            reset_n   => s_reset_n,
            binary_in => s_binary_to_bcd_binary_in,
            valid_in  => s_valid_in,
            bcd_out   => s_binary_to_bcd_bcd_out,
            valid_out => s_binary_to_bcd_valid_out
        );

    -- Lógica que convierte las salidas bcd_out y valid_out a la entrada
    -- input_chars del adaptador.
    --
    -- Cada vez que valid_out = '1' se guarda el resultado en reg_input_chars,
    -- así el display mantiene la última conversión mientras no llegue otra.
    -- Cada nibble de bcd_out es un dígito decimal y se pasa a carácter con
    -- f_basys3_nibble_to_char. El índice 0 de input_chars es el dígito de la
    -- derecha del display (an[0]), así que le corresponden las unidades,
    -- bcd_out(3 downto 0).
    p_display_chars_reg : process(clk, s_reset_n)
    begin
        if s_reset_n = '0' then
            reg_input_chars <= (others => CHAR_0);
        elsif rising_edge(clk) then
            if s_binary_to_bcd_valid_out = '1' then
                for I in 0 to c_n_display_elements - 1 loop
                    reg_input_chars(I) <= f_basys3_nibble_to_char(
                        s_binary_to_bcd_bcd_out((I + 1) * C_BITS_PER_NIBBLE - 1 downto I * C_BITS_PER_NIBBLE));
                end loop;
            end if;
        end if;
    end process p_display_chars_reg;

    u_display_adapter : seven_segment_display_adapter
        port map (
            clk         => clk,
            reset_n     => s_reset_n,
            input_chars => reg_input_chars, 
            input_dots  => c_input_dots,
            anodes      => an,
            segments    => seg,
            dp          => dp
            );
    

end architecture;