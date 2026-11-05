#==============================================================================
# fuentes.tcl - fuentes de la práctica, en orden de compilación.
#
# Las rutas son relativas a la raíz de la práctica; simular.do les antepone
# ../../ porque se ejecuta desde sim/run.
#==============================================================================

# Fuentes que pertenecen a una librería adicional
set custom_library_sources [list \

]

# Fuentes que pertenecen a la librería de trabajo WORK
set work_sources [list \
    rtl/ctes_pkg.vhd             \
    rtl/spi_master.vhd           \
    testbench/tb_spi_master.vhd  \
]
