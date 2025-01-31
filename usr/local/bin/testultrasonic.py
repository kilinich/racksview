import serial

def read_distance():
    ser = serial.Serial('/dev/ttyAMA0', baudrate=115200, bytesize=8, parity='N', stopbits=1, timeout=1)
    
    try:
        buffer = bytearray()
        while True:
            byte = ser.read(1)
            if byte:
                buffer.append(byte[0])
                
                if len(buffer) > 4:
                    buffer.pop(0)
                
                if len(buffer) == 4 and buffer[0] == 0xFF:
                    start_byte, data_h, data_l, checksum = buffer
                    calculated_checksum = (start_byte + data_h + data_l) & 0x00FF
                    
                    if calculated_checksum == checksum:
                        distance = (data_h << 8) + data_l
                        print(distance)
                        
                        buffer.clear()
    except KeyboardInterrupt:
        pass
    finally:
        ser.close()

if __name__ == "__main__":
    read_distance()
