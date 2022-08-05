import serial
import time
import sys

ser = serial.Serial(
    port='/dev/ttyUSB1',
    baudrate=9600,
    parity=serial.PARITY_NONE,
    stopbits=serial.STOPBITS_ONE,
    bytesize=serial.EIGHTBITS
)
ser.flushInput()
ser.flushOutput()

def get():
    rx = int.from_bytes(ser.read(1), byteorder='big')
    #print(f">{hex(rx)}")
    return rx

def put(tx):
    ser.write(tx.to_bytes(1, byteorder='big'))
    #print(f"<{hex(tx)}")

def ack():
    put(0)

with open(sys.argv[1]) as f:
    lines = f.read()
    lines = lines.split('\n')[:-1]
    mem = []
    for i in range(len(lines)):
        r = {}
        r['data'] = int(lines[i],16)
        r['addr'] = i * 4
        mem.append(r)

# state = "START"
put(0)
state = "IDLE"
raddr = 0
waddr = 0
wdata = 0
while(1):
    if state == "IDLE":
        rx = get()
        if rx == 0x0F:
            state = "W0"
        elif rx == 0xF0:
            state = "R0"
        else:
            print("Invalid IDLE CMD")
            assert False

        ack()

    elif state in ["R0", "R1", "R2", "R3"]:

        rx = get()

        raddr >>= 8
        raddr |= rx << 24
        if state == "R0":
            state = "R1"
        elif state == "R1":
            state = "R2"
        elif state == "R2":
            state = "R3"
        else:
            state = "RD0"
        ack()

    elif state in ["RD0", "RD1", "RD2", "RD3"]:

        if state == "RD0":
            for m in mem:
                if m['addr'] == raddr:
                    rdata = m['data']
                    break
            state = "RD1"
        elif state == "RD1":
            state = "RD2"
        elif state == "RD2":
            state = "RD3"
        else:
            state = "IDLE"
            print(f"0x{raddr:08x} > 0x{rdata:08x}")
        put(rdata & 0xFF)
        rdata >>= 8
        get()

    elif state in ["W0", "W1", "W2", "W3"]:

        rx = get()

        waddr >>= 8
        waddr |= rx << 24
        if state == "W0":
            state = "W1"
        elif state == "W1":
            state = "W2"
        elif state == "W2":
            state = "W3"
        else:
            state = "WD0"
        ack()

    elif state in ["WD0", "WD1", "WD2", "WD3"]:

        rx = get()

        wdata >>= 8
        wdata |= rx << 24
        if state == "WD0":
            state = "WD1"
        elif state == "WD1":
            state = "WD2"
        elif state == "WD2":
            state = "WD3"
        else:
            state = "IDLE"

            found = False
            for m in mem:
                if m['addr'] == waddr:
                    m['data'] = wdata
                    found = True

            if not found:
                r = {}
                r['addr'] = waddr
                r['data'] = wdata
                mem.append(r)

            print(f"0x{waddr:08x} < 0x{wdata:08x}")
        ack()

