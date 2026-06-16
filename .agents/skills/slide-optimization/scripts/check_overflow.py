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
        httpd.serve_forever()

def main():
    parser = argparse.ArgumentParser(description="Check Reveal.js slide for vertical/horizontal overflow.")
    parser.add_argument("--index", type=int, required=True, help="0-based Reveal.js slide index (e.g. 25)")
    args = parser.parse_args()

    # Start local HTTP server in a daemon thread
    server_thread = threading.Thread(target=start_server, daemon=True)
    server_thread.start()
    time.sleep(1.5)
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(viewport={"width": 1280, "height": 720})
        page = context.new_page()
        url = f"http://localhost:{PORT}/#/{args.index}"
        page.goto(url)
        page.wait_for_timeout(2500)
        
        # Evaluate if there is any overflow in the slide or cards
        overflow_data = page.evaluate("""() => {
            const results = [];
            const activeSection = document.querySelector('.slides section.present');
            if (!activeSection) {
                return [{error: 'No active section found'}];
            }
            
            // Check active section bounds
            results.push({
                element: 'section.present',
                scrollHeight: activeSection.scrollHeight,
                clientHeight: activeSection.clientHeight,
                scrollWidth: activeSection.scrollWidth,
                clientWidth: activeSection.clientWidth,
                hasVerticalOverflow: activeSection.scrollHeight > activeSection.clientHeight,
                hasHorizontalOverflow: activeSection.scrollWidth > activeSection.clientWidth
            });
            
            // Check all cards or wrapper divs under section
            const elements = activeSection.querySelectorAll('div');
            elements.forEach((el, idx) => {
                const style = window.getComputedStyle(el);
                const isScrollable = style.overflowY === 'scroll' || style.overflowY === 'auto' || style.overflow === 'scroll' || style.overflow === 'auto';
                if (el.scrollHeight > el.clientHeight && el.clientHeight > 0) {
                    results.push({
                        id: el.id || 'div_' + idx,
                        className: el.className,
                        scrollHeight: el.scrollHeight,
                        clientHeight: el.clientHeight,
                        isScrollable: isScrollable,
                        hasVerticalOverflow: true
                    });
                }
            });
            return results;
        }""")
        
        print("DOM Overflow Inspection Results:")
        has_warnings = False
        for res in overflow_data:
            if 'error' in res:
                print(f"Error: {res['error']}")
                has_warnings = True
            elif res.get('element') == 'section.present':
                print(f"Active Slide Section: scrollHeight={res['scrollHeight']}, clientHeight={res['clientHeight']}")
                if res['hasVerticalOverflow']:
                    print("  WARNING: Active slide has vertical overflow (content exceeds viewport)!")
                    has_warnings = True
                else:
                    print("  Success: No vertical overflow on active slide.")
            else:
                print(f"Element [{res['id']}] class='{res['className']}': scrollHeight={res['scrollHeight']}, clientHeight={res['clientHeight']}")
                if not res['isScrollable']:
                    print("  WARNING: This element has vertical overflow but is NOT marked as scrollable or hidden, which could cause content cutoff or scrollbars!")
                    has_warnings = True
                else:
                    print("  Note: Element is scrollable but has overflow.")
                    
        browser.close()
        
        if has_warnings:
            print("\nVerification: FAILED (Overflow detected)")
        else:
            print("\nVerification: SUCCESS (No overflow)")

if __name__ == "__main__":
    main()
