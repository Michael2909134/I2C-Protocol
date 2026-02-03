# I2C-Protocol
The Inter-Integrated Circuit (I²C) protocol is a synchronous two-wire serial communication standard widely used in embedded and FPGA systems. It combines the simplicity of UART with the multi-device capability of SPI, allowing multiple masters and slaves to communicate on the same bus using minimal wiring.
<br>

***Key Features***
<br>
Two wires: SDA (data) and SCL (clock)
<br>
Synchronous communication
<br>
Open-drain bus architecture
<br>
Multi-master & multi-slave support
<br>

***Bus Operation***
<br>
-Both SDA and SCL are open-drain
<br>
-Devices can pull lines LOW, not HIGH
<br>
-Pull-up resistors maintain default HIGH state
<br>
-Prevents bus contention and short circuits
<br>

***Speed Modes***
<br>
-Standard: 100 kbps
<br>
-Fast: 400 kbps
<br>
-High-Speed: up to 3.4 Mbps
<br>

***System Architecture***
<br>
.I²C Master
<br>
Generates SCL
<br>
Initiates communication
<br>
.I²C Slave
<br>
Responds to matching 7-bit address
<br>
.I²C Bus
<br>
Shared SDA and SCL lines

📦 Data Frame Format

Start Condition

7-bit Address

Read/Write Bit

ACK / NACK

Data Byte(s)

Stop Condition
