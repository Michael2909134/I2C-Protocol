`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2025 22:28:24
// Design Name: 
// Module Name: I2C_top_module_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module I2C_top_module_tb;
     reg clk;
     reg rst;
     reg send;
     reg r_w;
     reg [6:0] master_address;
     reg [7:0] data_in_1;
     reg [7:0] data_in_2;
     wire tx_done;
     wire rx_done;
     wire [7:0] data_out_master;
     wire [7:0] data_out_slave;
          
     I2C_top_module uut(
     .clk(clk),
          .rst(rst),
          .send(send),
          .r_w(r_w),
          .master_address(master_address),
          .data_in_1(data_in_1),
          .data_in_2(data_in_2),
          .tx_done(tx_done),
          .rx_done(rx_done),
          .data_out_master(data_out_master),
          .data_out_slave(data_out_slave)
 );    
 
 initial
 begin
  clk=0;
  forever #5 clk=~clk;
end

initial
  begin
   rst=1;
   send=0;
   master_address=7'b0101101;
   r_w=1;
   data_in_1=8'b10110111;
   data_in_2=8'b01010110;
   #10 rst=0;
   #10 send=1;
   #100 send = 0;
end
 endmodule
