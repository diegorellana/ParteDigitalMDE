library ieee;
use ieee.std_logic_1164.all;

-- La librería work ya está implicita, no hace falta declararla
use work.ctes_pkg.all;
use work.types_pkg.all;

entity top_mini_alu is
    port (
        operand_a      : in  std_logic_vector(C_DATA_BW - 1 downto 0);
        operand_b      : in  std_logic_vector(C_DATA_BW - 1 downto 0);
        operation_code : in  std_logic_vector(C_OP_CODE_BW - 1 downto 0);
        operation_args : in  std_logic_vector(C_OP_ARG_BW - 1 downto 0);
        result         : out std_logic_vector(C_DATA_BW - 1 downto 0);
        error_flag     : out std_logic;
        error_code     : out std_logic_vector(C_ERROR_BW - 1 downto 0)
    );
end entity;

architecture top_alu_arch of top_mini_alu is

    -- Entradas a las funcional units
    signal s_fu_inputs : fu_inputs;

    -- Señales de salida de los distintas functional units
    signal s_fu_adder_outputs : fu_outputs;

begin

    -- Asignar entradas a las distintas functional units
    s_fu_inputs.operand_a      <= operand_a;
    s_fu_inputs.operand_b      <= operand_b;
    s_fu_inputs.operation_args <= operation_args;

    -- Multiplexar la salida de la unidad funcional correspondiente a la salida
    p_alu_out_mux : process (operation_code, s_fu_adder_outputs)
    begin
        -- Multiplexor
        case operation_code is
            when C_OPCODE_ADD =>
                result     <= s_fu_adder_outputs.result;
                error_flag <= s_fu_adder_outputs.error_flag;
                error_code <= s_fu_adder_outputs.error_code;
            when others =>
                -- Caso por defecto: el OPCODE recibido no está implementado
                result     <= (others => '0'); -- Result vale "todo ceros"
                error_flag <= '1'; 
                error_code <= C_ERROR_INVALID_OPCODE;
        end case;
    end process;

    -- Instanciar componentes

    -- * FU adder
    u_fu_adder : entity work.functional_unit(fu_adder)
        port map (
            inputs  => s_fu_inputs,
            outputs => s_fu_adder_outputs
        );

    -- * Resto de unidades funcionales
    

end architecture;
