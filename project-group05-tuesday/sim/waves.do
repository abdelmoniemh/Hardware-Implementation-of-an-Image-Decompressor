# activate waveform simulation

view wave

# format signal names in waveform

configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits us

# add signals to waveform

add wave -divider -height 20 {Top-level signals}
add wave -bin UUT/CLOCK_50_I
add wave -bin UUT/resetn
add wave UUT/top_state
#add wave -uns UUT/UART_timer

add wave -divider -height 10 {SRAM signals}
add wave -position insertpoint sim:/TB/UUT/M1_State
add wave -uns UUT/SRAM_address
add wave -hex UUT/SRAM_read_data
add wave -hex UUT/SRAM_write_data
add wave -bin UUT/SRAM_we_n


#add wave -divider -height 10 {VGA signals}
#add wave -bin UUT/VGA_unit/VGA_HSYNC_O
#add wave -bin UUT/VGA_unit/VGA_VSYNC_O
#add wave -uns UUT/VGA_unit/pixel_X_pos
#add wave -uns UUT/VGA_unit/pixel_Y_pos
#add wave -hex UUT/VGA_unit/VGA_red
#add wave -hex UUT/VGA_unit/VGA_green
#add wave -hex UUT/VGA_unit/VGA_blue


#add wave -position insertpoint sim:/TB/UUT/#ASSIGN#227/*
#add wave -position insertpoint sim:/TB/UUT/#ASSIGN#228/*
#add wave -position insertpoint sim:/TB/UUT/#ASSIGN#229/*
#add wave -position insertpoint sim:/TB/UUT/data_counter
#radix signal sim:/TB/UUT/data_counter decimal
#add wave -position insertpoint sim:/TB/UUT/readCycle
#add wave -position insertpoint sim:/TB/UUT/LOcounter
#add wave -position insertpoint sim:/TB/UUT/linecounter
#add wave -position insertpoint sim:/TB/UUT/ubufindex
#
#add wave -divider -height 10 {Output Buffers}
#add wave -position insertpoint sim:/TB/UUT/tempOutputBuf1
#add wave -position insertpoint sim:/TB/UUT/tempOutputBuf2
#add wave -position insertpoint sim:/TB/UUT/tempOutputBuf3
#add wave -position insertpoint sim:/TB/UUT/tempOutputBuf4
#add wave -position insertpoint sim:/TB/UUT/cc15OutputBuf
#radix signal sim:/TB/UUT/cc15OutputBuf hexadecimal
#add wave -position insertpoint sim:/TB/UUT/delayedGBOdd
#radix signal sim:/TB/UUT/delayedGBOdd hexadecimal
#
#
#add wave -divider -height 10 {Multipliers}
#add wave -position insertpoint sim:/TB/UUT/multiplier1
#add wave -position insertpoint sim:/TB/UUT/multiplier2
#add wave -position insertpoint sim:/TB/UUT/multiplier3
#add wave -position insertpoint sim:/TB/UUT/multiplier1_buf
#add wave -position insertpoint sim:/TB/UUT/multiplier2_buf
#add wave -position insertpoint sim:/TB/UUT/multiplier3_buf
#
#
#add wave -divider -height 10 {Operators}
#add wave -position insertpoint sim:/TB/UUT/operand1
#add wave -position insertpoint sim:/TB/UUT/operand2
#add wave -position insertpoint sim:/TB/UUT/operand3
#add wave -position insertpoint sim:/TB/UUT/operand4
#add wave -position insertpoint sim:/TB/UUT/operand5
#add wave -position insertpoint sim:/TB/UUT/operand6
#
#add wave -divider -height 10 {U/V Buffers}
#add wave -position insertpoint sim:/TB/UUT/U_buf
#add wave -position insertpoint sim:/TB/UUT/U_buf2
#add wave -position insertpoint sim:/TB/UUT/V_buf
#add wave -position insertpoint sim:/TB/UUT/V_buf2
#add wave -position insertpoint sim:/TB/UUT/Y
#add wave -position insertpoint sim:/TB/UUT/Y_buf
#
#
#add wave -divider -height 10 {U/V Prime}
#add wave -position insertpoint sim:/TB/UUT/UprimeEven
#add wave -position insertpoint sim:/TB/UUT/UprimeOdd
#add wave -position insertpoint sim:/TB/UUT/VprimeEven
#add wave -position insertpoint sim:/TB/UUT/VprimeOdd
#
#
#add wave -divider -height 10 {RGB + Buffers}
#add wave -position insertpoint sim:/TB/UUT/R
#add wave -position insertpoint sim:/TB/UUT/G
#add wave -position insertpoint sim:/TB/UUT/B
#add wave -position insertpoint sim:/TB/UUT/R_buf
#add wave -position insertpoint sim:/TB/UUT/G_buf
#add wave -position insertpoint sim:/TB/UUT/B_buf
#radix signal sim:/TB/UUT/R hexadecimal
#radix signal sim:/TB/UUT/G hexadecimal
#radix signal sim:/TB/UUT/B hexadecimal
#radix signal sim:/TB/UUT/R_buf hexadecimal
#radix signal sim:/TB/UUT/G_buf hexadecimal
#radix signal sim:/TB/UUT/B_buf hexadecimal
#
#add wave -divider -height 10 {U/V +- Signals}
#add wave -position insertpoint  \
#sim:/TB/UUT/Vjm5
#add wave -position insertpoint  \
#sim:/TB/UUT/Vjm3
#add wave -position insertpoint  \
#sim:/TB/UUT/Vjm1
#add wave -position insertpoint  \
#sim:/TB/UUT/Vjp1
#add wave -position insertpoint  \
#sim:/TB/UUT/Vjp3
#add wave -position insertpoint  \
#sim:/TB/UUT/Vjp5
#
#add wave -position insertpoint  \
#sim:/TB/UUT/Ujm5
#add wave -position insertpoint  \
#sim:/TB/UUT/Ujm3
#add wave -position insertpoint  \
#sim:/TB/UUT/Ujm1
#add wave -position insertpoint  \
#sim:/TB/UUT/Ujp1
#add wave -position insertpoint  \
#sim:/TB/UUT/Ujp3
#add wave -position insertpoint  \
#sim:/TB/UUT/Ujp5




add wave -divider -height 10 {M2 DRAM}
add wave -position insertpoint sim:/TB/UUT/M2_unit/address_0_a
add wave -position insertpoint sim:/TB/UUT/M2_unit/address_0_b
add wave -position insertpoint sim:/TB/UUT/M2_unit/read_data_0_a
add wave -position insertpoint sim:/TB/UUT/M2_unit/read_data_0_b
add wave -position insertpoint sim:/TB/UUT/M2_read_data_0_a
add wave -position insertpoint sim:/TB/UUT/read_data_0_a
add wave -position insertpoint sim:/TB/UUT/M2_read_data_0_b
add wave -position insertpoint sim:/TB/UUT/read_data_0_b

add wave -divider -height 10 {M2 Address Generator}
add wave -position insertpoint sim:/TB/UUT/M2_unit/increment
add wave -position insertpoint sim:/TB/UUT/M2_unit/SRAM_address
add wave -position insertpoint sim:/TB/UUT/M2_unit/columnBlockIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/rowBlockIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/columnIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/rowIndex

add wave -divider -height 10 {M2 Top State}
add wave -position insertpoint sim:/TB/UUT/M2_unit/M2_State
add wave -position insertpoint sim:/TB/UUT/M2_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/M2_done
add wave -position insertpoint sim:/TB/UUT/M2_unit/fetchSprimeEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/fetchSprimeDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/FetchSprimeFinished
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/ComputeTFinished
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/ComputeSFinished
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/WriteSFinished
add wave -position insertpoint sim:/TB/UUT/M2_unit/blockCounter

add wave -divider -height 10 {M2 Fetch Sprime State}
add wave -position insertpoint sim:/TB/UUT/M2_unit/fetchSprimeEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/fetchSprimeDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/fetchSprime

add wave -divider -height 10 {M2 Fetch Sprime SRAM Address}
add wave -position insertpoint sim:/TB/UUT/M2_unit/F_SRAM_address
add wave -position insertpoint sim:/TB/UUT/M2_unit/SRAM_read_data
radix signal sim:/TB/UUT/M2_unit/SRAM_address decimal
add wave -position insertpoint sim:/TB/UUT/M2_unit/increment
add wave -position insertpoint sim:/TB/UUT/M2_unit/incrementColumn
add wave -position insertpoint sim:/TB/UUT/M2_unit/decrementColumn
add wave -position insertpoint sim:/TB/UUT/M2_unit/incrementRow
add wave -position insertpoint sim:/TB/UUT/M2_unit/decrementRow
add wave -position insertpoint sim:/TB/UUT/M2_unit/doubleIncrementRow

add wave -divider -height 10 {M2 Fetch Sprime DRAM}
add wave -position insertpoint sim:/TB/UUT/M2_unit/F_address_0_a
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSprimeCounter
add wave -position insertpoint sim:/TB/UUT/M2_unit/F_write_data_0_a_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/F_write_data_0_a

add wave -divider -height 10 {M2 Compute T State}
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTState

add wave -divider -height 10 {M2 Compute T Read/Writes}
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_address_0_a
radix signal sim:/TB/UUT/M2_unit/T_address_0_a unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/read_data_0_a
radix signal sim:/TB/UUT/M2_unit/read_data_0_a hexadecimal
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_address_0_b
radix signal sim:/TB/UUT/M2_unit/T_address_0_b unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/read_data_0_b
radix signal sim:/TB/UUT/M2_unit/read_data_0_b hexadecimal
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_address_1_a
radix signal sim:/TB/UUT/M2_unit/T_address_1_a unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_data_1_a_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_data_1_a
radix signal sim:/TB/UUT/M2_unit/T_write_data_1_a hexadecimal
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_data_0_a_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_data_0_b_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_data_1_a_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_data_1_b_enable

add wave -divider -height 10 {M2 Compute T Buffers}
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_offset
radix signal sim:/TB/UUT/M2_unit/c_offset unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_column_counter
radix signal sim:/TB/UUT/M2_unit/c_column_counter unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTWriteAddress
add wave -position insertpoint sim:/TB/UUT/M2_unit/firstComputeTRun
radix signal sim:/TB/UUT/M2_unit/computeTWriteAddress unsigned

add wave -position insertpoint sim:/TB/UUT/M2_unit/sPrimeAddress
radix signal sim:/TB/UUT/M2_unit/sPrimeAddress unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/sPrimeRowBlockCounter
radix signal sim:/TB/UUT/M2_unit/sPrimeRowBlockCounter unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/t_buf
add wave -position insertpoint sim:/TB/UUT/M2_unit/t_buf2
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeTWriteBuffer 
#add wave -position insertpoint sim:/TB/UUT/M2_unit/writeCycleOutput0 
#add wave -position insertpoint sim:/TB/UUT/M2_unit/bufferCycleOutput0
#add wave -position insertpoint sim:/TB/UUT/M2_unit/writeCycleOutput1
#add wave -position insertpoint sim:/TB/UUT/M2_unit/bufferCycleOutput1
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_write_address
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_columnIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_rowIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_increment
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_incrementColumn
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_decrementColumn
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_incrementRow
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_decrementRow
add wave -position insertpoint sim:/TB/UUT/M2_unit/bufferCycle

add wave -divider -height 10 {M2 Compute T Math}
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_operand1
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_operand2
add wave -position insertpoint sim:/TB/UUT/M2_unit/multiplier1
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_operand3
add wave -position insertpoint sim:/TB/UUT/M2_unit/T_operand4
add wave -position insertpoint sim:/TB/UUT/M2_unit/multiplier2


add wave -divider -height 10 {M2 Compute S State}
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeS_State

add wave -divider -height 10 {M2 Compute S Read/Writes}
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_transpose_address
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_0
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_8
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_row_counter
add wave -position insertpoint sim:/TB/UUT/M2_unit/t_address
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_block_counter
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSWriteAddress

add wave -position insertpoint sim:/TB/UUT/M2_unit/S_address_1_a
radix signal sim:/TB/UUT/M2_unit/S_address_1_a unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/read_data_1_a
radix signal sim:/TB/UUT/M2_unit/read_data_1_a hexadecimal

add wave -position insertpoint sim:/TB/UUT/M2_unit/S_address_1_b
radix signal sim:/TB/UUT/M2_unit/S_address_1_b unsigned
add wave -position insertpoint sim:/TB/UUT/M2_unit/S_write_data_1_b_enable
add wave -position insertpoint sim:/TB/UUT/M2_unit/S_write_data_1_b
radix signal sim:/TB/UUT/M2_unit/S_write_data_1_a hexadecimal

add wave -divider -height 10 {M2 Compute S Math}
add wave -position insertpoint sim:/TB/UUT/M2_unit/S_operand1
add wave -position insertpoint sim:/TB/UUT/M2_unit/S_operand2
add wave -position insertpoint sim:/TB/UUT/M2_unit/multiplier1
add wave -position insertpoint sim:/TB/UUT/M2_unit/S_operand3
add wave -position insertpoint sim:/TB/UUT/M2_unit/S_operand4
add wave -position insertpoint sim:/TB/UUT/M2_unit/multiplier2

add wave -position insertpoint sim:/TB/UUT/M2_unit/s_buf
add wave -position insertpoint sim:/TB/UUT/M2_unit/s_buf2
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSWrite0 
add wave -position insertpoint sim:/TB/UUT/M2_unit/computeSWrite1 
add wave -position insertpoint sim:/TB/UUT/M2_unit/c_transpose_address

add wave -divider -height 10 {Write S}
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSEnable
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSDone
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeS_State
add wave -position insertpoint sim:/TB/UUT/M2_unit/address_1_b
add wave -position insertpoint sim:/TB/UUT/M2_unit/read_data_1_b
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSAddressDRAMCounter
add wave -position insertpoint sim:/TB/UUT/M2_unit/W_SRAM_address
add wave -position insertpoint sim:/TB/UUT/M2_unit/W_SRAM_write_data
add wave -position insertpoint sim:/TB/UUT/M2_unit/WrowIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/WcolumnIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/WrowBlockIndex 
add wave -position insertpoint sim:/TB/UUT/M2_unit/WcolumnBlockIndex
add wave -position insertpoint sim:/TB/UUT/M2_unit/firstWrite
add wave -position insertpoint sim:/TB/UUT/M2_unit/W_write_en
add wave -position insertpoint sim:/TB/UUT/M2_unit/writeSBuffer

add wave -position insertpoint sim:/TB/UUT/M2_unit/writeIncrement
add wave -position insertpoint sim:/TB/UUT/M2_unit/rowIncrement










