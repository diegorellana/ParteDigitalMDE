--==============================================================================
-- binary_to_bcd.vhd - conversor de binario a BCD con el algoritmo double dabble
-- implementado como pipeline.
--
-- Estructura (sección 5 del enunciado):
--   - Registros de entrada: reg_binary_in (ya saturado a gen_max_binary_value)
--     y reg_valid_in.
--   - Path de datos: gen_binary_bw etapas iguales. Cada etapa I normaliza
--     (suma 3 a los dígitos BCD que valen 5 o más) y desplaza una posición a
--     la izquierda, metiendo por abajo el siguiente bit binario. Si
--     gen_pipeline(I) = '1', la salida de la etapa I se registra.
--   - Path de validación: registro de desplazamiento reg_valid_in_delayed con
--     tantos bits como unos tiene gen_pipeline, para que valid llegue a la
--     salida con el mismo retraso que el dato.
--   - Registros de salida: reg_bcd_out y reg_valid_out.
--
-- Latencia total = (número de unos de gen_pipeline) + 2 ciclos.
--
-- Los genéricos tienen como valor por defecto las constantes de ctes_pkg, que
-- son las que pide el enunciado para la síntesis. Así Design Compiler puede
-- elaborar la entidad sin pasarle -parameters.
--==============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library binary_to_bcd_lib;
use binary_to_bcd_lib.ctes_pkg.all;
use binary_to_bcd_lib.functions_pkg.all;

entity binary_to_bcd is
    generic (
        gen_binary_bw        : integer          := C_BINARY_BW;
        gen_bcd_bw           : integer          := C_BCD_BW;
        gen_max_binary_value : integer          := C_MAX_BINARY_VALUE;
        gen_pipeline         : std_logic_vector := C_PIPELINE
    );
    port (
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        binary_in : in  std_logic_vector(gen_binary_bw - 1 downto 0);
        valid_in  : in  std_logic;
        bcd_out   : out std_logic_vector(gen_bcd_bw - 1 downto 0);
        valid_out : out std_logic
    );
end entity binary_to_bcd;

architecture rtl of binary_to_bcd is

    -- gen_pipeline no tiene rango fijo: lo copiamos a un vector con rango
    -- (gen_binary_bw - 1 downto 0) para que el bit I sea siempre la etapa I.
    constant c_pipeline       : std_logic_vector(gen_binary_bw - 1 downto 0) := gen_pipeline;
    constant c_pipeline_delay : integer := f_count_ones_in_vector(gen_pipeline);

    constant c_max_binary_value : unsigned(gen_binary_bw - 1 downto 0) :=
        to_unsigned(gen_max_binary_value, gen_binary_bw);

    -- Lo que pasa de una etapa a la siguiente: los dígitos BCD que se van
    -- construyendo y los bits binarios que todavía no se han consumido.
    type t_pipeline_data is record
        temp_bcd       : std_logic_vector(gen_bcd_bw - 1 downto 0);
        temp_binary_in : std_logic_vector(gen_binary_bw - 1 downto 0);
    end record;

    type t_pipeline_array is array (0 to gen_binary_bw - 1) of t_pipeline_data;

    -- Registros de entrada
    signal reg_binary_in : std_logic_vector(gen_binary_bw - 1 downto 0);
    signal reg_valid_in  : std_logic;

    -- Path de datos
    signal s_entrada_pipeline : t_pipeline_array;  -- entrada de cada etapa
    signal s_normalizacion    : t_pipeline_array;  -- tras normalizar
    signal s_desplazamiento   : t_pipeline_array;  -- tras desplazar
    signal reg_pipeline       : t_pipeline_array;  -- registro opcional de cada etapa
    signal s_salida_pipeline  : t_pipeline_array;  -- salida de cada etapa (registrada o no)

    -- Path de validación de salidas
    signal reg_valid_in_delayed : std_logic_vector(c_pipeline_delay - 1 downto 0);

    -- Registros de salida
    signal reg_bcd_out   : std_logic_vector(gen_bcd_bw - 1 downto 0);
    signal reg_valid_out : std_logic;

begin

    -- Comprobaciones de los genéricos (solo actúan en simulación)
    assert gen_pipeline'length = gen_binary_bw
        report "gen_pipeline tiene que tener gen_binary_bw bits" severity failure;
    assert c_pipeline_delay >= 1
        report "gen_pipeline tiene que tener al menos un bit a '1'" severity failure;
    assert gen_bcd_bw = C_BCD_BW
        report "f_double_dabble_normalize_nibble_array trabaja con C_BCD_BW bits" severity failure;

    ---------------------------------------------------------------------------
    -- Registros de entrada. Si binary_in supera gen_max_binary_value, se
    -- guarda gen_max_binary_value (saturación).
    ---------------------------------------------------------------------------
    p_input_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_binary_in <= (others => '0');
            reg_valid_in  <= '0';
        elsif rising_edge(clk) then
            reg_valid_in <= valid_in;
            if unsigned(binary_in) > c_max_binary_value then
                reg_binary_in <= std_logic_vector(c_max_binary_value);
            else
                reg_binary_in <= binary_in;
            end if;
        end if;
    end process p_input_reg;

    ---------------------------------------------------------------------------
    -- Path de datos: pipeline del algoritmo double dabble
    ---------------------------------------------------------------------------

    -- Entrada de la etapa 0: dígitos BCD a cero y el valor binario completo
    s_entrada_pipeline(0).temp_bcd       <= (others => '0');
    s_entrada_pipeline(0).temp_binary_in <= reg_binary_in;

    generate_pipeline_stages : for I in 0 to gen_binary_bw - 1 generate

        -- Normalizar: cada dígito BCD que valga 5 o más se incrementa en 3
        s_normalizacion(I).temp_bcd <=
            f_double_dabble_normalize_nibble_array(s_entrada_pipeline(I).temp_bcd);
        s_normalizacion(I).temp_binary_in <= s_entrada_pipeline(I).temp_binary_in;

        -- Desplazar: todo una posición a la izquierda. El bit más
        -- significativo de los binarios pendientes entra por abajo en el BCD.
        s_desplazamiento(I).temp_bcd <=
            s_normalizacion(I).temp_bcd(gen_bcd_bw - 2 downto 0) &
            s_normalizacion(I).temp_binary_in(gen_binary_bw - 1);
        s_desplazamiento(I).temp_binary_in <=
            s_normalizacion(I).temp_binary_in(gen_binary_bw - 2 downto 0) & '0';

        -- Etapa registrada: gen_pipeline(I) = '1'
        generate_stage_register : if c_pipeline(I) = '1' generate
            p_pipeline_reg : process(clk, reset_n)
            begin
                if reset_n = '0' then
                    reg_pipeline(I).temp_bcd       <= (others => '0');
                    reg_pipeline(I).temp_binary_in <= (others => '0');
                elsif rising_edge(clk) then
                    reg_pipeline(I) <= s_desplazamiento(I);
                end if;
            end process p_pipeline_reg;

            s_salida_pipeline(I) <= reg_pipeline(I);
        end generate generate_stage_register;

        -- Etapa sin registrar: gen_pipeline(I) = '0'
        generate_stage_no_register : if c_pipeline(I) = '0' generate
            s_salida_pipeline(I) <= s_desplazamiento(I);
        end generate generate_stage_no_register;

        -- La salida de la etapa I es la entrada de la etapa I+1
        generate_next_stage : if I < gen_binary_bw - 1 generate
            s_entrada_pipeline(I + 1) <= s_salida_pipeline(I);
        end generate generate_next_stage;

    end generate generate_pipeline_stages;

    ---------------------------------------------------------------------------
    -- Path de validación de salidas: registro de desplazamiento con
    -- c_pipeline_delay bits.
    ---------------------------------------------------------------------------
    p_valid_delay_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_valid_in_delayed <= (others => '0');
        elsif rising_edge(clk) then
            reg_valid_in_delayed(0) <= reg_valid_in;
            for I in 1 to c_pipeline_delay - 1 loop
                reg_valid_in_delayed(I) <= reg_valid_in_delayed(I - 1);
            end loop;
        end if;
    end process p_valid_delay_reg;

    ---------------------------------------------------------------------------
    -- Registros de salida
    ---------------------------------------------------------------------------
    p_output_reg : process(clk, reset_n)
    begin
        if reset_n = '0' then
            reg_bcd_out   <= (others => '0');
            reg_valid_out <= '0';
        elsif rising_edge(clk) then
            reg_bcd_out   <= s_salida_pipeline(gen_binary_bw - 1).temp_bcd;
            reg_valid_out <= reg_valid_in_delayed(c_pipeline_delay - 1);
        end if;
    end process p_output_reg;

    bcd_out   <= reg_bcd_out;
    valid_out <= reg_valid_out;

end architecture rtl;
