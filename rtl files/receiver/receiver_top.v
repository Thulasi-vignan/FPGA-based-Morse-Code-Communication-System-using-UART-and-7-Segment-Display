`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 04:39:01 PM
// Design Name: 
// Module Name: receiver_top
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


module receiver_top(
    input clock,
    input reset,
    input rx,
    input wire letter_done,
    //output  [8:0] data_out,
    output  valid,
    output [6:0] seg_out,
    output [7:0] current_display,
    output [7:0] current_display_check

    );
    
    wire letter_Done;
    //wire ascii_char;
    wire [7:0] data_out;
    
    uart_rx r1 (clock,reset,rx,data_out,valid);
    
    // Synchronize external letter_done to FPGA clock domain
    reg letter_d1, letter_d2;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            letter_d1 <= 0;
            letter_d2 <= 0;
        end else begin
            letter_d1 <= letter_done;
            letter_d2 <= letter_d1;
        end
    end
    assign letter_Done = letter_d2; // safe synchronized signal
    
   // assign letter_done = letter_Done;
    //assign ascii_char =  data_out[7:0];
    
    seven_seg_disp disp1 (data_out,clock,letter_Done,reset,seg_out,current_display,current_display_check);
    
endmodule
