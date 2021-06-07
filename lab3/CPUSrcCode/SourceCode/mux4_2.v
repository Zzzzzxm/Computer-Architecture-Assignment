module mux4to2(
	input [31:0] s1,	//rs1
	input [31:0] s2,	//imm
	input [31:0] s3,	//csr
	input [31:0] s4,	//32'b0
	input [2:0]   s,
	output reg [31:0] out1,
	output reg [31:0] out2
);

	always@(*)
	begin
		case(s)
			3'b000:	//NOT CSR
				begin
					out1 <= s1;
					out2 <= s2;
				end
			3'b001:	//CSRRW
				begin
					out1 <= s1;
					out2 <= s4;
				end
			3'b010:	//CSRRWI
				begin
					out1 <= s2;
					out2 <= s4;
				end
			3'b011:	//CSRRC,CSRRS
				begin
					out1 <= s3;
					out2 <= s1;
				end
			3'b100:	//CSRRCI,CSRRSI
				begin
					out1 <= s3;
					out2 <= s2;
				end
			default:;
		endcase
	end
endmodule