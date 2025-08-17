#!/usr/bin/env python3
"""
Update anchored blocks in ROADMAP.md

Usage:
    python scripts/update_anchors.py P0_TASKS new_p0.md METRICS new_metrics.md ...
    
Or with stdin:
    echo "new content" | python scripts/update_anchors.py P0_TASKS -
"""

import re
import sys
import pathlib

def replace_block(text, start_anchor, end_anchor, replacement):
    """Replace content between anchor tags."""
    pattern = re.compile(
        rf"({re.escape(start_anchor)})(.*?)({re.escape(end_anchor)})",
        re.DOTALL
    )
    
    def replacer(match):
        return match.group(1) + "\n" + replacement.strip() + "\n" + match.group(3)
    
    return pattern.sub(replacer, text)

def main():
    # Parse command line arguments
    args = sys.argv[1:]
    if len(args) == 0 or len(args) % 2 != 0:
        print("Usage: update_anchors.py ANCHOR1 file1.md ANCHOR2 file2.md ...")
        print("       Use '-' as filename to read from stdin")
        sys.exit(1)
    
    # Read current ROADMAP
    roadmap_path = pathlib.Path("ROADMAP.md")
    if not roadmap_path.exists():
        print(f"Error: {roadmap_path} not found")
        sys.exit(1)
    
    roadmap_content = roadmap_path.read_text()
    
    # Process each anchor/file pair
    pairs = list(zip(args[0::2], args[1::2]))
    for anchor, filename in pairs:
        # Read new content
        if filename == "-":
            new_content = sys.stdin.read()
        else:
            file_path = pathlib.Path(filename)
            if not file_path.exists():
                print(f"Warning: {file_path} not found, skipping {anchor}")
                continue
            new_content = file_path.read_text()
        
        # Update the anchored block
        start_anchor = f"<!-- {anchor} -->"
        end_anchor = f"<!-- /{anchor} -->"
        
        if start_anchor in roadmap_content and end_anchor in roadmap_content:
            roadmap_content = replace_block(
                roadmap_content,
                start_anchor,
                end_anchor,
                new_content
            )
            print(f"✅ Updated {anchor} block")
        else:
            print(f"⚠️  Anchor {anchor} not found in ROADMAP.md")
    
    # Write updated ROADMAP
    roadmap_path.write_text(roadmap_content)
    print("📝 ROADMAP.md updated successfully")

if __name__ == "__main__":
    main()