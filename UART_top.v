`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 01:39:00 PM
// Design Name: 
// Module Name: UART_top
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


module UART_top(
input wire             clk,
input wire             rst,
input wire             rx_in,
input wire        [4:0]prescale,
input wire             par_en,
input wire             par_typ,

output wire       [7:0]p_data,
output wire            data_valid
);
wire       enable;
wire       dat_samp_en;
wire       deser_en;
wire       strt_chk_en;
wire       par_chk_en;
wire       stp_chk_en;
wire       strt_glitch;
wire       par_err;
wire       stp_err;
wire       sampled_bit;
wire [5:0] edge_cnt;
wire [3:0] bit_cnt;


fsm u_fsm(
. clk(clk),
. rst(rst),
. rx_in(rx_in),
. par_en(par_en),
. bit_cnt(bit_cnt),
. edge_cnt(edge_cnt),
. par_err(par_err),
. strt_glitch(strt_glitch),
. stp_err(stp_err),

.enable(enable),
.dat_samp_en(dat_samp_en),
.deser_en(deser_en),
.data_valid(data_valid),
.strt_chk_en(strt_chk_en),
.stp_chk_en(stp_chk_en),
.par_chk_en(par_chk_en)
);



edge_bit_counter u_edge_bit_counter(
.clk(clk),
.rst(rst),
.enable(enable),
.prescale(prescale),

.edge_cnt(edge_cnt),
.bit_cnt(bit_cnt)
);

data_sampling u_data_sampling(
. clk(clk),
. rst(rst),
. rx_in(rx_in),
. dat_samp_en(dat_samp_en),
. edge_cnt(edge_cnt),
. prescale(prescale),

. sampled_bit(sampled_bit)
);


deserializer u_deserializer(
.clk(clk),
.rst(rst),
.deser_en(deser_en),
.sampled_bit(sampled_bit),
.edge_cnt(edge_cnt),
.prescale(prescale),
.p_data(p_data)
);

strt_check u_strt_check(
. strt_chk_en(strt_chk_en),
. sampled_bit(sampled_bit),
. strt_glitch(strt_glitch)
);

parity_check u_parity_check(
.par_chk_en(par_chk_en),
.par_typ(par_typ), 
.p_data(p_data),
.sampled_bit(sampled_bit),
.par_err(par_err)
);

stop_check u_stop_check (
. stp_chk_en(stp_chk_en),
. sampled_bit(sampled_bit),
. stp_err(stp_err)
);

endmodule

