library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library basys3_lib;
use basys3_lib.basys3_ctes_pkg.all;

entity debouncer is
    port (
        clk          : in std_logic;
        reset_n      : in std_logic;
        input_value  : in std_logic;
        output_value : out std_logic        
    );
end entity debouncer;

architecture rtl of debouncer is

    constant c_tics_in_debounce_window : natural := c_debounce_time / c_clk_period;
    constant c_counter_bw : natural := natural(ceil(log2(real(c_tics_in_debounce_window + 1))));

    signal reg_counter : std_logic_vector(c_counter_bw - 1 downto 0);

    signal reg_in_meta : std_logic;
    signal reg_in      : std_logic;
    signal reg_out     : std_logic;

    type t_fsm is (IDLE, DEBOUNCE_WINDOW, CHECK_OUTPUT);
    signal reg_fsm : t_fsm;

begin

    -- Sincronizador de 2 FF: input_value viene del pulsador, asíncrono al reloj.
    -- El primer FF puede quedar metaestable; el segundo entrega un valor estable.
    p_sync_in : process(clk)
    begin
        if rising_edge(clk) then
            reg_in_meta <= input_value;
            reg_in      <= reg_in_meta;
        end if;
    end process p_sync_in;

    p_counter_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_counter <= (others => '0');
        elsif rising_edge(clk) then
            reg_counter <= (others => '0');
            -- Cuenta solo mientras la entrada se mantenga en el valor nuevo;
            -- si rebota al valor antiguo (reg_in = reg_out), vuelve a 0.
            if reg_fsm = DEBOUNCE_WINDOW and reg_in /= reg_out then
                reg_counter <= std_logic_vector(unsigned(reg_counter) + 1);
            end if;
        end if;
    end process p_counter_reg;

    p_fsm_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_fsm <= IDLE;
        elsif rising_edge(clk) then
            case reg_fsm is
                when IDLE =>
                    if reg_in /= reg_out then
                        reg_fsm <= DEBOUNCE_WINDOW;
                    end if;
                when DEBOUNCE_WINDOW =>
                    if (unsigned(reg_counter) >= c_tics_in_debounce_window) then
                        reg_fsm <= CHECK_OUTPUT;
                    end if;
                when CHECK_OUTPUT =>
                    reg_fsm <= IDLE;
            end case;
        end if;
    end process p_fsm_reg;

    p_out_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out <= '0';
        elsif rising_edge(clk) then
            if reg_fsm = CHECK_OUTPUT then
                reg_out <= reg_in;
            end if;
        end if;
    end process p_out_reg;

    output_value <= reg_out;    

end architecture rtl;