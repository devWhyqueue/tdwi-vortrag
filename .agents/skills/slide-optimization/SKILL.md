---
name: slide-optimization
description: Guidelines and automated verification procedures for visually optimizing reveal.js slides for the KVWL Lakehouse project, maintaining domain-specific billing terminology boundaries.
---

# Slide Optimization Skill

This skill provides guidelines and automated workflows for visually optimizing Reveal.js slides in the `presentation/index.html` workspace, using draft mockups from a Google NotebookLM slide deck as inspiration.

---

## 1. Core Concept: Draft-to-Reveal Optimization

The optimization process is driven by visual comparison between the raw HTML slides and the high-fidelity draft mockup slides generated in Google NotebookLM.

### The Source Draft (Reference)
- **Location:** Draft mockups for each slide are stored as PNG files under `presentation/reference/` (named `slide-XX.png` where `XX` is the slide index).
- **Purpose:** These images serve as the "ground truth" design inspiration. They showcase the desired structure, column layouts, custom figures, card styles, and visual composition.

### Optimization Workflow
1. **Locate Reference:** Find the draft mockup PNG in `presentation/reference/` for the slide you are working on (e.g., `presentation/reference/slide-12.png`).
2. **Capture Current HTML Slide:** Run the local dev server and use the Playwright verification script to capture the actual HTML slide rendering.
3. **Analyze Discrepancies:** Compare the actual rendering and reference PNG side-by-side. Look for:
   - Layout structure (e.g., columns, centered vs. stretched layouts, spacing).
   - Component details (e.g., custom SVGs, code panel designs, margins).
   - Readability issues (e.g., font sizes, overflow/scrollbars, text-wrapping).
4. **Implement Layout in HTML/CSS:** Modify `index.html` and `styles.css` using the design tokens and standard components to replicate the mockup's visual appeal.
5. **Verify:** Re-run the Playwright verification script, check the new screenshot, and repeat until the HTML matches the visual quality of the draft mockup.

---

## 2. Design Tokens & Colors (CSS Reference)

Always stick to the CSS custom properties defined in `presentation/styles.css` rather than using raw hex codes:

| Variable | Color | Purpose / Meaning |
| :--- | :--- | :--- |
| `--navy` | `#0f172a` | Primary dark headings, titles, and high-emphasis text |
| `--navy-deep` | `#0b1325` | Extra dark accents / card headers |
| `--steel` | `#475569` | Secondary neutral headers, inactive zones |
| `--teal` | `#2a7d8f` | Primary brand accent color, active flow paths |
| `--teal-deep` | `#1c5a69` | Secondary brand color / dark brand text |
| `--panel-dark` | `#cbd5e1` | Panel borders and light gray container outlines |
| `--bg-soft` | `#f8fafc` | Soft background panel fills |
| `--font-mono` | `Consolas, ...` | Monospace code font stack |
| `--ink` | `#334155` | Primary body text |
| `--ink-muted` | `#64748b` | Subtitles and low-emphasis text |
| `--green` | `#16a34a` | Permitted states, validation matches, success cards |
| `--red` | `#dc2626` | Forbidden states, anomalies, critical warnings |
| `--amber` | `#d97706` | Architectural warnings, alert callouts |

---

## 3. Visual Design & Layout Standards

To ensure a cohesive, high-end look across all slides, adhere strictly to the following HTML/CSS design patterns:

### Fixed Footprint Containers (No Scrollbars)
- **Standard Dimensions:** Wrap content in a container with a fixed footprint of `width: 1060px; height: 425px; margin: 0 auto; box-sizing: border-box;`. This prevents vertical stretching and keeps layouts stable across slides.
- **Scrollbar Elimination:** Always set `overflow: hidden` on code panels, lists, or container boxes. Scrollbars on slides look unprofessional. Keep text sizes and line-heights compact to prevent content overflow.

### Code & Directory Tree Boxes
- **Visual Style:** Use the following styles for code boxes and directory structures:
  ```html
  <div style="background:#f4f6f7; border:1.5px solid var(--panel-dark); border-radius:8px; font-family:var(--font-mono); font-size:0.55em; line-height:1.3; padding:10px 14px; overflow:hidden; box-shadow:inset 0 1px 3px rgba(0,0,0,0.05);">
  ```
- **Directory Trees:** Format path hierarchies manually using ASCII tree characters:
  ```text
  s3://process-zone/controlling/
  ├── fact/
  │   └── belege/
  │       ├── _delta_log/
  │       │   └── 00000000000000000000.json
  │       └── part-00000-uuid.snappy.parquet
  └── dim/
      └── kostenart/
  ```
- **JSON Syntax Highlighting:** Style raw JSON characters using high-readibility span classes:
  - Braces/Colons: `#475569` (gray)
  - Keys: `#0369a1` (blue)
  - Strings: `#15803d` (green)
  - Numbers: `#b91c1c` (red)
  - Booleans: `#2563eb` (bright blue)

### Callout Banners
- **No Full-Width Stretch:** Center bottom callout banners and restrict their width to prevent them from taking up the entire slide width:
  ```html
  <div class="mt-auto" style="display:flex; justify-content:center;">
    <div class="callout callout--amber" style="width:fit-content; white-space:nowrap;">
      <strong>Note:</strong> Centered single-line banner text fits here.
    </div>
  </div>
  ```
- **Classes:** Use `.callout--teal` (info/neutral), `.callout--amber` (warning), or `.callout--red` (error/critique) depending on context.

### Flex Columns & Alignment
- **Centered Columns:** When placing text cards next to graphics or trees, align items vertically: `display: flex; flex-direction: column; justify-content: center;`.
- **Flow Arrows:** For flow arrows between columns, use solid inline SVG arrows:
  ```html
  <svg viewBox="0 0 40 40" width="32" height="32" xmlns="http://www.w3.org/2000/svg">
    <path d="M 5 20 L 32 20" stroke="var(--teal)" stroke-width="2.5" stroke-linecap="round" />
    <polygon points="28,15 37,20 28,25" fill="var(--teal)" />
  </svg>
  ```
  *Avoid CSS linear gradients inside SVGs (`stroke="url(#id)"`) because Reveal.js transformations break gradient references.*

### Inline SVG Sizing (Critical — read before embedding any SVG)
- **Always use `height:auto; width:100%`**, never `height:Npx` where N equals the viewBox height. When the explicit height matches the viewBox height, the SVG renders at exactly 1:1 scale regardless of how wide the flex container is — the content will look tiny.
- **Keep the viewBox compact** (height ≤ ~220 units for a 400-wide viewBox). A ratio of roughly 2:1 (width:height) means that when the SVG scales up to fill a ~600px-wide column, the rendered height stays around 300px — within the available slide space.
- **Pattern for inline diagram SVGs:**
  ```html
  <div style="flex:1.4; overflow:hidden;">
    <svg viewBox="0 0 400 210" xmlns="http://www.w3.org/2000/svg" style="width:100%; height:auto;">
      ...
    </svg>
  </div>
  ```
- If the SVG overflows the slide vertically after using `height:auto`, tighten the viewBox height (compact coordinates) rather than re-adding a fixed pixel height.

### Zone Minimap (zone-map-mini)
- **Active States:** For slides demonstrating a specific zone, include the minimap. Highlight current zones with `active zm-here` (which adds the active green color and the ▼ indicator pin above it):
  ```html
  <div class="zone-map-mini">
    <div class="zm-zone zm-landing">Landing</div>
    <div class="zm-arrow">→</div>
    <div class="zm-zone zm-raw">Raw</div>
    <div class="zm-arrow">→</div>
    <div class="zm-zone zm-process active zm-here">Process</div>
    <div class="zm-arrow">→</div>
    <div class="zm-zone zm-access">Access</div>
  </div>
  ```

---

## 4. KVWL Domain Terminology Boundaries

To maintain accuracy and relevance to the KVWL context, strictly adhere to these vocabulary guidelines in slide text, speaker notes, and scripts:

- **NO Clinical/Medical Terminology:** Do not mention clinical risks, medical errors, patient treatment hazards, or similar terms. The project's stakes are strictly administrative, financial, and organizational.
- **Core Business Context:** The project advices doctors and practices and manages or audits their billing and invoicing data ("Wir beraten Ärzte und Praxen und prüfen/machen ihre Abrechnungen").
- **Errors Definition:**
  - **False Merge (Falsche Zusammenführung) [CRITICAL]:** Merging data of two different patients into a single profile. This is the more severe error since it compromises billing accuracy, data privacy, and legal compliance.
  - **Split (Aufteilung) [MINOR]:** Splitting a single patient's records into multiple profiles. Less severe, resulting in distributed records but without cross-patient data leaks.

---
 
## 5. Automated Playwright Verification & Mapping Workflow
 
Always visually inspect your slide changes after modifying the HTML/CSS using the verification and mapping scripts stored in the skill's scripts directory: `.agents/skills/slide-optimization/scripts/`.
 
### 1. Slide Navigation Structure & Offsets
Reveal.js navigation is 0-indexed in the URL `#/{index}` and counts all horizontal `<section>` tags, including Cover and Chapter cover slides. Because Chapter title slides have been inserted (adding to the index), the 0-based URL index in Reveal.js is **shifted** relative to the 1-based reference PNG filenames (`presentation/reference/slide-XX.png`).

Specifically:
- For Slides 0 to 4: Reveal.js URL `/#/idx` maps to `slide-(idx+1).png` (e.g. index 3 maps to `slide-04.png`).
- For Slides 16 to 30: Reveal.js URL `/#/idx` maps to `slide-(idx-1).png` (e.g. index 23 maps to `slide-22.png`, index 24 maps to `slide-23.png`).

To see the exact mapping of Reveal.js index vs. Reference mockup filename, always run:
```bash
python .agents/skills/slide-optimization/scripts/check_slide_mapping.py
```
This prints a clean mapping table to prevent you from aligning the wrong slides.

> **Warning — Reference images can be misaligned:** The reference PNGs were generated from an early NotebookLM draft and may not match the current slide order if slides were added or reordered since then. Always **visually confirm** that the reference PNG content matches the actual slide content before using it as the optimization target. If they don't match, check adjacent reference files (±1 or ±2) to find the correct one.
 
### 2. Running Verification Screenshots
Use the automated, parameter-driven script at `.agents/skills/slide-optimization/scripts/verify_slide.py` to capture screenshots of your modified slide.
 
To verify a newly edited slide:
1. Run the script, passing the target Reveal.js slide index and output screenshot file path:
   ```bash
   python .agents/skills/slide-optimization/scripts/verify_slide.py --index <index> --output C:\Users\Yannik\.gemini\antigravity\brain\<conversation-id>\<filename>.png
   ```
   *(e.g., for Slide 22 at index 23: `--index 23 --output C:\Users\Yannik\.gemini\antigravity\brain\71c796ea-d8cf-435c-994c-ba11b9be4730\slide_22_after.png`)*
2. Check the generated screenshot under your brain app data directory and compare it side-by-side with the reference PNG under `presentation/reference/`. Inspect for vertical scrollbars, text wrapping, overlapping elements, or text alignment errors.
 
### 3. DOM Overflow & Scrollbar Check
Use the automated script at `.agents/skills/slide-optimization/scripts/check_overflow.py` to check for vertical and horizontal overflows in the DOM of a slide:
```bash
python .agents/skills/slide-optimization/scripts/check_overflow.py --index <index>
```
*(e.g., to inspect slide 24 at index 25: `python .agents/skills/slide-optimization/scripts/check_overflow.py --index 25`)*
This script will output SUCCESS if no overflow is detected or warnings identifying specific elements with scrollbars or overflow issues.

**Known false positives:** The script reports warnings for inner elements where `scrollHeight > clientHeight` by a few pixels even when the parent container already has `overflow:hidden`. These 2–5px discrepancies are caused by browser font line-height rounding (e.g., text inside a card's metric row) and do not produce visible scrollbars. They are safe to ignore **if and only if** the parent card or column div already has `overflow:hidden` set. Always cross-check against the visual screenshot — if no scrollbar is visible in the rendered slide, the warning is a false positive.

### 4. Automated Layout Scanning (Tesseract OCR)
If Tesseract OCR is available on the system, you can run Tesseract directly on the reference images to extract text layout, headers, and bounding boxes, providing immediate structural insights without manually parsing the images.
To run OCR on a reference image:
```bash
tesseract presentation/reference/slide-XX.png stdout -l eng
```
For region-specific layout analysis, write a temporary Python script in your scratch directory using PIL to crop the target zones (like cards or tables) before running Tesseract.
