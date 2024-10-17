`timescale 100 ns / 10 ps
/*
1.对阶
2.尾数相减
3.规格化
4.判溢出
*/
module floatAdd16 (floatA,floatB,sum);
	
input [15:0] floatA, floatB;//定义两个输入的16位的数 0 10001 0000000000        0 10001 0000000000
output reg [15:0] sum;      //定义相加后输出的16位的数 0 100010 0010000000

reg sign; //符号位 fp16的符号位
reg signed [5:0] exponent; //有符号数 第五位是个标志位
reg [9:0] mantissa;  //有效精度，尾数 未加signed 无符号数
reg [4:0] exponentA, exponentB;  //指数位
reg [10:0] fractionA, fractionB, fraction;	//fraction = {1,mantissa} 加上最高的隐藏位1 变为11位宽
reg [7:0] shiftAmount; //移位
reg cout;

always @ (floatA or floatB) begin
	exponentA = floatA[14:10];
	exponentB = floatB[14:10];
	fractionA = {1'b1,floatA[9:0]};
	fractionB = {1'b1,floatB[9:0]}; 
	
	exponent = exponentA;
//===============================特殊情况
	if (floatA == 0) 
		begin						//特殊情况 如果floatA = 0 则总和为floatB
			sum = floatB;
		end 
	else if (floatB == 0) 
		begin					//特殊情况 如果floatB = 0 则总和为floatA
			sum = floatA;
		end 
	else if (floatA[14:0] == floatB[14:0] && floatA[15]^floatB[15]==1'b1) //特殊情况 floatA和floatB大小相等 符号相反
			begin  
				sum=0;
			end 
	else 
		begin //对阶 使两个数的阶码相等，小阶向大阶看齐，尾数每右移一位，阶码加1
			if (exponentB > exponentA) 
			begin
				shiftAmount = exponentB - exponentA;
				fractionA = fractionA >> (shiftAmount);
				exponent = exponentB;   //exponent等于大的
			end 
		else if (exponentA > exponentB) 
			begin 
				shiftAmount = exponentA - exponentB;
				fractionB = fractionB >> (shiftAmount);   //fractionB右移
				exponent = exponentA;   //exponent等于大的
			end
		//尾数相加减和规格化
		if (floatA[15] == floatB[15])  //符号位相同
			begin			
				{cout,fraction} = fractionA + fractionB;
				if (cout == 1'b1)  //判断相加后进位
					begin
						{cout,fraction} = {cout,fraction} >> 1; //右移一位
						exponent = exponent + 1;  //指数位加1
					end
				sign = floatA[15];
		end else begin						//符号位不同
			if (floatA[15] == 1'b1) //如果floatA的符号位为1 负 则floatB的符号位是0 正
				begin
					{cout,fraction} = fractionB - fractionA;
				end 
			else 
				begin
					{cout,fraction} = fractionA - fractionB;
				end
			sign = cout;   //尾数相减后如果是正数 则说明整体是正的 如果是负数 则说明整体是负的 而sign也取决于cout
			if (cout == 1'b1) 
				begin   //如果cout=1,则说明fraction是个负数
					fraction = -fraction;
				end 
			else 
				begin
					
				end
			if (fraction [10] == 0) begin
				if (fraction[9] == 1'b1) begin
					fraction = fraction << 1;
					exponent = exponent - 1;
				end else if (fraction[8] == 1'b1) begin
					fraction = fraction << 2;
					exponent = exponent - 2;
				end else if (fraction[7] == 1'b1) begin
					fraction = fraction << 3;
					exponent = exponent - 3;
				end else if (fraction[6] == 1'b1) begin
					fraction = fraction << 4;
					exponent = exponent - 4;
				end else if (fraction[5] == 1'b1) begin
					fraction = fraction << 5;
					exponent = exponent - 5;
				end else if (fraction[4] == 1'b1) begin
					fraction = fraction << 6;
					exponent = exponent - 6;
				end else if (fraction[3] == 1'b1) begin
					fraction = fraction << 7;
					exponent = exponent - 7;
				end else if (fraction[2] == 1'b1) begin
					fraction = fraction << 8;
					exponent = exponent - 8;
				end else if (fraction[1] == 1'b1) begin
					fraction = fraction << 9;
					exponent = exponent - 9;
				end else if (fraction[0] == 1'b1) begin
					fraction = fraction << 10;
					exponent = exponent - 10;
				end 
			end
		end
		mantissa = fraction[9:0];
		if(exponent[5]==1'b1) begin //exponent is negative
			sum = 16'b0000000000000000;
		end
		else begin
			sum = {sign,exponent[4:0],mantissa};
		end		
	end		
end

endmodule
