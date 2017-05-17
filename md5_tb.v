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
module md5_tb;
	// Inputs
	reg clk;
	reg start;
	reg [7:0] data_in;
	// Outputs
	wire [127:0] digest;
	wire valid;

	// Instantiate the Unit Under Test (UUT)
	md5 uut (
		.clk(clk),  
		.start(start), 
		.data_in(data_in), 
		.digest(digest), 
		.valid(valid)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		start = 0;
		data_in = 0;
		// Wait 100 ns for global reset to finish
		#10 start = 1;		          
	end
	initial    
	begin
	   #10 data_in = "h";
       #10 data_in = "e";
       #10 data_in = "l";
       #10 data_in = "l";
       #10 data_in = "o";      
	   #10 data_in = "=";		
	end
   always #5 clk = ~clk;
endmodule