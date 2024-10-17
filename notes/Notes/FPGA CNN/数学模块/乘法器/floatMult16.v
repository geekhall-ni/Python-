`timescale 100 ns / 10 ps
//计算两个fp16数的相乘 阶码相加 尾数相乘 规格化 判断溢出
module floatMult16 (floatA,floatB,product);

input [15:0] floatA, floatB;
output reg [15:0] product;

reg sign;
reg signed [5:0] exponent; //1 10001 有符号数 第六个是标志位 其余五个是指数位          符号数进行比较时加上signed，即可考虑数值正负
reg [9:0] mantissa; //有效精度，尾数
reg [10:0] fractionA, fractionB;	//fraction = {1,mantissa}
reg [21:0] fraction;


always @ (floatA or floatB) begin
//================================================特殊情况
	if (floatA == 0 || floatB == 0) 
		begin
			product = 0;
		end 
	else 
//=========================================================非特殊情况	
		begin
		sign = floatA[15] ^ floatB[15];   // 异或 得到符号位
		exponent = floatA[14:10] + floatB[14:10] - 5'd15 + 5'd2;  //阶码相加 5'd15:5代表位宽 d代表十进制 15代表数值 01111 同理 5'd2:00010
	
		fractionA = {1'b1,floatA[9:0]}; //拼接 加上最高的隐藏位1
		fractionB = {1'b1,floatB[9:0]}; //尾数相乘
		fraction = fractionA * fractionB;
		
//=================================================规格化
		if (fraction[21] == 1'b1) begin
			fraction = fraction << 1;
			exponent = exponent - 1; 
		end else if (fraction[20] == 1'b1) begin
			fraction = fraction << 2;
			exponent = exponent - 2;
		end else if (fraction[19] == 1'b1) begin
			fraction = fraction << 3;
			exponent = exponent - 3;
		end else if (fraction[18] == 1'b1) begin
			fraction = fraction << 4;
			exponent = exponent - 4;
		end else if (fraction[17] == 1'b1) begin
			fraction = fraction << 5;
			exponent = exponent - 5;
		end else if (fraction[16] == 1'b1) begin
			fraction = fraction << 6;
			exponent = exponent - 6;
		end else if (fraction[15] == 1'b1) begin
			fraction = fraction << 7;
			exponent = exponent - 7;
		end else if (fraction[14] == 1'b1) begin
			fraction = fraction << 8;
			exponent = exponent - 8;
		end else if (fraction[13] == 1'b1) begin
			fraction = fraction << 9;
			exponent = exponent - 9;
		end else if (fraction[12] == 1'b0) begin
			fraction = fraction << 10;
			exponent = exponent - 10;
		end 
	
		mantissa = fraction[21:12];
		if(exponent[5]==1'b1) begin //exponent是负数
			product=16'b0000000000000000;
		end
		else begin
			product = {sign,exponent[4:0],mantissa};
		end
	end
end

endmodule
