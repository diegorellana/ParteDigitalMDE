# Ondas del conversor binario a BCD: entradas, salidas, registros de entrada,
# el path de validación y la salida de cada etapa del pipeline.
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider entradas
add wave -noupdate /tb_binary_to_bcd/tb_clk
add wave -noupdate /tb_binary_to_bcd/tb_reset_n
add wave -noupdate /tb_binary_to_bcd/tb_valid_in
add wave -noupdate -radix unsigned /tb_binary_to_bcd/tb_binary_in
add wave -noupdate -divider salidas
add wave -noupdate /tb_binary_to_bcd/tb_valid_out
add wave -noupdate -radix hexadecimal /tb_binary_to_bcd/tb_bcd_out
add wave -noupdate -divider {registros de entrada}
add wave -noupdate /tb_binary_to_bcd/dut/reg_valid_in
add wave -noupdate -radix unsigned /tb_binary_to_bcd/dut/reg_binary_in
add wave -noupdate -divider {path de validacion}
add wave -noupdate /tb_binary_to_bcd/dut/reg_valid_in_delayed
add wave -noupdate -divider {pipeline}
add wave -noupdate -radix hexadecimal /tb_binary_to_bcd/dut/s_salida_pipeline
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 260
configure wave -valuecolwidth 100
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {300 ns}
