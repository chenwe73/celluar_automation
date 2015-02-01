// FSM

module FSM 	(Clock, Resetn, clear, draw, 
				xClear, yClear, xCountDraw, yCountDraw,
				CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
				CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, 
				Enable, isDraw);
	// define input and output ports
	input Clock, Resetn;
	input clear, draw;
	input [8:0] xClear;
	input [7:0] yClear;
	input [8:0] xCountDraw;
	input [7:0] yCountDraw;
	output CXC_Resetn, CXC_Enable, CYC_Resetn, CYC_Enable, 
			 CXD_Resetn, CXD_Enable, CYD_Resetn, CYD_Enable, 
			 Enable, isDraw;
	reg [4:0] y_Q;
	reg [4:0] Y_D; // y_Q represents current state, Y_D represents next state
	parameter Idle = 5'b00001, Clear_IterX = 5'b00010, Clear_IncY = 5'b00100, Draw_IterX = 5'b01000, Draw_IncY = 5'b10000;
	parameter xScreen = 160-1, yScreen = 120-1;
	parameter xDraw = 10-1, yDraw = 40-1;
	
	always @(*)
	begin: state_table
		case (y_Q)
			Idle: 		if (clear) 				Y_D = Clear_IterX;
							else if (draw)			Y_D = Draw_IterX;
							else						Y_D = Idle;
							
			Clear_IterX:if (xClear < xScreen)Y_D = Clear_IterX;
							else 						Y_D = Clear_IncY;
							
			Clear_IncY:	if (yClear < yScreen)Y_D = Clear_IterX;
							else						Y_D = Idle;
							
			Draw_IterX: if (xCountDraw<xDraw)Y_D = Draw_IterX;
							else						Y_D = Draw_IncY;
							
			Draw_IncY: 	if (yCountDraw<yDraw)Y_D = Draw_IterX;
							else						Y_D = Idle;
			
			default: Y_D = 5'bxxxxx;
		endcase
	end // state_table
	
	
	always @(posedge Clock)
	begin: state_FFs
		if (Resetn == 0)
			y_Q <= Idle;
		else
			y_Q <= Y_D;
	end // state_FFS
	
	// assignments for output z and the LEDs
	assign CXC_Resetn = (y_Q != Clear_IncY);
	assign CXC_Enable = (y_Q == Clear_IterX);
	assign CYC_Resetn = (y_Q != Idle);
	assign CYC_Enable = (y_Q == Clear_IncY);
	assign CXD_Resetn = (y_Q != Draw_IncY);
	assign CXD_Enable = (y_Q == Draw_IterX);
	assign CYD_Resetn = (y_Q != Idle);
	assign CYD_Enable = (y_Q == Draw_IncY);
	assign Enable = (y_Q == Clear_IterX) || (y_Q == Draw_IterX);
	assign isDraw = (y_Q == Draw_IterX)  || (y_Q == Draw_IncY);
	
endmodule
