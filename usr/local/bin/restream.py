import argparse
import logging
from flask import Flask, Response
import socket
import time
from waitress import serve

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

parser = argparse.ArgumentParser(description="MJPEG HTTP Stream Server")
parser.add_argument("--tcp_host", type=str, default="127.0.0.1", help="TCP server host")
parser.add_argument("--tcp_port", type=int, default=8080, help="TCP server port")
parser.add_argument("--http_host", type=str, default="0.0.0.0", help="HTTP server host")
parser.add_argument("--http_port", type=int, default=8081, help="HTTP server port")
args = parser.parse_args()

app = Flask(__name__)

TCP_SERVER_HOST = args.tcp_host
TCP_SERVER_PORT = args.tcp_port
BOUNDARY_STRING = "--ThisRandomString"

def generate_stream():
    while True:
        try:
            with socket.create_connection((TCP_SERVER_HOST, TCP_SERVER_PORT)) as sock:
                logger.info(f"Connected to {TCP_SERVER_HOST}:{TCP_SERVER_PORT}")
                while True:
                    data = sock.recv(4096)
                    if not data:
                        break
                    yield data
        except socket.error as e:
            logger.error(f"Error connecting to {TCP_SERVER_HOST}:{TCP_SERVER_PORT}: {e}")
            time.sleep(1)

@app.route('/')
def mjpeg_stream():
    logger.info("Received HTTP request for MJPEG stream")
    headers = {"Content-Type": f"multipart/x-mixed-replace; boundary={BOUNDARY_STRING}"}
    return Response(generate_stream(), headers=headers)

if __name__ == '__main__':
    logger.info(f"Starting MJPEG HTTP Stream Server on {args.http_host}:{args.http_port}")
    serve(app, host=args.http_host, port=args.http_port)
