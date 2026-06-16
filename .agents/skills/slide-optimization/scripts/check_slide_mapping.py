import re
import os
import sys

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

def main():
    presentation_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..", "..", "presentation"))
    html_path = os.path.join(presentation_dir, "index.html")
    ref_dir = os.path.join(presentation_dir, "reference")
    
    if not os.path.exists(html_path):
        print(f"Error: index.html not found at {html_path}")
        return
        
    with open(html_path, 'r', encoding='utf-8') as f:
        content = f.read()

    match = re.search(r'<div class="slides">([\s\S]*)', content)
    if not match:
        print("Error: No slides container found in index.html")
        return

    slides_content = match.group(1)

    sections = []
    current_depth = 0
    section_starts = []
    
    last_comment = ""
    for m in re.finditer(r'<!--([\s\S]*?)-->|<section\b|</section>', slides_content):
        full_match = m.group(0)
        if full_match.startswith('<!--'):
            last_comment = m.group(1).strip()
        elif full_match.startswith('<section'):
            if current_depth == 0:
                section_starts.append((m.start(), last_comment))
                last_comment = ""
            current_depth += 1
        elif full_match == '</section>':
            current_depth -= 1
            if current_depth == 0:
                end_pos = m.end()
                start_pos, comment = section_starts[-1]
                sections.append((slides_content[start_pos:end_pos], comment))

    print("\n" + "="*80)
    print("REVEAL.JS SLIDE INDEX & REFERENCE FILE MAPPING")
    print("="*80)
    print(f"{'Reveal.js URL':<15} | {'Physical order':<15} | {'Slide label / Comment':<40} | {'Mockup Ref PNG'}")
    print("-"*110)
    
    for idx, (sec, comment) in enumerate(sections):
        headline_match = re.search(r'<p class="slide-headline">([\s\S]*?)</p>', sec)
        headline = ""
        if headline_match:
            headline = re.sub(r'<[^>]*>', '', headline_match.group(1)).strip()
            headline = " ".join(headline.split())
        
        slide_label = ""
        for line in comment.split('\n'):
            if 'SLIDE' in line or 'COVER' in line:
                slide_label = line.replace('===', '').replace('---', '').strip()
                break
            if 'CHAPTER' in line:
                slide_label = line.replace('===', '').replace('---', '').strip()
                break
                
        if not slide_label:
            slide_label = headline[:35] + "..." if len(headline) > 35 else headline
            
        # Hardcoded correct mapping based on verified OCR slide content
        ref_mapping = "N/A"
        if idx <= 4:
            # Slides 1 to 5 map directly to slide-01.png to slide-05.png
            ref_mapping = f"slide-{idx+1:02d}.png"
        elif idx == 5:
            ref_mapping = "N/A (Chapter 1 Title Slide)"
        elif idx >= 6 and idx <= 15:
            # Slides 6 to 15 map directly to slide-06.png to slide-15.png
            ref_mapping = f"slide-{idx:02d}.png"
        elif idx == 16:
            ref_mapping = "N/A (Chapter 2 Title Slide)"
        elif idx >= 17 and idx <= 32:
            # Slides 16 to 31 map directly to slide-16.png to slide-31.png
            ref_mapping = f"slide-{idx-1:02d}.png"
        elif idx == 33:
            ref_mapping = "N/A (Chapter 3 Title Slide)"
        elif idx >= 34 and idx <= 36:
            # Slides 32 to 34 map to slide-32.png to slide-34.png
            ref_mapping = f"slide-{idx-2:02d}.png"
        elif idx == 37:
            ref_mapping = "N/A (Slide 35 - Don'ts)"
        elif idx == 38:
            ref_mapping = "N/A (Slide 36 - Schlussbild Q&A)"
        elif idx == 39:
            ref_mapping = "N/A (Slide 37 - Final Message)"
            
        url_index = f"#/{idx}"
        physical_order = f"{idx + 1}"
        print(f"{url_index:<15} | {physical_order:<15} | {slide_label:<40} | {ref_mapping}")
        
    print("="*110 + "\n")

if __name__ == "__main__":
    main()
