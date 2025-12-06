`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 04:52:37 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx
(
  input clk,
  input rst,
  input [7:0] data_in, // Data to transmit
  output reg tx,       // UART TX output (to Bluetooth module RX)
  output reg busy      // High while transmitting
);

  reg [15:0] tick_counter;
   reg tick;
reg start;
 
  // Define FSM states.
  localparam STATE_IDLE     = 2'd0;
  localparam STATE_LOAD     = 2'd1;
  localparam STATE_TRANSMIT = 2'd2;
  localparam STATE_DONE     = 2'd3;
  
  reg [1:0] state;
  reg [3:0] bit_index;
  reg [9:0] tx_shift_reg;  // Frame: {stop, data[7:0], start}
  reg [15:0] counter;
  
  
   always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
      tick    <= 0;
    end else begin
      if (counter == 10417) begin
        counter <= 0;
        tick    <= 1;
      end else begin
        counter <= counter + 1;
       tick <= 0;
      end
    end
  end
  
  
  
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state         <= STATE_IDLE;
      tick_counter  <= 0;
      bit_index     <= 0;
      busy          <= 0;
      tx            <= 1'b1; // Idle state is high.
      tx_shift_reg  <= 10'b1111111111;
    end else begin
      case (state)
        STATE_IDLE: begin
          busy <= 0;
          tx   <= 1;
             if (!busy)
          start <= 1;
       else begin
        start <= 0;
      end
          
          if (start) begin
            state <= STATE_LOAD;
          end
        end
        STATE_LOAD: begin
          tx_shift_reg <= {1'b1, data_in, 1'b0};  // Load frame: {stop, data, start}
          bit_index    <= 0;
          tick_counter <= 0;
          busy         <= 1;
          state        <= STATE_TRANSMIT;
        end
        STATE_TRANSMIT: begin
          if (tick_counter < tick - 1) begin
            tick_counter <= tick_counter + 1;
          end else begin
            tick_counter <= 0;
            tx           <= tx_shift_reg[0];
            tx_shift_reg <= {1'b1, tx_shift_reg[9:1]}; // Shift in a '1' for stop bit.
            bit_index    <= bit_index + 1;
            if (bit_index == 9) begin
              state <= STATE_DONE;
            end
          end
        end
        STATE_DONE: begin
          busy  <= 0;
          state <= STATE_IDLE;
        end
        default: state <= STATE_IDLE;
      endcase
    end
  end
endmodule

