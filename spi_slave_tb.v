`timescale 1ns/1ps
module spi_slave_tb;
	parameter DATA_WIDTH = 8;
	
	//測試訊號宣告
	reg sclk;
	reg rst_n;
	reg mosi;
	wire miso;
	wire [DATA_WIDTH-1:0] data_out;
	reg [DATA_WIDTH-1:0] data_in;
	reg load;
	wire done;
	
	//測試資料
	reg [DATA_WIDTH-1:0] mosi_test_data = 8'b11001100;
	reg [DATA_WIDTH-1:0] miso_test_data = 8'b10101010;
	
	//帶測模組實例化
	spi_slave #(
		.DATA_WIDTH(DATA_WIDTH)
	) uut (
		.sclk(sclk),
		.rst_n(rst_n),
		.mosi(mosi),
		.miso(miso),
		.data_out(data_out),
		.data_in(data_in),
		.load(load),
		.done(done)
	);
	//系統時脈產生器(模擬主機的SCLK)
	initial sclk = 0;
	always #10 sclk = ~sclk; // 50MHz(週期20ns)
	
	//測試流程
	initial begin
		$display("=== Start spi_slave_tb simulation ===");
		
		//初始狀態
		rst_n = 0;
		load = 0;
		mosi = 0;
		data_in = miso_test_data;
		
		#25;
		rst_n = 1;
		
		//載入要傳出去的資料(MISO)
		#20;
		load = 1;
		#20;
		load = 0;
		
		//傳送 8 bits 到 MOSI (bit 7 to bit 0)
		//傳送資料為: 11001100
		
	   #15;
		send_mosi_bits(mosi_test_data);
		
		//等待 done 拉高
		wait(done == 1);
		#10;
		
		$display(">> [傳送端 MOSI] = %b", mosi_test_data);
		$display("[從設備接收 data_out] =%b", data_out);
		$display(">>[預期值] = %b", mosi_test_data);
		if (data_out === mosi_test_data) 
			$display("[結果]正確! Slave接收到的資料與MOSI一致");
		else
		    $display("[結果]錯誤! 資料不一致");
		$finish;
	end
	
	// 傳送每一個 bit 並即時顯示
	task send_mosi_bits(input[DATA_WIDTH-1:0] bits);
		integer i;
		for (i = DATA_WIDTH-1;i >= 0; i = i - 1) begin
			mosi = bits[i];  //先設定MOSI
			@(negedge sclk);  //再等 SCLK 下降緣(對應 master 傳輸)
         $display("[MOSI bit %0d]-> %b | [MISO] = %b", i, bits[i], miso);
		end
	endtask
endmodule