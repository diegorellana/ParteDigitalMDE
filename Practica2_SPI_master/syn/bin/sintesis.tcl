#==============================================================================
# sintesis.tcl - sintetiza el SPI maestro con Design Compiler.
#
# Todas las rutas del script asumen que se ejecuta desde syn/run
#
# Dos formas de usarlo:
#
#   a) a mano, copiando cada apartado en el intérprete de dc_shell, en orden;
#   b) de una vez, desde la terminal. Hay dos formas, y las dos dejan el log
#      en un archivo y además lo enseñan por pantalla mientras corre:
#
#        dc_shell -f ../bin/sintesis.tcl -output_log_file ../reports/log_sintesis.txt
#        dc_shell -f ../bin/sintesis.tcl 2>&1 | tee ../reports/log_sintesis.txt
#
#      La primera es la opción propia de la herramienta. La segunda es la del
#      shell: el 2>&1 lleva la salida de error al mismo sitio que la normal,
#      para que tee las recoja las dos.
#
#      El apartado 12 cierra la sesión: sin él, dc_shell se queda esperando
#      órdenes y el volcado nunca termina.
#==============================================================================

#------------------------------------------------------------------------------
# 1. Qué se sintetiza
#------------------------------------------------------------------------------
set C_TOP                  spi_master
set C_ARQUITECTURA         rtl
set C_LIBRERIA_TRABAJO     WORK
set C_LIBRERIA_ADICIONAL   TBD

set C_PUERTO_RELOJ         clk
set C_PERIODO_NS           10.0
set C_RETARDO_ENTRADA_NS   2.0
set C_RETARDO_SALIDA_NS    2.0

set C_ESTANDAR_VHDL        2008

set C_LIBRERIA_TECNOLOGICA class.db
set C_ESFUERZO             medium
set C_CAMINOS_INFORME      5

#------------------------------------------------------------------------------
# 2. Parar en el primer error
#
#    Sin esto, analyze, elaborate, link y compile se encadenan pase lo que
#    pase: con una errata en el VHDL el script llega hasta el final, escupe
#    una cascada de errores y deja informes escritos que parecen buenos.
#
#    Hacen falta las dos variables. sh_continue_on_error manda sobre la otra,
#    así que poner solo sh_script_stop_severity no hace nada. Van explícitas
#    porque su valor por defecto no es el mismo en todas las instalaciones, y
#    un script que se comporta distinto según la máquina no sirve.
#------------------------------------------------------------------------------
set_app_var sh_continue_on_error   false
set_app_var sh_script_stop_severity E

#------------------------------------------------------------------------------
# 3. Cargar la lista de fuentes
#------------------------------------------------------------------------------
source ../bin/fuentes.tcl

#------------------------------------------------------------------------------
# 4. Librería tecnológica
#
#    class.db es la librería de ejemplo que Synopsys distribuye con la propia
#    herramienta, así que no hace falta ningún PDK.
#
#    target_library  es con lo que la herramienta puede construir el circuito.
#    link_library    es con lo que puede resolver referencias; el * delante
#                    significa «y además lo que ya esté cargado en memoria».
#------------------------------------------------------------------------------
set dir_tecnologia $env(SYNOPSYS)/libraries/syn

set search_path    [concat $search_path $dir_tecnologia]
set target_library $C_LIBRERIA_TECNOLOGICA
set link_library   [list * $C_LIBRERIA_TECNOLOGICA]
set symbol_library {}

#------------------------------------------------------------------------------
# 5. Limpiar y definir las librerías de trabajo
#
#    Cada ejecución parte de cero: se borran los directorios de las librerías y
#    se vuelven a crear, para no arrastrar unidades analizadas de una sesión
#    anterior.
#------------------------------------------------------------------------------
file delete -force ./$C_LIBRERIA_ADICIONAL
file mkdir         ./$C_LIBRERIA_ADICIONAL
define_design_lib $C_LIBRERIA_ADICIONAL -path ./$C_LIBRERIA_ADICIONAL

file delete -force ./$C_LIBRERIA_TRABAJO
file mkdir         ./$C_LIBRERIA_TRABAJO
define_design_lib $C_LIBRERIA_TRABAJO -path ./$C_LIBRERIA_TRABAJO

# Los informes de la ejecución anterior, fuera: lo que quede en reports/ es
# siempre de la última síntesis. El patrón es *.rpt y no *, porque el log de
# la sesión se escribe en esa misma carpeta y el shell ya lo tiene abierto.
foreach informe [glob -nocomplain ../reports/*.rpt] { file delete -force $informe }

#------------------------------------------------------------------------------
# 6. Analizar las fuentes, en el orden de la lista
#
#    Si el diseño usa una librería adicional, esta se analiza primero.
#------------------------------------------------------------------------------

# Versión del lenguaje con la que se leen las fuentes. VHDL-2008 no está activo
# por defecto. Es una variable de la herramienta, no una opción de `analyze`:
# vale para todo lo que se analice después.
set hdlin_vhdl_std $C_ESTANDAR_VHDL

foreach fuente $custom_library_sources {
    echo "analyze \[$C_LIBRERIA_ADICIONAL\] $fuente"
    analyze -format vhdl -library $C_LIBRERIA_ADICIONAL ../../$fuente
}

foreach fuente $work_sources {
    echo "analyze \[$C_LIBRERIA_TRABAJO\] $fuente"
    analyze -format vhdl -library $C_LIBRERIA_TRABAJO ../../$fuente
}

#------------------------------------------------------------------------------
# 7. Elaborar y enlazar
#
#    analyze comprueba la sintaxis de cada archivo por separado. elaborate
#    construye el diseño: resuelve genéricos, instancia los componentes y deja
#    en memoria una jerarquía sobre la que ya se puede trabajar.
#------------------------------------------------------------------------------
elaborate $C_TOP -architecture $C_ARQUITECTURA -library $C_LIBRERIA_TRABAJO
current_design $C_TOP
link

#------------------------------------------------------------------------------
# 8. Restricciones
#
#    Sin reloj declarado no hay análisis temporal: la herramienta no sabe entre
#    qué dos instantes tiene que caber la lógica.
#
#    Los retardos de entrada y de salida reservan la parte del periodo que se
#    consume FUERA de este bloque: lo que tarda el circuito de delante en poner
#    el dato, y lo que necesita el de detrás para recogerlo.
#------------------------------------------------------------------------------
create_clock -name clk -period $C_PERIODO_NS [get_ports $C_PUERTO_RELOJ]

set entradas_datos [remove_from_collection [all_inputs] [get_ports $C_PUERTO_RELOJ]]
set_input_delay  $C_RETARDO_ENTRADA_NS -clock clk $entradas_datos
set_output_delay $C_RETARDO_SALIDA_NS  -clock clk [all_outputs]

#------------------------------------------------------------------------------
# 9. Sintetizar
#------------------------------------------------------------------------------
compile -map_effort $C_ESFUERZO

#------------------------------------------------------------------------------
# 10. Informes
#------------------------------------------------------------------------------
check_design                                > ../reports/check_design.rpt
report_area                                 > ../reports/area.rpt
report_timing -max_paths $C_CAMINOS_INFORME > ../reports/timing.rpt
report_qor                                  > ../reports/qor.rpt
report_reference                            > ../reports/referencias.rpt

#------------------------------------------------------------------------------
# 11. Biestables frente a latches
#
#     Un proceso combinacional con una asignación incompleta hace que la
#     herramienta infiera un latch. Este apartado cuenta cuántos registros
#     disparados por flanco (biestables) y cuántos sensibles a nivel (latches)
#     tiene el circuito sintetizado y, si hay latches, los lista por su nombre
#     para poder localizarlos.
#------------------------------------------------------------------------------
proc cuantos {coleccion} {
    if {$coleccion eq ""} { return 0 }
    return [sizeof_collection $coleccion]
}

set col_ff  [all_registers -edge_triggered]
set col_lat [all_registers -level_sensitive]

set f [open ../reports/registros.rpt w]
puts $f "Diseno   : $C_TOP"
puts $f "Libreria : $C_LIBRERIA_TECNOLOGICA"
puts $f "Biestables disparados por flanco : [cuantos $col_ff]"
puts $f "Latches (sensibles a nivel)      : [cuantos $col_lat]"
if {[cuantos $col_lat] > 0} {
    puts $f ""
    puts $f "Latches inferidos:"
    foreach_in_collection celda $col_lat {
        puts $f "  [get_object_name $celda]"
    }
}
close $f

echo "=============================================================="
echo " $C_TOP  ->  [cuantos $col_ff] biestables, [cuantos $col_lat] latches"
echo " Informes en ../reports/"
echo "=============================================================="

#------------------------------------------------------------------------------
# 12. Netlist y fin de la sesión
#
#     Comentar el exit si se está ejecutando el script a mano y se quiere
#     seguir trabajando en el intérprete.
#------------------------------------------------------------------------------
write -format verilog -hierarchy -output ../out/$C_TOP.v
write -format ddc     -hierarchy -output ../out/$C_TOP.ddc

exit
