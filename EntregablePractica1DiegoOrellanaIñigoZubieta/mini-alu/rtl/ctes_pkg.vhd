library ieee;
use ieee.std_logic_1164.all;

package ctes_pkg is
    -- Definición de anchuras de bit
    constant C_DATA_BW    : integer := 8;
    constant C_OP_CODE_BW : integer := 3;
    constant C_OP_ARG_BW  : integer := 2;    
    constant C_ERROR_BW   : integer := 3;

    -- Definicion de OPCODES
    -- Nota: las siguientes constantes se pueden compilar correctamente
    --       porque C_OP_CODE_BW ya está analizado anteriormente
    constant C_OPCODE_ADD           : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := "000";
    constant C_OPCODE_SUB           : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := "001";
    constant C_OPCODE_COMP          : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := "010";
    constant C_OPCODE_SHIFT         : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := "011";
    constant C_OPCODE_BITWISE_LOGIC : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := "100";
    constant C_OPCODE_NIBBLE_SWAP   : std_logic_vector(C_OP_CODE_BW - 1 downto 0) := "101";
    
    -- Definición de argumentos
    -- Nota: las siguientes constantes se pueden compilar correctamente
    --       porque C_OP_ARG_BW ya está analizado 
    --       anteriormente
    constant C_ARG_UNSIGNED : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "00";
    constant C_ARG_SIGNED   : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "01";
    constant C_ARG_SHR_U    : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "00";
    constant C_ARG_SHR_S    : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "01";
    constant C_ARG_SHL_U    : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "10";
    constant C_ARG_SHL_S    : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "11";
    constant C_ARG_CMP_U_G  : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "00";
    constant C_ARG_CMP_S_G  : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "01";
    constant C_ARG_CMP_U_L  : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "10";
    constant C_ARG_CMP_S_L  : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "11";
    constant C_ARG_AND      : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "00";
    constant C_ARG_OR       : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "01";
    constant C_ARG_XOR      : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "10";
    constant C_ARG_MALB     : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "00";
    constant C_ARG_MBLA     : std_logic_vector(C_OP_ARG_BW - 1 downto 0) := "01";

    -- Definicion de códigos de error
    constant C_STATUS_OK              : std_logic_vector(C_ERROR_BW - 1 downto 0) := "000";
    constant C_ERROR_INVALID_OPCODE   : std_logic_vector(C_ERROR_BW - 1 downto 0) := "001";
    constant C_ERROR_INVALID_ARGUMENT : std_logic_vector(C_ERROR_BW - 1 downto 0) := "010";
    constant C_ERROR_OVERFLOW         : std_logic_vector(C_ERROR_BW - 1 downto 0) := "011";
    constant C_ERROR_UNDERFLOW        : std_logic_vector(C_ERROR_BW - 1 downto 0) := "100";  
    
end package ctes_pkg;