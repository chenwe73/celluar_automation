// Falling Sand

module test (KEY, SW, LEDR, LEDG);
	input [1:0] KEY;
	input [17:0] SW;
	output [17:0] LEDR;
	output [1:0] LEDG;
	
	parameter [3:0] const = 4'b0001;
	
	assign LEDR = SW;
	LFSR R (KEY[0], KEY[1], const, LEDG[0]);

endmodule

module game (Clock, Resetn, x, y, seedSel, out);
	input Clock, Resetn;
	input [8:0] x;
	input [7:0] y;
	input [1:0] seedSel;
	output reg [2:0]out;
	// state matrix
	parameter ySize = 40-1;
	parameter xSize = 10-1;
	reg [2:0] current [0:ySize][0:xSize];
	reg [2:0] next [0:ySize][0:xSize]; 
	// cell variable
	parameter Atom0 = 3'b001;
	parameter Atom1 = 3'b101;
	parameter AirV  = 3'b000;
	parameter WallV = 3'b011;
	// cell type
	parameter atom = 2'b01;
	parameter air  = 2'b00;
	parameter wall = 2'b11;
	// external modules
	wire T;
	TFlipFlop TFF (Clock, T);
	/*wire rand;
	reg Rloadn;
	parameter [3:0] RandSeed = 4'b0110;
	LFSR R (Clock, Rloadn, RandSeed, rand);*/
	
	// seed
	wire [2:0] seed [0:ySize][0:xSize];
	
	
	
	// computing next state
	always @ (*)
	begin
		integer y;
		integer x;
		
		if (T) // even partition
		begin
			for (y = 0; y <= ySize-1; y = y+2)
			begin
				for (x = 0; x <= xSize-1; x = x+2)
				begin
					case ({current[y][x][1:0], current[y][x+1][1:0], current[y+1][x][1:0], current[y+1][x+1][1:0]})
						{atom, air, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, air};		// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{air, atom, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, air, atom};		// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, air, atom, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// a topple
															= {current[y+1][x+1], current[y][x+1], current[y+1][x], current[y][x]};
						{atom, air, air, atom}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{air, atom, atom, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{air, atom, air, atom}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// b topple
															= {current[y][x], current[y+1][x], current[y][x+1], current[y+1][x+1]};
						{atom, atom, atom, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {atom, air, atom, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, atom, air, atom}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, atom, atom, atom};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{atom, atom, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// a fall, b fall
															= {current[y+1][x], current[y+1][x+1], current[y][x], current[y][x+1]};
						// 2 walls, 1 atom
						{wall, atom, wall, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {wall, air, wall, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, wall, air, wall}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, wall, atom, wall};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						// 1 wall, 1 atom
						{wall, atom, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {wall, air, air, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, wall, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, wall, atom, air};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{air, atom, wall, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, wall, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, air, air, wall}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, wall};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{atom, air, wall, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, wall, atom};	// a topple
															= {current[y+1][x+1], current[y][x+1], current[y+1][x], current[y][x]};
						{air, atom, air, wall}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, wall};	// b topple
															= {current[y][x], current[y+1][x], current[y][x+1], current[y+1][x+1]};
						// 1 wall, 2 atom
						{wall, atom, atom, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {wall, air, atom, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, wall, air, atom}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, wall, atom, atom};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{atom, atom, wall, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {atom, air, wall, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, atom, air, wall}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, atom, atom, wall};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						default: 						{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} // no change
															= {current[y][x], current[y][x+1], current[y+1][x], current[y+1][x+1]};
					endcase
				end
			end
		end
		else // odd partition
		begin
			for (y = 1; y <= ySize-1; y = y+2)
			begin
				for (x = 1; x <= xSize-1; x = x+2)
				begin
					case ({current[y][x][1:0], current[y][x+1][1:0], current[y+1][x][1:0], current[y+1][x+1][1:0]})
						{atom, air, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, air};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{air, atom, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, air, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, air, atom, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// a topple
															= {current[y+1][x+1], current[y][x+1], current[y+1][x], current[y][x]};
						{atom, air, air, atom}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{air, atom, atom, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{air, atom, air, atom}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// b topple
															= {current[y][x], current[y+1][x], current[y][x+1], current[y+1][x+1]};
						{atom, atom, atom, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {atom, air, atom, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, atom, air, atom}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, atom, atom, atom};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{atom, atom, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, atom};	// a fall, b fall
															= {current[y+1][x], current[y+1][x+1], current[y][x], current[y][x+1]};
						// 2 walls, 1 atom
						{wall, atom, wall, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {wall, air, wall, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, wall, air, wall}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, wall, atom, wall};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						// 1 wall, 1 atom
						{wall, atom, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {wall, air, air, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, wall, air, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, wall, atom, air};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{air, atom, wall, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, wall, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, air, air, wall}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, wall};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{atom, air, wall, air}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, wall, atom};	// a topple
															= {current[y+1][x+1], current[y][x+1], current[y+1][x], current[y][x]};
						{air, atom, air, wall}:		{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, air, atom, wall};	// b topple
															= {current[y][x], current[y+1][x], current[y][x+1], current[y+1][x+1]};
						// 1 wall, 2 atom
						{wall, atom, atom, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {wall, air, atom, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, wall, air, atom}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, wall, atom, atom};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						{atom, atom, wall, air}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {atom, air, wall, atom};	// b fall
															= {current[y][x], current[y+1][x+1], current[y+1][x], current[y][x+1]};
						{atom, atom, air, wall}:	{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} //= {air, atom, atom, wall};	// a fall
															= {current[y+1][x], current[y][x+1], current[y][x], current[y+1][x+1]};
						default: 						{next[y][x], next[y][x+1], next[y+1][x], next[y+1][x+1]} // no change
															= {current[y][x], current[y][x+1], current[y+1][x], current[y+1][x+1]};
					endcase
				end
			end
		end
	end
	
	// register
	always @(posedge Clock)
	begin
		integer y;
		integer x;
		
		if (Resetn == 1'b0)
		begin
			// seeding
			for (y = 0; y <= ySize; y = y+1)
				for (x = 0; x <= xSize; x = x+1)
					current[y][x] <= 3'b000;
			// wall 4 sides
			for (x = 0; x <= xSize; x = x+1)
			begin
				current[0][x] 		<= WallV;
				current[ySize][x] <= WallV;
			end
			for (y = 0; y <= ySize; y = y+1)
			begin
				current[y][0] 		<= WallV;
				current[y][xSize] <= WallV;
			end
			
			// extra walls
			current[4][4] <= WallV;
			current[4][5] <= WallV;
			current[5][3] <= WallV;
			current[5][6] <= WallV;
			current[6][2] <= WallV;
			current[6][7] <= WallV;


			current[10][3] <= WallV;
			current[10][6] <= WallV;
			current[11][3] <= WallV;
			current[11][6] <= WallV;
			current[12][3] <= WallV;
			current[12][6] <= WallV;
			current[13][2] <= WallV;
			current[13][7] <= WallV;
			current[14][1] <= WallV;
			current[14][8] <= WallV;

			current[19][3] <= WallV;
			current[19][4] <= WallV;
			current[19][5] <= WallV;
			current[19][6] <= WallV;

			current[24][1] <= WallV;
			current[24][8] <= WallV;
			current[25][2] <= WallV;
			current[25][7] <= WallV;
			current[26][3] <= WallV;
			current[26][6] <= WallV;
			current[27][4] <= WallV;
			
			//Rloadn <= 1'b0;
		end
		
		else
		begin
			// updating
			for (y = 0; y <= ySize; y = y+1)
				for (x = 0; x <= xSize; x = x+1)
					current[y][x] <= next[y][x];
			
			// continuous seeding
			if (seedSel[1] == 1'b1)
				current[1][3] <= Atom0;
			if (seedSel[0] == 1'b1)
				current[1][6] <= Atom1;
			
			//Rloadn <= 1'b1;
		end
	end
	
	// output
	always @(*)
	begin
		if (y <= ySize && x <= xSize)
			out = current[y][x];
		else
			out = 3'b0;
	end
	
endmodule
