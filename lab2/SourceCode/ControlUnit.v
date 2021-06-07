`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: ControlUnit
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: RISC-V Instruction Decoder
//////////////////////////////////////////////////////////////////////////////////
//功能和接口说�?
    //ControlUnit       是本CPU的指令译码器，组合�?�辑电路
//输入
    // Op               是指令的操作码部�?
    // Fn3              是指令的func3部分
    // Fn7              是指令的func7部分
//输出
    // JalD==1          表示Jal指令到达ID译码阶段
    // JalrD==1         表示Jalr指令到达ID译码阶段
    // RegWriteD        表示ID阶段的指令对应的寄存器写入模�?
    // MemToRegD==1     表示ID阶段的指令需要将data memory读取的�?�写入寄存器,
    // MemWriteD        �?4bit，为1的部分表示有效，对于data memory�?32bit字按byte进行写入,MemWriteD=0001表示只写入最�?1个byte，和xilinx bram的接口类�?
    // LoadNpcD==1      表示将NextPC输出到ResultM
    // RegReadD         表示A1和A2对应的寄存器值是否被使用到了，用于forward的处�?
    // BranchTypeD      表示不同的分支类型，�?有类型定义在Parameters.v�?
    // AluContrlD       表示不同的ALU计算功能，所有类型定义在Parameters.v�?
    // AluSrc2D         表示Alu输入�?2的�?�择
    // AluSrc1D         表示Alu输入�?1的�?�择
    // ImmType          表示指令的立即数格式
//实验要求  
    //补全模块  

`include "Parameters.v"   
module ControlUnit(
    input wire [6:0] Op,
    input wire [2:0] Fn3,
    input wire [6:0] Fn7,
    output wire JalD,
    output wire JalrD,
    output reg [2:0] RegWriteD,
    output wire MemToRegD,
    output reg [3:0] MemWriteD,
    output wire LoadNpcD,
    output reg [1:0] RegReadD,
    output reg [2:0] BranchTypeD,
    output reg [3:0] AluContrlD,
    output wire [1:0] AluSrc2D,		//0:ForwardData2 1:Rs2E 2:Imm
    output wire AluSrc1D, 			//1:PC 0:ForwardData1
	output wire ResultCtrlD,
	output reg [2:0] MuxcD,
    output reg [2:0] ImmType,
    output wire CSRWriteD,
    output wire CSRRead        
    ); 
    
	assign AluSrc1D = (Op == 7'b0010111) ? 1:0;	
	assign AluSrc2D = ((Op == 7'b0010011)&&(Fn3[1:0] == 2'b01)) ? (2'b01) : (((Op == 7'b0110011)||(Op == 7'b1100011)) ? 2'b00 : 2'b10);
	assign JalD = (Op == 7'b1101111) ? 1:0;
    assign JalrD = (Op == 7'b1100111) ? 1:0;
    assign MemToRegD = (Op == 7'b0000011) ? 1:0; 
	assign LoadNpcD = ((Op == 7'b1101111)||(Op == 7'b1100111)) ? 1:0;
	assign ResultCtrlD = (Op == 7'b1110011) ? 1:0;	//choose regwrite
	assign CSRWriteD = (Op == 7'b1110011) ? 1:0;
	assign CSRRead = (Op == 7'b1110011) ? 1:0;
	
	always@(*)
	begin
		case(Op)
			7'b0010011:	 //立即数指�?	
				begin
					RegWriteD <= `LW;
					MemWriteD <= 0;
					ImmType <= `ITYPE;
					RegReadD <= 2'b10;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
					case(Fn3)
						3'b000:	//ADDI
							AluContrlD <= `ADD;
						3'b001:	//SLLI
							AluContrlD <= `SLL;
						3'b010:	//SLTI
							AluContrlD <= `SLT;
						3'b011:	//SLTUI
							AluContrlD <= `SLTU;
						3'b100:	//XORI
							AluContrlD <= `XOR;
						3'b101:	//SRLI or SRAI
							begin
								if(Fn7 == 7'b0)
									AluContrlD <= `SRL;	
								else
									AluContrlD <= `SRA;
							end
						3'b110:	//ORI
							AluContrlD <= `OR;
						3'b111:	//ANDI
							AluContrlD <= `AND;
					endcase	
				end
			7'b0110011:	//R-TYPE
				begin
					RegWriteD <= `LW;
					MemWriteD <= 0;
					ImmType <= `RTYPE;
					RegReadD <= 2'b11;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
					case(Fn3)
						3'b000:	//ADD or SUB
						  begin
							if(Fn7 == 7'b0)
								AluContrlD <= `ADD;	
							else
								AluContrlD <= `SUB;
						  end
						3'b001:	//SLL
							AluContrlD <= `SLL;
						3'b010:	//SLT
							AluContrlD <= `SLT;
						3'b011:	//SLTU
							AluContrlD <= `SLTU;
						3'b100:	//XOR
							AluContrlD <= `XOR;
						3'b101:	//SRL or SRA
							begin
								if(Fn7 == 7'b0)
									AluContrlD <= `SRL;
								else
									AluContrlD <= `SRA;
							end
						3'b110:	//OR
							AluContrlD <= `OR;
						3'b111:	//AND
							AluContrlD <= `AND;
					endcase
				end
			7'b0110111:	//LUI
				begin
					RegWriteD <= `LW;
					MemWriteD <= 0;
					AluContrlD <= `LUI;
					ImmType <= `UTYPE;
					RegReadD <= 2'b00;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
				end
			7'b0010111:	//AUIPC
				begin
					RegWriteD <= `LW;
					MemWriteD <= 0;
					AluContrlD <= `ADD;
					ImmType <= `UTYPE;	
					RegReadD <= 2'b00;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
				end
			7'b1101111:	//JAL
				begin
					RegWriteD <= `LW;
					MemWriteD <= 0;
					AluContrlD <= `ADD;
					ImmType <= `JTYPE;
					RegReadD <= 2'b00;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
				end
			7'b1100111: //JALR
				begin
					RegWriteD <= `LW;
					MemWriteD <= 0;
					AluContrlD <= `ADD;
					ImmType <= `ITYPE;
					RegReadD <= 2'b10;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
				end
			7'b1100011:	//Branch
				begin
				    RegWriteD <= `NOREGWRITE;
					MemWriteD <= 0;
					ImmType <= `BTYPE;	
					RegReadD <= 2'b11;
					MuxcD <= 3'b000;
					case(Fn3)
						3'b000:	//BEQ
							BranchTypeD <= `BEQ;
						3'b001:	//BNE
							BranchTypeD <= `BNE;
						3'b100:	//BLT
							BranchTypeD <= `BLT;
						3'b101:	//BGE
							BranchTypeD <= `BGE;
						3'b110:	//BLTU
							BranchTypeD <= `BLTU;
						3'b111:	//BGEU
							BranchTypeD <= `BGEU;
						default:;
					endcase
				end
			7'b0000011:	//LOAD
				begin
					MemWriteD <= 0;
					AluContrlD <= `ADD;
					ImmType <= `ITYPE;
					RegReadD <= 2'b10;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
					case(Fn3)
						3'b000:	//LB
							RegWriteD <= `LB;
						3'b001:	//LH
							RegWriteD <= `LH;
						3'b010:	//LW
							RegWriteD <= `LW;
						3'b100: //LBU
							RegWriteD <= `LBU;
						3'b101: //LHU
							RegWriteD <= `LHU;
						default:;
					endcase
				end
			7'b0100011:	//STORE
				begin
					RegWriteD <= `NOREGWRITE;
					AluContrlD <= `ADD;
					ImmType <= `STYPE; 
					RegReadD <= 2'b11;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
					case(Fn3)
						3'b000:	//SB
							MemWriteD <= 4'b0001;
						3'b001:	//SH
							MemWriteD <= 4'b0011;
						3'b010:	//SW
							MemWriteD <= 4'b1111;
						default:;
					endcase
				end
			7'b1110011:	//CSR
				begin
					RegWriteD <= `LW;
					ImmType <= `CTYPE;
					MemWriteD <= 0;
					RegReadD <= 2'b10;
					BranchTypeD <= `NOBRANCH;
					case(Fn3)
						3'b001:	//CSRRW
							begin
								AluContrlD <= `ADD;
								MuxcD <= 3'b001;
							end
						3'b010:	//CSRRS
							begin
								AluContrlD <= `OR;
								MuxcD <= 3'b011;
							end
						3'b011:	//CSRRC
							begin
								AluContrlD <= `NOR;
								MuxcD <= 3'b011;
							end
						3'b101:	//CSRRWI
							begin
								AluContrlD <= `ADD;
								MuxcD <= 3'b010;
							end
						3'b110:	//CSRRSI
							begin
								AluContrlD <= `OR;
								MuxcD <= 3'b100;
							end
						3'b111:	//CSRRCI
							begin
								AluContrlD <= `NOR;
								MuxcD <= 3'b100;
							end
					endcase
				end
			default:	//NOP
				begin
					RegWriteD <= `NOREGWRITE;
					MemWriteD <= 0;
					AluContrlD <= `ADD;
					ImmType <= `RTYPE;
					RegReadD <= 2'b00;
					BranchTypeD <= `NOBRANCH;
					MuxcD <= 3'b000;
				end
		endcase
	end
endmodule

