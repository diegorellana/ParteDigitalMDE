library ieee;
use ieee.std_logic_1164.all;

library basys3_lib;
use basys3_lib.basys3_ctes_pkg.all;
use basys3_lib.basys3_components_pkg.all;
use basys3_lib.basys3_types_pkg.all;
use basys3_lib.basys3_functions_pkg.all;

entity top_fifo_fpga is
    port (
        clk   : in std_logic;
        btnC  : in std_logic; -- Servirá como reset_n
        sw    : in std_logic_vector(c_n_switches - 1 downto 0);
        -- btnU  : in std_logic; -- Servira como valid_in
        btnL  : in std_logic; -- Servirá como write_enable
        btnR  : in std_logic; -- Servirá como read_enable 
        -- LEDS
        led   : out std_logic_vector(c_n_leds - 1 downto 0);
        -- Display de 7 segmentos
        seg   : out std_logic_vector(0 to c_n_display_segments - 1);
        dp    : out std_logic;
        an    : out std_logic_vector(0 to c_n_display_elements - 1)
    );
end entity top_fifo_fpga;

architecture rtl of top_fifo_fpga is

    -- Las medidas de la FIFO que se instancia en la placa. Van aquí y no
    -- en un paquete para que este top compile sin depender del contenido
    -- de ctes_pkg.vhd, que forma parte del diseño que se entrega.
    --
    -- El ancho tiene que ser el número de interruptores de la Basys 3; el
    -- assert de más abajo lo comprueba. La profundidad es pequeña a
    -- propósito, para poder llenar la FIFO desde la placa en pocos
    -- pulsos y ver encenderse el indicador full.
    constant FIFO_WIDTH : integer := 16;
    constant FIFO_DEPTH : integer := 4;

    signal s_reset_n : std_logic;
    signal s_write_enable : std_logic;
    signal s_data_to_write : std_logic_vector(FIFO_WIDTH - 1 downto 0);
    signal s_read_enable   : std_logic;
    signal s_data_read     : std_logic_vector(FIFO_WIDTH - 1 downto 0);
    signal s_read_valid    : std_logic;
    signal s_empty         : std_logic;
    signal s_full          : std_logic;
    
    signal s_btnL_debounced : std_logic;
    signal reg_btnL_debounced, reg_btnL_debounced_2 : std_logic;
    
    signal s_btnR_debounced : std_logic;
    signal reg_btnR_debounced, reg_btnR_debounced_2 : std_logic;
    
    signal reg_input_chars : t_display_word;
    constant c_input_dots : std_logic_vector(0 to c_n_display_elements - 1) := (others => '0');
    
    constant c_bits_per_nibble : integer := 4;
    
begin

    assert FIFO_WIDTH = c_n_switches report "FIFO_WIDTH debe valer " & integer'image(c_n_switches) severity failure;
    s_reset_n <= not btnC;
    
    -- Debouncer y lógica para generar write_enable
    u_debouncer_l : debouncer
        port map (
            clk => clk,
            reset_n => s_reset_n,
            input_value => btnL,
            output_value => s_btnL_debounced
        );
     
    p_debouncer_l_reg : process(clk, s_reset_n)
    begin
        if s_reset_n = '0' then
            reg_btnL_debounced   <= '0';
            reg_btnL_debounced_2 <= '0';        
        elsif rising_edge(clk) then
            reg_btnL_debounced   <= s_btnL_debounced;
            reg_btnL_debounced_2 <= reg_btnL_debounced;
        end if;
    end process p_debouncer_l_reg;
    
    s_write_enable <= '1' when (reg_btnL_debounced = '0' and reg_btnL_debounced_2 = '1') else '0';
    
-- Debouncer y lógica para generar read_enable
    u_debouncer_r : debouncer
        port map (
            clk => clk,
            reset_n => s_reset_n,
            input_value => btnR,
            output_value => s_btnR_debounced
        );
     
    p_debouncer_r_reg : process(clk, s_reset_n)
    begin
        if s_reset_n = '0' then
            reg_btnR_debounced   <= '0';
            reg_btnR_debounced_2 <= '0';        
        elsif rising_edge(clk) then
            reg_btnR_debounced   <= s_btnR_debounced;
            reg_btnR_debounced_2 <= reg_btnR_debounced;
        end if;
    end process p_debouncer_r_reg;
    
    s_read_enable <= '1' when (reg_btnR_debounced = '0' and reg_btnR_debounced_2 = '1') else '0';    
    
    -- Debouncer para lógica data_to_write
    generate_switch_debouncer : for I in sw'range generate
        -- La definición de debouncer viene en el package 
        -- basys3_lib.basys3_components_pkg.all;
        u_debouncer : debouncer
            port map (
                clk => clk,
                reset_n => s_reset_n,
                input_value => sw(I),
                output_value => s_data_to_write(I)
            );
    end generate generate_switch_debouncer;    
    
    
    -- Instanciar FIFO
    u_fifo : entity work.fifo(rtl)
        generic map (
            gen_depth => FIFO_DEPTH,
            gen_width => FIFO_WIDTH    
        )
        port map (
            clk           => clk,
            reset_n       => s_reset_n,
            write_enable  => s_write_enable,
            data_to_write => s_data_to_write,
            read_enable   => s_read_enable,
            data_read     => s_data_read,
            read_valid    => s_read_valid,
            empty         => s_empty,
            full          => s_full    
        );
        
    -- Instanciar adaptador a display de 7 segmentos y lógica para converir data_read y s_read_valid 
    p_input_chars_reg : process(clk, s_reset_n)
        variable v_nibble_slice : std_logic_vector(C_BITS_PER_NIBBLE - 1 downto 0);
    begin
        if s_reset_n = '0' then
            for I in 0 to c_n_display_elements - 1 loop
                reg_input_chars(I) <= CHAR_0;
            end loop;
        elsif rising_edge(clk) then
            if s_read_valid = '1' then
                for I in 0 to c_n_display_elements - 1 loop
                    v_nibble_slice := s_data_read((I+1)*C_BITS_PER_NIBBLE - 1 downto I*C_BITS_PER_NIBBLE);
                    reg_input_chars(I) <= f_basys3_nibble_to_char(v_nibble_slice);
                end loop;
            end if;
        end if;
    end process p_input_chars_reg;       
    
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
            
    -- Conectar leds
    p_leds : process(s_empty, s_full)
    begin
        led <= (others => '0');   -- por defecto
        led(0)             <= s_empty;
        led(c_n_leds - 1)  <= s_full;
    end process p_leds;
    
end architecture rtl;