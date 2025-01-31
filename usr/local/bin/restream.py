import configparser
import argparse
import socket
import time
import logging
from flask import Flask, Response
from waitress import serve

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Load parameters from the configuration file
def load_config(config_path):
    config = configparser.ConfigParser()
    config.read(config_path)
    return {
        "mjpeg_addr": config.get("MJPEG_Source", "MJPEG_ADDR", fallback="127.0.0.1"),
        "mjpeg_port": config.getint("MJPEG_Source", "MJPEG_PORT", fallback=8012),
        "bind_addr": config.get("HTTP_Stream", "BIND_ADDR", fallback="0.0.0.0"),
        "bind_port": config.getint("HTTP_Stream", "BIND_PORT", fallback=8081)
    }

# Parse command-line arguments
parser = argparse.ArgumentParser(description="MJPEG Streaming Server")
parser.add_argument("-c", "--config", required=True, help="Path to configuration file")
args = parser.parse_args()

# Load configuration
config = load_config(args.config)

app = Flask(__name__)
BOUNDARY_STRING = "--ThisRandomString"

MJPEG_ADDR = config["mjpeg_addr"]
MJPEG_PORT = config["mjpeg_port"]
BIND_ADDR = config["bind_addr"]
BIND_PORT = config["bind_port"]

def generate_stream():
    while True:
        try:
            logging.info(f"Connecting to MJPEG source at {MJPEG_ADDR}:{MJPEG_PORT}")
            with socket.create_connection((MJPEG_ADDR, MJPEG_PORT)) as sock:
                logging.info("Connection established. Streaming data...")
                while True:
                    data = sock.recv(4096)
                    if not data:
                        logging.warning("No more data received. Reconnecting...")
                        break
                    yield data
        except socket.error as e:
            logging.error(f"Error connecting to {MJPEG_ADDR}:{MJPEG_PORT}: {e}")
            time.sleep(1)

@app.route('/')
def mjpeg_stream():
    logging.info("Client connected. Streaming MJPEG...")
    headers = {
        "Content-Type": f"multipart/x-mixed-replace; boundary={BOUNDARY_STRING}"
    }
    return Response(generate_stream(), headers=headers)

if __name__ == '__main__':
    logging.info(f"Starting MJPEG streaming server on {BIND_ADDR}:{BIND_PORT}")
    serve(app, host=BIND_ADDR, port=BIND_PORT)
