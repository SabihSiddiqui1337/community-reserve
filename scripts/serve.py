"""Static server for the Flutter web build with no-cache headers, so fresh
builds always load (no hard-refresh needed). Serves ../build/web on :8090."""
import functools
import http.server
import os
import socketserver

ROOT = os.path.join(os.path.dirname(__file__), "..", "build", "web")


class NoCacheHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")
        super().end_headers()


socketserver.TCPServer.allow_reuse_address = True
handler = functools.partial(NoCacheHandler, directory=os.path.abspath(ROOT))
with socketserver.TCPServer(("127.0.0.1", 8090), handler) as httpd:
    print(f"Serving {os.path.abspath(ROOT)} at http://127.0.0.1:8090 (no-cache)")
    httpd.serve_forever()
