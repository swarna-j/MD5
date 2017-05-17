`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Nanyang Technological University
// Create Date:    17:02:21 03/11/2017 
// Module Name:    md5 
// Project Name: MD5
// Target Devices: Spartan-6 (xc6slx45-2csg484)
// Description: MD5 Hashing Algorithm
// Dependencies: None
// Revision 0.01 - File Created
// Additional Comments: ES6126 - Algorithms to Architectures - Assignment 2
//////////////////////////////////////////////////////////////////////////////////
`define h0 32'h67452301
`define h1 32'hefcdab89
`define h2 32'h98badcfe
`define h3 32'h10325476

`define INIT 1
`define GROUP_DATA 2
`define ROUND_OPERATION 3
`define EVAL_K 4
`define EVAL_T 5
`define EVAL_S 6
`define ROUND_RESULT 7
`define HALT_ITERATION 8
`define PROCESS_OUTPUT 9 
`define REORDER_OUTPUT 10

module md5(input clk, 			          
           input start,			  
	       input [7:0] data_in, 			  			  	
		   output reg [127:0] digest, 
		   output reg valid);

	reg [1:0] round; //4 rounds - 2 bits
	reg [3:0] phase; // 16 phases - 4bits
	reg [7:0] message[63:0];
	reg [31:0] group[15:0];
	reg [511:0] padded_message = 512'b0; //512 bits
	reg [127:0] word;
	reg [127:0] next_word;
	reg [127:0] out;
	reg [31:0] temp_output[3:0]; //4 bytes
	reg [31:0] reordered_output[3:0]; // {a b c d} are stored as {d c b a} Need to be reversed back
	reg [3:0] p_s; // Present state
    reg [3:0] n_s = `INIT; // Next state - initialized to first state
	reg [31:0] a; 
	reg [31:0] b;
    reg [31:0] c;
    reg [31:0] d;
	reg [31:0] F_res; // Function result
	reg [31:0] round_result;
    reg [3:0] K;
	reg [31:0]T;
	reg [4:0] S;
	reg [5:0] len = 6'b0; // length in bytes - 64 bytes max 
	reg [7:0] total_len; // length in bits
	reg [6:0] i = 7'b0; 
	reg [5:0] j = 6'b0; 
	reg [6:0] k = 7'b0; //to store value upto 64 = 2^6, extra bit to prevent overflow

initial 
begin
   for(i = 0; i < 64; i=i+1)
	  message[i][7:0] = 8'b0;
end
	
always @ (posedge clk) 
begin        
   p_s = n_s;
   case(p_s)	
	`INIT: 
	 begin      
	   round = 2'd0;
	   phase = 4'd0;	
	   valid = 1'b0;	
	   word  = {`h0, `h1, `h2, `h3};
	   digest = 128'd0;
		
	    if(start) // start should be high throughout input sending
	    begin
	       if(data_in != "=")
	       begin
		      message[len] = data_in;
		      len = len+1;	
	       end
	       else //data_in == "="
	       begin		
              message[len] = 8'h80; // Append 1 to message.. 8'd256 = 1000 0000
		      total_len = len*8; // Bytes to bits conversion		                      
		      n_s = `GROUP_DATA;
	       end
	    end			
	 end	 
	 `GROUP_DATA:
	 begin
	    if(j < 6'd16)
	    begin
		  group[j][7:0] = message[k];
		  group[j][15:8] = message[k+1];
		  group[j][23:16] = message[k+2];
		  group[j][31:24] = message[k+3];
		  k = k + 4;
		  j = j + 1;
		  n_s = `GROUP_DATA;
	    end
	    else
	    begin
		  j = 0; k = 0;
		  group[14] = total_len;
		  padded_message = {group[0],group[1],group[2],group[3],group[4],group[5],
		                    group[6],group[7],group[8],group[9],group[10],group[11],
							group[12],group[13],group[14],group[15]};
		  n_s = `ROUND_OPERATION;			
	    end
	 end
	`ROUND_OPERATION:				
	 begin			
		 a = word[127:96];
		 b = word[95:64];
		 c = word[63:32];
		 d = word[31:0];
		 case(round)				 
			2'b00: F_res = ((b & c) | (~b & d)); 
			2'b01: F_res = ((b & d) | (c & ~d)); 
			2'b10: F_res = (b ^ c ^ d); 
			2'b11: F_res = (c ^ (b | ~d)); 
		 endcase
		 n_s = `EVAL_K;
	  end
	 `EVAL_K:
	  begin
		  case({round, phase})
			// Round 1 (00)
			// K = phase
			6'b00_0000: K <= 4'd0; 
			6'b00_0001: K <= 4'd1; 
			6'b00_0010: K <= 4'd2; 
			6'b00_0011: K <= 4'd3; 
			6'b00_0100: K <= 4'd4; 
			6'b00_0101: K <= 4'd5; 
			6'b00_0110: K <= 4'd6; 
			6'b00_0111: K <= 4'd7; 
			6'b00_1000: K <= 4'd8; 
			6'b00_1001: K <= 4'd9; 
			6'b00_1010: K <= 4'd10; 
			6'b00_1011: K <= 4'd11; 
			6'b00_1100: K <= 4'd12; 
			6'b00_1101: K <= 4'd13; 
			6'b00_1110: K <= 4'd14; 
			6'b00_1111: K <= 4'd15; 
			// Round 2 (01)
			// K = (phase*5 + 1)%16;
			6'b01_0000: K <= 4'd1; 
			6'b01_0001: K <= 4'd6; 
			6'b01_0010: K <= 4'd11; 
			6'b01_0011: K <= 4'd0; 
			6'b01_0100: K <= 4'd5; 
			6'b01_0101: K <= 4'd10; 
			6'b01_0110: K <= 4'd15; 
			6'b01_0111: K <= 4'd4; 
			6'b01_1000: K <= 4'd9; 
			6'b01_1001: K <= 4'd14; 
			6'b01_1010: K <= 4'd3; 
			6'b01_1011: K <= 4'd8; 
			6'b01_1100: K <= 4'd13; 
			6'b01_1101: K <= 4'd2; 
			6'b01_1110: K <= 4'd7; 
			6'b01_1111: K <= 4'd12; 
			// Round 3 (10)
			// K = (phase*3 + 5)%16;
			6'b10_0000: K <= 4'd5; 
			6'b10_0001: K <= 4'd8; 
			6'b10_0010: K <= 4'd11; 
			6'b10_0011: K <= 4'd14; 
			6'b10_0100: K <= 4'd1; 
			6'b10_0101: K <= 4'd4; 
			6'b10_0110: K <= 4'd7; 
			6'b10_0111: K <= 4'd10; 
			6'b10_1000: K <= 4'd13; 
			6'b10_1001: K <= 4'd0; 
			6'b10_1010: K <= 4'd3; 
			6'b10_1011: K <= 4'd6; 
			6'b10_1100: K <= 4'd9; 
			6'b10_1101: K <= 4'd12; 
			6'b10_1110: K <= 4'd15; 
			6'b10_1111: K <= 4'd2; 
			// Round 4 (11)
			// K = (phase*7)%16
			6'b11_0000: K <= 4'd0; 
			6'b11_0001: K <= 4'd7; 
			6'b11_0010: K <= 4'd14; 
			6'b11_0011: K <= 4'd5; 
			6'b11_0100: K <= 4'd12; 
			6'b11_0101: K <= 4'd3; 
			6'b11_0110: K <= 4'd10; 
			6'b11_0111: K <= 4'd1; 
			6'b11_1000: K <= 4'd8; 
			6'b11_1001: K <= 4'd15; 
			6'b11_1010: K <= 4'd6; 
			6'b11_1011: K <= 4'd13; 
			6'b11_1100: K <= 4'd4; 
			6'b11_1101: K <= 4'd11; 
			6'b11_1110: K <= 4'd2; 
			6'b11_1111: K <= 4'd9; 
		 endcase
		 n_s = `EVAL_T;
	 end
	`EVAL_T:
	 begin	   
		case( {round, phase} )
			// Round 1 (00)
			6'b00_0000: T <= 32'hd76aa478;
			6'b00_0001: T <= 32'he8c7b756;
			6'b00_0010: T <= 32'h242070db;
			6'b00_0011: T <= 32'hc1bdceee;
			6'b00_0100: T <= 32'hf57c0faf;
			6'b00_0101: T <= 32'h4787c62a;
			6'b00_0110: T <= 32'ha8304613;
			6'b00_0111: T <= 32'hfd469501;
			6'b00_1000: T <= 32'h698098d8;
			6'b00_1001: T <= 32'h8b44f7af;
			6'b00_1010: T <= 32'hffff5bb1;
			6'b00_1011: T <= 32'h895cd7be;
			6'b00_1100: T <= 32'h6b901122;
			6'b00_1101: T <= 32'hfd987193;
			6'b00_1110: T <= 32'ha679438e;
			6'b00_1111: T <= 32'h49b40821;
			// Round 2 (01)
			6'b01_0000: T <= 32'hf61e2562;
			6'b01_0001: T <= 32'hc040b340;
			6'b01_0010: T <= 32'h265e5a51;
			6'b01_0011: T <= 32'he9b6c7aa;
			6'b01_0100: T <= 32'hd62f105d;
			6'b01_0101: T <= 32'h02441453;
			6'b01_0110: T <= 32'hd8a1e681;
			6'b01_0111: T <= 32'he7d3fbc8;
			6'b01_1000: T <= 32'h21e1cde6;
			6'b01_1001: T <= 32'hc33707d6;
			6'b01_1010: T <= 32'hf4d50d87;
			6'b01_1011: T <= 32'h455a14ed;
			6'b01_1100: T <= 32'ha9e3e905;
			6'b01_1101: T <= 32'hfcefa3f8;
			6'b01_1110: T <= 32'h676f02d9;
			6'b01_1111: T <= 32'h8d2a4c8a;
			// Round 3 (10)
			6'b10_0000: T <= 32'hfffa3942;
			6'b10_0001: T <= 32'h8771f681;
			6'b10_0010: T <= 32'h6d9d6122;
			6'b10_0011: T <= 32'hfde5380c;
			6'b10_0100: T <= 32'ha4beea44;
			6'b10_0101: T <= 32'h4bdecfa9;
			6'b10_0110: T <= 32'hf6bb4b60;
			6'b10_0111: T <= 32'hbebfbc70;
			6'b10_1000: T <= 32'h289b7ec6;
			6'b10_1001: T <= 32'heaa127fa;
			6'b10_1010: T <= 32'hd4ef3085;
			6'b10_1011: T <= 32'h04881d05;
			6'b10_1100: T <= 32'hd9d4d039;
			6'b10_1101: T <= 32'he6db99e5;
			6'b10_1110: T <= 32'h1fa27cf8;
			6'b10_1111: T <= 32'hc4ac5665;
			// Round 4 (11)
			6'b11_0000: T <= 32'hf4292244;
			6'b11_0001: T <= 32'h432aff97;
			6'b11_0010: T <= 32'hab9423a7;
			6'b11_0011: T <= 32'hfc93a039;
			6'b11_0100: T <= 32'h655b59c3;
			6'b11_0101: T <= 32'h8f0ccc92;
			6'b11_0110: T <= 32'hffeff47d;
			6'b11_0111: T <= 32'h85845dd1;
			6'b11_1000: T <= 32'h6fa87e4f;
			6'b11_1001: T <= 32'hfe2ce6e0;
			6'b11_1010: T <= 32'ha3014314;
			6'b11_1011: T <= 32'h4e0811a1;
			6'b11_1100: T <= 32'hf7537e82;
			6'b11_1101: T <= 32'hbd3af235;
			6'b11_1110: T <= 32'h2ad7d2bb;
			6'b11_1111: T <= 32'heb86d391;
			default:    T <= 32'hxxxxxxxx;
		endcase
		n_s = `EVAL_S;
	 end
	`EVAL_S:
	 begin
		case({round,phase[1:0]})
			// Round 1 (00)
			4'b00_00: S <= 5'd7;
			4'b00_01: S <= 5'd12;
			4'b00_10: S <= 5'd17;
			4'b00_11: S <= 5'd22;
			// Round 2 (01)
			4'b01_00: S <= 5'd5;
			4'b01_01: S <= 5'd9;
			4'b01_10: S <= 5'd14;
			4'b01_11: S <= 5'd20;
			// Round 3 (10)
			4'b10_00: S <= 5'd4;
			4'b10_01: S <= 5'd11;
			4'b10_10: S <= 5'd16;
			4'b10_11: S <= 5'd23;
			// Round 4 (11)
			4'b11_00: S <= 5'd6;
			4'b11_01: S <= 5'd10;
			4'b11_10: S <= 5'd15;
			4'b11_11: S <= 5'd21;
		endcase
		n_s = `ROUND_RESULT;
	  end
	 `ROUND_RESULT:
 	  begin
			F_res = F_res + a + padded_message[480-32*K +: 32] + T;
			round_result = b + ((F_res << S) | (F_res >> (32-S)));
			next_word = {word[31:0], round_result, word[95:32]};				
			if( phase == 5'd15 ) 
			begin				
				if( round == 2'b11 ) // 4 rounds are over 						
					n_s = `HALT_ITERATION;					
			   else
				begin				   
				   round = round + 2'd1; //After all 16 phases, next round				
				   phase = 5'b0;
			       word = next_word;	
				   n_s = `ROUND_OPERATION;
				end
			end		
			else
			begin
			   phase = phase + 4'd1;
			   n_s = `ROUND_OPERATION;
			   word = next_word;	
			end			
	  end	 	 
	 `HALT_ITERATION:
	  begin	      						
		   out = {next_word[127:96]+ `h0, 
			       next_word[95:64] + `h1,  
		           next_word[63:32] +`h2, 
				   next_word[31:0]  +`h3};						
		   k = 0; j = 0;
		   n_s = `PROCESS_OUTPUT;
	  end
	 `PROCESS_OUTPUT:
	  begin
			temp_output[0] <= out[127:96];
			temp_output[1] <= out[95:64];
			temp_output[2] <= out[63:32];
			temp_output[3] <= out[31:0];
			n_s = `REORDER_OUTPUT;			
		end
	  `REORDER_OUTPUT:
		begin
		   if(k < 4)
			begin
				reordered_output[k] = {temp_output[j][7:0],
									   temp_output[j][15:8],
									   temp_output[j][23:16],
									   temp_output[j][31:24]};
                k = k + 1;
			    j = j + 1;
			end
			else
			begin
				digest = {reordered_output[0], 
				          reordered_output[1], 
						  reordered_output[2], 
						  reordered_output[3]};
				valid = 1'b1;
			end
	  end			
	endcase							 
  end
endmodule