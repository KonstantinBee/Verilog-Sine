onerror {resume}
radix define fixed#25#decimal -fixed -fraction 25 -base signed -precision 6
quietly WaveActivateNextPane {} 0
add wave -noupdate /Sintest/SinX/clock
add wave -noupdate /Sintest/SinX/KEY0
add wave -noupdate /Sintest/SinX/KEY1
add wave -noupdate /Sintest/SinX/direction
add wave -noupdate /Sintest/SinX/reset
add wave -noupdate /Sintest/SinX/expense
add wave -noupdate /Sintest/SinX/Limit_quarter
add wave -noupdate /Sintest/SinX/Limit_half
add wave -noupdate /Sintest/SinX/Limit_period
add wave -noupdate -format Analog-Step -height 84 -max 5.0 /Sintest/SinX/counter_sin_quarter
add wave -noupdate /Sintest/SinX/Sin
add wave -noupdate -format Analog-Interpolated -height 84 -max 0.99984300000000004 -min -0.99984300000000004 /Sintest/M
add wave -noupdate /Sintest/SinX/Step
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2853000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1409536 ps}
run -all
