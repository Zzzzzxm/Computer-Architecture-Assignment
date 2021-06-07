`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: USTC ESLAB 
// Engineer: Wu Yuzhang
// 
// Design Name: RISCV-Pipline CPU
// Module Name: NPC_Generator
// Target Devices: Nexys4
// Tool Versions: Vivado 2017.4.1
// Description: Choose Next PC value
//////////////////////////////////////////////////////////////////////////////////
//功能说明
    //NPC_Generator是用来生成Next PC值的模块，根据不同的跳转信号选择不同的新PC�?
//输入
    //PCF              旧的PC�?
    //JalrTarget       jalr指令的对应的跳转目标
    //BranchTarget     branch指令的对应的跳转目标
    //JalTarget        jal指令的对应的跳转目标
    //BranchE==1       Ex阶段的Branch指令确定跳转
    //JalD==1          ID阶段的Jal指令确定跳转
    //JalrE==1         Ex阶段的Jalr指令确定跳转
//输出
    //PC_In            NPC的�??
//实验要求  
    //补全模块  

module NPC_Generator(
    input wire [31:0] PCF, JalrTarget, BranchTarget, JalTarget, PredictedTargetF, PCE,
    input wire BranchE, JalD, JalrE, PredictedE, PredictedF, PredictedTE,PredictedTF,
    output reg [31:0] PC_In
    );
    
	always@(*)
	begin
		if(JalrE)
			PC_In <= JalrTarget;
		else if(BranchE && (~PredictedE || (PredictedE && ~PredictedTE)))		//预测不跳转但跳转，NPC为跳转地�?
			PC_In <= BranchTarget;
		else if(~BranchE && (PredictedE && PredictedTE))		//预测跳转但不跳转，NPC为原本的PC+4
			PC_In <= PCE + 4;
		else if(JalD)
			PC_In <= JalTarget;
		else if(PredictedF && PredictedTF)					//预测跳转，NPC为预测跳转的地址
			PC_In <= PredictedTargetF;
		else
			PC_In <= PCF + 4;
	end
    // 请补全此处代�?
    
endmodule