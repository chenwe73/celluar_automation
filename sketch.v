// Etch-and-sketch

module sand
	(
		CLOCK_50,						//	On Board 50 MHz
		KEY,								//	Push Button[3:0]
		SW,								//	DPDT Switch[17:0]
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   							//	VGA Blue[9:0]
		LEDR,
		LEDG
	);

	input				CLOCK_50;				//	50 MHz
	input		[3:0]	KEY;						//	Button[3:0]
	input		[17:0]SW;						//	Switches[0:0]
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output 	[17:0]LEDR;
	output 	[7:0] LEDG;
	
	wire resetn;
	assign resetn = KEY[3]; // changed?
	assign LEDR = SW;
	
	// Create the color, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] color;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(color),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "<your background image>";
			
	// Put your code here. Your code should produce signals x,y,color and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	
	wire Clock, Resetn;
	wire clear, draw;
	wire [8:0] xClear;
	wire [7:0] yClear;
	wire [8:0] xCountDraw;
	wire [7:0] yCountDraw;
	wire CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
			CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, 
			Enable, isDraw;
	
	wire [2:0] colorOut;
	wire [8:0] xCoord;
	wire [7:0] yCoord;
	
	assign Clock = CLOCK_50;
	assign Resetn = resetn;
	assign clear = ~KEY[2]; // active-low
	assign color = colorOut;
	assign x = xCoord[7:0];
	assign y = yCoord[6:0];
	assign writeEn = Enable;
	
	wire G_Clock, G_Resetn;
	wire [1:0] seedSel;
	assign G_Resetn = SW[0];
	assign seedSel = SW[17:16];
	
	wire T;
	TFlipFlop GTFF (G_Clock, T);
	assign LEDG[0] = T;
	
	
	FSM U1 	(Clock, Resetn, clear, G_Clock, 
				xClear, yClear, xCountDraw, yCountDraw,
				CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
				CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, 
				Enable, isDraw);
	
	Datapath D1 (Clock, seedSel,
					CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
					CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, isDraw, 
					xClear, yClear, xCountDraw, yCountDraw, 
					colorOut, xCoord, yCoord, 
					G_Clock, G_Resetn);
	
endmodule