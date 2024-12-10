from flask import Flask, Response
import socket

app = Flask(__name__)

TCP_SERVER_HOST = "127.0.0.1"
TCP_SERVER_PORT = 8080
BOUNDARY_STRING = "--ThisRandomString"

def generate_stream():
    try:
        with socket.create_connection((TCP_SERVER_HOST, TCP_SERVER_PORT)) as sock:
            while True:
                data = sock.recv(4096)  
                if not data:
                    break
                yield data
    except socket.error as e:
        print(f"Error connecting to {TCP_SERVER_HOST}:{TCP_SERVER_PORT}: {e}")
        yield b''

@app.route('/')
def mjpeg_stream():
    headers = {
        "Content-Type": f"multipart/x-mixed-replace; boundary={BOUNDARY_STRING}"
    }
    return Response(generate_stream(), headers=headers)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
