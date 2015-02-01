// Datapath

module Datapath  (Clock, seedSel,
						CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
						CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, isDraw, 
						xClear, yClear, xCountDraw, yCountDraw, 
						colorOut, xCoord, yCoord, 
						G_Clock, G_Resetn);
	
	parameter [8:0] xStartDraw = 9'd70;
	parameter [7:0] yStartDraw = 8'd40;
	
	input Clock, 
			CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
			CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, isDraw;
	
	output [8:0] xClear;
	output [7:0] yClear;
	output [8:0] xCountDraw;
	output [7:0] yCountDraw;
	output [2:0] colorOut;
	output reg [8:0] xCoord;
	output reg [7:0] yCoord;
	
	wire [8:0] xCoordDraw;
	wire [7:0] yCoordDraw;
	
	wire [2:0] state;
	input [2:0] seedSel;
	input G_Resetn;
	wire DC_Load;
	output G_Clock;
	
	CounterX_Clear CXC (Clock, CXC_Resetn, CXC_Enable, xClear);
	CounterY_Clear CYC (Clock, CYC_Resetn, CYC_Enable, yClear);
	CounterX_Draw CXD (Clock, CXD_Resetn, CXD_Enable, xCountDraw);
	CounterY_Draw CYD (Clock, CYD_Resetn, CYD_Enable, yCountDraw);
	
	adder_9size XD (xStartDraw, xCountDraw, xCoordDraw);
	adder_8size YD (yStartDraw, yCountDraw, yCoordDraw);
	
	color C (state, isDraw, colorOut);
	downCounter DC (Clock, ~DC_Load, G_Clock);
	DFlipFlop (Clock, G_Clock, DC_Load);
	game G (G_Clock, G_Resetn, xCountDraw, yCountDraw, seedSel, state);
	
	always @ (*)
	begin
		if (isDraw)
		begin
			xCoord = xCoordDraw;
			yCoord = yCoordDraw;
		end
		else
		begin
			xCoord = xClear;
			yCoord = yClear;
		end
	end
	
endmodule


module CounterX_Clear (Clock, Resetn, Enable, Q);
	parameter size = 9;
	input Enable, Resetn, Clock;
	output reg [size-1:0] Q;
	
	always @ (posedge Clock)
	begin
		if (Resetn == 0)
			Q <= 0;
		else if (Enable == 1)
			Q <= Q + 1;
	end
	
endmodule


module CounterY_Clear (Clock, Resetn, Enable, Q);
	parameter size = 8;
	input Enable, Resetn, Clock;
	output reg [size-1:0] Q;
	
	always @ (posedge Clock)
	begin
		if (Resetn == 0)
			Q <= 0;
		else if (Enable == 1)
			Q <= Q + 1;
	end
	
endmodule


module CounterX_Draw (Clock, Resetn, Enable, Q);
	parameter size = 9;
	input Enable, Resetn, Clock;
	output reg [size-1:0] Q;
	
	always @ (posedge Clock)
	begin
		if (Resetn == 0)
			Q <= 0;
		else if (Enable == 1)
			Q <= Q + 1;
	end
	
endmodule


module CounterY_Draw (Clock, Resetn, Enable, Q);
	parameter size = 8;
	input Enable, Resetn, Clock;
	output reg [size-1:0] Q;
	
	always @ (posedge Clock)
	begin
		if (Resetn == 0)
			Q <= 0;
		else if (Enable == 1)
			Q <= Q + 1;
	end
	
endmodule


module adder_9size (start, count, coord);
	parameter size = 9;
	input [size-1:0] start; 
	input [9:0] count;
	output reg [size-1:0] coord;
	
	always @(*)
	begin
		coord = start + count;
	end
	
endmodule


module adder_8size (start, count, coord);
	parameter size = 8;
	input [size-1:0] start; 
	input [8:0] count;
	output reg [size-1:0] coord;
	
	always @(*)
	begin
		coord = start + count;
	end
	
endmodule


module color (state, isDraw, out);
	parameter size = 3;
	parameter black = 3'b000;
	parameter white = 3'b111;
	parameter green = 3'b010;
	parameter blue  = 3'b001;
	parameter red   = 3'b100;
	// cell variable
	parameter Atom0 = 3'b001;
	parameter Atom1 = 3'b101;
	parameter AirV  = 3'b000;
	parameter WallV = 3'b011;
	
	input [2:0] state;
	input isDraw;
	output reg [size-1:0] out;
	
	always @ (*)
	begin
		if (!isDraw)
			out = white;
		else
		begin
			if (state == AirV)
				out = white;
			else if (state == WallV)
				out = black;
			else if (state == Atom0)
				out = red;
			else if (state == Atom1)
				out = blue;
		end
	end
	
endmodule

// Timer
module downCounter (Clock, Loadn, Pulse);
	parameter bit = 26;
	parameter n = 26'd5000000;
	input Loadn, Clock;
	output reg Pulse;
	reg [bit-1:0] Q;
	
	always @ (posedge Clock)
	begin
		if (Loadn == 0)
			Q <= n;
		else
			Q <= Q - 1;
	end
	
	always @(posedge Clock)
	begin
		if (Q == 0)
		begin
			Pulse <= 1;
		end
		else
			Pulse <= 0;
	end
	
endmodule


// D Flip Flop
module DFlipFlop (clk, d, q);
	input clk, d;
	output q;
	reg q;
	
	always @(posedge clk)
	begin
		q <= d;
	end
	
endmodule


// T-flip-flop
module TFlipFlop (clock, T);
	input clock;
	output reg T;
	
	always @ (posedge clock)
	begin
		T <= ~T;
	end
	
endmodule


// Linear Feedback Shift Register
module LFSR (clock, loadn, load, out);
	parameter size = 4-1;
	input clock, loadn;
	input [size:0] load;
	output out;
	
	reg [size:0] current;
	
	always @ (posedge clock, negedge loadn)
	begin
		if (loadn == 0)
			current <= load;
		else
		begin
			current[0] <= current[2] ^ current[3];
			current[1] <= current[0];
			current[2] <= current[1];
			current[3] <= current[2];
		end
	end
	assign out = current[0];
	
endmodule
