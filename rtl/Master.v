`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.05.2025 22:26:10
// Design Name: 
// Module Name: Master
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


module Master(
    input clk,
    input rst,
    input send,
    inout sda,
    input r_w,
    input [6:0] master_addr,
    input [7:0] data_in_1,
    output reg sclk,
    output reg tx_done=0,
    output reg rx_done=0,
    output reg [7:0] data_out_master=0
);

reg [3:0] current_state,next_state;
reg [2:0] counter;
reg [3:0] bit_index;
reg [7:0] tx_shift_reg;
reg [7:0] rx_shift_reg=0;
reg [7:0] master_addr_reg;
reg prev_sclk;
reg addr_ack_received;
reg sda_en;
reg sda_out;
reg write_ack_received;
reg read_ack_sent=0;


parameter idle=4'd0;
parameter start=4'd1;
parameter address=4'd2;
parameter address_ack=4'd3;
parameter write=4'd4;
parameter write_ack=4'd5;
parameter read=4'd6;
parameter read_ack=4'd7;
parameter stop=4'd8;

assign sda=(sda_en)?sda_out:1'bz;
always @(posedge clk or posedge rst)
begin
  if(rst) begin
    sclk<=1;
    counter<=0;
  end else if(counter==4) begin
      if(current_state>idle) begin
       sclk<=~sclk;
       counter<=0;
      end
  end else
    counter<=counter+1;
 end
 
 always @(posedge clk or posedge rst) 
 begin
   if(rst) begin
     current_state<=idle;
     bit_index<=0;
     tx_shift_reg<=0;
     sda_en<=0;
     sda_out<=1;
     master_addr_reg<=0;
     prev_sclk<=1;
     tx_done<=0;
     addr_ack_received=0;
     write_ack_received=0;
   end else begin
     current_state<=next_state;
     prev_sclk<=sclk;
   end
end

always @(*)
begin
  case(current_state) 
    idle:if(send) next_state=start;
    
    start:next_state=address;
    
    address:if(bit_index==9) next_state=address_ack;
     
    address_ack:begin
       if(addr_ack_received) begin
         if(r_w==0) begin
          bit_index=0;
          next_state=write;
         end else begin
          bit_index=0;
          next_state=read;
         end
    end
    end
    write:if(bit_index==9) next_state=write_ack;
    
    write_ack: begin
       if(write_ack_received && !r_w) begin
            next_state=stop;
       end
    end
    
    read:begin
       if(bit_index==8) begin
          next_state=read_ack;
       end
    end
        
    read_ack: begin
        if(read_ack_sent) begin
           next_state=stop;
        end
    end
    
   stop:if(sclk && !prev_sclk) next_state=idle;
    
    default:next_state=idle;
  endcase
end    

always @(posedge clk) 
begin
   case(current_state)
   idle:begin
   sda_en<=1;
   sda_out<=1;
   tx_done<=0;
   sclk<=1;
   if(send) begin
     master_addr_reg<={master_addr,r_w};
     tx_shift_reg<=data_in_1;
     bit_index<=0;
   end
   end
    start:begin
      sda_en<=1;
      sda_out<=0;
    end
   
    address: ;
   //
  
    write: ;
    stop:begin
    //  sda_en<=1;
    //  sda_out<=0;
      tx_done<=1;
      rx_done<=1;
      data_out_master<=rx_shift_reg;
    end
  endcase
end

always @(negedge sclk) 
begin 
    case(current_state)
    address: begin
      sda_en<=1;
      sda_out<=master_addr_reg[7];
      master_addr_reg<=master_addr_reg<<1;
      bit_index<=bit_index+1;   
      if(bit_index==8) begin
         sda_en<=0;
      end 
    end 
    
    write: begin
      sda_en<=1;
      sda_out<=tx_shift_reg[7];
      tx_shift_reg<=tx_shift_reg<<1;
      bit_index<=bit_index+1;
      if(bit_index==8) begin
         sda_en<=0;
      end 
    end 
    
     read_ack:begin
         sda_en<=1;
         sda_out<=0;
         read_ack_sent<=1;
     end
     
     
     stop:begin
        sda_en<=1;
        sda_out<=1;
     end
   
 
endcase
end

always @(posedge sclk)
begin
   if(current_state==address_ack) begin
     addr_ack_received<=(sda==0);
   end else if(current_state == write_ack) begin
     write_ack_received<=(sda==0);
   end  else if (current_state == read) begin
      rx_shift_reg<={rx_shift_reg[6:0],sda};
      bit_index<=bit_index+1;
   end  
   end

endmodule