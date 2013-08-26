module FIFO_Loader(
	output reg [7:0] data,
	output reg wrreq,
	
	input clk,
	input wrfull,
	input rst
);

	//State Machine Declaraction
	enum { RST = 0 , WRITE = 1 , ADV = 2, DONE = 4} state, next_state;

	reg [7:0] address;
	
	//ROM to be send to the display
	parameter NCHARS = 27;
	
	always @(address)
	 begin
	  case (address)
		 0 : data = 8'hFE; //Signal Device Command
		 1 : data = 8'h01; //Clear the Screen
		 2 : data = "C"; 
		 3 : data = "h";
		 4 : data = "r";
		 5 : data = "i";
		 6 : data = "s";
		 7 : data = " ";
		 8 : data = "Z";
		 9 : data = "e";
		 10 : data = "h";
		 11 : data = 8'hFE; //Signal Device Command
		 12 : data = 8'hC0; //Move to the 1st Char of the 2nd line (16x2 Screen)
		 13 : data = "i";
		 14 : data = "d";
		 15 : data = "l";
		 16 : data = "e";
		 17 : data = "-";
		 18 : data = "l";
		 19 : data = "o";
		 20 : data = "g";
		 21 : data = "i";
		 22 : data = "c";
		 23 : data = ".";
		 24 : data = "c";
		 25 : data = "o";
		 26 : data = "m";
		 default: data=8'hFF;
	  endcase
	end

	

	//State Machine Output Calculation
	always @(posedge clk) begin
		state <= next_state;
		if (state[4:0] == ADV) address <= address + 8'd1;
		if (state[4:0] == RST) address <= 8'd0;
		
		
	end

	//State Machine Next State Calculation
	always_comb begin
		wrreq = 0;
		
		case (state)
			RST:		next_state = WRITE;
			
			WRITE:	begin
							if (wrfull) next_state = DONE;
							else begin
								wrreq = 1;
								next_state = ADV;
							end
							
						end
			
			ADV:		begin
							if (address == (NCHARS-1) ) next_state = DONE;
							else	next_state = WRITE;
						end
			DONE: 	next_state = DONE;
			default:	next_state = RST;
				
			endcase
			if (rst) next_state = RST;
	end




endmodule
