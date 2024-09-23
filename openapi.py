import http.server
import socketserver

openapi_file_path = "path/to/your/openapi.json"

with socketserver.TCPServer(("", 9091), http.server.SimpleHTTPRequestHandler) as httpd:
    print(f"Serving at http://localhost:9091")
    httpd.serve_forever()
