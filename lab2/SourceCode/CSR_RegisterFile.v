module CSR_RegisterFile(
    input wire clk,
    input wire rst,
    input wire WE,
    input wire [4:0] A,
    input wire [4:0] B,
    input wire CSRRead,
    input wire [31:0] WD,
    output reg [31:0] RD
    );

    reg [31:0] CSR[31:0];
    integer i;
    //
    always@(negedge clk or posedge rst) 
    begin 
        if(rst)                                 for(i=0;i<32;i=i+1) CSR[i][31:0]<=32'b0;
        else if(WE)    CSR[B]<=WD;   
    end
    //  
	always@(*)
	begin
		if(!clk && CSRRead)
			RD <= CSR[A];
	end
    
endmodule