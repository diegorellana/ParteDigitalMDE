library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library binary_to_bcd_lib;
use binary_to_bcd_lib.ctes_pkg.all;
use binary_to_bcd_lib.subtypes_pkg.all;

package functions_pkg is

    function f_double_dabble_normalize_nibble(input : t_nibble) return t_nibble;

    function f_double_dabble_normalize_nibble_array(input : std_logic_vector(C_BCD_BW - 1 downto 0))  return std_logic_vector;

    function f_count_ones_in_vector(input : std_logic_vector) return integer;

end package functions_pkg;

package body functions_pkg is

    function f_double_dabble_normalize_nibble(input : t_nibble) 
        return t_nibble is
        variable v_tmp : t_nibble := input;
    begin
        if (unsigned(v_tmp) >= 5) then
            v_tmp := std_logic_vector(unsigned(v_tmp) + 3);
        end if;

        return v_tmp;
    end function f_double_dabble_normalize_nibble;

    function f_double_dabble_normalize_nibble_array(input : std_logic_vector(C_BCD_BW - 1 downto 0)) 
        return std_logic_vector is

        variable v_tmp_nibble : std_logic_vector(C_BITS_PER_NIBBLE - 1 downto 0);
        variable v_tmp_out : std_logic_vector(input'range) := input;
    begin    
        for I in 0 to C_DECIMAL_DIGITS - 1 loop
            v_tmp_nibble := input((I+1)*C_BITS_PER_NIBBLE - 1 downto I*C_BITS_PER_NIBBLE);
            v_tmp_nibble := f_double_dabble_normalize_nibble(v_tmp_nibble);
            v_tmp_out((I+1)*C_BITS_PER_NIBBLE - 1 downto I*C_BITS_PER_NIBBLE) := v_tmp_nibble;
        end loop;

        return v_tmp_out;

    end function f_double_dabble_normalize_nibble_array;

    function f_count_ones_in_vector(input : std_logic_vector) return integer is
        variable v_count : integer := 0;
    begin
        -- Recorre el vector bit a bit y suma uno por cada '1'.
        -- Se usa input'range para que funcione con cualquier anchura
        -- y con rangos tanto "downto" como "to".
        for I in input'range loop
            if input(I) = '1' then
                v_count := v_count + 1;
            end if;
        end loop;
        return v_count;
    end function f_count_ones_in_vector;

end package body;