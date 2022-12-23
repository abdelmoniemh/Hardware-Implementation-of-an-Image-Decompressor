`include "define_state.h"

module Milestone2 (
		/////// board clocks                      ////////////
		input logic Clock,                   // 50 MHz clock
		input logic Resetn,
		input logic M2_enable,
		input logic[15:0] SRAM_read_data,

		output logic [6:0] address_0_a,
		output logic [6:0] address_0_b,
		output logic [31:0] write_data_0_a,
		output logic [31:0] write_data_0_b,
		output logic write_data_0_a_enable,
		output logic write_data_0_b_enable,
		input logic [31:0] read_data_0_a,
		input logic [31:0] read_data_0_b,
		
		output logic [6:0] address_1_a,
		output logic [6:0] address_1_b,
		output logic [31:0] write_data_1_a,
		output logic [31:0] write_data_1_b,
		output logic write_data_1_a_enable,
		output logic write_data_1_b_enable,
		input logic [31:0] read_data_1_a,
		input logic [31:0] read_data_1_b,

		output logic [17:0]	SRAM_address,
		output logic [15:0]	SRAM_write_data,
		output logic SRAM_we_n,
		output logic M2_done                    // UART transmit signal
);

	//assign SRAM_address = 18'd0;

readSprime_States fetchSprime;
M2_States M2_State;
computeT_States computeTState;

logic [6:0] F_address_0_a = 7'd0;
logic [6:0] F_address_0_b = 7'd0;
logic [31:0] F_write_data_0_a = 31'd0;
logic [31:0] F_write_data_0_b = 31'd0;
logic F_write_data_0_a_enable = 1'b0;
logic F_write_data_0_b_enable = 1'b0;
logic [31:0] F_read_data_0_a = 31'd0;
logic [31:0] F_read_data_0_b = 31'd0;
logic signed [31:0] T_read_data_0_b;
assign T_read_data_0_b = $signed(read_data_0_b);


logic [7:0] rowBlockIndex = 8'd0;
logic [7:0] columnBlockIndex= 8'd0;
logic [7:0] rowIndex= 8'd0;
logic [7:0] columnIndex= 8'd0;

logic increment = 1'b0;
logic incrementColumn = 1'b0;
logic incrementRow = 1'b0;
logic doubleIncrementRow = 1'b0;
logic decrementColumn = 1'b0;
logic decrementRow = 1'b0;

//logic [17:0] SRAM_read_offset = 18'd76800;
logic computeY = 1'b1;
logic computeU = 1'b0;
logic computeV = 1'b0;
logic[6:0] columnBlockIndexBound = 7'd39;
logic [17:0] F_SRAM_address;
always_comb begin
	if (computeV) begin
		columnBlockIndexBound = 7'd19;
		F_SRAM_address = {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<7} + {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<5} + {7'd0 ,columnBlockIndex, 3'd0} + {11'd0, columnIndex} + 18'd192000;
	end else if (computeU) begin
		columnBlockIndexBound = 7'd19;
		F_SRAM_address = {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<7} + {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<5} + {7'd0 ,columnBlockIndex, 3'd0} + {11'd0, columnIndex} + 18'd153600;
	end else begin
		columnBlockIndexBound = 7'd39;
		F_SRAM_address = {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<8} + {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<6} + {7'd0 ,columnBlockIndex, 3'd0} + {11'd0, columnIndex} + 18'd76800; //
	end
end



//assign F_SRAM_address = {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<8} + {10'd0, ({7'd0 ,rowBlockIndex, 3'd0} + {11'd0, rowIndex})<<<6} + {7'd0 ,columnBlockIndex, 3'd0} + {11'd0, columnIndex} + 18'd76800; //
//assign F_SRAM_address = {{rowBlockIndex, 3'd0} + {3'd0, rowIndex}, 8'd0} + {1'd0, {rowBlockIndex, 3'd0} + {3'd0, rowIndex}, 6'd0} + {7'd0 ,columnBlockIndex, 3'd0} + {10'd0, columnIndex} + 18'd76800;

logic F_SRAM_we_n;

logic fetchSprimeEnable = 1'b0;
logic fetchSprimeDone = 1'b0;
logic signed [15:0] SprimeBuffer = 16'd0;
logic[6:0] writeSprimeCounter = 7'd0;
logic firstSprimeRun = 1'b1;
logic computeTDone = 1'b0;
logic computeTEnable = 1'b0;
logic[6:0] Sprime_Offset = 7'd0;



always_ff @(posedge Clock or negedge Resetn) begin : FetchS
	if(~Resetn) begin
		SprimeBuffer <= 16'd0;
		firstSprimeRun <= 1'd1;
		rowIndex = 8'd0;
		columnIndex = 8'd0;
		rowBlockIndex = 8'd0;
		columnBlockIndex = 8'd0;
		fetchSprime <= F_IDLE;
	end else begin
		if (M2_enable) begin
			if(~M2_done) begin
					case(fetchSprime)
						F_IDLE: begin
							if (fetchSprimeEnable == 1'b1) begin
								fetchSprime <= F_IDLE2;		
							end
							fetchSprimeDone <= 1'b0;
						end
						
						F_IDLE2: begin
							if (fetchSprimeEnable == 1'b1) begin
								fetchSprime <= F_IDLE3;
							end else begin
								fetchSprime <= F_IDLE;
							end
						end
						
						F_IDLE3: begin
							if (fetchSprimeEnable == 1'b1) begin
								fetchSprime <= F_LI_0;
								SprimeBuffer <= 16'd0;
								firstSprimeRun <= 1'd1;
								writeSprimeCounter <= 7'd0;
							end else begin
								fetchSprime <= F_IDLE;
							end
						end
						
						F_LI_0: begin
							if (rowBlockIndex == 7'd30)
								rowBlockIndex <= 7'd0;
							F_SRAM_we_n <= 1'b1;
							writeSprimeCounter <= 7'd0;
							fetchSprime <= F_LI_1;
						end
						
						F_LI_1: begin
							rowIndex <= rowIndex + 7'd1;
							fetchSprime <= F_LI_2;
						end
						
						F_LI_2: begin
							rowIndex <= rowIndex - 7'd1;
							columnIndex <= columnIndex + 7'd1;
							fetchSprime <= F_CC_3;
						end
						
						F_CC_3: begin

							rowIndex <= rowIndex + 7'd1;	
							firstSprimeRun <= 1'b0;
							
							F_write_data_0_a_enable <= 1'b0;
								
							SprimeBuffer <= $signed(SRAM_read_data);
							fetchSprime <= F_CC_4;
						end
						F_CC_4: begin
							if (~(columnIndex == 7'd7)) begin
								rowIndex <= rowIndex - 7'd1;
								columnIndex <= columnIndex + 7'd1;
							end else begin
								columnIndex <= 7'd0;	
								rowIndex <= rowIndex + 7'd1;
							end
							
							F_address_0_a <= writeSprimeCounter + Sprime_Offset;
							writeSprimeCounter <= writeSprimeCounter + 7'd1;
							
							F_write_data_0_a_enable <= 1'b1;
							F_write_data_0_a <= {SprimeBuffer, $signed(SRAM_read_data)};
							
							if (rowIndex == 8'd7 && columnIndex == 8'd7) begin
								fetchSprime <= F_LO_5;
							end else begin
								fetchSprime <= F_CC_3;
							end
						end
						
						F_LO_5: begin
							SprimeBuffer <= SRAM_read_data;
							fetchSprime <= F_LO_6;
						end
						F_LO_6: begin
							F_address_0_a <= writeSprimeCounter + Sprime_Offset;
							writeSprimeCounter <= writeSprimeCounter + 7'd1;
							F_write_data_0_a_enable <= 1'b1;
							F_write_data_0_a <= {SprimeBuffer, SRAM_read_data};
							fetchSprime <= F_LO_7;
						end
						F_LO_7: begin
							columnIndex<=7'd0;
							rowIndex<=7'd0;
							if (columnBlockIndex == columnBlockIndexBound) begin
								columnBlockIndex<= 7'd0;
								rowBlockIndex <= rowBlockIndex+7'd1;
							end else begin
								columnBlockIndex <= columnBlockIndex + 7'd1;
							end
							F_write_data_0_a_enable <= 1'b0;
							fetchSprimeDone <= 1'b1;
							fetchSprime <= F_IDLE;
						end
						
					endcase
			end
		end
	end
end



int multiplier1;
int multiplier2;
int T_operand1 = 32'b0;
int T_operand2 = 32'b0;
int T_operand3 = 32'b0;
int T_operand4 = 32'b0;
int S_operand1 = 32'b0;
int S_operand2 = 32'b0;
int S_operand3 = 32'b0;
int S_operand4 = 32'b0;
assign multiplier1= ((computeTEnable == 1'b1) ?  T_operand1: S_operand1)*((computeTEnable == 1'b1) ?  T_operand2: S_operand2);
assign multiplier2= ((computeTEnable == 1'b1) ?  T_operand3: S_operand3)*((computeTEnable == 1'b1) ?  T_operand4: S_operand4);





//computeT_States computeTState;
logic	[7:0] computeTWriteAddress = 7'b0;
logic [6:0] c_offset = 7'd64;
logic [6:0] c_column_counter = 7'd0;
logic [6:0] sPrimeAddress = 7'd0;
logic [6:0] sPrimeRowBlockCounter = 7'd0;

int t_buf = 32'd0;
int t_buf2 = 32'd0;
int computeTWriteBuffer = 32'd0;
logic bufferCycle = 1'd1;

int writeCycleOutput = 32'd0;
int bufferCycleOutput0 = 32'd0;

int computeTOperand1;
assign computeTOperand1 = $signed(read_data_0_a[31:16]);
int computeTOperand2;
assign computeTOperand2 = $signed(read_data_0_a[15:0]);
logic firstComputeTRun = 1'b1;

logic [6:0] T_address_0_a = 7'd0;
logic [6:0] T_address_0_b = 7'd0;
logic [31:0] T_write_data_0_a = 31'd0;
logic [31:0] T_write_data_0_b = 31'd0;
logic T_write_data_0_a_enable = 1'd0;
logic T_write_data_0_b_enable = 1'd0;

logic [6:0] T_address_1_a = 7'd0;
logic [6:0] T_address_1_b = 7'd0;
logic [31:0] T_write_data_1_a = 31'd0;
logic [31:0] T_write_data_1_b = 31'd0;
logic T_write_data_1_a_enable = 1'd0;
logic T_write_data_1_b_enable = 1'd0;



logic [6:0] T_rowIndex= 7'd0;
logic [6:0] T_columnIndex = 7'd0;

logic T_increment = 1'b0;
logic T_incrementColumn = 1'b0;
logic T_incrementRow = 1'b0;
logic T_doubleIncrementRow = 1'b0;
logic T_decrementColumn = 1'b0;
logic T_decrementRow = 1'b0;

logic [6:0] T_write_address;
assign T_write_address = T_rowIndex<<2 + T_columnIndex;


always @(T_incrementColumn or T_incrementRow  or T_increment or T_decrementRow or T_decrementColumn or T_doubleIncrementRow or Resetn) begin : WriteTAddressGenerator
	if (~Resetn) begin
		T_rowIndex = 7'd0;
		T_columnIndex = 7'd0;
	end else begin
		if (T_increment) begin
			if (T_columnIndex == 7'd7) begin
				if (T_rowIndex == 7'd7) begin
					T_columnIndex = 7'd0;
					T_rowIndex = 7'd0;
				end else begin
					T_columnIndex = 7'd0;
					T_rowIndex = T_rowIndex + 7'd1;
				end			
			end else begin
				T_columnIndex = T_columnIndex + 7'd1;
			end
		end
		if (T_incrementRow) begin 
			T_rowIndex = T_rowIndex + 7'd1;
		end else if (T_decrementRow) begin 
			T_rowIndex = T_rowIndex - 7'd1;
		end 
		if (T_incrementColumn) begin
			T_columnIndex = T_columnIndex + 7'd1;
		end else if (T_decrementColumn) begin
			T_columnIndex = T_columnIndex - 7'd1;
		end
		if (T_doubleIncrementRow)begin
			T_rowIndex = T_rowIndex + 7'd1;
		end
	end
end



always_ff @(posedge Clock or negedge Resetn) begin : ComputeT
	if(~Resetn) begin
		bufferCycle = 1'd1;
		computeTDone <= 1'b0;
		firstComputeTRun <= 1'b1;
		computeTState <= T_IDLE;
	end else begin
		if (M2_enable) begin
			if(~M2_done) begin
					case(computeTState)
						T_IDLE: begin
							if (computeTEnable == 1'b1) begin
								computeTState <= T_IDLE2;
							end
							computeTDone <= 1'b0;
						end
						
						T_IDLE2: begin
							if (computeTEnable == 1'b1) begin
								computeTState <= T_IDLE3;
							end else begin
								computeTState <= T_IDLE;
							end
						end
						
						T_IDLE3: begin
							if (computeTEnable == 1'b1) begin
								computeTState <= T_LI_0;
								t_buf <= 32'd0;
								t_buf2 <= 32'd0;
								computeTWriteAddress = 7'b0;
								c_offset = 7'd64;
								c_column_counter = 7'd0;
								sPrimeAddress = 7'd0;
								sPrimeRowBlockCounter = 7'd0;
								bufferCycle = 1'd1;
								firstComputeTRun <= 1'b1;
							end else begin
								computeTState <= T_IDLE;
							end
						end
						
						T_LI_0: begin
							
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							T_address_0_b <= c_offset;
							computeTState <= T_LI_1;
							firstComputeTRun = 1'b1;
						end
						
						T_LI_1: begin
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							T_address_0_b <= c_offset + 7'd8;
							computeTState <= T_LI_2;
						end
						
						T_LI_2: begin
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							T_address_0_b <= c_offset + 7'd16;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							computeTState <= T_CC_3;
						end
						
						T_CC_3: begin
						

							if (~firstComputeTRun) begin
								T_address_1_a <= computeTWriteAddress;
								T_write_data_1_a_enable <= 1'b1;
								T_write_data_1_a <= computeTWriteBuffer;
							end

							
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							T_address_0_b <= c_offset + 7'd24 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= multiplier1;
							t_buf2 <= multiplier2;
							
														
							computeTState <= T_CC_4;
						end
						
						T_CC_4: begin
							if (~firstComputeTRun) begin
								if (computeTWriteAddress == 7'd15 ||  computeTWriteAddress == 7'd31 ||  computeTWriteAddress == 7'd47)
									computeTWriteAddress <= computeTWriteAddress + 7'd1;
								else
									computeTWriteAddress <= computeTWriteAddress - 7'd7;
							end else 
								firstComputeTRun <= 1'b0;
							
							
							T_write_data_1_a_enable <= 1'b0;
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							T_address_0_b <= c_offset + 7'd32 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							
							computeTState <= T_CC_5;
						end
					
						T_CC_5: begin
						
						
							
							
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							T_address_0_b <= c_offset + 7'd40 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							
							computeTState <= T_CC_6;
						end
						
						T_CC_6: begin
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							T_address_0_b <= c_offset + 7'd48 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							
							computeTState <= T_CC_7;
						end
						
						T_CC_7: begin

							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeRowBlockCounter<<<3;
							
							
							T_address_0_b <= c_offset + 7'd56 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							
							computeTState <= T_CC_8;
						end
						
						T_CC_8: begin
						
							//c_column_counter <= c_column_counter + 7'd1;
							if (c_column_counter == 7'd7) begin
								c_column_counter <= 7'd0;
//								T_address_0_a <= sPrimeRowBlockCounter<<<3 + 7'd8;
//								sPrimeAddress <= sPrimeRowBlockCounter<<<3 + 7'd9;
								T_address_0_a <= sPrimeAddress + 7'd8;
								sPrimeAddress <= sPrimeAddress + 7'd1 + 7'd8;
								sPrimeRowBlockCounter <= sPrimeRowBlockCounter + 7'd1;
								T_doubleIncrementRow <= 1'b1;
								T_address_0_b <= c_offset;
							end else begin
								c_column_counter <= c_column_counter + 7'd1;
								T_address_0_a <= sPrimeAddress + Sprime_Offset;
								sPrimeAddress <= sPrimeAddress + 7'd1;
								T_address_0_b <= c_offset + c_column_counter + 7'd1;
							end

							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							
							computeTState <= T_CC_9;
						end
						
						T_CC_9: begin
							T_doubleIncrementRow <= 1'b0;
						
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							T_address_0_b <= c_offset + 7'd8 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= $signed(read_data_0_a[31:16]); // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= $signed(read_data_0_a[15:0]); // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							
							computeTState <= T_CC_10;
						end
						
						T_CC_10: begin
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							T_address_0_b <= c_offset + 7'd16 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							

							T_address_1_a <= computeTWriteAddress;
							
							computeTWriteAddress <= computeTWriteAddress + 7'd8;
							T_write_data_1_a_enable <= 1'b1;
							computeTWriteBuffer <=  ($signed(t_buf2 + multiplier2))>>>8;
							T_write_data_1_a <= ($signed(t_buf + multiplier1))>>>8;
							
							//bufferCycle <= ~bufferCycle;
														
							t_buf <= 32'd0;
							t_buf2 <= 32'd0;
							if (c_column_counter == 7'd7 && sPrimeRowBlockCounter == 7'd3) begin // 6 or 7 double if long version works better
								computeTState <= T_LO_11;
							end else begin
								computeTState <= T_CC_3;
							end
						
						end
								
						T_LO_11: begin
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;
							
							computeTWriteAddress <= computeTWriteAddress - 7'd7;
							T_write_data_1_a_enable <= 1'b1;
							T_write_data_1_a <= computeTWriteBuffer;
							T_address_1_a <= computeTWriteAddress;
							

							T_address_0_b <= c_offset + 7'd24 + c_column_counter;

							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S

							t_buf <= multiplier1;
							t_buf2 <= multiplier2;

							computeTState <= T_LO_12;
						end

						T_LO_12: begin
							T_write_data_1_a_enable <= 1'b0;
						
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;

							T_address_0_b <= c_offset + 7'd32 + c_column_counter;
							
							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S
							
							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;
							computeTState <= T_LO_13;
						end

						T_LO_13: begin
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;

							T_address_0_b <= c_offset + 7'd40 + c_column_counter;

							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S

							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;

							computeTState <= T_LO_14;
						end

						T_LO_14: begin

							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;

							T_address_0_b <= c_offset + 7'd48 + c_column_counter;

							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S

							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;

							computeTState <= T_LO_15;
						end

						T_LO_15: begin
						
							T_address_0_a <= sPrimeAddress + Sprime_Offset;
							sPrimeAddress <= sPrimeAddress + 7'd1;

							T_address_0_b <= c_offset + 7'd56 + c_column_counter;

							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S

							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;

							computeTState <= T_LO_16;
						end

						T_LO_16: begin

							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S

							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;

							computeTState <= T_LO_17;
						end
						T_LO_17: begin

							T_operand1 <= T_read_data_0_b; // C[0]
							T_operand2 <= computeTOperand1; // S
							
							T_operand3 <= T_read_data_0_b;  // C[0]
							T_operand4 <= computeTOperand2; // S

							t_buf <= t_buf + multiplier1;
							t_buf2 <= t_buf2 + multiplier2;	

							computeTState <= T_LO_18;
						end

						T_LO_18: begin
							T_address_1_a <= computeTWriteAddress;
							computeTWriteAddress <= computeTWriteAddress + 7'd8;
							T_write_data_1_a_enable <= 1'b1;
							computeTWriteBuffer <= (t_buf2 + multiplier2)>>>8;
							T_write_data_1_a <= (t_buf+multiplier1)>>>8;

							computeTState <= T_LO_19;
						end	
						
						T_LO_19: begin
							T_address_1_a <= computeTWriteAddress;
							T_write_data_1_a <= computeTWriteBuffer;
							T_write_data_1_a_enable <= 1'b1;
							computeTState <= T_LO_20;
						end
						
						T_LO_20: begin
							T_write_data_1_a_enable <= 1'b0;
							computeTState <= T_IDLE;
							computeTDone <= 1'b1;
						end

					endcase
			end
		end
	end
end


logic [6:0] S_address_0_a = 7'd0;
logic [6:0] S_address_0_b = 7'd0;
logic [31:0] S_write_data_0_a = 31'd0;
logic [31:0] S_write_data_0_b = 31'd0;
logic S_write_data_0_a_enable = 1'd0;
logic S_write_data_0_b_enable = 1'd0;

logic [6:0] S_address_1_a = 7'd0;
logic [6:0] S_address_1_b = 7'd0;
logic [31:0] S_write_data_1_a = 31'd0;
logic [31:0] S_write_data_1_b = 31'd0;
logic S_write_data_1_a_enable = 1'd0;
logic S_write_data_1_b_enable = 1'd0;

logic [6:0] S_write_offset = 7'd64;

logic computeSEnable = 1'b0;
logic computeSDone = 1'b0;
computeS_States computeS_State;

logic [6:0] c_row_counter = 7'd0;
logic [6:0] t_address = 7'd0;
logic [6:0] c_block_counter = 7'd0;
logic [6:0] computeSWriteAddress = 7'd0;

logic [6:0] t_col_counter = 7'd0;

int s_buf = 32'd0;
int s_buf2 = 32'd0;

int computeSWrite0;
assign computeSWrite0 = ($signed(s_buf+multiplier1))>>>16;
int computeSWrite1;
assign computeSWrite1 = ($signed(s_buf2+multiplier2))>>>16;

logic [7:0] c_transpose_address;


int c_0 = 32'd0;
int c_8 = 32'd0;

always_comb begin : getC_Transpose
	if (c_transpose_address == 8'd0) begin
		c_0 <= 32'd1448;
		c_8 <= 32'd1448;
	end else if (c_transpose_address == 8'd1) begin
		c_0 <= 32'd2008;
		c_8 <= 32'd1702;
	end else if (c_transpose_address == 8'd2) begin
		c_0 <= 32'd1892;
		c_8 <= 32'd783;
	end else if (c_transpose_address == 8'd3) begin
		c_0 <= 32'd1702;
		c_8 <= -32'd399;
	end else if (c_transpose_address == 8'd4) begin
		c_0 <= 32'd1448;
		c_8 <= -32'd1448;
	end else if (c_transpose_address == 8'd5) begin
		c_0 <= 32'd1137;
		c_8 <= -32'd2008;
	end else if (c_transpose_address == 8'd6) begin
		c_0 <= 32'd783;
		c_8 <= -32'd1892;
	end else if (c_transpose_address == 8'd7) begin
		c_0 <= 32'd399;
		c_8 <= -32'd1137;
	end else if (c_transpose_address == 8'd8) begin
		c_0 <= 32'd1448;
		c_8 <= 32'd1448;
	end else if (c_transpose_address == 8'd9) begin
		c_0 <= 32'd1137;
		c_8 <= 32'd399;
	end else if (c_transpose_address == 8'd10) begin
		c_0 <= -32'd783;
		c_8 <= -32'd1812;
	end else if (c_transpose_address == 8'd11) begin
		c_0 <= -32'd2008;
		c_8 <= -32'd1137;
	end else if (c_transpose_address == 8'd12) begin
		c_0 <= -32'd1448;
		c_8 <= 32'd1448;
	end else if (c_transpose_address == 8'd13) begin
		c_0 <= 32'd399;
		c_8 <= 32'd1702;
	end else if (c_transpose_address == 8'd14) begin
		c_0 <= 32'd1892;
		c_8 <= -32'd783;
	end else if (c_transpose_address == 8'd15) begin
		c_0 <= 32'd1702;
		c_8 <= -32'd2008;
	end else if (c_transpose_address == 8'd16) begin
		c_0 <= 32'd1448;
		c_8 <= 32'd1448;
	end else if (c_transpose_address == 8'd17) begin
		c_0 <= -32'd399;
		c_8 <= -32'd1137;
	end else if (c_transpose_address == 8'd18) begin
		c_0 <= -32'd1892;
		c_8 <= -32'd783;
	end else if (c_transpose_address == 8'd19) begin
		c_0 <= 32'd1137;
		c_8 <= 32'd2008;
	end else if (c_transpose_address == 8'd20) begin
		c_0 <= 32'd1448;
		c_8 <= -32'd1448;
	end else if (c_transpose_address == 8'd21) begin
		c_0 <= -32'd1702;
		c_8 <= -32'd399;
	end else if (c_transpose_address == 8'd22) begin
		c_0 <= -32'd783;
		c_8 <= 32'd1892;
	end else if (c_transpose_address == 8'd23) begin
		c_0 <= 32'd2008;
		c_8 <= -32'd1702;
	end else if (c_transpose_address == 8'd24) begin
		c_0 <= 32'd1448;
		c_8 <= 32'd1448;
	end else if (c_transpose_address == 8'd25) begin
		c_0 <= -32'd1702;
		c_8 <= -32'd2008;
	end else if (c_transpose_address == 8'd26) begin
		c_0 <= 32'd783;
		c_8 <= 32'd1892;
	end else if (c_transpose_address == 8'd27) begin
		c_0 <= 32'd399;
		c_8 <= -32'd1702;
	end else if (c_transpose_address == 8'd28) begin
		c_0 <= -32'd1448;
		c_8 <= 32'd1448;
	end else if (c_transpose_address == 8'd29) begin
		c_0 <= 32'd2008;
		c_8 <= -32'd1137;
	end else if (c_transpose_address == 8'd30) begin
		c_0 <= -32'd1892;
		c_8 <= 32'd783;
	end else if (c_transpose_address == 8'd31) begin
		c_0 <= 32'd1137;
		c_8 <= -32'd399;
	end else begin
		c_0 <= 32'd0;
		c_8 <= 32'd0;
	
	end
	
end


always_ff @(posedge Clock or negedge Resetn) begin : ComputeS
	if(~Resetn) begin
		computeSDone <= 1'b0;
		c_transpose_address <= 1'b0;
		//c_block_counter<=7'd1;
		computeS_State <= CS_IDLE;
	end else begin
		if (M2_enable) begin
			if(~M2_done) begin
					case(computeS_State)
						CS_IDLE: begin
							if (computeSEnable == 1'b1) begin
								computeS_State <= CS_IDLE2;
							end
							computeSDone <= 1'b0;
						end
						
						CS_IDLE2: begin
							if (computeSEnable == 1'b1) begin
								computeS_State <= CS_IDLE3;
							end else begin
								computeS_State <= CS_IDLE;
							end
						end
						
						CS_IDLE3: begin
							if (computeSEnable == 1'b1) begin
								computeS_State <= S_LI_0;
								c_row_counter <= 7'd0;
								t_address <= 7'd0;
								c_block_counter <= 7'd0;
								computeSWriteAddress <= 7'd0;
								t_col_counter <= 7'd0;
								s_buf <= 32'd0;
								s_buf2 <= 32'd0;
								c_transpose_address <= 8'd0;
								S_operand1 <= 32'd0;
								S_operand2 <= 32'd0;
								S_operand3 <= 32'd0;
								S_operand4 <= 32'd0;	
							end else begin
								computeS_State <= CS_IDLE;
							end
						end
						
						S_LI_0: begin

							 
							//S_address_0_b <= c_offset;
							
							S_address_1_a <= t_address;
							//t_address <= t_address + 7'd8;
							
							computeS_State <= S_LI_1;

						end
						
						S_LI_1: begin
							//S_address_0_b <= c_offset + 7'd8;
							c_transpose_address <= 7'd0;
							
							S_address_1_a <= t_address + 7'd8;
							//t_address <= t_address + 7'd8;
							
							computeS_State <= S_LI_2;
						end
						
						S_LI_2: begin
							//S_address_0_b <= c_offset + 7'd16;
							c_transpose_address <= 7'd1;
							
							S_address_1_a <= t_address  + 7'd16;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= $signed(read_data_1_a);

							S_operand3 <= c_8;
							S_operand4 <= $signed(read_data_1_a);	
							
							s_buf <= 32'd0;
							s_buf2 <= 32'd0;
							
							computeS_State <= S_CC_3;
						end
						
						S_CC_3: begin
							
							//S_address_0_b <= c_offset + 7'd24 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd24;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= $signed(read_data_1_a);

							S_operand3 <= c_8;
							S_operand4 <= $signed(read_data_1_a);	
							
							s_buf <= multiplier1;
							s_buf2 <= multiplier2;
							
							S_write_data_1_b_enable <= 1'b0;
							
							computeS_State <= S_CC_4;
							
						end
						
						S_CC_4: begin
							//S_address_0_b <= c_offset + 7'd32 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address  + 7'd32;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_5;
							
						end
						
						S_CC_5: begin
							//S_address_0_b <= c_offset + 7'd40 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address  + 7'd40;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_6;
							
						end
						
						S_CC_6: begin
							//S_address_0_b <= c_offset + 7'd48 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd48;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_7;
							
						end
						
						S_CC_7: begin
							//S_address_0_b <= c_offset + 7'd56 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd56;
							//t_address <= t_address + 7'd8;
							
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_8;
							
						end
						
						S_CC_8: begin
						
						
						if(t_address==7'd7) begin
							S_address_1_a<= 7'd0; 
							t_address<=7'd0;
							c_block_counter<= c_block_counter+7'd1;
							//c_transpose_address<=((c_block_counter+7'd1)<<<3) + 7'd8;
							c_transpose_address<=(c_block_counter+7'd1)<<<3;
						end else begin
							c_transpose_address<=c_transpose_address + 7'd1;
							t_address<=t_address + 7'd1;
							S_address_1_a <= t_address +7'd1;
						end					
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_9;
							
						end
						
						S_CC_9: begin
							//S_address_0_b <= c_offset + 7'd8 + c_row_counter;
							c_transpose_address<=c_block_counter<<<3;
							//c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd8;
							//t_address <= t_address + 7'd4;
							
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_10;
							
						end
						
						S_CC_10: begin
							S_address_0_b <= 7'd1 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd16;
							//t_address <= t_address + 7'd4;
							
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= 32'd0;
							s_buf2 <= 32'd0;//s+mult
														
							S_address_1_b <= computeSWriteAddress +S_write_offset;
							computeSWriteAddress <= computeSWriteAddress + 7'd1;
							S_write_data_1_b_enable <= 1'b1;
							S_write_data_1_b <= {computeSWrite0[15:0], computeSWrite1[15:0]};
							
							if (t_address == 7'd7 && c_block_counter == 7'd3) begin
								computeS_State <= S_LO_11;
							end else begin
								computeS_State <= S_CC_3;
							end
							
						end
						
						S_LO_11: begin
						
						
							
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd24;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= multiplier1;
							s_buf2 <= multiplier2;
							
							S_write_data_1_b_enable <= 1'b0;
							
							computeS_State <= S_LO_12;
						end
						
						S_LO_12: begin
						
						
							//S_address_0_b <= c_offset + 7'd32 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address  + 7'd32;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
							
							computeS_State <= S_CC_5;
						
							computeS_State <= S_LO_13;
						end
						
						S_LO_13: begin
						
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address  + 7'd40;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
						
							computeS_State <= S_LO_14;
						end
						
						S_LO_14: begin
						
							//S_address_0_b <= c_offset + 7'd48 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd48;
							//t_address <= t_address + 7'd8;
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
						
							computeS_State <= S_LO_15;
						end
						
						S_LO_15: begin
						
							//S_address_0_b <= c_offset + 7'd56 + c_row_counter;
							c_transpose_address<=c_transpose_address + 7'd1;
							
							S_address_1_a <= t_address + 7'd56;
							//t_address <= t_address + 7'd8;
							
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
						
							computeS_State <= S_LO_16;
						end
						
						S_LO_16: begin
				
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
						
							computeS_State <= S_LO_17;
						end
						
						S_LO_17: begin

							
							
							S_operand1 <= c_0;
							S_operand2 <= read_data_1_a;

							S_operand3 <= c_8;
							S_operand4 <= read_data_1_a;	
							
							s_buf <= s_buf + multiplier1;
							s_buf2 <= s_buf2 + multiplier2;
						
							computeS_State <= S_LO_18;
						end
						
						S_LO_18: begin
		
						
							S_address_1_b <= computeSWriteAddress + S_write_offset;
							S_write_data_1_b_enable <= 1'b1;
							S_write_data_1_b <= {computeSWrite0[15:0], computeSWrite1[15:0]};
						
							computeS_State <= S_LO_19;
						end
						
						S_LO_19: begin
						
							S_write_data_1_b_enable <= 1'b0;
							computeSDone <= 1'b1;
							computeS_State <= CS_IDLE;
						end

					endcase
			end
		end
	end
end

writeS_States writeS_State;


logic [6:0] W_address_1_b = 7'd0;
logic [17:0] W_SRAM_address;
logic [15:0] W_SRAM_write_data = 16'd0;
logic [6:0] writeSAddressDRAMCounter = 7'd0;
logic W_write_en = 1'b1;
logic writeSEnable = 1'b0;
logic writeSDone = 1'b0;
logic [17:0] writeSAddressCounter = 18'd0;


logic [7:0] WrowIndex = 8'd0;
logic [7:0] WcolumnIndex = 8'd0;
logic [7:0] WrowBlockIndex = 8'd0;
logic [7:0] WcolumnBlockIndex = 8'd0;
logic writeIncrement;
logic [1:0] rowIncrement = 2'd0;
logic [31:0] writeSBuffer = 31'd0;
logic firstWrite;

logic[6:0] S_Offset = 7'd64;
// assign W_SRAM_address = {10'd0, ({7'd0 ,WrowBlockIndex, 3'd0} + {11'd0, WrowIndex})<<<7} + {10'd0, ({7'd0 ,WrowBlockIndex, 3'd0} + {11'd0, WrowIndex})<<<5} + {8'd0 ,WcolumnBlockIndex, 2'd0} + {11'd0, WcolumnIndex};
assign W_SRAM_address = {{WrowBlockIndex, 3'd0} + {3'd0, WrowIndex}, 7'd0} + {2'd0 ,{WrowBlockIndex, 3'd0} + {3'd0, WrowIndex}, 5'd0} + {8'd0 ,WcolumnBlockIndex, 2'd0} + {10'd0, WcolumnIndex};


always_ff @(posedge Clock or negedge Resetn) begin : WriteS
	if(~Resetn) begin
		writeSDone <= 1'b0;
		writeSAddressDRAMCounter <= 7'd0;
		firstWrite <= 1'd1;
		writeS_State <= W_IDLE;
		writeIncrement = 1'd0;
	end else begin
		if (M2_enable) begin
			if(~M2_done) begin
					case(writeS_State)
						W_IDLE: begin
							if (writeSEnable == 1'b1) begin
								writeS_State <= W_IDLE2;
							end
							writeSDone <= 1'd0;
						end
						
						W_IDLE2: begin
							if (writeSEnable == 1'b1) begin
								writeS_State <= W_IDLE3;
							end else begin
								writeS_State <= W_IDLE;
							end
						end
						
						W_IDLE3: begin
							if (writeSEnable == 1'b1) begin
								writeS_State <= W_LI_0;
								firstWrite <= 1'b1;
								W_write_en <= 1'b1;
								writeSAddressCounter <= 18'd0;
								W_address_1_b <= 7'd0;
								W_SRAM_write_data <= 16'd0;
								writeSAddressDRAMCounter <= 8'd0;
							end else begin
								writeS_State <= W_IDLE;
							end
						end
						
						W_LI_0: begin

							W_address_1_b <= S_Offset;
							writeSAddressDRAMCounter <= S_Offset + 7'd1;
							writeS_State <= W_LI_1;
						end
						
						W_LI_1: begin
							W_address_1_b <= writeSAddressDRAMCounter;
							writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
							writeS_State <= W_LI_2;
						end
						
						W_LI_2: begin
							W_address_1_b <= writeSAddressDRAMCounter;
							writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
							writeSBuffer <= read_data_1_b;
							writeS_State <= W_LI_3;
						end
						
						W_LI_3: begin
							W_address_1_b <= writeSAddressDRAMCounter;
							writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
							W_write_en <= 1'b0;
							
							
							
							if (writeSBuffer[31]) begin
									W_SRAM_write_data[15:8] <= 8'b0;
								end else begin
									if (|(writeSBuffer[30:24])) begin
										W_SRAM_write_data[15:8] <= 8'hFF;
									end else begin 
										W_SRAM_write_data[15:8] <= $signed(writeSBuffer[23:16]);
									end
							end
							
							if (read_data_1_b[31]) begin
									W_SRAM_write_data[7:0] <= 8'b0;
								end else begin
									if (|(read_data_1_b[30:24])) begin
										W_SRAM_write_data[7:0] <= 8'hFF;
									end else begin 
										W_SRAM_write_data[7:0] <= $signed(read_data_1_b[23:16]);
									end
							end
							
							writeSBuffer <= {writeSBuffer[15:0], read_data_1_b[15:0]};
							writeS_State <= W_CC_4;
						end
						
						W_CC_4: begin
							W_address_1_b <= writeSAddressDRAMCounter;
							writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
							
							WrowIndex <= WrowIndex + 7'd1;
							
							if (writeSBuffer[31]) begin
									W_SRAM_write_data[15:8] <= 8'b0;
								end else begin
								if (|(read_data_1_b[30:24])) begin
									W_SRAM_write_data[15:8] <= 8'hFF;
								end else begin 
									W_SRAM_write_data[15:8] <= $signed(writeSBuffer[23:16]);
								end
							end 

							
							if (writeSBuffer[15]) begin
									W_SRAM_write_data[7:0] <= 8'b0;
							end else begin
								if (|(writeSBuffer[14:8])) begin
									W_SRAM_write_data[7:0] <= 8'hFF;
								end else begin 
									W_SRAM_write_data[7:0] <= $signed(writeSBuffer[7:0]);
								end
							end
						
							writeSBuffer <= read_data_1_b;
							writeS_State <= W_CC_5;
						end
						
						
						W_CC_5: begin
							W_address_1_b <= writeSAddressDRAMCounter;
							//writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
							
							if (writeSBuffer[31]) begin
								W_SRAM_write_data[15:8] <= 8'b0;
							end else begin
								if (|(writeSBuffer[30:24])) begin
									W_SRAM_write_data[15:8] <= 8'hFF;
								end else begin 
									W_SRAM_write_data[15:8] <= $signed(writeSBuffer[23:16]);
								end
							end
							
							if (read_data_1_b[31]) begin
								W_SRAM_write_data[7:0] <= 8'b0;
							end else begin
								if (|(read_data_1_b[30:24])) begin
									W_SRAM_write_data[7:0] <= 8'hFF;
								end else begin 
									W_SRAM_write_data[7:0] <= $signed(read_data_1_b[23:16]);
								end
							end
							
							writeSBuffer <= {writeSBuffer[15:0], read_data_1_b[15:0]};
							
							//WrowIndex <= WrowIndex + 7'd1;
							if (WcolumnIndex == 7'd1 && WrowIndex == 7'd7) begin
								writeS_State <= W_LO_6;
								WrowIndex <= WrowIndex - 7'd1;
								WcolumnIndex <= WcolumnIndex + 7'd1;
							end else if (WcolumnIndex == 7'd3) begin
								WcolumnIndex <= 7'd0;
								WrowIndex <= WrowIndex + 7'd1;
								writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
								writeS_State <= W_CC_4;
							end else begin
								WrowIndex <= WrowIndex - 7'd1;
								WcolumnIndex <= WcolumnIndex + 7'd1;
								writeSAddressDRAMCounter <= writeSAddressDRAMCounter + 7'd1;
								writeS_State <= W_CC_4;
							end
							
						end
						
						
						W_LO_6: begin
							W_address_1_b <= writeSAddressDRAMCounter;
							//get 54 62 // write 60, 61
							//WcolumnIndex <= WcolumnIndex + 7'd1;
							WrowIndex <= WrowIndex + 7'd1;
							
							if (writeSBuffer[31]) begin
									W_SRAM_write_data[15:8] <= 8'b0;
								end else begin
									if (|(read_data_1_b[30:24])) begin
										W_SRAM_write_data[15:8] <= 8'hFF;
									end else begin 
										W_SRAM_write_data[15:8] <= writeSBuffer[23:16];
									end
							end
							
							if (writeSBuffer[15]) begin
									W_SRAM_write_data[7:0] <= 8'b0;
								end else begin
									if (|(writeSBuffer[14:8])) begin
										W_SRAM_write_data[7:0] <= 8'hFF;
									end else begin 
										W_SRAM_write_data[7:0] <= writeSBuffer[7:0];
									end
							end
							
							writeSBuffer <= read_data_1_b;
							writeS_State <= W_LO_7;
						end

						
						
						W_LO_7: begin
							//get 55 63
							WrowIndex <= WrowIndex - 7'd1;
							WcolumnIndex <= WcolumnIndex + 7'd1;

							if (writeSBuffer[31]) begin
									W_SRAM_write_data[15:8] <= 8'b0;
								end else begin
									if (|(writeSBuffer[30:24])) begin
										W_SRAM_write_data[15:8] <= 8'hFF;
									end else begin 
										W_SRAM_write_data[15:8] <= writeSBuffer[23:16];
									end
							end
							
							if (read_data_1_b[31]) begin
									W_SRAM_write_data[7:0] <= 8'b0;
								end else begin
									if (|(read_data_1_b[30:24])) begin
										W_SRAM_write_data[7:0] <= 8'hFF;
									end else begin 
										W_SRAM_write_data[7:0] <= read_data_1_b[23:16];
									end
							end
							
							writeSBuffer <= {writeSBuffer[15:0], read_data_1_b[15:0]};
							writeS_State <= W_LO_8;
						end
						
						W_LO_8: begin
							WrowIndex <= WrowIndex + 7'd1;
							if (writeSBuffer[31]) begin
									W_SRAM_write_data[15:8] <= 8'b0;
								end else begin
								if (|(read_data_1_b[30:24])) begin
									W_SRAM_write_data[15:8] <= 8'hFF;
								end else begin 
									W_SRAM_write_data[15:8] <= writeSBuffer[23:16];
								end
							end
							
							if (writeSBuffer[15]) begin
								W_SRAM_write_data[7:0] <= 8'b0;
							end else begin
								if (|(writeSBuffer[14:8])) begin
									W_SRAM_write_data[7:0] <= 8'hFF;
								end else begin 
									W_SRAM_write_data[7:0] <= writeSBuffer[7:0];
								end
							end
							
							writeS_State <= W_LO_9;
						end
						
						W_LO_9: begin
							WcolumnIndex<=7'd0;
							WrowIndex<=7'd0;
							if (WcolumnBlockIndex == 7'd39) begin
								WcolumnBlockIndex<= 7'd0;
								WrowBlockIndex<=WrowBlockIndex + 7'd1;
							end else begin
								WcolumnBlockIndex <= WcolumnBlockIndex + 7'd1;
							end
							writeSDone = 1'b1;
							W_write_en <= 1'b1;
							writeS_State <= W_IDLE;
						end
						
					endcase
			end
			end
	end
end


always_comb begin : AllocateMemoryPorts
	if (M2_State == task0) begin
		//Fetch S'
		address_0_a = F_address_0_a;
		write_data_0_a = F_write_data_0_a;
		write_data_0_a_enable = F_write_data_0_a_enable;
		SRAM_address = F_SRAM_address;
		SRAM_we_n = F_SRAM_we_n;
		
		//Not Used - checked

		SRAM_write_data = 16'd0;
		address_0_b = 7'd0;
		address_1_a = 7'd0;
		address_1_b = 7'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		write_data_1_a  = 31'd0;
		write_data_1_a_enable  = 1'd0;
		write_data_1_b  = 31'd0;
		write_data_1_b_enable  = 1'd0;
		
	end else if (M2_State == task1) begin
		//Compute T
		address_0_a = T_address_0_a;
		address_0_b = T_address_0_b;
		address_1_a = T_address_1_a;
		write_data_1_a  = T_write_data_1_a;
		write_data_1_a_enable  = T_write_data_1_a_enable;
		
		//Not Used - checked
		SRAM_address = 18'd0;
		SRAM_we_n = 1'd1;
		SRAM_write_data = 16'd0;
		address_1_b = 7'd0;
		write_data_0_a = 31'd0;
		write_data_0_a_enable = 1'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		write_data_1_b  = 31'd0;
		write_data_1_b_enable  = 1'd0;


	end else if (M2_State == task2) begin
		//Compute s
		address_0_b = S_address_0_b;
		address_1_a = S_address_1_a;
		write_data_1_a  = S_write_data_1_a;
		write_data_1_a_enable  = S_write_data_1_a_enable;
		address_1_b = S_address_1_b;
		write_data_1_b  = S_write_data_1_b;
		write_data_1_b_enable  = S_write_data_1_b_enable;
		
		//Fetch S'
		address_0_a = F_address_0_a;
		write_data_0_a = F_write_data_0_a;
		write_data_0_a_enable = F_write_data_0_a_enable;
		SRAM_address = F_SRAM_address;
		SRAM_we_n = F_SRAM_we_n;
		
		
		
		
		//SRAM_address = 18'd0;
		//SRAM_we_n = 1'd1;
		SRAM_write_data = 16'd0;
		//address_0_a = 7'd0;

		
		//write_data_0_a = 31'd0;
		//write_data_0_a_enable = 1'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		//write_data_1_b = 31'd0;
		//write_data_1_b_enable = 1'd0;
		
	end else if (M2_State == task3) begin
		//Write S
		SRAM_address = W_SRAM_address;
		SRAM_write_data = W_SRAM_write_data;
		SRAM_we_n = W_write_en;
		address_1_b = W_address_1_b;
		
		//Compute T
		address_0_a = T_address_0_a;
		address_0_b = T_address_0_b;
		address_1_a = T_address_1_a;
		write_data_1_a  = T_write_data_1_a;
		write_data_1_a_enable  = T_write_data_1_a_enable;
		//not used
		//address_0_a = 7'd0;
		//address_0_b = 7'd0;
		//address_1_a = 7'd0;
		
		write_data_0_a = 31'd0;
		write_data_0_a_enable = 1'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		//write_data_1_a  = 31'd0;
		//write_data_1_a_enable  = 1'd0;
		write_data_1_b  = 31'd0;
		write_data_1_b_enable  = 1'd0;
	end else if (M2_State == leadOutTask0) begin
			//Compute s
		address_0_b = S_address_0_b;
		address_1_a = S_address_1_a;
		write_data_1_a  = S_write_data_1_a;
		write_data_1_a_enable  = S_write_data_1_a_enable;
		address_1_b = S_address_1_b;
		write_data_1_b  = S_write_data_1_b;
		write_data_1_b_enable  = S_write_data_1_b_enable;
		
		SRAM_address = 18'd0;
		SRAM_we_n = 1'd1;
		SRAM_write_data = 16'd0;
		address_0_a = 7'd0;

		
		write_data_0_a = 31'd0;
		write_data_0_a_enable = 1'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		//write_data_1_b = 31'd0;
		//write_data_1_b_enable = 1'd0;
		
	end else if (M2_State == leadOutTask1) begin
		//Write S
		SRAM_address = W_SRAM_address;
		SRAM_write_data = W_SRAM_write_data;
		SRAM_we_n = W_write_en;
		address_1_b = W_address_1_b;

		//not used
		address_0_a = 7'd0;
		address_0_b = 7'd0;
		address_1_a = 7'd0;
		
		write_data_0_a = 31'd0;
		write_data_0_a_enable = 1'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		write_data_1_a  = 31'd0;
		write_data_1_a_enable  = 1'd0;
		write_data_1_b  = 31'd0;
		write_data_1_b_enable  = 1'd0;
	
	end else begin
		SRAM_address = 18'd0;
		SRAM_we_n = 1'd1;
		SRAM_write_data = 16'd0;
		address_0_a = 7'd0;
		address_0_b = 7'd0;
		address_1_a = 7'd0;
		address_1_b = 7'd0;
		write_data_0_a = 31'd0;
		write_data_0_a_enable = 1'd0;
		write_data_0_b = 31'd0;
		write_data_0_b_enable = 1'd0;
		write_data_1_a  = 31'd0;
		write_data_1_a_enable  = 1'd0;
		write_data_1_b  = 31'd0;
		write_data_1_b_enable  = 1'd0;
	end
end

logic [7:0] blockCounter = 8'd0;
logic FetchSprimeFinished = 1'd0;
logic ComputeTFinished = 1'd0;
logic ComputeSFinished = 1'd0;
logic WriteSFinished = 1'd0;

always_ff @(posedge Clock or negedge Resetn) begin : M2TopLevel
	if(~Resetn) begin
		//increment <= 1'b0;
		fetchSprimeEnable <= 1'b0;
		M2_done <= 1'b0;
		Sprime_Offset <= 7'd0;
		FetchSprimeFinished <= 1'd0;
		ComputeTFinished <= 1'd0;
		ComputeSFinished <= 1'd0;
		WriteSFinished <= 1'd0;
		M2_State <= M2_IDLE;
		blockCounter <= 8'd0;
	end else begin
			
		case(M2_State)
			M2_IDLE: begin
				if(M2_enable) begin
					M2_State<= task0;
				end
			end
			
			task0: begin
				if (fetchSprimeDone) begin
					fetchSprimeEnable <= 1'b0;
					FetchSprimeFinished <= 1'b1;
				end
				if (FetchSprimeFinished) begin
					M2_State <= task1;
					FetchSprimeFinished <= 1'b0;
					fetchSprimeEnable <= 1'b0;
				end else begin
					fetchSprimeEnable <= 1'b1;
				end
			end
			
			task1: begin
				if (computeTDone) begin
					computeTEnable <= 1'b0;
					ComputeTFinished <= 1'b1;
				end
				if (ComputeTFinished) begin
					M2_State <= task2;
					ComputeTFinished <= 1'b0;
					computeTEnable <= 1'b0;
				end else begin
					computeTEnable <= 1'b1;
				end
			end

			task2: begin
				if (computeSDone) begin
					computeSEnable <= 1'b0;
					ComputeSFinished <= 1'b1;
				end
				if (fetchSprimeDone) begin
					fetchSprimeEnable <= 1'b0;
					FetchSprimeFinished <= 1'b1;
				end
				
				if (ComputeSFinished) begin
					computeSEnable <= 1'b0;
				end else begin
					computeSEnable <= 1'b1;
				end
				if (FetchSprimeFinished) begin
					fetchSprimeEnable <= 1'b0;
				end else begin
					fetchSprimeEnable <= 1'b1;
				end
				
				if (ComputeSFinished && FetchSprimeFinished) begin
					ComputeSFinished <= 1'b0;
					FetchSprimeFinished <= 1'b0;
					M2_State <= task3;
				end
			end
			
			task3: begin
			
				if (computeTDone) begin
					computeTEnable <= 1'b0;
					ComputeTFinished <= 1'b1;
				end
				if (ComputeTFinished) begin
					computeTEnable <= 1'b0;
				end else begin
					computeTEnable <= 1'b1;
				end
				
				if (writeSDone) begin
					writeSEnable  <= 1'b0;
					WriteSFinished <= 1'b1;
				end
				if (WriteSFinished) begin
					writeSEnable <= 1'b0;
				end else begin
					writeSEnable <= 1'b1;
				end
				
				if (ComputeTFinished && WriteSFinished) begin
					WriteSFinished <= 1'b0;
					ComputeTFinished <= 1'b0;
					blockCounter <= blockCounter + 8'd1;
					if (computeV && rowBlockIndex == 7'd90 || computeV && rowBlockIndex == 7'd60 || computeY && rowBlockIndex == 7'd30) begin
					//if (columnBlockIndex == 7'd2) begin
						M2_State <= leadOutTask0;
					//M2_done <= 1'b1;
					end else begin
						M2_State <= task2;
					end
				end

			end
			
			leadOutTask0: begin
				if (computeSDone) begin
					computeSEnable <= 1'b0;
					ComputeSFinished <= 1'b1;
				end
				
				if (ComputeSFinished) begin
					M2_State <= leadOutTask1;
					ComputeSFinished <= 1'b0;
					computeSEnable <= 1'b0;
				end else begin
					computeSEnable <= 1'b1;
				end
			end
			 
			leadOutTask1: begin
				
				
				if (writeSDone) begin
					writeSEnable  <= 1'b0;
					WriteSFinished <= 1'b1;
				end
				if (WriteSFinished) begin
					if (computeV) begin
					
					end else if (computeU) begin
					
					end else if (computeY) begin
					
					end
					if (computeY && computeU && computeV) begin
						M2_State <= M2_IDLE;
						writeSEnable <= 1'b0;
						WriteSFinished <= 1'b0;
						M2_done <= 1'b1;
					end else begin
						if (computeU) begin
							computeV <= 1'b1;
							M2_State <= M2_IDLE;
							writeSEnable <= 1'b0;
							WriteSFinished <= 1'b0;
						end else if (computeY) begin
							computeU <= 1'b1;
							M2_State <= M2_IDLE;
							writeSEnable <= 1'b0;
							WriteSFinished <= 1'b0;
						end
					end

				end else begin
					writeSEnable <= 1'b1;
				end
				
			end		
		
		endcase			
	end
end


endmodule
