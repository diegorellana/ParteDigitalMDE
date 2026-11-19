library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package ctes_pkg is
    -- No modificar: estas constantes están pensadas para
    -- el display de 7 segmentos de la Basys3
    constant C_DECIMAL_DIGITS      : integer := 4;
    constant C_BITS_PER_NIBBLE     : integer := 4;
    constant C_MAX_BINARY_VALUE    : integer := 10**C_DECIMAL_DIGITS - 1;
    constant C_BINARY_BW           : integer := natural(ceil(log2(real(C_MAX_BINARY_VALUE + 1))));
    constant C_BCD_BW              : integer := C_DECIMAL_DIGITS * C_BITS_PER_NIBBLE;
    -- La constante que controla la ubicación de las
    -- etapas de registro en el pipeline se puede
    -- modificar
    constant C_PIPELINE            : std_logic_vector(C_BINARY_BW - 1 downto 0) := (others => '1');
end package ctes_pkg;