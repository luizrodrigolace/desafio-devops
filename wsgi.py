import logging

from waitress import serve

from app import app

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("waitress")

if __name__ == "__main__":
    print("Serving on http://0.0.0.0:8000")
    serve(app, host="0.0.0.0", port=8000)
