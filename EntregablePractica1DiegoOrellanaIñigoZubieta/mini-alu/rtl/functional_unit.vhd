library ieee;
use ieee.std_logic_1164.all;

use work.types_pkg.all;

entity functional_unit is
    port (
        inputs  : in fu_inputs;
        outputs : out fu_outputs
    );
end entity functional_unit;