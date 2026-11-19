#==============================================================================
# fuentes.tcl - fuentes de la práctica, en orden de compilación.
#
# Las rutas son relativas a la raíz de la práctica; simular.do les antepone
# ../../ porque se ejecuta desde sim/run.
#==============================================================================

# Fuentes que pertenecen a una librería adicional
set custom_library_sources [list \
    rtl/binary_to_bcd_lib/ctes_pkg.vhd \
    rtl/binary_to_bcd_lib/subtypes_pkg.vhd \
    rtl/binary_to_bcd_lib/functions_pkg.vhd \
]

# Fuentes que pertenecen a la librería de trabajo WORK
set work_sources [list \
    rtl/binary_to_bcd.vhd \
    testbench/tb_binary_to_bcd.vhd \
]
