`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 07:03:40 AM
// Design Name: 
// Module Name: UART_R_tb
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


module UART_R_tb;
    

    reg       clk;
    reg       rst;
    reg       rx_in;
    reg [4:0] prescale;
    reg       par_en;
    reg       par_typ;

    wire [7:0] p_data;
    wire       data_valid;

    always #5 clk = ~clk;
    
    UART_top uut (
        .clk(clk),
        .rst(rst),
        .rx_in(rx_in),
        .prescale(prescale),
        .par_en(par_en),
        .par_typ(par_typ),
        .p_data(p_data),
        .data_valid(data_valid)
    );
    initial begin
       $dumpfile("UART_top.vcd");
       $dumpvars(0, UART_R_tb);
     end
    initial begin
        clk      = 1'b0;
        rst      = 1'b0;
        rx_in    = 1'b1;
        prescale = 5'd8;
        par_en   = 1'b1;
        par_typ  = 1'b0;

        #20;
        rst = 1'b1;
        #20;

        rx_in = 1'b0;
        #(80);
        rx_in = 1'b1; 
        #(80);
        rx_in = 1'b0; 
        #(80);
        rx_in = 1'b1;
         #(80);
        rx_in = 1'b0;
         #(80);
        rx_in = 1'b0; 
        #(80);
        rx_in = 1'b1; 
        #(80);
        rx_in = 1'b0;
         #(80);
        rx_in = 1'b1; 
        #(80);

        rx_in = 1'b0;
        #(80);

        rx_in = 1'b1;
        #(80);

        #100;
        $finish;
    end
endmodule
