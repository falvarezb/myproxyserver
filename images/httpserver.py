import http.server


class MyHTTPRequestHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # log request headers to stdout
        headers = "\n".join(f"{header}: {value}" for header, value in self.headers.items())
        print(f"\n==============\n{headers}==============\n")

        # and also send them back to the client
        self.send_response(200)
        self.send_header("Content-type", "text/html")
        self.end_headers()        
        headers_list = '\n'.join(f'<li>{header}: {value}</li>' for header, value in self.headers.items())
        html_content = f"""
        <html>
        <head>
            <title>Hello, World!</title>
        </head>
        <body>
            <h1>Hello, World!</h1>
            <h2>Request Headers:</h2>
            <ul>
                {headers_list}
            </ul>
        </body>
        </html>
        """
        self.wfile.write(bytes(html_content, "utf-8"))


if __name__ == "__main__":
    server_address = ("", 8000)
    httpd = http.server.HTTPServer(server_address, MyHTTPRequestHandler)
    print("Server running on http://localhost:8000")
    httpd.serve_forever()
