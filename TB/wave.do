onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group GENERAL -label CLK /TB_PAMPY/pamPy_arc/general_clk
add wave -noupdate -expand -group GENERAL -label RESET /TB_PAMPY/pamPy_arc/general_reset
add wave -noupdate -expand -group GENERAL -color Salmon -label {CURRENT STATE} -radix decimal /TB_PAMPY/pamPy_arc/control/STATE
add wave -noupdate -expand -group GENERAL -color Yellow -label PC -radix decimal /TB_PAMPY/pamPy_arc/block_2/REG_PC_OUT
add wave -noupdate -expand -group GENERAL -color Red -label INSTRUCTION /TB_PAMPY/pamPy_arc/block_2/REG_INSTR_OUT
add wave -noupdate -expand -group GENERAL -color Blue -label ARG /TB_PAMPY/pamPy_arc/block_2/REG_ARG_OUT
add wave -noupdate -expand -group MEMORIES -label {TOP STACK} -radix decimal /TB_PAMPY/pamPy_arc/block_4/TOP_STACK
add wave -noupdate -expand -group MEMORIES -label {MEM INSTR} /TB_PAMPY/pamPy_arc/block_2/MEM_INSTR_OUT
add wave -noupdate -expand -group CONTROLS -label {REG PC} /TB_PAMPY/pamPy_arc/control/CTRL_REG_PC
add wave -noupdate -expand -group CONTROLS -label {REG ARG} /TB_PAMPY/pamPy_arc/control/CTRL_REG_ARG
add wave -noupdate -expand -group CONTROLS -label {REG INSTR} /TB_PAMPY/pamPy_arc/control/CTRL_REG_INSTR
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {327 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
WaveRestoreZoom {150 ns} {405 ns}
