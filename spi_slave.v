`timescale 1ns/1ps
module spi_slave #(
	parameter DATA_WIDTH = 8
)(
	input wire sclk,  //主設備提供的時脈
	input wire rst_n,  
	input wire mosi,  //從主設備傳來的資料
	output reg miso,  //傳送給主設備的資料
	output reg [DATA_WIDTH-1:0] data_out,  //接收到的資料
	input wire [DATA_WIDTH-1:0] data_in,  //要送出去的資料
	input wire load,  //載入要傳送的資料
	output reg done  //表示8-bit傳輸完成
);

	reg [DATA_WIDTH-1:0] shift_in;
	reg [DATA_WIDTH-1:0] shift_out;
	reg [3:0] bit_cnt;
	
	always @(posedge sclk or negedge rst_n) begin
		if (!rst_n) begin
			shift_in <= 0;
			shift_out <= 0;
			bit_cnt <= 0;
			miso <= 0;
			done <= 0;
		end else begin
		   //若 load 為 High,則載入 data_in
			if (load) begin
				shift_out <= data_in;
		   end else begin
				// Shift in from MOSI
				shift_in <= {mosi,shift_in[DATA_WIDTH-1:1]};
				
				// Shift out ot MISO
				miso <= shift_out[DATA_WIDTH-1];
				shift_out <= {shift_out[DATA_WIDTH-2:0],1'b0};
				
			   // Bit counter
			   bit_cnt <= bit_cnt + 1;
			
			   if (bit_cnt == DATA_WIDTH - 1) begin
				   done <= 1;
				   data_out <= shift_in;  //補捉完整資料
			   end else begin
			 	   done <= 0;
			   end
		    end
		end
	end
	
endmodule