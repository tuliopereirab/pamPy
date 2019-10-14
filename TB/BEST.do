onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group GENERAL -label CLK /TB_PAMPY/pamPy_arc/general_clk
add wave -noupdate -expand -group GENERAL -label RESET /TB_PAMPY/pamPy_arc/general_reset
add wave -noupdate -expand -group GENERAL -color Salmon -label {CURRENT STATE} -radix decimal /TB_PAMPY/pamPy_arc/control/STATE
add wave -noupdate -expand -group GENERAL -color Yellow -label PC -radix decimal /TB_PAMPY/pamPy_arc/block_2/REG_PC_OUT
add wave -noupdate -expand -group GENERAL -color Red -label INSTRUCTION /TB_PAMPY/pamPy_arc/block_2/REG_INSTR_OUT
add wave -noupdate -expand -group GENERAL -color Blue -label ARG /TB_PAMPY/pamPy_arc/block_2/REG_ARG_OUT
add wave -noupdate -expand -group MEMORIES -label {TOP STACK} -radix binary /TB_PAMPY/pamPy_arc/block_4/TOP_STACK
add wave -noupdate -expand -group MEMORIES -label {MEM INSTR} /TB_PAMPY/pamPy_arc/block_2/MEM_INSTR_OUT
add wave -noupdate -expand -group MEMORIES -color {Dark Orchid} -label {REG TOS} -radix decimal /TB_PAMPY/pamPy_arc/block_4/REG_TOS_OUT
add wave -noupdate -expand -group CONTROLS -label {REG PC} /TB_PAMPY/pamPy_arc/control/CTRL_REG_PC
add wave -noupdate -expand -group CONTROLS -label {REG ARG} /TB_PAMPY/pamPy_arc/control/CTRL_REG_ARG
add wave -noupdate -expand -group CONTROLS -label {REG INSTR} /TB_PAMPY/pamPy_arc/control/CTRL_REG_INSTR
add wave -noupdate -expand -group CONTROLS -label STACK /TB_PAMPY/pamPy_arc/control/CTRL_STACK
add wave -noupdate -expand -group CONTROLS -label ULA /TB_PAMPY/pamPy_arc/control/SEL_ULA
add wave -noupdate -expand -group CONTROLS -label {MUX STACK} /TB_PAMPY/pamPy_arc/control/SEL_MUX_STACK
add wave -noupdate -expand -group CONTROLS -label {REG TOS} /TB_PAMPY/pamPy_arc/control/CTRL_REG_TOS
add wave -noupdate -expand -group CONTROLS -label STACK /TB_PAMPY/pamPy_arc/control/CTRL_STACK
add wave -noupdate -expand -group CONTROLS -label {WRITE MEMORY} /TB_PAMPY/pamPy_arc/control/CTRL_REG_WRITE_MEMORY
add wave -noupdate -expand -group CONTROLS -color Gray60 -label {MEM EXT} /TB_PAMPY/pamPy_arc/control/CTRL_MEM_EXT
add wave -noupdate -expand -group ULA -label {ULA OUT} /TB_PAMPY/pamPy_arc/block_1/ULA_OUT
add wave -noupdate -expand -group ULA -label {OP 1} /TB_PAMPY/pamPy_arc/block_1/REG1_OUT
add wave -noupdate -expand -group ULA -label {OP 2} /TB_PAMPY/pamPy_arc/block_1/REG2_OUT
add wave -noupdate -expand -group ULA -label COMP /TB_PAMPY/pamPy_arc/block_1/ULA_COMP_OUT
add wave -noupdate -expand -group ULA -label OVERFLOW /TB_PAMPY/pamPy_arc/block_1/ULA_OVERFLOW_OUT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {283 ns} 0}
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
WaveRestoreZoom {0 ns} {525 ns}
