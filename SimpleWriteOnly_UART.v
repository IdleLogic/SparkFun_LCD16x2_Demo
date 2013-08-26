module SimpleWriteOnly_UART(
	input TX_CLK,
	input [7:0] data_in,
	input rdempty,
	input rst,
	output reg rdreq,
	output reg TX

);

parameter STARTBIT 	= 1'b0;
parameter STOPBIT	= 1'b1;

//STATE Definition
enum { 	RST = 0,
			WRITE_StartBit = 2, 
			WRITE_B0 = 4, 
			WRITE_B1 = 8, 
			WRITE_B2 = 16, 
			WRITE_B3 = 32,
			WRITE_B4 = 64,
			WRITE_B5 = 128,
			WRITE_B6 = 256,
			WRITE_B7 = 512,
			WRITE_StopBit = 1024, 
			LOAD = 2048, 
			IDLE = 4096
			} state, next_state;

reg [7:0] data_shiftreg;

//REGISTER DEFINITION
always @(posedge TX_CLK) begin
	TX <= 1'b1; //Hold the BUS High if no activity is happening
	state <= next_state;	
	
	if (	state == IDLE ||
			state == WRITE_StopBit) 	TX <= STOPBIT;
		
	if (	state == WRITE_StartBit) 	begin
													data_shiftreg <= data_in;
													TX <= STARTBIT;
												end
	if (	state == WRITE_B0 ||
			state == WRITE_B1 || 
			state == WRITE_B2 || 
			state == WRITE_B3 || 
			state == WRITE_B4 || 
			state == WRITE_B5 ||
			state == WRITE_B6 || 	
			state == WRITE_B7  ) 		begin
													TX <= data_shiftreg[0];
													data_shiftreg <= {1'b0, data_shiftreg[7:1]};
												end
	
											
		
end

//NEXT STATE CALCULATION
always_comb begin
	rdreq = 0;
	
	case (state)
		RST:					next_state = IDLE;					
		
		IDLE:					if (!rdempty) next_state = LOAD;
								else next_state = IDLE;
								
		LOAD:					begin
									rdreq = 1;
									next_state = WRITE_StartBit;
								end
		
		WRITE_StartBit:	next_state = WRITE_B0;
		WRITE_B0:			next_state = WRITE_B1;
		WRITE_B1:			next_state = WRITE_B2;
		WRITE_B2:			next_state = WRITE_B3;
		WRITE_B3:			next_state = WRITE_B4;
		WRITE_B4:			next_state = WRITE_B5;
		WRITE_B5:			next_state = WRITE_B6;
		WRITE_B6:			next_state = WRITE_B7;
		WRITE_B7:			next_state = WRITE_StopBit;
		WRITE_StopBit:		next_state = IDLE;
								
		
		default:	next_state = RST;
			
		endcase
		if (rst) next_state = RST;
end


endmodule