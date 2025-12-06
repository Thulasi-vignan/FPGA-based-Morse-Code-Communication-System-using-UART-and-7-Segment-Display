# FPGA Morse Code Communication System (UART-Based)

This project implements a complete Morse code communication system on FPGA using Verilog HDL.  
Two Nexys A7 boards are used: one acts as the **Transmitter**, and the other acts as the **Receiver**.  
All operations—including dot/dash detection, decoding, UART transfer, buffering, and display—are implemented fully in hardware without any microcontroller.

---

## 🚀 Functionality Overview

- Detects **dot** and **dash** inputs from a push-button using precise timing counters.
- Converts Morse sequences into **ASCII characters** using a hardware-based decoder.
- Sends characters through **UART communication** to another FPGA board.
- Uses a **FIFO buffer** to handle incoming data at varying rates.
- Displays characters in real time on a **multiplexed 7-segment display**.
- Operates entirely with **hardware FSMs and synchronous logic**, ensuring deterministic timing and reliable communication.

---

## 🧠 Working Principle

### 1️⃣ **Input Handling & Debouncing**
A mechanical push-button is used to generate Morse inputs.  
A hardware debouncer removes noise and bouncing by ensuring the button remains stable for a specific duration.

### 2️⃣ **Timing-Based Dot/Dash Detection**
A high-resolution counter measures how long the button is pressed:
- Short press → **Dot**
- Long press → **Dash**

These timings follow standard Morse rules.

### 3️⃣ **Morse Decoder (LUT + Binary Tree Logic)**
The collected dots and dashes form a Morse sequence.  
This is matched against a hardware lookup table based on the Morse binary tree to generate the corresponding **ASCII character**.

### 4️⃣ **UART Transmission**
The ASCII character is sent to the receiver FPGA via UART:
- 1 Start Bit  
- 8 Data Bits  
- 1 Stop Bit  

A baud-rate generator ensures proper communication timing.

### 5️⃣ **UART Reception with Oversampling**
The receiver samples each bit multiple times to reliably detect the frame.  
It reconstructs the ASCII character and forwards it to the FIFO.

### 6️⃣ **FIFO Buffering**
The FIFO buffer prevents data loss when characters arrive faster than they can be displayed.  
It ensures smooth and continuous system operation.

### 7️⃣ **7-Segment Display Multiplexing**
The ASCII character is converted into a 7-segment pattern.  
A fast multiplexing driver refreshes each digit at high speed, giving a flicker-free display.

---

## 🛠️ Hardware Requirements

- 2 × Nexys A7 FPGA boards  
- UART jumper wire (TX → RX)  
- Common GND connection  
- Xilinx Vivado 2023+  

---


