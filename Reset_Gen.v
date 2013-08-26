module Reset_Gen(
	input clk_50,
	output reg rst_n
);


enum { RESET = 0, COUNT = 2, DONE = 4} state, next_state;

initial begin
	rst_n = 1;
end


reg [25:0] counter;


//State Machine Output Calculation
always @(posedge clk_50) begin
	state <= next_state;
	rst_n = 1'b1;
	if (state == COUNT) 	counter <= counter + 26'd1;
	if (state == RESET) 	counter <= 26'd0;
	if (state == DONE)	rst_n = 1'b0;
	
end

//State Machine Next State Calculation
always_comb begin	
	case (state)
		RESET:	next_state = COUNT;
		
		COUNT: 	if (counter >= 26'h3FFFFFF) next_state = DONE; //Wait ~1.3s for the LCD To Finish Splash Screen 
					else next_state = COUNT;
		DONE:		next_state = DONE;
		default:	next_state = RESET;
			
		endcase
end


endmodule

