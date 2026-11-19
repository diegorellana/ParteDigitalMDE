#==============================================================================
# simular.do - lanza en Questa la simulación de la práctica.
#
# Es una plantilla: hay que rellenar todo lo que pone
# A_DEFINIR_POR_EL_ALUMNO, y la lista de fuentes de ../bin/fuentes.tcl.
#
# Todas las rutas del script asumen que se ejecuta desde sim/run
#==============================================================================

#------------------------------------------------------------------------------
# 1. Qué se simula
#------------------------------------------------------------------------------
set C_TOP                  tb_binary_to_bcd
set C_LIBRERIA_TRABAJO     work
set C_LIBRERIA_ADICIONAL   binary_to_bcd_lib
set C_ESTANDAR_VHDL        -2008

#------------------------------------------------------------------------------
# 2. Cargar lista de fuentes
#------------------------------------------------------------------------------
source ../bin/fuentes.tcl

#------------------------------------------------------------------------------
# 3. Limpiar librerías. Cada ejecución parte desde cero, sin compilación
#    incremental. Evita dejar un rastro de elementos viejos.
#------------------------------------------------------------------------------
catch {quit -sim}

file delete -force $C_LIBRERIA_ADICIONAL
vlib $C_LIBRERIA_ADICIONAL
vmap $C_LIBRERIA_ADICIONAL $C_LIBRERIA_ADICIONAL

file delete -force $C_LIBRERIA_TRABAJO
vlib $C_LIBRERIA_TRABAJO
vmap $C_LIBRERIA_TRABAJO $C_LIBRERIA_TRABAJO

#------------------------------------------------------------------------------
# 4. Analizar las fuentes, en el orden de la lista
#
#    En caso de que work use una librería adicional, esta se compila primero
#------------------------------------------------------------------------------
foreach fuente $custom_library_sources {
    echo "vcom \[$C_LIBRERIA_ADICIONAL\] $fuente"
    vcom $C_ESTANDAR_VHDL -work $C_LIBRERIA_ADICIONAL ../../$fuente
}

foreach fuente $work_sources {
    echo "vcom \[$C_LIBRERIA_TRABAJO\] $fuente"
    vcom $C_ESTANDAR_VHDL -work $C_LIBRERIA_TRABAJO ../../$fuente
}

#------------------------------------------------------------------------------
# 5. Elaborar y cargar la simulación
#
#    -voptargs=+acc desactiva las optimizaciones que eliminarían las señales
#    internas: sin eso, muchas no se pueden ver en el visor de ondas.
#------------------------------------------------------------------------------
vsim -voptargs=+acc $C_LIBRERIA_TRABAJO.$C_TOP

#------------------------------------------------------------------------------
# 6. Configuración del visor de ondas
#
#    Esta práctica no trae ningún ondas.do: el visor hay que construirlo.
#    La forma cómoda es colocar las señales a mano en la ventana Wave y
#    volcar el resultado con
#        write format wave ../bin/ondas.do
#    Hecho eso, se descomenta la línea de abajo y se carga solo.
#------------------------------------------------------------------------------
do ../bin/ondas.do

#------------------------------------------------------------------------------
# 7. Ejecutar la simulación
#
#    Descomenta si se quiere que arranque sola.
#------------------------------------------------------------------------------
run -all

#------------------------------------------------------------------------------
# 8. Reiniciar una simulación ya cargada
#------------------------------------------------------------------------------
# restart -f
