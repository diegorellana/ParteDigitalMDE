# Ondas de la FIFO: entradas, salidas y lo de dentro (punteros, contador y memoria)
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider entradas
add wave -noupdate /tb_fifo/tb_clk
add wave -noupdate /tb_fifo/tb_reset_n
add wave -noupdate /tb_fifo/tb_write_enable
add wave -noupdate -radix hexadecimal /tb_fifo/tb_data_to_write
add wave -noupdate /tb_fifo/tb_read_enable
add wave -noupdate -divider salidas
add wave -noupdate -radix hexadecimal /tb_fifo/tb_data_read
add wave -noupdate /tb_fifo/tb_read_valid
add wave -noupdate /tb_fifo/tb_empty
add wave -noupdate /tb_fifo/tb_full
add wave -noupdate -divider internas
add wave -noupdate /tb_fifo/dut/s_write_accepted
add wave -noupdate /tb_fifo/dut/s_read_accepted
add wave -noupdate -radix unsigned /tb_fifo/dut/reg_write_pointer
add wave -noupdate -radix unsigned /tb_fifo/dut/reg_read_pointer
add wave -noupdate -radix unsigned /tb_fifo/dut/reg_data_counter
add wave -noupdate -radix hexadecimal -expand /tb_fifo/dut/reg_array
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 220
configure wave -valuecolwidth 80
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {600 ns}
