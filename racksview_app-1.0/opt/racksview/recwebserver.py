import os
import argparse
import configparser
import socket
import logging
from flask import Flask, send_from_directory, render_template_string, request
from waitress import serve  # Use Waitress

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Simple Flask file server")
parser.add_argument("--config", help="Path to the config file", default=None)
args = parser.parse_args()

# Load configuration
config = configparser.ConfigParser()
if args.config and os.path.exists(args.config):
    config.read(args.config)

BASEDIR = config.get("server", "basedir", fallback="/media/usb/video")
PORT = config.getint("server", "port", fallback=80)

# Get the hostname of the server
HOSTNAME = socket.gethostname()

# Create Flask app
app = Flask(__name__)

@app.route("/", defaults={"subpath": ""})
@app.route("/<path:subpath>")
def list_files(subpath):
    folder_path = os.path.join(BASEDIR, subpath)
    logging.info(f"Listing files in {folder_path}")

    if not os.path.exists(folder_path):
        return "Folder not found", 404

    if os.path.isfile(folder_path):  # If it's a file, serve it directly
        return serve_file(subpath)

    # If it's a directory, list contents
    items = sorted(os.listdir(folder_path))
    dirs = [item for item in items if os.path.isdir(os.path.join(folder_path, item))]
    files = [(item, os.path.getsize(os.path.join(folder_path, item)) / (1024 * 1024)) 
             for item in items if os.path.isfile(os.path.join(folder_path, item))]

    # Fix `../` link handling for top-level navigation
    parent_path = "/" if "/" not in subpath else "/" + subpath.rsplit("/", 1)[0]

    # Format the displayed path
    display_path = "/" + subpath if subpath else "/"

    # Get host without port (if needed)
    base_host = request.host.split(":")[0]
    live_video_url = f"http://{base_host}:8082/"

    return render_template_string("""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>{{ hostname }} video recordings - {{ display_path }}</title>
            <style>
                body { font-family: "Courier New", Courier, monospace; margin: 20px; }
                h3 { margin-bottom: 10px; }
                ul { list-style-type: none; padding: 0; }
                li { padding: 5px 0; font-size: 16px; }
                .size { color: gray; font-size: 14px; margin-left: 10px; }
                a { text-decoration: none; color: #0066cc; }
                a:hover { color: #004499; }
                .live-video { font-size: 18px; font-weight: bold; margin-bottom: 15px; }
            </style>
        </head>
        <body>
            <h3>{{ hostname }} <a href="{{ live_video_url }}" class="live-video">🔴 Live Video</a></h3>
            <h3>Video recordings - <span style="color: gray;">{{ display_path }}</span></h3>
            <ul>
                {% if subpath %}
                    <li><a href="{{ parent_path }}">⤴️..</a></li>
                {% endif %}
                {% for d in dirs %}
                    <li><a href="{{ '/' + (subpath + '/' + d if subpath else d) }}">📂 {{ d }}</a></li>
                {% endfor %}
                {% for f, size in files %}
                    <li>
                        <a href="{{ '/' + (subpath + '/' + f if subpath else f) }}">📼 {{ f }}</a>
                        <span class="size">({{ "%.2f"|format(size) }} MB)</span>
                    </li>
                {% endfor %}
            </ul>
        </body>
        </html>
    """, hostname=HOSTNAME, display_path=display_path, subpath=subpath, dirs=dirs, files=files, parent_path=parent_path, live_video_url=live_video_url)

@app.route("/<path:filename>")
def serve_file(filename):
    """ Serve a file for download. """
    directory = os.path.dirname(filename)
    filename = os.path.basename(filename)
    logging.info(f"Downloading file: {filename}")
    return send_from_directory(os.path.join(BASEDIR, directory), filename, as_attachment=True)

if __name__ == "__main__":
    logging.info(f"Starting Waitress on port {PORT}...")
    serve(app, host="0.0.0.0", port=PORT)
