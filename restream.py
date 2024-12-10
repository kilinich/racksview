from flask import Flask, Response
import socket

app = Flask(__name__)

TCP_SERVER_HOST = "127.0.0.1"
TCP_SERVER_PORT = 8080
BOUNDARY_STRING = "--ThisRandomString"  # Граница для MJPEG

def generate_stream():
    """Генератор потока MJPEG через сокетное подключение."""
    try:
        with socket.create_connection((TCP_SERVER_HOST, TCP_SERVER_PORT)) as sock:
            while True:
                data = sock.recv(1024)  # Читаем данные порциями
                if not data:  # Если поток закрыт
                    break
                yield data
    except socket.error as e:
        print(f"Ошибка подключения к {TCP_SERVER_HOST}:{TCP_SERVER_PORT}: {e}")
        yield b''

@app.route('/')
def mjpeg_stream():
    """Эндпоинт для трансляции MJPEG в браузер."""
    headers = {
        "Content-Type": f"multipart/x-mixed-replace; boundary={BOUNDARY_STRING}"
    }
    return Response(generate_stream(), headers=headers)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)
