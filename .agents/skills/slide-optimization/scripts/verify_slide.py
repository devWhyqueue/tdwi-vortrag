import time
import http.server
import socketserver
import threading
import argparse
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')
import os
from playwright.sync_api import sync_playwright

PORT = 8085
DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "presentation"))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

def start_server():
    socketserver.TCPServer.allow_reuse_address = True
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"Serving at port {PORT}")
        httpd.serve_forever()

def main():
    parser = argparse.ArgumentParser(description="Verify Reveal.js slide rendering.")
    parser.add_argument("--index", type=int, required=True, help="0-based Reveal.js slide index to navigate to (e.g. 23)")
    parser.add_argument("--output", type=str, required=True, help="Absolute or relative path to save the screenshot to")
    args = parser.parse_args()

    # Start local HTTP server in a daemon thread
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    time.sleep(1.5) # Give server time to bind and start
    
    print("Launching Playwright...")
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1280, "height": 720})
        page = context.new_page()
        
        url = f"http://localhost:{PORT}/#/{args.index}"
        print(f"Navigating to {url}")
        page.goto(url)
        
        # Wait for Reveal.js transitions and animations to settle
        print("Waiting for page load and animations...")
        page.wait_for_timeout(3000)
        
        abs_output = os.path.abspath(args.output)
        os.makedirs(os.path.dirname(abs_output), exist_ok=True)
        page.screenshot(path=abs_output)
        print(f"Screenshot successfully saved to {abs_output}")
        
        browser.close()

if __name__ == "__main__":
    main()
