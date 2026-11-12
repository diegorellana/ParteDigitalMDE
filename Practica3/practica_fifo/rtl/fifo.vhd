--==============================================================================
-- fifo.vhd - memoria FIFO de un solo reloj, genérica en profundidad y ancho.
--
-- Idea general:
--   - reg_array es la memoria (gen_depth posiciones de gen_width bits).
--   - reg_write_pointer apunta a donde va el siguiente dato que entre.
--   - reg_read_pointer apunta al siguiente dato que va a salir.
--   - reg_data_counter cuenta cuántos datos hay guardados (0..gen_depth).
--     De aquí salen empty (= 0) y full (= gen_depth).
--
-- Los dos punteros dan la vuelta al llegar a gen_depth - 1 (cola circular).
--
-- Lectura: si se acepta una lectura en el ciclo N, en el ciclo N+1 sale el
-- dato por data_read y read_valid se pone a '1' durante ese ciclo. Fuera de
-- eso data_read puede valer cualquier cosa (se queda con el último leído).
--
-- Escritura y lectura a la vez:
--   - llena:      solo se hace la lectura (la escritura se pierde)
--   - vacía:      solo se hace la escritura (la lectura se pierde)
--   - intermedio: se hacen las dos y el contador no cambia
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;

entity fifo is
    generic (
        gen_depth : integer;
        gen_width : integer
    );
    port (
        clk           : in  std_logic;
        reset_n       : in  std_logic;
        write_enable  : in  std_logic;
        data_to_write : in  std_logic_vector(gen_width - 1 downto 0);
        read_enable   : in  std_logic;
        data_read     : out std_logic_vector(gen_width - 1 downto 0);
        read_valid    : out std_logic;
        empty         : out std_logic;
        full          : out std_logic
    );
end entity fifo;

architecture rtl of fifo is

    -- Punteros de escritura y lectura, y contador de ocupación.
    -- Ojo: el contador va hasta gen_depth (no gen_depth - 1), porque tiene
    -- que poder distinguir "llena" de "vacía" cuando los punteros coinciden.
    signal reg_write_pointer : integer range 0 to gen_depth - 1;
    signal reg_read_pointer  : integer range 0 to gen_depth - 1;
    signal reg_data_counter  : integer range 0 to gen_depth;

    -- La memoria de la FIFO
    type t_array is array (0 to gen_depth - 1) of std_logic_vector(gen_width - 1 downto 0);
    signal reg_array : t_array;

    -- Operaciones que de verdad se hacen este ciclo (la petición + que se pueda)
    signal s_write_accepted : std_logic;
    signal s_read_accepted  : std_logic;

    -- Registros de salida: dato leído y su read_valid (salen un ciclo después)
    signal reg_data_read  : std_logic_vector(gen_width - 1 downto 0);
    signal reg_read_valid : std_logic;

begin

    ----------------------------------------------------------------------------
    -- Indicadores empty y full, sacados directamente del contador
    ----------------------------------------------------------------------------
    p_empty : process (reg_data_counter)
    begin
        if reg_data_counter = 0 then
            empty <= '1';
        else
            empty <= '0';
        end if;
    end process p_empty;

    p_full : process (reg_data_counter)
    begin
        if reg_data_counter = gen_depth then
            full <= '1';
        else
            full <= '0';
        end if;
    end process p_full;

    ----------------------------------------------------------------------------
    -- Qué operaciones se aceptan.
    -- Se mira solo el contador (es lo mismo que mirar full / empty), así una
    -- lectura simultánea NO deja escribir en una FIFO llena y una escritura
    -- simultánea NO deja leer de una FIFO vacía, que es lo que pide la tabla.
    -- Asigno '0' por defecto al principio para que no salgan latches.
    ----------------------------------------------------------------------------
    p_write_accepted : process (write_enable, reg_data_counter)
    begin
        s_write_accepted <= '0';
        if write_enable = '1' and reg_data_counter < gen_depth then
            s_write_accepted <= '1';
        end if;
    end process p_write_accepted;

    p_read_accepted : process (read_enable, reg_data_counter)
    begin
        s_read_accepted <= '0';
        if read_enable = '1' and reg_data_counter > 0 then
            s_read_accepted <= '1';
        end if;
    end process p_read_accepted;

    ----------------------------------------------------------------------------
    -- Puntero de escritura: avanza con cada escritura aceptada y vuelve a 0
    -- después de la última posición.
    ----------------------------------------------------------------------------
    p_write_pointer : process (clk, reset_n)
    begin
        if reset_n = '0' then
            reg_write_pointer <= 0;
        elsif rising_edge(clk) then
            if s_write_accepted = '1' then
                if reg_write_pointer = gen_depth - 1 then
                    reg_write_pointer <= 0;
                else
                    reg_write_pointer <= reg_write_pointer + 1;
                end if;
            end if;
        end if;
    end process p_write_pointer;

    ----------------------------------------------------------------------------
    -- Puntero de lectura: igual que el de escritura pero con la lectura
    ----------------------------------------------------------------------------
    p_read_pointer : process (clk, reset_n)
    begin
        if reset_n = '0' then
            reg_read_pointer <= 0;
        elsif rising_edge(clk) then
            if s_read_accepted = '1' then
                if reg_read_pointer = gen_depth - 1 then
                    reg_read_pointer <= 0;
                else
                    reg_read_pointer <= reg_read_pointer + 1;
                end if;
            end if;
        end if;
    end process p_read_pointer;

    ----------------------------------------------------------------------------
    -- Contador de ocupación.
    -- Solo escritura -> +1. Solo lectura -> -1. Las dos o ninguna -> igual.
    -- No hace falta comprobar los límites aquí: s_write_accepted ya no se
    -- activa con la FIFO llena ni s_read_accepted con la FIFO vacía.
    ----------------------------------------------------------------------------
    p_count : process (clk, reset_n)
    begin
        if reset_n = '0' then
            reg_data_counter <= 0;
        elsif rising_edge(clk) then
            if s_write_accepted = '1' and s_read_accepted = '0' then
                reg_data_counter <= reg_data_counter + 1;
            elsif s_write_accepted = '0' and s_read_accepted = '1' then
                reg_data_counter <= reg_data_counter - 1;
            end if;
        end if;
    end process p_count;

    ----------------------------------------------------------------------------
    -- Escritura en la memoria.
    -- Sin reset a propósito: lo que haya en una posición no importa hasta que
    -- se escribe, porque el contador impide leerla antes. Además así Vivado
    -- puede meter la memoria en RAM (las RAM de la FPGA no tienen reset).
    ----------------------------------------------------------------------------
    p_array : process (clk)
    begin
        if rising_edge(clk) then
            if s_write_accepted = '1' then
                reg_array(reg_write_pointer) <= data_to_write;
            end if;
        end if;
    end process p_array;

    ----------------------------------------------------------------------------
    -- Dato leído: se captura en el flanco en el que se acepta la lectura, así
    -- que aparece en data_read el ciclo siguiente.
    -- Tampoco tiene reset: data_read solo vale algo cuando read_valid = '1'.
    ----------------------------------------------------------------------------
    p_data_read : process (clk)
    begin
        if rising_edge(clk) then
            if s_read_accepted = '1' then
                reg_data_read <= reg_array(reg_read_pointer);
            end if;
        end if;
    end process p_data_read;

    ----------------------------------------------------------------------------
    -- read_valid: copia retrasada un ciclo de s_read_accepted, para que vaya
    -- a la par que reg_data_read. Este sí lleva reset, si no después del reset
    -- podría salir un read_valid = '1' falso.
    ----------------------------------------------------------------------------
    p_read_valid : process (clk, reset_n)
    begin
        if reset_n = '0' then
            reg_read_valid <= '0';
        elsif rising_edge(clk) then
            reg_read_valid <= s_read_accepted;
        end if;
    end process p_read_valid;

    -- Salidas
    data_read  <= reg_data_read;
    read_valid <= reg_read_valid;

end architecture rtl;
