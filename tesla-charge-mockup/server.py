from http.server import HTTPServer, SimpleHTTPRequestHandler
from pathlib import Path
import os

ROOT = Path(__file__).resolve().parent
os.chdir(ROOT)
port = int(os.environ.get('PORT', '8765'))
print(f'Serving tesla-charge-mockup on http://127.0.0.1:{port}')
HTTPServer(('127.0.0.1', port), SimpleHTTPRequestHandler).serve_forever()
