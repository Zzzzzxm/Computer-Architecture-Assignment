module BTB#(
	parameter BUFFER_ADDR_LEN = 12
)(
	input clk, rst,
	input [31:0] PCF,
	output reg PredictedF,
	output reg [31:0] PredictedTargetF,
	input [31:0] PCE,
	input [31:0] BrNPC,
	input BranchE
);

localparam TAG_ADDR_LEN = 32 - BUFFER_ADDR_LEN - 2;

localparam BUFFER_SIZE  = 1 << BUFFER_ADDR_LEN;

reg [            31:0] Predicted_mem    [BUFFER_SIZE]; 
reg [TAG_ADDR_LEN-1:0] Predicted_tags   [BUFFER_SIZE];            

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
	if((tag_addr_F == Predicted_tags[buffer_addr_F]))
	begin
		PredictedF = 1;
		PredictedTargetF = Predicted_mem[buffer_addr_F];
	end
	else
	begin
		PredictedF = 0;
		PredictedTargetF = Predicted_mem[buffer_addr_F];
	end	
end

always@(posedge clk or posedge rst) 
	begin
	if(rst) 
	begin
		for(integer i = 0; i < BUFFER_SIZE; i++)
		begin
			Predicted_mem[i]  = 0;
			Predicted_tags[i] = 0; 
		end
		PredictedF <= 0;
		PredictedTargetF <= 0;
	end
	else begin
		if(BranchE)
		begin
			Predicted_mem[buffer_addr_E]  = BrNPC  		;
			Predicted_tags[buffer_addr_E] = tag_addr_E  ;
		end
	end
end

endmodule
		
			
         