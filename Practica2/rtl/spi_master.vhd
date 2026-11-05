--==============================================================================
-- spi_master.vhd - periférico SPI maestro.
--
-- Lo que se entrega resuelto es la señalización del grupo de control: el
-- registro de las entradas, la máquina de estados y las tres salidas que
-- salen de ella (cs_n, transaction_done y ready). Con eso, el cronograma de
-- la sección «Los puertos del grupo de control» del enunciado ya se cumple.
--
-- Lo que falta es la señalización del bus SPI: generar sck, sacar los bits
-- por mosi y recoger los que llegan por miso en rx_word.
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.ctes_pkg.all;

entity spi_master is
    port (
        clk               : in std_logic;
        reset_n           : in std_logic;
        -- Control de entrada
        tx_word           : in std_logic_vector(TRANSACTION_BW - 1 downto 0);
        start_transaction : in std_logic;
        -- Control de salida
        rx_word           : out std_logic_vector(TRANSACTION_BW - 1 downto 0);
        transaction_done  : out std_logic;
        ready             : out std_logic;
        -- SPI
        cs_n              : out std_logic;
        sck               : out std_logic;
        mosi              : out std_logic;
        miso              : in std_logic
    );
end entity spi_master;

architecture rtl of spi_master is

    -- La máquina de estados.
    --
    -- Los tres SPI_DUMMY_* son de relleno. No hacen nada: solo ocupan un
    -- ciclo cada uno, para que en el visor de ondas se vea un hueco en cs_n
    -- donde después irá la trama. Son los que hay que sustituir por los
    -- estados que pida la señalización SPI, que no tienen por qué ser tres.
    -- Los cambiamos a GUARD_INICAL, BITS, GUARD_FINAL
    type t_fsm is (IDLE,
                   GUARD_INICIAL, BITS, GUARD_FINAL,
                   TRANSACTION_COMPLETE, RETURN_TO_IDLE);
    signal reg_fsm : t_fsm;

    -- Entradas registradas. Son la única parte del diseño a la que le está
    -- permitido leer los puertos de entrada.
    signal reg_in_start_transaction : std_logic;
    signal reg_in_tx_word : std_logic_vector(tx_word'range);
    signal reg_in_miso : std_logic;

    -- Salidas registradas. Las tres primeras ya tienen su lógica; las tres
    -- últimas todavía no.
    signal reg_out_cs_n : std_logic;                -- Ya tiene lógica
    signal reg_out_transaction_done : std_logic;    -- Ya tiene lógica
    signal reg_out_ready : std_logic;               -- Ya tiene lógica
    signal reg_out_sck : std_logic;                 -- Nuestras
    signal reg_out_mosi : std_logic;                -- Nuestras
    signal reg_out_rx_word : std_logic_vector(rx_word'range);   --Nuestras

    -- Anchos de bit de contadores necesarios para
    -- * Contar de 0 hasta CLOCK_TICS_PER_SCK
    constant C_CLOCK_TICS_PER_SCK_COUNTER_BW      : integer := natural(ceil(log2(real(CLOCK_TICS_PER_SCK + 1))));
    -- * Contar de 0 hasta CLOCK_TICS_PER_HALF_SCK
    constant C_CLOCK_TICS_PER_HALF_SCK_COUNTER_BW : integer := natural(ceil(log2(real(CLOCK_TICS_PER_HALF_SCK + 1))));
    -- * Contar de 0 hasta TRANSACTION_BW
    constant C_TRANSACTION_BW_COUNTER_BW          : integer := natural(ceil(log2(real(TRANSACTION_BW + 1))));

    -- * Contar medios periodos de sck dentro de una fase (0..2*TRANSACTION_BW-1)
    constant C_HALF_PERIODS_COUNTER_BW : integer := natural(ceil(log2(real(2 * TRANSACTION_BW))));

    -- Divisor de reloj: cuenta ciclos de clk dentro de un medio periodo de sck (0..4)
    signal reg_tic_counter  : unsigned(C_CLOCK_TICS_PER_HALF_SCK_COUNTER_BW - 1 downto 0);
    -- Medios periodos transcurridos en la fase actual
    signal reg_half_counter : unsigned(C_HALF_PERIODS_COUNTER_BW - 1 downto 0);
    -- Último ciclo de un medio periodo de sck
    signal s_half_tick      : std_logic;
    -- Último ciclo de la fase actual (guarda inicial, bits o guarda final)
    signal s_fin_fase       : std_logic;
    -- Palabra a enviar, guardada al aceptar la petición
    signal reg_tx_word : std_logic_vector(tx_word'range);
begin

    assert CLOCK_TICS_PER_SCK mod 2 = 0
        report "El divisor del clock no cuenta un número par de ciclos"
        severity error;

    --==========================================================================
    -- Registro de las entradas
    --==========================================================================
    p_inputs_reg : process(clk, reset_n) -- reset_n es asincrono. Evalúa cuando cambia CLK
    begin
        if reset_n = '0' then                   -- SI se activa rst...
            reg_in_start_transaction <= '0';    -- all a 0
            reg_in_tx_word <= (others => '0');  -- all a 0
            reg_in_miso <= '0';                 -- all a 0    
        elsif rising_edge(clk) then                             -- al detectar rising edge
            reg_in_start_transaction <= start_transaction;      -- pulso de petición, visto 1 ciclo después
            reg_in_tx_word <= tx_word;                          -- palabra a enviar
            reg_in_miso <= miso;                                -- bit de esclavo alineado con clk
        end if;
    end process p_inputs_reg;

    --==========================================================================
    -- La máquina de estados
    --
    -- Los tres estados de relleno se encadenan solos, un ciclo cada uno. Al
    -- sustituirlos habrá que decidir qué hace avanzar a los estados nuevos,
    -- que ya no será el paso del ciclo sino la cuenta del divisor de reloj.
    --==========================================================================
    p_fsm_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_fsm <= IDLE;             -- Luego del RST, se espera en reposo
        elsif rising_edge(clk) then
            case reg_fsm is
                when IDLE =>
                    if reg_in_start_transaction = '1' then
                        reg_fsm <= GUARD_INICIAL;
                    end if;
                -- Cada fase termina en el último ciclo de su último medio periodo.
                when GUARD_INICIAL =>
                    if s_fin_fase = '1' then
                        reg_fsm <= BITS;
                    end if;
                when BITS =>
                    if s_fin_fase = '1' then
                        reg_fsm <= GUARD_FINAL;
                    end if;
                when GUARD_FINAL =>
                    if s_fin_fase = '1' then
                        reg_fsm <= TRANSACTION_COMPLETE;
                    end if;
                when TRANSACTION_COMPLETE =>
                    reg_fsm <= RETURN_TO_IDLE;
                when RETURN_TO_IDLE =>
                    reg_fsm <= IDLE;
            end case;
        end if;
    end process p_fsm_reg;

    --==========================================================================
    -- Las tres salidas del grupo de control
    --
    -- Las tres se deciden mirando solo en qué estado está la máquina, nunca
    -- los puertos de entrada. Eso es lo que hace que sus instantes sean los
    -- que fija el enunciado, y es la razón de que ready tarde dos ciclos en
    -- bajar: uno lo cuesta el registro de entrada y otro el de salida.
    --==========================================================================
    p_cs_n_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out_cs_n <= '1';
        elsif rising_edge(clk) then
            reg_out_cs_n <= '0';
            if reg_fsm = IDLE or reg_fsm = TRANSACTION_COMPLETE
                               or reg_fsm = RETURN_TO_IDLE then
                reg_out_cs_n <= '1';
            end if;
        end if;
    end process p_cs_n_reg;

    p_transaction_done_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out_transaction_done <= '0';
        elsif rising_edge(clk) then
            reg_out_transaction_done <= '0';
            if reg_fsm = TRANSACTION_COMPLETE then
                reg_out_transaction_done <= '1';
            end if;
        end if;
    end process p_transaction_done_reg;

    -- ready es el único que no es una decodificación directa del estado: se
    -- pone a cero en cuanto la petición se acepta y no vuelve a uno hasta el
    -- final, así que se describe como un biestable con puesta a uno y puesta
    -- a cero.
    p_ready_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out_ready <= '1';
        elsif rising_edge(clk) then
            if reg_out_ready = '1' then
                if (reg_fsm = IDLE) and (reg_in_start_transaction = '1') then
                    reg_out_ready <= '0';
                end if;
            else
                if reg_fsm = RETURN_TO_IDLE then
                    reg_out_ready <= '1';
                end if;
            end if;
        end if;
    end process p_ready_reg;

    --==========================================================================
    -- A partir de aquí, vuestro diseño: la señalización del bus SPI.
    --==========================================================================

    --==========================================================================
    -- sck: reloj serie del bus. Reposo a nivel bajo (CPOL = 0).
    --==========================================================================
    -- Durante BITS, sck es '1' en la primera mitad de cada bit (medio periodo
    -- par) y '0' en la segunda (impar). En las guardas y en reposo, '0'.
    p_sck_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out_sck <= '0';
        elsif rising_edge(clk) then
            reg_out_sck <= '0';
            if reg_fsm = BITS and reg_half_counter(0) = '0' then
                reg_out_sck <= '1';
            end if;
        end if;
    end process p_sck_reg;

    --==========================================================================
    -- tx_word: copia de la palabra a enviar.
    --==========================================================================
    -- reg_in_tx_word se pisa en cada ciclo con lo que haya en el puerto, así
    -- que la palabra válida se captura en el mismo ciclo en que la FSM acepta
    -- la petición (misma condición que la salida de IDLE) y se mantiene fija
    -- durante toda la trama.
    p_tx_word_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_tx_word <= (others => '0');
        elsif rising_edge(clk) then
            if reg_fsm = IDLE and reg_in_start_transaction = '1' then
                reg_tx_word <= reg_in_tx_word;
            end if;
        end if;
    end process p_tx_word_reg;

    --==========================================================================
    -- mosi: datos hacia el esclavo, MSB primero.
    --==========================================================================
    -- En BITS, el bit en curso es reg_half_counter / 2 (todos los bits menos
    -- el bajo). Se saca el bit (TRANSACTION_BW-1-índice) para ir del MSB al
    -- LSB. Al ser salida registrada, mosi cambia un ciclo después de que
    -- cambie el contador; fuera de BITS vale '0'.
    p_mosi_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out_mosi <= '0';
        elsif rising_edge(clk) then
            reg_out_mosi <= '0';
            if reg_fsm = BITS then
                reg_out_mosi <= reg_tx_word(TRANSACTION_BW - 1 -
                                to_integer(reg_half_counter(reg_half_counter'high downto 1)));
            end if;
        end if;
    end process p_mosi_reg;

    --==========================================================================
    -- rx_word: registro de desplazamiento con los bits recibidos por miso.
    --==========================================================================
    -- Se muestrea una vez por bit, en el primer ciclo de la segunda mitad del
    -- bit (reg_half_counter(0) = '1' y reg_tic_counter = 0), y se desplaza a
    -- la izquierda: el primer bit recibido (MSB) acaba en la posición alta
    -- tras TRANSACTION_BW bits.
    p_rx_word_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_out_rx_word <= (others => '0');
        elsif rising_edge(clk) then
            if reg_fsm = BITS and reg_half_counter(0) = '1' and reg_tic_counter = 0 then
                reg_out_rx_word <= reg_out_rx_word(TRANSACTION_BW - 2 downto 0) & reg_in_miso;
            end if;
        end if;
    end process p_rx_word_reg;



     --==========================================================================
    -- Divisor de reloj y contadores de la trama
    --==========================================================================
    -- half_tick: último ciclo de cada medio periodo de sck (cuenta 4 de 0..4).
    
    s_half_tick <= '1' when reg_tic_counter = CLOCK_TICS_PER_HALF_SCK - 1 else '0';

    -- Fin de fase: guardas = 2 medios periodos; bits = 2 por bit.
    s_fin_fase <= '1' when s_half_tick = '1' and
                           ((reg_fsm = BITS and reg_half_counter = 2 * TRANSACTION_BW - 1) or
                            ((reg_fsm = GUARD_INICIAL or reg_fsm = GUARD_FINAL)
                             and reg_half_counter = 1))
                  else '0';


    -- Cuenta ciclos de clk de 0 a 4. Solo corre durante las fases SPI.
    p_tic_counter_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_tic_counter <= (others => '0');
        elsif rising_edge(clk) then
            if reg_fsm = GUARD_INICIAL or reg_fsm = BITS or reg_fsm = GUARD_FINAL then
                if s_half_tick = '1' then
                    reg_tic_counter <= (others => '0');
                else
                    reg_tic_counter <= reg_tic_counter + 1;
                end if;
            else
                reg_tic_counter <= (others => '0');
            end if;
        end if;
    end process p_tic_counter_reg;

    -- Cuenta medios periodos dentro de la fase. Vuelve a 0 al cambiar de fase.
    p_half_counter_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_half_counter <= (others => '0');
        elsif rising_edge(clk) then
            if reg_fsm = GUARD_INICIAL or reg_fsm = BITS or reg_fsm = GUARD_FINAL then
                if s_fin_fase = '1' then
                    reg_half_counter <= (others => '0');
                elsif s_half_tick = '1' then
                    reg_half_counter <= reg_half_counter + 1;
                end if;
            else
                reg_half_counter <= (others => '0');
            end if;
        end if;
    end process p_half_counter_reg;

    --==========================================================================
    -- Los puertos de salida salen de sus registros y de nada más
    --==========================================================================
    cs_n             <= reg_out_cs_n;
    sck              <= reg_out_sck;
    mosi             <= reg_out_mosi;
    rx_word          <= reg_out_rx_word;
    transaction_done <= reg_out_transaction_done;
    ready            <= reg_out_ready;

end architecture rtl;
