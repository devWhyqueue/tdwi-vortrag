import os
import time
import http.server
import socketserver
import threading
from playwright.sync_api import sync_playwright

PORT = 8087
DIRECTORY = os.path.abspath(os.path.dirname(__file__))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def start_server():
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving at port {PORT}")
        httpd.serve_forever()

def export_pdf():
    # Start local HTTP server in a daemon thread
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    time.sleep(1.5) # Give server time to bind and start
    
    print("Launching Playwright...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page()
        
        # Open reveal.js page with ?print-pdf parameter
        url = f"http://localhost:{PORT}/index.html?print-pdf"
        print(f"Navigating to {url}...")
        page.goto(url)
        
        # Wait for all slides, transitions, and dynamic elements to load
        print("Waiting for slides to load...")
        page.wait_for_timeout(5000)
        
        # Export to PDF
        output_pdf = os.path.join(DIRECTORY, "presentation.pdf")
        print(f"Generating PDF: {output_pdf}...")
        
        # PDF generation options
        page.pdf(
            path=output_pdf,
            print_background=True,
            prefer_css_page_size=True
        )
        
        print("PDF successfully generated!")
        browser.close()

if __name__ == "__main__":
    export_pdf()
