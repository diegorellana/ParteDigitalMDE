#==============================================================================
# fuentes.tcl - fuentes sintetizables, en orden de análisis.
#
# Las rutas son relativas a la raíz de la práctica. sintesis.tcl les antepone
# ../../ porque se ejecuta desde syn/run.
#
# Aquí NO va el testbench: no es sintetizable. Esa es la razón de que esta
# lista sea distinta de la de sim/bin/fuentes.tcl, que sí lo incluye: mismo
# nombre, distinto directorio y distinto contenido.
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
]
