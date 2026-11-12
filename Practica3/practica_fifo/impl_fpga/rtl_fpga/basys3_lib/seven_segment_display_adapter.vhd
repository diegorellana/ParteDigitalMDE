library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library basys3_lib;
use basys3_lib.basys3_ctes_pkg.all;
use basys3_lib.basys3_types_pkg.all;
use basys3_lib.basys3_functions_pkg.all;


entity seven_segment_display_adapter is
    port (
        clk         : in std_logic;
        reset_n     : in std_logic;
        input_chars : in t_display_word;
        input_dots  : in std_logic_vector(0 to c_n_display_elements - 1);
        anodes      : out std_logic_vector(0 to c_n_display_elements - 1);
        segments    : out std_logic_vector(0 to c_n_display_segments - 1);
        dp          : out std_logic
    );
end entity seven_segment_display_adapter;

architecture rtl of seven_segment_display_adapter is

    constant c_tics_per_character : natural := c_ssd_char_time / c_clk_period;
    constant c_time_counter_bw : natural := natural(ceil(log2(real(c_tics_per_character + 1))));

    -- Como c_n_display_elements es una potencia de dos y contamos desde 
    -- 0 hasta c_n_display_elements - 1, el +1 está de sobra en este caso
    constant c_character_pointer_bw : natural := natural(ceil(log2(real(c_n_display_elements + 1))));

    signal reg_time_counter : std_logic_vector(c_time_counter_bw - 1 downto 0);
    signal reg_character_pointer : std_logic_vector(c_character_pointer_bw - 1 downto 0);

    signal reg_input_chars : t_display_word;
    signal reg_input_dots : std_logic_vector(input_dots'range);
    -- Para alinear el retraso de la conversion characters/segments y decimal_points
    signal reg_input_dots_delay : std_logic_vector(reg_input_dots'range);
    type t_display_conversions is array (0 to c_n_display_elements - 1) of t_display_segment;
    signal reg_display_conversions : t_display_conversions;

    signal reg_anodes : std_logic_vector(anodes'range);
    signal reg_segments : std_logic_vector(segments'range);
    signal reg_dp : std_logic;

begin

    p_time_counter_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_time_counter <= (others => '0');
        elsif rising_edge(clk) then
            if unsigned(reg_time_counter) = c_tics_per_character - 1 then
                reg_time_counter <= (others => '0');
            else
                reg_time_counter <= std_logic_vector(unsigned(reg_time_counter) + 1);
            end if;
        end if;
    end process p_time_counter_reg;

    p_character_pointer_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_character_pointer <= (others => '0');
        elsif rising_edge(clk) then
            if unsigned(reg_time_counter) = c_tics_per_character - 1 then
                if unsigned(reg_character_pointer) = c_n_display_elements - 1 then
                    reg_character_pointer <= (others => '0');
                else
                    reg_character_pointer <= std_logic_vector(unsigned(reg_character_pointer) + 1);
                end if;
            end if;
        end if;
    end process p_character_pointer_reg;

    p_input_reg : process(clk)
    begin
        if rising_edge(clk) then
            reg_input_chars      <= input_chars;
            reg_input_dots       <= input_dots;
            reg_input_dots_delay <= reg_input_dots;
        end if;
    end process p_input_reg;

    -- reg_display_conversions
    p_segment_conversion : process(clk)
    begin
        if rising_edge(clk) then
            for I in 0 to c_n_display_elements - 1  loop
                reg_display_conversions(I) <= f_basys3_character_to_segments(reg_input_chars(I));
            end loop;
        end if;
    end process p_segment_conversion;

    p_out_mux_reg : process(clk, reset_n)
        variable v_out_index : natural := 0;
    begin
        if reset_n = '0' then
            reg_anodes  <= (others => '1');
            reg_segments <= (others => '1');
            reg_dp       <= '1';
        elsif rising_edge(clk) then
            v_out_index := to_integer(unsigned(reg_character_pointer));
            -- Apagados por defecto
            reg_anodes   <= (others => '1');
            reg_segments <= (others => '1');
            reg_dp       <= '1';
            if v_out_index < c_n_display_elements then
                reg_anodes(v_out_index) <= '0';
                reg_segments            <= reg_display_conversions(v_out_index);
                reg_dp                  <= not reg_input_dots_delay(v_out_index);
            end if;
        end if;
    end process p_out_mux_reg;

    anodes <= reg_anodes;
    segments <= reg_segments;
    dp <= reg_dp;

end architecture;