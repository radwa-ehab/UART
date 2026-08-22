`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 04:56:18 AM
// Design Name: 
// Module Name: UART-T
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

module mux(
    input wire [1:0] mux_sel,
    input wire ser_data,
    input wire par_bit,
    output reg tx_out
);
    always@(*)begin
        case(mux_sel)
            2'b00:tx_out=1'b0;
            2'b01:tx_out=ser_data;
            2'b10:tx_out= par_bit;
            2'b11:tx_out=1'b1;
            default:tx_out=1'b0;
        endcase
    end
endmodule



module piso#(
    parameter data_width=8
)(
    input wire 				clk,
	input wire 				rst,
	input wire   [data_width-1:0]p_data,
	input wire              ser_en,
	
	

	output reg              ser_data,
	output reg              ser_done
);
    reg [data_width-1:0] shift_reg;
    reg [$clog2(data_width):0] count;

    always @(posedge clk or negedge rst) begin
         if(!rst)begin
            shift_reg    <={data_width{1'b0}};
            ser_data     <=1'b0;
            count        <='b0;
            ser_done     <=1'b0;
        end
        else if(ser_en)begin
            if(count==data_width-1)begin
                ser_data <= shift_reg[data_width-1];
                ser_done <= 1'b1;
                count    <= 'b0;
            end
            else begin
                if (count=='b0) begin
                    shift_reg <= p_data;       
                    ser_data  <= p_data[0];
                end else begin
                    ser_data  <= shift_reg[count];
                end
                count    <= count + 1'b1;
                ser_done <= 1'b0;
            end
           
        end
         else begin
            count     <='b0;
            ser_done  <=1'b0;
        end
    end
endmodule


module parity_calc #(
    parameter data_width = 8
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire [data_width-1:0] p_data,
    input  wire                  data_valid,
    input  wire                  par_typ,
    output reg                   par_bit
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            par_bit <= 1'b0;
        end 
        else if (data_valid) begin
            if (par_typ == 1'b0) begin
                par_bit <= ^p_data;
            end 
            else begin
                par_bit <= ~^p_data;
            end
        end
    end

endmodule


module fsm(
    input wire       clk,
    input wire       rst,
    input wire       data_valid,
    input wire       par_en,
    input wire       ser_done,

    output reg       ser_en,
    output reg [1:0] mux_sel,
    output reg       busy   
);
localparam 
            idle   = 3'b000,
            start  = 3'b001,
            data   = 3'b010,
            parity = 3'b011,
            stop   = 3'b100;

reg [2:0]cs,ns;
always @(posedge clk or negedge rst) begin
        if (!rst)
            cs <= idle;
        else
            cs <= ns;
end

always@(*)begin
    case(cs)
        idle:begin
            if(data_valid)
                ns=start;
            else 
                ns=idle;
        end
        start:begin
            ns=data;
        end
        data:begin
            if(ser_done)begin
                if(par_en)ns=parity;
                else ns=stop;
            end
            else ns=data;
        end
        parity:begin
            ns=stop;
        end
        stop:begin
            ns=idle;
        end
        default : ns=idle;
    endcase
end


always @(*)begin
    ser_en  =1'b0;
    mux_sel =2'b11;
    busy    =1'b0;

    case(cs)
    idle:begin
        ser_en  =1'b0;
        mux_sel =2'b11;
        busy    =1'b0;
    end
    start:begin
        ser_en  =1'b0;
        mux_sel =2'b00;
        busy    =1'b1;
    end
    data:begin
        ser_en  =1'b1;
        mux_sel =2'b01;
        busy    =1'b1;
    end
    parity:begin
        ser_en  =1'b0;
        mux_sel =2'b10;
        busy    =1'b1;
    end
    stop:begin
        ser_en  =1'b0;
        mux_sel =2'b11;
        busy    =1'b1;
    end
    default :begin
        ser_en  =1'b0;
        mux_sel =2'b11;
        busy    =1'b0;
    end
    endcase 

end
endmodule

