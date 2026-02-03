`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2025 22:23:23
// Design Name: 
// Module Name: I2C_top_module
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


module I2C_top_module(
    input wire clk,
    input wire rst,
    input wire send,
    input wire r_w,
    input wire [6:0] master_address,  
    input wire [7:0] data_in_1, 
    input wire [7:0] data_in_2,
    output wire tx_done,
    output wire rx_done,
    output wire [7:0] data_out_master,
    output wire [7:0] data_out_slave
);

//internal signals
wire sclk;
wire sda;
    Master master_inst(
    .clk(clk),
        .rst(rst),
        .send(send),
        .r_w(r_w),
        .master_addr(master_address),
        .data_in_1(data_in_1),
        .tx_done(tx_done),
        .sclk(sclk),
        .sda(sda),
        .data_out_master(data_out_master)
    
 );
    Slave slave_inst(
    .clk(clk),
        .rst(rst),
        .r_w(r_w),
        .slave_addr(master_address),
        .data_in_2(data_in_2),
        .sclk(sclk),
        .sda(sda),
        .rx_done(rx_done),
        .data_out_slave(data_out_slave)
 );
endmodule

