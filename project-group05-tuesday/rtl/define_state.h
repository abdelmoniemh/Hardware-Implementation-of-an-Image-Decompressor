`ifndef DEFINE_STATE

// for top state - we have more states than needed
typedef enum logic [2:0] {
	S_IDLE,
	S_UART_RX,
	S_M1,
	S_M2,
	S_M3
} top_state_type;

typedef enum logic [1:0] {
	S_RXC_IDLE,
	S_RXC_SYNC,
	S_RXC_ASSEMBLE_DATA,
	S_RXC_STOP_BIT
} RX_Controller_state_type;

typedef enum logic [2:0] {
	S_US_IDLE,
	S_US_STRIP_FILE_HEADER_1,
	S_US_STRIP_FILE_HEADER_2,
	S_US_START_FIRST_BYTE_RECEIVE,
	S_US_WRITE_FIRST_BYTE,
	S_US_START_SECOND_BYTE_RECEIVE,
	S_US_WRITE_SECOND_BYTE
} UART_SRAM_state_type;

typedef enum logic [3:0] {
	S_VS_WAIT_NEW_PIXEL_ROW,
	S_VS_NEW_PIXEL_ROW_DELAY_1,
	S_VS_NEW_PIXEL_ROW_DELAY_2,
	S_VS_NEW_PIXEL_ROW_DELAY_3,
	S_VS_NEW_PIXEL_ROW_DELAY_4,
	S_VS_NEW_PIXEL_ROW_DELAY_5,
	S_VS_FETCH_PIXEL_DATA_0,
	S_VS_FETCH_PIXEL_DATA_1,
	S_VS_FETCH_PIXEL_DATA_2,
	S_VS_FETCH_PIXEL_DATA_3
} VGA_SRAM_state_type;

typedef enum logic [5:0] {
	M1_IDLE,
	LI_0,
	LI_1,
	LI_2,
	LI_3,
	LI_4,
	LI_5,
	LI_6,
	LI_7,
	LI_8,
	LI_9,
	CC_10,
	CC_11,
	CC_12,
	CC_13,
	CC_14,
	CC_15,
	CC_16,
	LO_17,
	LO_18,
	LO_19,
	LO_20,
	LO_21,
	LO_22,
	LO_23,
	LO_Final1,
	LO_Final2,
	LO_Final3

} M1_States;

typedef enum logic [2:0] { //Top Level M2 FSM
	M2_IDLE,
	task0,
	task1,
	task2,
	task3,
	leadOutTask0,
	leadOutTask1	
} M2_States;

typedef enum logic [3:0] { // Fetch S'
	F_IDLE,
	F_IDLE2,
	F_IDLE3,
	F_LI_0,
	F_LI_1,
	F_LI_2,
	F_CC_3,
	F_CC_4,
	F_LO_5,
	F_LO_6,
	F_LO_7,
	F_LO_8
} readSprime_States;



typedef enum logic [5:0] { // Compute T
	T_IDLE,
	T_IDLE2,
	T_IDLE3,
	T_LI_0,
	T_LI_1,
	T_LI_2,
	T_CC_3,
	T_CC_4,
	T_CC_5,
	T_CC_6,
	T_CC_7,
	T_CC_8,
	T_CC_9,
	T_CC_10,
	T_LO_11,
	T_LO_12,
	T_LO_13,
	T_LO_14,
	T_LO_15,
	T_LO_16,
	T_LO_17,
	T_LO_18,
	T_LO_19,
	T_LO_20
} computeT_States;

typedef enum logic [5:0] { // Compute S
	CS_IDLE,
	CS_IDLE2,
	CS_IDLE3,
	S_LI_0,
	S_LI_1,
	S_LI_2,
	S_CC_3,
	S_CC_4,
	S_CC_5,
	S_CC_6,
	S_CC_7,
	S_CC_8,
	S_CC_9,
	S_CC_10,
	S_LO_11,
	S_LO_12,
	S_LO_13,
	S_LO_14,
	S_LO_15,
	S_LO_16,
	S_LO_17,
	S_LO_18, 
	S_LO_19
} computeS_States;

typedef enum logic [3:0] { // Write S
	W_IDLE,
	W_IDLE2,
	W_IDLE3,
	W_LI_0,
	W_LI_1,
	W_LI_2,
	W_LI_3,
	W_CC_4,
	W_CC_5,
	W_LO_6,
	W_LO_7,
	W_LO_8,
	W_LO_9
} writeS_States;

parameter 
   VIEW_AREA_LEFT = 160,
   VIEW_AREA_RIGHT = 480,
   VIEW_AREA_TOP = 120,
   VIEW_AREA_BOTTOM = 360;

`define DEFINE_STATE 1
`endif
