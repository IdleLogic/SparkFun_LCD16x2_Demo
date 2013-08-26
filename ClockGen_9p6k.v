module ClockGen_9p6k(
	input wire clk_50,
	output reg clk_9p6k
);



enum { RESET = 0, COUNT = 2} state, next_state;

initial begin
	clk_9p6k = 0;
end


reg [12:0] counter;


//REGISTER DEFINITION
always @(posedge clk_50) begin
	state <= next_state;
	if (state == COUNT) counter <= counter + 13'd1;
	if (state == RESET) 	begin
									counter <= 13'd0;
									clk_9p6k <= ~clk_9p6k;
								end
	
end

//NEXT STATE CALCULATION
always_comb begin	
	
	case (state)
		RESET:	next_state = COUNT;
		
		COUNT: 	if (counter >= 2604) next_state = RESET;
					else next_state = COUNT;
		default:	next_state = RESET;
			
		endcase
		//if (rst) next_state = RESET;
end


endmodule