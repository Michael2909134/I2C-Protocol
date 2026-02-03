`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2025 22:27:22
// Design Name: 
// Module Name: Slave
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


module Slave(
    input clk,
    input rst,
    input sclk,
    inout sda,
    input r_w,
    input [6:0] slave_addr,
    input [7:0] data_in_2,
    output reg tx_done=0,
    output reg [7:0] data_out_slave=0,
    output reg rx_done=0
);

reg [3:0] current_state,next_state;
reg [7:0] rx_shift_reg;
reg [7:0] tx_shift_reg;
reg [3:0] bit_index;
reg prev_sclk;
reg sda_en;
reg sda_out;
reg addr_ack_sent;
reg write_ack_sent;
reg read_ack_received=0;

reg [7:0] data_reg = 0;
parameter idle=4'd0;
parameter start=4'd1;
parameter address=4'd2;
parameter address_ack=4'd3;
parameter write=4'd4;
parameter write_ack=4'd5;
parameter read=4'd6;
parameter read_ack=4'd7;
parameter stop=4'd8;

assign sda=(sda_en)? sda_out:1'bz;
always @(posedge clk or posedge rst)
begin
 if(rst) begin
    current_state<=idle;
    bit_index<=0;
    rx_shift_reg<=0;
    rx_done<=0;
    sda_en<=0;
    sda_out<=1;
    prev_sclk<=0;
    addr_ack_sent<=0;
    write_ack_sent<=0;
 end else begin
    current_state<=next_state;
    prev_sclk<=sclk;
 end
end

always @(*)
 begin
    case(current_state)
    idle:begin
       if(!sda && sclk) begin
          next_state=start;
       end else
          next_state=idle;
    end
    
    start:begin
      next_state=address;
    end
    
    address:begin
        if(bit_index==8) begin
           next_state=address_ack;
        end else
           next_state=address;
    end
    
    address_ack:begin
       if(addr_ack_sent) begin
         if(r_w==0) begin
          bit_index=0;
          next_state=write;
         end else begin
          bit_index=0;
          next_state=read;
         end
    end
    end
    
    write:begin
        if(bit_index==9) begin
           next_state=write_ack;
        end else
           next_state=write;
    end
    write_ack:begin
       if(write_ack_sent && !r_w) begin
          next_state=stop;
       end else
          next_state=write_ack;
    end
    read:begin
        if(bit_index==9) begin
           next_state=read_ack;
        end else
            next_state=read;
    end
        
    read_ack:if(read_ack_received) next_state=stop;
    
    
    stop:begin
       if(sclk && sda) begin
          next_state=idle;
       end
    end
    
    default:next_state=idle;
 endcase
 end

 
always @(posedge clk)
begin
  case(current_state)
  idle:begin
    rx_done<=0;
    sda_en<=0;
    bit_index<=0;
    tx_shift_reg<=data_in_2;
  end
  
  start:begin
    bit_index<=0;
    rx_done<=0;
  end
  
  
  stop:begin
    tx_done<=1;
    rx_done<=1;
    data_out_slave<=data_reg;
  end
endcase
end

always @(posedge sclk)
begin
   if(current_state==address)begin
       rx_shift_reg<={rx_shift_reg[6:0],sda};
       bit_index<=bit_index+1;
   end else if (current_state == write) begin
       data_reg<={data_reg[6:0],sda};
       bit_index<=bit_index+1;
   end else if(current_state == read_ack) begin
       read_ack_received<=(sda==0);
   end
end


always @(negedge sclk)
begin
   
   case(current_state)
      address_ack:begin
        if(rx_shift_reg[7:1]==slave_addr) begin
              sda_en<=1;
              sda_out<=0;
              addr_ack_sent<=1;
            
        end 
      end
      
      
      write:begin
         sda_en<=0;
      end
       
      write_ack:begin
         sda_en<=1;
         sda_out<=0;
         write_ack_sent<=1;
      end
      
      read:begin
        sda_en<=1;
        sda_out<=tx_shift_reg[7];
        tx_shift_reg<=tx_shift_reg<<1;
        bit_index<=bit_index+1;   
        if(bit_index==8) begin
           sda_en<=0;
        end 
      end
     
      stop:begin
         sda_en<=0;
      end
      
   endcase
end
endmodule

