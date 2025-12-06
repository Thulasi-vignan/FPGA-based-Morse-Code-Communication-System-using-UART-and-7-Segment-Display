`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/19/2025 04:29:21 PM
// Design Name: 
// Module Name: uart_rx
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

module uart_rx (
  input clk,
  input rst,
  input rx,                 // UART RX input signal (from Bluetooth module TX)
  output reg [7:0] data_out, // Received 8-bit data

  output reg valid         // Data valid pulse (one clock cycle)
 );
 reg tick;
reg  [2:0]  bit_index  ;

  // Counters and registers for timing and data sampling.
  reg [15:0] tick_counter;   // Counts clock ticks to generate baud timing

  reg [7:0]  rx_shift_reg;   // Shift register for received data

  // Define states for the receiver FSM.
  localparam STATE_IDLE  = 2'd0;
  localparam STATE_START = 2'd1;
  localparam STATE_DATA  = 2'd2;
  localparam STATE_STOP  = 2'd3;

reg [1:0] state;

parameter BAUD_COUNT = 10417;
parameter HALF_BAUD = BAUD_COUNT / 2;

 reg [15:0] counter;
  
  
   always @(posedge clk or posedge rst) begin
    if (rst) begin
      counter <= 0;
      tick    <= 0;
    end else 
 
    begin
      if (counter == 5207) begin
        counter <= 0;
        tick    <= 1;
      end else begin
        counter <= counter + 1;
        tick    <= 0;
      end
    end
  end
  

  always @(posedge clk or posedge rst) begin
    if (rst) begin
    
      state        <= STATE_IDLE;
      tick_counter <= 0;
      bit_index    <= 0;
      rx_shift_reg <= 0;
      data_out     <= 0;
      valid        <= 0;
    end 
    else  begin
      
      case (state)
        // Wait for the start bit (rx goes low).
     STATE_IDLE: begin
          valid        <= 0;  // Clear valid flag each cycle.
          tick_counter <= 0;
          bit_index    <= 0;
          if (rx == 1'b0) begin  // Start bit detected (active low).
            state <= STATE_START;
          end else begin
            state <= STATE_IDLE;
          end
        end

        // In the start state, wait for half a bit period to sample in the middle.
        STATE_START: begin
          if (tick_counter < (BAUD_COUNT / 2) - 1) begin
            tick_counter <= tick_counter + 1;
          end else begin
            tick_counter <= 0;
            // Sample the start bit to ensure it's still low.
            if (rx == 1'b0) begin
              state <= STATE_DATA;
            end else begin
              state <= STATE_IDLE;  // False start, return to idle.
            end
          end
        end

        // Sample the 8 data bits.
        STATE_DATA: begin
          if (tick_counter < BAUD_COUNT - 1) begin
            tick_counter <= tick_counter + 1;
          end else begin
            tick_counter <= 0;
            // Sample the current data bit.
            rx_shift_reg[bit_index] <= rx;
            if (bit_index < 7) begin
              bit_index <= bit_index + 1;
              state     <= STATE_DATA;
            end else begin
              bit_index <= 0;
              state     <= STATE_STOP;
            end
          end
        end

        // Sample the stop bit.
        STATE_STOP: begin
          if (tick_counter < BAUD_COUNT - 1) begin
            tick_counter <= tick_counter + 1;
          end else begin
            tick_counter <= 0;
            // Check the stop bit (should be high for a valid frame).
            if (rx == 1'b1) begin
              data_out <= rx_shift_reg;
              valid    <= 1;  // Signal valid data for one clock cycle.
            end
            state <= STATE_IDLE;  // Return to idle for the next frame.
          end
        end

        default: state <= STATE_IDLE;
      endcase
    end
   
  end

endmodule
