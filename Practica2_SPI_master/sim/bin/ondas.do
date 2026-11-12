#==============================================================================
# ondas.do - visor de ondas de partida para el SPI maestro.
#
# Cuatro bloques separados por divisores: los puertos de la entidad, los
# registros de entrada, el estado de la máquina y los registros de salida.
# Son las señales que ya existen en el esqueleto de spi_master.vhd; según
# crezca el diseño habrá que ir añadiendo aquí las señales internas que
# interese mirar, empezando por los contadores.
#
# Las señales se cuelgan del DUT y no del banco de pruebas, para que los
# nombres que se leen sean los de spi_master.vhd.
#
# Hace falta que vsim se haya lanzado con -voptargs=+acc; si no, las señales
# internas no existen y este script falla.
#==============================================================================

set C_DUT sim:/tb_spi_master/dut

quietly set WildcardFilter "Memory CellInternal"
delete wave *

#------------------------------------------------------------------------------
# Puertos de la entidad, en el orden en que se declaran
#------------------------------------------------------------------------------
add wave -divider "Puertos"
add wave                      $C_DUT/clk
add wave                      $C_DUT/reset_n
add wave -radix hexadecimal   $C_DUT/tx_word
add wave                      $C_DUT/start_transaction
add wave -radix hexadecimal   $C_DUT/rx_word
add wave                      $C_DUT/transaction_done
add wave                      $C_DUT/ready
add wave                      $C_DUT/cs_n
add wave                      $C_DUT/sck
add wave                      $C_DUT/mosi
add wave                      $C_DUT/miso

#------------------------------------------------------------------------------
# Registros de entrada
#------------------------------------------------------------------------------
add wave -divider "Registros de entrada"
add wave                      $C_DUT/reg_in_start_transaction
add wave -radix hexadecimal   $C_DUT/reg_in_tx_word
add wave                      $C_DUT/reg_in_miso

#------------------------------------------------------------------------------
# La maquina de estados
#------------------------------------------------------------------------------
add wave -divider "FSM"
add wave                      $C_DUT/reg_fsm

#------------------------------------------------------------------------------
# Registros de salida
#------------------------------------------------------------------------------
add wave -divider "Registros de salida"
add wave -radix hexadecimal   $C_DUT/reg_out_rx_word
add wave                      $C_DUT/reg_out_transaction_done
add wave                      $C_DUT/reg_out_ready
add wave                      $C_DUT/reg_out_cs_n
add wave                      $C_DUT/reg_out_sck
add wave                      $C_DUT/reg_out_mosi

configure wave -signalnamewidth 1
configure wave -timelineunits ns
