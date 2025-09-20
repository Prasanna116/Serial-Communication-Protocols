# Serial-Communication-Protocols
This project presents the design and verification of Serial Communication Protocols such as **UART**, **SPI**, and **I2C** protocols. These were designed using Verilog HDL using Open-Source tool - ICARUS Verilog and debugged and verified using GTKWave. The goal is to design, simulate, and understand industry-standard serial communication protocols at the RTL (Register Transfer Level). 

---

## 🔹 Implemented Protocols  

### 1. **UART (Universal Asynchronous Receiver/Transmitter)**
- Supports **TX and RX** modules.  
- Configurable **baud rate generator**.  
- **APB master/slave integration** for system-level testing.  
- Testbenches for both TX and RX.  

📘 **Block Diagram**  
![UART Block Diagram](images/uart_block.png)  

📘 **Timing Diagram (TX Example)**  
![UART Timing](images/uart_timing.png)  

---

### 2. **SPI (Serial Peripheral Interface)**
- Supports all **4 SPI modes** (CPOL, CPHA).  
- Parameterizable **clock divider**.  
- **Full-duplex communication** between Master and Slave.  

📘 **Block Diagram**  
![SPI Block Diagram](images/spi_block.png)  

📘 **Timing Diagram (Mode 0 Example)**  
![SPI Timing](images/spi_timing.png)  

---

### 3. **I2C (Inter-Integrated Circuit)**
- Master and Slave implementations.  
- Supports **7-bit addressing**.  
- Handles **ACK/NACK** conditions.  
- Data transfer synchronized with **SCL**.  

📘 **Block Diagram**  
![I2C Block Diagram](images/i2c_block.png)  

📘 **Timing Diagram (Write Transaction)**  
![I2C Timing](images/i2c_timing.png)  

---

## 🛠️ Tools Used
- **HDL**: Verilog  
- **Simulation**: ModelSim / Icarus Verilog  
- **Waveform Analysis**: GTKWave  
- **Version Control**: Git + GitHub  

---
