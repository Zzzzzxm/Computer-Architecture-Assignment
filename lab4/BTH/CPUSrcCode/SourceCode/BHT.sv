module BHT#(
	parameter BUFFER_ADDR_LEN = 12
)(
	input clk,rst,
	input [31:0] PCF,
	output reg PredictedTF,
	input BranchE,
	input Branch,
	input [31:0] PCE
);

localparam BUFFER_SIZE = 1 << BUFFER_ADDR_LEN;

localparam TAG_ADDR_LEN = 32 - BUFFER_ADDR_LEN - 2;

reg [            1:0] Predicted_state    [BUFFER_SIZE]; 

wire [              2-1:0]   word_addr_F    ;                   
wire [BUFFER_ADDR_LEN-1:0]   buffer_addr_F  ;
wire [   TAG_ADDR_LEN-1:0]   tag_addr_F     ;

wire [              2-1:0]   word_addr_E    ;                   
wire [BUFFER_ADDR_LEN-1:0]   buffer_addr_E  ;
wire [   TAG_ADDR_LEN-1:0]   tag_addr_E     ;

assign {tag_addr_E, buffer_addr_E, word_addr_E} = PCE;
assign {tag_addr_F, buffer_addr_F, word_addr_F} = PCF;

always@(*)
begin
	if((Predicted_state[buffer_addr_F] == 2'b11) || (Predicted_state[buffer_addr_F] == 2'b10))
		PredictedTF = 1;
	else
		PredictedTF = 0;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		for(integer i = 0;i < BUFFER_SIZE;i++)
		begin
			Predicted_state[i] = 2'b00;
		end
		PredictedTF <= 0;
	end
	else if(Branch)
	begin
		case(Predicted_state[buffer_addr_E])
			2'b11:	begin
						if(!BranchE)
							Predicted_state[buffer_addr_E] <= 2'b10;
					end
			2'b10:	begin
						if(BranchE)
							Predicted_state[buffer_addr_E] <= 2'b11;
						else
							Predicted_state[buffer_addr_E] <= 2'b01;
					end
			2'b01:	begin
						if(BranchE)
							Predicted_state[buffer_addr_E] <= 2'b10;
						else
							Predicted_state[buffer_addr_E] <= 2'b00;
					end
			2'b00:	begin
						if(BranchE)
							Predicted_state[buffer_addr_E] <= 2'b01;
					end
		endcase
	end
end

endmodule
		
		