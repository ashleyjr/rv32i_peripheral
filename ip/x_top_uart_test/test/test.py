import serial
import time

ser = serial.Serial(
    port='/dev/ttyUSB1',
    baudrate=115200,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)


for tx in range(0, 256):
    ser.write(tx.to_bytes(1, byteorder='big'))
    rx = int.from_bytes(ser.read(1), byteorder='big')
    print(f"{rx}={tx}")
    assert rx == tx

