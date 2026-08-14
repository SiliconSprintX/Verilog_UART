# UART Verilog Design and Testbench

![Verilog](https://img.shields.io/badge/HDL-Verilog-blue)
![UART](https://img.shields.io/badge/Protocol-UART-green)
![RTL Design](https://img.shields.io/badge/Design-RTL-orange)
![Simulation](https://img.shields.io/badge/Simulation-Icarus%20Verilog-lightgrey)

## 📌 Project Overview

This project implements a simple **UART (Universal Asynchronous Receiver Transmitter)** using **Verilog HDL**.

The design includes both **UART transmission and reception** in a single Verilog module. A simple Verilog testbench is used to simulate the UART communication using a **TX-to-RX loopback connection**.

The project is designed as a beginner-friendly RTL project to understand:

* UART communication
* Serial data transmission
* Serial data reception
* Start and stop bits
* Shift registers
* Bit counters
* Clock-based bit timing
* Basic RTL design
* Verilog testbench development
* Simulation and waveform analysis

---

# 🎯 Project Objectives

The main objectives of this project are:

* Understand the basic UART protocol.
* Design a UART transmitter using Verilog.
* Design a UART receiver using Verilog.
* Transmit 8-bit data serially.
* Receive serial data and convert it back to 8-bit parallel data.
* Implement start and stop bits.
* Implement configurable bit timing using `CLKS_PER_BIT`.
* Create a simple Verilog testbench.
* Perform TX-to-RX loopback testing.
* Verify transmitted and received data.
* Generate and analyze simulation waveforms.

---

# 🔷 What is UART?

**UART (Universal Asynchronous Receiver Transmitter)** is a hardware communication protocol used for serial data transmission between two devices.

UART is **asynchronous**, which means that the transmitter and receiver do not use a shared clock signal for communication.

Instead, both sides must operate using the same communication timing, commonly represented by the **baud rate**.

Typical UART baud rates include:

```text
9600
19200
38400
57600
115200
```

This project implements a simple UART configuration using:

```text
8 Data Bits
No Parity
1 Stop Bit
```

This is commonly known as **8-N-1 UART**.

---

# 📡 UART Frame Format

The UART frame used in this project consists of:

```text
Idle    Start        Data Bits                         Stop
  1       0       D0 D1 D2 D3 D4 D5 D6 D7                1
  │       │        │                    │                │
  └───────┴────────┴────────────────────┴────────────────┘
```

### Frame Structure

| Field     | Size | Description                |
| --------- | ---: | -------------------------- |
| Idle      |    1 | TX line remains HIGH       |
| Start Bit |    1 | Logic LOW                  |
| Data      |    8 | Data transmitted LSB first |
| Parity    |    0 | Not implemented            |
| Stop Bit  |    1 | Logic HIGH                 |

Therefore, one complete UART frame contains:

```text
1 Start Bit + 8 Data Bits + 1 Stop Bit = 10 Bits
```

---

# 🧩 Project Architecture

The UART design contains both the transmitter and receiver inside a single `uart` module.

```text
                    ┌───────────────────┐
                    │     UART MODULE   │
                    │                   │
     tx_data[7:0] ─►│   TRANSMITTER     │
     tx_start ─────►│        │          │
                    │        ▼          │
                    │       TX ───────────────┐
                    │                         │
                    │                         │
                    │       RX ◄──────────────┘
                    │        │                │
                    │        ▼                │
                    │    RECEIVER             │
                    │        │                │
                    │        ▼                │
                    │   rx_data[7:0]          │
                    │   rx_done               │
                    │                         │
                    └─────────────────────────┘

                         TX → RX
                       LOOPBACK
```

The testbench directly connects:

```verilog
assign rx = tx;
```

Therefore, every byte transmitted by the UART transmitter is automatically received by the UART receiver.

---

# 🚀 UART Transmitter

The transmitter converts an 8-bit parallel value into a serial UART frame.

### TX Data Flow

```text
              tx_data[7:0]
                   │
                   ▼
           ┌───────────────┐
           │ TX Shift      │
           │ Register      │
           └───────┬───────┘
                   │
                   ▼
           ┌───────────────┐
           │ Bit Counter   │
           └───────┬───────┘
                   │
                   ▼
           ┌───────────────┐
           │ TX Timing     │
           └───────┬───────┘
                   │
                   ▼
                  TX
```

The transmitter generates the following sequence:

```text
START → D0 → D1 → D2 → D3 → D4 → D5 → D6 → D7 → STOP
```

### TX Operation

1. UART waits in the idle state.
2. `tx_start` initiates transmission.
3. The 8-bit input data is loaded into the shift register.
4. A start bit (`0`) is transmitted.
5. Data bits are transmitted **LSB first**.
6. A stop bit (`1`) is transmitted.
7. `tx_busy` becomes inactive after transmission is completed.
8. The TX line returns to the idle HIGH state.

---

# 📥 UART Receiver

The receiver converts the incoming serial UART frame into an 8-bit parallel value.

### RX Data Flow

```text
                    RX
                    │
                    ▼
             ┌──────────────┐
             │ Start Bit    │
             │ Detection    │
             └──────┬───────┘
                    │
                    ▼
             ┌──────────────┐
             │ Bit Timing   │
             └──────┬───────┘
                    │
                    ▼
             ┌──────────────┐
             │ RX Shift     │
             │ Register     │
             └──────┬───────┘
                    │
                    ▼
             ┌──────────────┐
             │ Bit Counter  │
             └──────┬───────┘
                    │
                    ▼
             ┌──────────────┐
             │ RX Data      │
             │ Register     │
             └──────┬───────┘
                    │
                    ▼
                rx_data[7:0]
```

### RX Operation

1. The receiver waits for the RX line to go LOW.
2. The LOW level is detected as a possible start bit.
3. The receiver waits for the appropriate sampling time.
4. The 8 data bits are sampled.
5. Received bits are stored in the RX shift register.
6. After the data bits are received, the stop bit is processed.
7. The received byte is transferred to `rx_data`.
8. `rx_done` is asserted for one clock cycle.

---

# ⏱️ Bit Timing

The design uses a parameter called:

```verilog
parameter CLKS_PER_BIT = 10;
```

`CLKS_PER_BIT` determines how many system-clock cycles are used for one UART bit.

For this project:

```text
CLKS_PER_BIT = 10
```

The transmitter and receiver use this value to control their serial bit timing.

### Timing Concept

```text
System Clock:

_‾_‾_‾_‾_‾_‾_‾_‾_‾_‾_‾_‾_‾_‾_

UART Bit:

__________          __________
          |        |
          |        |
          |        |
          <-------->
        CLKS_PER_BIT
```

The value can be changed when instantiating the UART module:

```verilog
uart #(
    .CLKS_PER_BIT(10)
) uut (
    ...
);
```

---

# 🔢 Example Transmission

Consider:

```text
tx_data = 8'h41
```

`8'h41` is the ASCII value for the character:

```text
A
```

Binary representation:

```text
8'h41 = 0100_0001
```

UART transmits the data **LSB first**:

```text
D0 = 1
D1 = 0
D2 = 0
D3 = 0
D4 = 0
D5 = 0
D6 = 1
D7 = 0
```

Therefore, the UART frame is:

```text
Start | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop

  0   |  1 |  0 |  0 |  0 |  0 |  0 |  1 |  0 |  1
```

---

# 🔄 TX-to-RX Loopback

The testbench uses a simple loopback connection:

```verilog
assign rx = tx;
```

This means the UART transmitter output is directly connected to the UART receiver input.

### Loopback Flow

```text
          ┌─────────────────────┐
          │       UART          │
          │                     │
          │   TX          RX    │
          │    │           ▲    │
          │    │           │    │
          └────┼───────────┼────┘
               │           │
               └───────────┘
                  LOOPBACK
```

The testbench sends data through TX and checks whether the same data is correctly received through RX.

---

# 🧪 Testbench

The project includes a simple Verilog testbench:

```text
uart_tb.v
```

The testbench performs the following operations:

1. Generates the system clock.
2. Applies reset.
3. Initializes UART inputs.
4. Sends test data through the transmitter.
5. Connects TX directly to RX.
6. Waits for `rx_done`.
7. Displays the received data.
8. Compares transmitted and received data.
9. Reports `PASS` or `FAIL`.
10. Generates a VCD waveform file.

---

# 🧪 Test Cases

The current testbench contains three test cases.

### Test 1 — ASCII `A`

```text
TX DATA = 8'h41
RX DATA = 8'h41
RESULT  = PASS
```

### Test 2 — `55`

```text
TX DATA = 8'h55
RX DATA = 8'h55
RESULT  = PASS
```

### Test 3 — `AA`

```text
TX DATA = 8'hAA
RX DATA = 8'hAA
RESULT  = PASS
```

These values are useful for observing different bit patterns during simulation.

---

# 📊 Expected Simulation Output

The testbench displays the transmitted and received data.

Expected output:

```text
--------------------------------
TRANSMITTING : 41
RECEIVED     : 41
RESULT       : PASS
--------------------------------

--------------------------------
TRANSMITTING : 55
RECEIVED     : 55
RESULT       : PASS
--------------------------------

--------------------------------
TRANSMITTING : AA
RECEIVED     : AA
RESULT       : PASS
--------------------------------
UART TEST COMPLETED
--------------------------------
```

The exact formatting may depend on the simulator being used.

---

# 📈 Waveform Generation

The testbench generates a VCD waveform file using:

```verilog
$dumpfile("uart.vcd");
$dumpvars(0, uart_tb);
```

The generated file can be opened using **GTKWave**.

### Important Signals to Observe

```text
clk
rst
tx_start
tx_data
tx
tx_busy
rx
rx_data
rx_done
```

The waveform can be used to observe:

* Reset operation
* TX start
* UART start bit
* Data bits
* Stop bit
* TX busy period
* RX sampling
* Received data
* RX completion

---

# 📁 Project Structure

```text
UART-Verilog/
│
├── README.md
│
├── uart.v
│
├── uart_tb.v
│
└── uart.vcd
```

### File Description

| File        | Description              |
| ----------- | ------------------------ |
| `README.md` | Project documentation    |
| `uart.v`    | UART RTL design          |
| `uart_tb.v` | Verilog testbench        |
| `uart.vcd`  | Simulation waveform file |

A waveform screenshot can also be added to the repository:

```text
waveform.png
```

---

# 🔌 UART Module Interface

The top-level UART module is:

```verilog
module uart (
    input        clk,
    input        rst,

    input        tx_start,
    input [7:0]  tx_data,
    output reg   tx,
    output reg   tx_busy,

    input        rx,
    output reg [7:0] rx_data,
    output reg       rx_done
);
```

### Input Signals

| Signal     | Width | Description          |
| ---------- | ----: | -------------------- |
| `clk`      |     1 | System clock         |
| `rst`      |     1 | Active-high reset    |
| `tx_start` |     1 | Starts transmission  |
| `tx_data`  |     8 | Data to transmit     |
| `rx`       |     1 | Serial receive input |

### Output Signals

| Signal    | Width | Description                    |
| --------- | ----: | ------------------------------ |
| `tx`      |     1 | Serial transmit output         |
| `tx_busy` |     1 | Indicates active transmission  |
| `rx_data` |     8 | Received parallel data         |
| `rx_done` |     1 | Indicates reception completion |

### Parameter

| Parameter      | Default | Description                         |
| -------------- | ------: | ----------------------------------- |
| `CLKS_PER_BIT` |    `10` | Number of clock cycles per UART bit |

---

# 🛠️ Tools Used

* **Verilog HDL** — RTL design and testbench
* **Icarus Verilog** — Simulation
* **GTKWave** — Waveform analysis
* **Git** — Version control
* **GitHub** — Project hosting

The design can also be simulated using other Verilog-compatible simulators such as ModelSim, QuestaSim, or Vivado Simulator.

---

# ▶️ Running the Simulation with Icarus Verilog

### 1. Compile the design and testbench

```bash
iverilog -o uart_sim uart.v uart_tb.v
```

### 2. Run the simulation

```bash
vvp uart_sim
```

### 3. Open the waveform

```bash
gtkwave uart.vcd
```

---

# 📚 Concepts Covered

This project provides hands-on practice with:

### Verilog HDL

* Modules
* Inputs and outputs
* Registers
* Parameters
* Counters
* Shift registers
* `always` blocks
* Sequential logic
* Asynchronous reset
* Non-blocking assignments
* Testbench development
* `$display`
* `$dumpfile`
* `$dumpvars`

### Digital Design

* Finite State Machine concepts
* Serial communication
* Parallel-to-serial conversion
* Serial-to-parallel conversion
* Bit counting
* Shift-register operation
* Clock-based timing

### UART

* UART frame structure
* Start bit
* Data bits
* Stop bit
* LSB-first transmission
* Asynchronous communication
* TX operation
* RX operation
* Loopback testing

---

# 📈 Project Flow

```text
Understand UART Protocol
          ↓
Design UART TX
          ↓
Design UART RX
          ↓
Add Bit Timing
          ↓
Create UART Module
          ↓
Write Verilog Testbench
          ↓
Connect TX → RX
          ↓
Transmit Test Data
          ↓
Receive Test Data
          ↓
Compare TX and RX Data
          ↓
Generate Waveform
          ↓
Analyze Simulation
```

---

# 🚀 Future Improvements

The current project implements a basic UART configuration.

Possible improvements for future versions include:

* Configurable baud rate
* Configurable data width
* Parity support
* Even/odd parity
* Multiple stop bits
* Parity error detection
* Frame error detection
* TX FIFO
* RX FIFO
* APB interface
* Interrupt support
* FPGA implementation

---

# 📌 Project Status

**Status: Completed – Basic UART TX/RX Simulation**

The current version demonstrates basic UART transmission and reception using a Verilog RTL design and a simple loopback testbench.

---

# 🎓 Learning Outcome

This project helped build a practical understanding of the complete basic RTL development flow:

```text
UART Protocol
      ↓
RTL Architecture
      ↓
Verilog Coding
      ↓
Testbench Development
      ↓
Simulation
      ↓
Data Checking
      ↓
Waveform Analysis
```

The project demonstrates how a simple UART can be designed and tested using **Verilog HDL**.

---

# 👩‍💻 Author

**Saakshi**

### Areas of Interest

* RTL Design
* Verilog HDL
* Digital Design
* VLSI
* ASIC Design
* FPGA
* Embedded Systems

---

# ⭐ Project

If you found this project useful, feel free to ⭐ the repository and explore the code.

---

## 📌 Keywords

`UART` `Verilog` `UART Verilog` `RTL Design` `Digital Design` `VLSI` `ASIC` `FPGA` `HDL` `UART Transmitter` `UART Receiver` `UART Testbench` `Baud Rate` `Serial Communication` `Verilog Simulation` `GTKWave` `Loopback`
