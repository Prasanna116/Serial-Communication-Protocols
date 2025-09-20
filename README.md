# Serial-Communication-Protocols
This project presents the design and verification of Serial Communication Protocols such as **UART**, **SPI**, and **I2C** protocols. These were designed using Verilog HDL using Open-Source tool - ICARUS Verilog and debugged and verified using GTKWave. The goal is to design, simulate, and understand industry-standard serial communication protocols at the RTL (Register Transfer Level). 

---

## 🔹 Implemented Protocols  

### 1. **UART (Universal Asynchronous Receiver/Transmitter)**  
UART is a **full-duplex, asynchronous** serial communication protocol.  
- Communication is done without a clock signal; both sides agree on a **baud rate**.  
- Data is framed with **start bit, data bits, optional parity, and stop bit(s)**.  
- Widely used in **low-speed device communication** like microcontrollers, GPS modules, and Bluetooth devices.  

**Implementation Highlights:**  
- Supports **TX and RX** modules.  
- Configurable **baud rate generator**.  
- **APB master/slave integration** for system-level testing.  
- Verified with **loopback testbench**.  

---

### 2. **SPI (Serial Peripheral Interface)**  
SPI is a **synchronous, full-duplex** communication protocol used between a single **Master** and multiple **Slaves**.  
- Uses **4 signals**: MOSI (Master Out Slave In), MISO (Master In Slave Out), SCLK (Clock), and CS (Chip Select).  
- Faster than UART and I2C due to its simplicity and dedicated lines.  
- Common in **sensors, SD cards, ADC/DACs, and displays**.  

**Implementation Highlights:**  
- Supports all **4 SPI modes** (CPOL, CPHA).  
- Parameterizable **clock divider** for SCLK generation.  
- Full-duplex **Master-Slave communication**.  
- Verified with testbenches for data transfer across all modes.  

---

### 3. **I2C (Inter-Integrated Circuit)**  
I2C is a **synchronous, half-duplex, multi-master, multi-slave** protocol using only **two wires**:  
- **SDA** (Serial Data) – bidirectional data line.  
- **SCL** (Serial Clock) – clock line.  
- Devices are addressed using **7-bit (or 10-bit) addressing**.  
- Supports **ACK/NACK** for data validation.  
- Widely used in **EEPROMs, RTCs, sensors, and SoC communication**.  

**Implementation Highlights:**  
- **Master and Slave modules** implemented.  
- Supports **7-bit addressing**.  
- Handles **ACK/NACK** conditions properly.  
- Data transfer synchronized with **SCL** (edge-based sampling).  

---

## 🛠️ Tools Used
- **HDL**: Verilog  
- **Simulation**: Icarus Verilog  
- **Waveform Analysis**: GTKWave  
- **Version Control**: Git + GitHub  

---

