`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 12:10:21 AM
// Design Name: 
// Module Name: UART_top_tb
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


module UART_top_tb;
    parameter data_width=8,clk_period=5;

    reg                      clk;
    reg                      rst;
    reg  [data_width-1:0]    p_data;
    reg                      data_valid;
    reg                      par_en;
    reg                      par_typ;

    wire                     tx_out;
    wire                     busy;

    UART_top #(
        .data_width(data_width)
    )uut(
        .clk(clk),
        .rst(rst),
        .p_data(p_data),
        .data_valid(data_valid),
        .par_en(par_en),
        .par_typ(par_typ),

        .tx_out(tx_out),
        .busy  (busy) 
    );

    always #(clk_period / 2.0) clk = ~clk;

    initial begin
        $dumpfile("UART_top.vcd");
        $dumpvars(0, UART_top_tb);
    end

    initial begin
        clk        =1'b0;
        rst        =1'b0;
        p_data     =8'b0;
        data_valid =1'b0;
        par_en     =1'b0;
        par_typ    =1'b0;

        #(clk_period*2);
        rst=1'b1;

        #(clk_period*2);
        p_data     =8'b10100101;
        par_en     =1'b1;
        par_typ    =1'b0;
        data_valid =1'b1;
        

        #clk_period;
        data_valid = 1'b0;
        
        #(clk_period*15);
        p_data     =8'b00111011;
        par_en     =1'b1;
        par_typ    =1'b1;
        data_valid =1'b1;
        #clk_period;
        data_valid =1'b0;

        
        #(clk_period*15);
        p_data     =8'b11001100;
        par_en     =1'b0;
        data_valid =1'b1;

        #clk_period;
        data_valid = 1'b0;
        #(clk_period*15);

        $finish;
        
       
    end
endmodule
