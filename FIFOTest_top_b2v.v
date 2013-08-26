// Copyright (C) 1991-2013 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files from any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

// PROGRAM		"Quartus II 64-Bit"
// VERSION		"Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition"
// CREATED		"Sun Aug 25 19:58:02 2013"

module FIFOTest_top_b2v(
	CLOCK_50,
	TX
);


input wire	CLOCK_50;
output wire	TX;

wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	[7:0] SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_6;
wire	[7:0] SYNTHESIZED_WIRE_8;
wire	SYNTHESIZED_WIRE_9;





FIFO_mega	FIFO_mega_inst(
	.wrreq(SYNTHESIZED_WIRE_0),
	.wrclk(CLOCK_50),
	.rdreq(SYNTHESIZED_WIRE_1),
	.rdclk(SYNTHESIZED_WIRE_11),
	.aclr(SYNTHESIZED_WIRE_12),
	.data(SYNTHESIZED_WIRE_4),
	.wrfull(SYNTHESIZED_WIRE_9),
	.rdempty(SYNTHESIZED_WIRE_6),
	.q(SYNTHESIZED_WIRE_8));


ClockGen_9p6k	ClockGen_9p6k_inst1(
	.clk_50(CLOCK_50),
	.clk_9p6k(SYNTHESIZED_WIRE_11));


SimpleWriteOnly_UART	SimpleWriteOnly_UART_inst3(
	.TX_CLK(SYNTHESIZED_WIRE_11),
	.rdempty(SYNTHESIZED_WIRE_6),
	.rst(SYNTHESIZED_WIRE_12),
	.data_in(SYNTHESIZED_WIRE_8),
	.rdreq(SYNTHESIZED_WIRE_1),
	.TX(TX));


Reset_Gen	Reset_Gen_inst4(
	.clk_50(CLOCK_50),
	.rst_n(SYNTHESIZED_WIRE_12));


FIFO_Loader	FIFO_Loader_inst5(
	.clk(CLOCK_50),
	.wrfull(SYNTHESIZED_WIRE_9),
	.rst(SYNTHESIZED_WIRE_12),
	.wrreq(SYNTHESIZED_WIRE_0),
	.data(SYNTHESIZED_WIRE_4));


endmodule

