#==============================================================================
# fuentes.tcl - fuentes de la práctica, en orden de compilación.
#==============================================================================

# Fuentes que pertenecen a una librería adicional
set custom_library_sources [list \

]

# Fuentes que pertenecen a la librería de trabajo WORK
set work_sources [list \
    rtl/ctes_pkg.vhd        \
    rtl/types_pkg.vhd       \
    rtl/functional_unit.vhd \
    rtl/fu_arch_adder.vhd   \
    rtl/fu_arch_substract.vhd \
    rtl/fu_arch_compare.vhd \
    rtl/fu_arch_shift.vhd \
    rtl/fu_arch_logic.vhd \
    rtl/fu_arch_nibble_swap.vhd \
    rtl/top_mini_alu.vhd    \
    testbench/tb_top_mini_alu.vhd \
]
