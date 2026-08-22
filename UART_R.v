`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 09:13:05 AM
// Design Name: 
// Module Name: UART_R
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


module fsm(
    input wire                     clk,
    input wire                     rst,
    input wire                     rx_in,
    input wire                     par_en,
    input wire               [3:0] bit_cnt,
    input wire               [5:0] edge_cnt,
    input wire                     par_err,
    input wire                     strt_glitch,
    input wire                     stp_err,

    output reg                     enable,
    output reg                     dat_samp_en,
    output reg                     deser_en,
    output reg                     data_valid,
    output reg                     strt_chk_en,
    output reg                     stp_chk_en,
    output reg                     par_chk_en
);
localparam 
            idle   = 3'b000,
            start  = 3'b001,
            data   = 3'b010,
            parity = 3'b011,
            stop   = 3'b100;
reg [2:0]cs,ns;
always @(posedge clk or negedge rst)begin
    if(!rst)cs<=idle;
    else cs<=ns;
end
always @(*)begin
    enable      =1'b0;
    dat_samp_en =1'b0;
    deser_en    =1'b0;
    data_valid  =1'b0;
    strt_chk_en =1'b0;
    stp_chk_en  =1'b0;
    par_chk_en  =1'b0;
    ns          =cs;
    case(cs)
        idle:begin
            if(!rx_in)ns=start;
        end
        start:begin
            enable      =1'b1;
            dat_samp_en =1'b1;
            strt_chk_en =1'b1;
            if(bit_cnt==4'd1)begin
                if(strt_glitch)ns=idle;
                else ns=data;
            end
        end
        data:begin
            enable      = 1'b1;
            dat_samp_en = 1'b1;
            deser_en    = 1'b1;
            if (bit_cnt==4'd9) begin
                    if (par_en) ns=parity;
                    else ns=stop;
            end
        end
        parity:begin
            enable      = 1'b1;
            dat_samp_en = 1'b1;
            par_chk_en  = 1'b1;
            if (bit_cnt==4'd10)ns=stop;
        end
        stop:begin
            enable      = 1'b1;
            dat_samp_en = 1'b1;
            stp_chk_en  = 1'b1;
            
            if ((par_en&& bit_cnt==4'd11)||(!par_en&& bit_cnt==4'd10)) begin
                if (!par_err&&!stp_err) begin
                    data_valid=1'b1; 
                     ns=idle;
                end else ns=idle;
                
                
            end
        end
         default : ns=idle;
    endcase
end

endmodule



module edge_bit_counter(
    input wire                     clk,
    input wire                     rst,
    input wire                     enable,
    input wire                [4:0]prescale,

    output reg                [5:0]edge_cnt,
    output reg                [3:0]bit_cnt
);
always @(posedge clk or negedge rst) begin
    if(!rst)begin
        edge_cnt<=6'd0;
        bit_cnt <=4'd0;
    end
    else if(enable)begin
        if(edge_cnt==prescale-1'b1)begin
       edge_cnt <=6'd0;
       bit_cnt   <=bit_cnt+4'd1;
        end
        else 
       edge_cnt<=edge_cnt+1'd1;
    end
    else begin
        edge_cnt<=6'd0;
        bit_cnt <=4'd0;
    end
    
end
endmodule


module data_sampling(
    input wire                     clk,
    input wire                     rst,
    input wire                     rx_in,
    input wire                     dat_samp_en,
    input wire               [5:0] edge_cnt,
    input wire               [4:0] prescale,

    output reg                     sampled_bit
);
reg [2:0] samples;
wire [4:0] mid_edge;

assign mid_edge=prescale>>1;
always @(posedge clk or negedge rst) begin
    if(!rst)begin
        samples<=3'b000;
        sampled_bit<=0;
    end
    else if(dat_samp_en)begin
        if(edge_cnt==mid_edge-1'b1)samples[0]<=rx_in;
        else if(edge_cnt==mid_edge)samples[1]<=rx_in;
        else if(edge_cnt==mid_edge+1'b1)samples[2]<=rx_in;

        if (edge_cnt == mid_edge + 2'd2) begin
                sampled_bit <= (samples[0] & samples[1]) | (samples[0] & samples[2]) | (samples[1] & samples[2]);
        end
    end
    else begin
        samples <=3'b000;
        sampled_bit<=1'b0;
    end
end

endmodule

module strt_check (
    input  wire strt_chk_en,
    input  wire sampled_bit,
    output wire strt_glitch
);
    assign strt_glitch=(strt_chk_en&&(sampled_bit!=1'b0))?1'b1:1'b0 ;
endmodule

module parity_check (
    input  wire       par_chk_en,
    input  wire       par_typ, // 0: Even, 1: Odd
    input  wire [7:0] p_data,
    input  wire       sampled_bit,
    output reg        par_err
);
    wire expected_parity;
    assign expected_parity=(par_typ==1'b0)?^p_data:~^p_data;

    always @(*) begin
        if (par_chk_en)
            par_err=(sampled_bit!=expected_parity);
        else
            par_err=1'b0;
    end
endmodule

module stop_check (
    input  wire stp_chk_en,
    input  wire sampled_bit,
    output wire stp_err
);
    assign stp_err=(stp_chk_en&&(sampled_bit!=1'b1))?1'b1:1'b0;
endmodule

module deserializer (
    input  wire       clk,
    input  wire       rst,
    input  wire       deser_en,
    input  wire       sampled_bit,
    input  wire [5:0] edge_cnt,
    input  wire [4:0] prescale,
    output reg  [7:0] p_data
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            p_data<=8'b0;
        end 
        else if (deser_en&&(edge_cnt==prescale-1'b1)) begin
            p_data<={sampled_bit,p_data[7:1]};
        end
    end

endmodule
