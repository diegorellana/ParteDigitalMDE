#==============================================================================
# implementar.tcl - crea el proyecto de Vivado, implementa y saca el bitstream.
#
# Se lanza desde impl_fpga/vivado_prj:
#     vivado -mode batch -source implementar.tcl
#
# Deja en reports/ los dos informes que se piden (utilización después de place
# y timing summary después de route) y en bitstream/ el .bit y el .bin.
#
# La profundidad y el ancho de la FIFO NO se cambian aquí: son las constantes
# FIFO_DEPTH y FIFO_WIDTH de rtl_fpga/top_fifo_fpga.vhd.
#==============================================================================

set C_PROYECTO  fifo_basys3
set C_TOP       top_fifo_fpga
set C_FPGA      xc7a35tcpg236-1
set C_RTL       ../rtl_fpga
set C_LIB_PLACA $C_RTL/basys3_lib

# Desde cero cada vez, para no arrastrar nada de una ejecución anterior
file delete -force ./$C_PROYECTO
create_project $C_PROYECTO ./$C_PROYECTO -part $C_FPGA

# La librería de la placa va en basys3_lib, que es como la llama el top
set fuentes_lib [list \
    $C_LIB_PLACA/basys3_ctes_pkg.vhd \
    $C_LIB_PLACA/basys3_types_pkg.vhd \
    $C_LIB_PLACA/basys3_functions_pkg.vhd \
    $C_LIB_PLACA/basys3_components_pkg.vhd \
    $C_LIB_PLACA/debouncer.vhd \
    $C_LIB_PLACA/seven_segment_display_adapter.vhd \
]
add_files $fuentes_lib
set_property library basys3_lib [get_files $fuentes_lib]

# La FIFO y el top van en work
add_files [list ../../rtl/fifo.vhd $C_RTL/top_fifo_fpga.vhd]

# Todo en VHDL-2008, igual que en Questa y en Design Compiler
set_property file_type {VHDL 2008} [get_files *.vhd]

add_files -fileset constrs_1 ../constraints/constraints.xdc

set_property top $C_TOP [current_fileset]
update_compile_order -fileset sources_1

# Que además del .bit saque el .bin
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Copio lo que hay que entregar a carpetas fáciles de encontrar
file mkdir reports bitstream
set dir_impl ./$C_PROYECTO/$C_PROYECTO.runs/impl_1
file copy -force $dir_impl/${C_TOP}_utilization_placed.rpt    reports/
file copy -force $dir_impl/${C_TOP}_timing_summary_routed.rpt reports/
file copy -force $dir_impl/${C_TOP}.bit bitstream/
file copy -force $dir_impl/${C_TOP}.bin bitstream/

# Informe de qué se ha inferido en la síntesis (para ver si hay RAM)
open_run synth_1
report_utilization -hierarchical -file reports/${C_TOP}_utilization_synth_hier.rpt
report_ram_utilization -file reports/${C_TOP}_ram_utilization_synth.rpt

close_project
