#==============================================================================
# simular.do - lanza en Questa la simulación de la práctica.
#
# Todas las rutas del script asumen que se ejecuta desde sim/run
#==============================================================================

#------------------------------------------------------------------------------
# 1. Qué se simula
#------------------------------------------------------------------------------
set C_TOP                  tb_top_mini_alu
set C_LIBRERIA_TRABAJO     work
set C_LIBRERIA_ADICIONAL   TBD
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
# 6. Configuración del visor de ondas (opcional)
#
#    Para generar el fichero: coloca las señales a tu gusto en la ventana Wave
#    y ejecuta
#        write format wave ../bin/wave.do
#    Después descomenta la línea siguiente.
#------------------------------------------------------------------------------
do ../bin/wave.do

#------------------------------------------------------------------------------
# 7. Ejecutar la simulación
#
#    Descomenta si se quiere que arranque sola.
#------------------------------------------------------------------------------
# run -all

#------------------------------------------------------------------------------
# 8. Reiniciar una simulación ya cargada
#------------------------------------------------------------------------------
# restart -f
