/*
Copyright by Henry Ko and Nicola Nicolici
Department of Electrical and Computer Engineering
McMaster University
Ontario, Canada
*/

`timescale 1ns/100ps
`ifndef DISABLE_DEFAULT_NET
`default_nettype none
`endif

`include "define_state.h"

// This is the top module (same as experiment4 from lab 5 - just module renamed to "project")
// It connects the UART, SRAM and VGA together.
// It gives access to the SRAM for UART and VGA
module project (
		/////// board clocks                      ////////////
		input logic CLOCK_50_I,                   // 50 MHz clock

		/////// pushbuttons/switches              ////////////
		input logic[3:0] PUSH_BUTTON_N_I,         // pushbuttons
		input logic[17:0] SWITCH_I,               // toggle switches

		/////// 7 segment displays/LEDs           ////////////
		output logic[6:0] SEVEN_SEGMENT_N_O[7:0], // 8 seven segment displays
		output logic[8:0] LED_GREEN_O,            // 9 green LEDs

		/////// VGA interface                     ////////////
		output logic VGA_CLOCK_O,                 // VGA clock
		output logic VGA_HSYNC_O,                 // VGA H_SYNC
		output logic VGA_VSYNC_O,                 // VGA V_SYNC
		output logic VGA_BLANK_O,                 // VGA BLANK
		output logic VGA_SYNC_O,                  // VGA SYNC
		output logic[7:0] VGA_RED_O,              // VGA red
		output logic[7:0] VGA_GREEN_O,            // VGA green
		output logic[7:0] VGA_BLUE_O,             // VGA blue
		
		/////// SRAM Interface                    ////////////
		inout wire[15:0] SRAM_DATA_IO,            // SRAM data bus 16 bits
		output logic[19:0] SRAM_ADDRESS_O,        // SRAM address bus 18 bits
		output logic SRAM_UB_N_O,                 // SRAM high-byte data mask 
		output logic SRAM_LB_N_O,                 // SRAM low-byte data mask 
		output logic SRAM_WE_N_O,                 // SRAM write enable
		output logic SRAM_CE_N_O,                 // SRAM chip enable
		output logic SRAM_OE_N_O,                 // SRAM output logic enable
		
		/////// UART                              ////////////
		input logic UART_RX_I,                    // UART receive signal
		output logic UART_TX_O                    // UART transmit signal
);
	
logic resetn;

//Project Variables
logic [17:0] M1_SRAM_address;
logic [15:0] M1_SRAM_write_data;
logic M1_write_en;

logic [17:0] M2_SRAM_address;
logic [15:0] M2_SRAM_write_data;
logic M2_SRAM_we_n;
logic M2_enable = 1'b0;
logic M2_done;

//Milestone 1 Vars
logic [17:0] U_offset = 18'd38400;
logic [17:0] V_offset = 18'd57600;

int j;
int linecounter;
int LOcounter;
int rgbWriteCounter;
logic [17:0] data_counter=18'd0;
int multiplier1;
int multiplier2;
int multiplier3;
int tempOutputBuf1;
int tempOutputBuf2;
int tempOutputBuf3;
int tempOutputBuf4;

int multiplier1_buf;
int multiplier2_buf;
int multiplier3_buf;

int multiplier2_Y_buf;

int operand1 = 32'b0;
int operand2 = 32'b0;
int operand3 = 32'b0;
int operand4 = 32'b0;
int operand5 = 32'b0;
int operand6 = 32'b0;

int Uprime = 32'b0;
int Vprime = 32'b0;

int UprimeEven = 32'b0;
int UprimeOdd = 32'b0;
int VprimeEven = 32'b0;
int VprimeOdd = 32'b0;
int ubufindex = 32'd0;

int R = 32'd0;
int G = 32'd0;
int B = 32'd0;

int R_buf = 32'd0;
int G_buf = 32'd0;
int B_buf = 32'd0;

int Y_Buf_Color_Buf;
logic first = 1'b1;

logic [15:0] Y;
logic [15:0] Y_buf;

logic [15:0] U_buf;
logic [15:0] U_buf2;
logic [15:0]V_buf;
logic [15:0] V_buf2;

logic [7:0] Ujm5;
logic [7:0] Vjm5;

logic [7:0] Ujm3;
logic [7:0] Vjm3;

logic [7:0] Ujm1;
logic [7:0] Vjm1;

logic [7:0] Ujp1;
logic [7:0] Vjp1;

logic [7:0] Ujp3;
logic [7:0] Vjp3;

logic [7:0] Ujp5;
logic [7:0] Vjp5;

logic readCycle= 1'b0;

logic [15:0] delayedGBOdd;


top_state_type top_state;

M1_States M1_State; 
logic M1_done;
// For Push button
logic [3:0] PB_pushed;

// For VGA SRAM interface
logic VGA_enable;
logic [17:0] VGA_base_address;
logic [17:0] VGA_SRAM_address;

// For SRAM
logic [17:0] SRAM_address;
logic [15:0] SRAM_write_data;
logic SRAM_we_n;
logic [15:0] SRAM_read_data;
logic SRAM_ready;

// For UART SRAM interface
logic UART_rx_enable;
logic UART_rx_initialize;
logic [17:0] UART_SRAM_address;
logic [15:0] UART_SRAM_write_data;
logic UART_SRAM_we_n;
logic [25:0] UART_timer;

logic [6:0] value_7_segment [7:0];

// For error detection in UART
logic Frame_error;

// For disabling UART transmit
assign UART_TX_O = 1'b1;

assign resetn = ~SWITCH_I[17] && SRAM_ready;

assign tempOutputBuf1 = (R_buf + multiplier1);
assign tempOutputBuf2 = (G_buf + multiplier1);
assign tempOutputBuf3 = (B_buf + multiplier1);
assign tempOutputBuf4 = (multiplier3 + multiplier2);

int cc15OutputBuf;
assign cc15OutputBuf = (R + multiplier2);

//assign cc15OutputBuf2 = (G - multiplier1);


// Push Button unit
PB_controller PB_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(resetn),
	.PB_signal(PUSH_BUTTON_N_I),	
	.PB_pushed(PB_pushed)
);

VGA_SRAM_interface VGA_unit (
	.Clock(CLOCK_50_I),
	.Resetn(resetn),
	.VGA_enable(VGA_enable),
   
	// For accessing SRAM
	.SRAM_base_address(VGA_base_address),
	.SRAM_address(VGA_SRAM_address),
	.SRAM_read_data(SRAM_read_data),
   
	// To VGA pins
	.VGA_CLOCK_O(VGA_CLOCK_O),
	.VGA_HSYNC_O(VGA_HSYNC_O),
	.VGA_VSYNC_O(VGA_VSYNC_O),
	.VGA_BLANK_O(VGA_BLANK_O),
	.VGA_SYNC_O(VGA_SYNC_O),
	.VGA_RED_O(VGA_RED_O),
	.VGA_GREEN_O(VGA_GREEN_O),
	.VGA_BLUE_O(VGA_BLUE_O)
);

// UART SRAM interface
UART_SRAM_interface UART_unit(
	.Clock(CLOCK_50_I),
	.Resetn(resetn), 
   
	.UART_RX_I(UART_RX_I),
	.Initialize(UART_rx_initialize),
	.Enable(UART_rx_enable),
   
	// For accessing SRAM
	.SRAM_address(UART_SRAM_address),
	.SRAM_write_data(UART_SRAM_write_data),
	.SRAM_we_n(UART_SRAM_we_n),
	.Frame_error(Frame_error)
);

logic [6:0] address_0_a, address_0_b;
logic [6:0] address_1_a, address_1_b;

logic [31:0] write_data_0_a, write_data_1_a;
logic [31:0] write_data_0_b, write_data_1_b;

logic write_data_0_a_enable, write_data_1_a_enable;
logic write_data_0_b_enable, write_data_1_b_enable;

logic [31:0] read_data_0_a, read_data_0_b;
logic [31:0] read_data_1_a, read_data_1_b;


dual_port_RAM0 RAM_inst0 (
	.address_a ( address_0_a ),
	.address_b ( address_0_b ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_0_a ),
	.data_b ( write_data_0_b ),
	.wren_a ( write_data_0_a_enable ),
	.wren_b ( write_data_0_b_enable ),
	.q_a ( read_data_0_a ),
	.q_b ( read_data_0_b )
	);

// instantiate RAM1
dual_port_RAM1 RAM_inst1 (
	.address_a ( address_1_a ),
	.address_b ( address_1_b ),
	.clock ( CLOCK_50_I ),
	.data_a ( write_data_1_a ),
	.data_b ( write_data_1_b ),
	.wren_a ( write_data_1_a_enable ),
	.wren_b ( write_data_1_b_enable ),
	.q_a ( read_data_1_a ),
	.q_b ( read_data_1_b )
	);

logic [6:0] M2_address_0_a = 7'd0;
logic [6:0] M2_address_0_b = 7'd0;
logic [31:0] M2_write_data_0_a = 31'd0;
logic [31:0] M2_write_data_0_b = 31'd0;
logic M2_write_data_0_a_enable = 1'd0;
logic M2_write_data_0_b_enable = 1'd0;
logic [31:0] M2_read_data_0_a;
logic [31:0] M2_read_data_0_b;

	
Milestone2 M2_unit(
	.Clock(CLOCK_50_I),
	.Resetn(resetn), 
   .M2_enable(M2_enable),
	.SRAM_read_data(SRAM_read_data),
	
	// For accessing SRAM
	.SRAM_address(M2_SRAM_address),
	.SRAM_write_data(M2_SRAM_write_data),
	.SRAM_we_n(M2_SRAM_we_n),
	.M2_done(M2_done),
	
	//DRAM 0 
	.address_0_a ( M2_address_0_a ),
	.address_0_b ( M2_address_0_b ),
	.write_data_0_a ( M2_write_data_0_a ),
	.write_data_0_b ( M2_write_data_0_b ),
	.write_data_0_a_enable ( M2_write_data_0_a_enable ),
	.write_data_0_b_enable ( M2_write_data_0_b_enable ),
	.read_data_0_a ( read_data_0_a ),
	.read_data_0_b ( read_data_0_b ),
	
	//DRAM 1
	.address_1_a ( address_1_a ),
	.address_1_b ( address_1_b ),
	.write_data_1_a ( write_data_1_a ),
	.write_data_1_b ( write_data_1_b ),
	.write_data_1_a_enable ( write_data_1_a_enable ),
	.write_data_1_b_enable ( write_data_1_b_enable ),
	.read_data_1_a ( read_data_1_a ),
	.read_data_1_b ( read_data_1_b )
);



always_comb begin
	if (top_state == S_M2) begin
		address_0_a = M2_address_0_a;
		address_0_b = M2_address_0_b;
		write_data_0_a = M2_write_data_0_a;
		write_data_0_b = M2_write_data_0_b;
		write_data_0_a_enable = M2_write_data_0_a_enable;
		write_data_0_b_enable = M2_write_data_0_b_enable;
	end else begin
		address_0_a = 7'd0;
		address_0_b = 7'd0;
		write_data_0_a = 31'd0;
		write_data_0_b = 31'd0;
		write_data_0_a_enable = 1'b0;
		write_data_0_b_enable = 1'b0;
	end
	
end

// SRAM unit
SRAM_controller SRAM_unit (
	.Clock_50(CLOCK_50_I),
	.Resetn(~SWITCH_I[17]),
	.SRAM_address(SRAM_address),
	.SRAM_write_data(SRAM_write_data),
	.SRAM_we_n(SRAM_we_n),
	.SRAM_read_data(SRAM_read_data),		
	.SRAM_ready(SRAM_ready),
		
	// To the SRAM pins
	.SRAM_DATA_IO(SRAM_DATA_IO),
	.SRAM_ADDRESS_O(SRAM_ADDRESS_O[17:0]),
	.SRAM_UB_N_O(SRAM_UB_N_O),
	.SRAM_LB_N_O(SRAM_LB_N_O),
	.SRAM_WE_N_O(SRAM_WE_N_O),
	.SRAM_CE_N_O(SRAM_CE_N_O),
	.SRAM_OE_N_O(SRAM_OE_N_O)
);

assign SRAM_ADDRESS_O[19:18] = 2'b00;

//Multiplier 
assign multiplier1=operand1*operand2;
assign multiplier2=operand3*operand4;
assign multiplier3=operand5*operand6;


always @(posedge CLOCK_50_I or negedge resetn) begin
	if (~resetn) begin
		top_state <= S_IDLE;
		M1_State <= M1_IDLE;
		M1_done <= 1'b0;
		M1_SRAM_address <= 16'b0;
		M1_SRAM_write_data <= 16'b0;
		M1_write_en <= 1'b1;
		
		UART_rx_initialize <= 1'b0;
		UART_rx_enable <= 1'b0;
		UART_timer <= 26'd0;
		
		VGA_enable <= 1'b1;
		
		Ujm5<= 8'b0;
		Ujm3<= 8'b0;
		Ujm1<= 8'b0;
		Ujp1<= 8'b0;
		Ujp3<= 8'b0;
		Ujp5<= 8'b0;
		
		Vjm5<= 8'b0;
		Vjm3<= 8'b0;
		Vjm1<= 8'b0;
		Vjp1<= 8'b0;
		Vjp3<= 8'b0;
		Vjp5<= 8'b0;
		ubufindex <= 32'd0;
		operand1 <= 32'b0;
		operand2 <= 32'b0;
		operand3 <= 32'b0;
		operand4 <=  32'b0;
		operand5 <=  32'b0;
		operand6 <=  32'b0;

		Uprime <=  32'b0;
		Vprime <=  32'b0;
		rgbWriteCounter <= 32'd0;
		
		data_counter<= 18'd0;
		readCycle<=1'b1;
		LOcounter<=32'd0;
		R <=  32'd0;
		G <=  32'd0;
		B <=  32'd0;	
		R_buf <=  32'd0;
		G_buf <=  32'd0;
		B_buf <=  32'd0;	
		delayedGBOdd<=16'd0;	
		Y_Buf_Color_Buf <=  32'd0;
		UprimeEven <=  32'b0;
		UprimeOdd <=  32'b0;
		VprimeEven <=  32'b0;
		VprimeOdd <=  32'b0;
		first <=  1'b1;
		
		//M2_done <= 1'b0;	
		
	end else begin

		// By default the UART timer (used for timeout detection) is incremented
		// it will be synchronously reset to 0 under a few conditions (see below)
		UART_timer <= UART_timer + 26'd1;

		case (top_state)
		S_IDLE: begin
			VGA_enable <= 1'b1;

			if (~UART_RX_I) begin
				// Start bit on the UART line is detected
				UART_rx_initialize <= 1'b1;
				UART_timer <= 26'd0;
				VGA_enable <= 1'b0;
				top_state <= S_UART_RX;
			end
		end

		S_UART_RX: begin
			// The two signals below (UART_rx_initialize/enable)
			// are used by the UART to SRAM interface for 
			// synchronization purposes (no need to change)
			UART_rx_initialize <= 1'b0;
			UART_rx_enable <= 1'b0;
			if (UART_rx_initialize == 1'b1) 
				UART_rx_enable <= 1'b1;

			// UART timer resets itself every time two bytes have been received
			// by the UART receiver and a write in the external SRAM can be done
			if (~UART_SRAM_we_n) 
				UART_timer <= 26'd0;

			// Timeout for 1 sec on UART (detect if file transmission is finished)
			if (UART_timer == 26'd49999999) begin
				top_state <= S_M2;
				UART_timer <= 26'd0;
			end
		end
		//M1 implimentation begins here
		S_M1: begin
				case(M1_State)
				
				M1_IDLE: begin
					LOcounter<=32'd0;
					M1_SRAM_address <= ((data_counter)>>1) + U_offset;
					M1_State<=LI_0;
				
					
				end
				LI_0: begin
				
					M1_SRAM_address<= ((data_counter)>>1) + V_offset;
					M1_State<=LI_1;
				
					
				end
				
				LI_1: begin
				
					M1_SRAM_address<= ((data_counter)>>1) + U_offset + 18'd1;
					data_counter<=data_counter +18'd1;
					M1_State<=LI_2;
				
					
				end
				
				LI_2: begin
				
					M1_SRAM_address<= ((data_counter)>>1) + V_offset + 18'd1;
					ubufindex <= ubufindex +32'd2;
					U_buf<= SRAM_read_data;
					Ujm5<= SRAM_read_data[15:8];
					Ujm3<= SRAM_read_data[15:8];
					Ujm1<= SRAM_read_data[15:8];
					Ujp1<= SRAM_read_data[7:0];
					
					
					
					operand3<= 32'd132251;
					operand4<=(SRAM_read_data[15:8]-16'd128);
					
					operand5<= -32'd25624;
					operand6<=(SRAM_read_data[15:8]-16'd128);
					
					
					U_buf2 <= SRAM_read_data;
					
					M1_State<=LI_3;
				
					
				end
				LI_3: begin
				
					M1_SRAM_address<= data_counter-18'd1;
					
					V_buf2<= SRAM_read_data;
					Vjm5<= SRAM_read_data[15:8];
					Vjm3<= SRAM_read_data[15:8];
					Vjm1<= SRAM_read_data[15:8];
					Vjp1<= SRAM_read_data[7:0];
					
					
					
					operand1<= -32'd53284;
					operand2<=(SRAM_read_data[15:8]-16'd128);
					
					operand3<= 32'd104595;
					operand4<=(SRAM_read_data[15:8]-16'd128);
					
					multiplier2_buf<=(multiplier2);
					multiplier3_buf<=(multiplier3);
					
					//Uprime<=U_buf[15:8];
					
					
					//V_buf2 <= SRAM_read_data;
					
					
					M1_State<=LI_4;
				
					
				end
				LI_4: begin
				
					M1_SRAM_address<= data_counter;
					data_counter<=data_counter+18'd1;
					Ujp3<=SRAM_read_data[15:8];
					Ujp5<=SRAM_read_data[7:0];
					

					operand1<= 32'd21;
					operand2<=(Ujm5 + SRAM_read_data[7:0]);
					
					operand3<= 32'd52;
					operand4<=(Ujm3 + SRAM_read_data[15:8]);
					
					
					operand5<= 32'd159;
					operand6<=(Ujm1 + Ujp1);
					
					R_buf <= multiplier2;
					G_buf <= G_buf + multiplier3_buf + multiplier1;
					B_buf <= multiplier2_buf;
					
					U_buf <= U_buf2;
					U_buf2 <= SRAM_read_data;
					ubufindex <= ubufindex +32'd2;
					
					M1_State<=LI_5;
				
					
				end
				
				LI_5: begin
				

				
					multiplier1_buf<=(multiplier1>>8);
					multiplier2_buf<=multiplier2>>8;
					multiplier3_buf<=multiplier3>>8;
					
					
					operand1<= 32'd21;
					operand2<=(Vjm5 + SRAM_read_data[7:0]);
					
					operand3<= 32'd52;
					operand4<=(Vjm3 + SRAM_read_data[15:8]);
					
					
					operand5<= 32'd159;
					operand6<=(Vjm1 + Vjp1);
					
					//U_buf<= SRAM_read_data;
					Uprime<= ((multiplier1) - (multiplier2) + (multiplier3) + (32'd128))>>>8;
					
					
					Vjp3<=SRAM_read_data[15:8];
					Vjp5<=SRAM_read_data[7:0];
					
					V_buf <= V_buf2;
					V_buf2 <= SRAM_read_data;
					
					//Y<= SRAM_read_data;
					
					M1_State<=LI_6;
					
					j <= j + 32'b1;
				
					
				end
				LI_6: begin

					operand1<=32'd76284;
					operand2<={26'b0, SRAM_read_data[15:8]} -32'd16;
					
					//M1_SRAM_address<= 18'd146944;
					if (linecounter > 0) begin
						M1_write_en<=1'b0;
						M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
						rgbWriteCounter<= rgbWriteCounter + 32'd1;
						M1_SRAM_write_data <= delayedGBOdd;
					end
					
					operand3<= 32'd132251;
					operand4<=Uprime - 32'd128;
					
					operand5<=-32'd25624;
					operand6<=Uprime-32'd128;
					
					//Y_Buf_Color_Buf<= multiplier1[7:0];
					Y<= SRAM_read_data;
					
					Vprime<= ((multiplier1) - (multiplier2) + (multiplier3) + (32'd128))>>>8;

					
					M1_State<=LI_7;
				
					
				end
				
				LI_7: begin
					//tempOutputBuf1 = R_buf + multiplier1>>16;
					//tempOutputBuf2 = G_buf + multiplier1>>16;
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter<= rgbWriteCounter + 32'd1;
					M1_write_en<=1'b0;
					if (tempOutputBuf1[31]) begin
						M1_SRAM_write_data[15:8] <= 8'b0;
					end else begin
						if (|(tempOutputBuf1[30:24])) begin
							M1_SRAM_write_data[15:8] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[15:8] <= tempOutputBuf1[23:16];
						end
					end
					
					if (tempOutputBuf2[31]) begin
						M1_SRAM_write_data[7:0] <= 8'b0;
					end else begin
						if (|(tempOutputBuf2[30:24])) begin
							M1_SRAM_write_data[7:0] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[7:0] <= tempOutputBuf2[23:16];
						end
					end

					
					operand1<=-32'd53281;
					operand2<=Vprime -32'd128;
					
					operand3<= 32'd104595;
					operand4<=Vprime - 32'd128;
					
					operand5<=32'd76284;
					operand6<={26'd0, Y[7:0]} - 32'd16;
					
					multiplier1_buf<=multiplier1;
					multiplier2_buf<=multiplier2;
					multiplier3_buf<=multiplier3;
					//tempM1 = {multiplier1<<16};
			
					Y_buf<= SRAM_read_data;
					
					R_buf <= R_buf + multiplier1;
					G_buf <= G_buf + multiplier1;
					B_buf <= B_buf + multiplier1;
					
					//Y_Buf_Color_Buf<= multiplier3[7:0];
					//rgbWriteCounter <= rgbWriteCounter + 32'd1;
					M1_State<=LI_8;
				
					
				end
				LI_8: begin
				
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;
					
					//tempOutputBuf1 = B_buf;
					//tempOutputBuf2 = {16'b0, multiplier3[31:16]} + multiplier2_buf;
				
					M1_write_en<=1'b0;
					if (B_buf[31]) begin
						M1_SRAM_write_data[15:8] <= 8'b0;
					end else begin
						if (|(B_buf[30:24])) begin
							M1_SRAM_write_data[15:8] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[15:8] <= B_buf[23:16];
						end
					end
					
					if (tempOutputBuf4[31]) begin
						M1_SRAM_write_data[7:0] <= 8'b0;
					end else begin
						if (|(tempOutputBuf4[30:24])) begin
							M1_SRAM_write_data[7:0] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[7:0] <= tempOutputBuf4[23:16];
						end
					end
					

					
					//R <= (multiplier3<<16)[7:0] + multiplier2_buf[7:0];
					//G <= {16'b0, multiplier3[31:16]} - multiplier3_buf - {16'b0, multiplier1[31:16]};
					//B <= {16'b0, multiplier3[31:16]} + {16'b0,multiplier2[31:16]};
					
					G <= multiplier3 + multiplier3_buf + multiplier1;
					B <= multiplier3 + multiplier2_buf;
					
					Ujm5 <= Ujm3;
					Ujm3 <= Ujm1;
					Ujm1 <= Ujp1;
					Ujp1 <= Ujp3;
					Ujp3 <= Ujp5;
					
					Vjm5 <= Vjm3;
					Vjm3 <= Vjm1;
					Vjm1 <= Vjp1;
					Vjp1 <= Vjp3;
					Vjp3 <= Vjp5;
					
					M1_State<=LI_9;
					
				end
				LI_9: begin
					//M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					//rgbWriteCounter <= rgbWriteCounter + 32'd1;
					//M1_write_en<=1'b1;
					//M1_SRAM_write_data[15:8] <= G;
					//M1_SRAM_write_data[7:0] <= B;
					//M1_SRAM_address<= 18'd146944 + 18'd2;
					//tempOutputBuf1 = G;
					//tempOutputBuf2 = B;
				
					M1_write_en<=1'b0;
					if (G[31]) begin
						delayedGBOdd[15:8] <= 8'b0;
					end else begin
						if (|(G[30:24])) begin
							delayedGBOdd[15:8] <= 8'hFF;
						end else begin 
							delayedGBOdd[15:8] <= G[23:16];
						end
					end
					
					if (B[31]) begin
						delayedGBOdd[7:0] <= 8'b0;
					end else begin
						if (|(B[30:24])) begin
							delayedGBOdd[7:0] <= 8'hFF;
						end else begin 
							delayedGBOdd[7:0] <= B[23:16];
						end
					end
					
					operand1 <= 32'd159;
					operand2 <= Ujm1 + Ujp1;
					
					operand3 <= 32'd159;
					operand4 <= Vjm1 + Vjp1;
					
					operand5 <= 32'd132251;
					operand6 <= {26'd0, U_buf[7:0]} - 32'd128;
					
					//Uprime <= U_buf[7:0];
					//Vprime <= V_buf[7:0];
					
					UprimeEven <= {26'd0, U_buf[7:0]};
					VprimeEven <= {26'd0, V_buf[7:0]};

					data_counter<=data_counter +18'd1;
					j <= j + 32'b1;
					M1_State<=CC_10;
					//top_state <= S_IDLE;
					M1_SRAM_address<= ((data_counter)>>1) + U_offset + 18'd1;
					M1_write_en<=1'b1;
					
				end
				
				CC_10: begin

					M1_write_en<=1'b1;
					if (first)
						M1_SRAM_address<= ((data_counter)>>1) + V_offset + 18'd1;
					else
						M1_SRAM_address<= ((data_counter)>>1) + V_offset + 18'd1;


					operand1 <= 32'd52;
					operand2 <= {26'd0,Vjm3} + {26'd0,Vjp3};
					
					operand3 <= 32'd52;
					operand4 <= {26'd0,Ujm3} + {26'd0,Ujp3};
					
					operand5 <= -32'd25624;
					operand6 <= UprimeEven - 32'd128;

					B_buf <= multiplier3;
					
					//Uprime <= U_buf[7:0];
	
					multiplier1_buf<=multiplier1;
					multiplier2_buf<=multiplier2;
					multiplier3_buf<=multiplier3;
	
					M1_State<=CC_11;
					
				end
				
				CC_11: begin
				
					//M1_SRAM_address<= data_counter;
					if (first) begin
						M1_SRAM_address<= data_counter-18'd1;
						first <= 1'b0;
					end else begin
						M1_SRAM_address<= data_counter;
						data_counter<=data_counter+18'd1;
					end
					
					operand1<=-32'd53281;
					operand2<=VprimeEven -32'd128;
					
					operand3<=32'd76284;
					operand4<=-32'd16;
					
					operand5<=32'd104595;
					operand6<=VprimeEven - 8'd128;
					
					G_buf <= 32'd0 + multiplier3;
					
					//Y in Y_buf
					Y <= Y_buf;
					
					UprimeOdd <= multiplier1_buf - multiplier2;
					VprimeOdd <= multiplier2_buf - multiplier1;
					M1_State<=CC_12;
					
				end
				
				CC_12: begin

				
					//M1_SRAM_address<= data_counter;
					
					//U_buf <= U_buf2;
					//U_buf2 <= SRAM_read_data;
					
					operand1<=32'd21;
					if (readCycle) begin
						U_buf <= U_buf2;
						U_buf2 <= SRAM_read_data;
						ubufindex <= ubufindex +32'd2;
						operand2<={26'd0, SRAM_read_data[15:8]} + {26'd0, Ujm5};// operand 2
						Ujp5 <= SRAM_read_data[15:8];
					end else begin 
						operand2<={26'd0, U_buf2[7:0]} + {26'd0, Ujm5};
						Ujp5 <= U_buf2[7:0];
					end
					
					operand3<=32'd76284;
					operand4<={26'd0, Y[7:0]};
					
					operand5<=32'd76284;
					operand6<={26'd0, Y[15:8]}; 
					
					multiplier2_Y_buf<=multiplier2;
					
					
					
					R_buf <= multiplier3;
					G_buf <= G_buf + multiplier1;
					//B_buf<=multiplier3_buf;
					
					j <= j + 32'b1;
					M1_State<=CC_13;
					
				end
				
				CC_13: begin
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;
					
					M1_SRAM_write_data <= delayedGBOdd;
					M1_write_en<=1'b0;	
				
					if (readCycle) begin
						V_buf <= V_buf2;
						V_buf2 <= SRAM_read_data;
						operand6<={26'd0, SRAM_read_data[15:8]} + {26'd0, Vjm5};
						Vjp5 <= SRAM_read_data[15:8];
					end else begin 
						operand6<={26'd0, V_buf2[7:0]} + {26'd0, Vjm5};
						Vjp5 <= V_buf2[7:0];
					end
					

					operand1<=32'd132251;
					operand2<=((UprimeOdd + 32'd128 + multiplier1)>>>8) - 32'd128;
					
					operand3<=-32'd25624;
					operand4<=((UprimeOdd + 32'd128 + multiplier1)>>>8) - 32'd128;
					
					operand5<=32'd21;
					//operand6<={26'd0, SRAM_read_data[15:8]} + {26'd0, Vjm5};
					
					R_buf <= R_buf + (multiplier3 + multiplier2_Y_buf);
					G_buf <= G_buf + (multiplier3 + multiplier2_Y_buf);
					B_buf <= B_buf + (multiplier3 + multiplier2_Y_buf);
					
					Y_Buf_Color_Buf <= multiplier2 + multiplier2_Y_buf;
					
					//Vjp5 <= SRAM_read_data[15:8];
					
					UprimeOdd <= ((UprimeOdd + 32'd128 + multiplier1)>>>8);
					M1_State<=CC_14;
					
				end
				
				CC_14: begin
					M1_write_en<=1'b0;
					
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;

					
					if (R_buf[31]) begin
						M1_SRAM_write_data[15:8] <= 8'b0;
					end else begin
						if (|(R_buf[30:24])) begin
							M1_SRAM_write_data[15:8] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[15:8] <= R_buf[23:16];
						end
					end
					
					if (G_buf[31]) begin
						M1_SRAM_write_data[7:0] <= 8'b0;
					end else begin
						if (|(G_buf[30:24])) begin
							M1_SRAM_write_data[7:0] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[7:0] <= G_buf[23:16];
						end
					end
										
					operand1<=-32'd53281;
					operand2<=((VprimeOdd + 32'd128 + multiplier3)>>>8) - 32'd128;
					
					operand3<=32'd104595;
					operand4<=((VprimeOdd + 32'd128 + multiplier3)>>>8) - 32'd128;
					
					multiplier1_buf<=multiplier1;
					multiplier2_buf<=multiplier2;
					multiplier3_buf<=multiplier3;
					
					R<= Y_Buf_Color_Buf;
					G<= Y_Buf_Color_Buf + multiplier2;
					B<= Y_Buf_Color_Buf + multiplier1;
					
					VprimeOdd <= ((VprimeOdd + 32'd128 + multiplier3)>>>8);
					//operand5<=32'd21;
					//operand6<={26'd0, SRAM_read_data[15:8]} + {26'd0, Vjm5};
					Ujm5 <= Ujm3;
					Ujm3 <= Ujm1;
					Ujm1 <= Ujp1;
					Ujp1 <= Ujp3;
					Ujp3 <= Ujp5;
					//Ujp5 <= 8'b0; //HERE
					Y_buf <= SRAM_read_data;	
					M1_State<=CC_15;
					
				end
				
				CC_15: begin
				
				
										
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;
				
					if (B_buf[31]) begin
						M1_SRAM_write_data[15:8] <= 8'b0;
					end else begin
						if (|(B_buf[30:24])) begin
							M1_SRAM_write_data[15:8] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[15:8] <= B_buf[23:16];
						end
					end
					
					if (cc15OutputBuf[31]) begin
						M1_SRAM_write_data[7:0] <= 8'b0;
					end else begin
						if (|(cc15OutputBuf[30:24])) begin
							M1_SRAM_write_data[7:0] <= 8'hFF;
						end else begin 
							//M1_SRAM_write_data[7:0]  <= cc15OutputBuf>>>16;
							M1_SRAM_write_data[7:0]<= cc15OutputBuf[23:16];
						end
					end
					
					R <= R + multiplier2;
					G <= G + multiplier1;
				
					Vjm5 <= Vjm3;
					Vjm3 <= Vjm1;
					Vjm1 <= Vjp1;
					Vjp1 <= Vjp3;
					Vjp3 <= Vjp5;
					//Vjp5 <= 8'b0;
					//Vjp5 <= V_buf2[7:0];//HERE
					
					M1_State<=CC_16;
					
				end
				
				CC_16: begin
					//M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					//rgbWriteCounter <= rgbWriteCounter + 32'd1;
					M1_SRAM_address<= ((data_counter)>>1) + U_offset + 18'd1;
					M1_write_en<=1'b1;
					
					//data_counter<=data_counter +18'd1;
					j<=j+32'd1;
				
					if (G[31]) begin
						delayedGBOdd[15:8] <= 8'b0;
					end else begin
						if (|(G[30:24])) begin
							delayedGBOdd[15:8] <= 8'hFF;
						end else begin 
							delayedGBOdd[15:8]  <= G[23:16];
							//delayedGBOdd[15:8] <= G>>>16;
						end
					end
					
					if (B[31]) begin
						delayedGBOdd[7:0] <= 8'b0;
					end else begin
						if (|(B[30:24])) begin
							delayedGBOdd[7:0] <= 8'hFF;
						end else begin 
							//M1_SRAM_write_data[7:0] <= B>>>16;
							delayedGBOdd[7:0] <= B[23:16];
						end
					end
					
					operand1 <= 32'd159;
					operand2 <= {26'd0,Ujm1} + {26'd0,Ujp1};
					
					operand3 <= 32'd159;
					operand4 <= {26'd0,Vjm1} + {26'd0,Vjp1};
					
					operand5 <= 32'd132251;
					operand6 <= readCycle ? {26'd0, U_buf[15:8]} - 32'd128 : {26'd0, U_buf[7:0]} - 32'd128;
					
					UprimeEven <= readCycle ? {26'd0, U_buf[15:8]} : {26'd0, U_buf[7:0]};
					VprimeEven <= readCycle ? {26'd0, V_buf[15:8]} : {26'd0, V_buf[7:0]};
					
					readCycle <= ~readCycle;

					if(j==311) begin
						M1_SRAM_address<=18'd0;
						LOcounter<= 32'd0;
						M1_State<=LO_17;
						//debug<=1'b0;
					end else begin
						M1_State<=CC_10;
					end
					
				end
				
				LO_17: begin

					M1_write_en<=1'b1;

					operand1 <= 32'd52;
					operand2 <= {26'd0,Vjm3} + {26'd0,Vjp3};
					
					operand3 <= 32'd52;
					operand4 <= {26'd0,Ujm3} + {26'd0,Ujp3};
					
					operand5 <= -32'd25624;
					operand6 <= UprimeEven - 32'd128;

					B_buf <= multiplier3;
	
					multiplier1_buf<=multiplier1;
					multiplier2_buf<=multiplier2;
					multiplier3_buf<=multiplier3;
	
					M1_State<=LO_18;
					
				end
				
				LO_18: begin
				

					M1_SRAM_address<= data_counter;
					data_counter<=data_counter+18'd1;

					
					operand1<=-32'd53281;
					operand2<=VprimeEven -32'd128;
					
					operand3<=32'd132251;
					operand4<=VprimeEven - 32'd128;
					
					operand5<=32'd104595;
					operand6<=VprimeEven - 8'd128;
					
					G_buf <= 32'd0 + multiplier3;
					
					Y <= Y_buf;
					
					UprimeOdd <= multiplier1_buf - multiplier2;
					VprimeOdd <= multiplier2_buf - multiplier1;
					M1_State<=LO_19;
					
				end
				
				LO_19: begin

					operand1<=32'd21;
					if (LOcounter == 32'd0) begin
						operand2<={26'd0, U_buf2[7:0]} + {26'd0, Ujm5};// operand 2
						Ujp5 <= U_buf2[7:0];
					end else begin
						operand2<={26'd0, Ujp5} + {26'd0, Ujm5};// operand 2
					end
					
					operand3<=32'd76284;
					operand4<={26'd0, Y[7:0]} - 32'd16;
					
					operand5<=32'd76284;
					operand6<={26'd0, Y[15:8]} - 32'd16; 
					
					R_buf <= multiplier3;
					G_buf <= G_buf + multiplier1;
					
					j <= j + 32'b1;
					M1_State<=LO_20;
					
				end
				
				LO_20: begin
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;
					
					M1_SRAM_write_data <= delayedGBOdd;
					M1_write_en<=1'b0;	
				
					if (LOcounter == 32'd0) begin
						operand6<={26'd0, V_buf2[7:0]} + {26'd0, Vjm5};// operand 2
						Vjp5 <= V_buf2[7:0];
					end else begin
						operand6<={26'd0, Vjp5} + {26'd0, Vjm5};// operand 2
					end
					

					operand1<=32'd132251;
					operand2<=((UprimeOdd + 32'd128 + multiplier1)>>>8) - 32'd128;
					
					operand3<=-32'd25624;
					operand4<=((UprimeOdd + 32'd128 + multiplier1)>>>8) - 32'd128;
					
					operand5<=32'd21;

					
					R_buf <= R_buf + multiplier3;
					G_buf <= G_buf + multiplier3;
					B_buf <= B_buf + multiplier3;
					
					Y_Buf_Color_Buf <= multiplier2;
					
					
					UprimeOdd <= ((UprimeOdd + 32'd128 + multiplier1)>>>8);
					M1_State<=LO_21;
					
				end
				
				LO_21: begin
					M1_write_en<=1'b0;
					
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;

					
					if (R_buf[31]) begin
						M1_SRAM_write_data[15:8] <= 8'b0;
					end else begin
						if (|(R_buf[30:24])) begin
							M1_SRAM_write_data[15:8] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[15:8] <= R_buf[23:16];
						end
					end
					
					if (G_buf[31]) begin
						M1_SRAM_write_data[7:0] <= 8'b0;
					end else begin
						if (|(G_buf[30:24])) begin
							M1_SRAM_write_data[7:0] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[7:0] <= G_buf[23:16];
						end
					end
										
					operand1<=-32'd53281;
					operand2<=((VprimeOdd + 32'd128 + multiplier3)>>>8) - 32'd128;
					
					operand3<=32'd104595;
					operand4<=((VprimeOdd + 32'd128 + multiplier3)>>>8) - 32'd128;
					
					multiplier1_buf<=multiplier1;
					multiplier2_buf<=multiplier2;
					multiplier3_buf<=multiplier3;
					
					R<= Y_Buf_Color_Buf;
					G<= Y_Buf_Color_Buf + multiplier2;
					B<= Y_Buf_Color_Buf + multiplier1;
					
					VprimeOdd <= ((VprimeOdd + 32'd128 + multiplier3)>>>8);

					Ujm5 <= Ujm3;
					Ujm3 <= Ujm1;
					Ujm1 <= Ujp1;
					Ujp1 <= Ujp3;
					Ujp3 <= Ujp5;

					Y_buf <= SRAM_read_data;	
					M1_State<=LO_22;
					
				end
				
				LO_22: begin
										
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					rgbWriteCounter <= rgbWriteCounter + 32'd1;
				
					if (B_buf[31]) begin
						M1_SRAM_write_data[15:8] <= 8'b0;
					end else begin
						if (|(B_buf[30:24])) begin
							M1_SRAM_write_data[15:8] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[15:8] <= B_buf[23:16];
						end
					end
					
					if (cc15OutputBuf[31]) begin
						M1_SRAM_write_data[7:0] <= 8'b0;
					end else begin
						if (|(cc15OutputBuf[30:24])) begin
							M1_SRAM_write_data[7:0] <= 8'hFF;
						end else begin 
							M1_SRAM_write_data[7:0]<= cc15OutputBuf[23:16];
						end
					end
					
					R <= R + multiplier2;
					G <= G + multiplier1;
				
					Vjm5 <= Vjm3;
					Vjm3 <= Vjm1;
					Vjm1 <= Vjp1;
					Vjp1 <= Vjp3;
					Vjp3 <= Vjp5;

					
					M1_State<=LO_23;
					
				end
				
				LO_23: begin

					M1_write_en<=1'b1;
					j<=j+32'd1;
				
					if (G[31]) begin
						delayedGBOdd[15:8] <= 8'b0;
					end else begin
						if (|(G[30:24])) begin
							delayedGBOdd[15:8] <= 8'hFF;
						end else begin 
							delayedGBOdd[15:8]  <= G[23:16];
						end
					end
					
					if (B[31]) begin
						delayedGBOdd[7:0] <= 8'b0;
					end else begin
						if (|(B[30:24])) begin
							delayedGBOdd[7:0] <= 8'hFF;
						end else begin 
							delayedGBOdd[7:0] <= B[23:16];
						end
					end
					
					readCycle <= 1'b0;
					
					operand1 <= 32'd159;
					operand2 <= {26'd0,Ujm1} + {26'd0,Ujp1};
					
					operand3 <= 32'd159;
					operand4 <= {26'd0,Vjm1} + {26'd0,Vjp1};
					
					operand5 <= 32'd132251;
					
					if (LOcounter == 32'd0) begin
						operand6 <= {26'd0, U_buf[7:0]} - 32'd128; 
						UprimeEven <= {26'd0, U_buf[7:0]};
						
						VprimeEven <= {26'd0, V_buf[7:0]};
					end else if (LOcounter == 32'd1) begin
						operand6 <= {26'd0, U_buf2[15:8]} - 32'd128; 
						UprimeEven <= {26'd0, U_buf2[15:8]};
						
						VprimeEven <= {26'd0, V_buf2[15:8]};
					end else if (LOcounter == 32'd2) begin
						operand6 <= {26'd0, U_buf2[7:0]} - 32'd128; 
						UprimeEven <= {26'd0, U_buf2[7:0]};
						
						VprimeEven <= {26'd0, V_buf2[7:0]};
					end 
					LOcounter <= LOcounter + 32'd1;
					

					if(LOcounter == 32'd3) begin
						if (linecounter == 32'd239) begin
							//top_state <= S_IDLE;
							M1_State<= LO_Final1;
						end else begin
							M1_State<= M1_IDLE;
							data_counter <= data_counter - 18'd1;
							readCycle <= 1'b1;
							j<= 32'b0;
							linecounter<=linecounter + 32'd1;
							LOcounter<= 32'd0;
							Ujm5<= 8'b0;
							Ujm3<= 8'b0;
							Ujm1<= 8'b0;
							Ujp1<= 8'b0;
							Ujp3<= 8'b0;
							Ujp5<= 8'b0;
							
							Vjm5<= 8'b0;
							Vjm3<= 8'b0;
							Vjm1<= 8'b0;
							Vjp1<= 8'b0;
							Vjp3<= 8'b0;
							Vjp5<= 8'b0;
							operand1 <= 32'b0;
							operand2 <= 32'b0;
							operand3 <= 32'b0;
							operand4 <=  32'b0;
							operand5 <=  32'b0;
							operand6 <=  32'b0;
							Uprime <=  32'b0;
							Vprime <=  32'b0;
							Y <=  16'b0;
							Y_buf<=  16'b0;
							U_buf<=  16'b0;
							U_buf<=  16'b0;
							V_buf<=  16'b0;
							V_buf2<=  16'b0;
							readCycle<=1'b1;
							R <=  32'd0;
							G <=  32'd0;
							B <=  32'd0;	
							R_buf <=  32'd0;
							G_buf <=  32'd0;
							B_buf <=  32'd0;	
							Y_Buf_Color_Buf <=  32'd0;
							UprimeEven <=  32'b0;
							UprimeOdd <=  32'b0;
							VprimeEven <=  32'b0;
							VprimeOdd <=  32'b0;
							first <=  1'b1;
						end
					end else begin
						M1_State<=LO_17;
					end
				
				end

				LO_Final1: begin
					M1_SRAM_address<= 18'd146944 + rgbWriteCounter[17:0];
					M1_SRAM_write_data <= delayedGBOdd;
					M1_write_en<=1'b0;
					M1_State<=LO_Final2;
				end
				LO_Final2: begin
					M1_State<=LO_Final3;
					M1_write_en<=1'b1;
				end
				LO_Final3: begin
					top_state <= S_IDLE;
				end
				
				
				
		default: M1_State<= M1_IDLE;
		endcase
		end
		S_M2: begin
			M2_enable <= 1'b1;
			if(M2_done) begin 
				top_state <= S_M1; 
				M2_enable <= 1'b0;
			end
		end

		default: top_state <= S_IDLE;

		endcase
	end
end

// for this design we assume that the RGB data starts at location 0 in the external SRAM
// if the memory layout is different, this value should be adjusted 
// to match the starting address of the raw RGB data segment
assign VGA_base_address = 18'd146944;

// Give access to SRAM for UART and VGA at appropriate time
always_comb begin
	if(top_state==S_UART_RX) begin
		SRAM_address = UART_SRAM_address;
		SRAM_write_data=UART_SRAM_write_data;
		SRAM_we_n = UART_SRAM_we_n;
	end else if(top_state==S_IDLE) begin
		SRAM_address = VGA_SRAM_address;
		SRAM_write_data=16'd0;
		SRAM_we_n = 1'b1;
		
	end else if (top_state==S_M1) begin
		SRAM_address = M1_SRAM_address;
		SRAM_write_data=M1_SRAM_write_data;
		SRAM_we_n = M1_write_en;
	end else if (top_state==S_M2) begin
		SRAM_address = M2_SRAM_address;
		SRAM_write_data= M2_SRAM_write_data;
		SRAM_we_n = M2_SRAM_we_n;
	end else begin
	//CHANGE THESE
		SRAM_address = VGA_SRAM_address;
		SRAM_write_data=16'd0;
		SRAM_we_n = 1'b1;
	
	end

end

//assign SRAM_address = (top_state == S_UART_RX) ? UART_SRAM_address : VGA_SRAM_address;
//
//assign SRAM_write_data = (top_state == S_UART_RX) ? UART_SRAM_write_data : 16'd0;
//
//assign SRAM_we_n = (top_state == S_UART_RX) ? UART_SRAM_we_n : 1'b1;

// 7 segment displays
convert_hex_to_seven_segment unit7 (
	.hex_value(SRAM_read_data[15:12]), 
	.converted_value(value_7_segment[7])
);

convert_hex_to_seven_segment unit6 (
	.hex_value(SRAM_read_data[11:8]), 
	.converted_value(value_7_segment[6])
);

convert_hex_to_seven_segment unit5 (
	.hex_value(SRAM_read_data[7:4]), 
	.converted_value(value_7_segment[5])
);

convert_hex_to_seven_segment unit4 (
	.hex_value(SRAM_read_data[3:0]), 
	.converted_value(value_7_segment[4])
);

convert_hex_to_seven_segment unit3 (
	.hex_value({2'b00, SRAM_address[17:16]}), 
	.converted_value(value_7_segment[3])
);

convert_hex_to_seven_segment unit2 (
	.hex_value(SRAM_address[15:12]), 
	.converted_value(value_7_segment[2])
);

convert_hex_to_seven_segment unit1 (
	.hex_value(SRAM_address[11:8]), 
	.converted_value(value_7_segment[1])
);

convert_hex_to_seven_segment unit0 (
	.hex_value(SRAM_address[7:4]), 
	.converted_value(value_7_segment[0])
);

assign   
   SEVEN_SEGMENT_N_O[0] = value_7_segment[0],
   SEVEN_SEGMENT_N_O[1] = value_7_segment[1],
   SEVEN_SEGMENT_N_O[2] = value_7_segment[2],
   SEVEN_SEGMENT_N_O[3] = value_7_segment[3],
   SEVEN_SEGMENT_N_O[4] = value_7_segment[4],
   SEVEN_SEGMENT_N_O[5] = value_7_segment[5],
   SEVEN_SEGMENT_N_O[6] = value_7_segment[6],
   SEVEN_SEGMENT_N_O[7] = value_7_segment[7];

assign LED_GREEN_O = {resetn, VGA_enable, ~SRAM_we_n, Frame_error, UART_rx_initialize, PB_pushed};

endmodule
