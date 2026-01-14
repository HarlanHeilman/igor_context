#!/usr/bin/env python3
"""
Extract chapters from PDF and create either split PDFs or markdown summaries.
Uses PyMuPDF for reliable bookmark extraction and text processing.
"""

from pathlib import Path
from typing import Optional
import sys
import re

try:
    import fitz
except ImportError:
    print("Error: pymupdf is required. Install with: uv pip install --system pymupdf")
    sys.exit(1)


def sanitize_filename(name: str) -> str:
    """Convert bookmark name to valid filename."""
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        name = name.replace(char, '_')
    name = name.strip('. ')
    return name or 'unnamed'


def extract_chapter_text(doc: fitz.Document, start_page: int, end_page: int) -> str:
    """Extract text from a page range."""
    text_parts = []

    for page_num in range(start_page, min(end_page + 1, len(doc))):
        page = doc[page_num]
        text = page.get_text()
        if text.strip():
            text_parts.append(text)

    return '\n\n'.join(text_parts)


def clean_text_for_markdown(text: str) -> str:
    """Clean extracted text for markdown formatting."""
    text = re.sub(r'\n{3,}', '\n\n', text)
    text = re.sub(r'[ \t]+', ' ', text)
    text = text.strip()
    return text


def create_markdown_summary(chapter_title: str, text: str, output_file: Path) -> None:
    """Create a markdown file with chapter content."""
    cleaned_text = clean_text_for_markdown(text)

    content = f"# {chapter_title}\n\n{cleaned_text}\n"

    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(content)


def get_toc_entries(doc: fitz.Document):
    """Extract table of contents entries with page numbers."""
    toc = doc.get_toc()
    entries = []

    for item in toc:
        level, title, page = item
        entries.append({
            'level': level,
            'title': title,
            'page': page - 1
        })

    return entries


def build_directory_path(chapters, idx: int, output_base: Path) -> Path:
    """Build directory path based on chapter hierarchy."""
    current = chapters[idx]
    current_level = current['level']

    path_parts = [output_base]

    parent_levels = {}
    for i in range(idx - 1, -1, -1):
        chapter = chapters[i]
        chapter_level = chapter['level']

        if chapter_level < current_level:
            if chapter_level not in parent_levels:
                parent_levels[chapter_level] = sanitize_filename(chapter['title'])
                if chapter_level == 1:
                    break

    for level in sorted(parent_levels.keys()):
        path_parts.append(parent_levels[level])

    path_parts.append(sanitize_filename(current['title']))

    return Path(*path_parts)


def split_by_keywords(
    doc: fitz.Document,
    output_base: Path,
    keyword: str,
    create_pdfs: bool,
    create_markdown: bool
) -> None:
    """Split PDF by searching for keywords in text content."""
    section_pages = []

    print(f"Searching for keyword: '{keyword}' in PDF content...")

    for page_num in range(len(doc)):
        page = doc[page_num]
        text = page.get_text("blocks")
        for block in text:
            if keyword.lower() in block[4].lower():
                section_pages.append(page_num)
                break

    if not section_pages:
        print(f"Warning: No sections found with keyword '{keyword}'")
        return

    if section_pages[-1] != len(doc) - 1:
        section_pages.append(len(doc))

    print(f"Found {len(section_pages)} sections")

    for i in range(len(section_pages) - 1):
        start_page = section_pages[i]
        end_page = section_pages[i + 1] - 1

        section_name = f"section_{i+1:03d}"

        section_path = output_base / section_name
        section_path.mkdir(parents=True, exist_ok=True)

        if create_pdfs:
            pdf_file = section_path / f"{section_name}_pages_{start_page+1}_to_{end_page+1}.pdf"
            new_doc = fitz.open()
            new_doc.insert_pdf(doc, from_page=start_page, to_page=end_page)
            new_doc.save(pdf_file)
            new_doc.close()
            print(f"Created PDF: {pdf_file} (pages {start_page + 1}-{end_page + 1})")

        if create_markdown:
            text = extract_chapter_text(doc, start_page, end_page)
            md_file = section_path / f"{section_name}.md"
            create_markdown_summary(f"Section {i+1}", text, md_file)
            print(f"Created Markdown: {md_file}")


def split_pdf_chapters(
    pdf_path: Path,
    output_base: Path,
    create_pdfs: bool = True,
    create_markdown: bool = False,
    keyword: Optional[str] = None
) -> None:
    """
    Split PDF into chapters and optionally create markdown files.

    Parameters
    ----------
    pdf_path : Path
        Path to input PDF file
    output_base : Path
        Base directory for output files
    create_pdfs : bool
        Whether to create split PDF files
    create_markdown : bool
        Whether to create markdown text files
    keyword : str, optional
        If provided, split by searching for this keyword instead of using TOC
    """
    if not pdf_path.exists():
        raise FileNotFoundError(f"PDF file not found: {pdf_path}")

    print(f"Reading PDF: {pdf_path}")
    doc = fitz.open(pdf_path)

    total_pages = len(doc)
    print(f"Total pages: {total_pages}")

    if keyword:
        split_by_keywords(doc, output_base, keyword, create_pdfs, create_markdown)
        doc.close()
        return

    toc_entries = get_toc_entries(doc)

    if not toc_entries:
        print("Warning: No table of contents found in PDF.")
        print("Creating single file with all pages...")

        output_base.mkdir(parents=True, exist_ok=True)

        if create_pdfs:
            output_file = output_base / 'full_document.pdf'
            doc.save(output_file)
            print(f"Created: {output_file}")

        if create_markdown:
            text = extract_chapter_text(doc, 0, total_pages - 1)
            md_file = output_base / 'full_document.md'
            create_markdown_summary('Full Document', text, md_file)
            print(f"Created: {md_file}")

        doc.close()
        return

    print(f"Found {len(toc_entries)} TOC entries")

    output_base.mkdir(parents=True, exist_ok=True)

    chapters = []
    for i, entry in enumerate(toc_entries):
        start_page = entry['page']

        if i + 1 < len(toc_entries):
            next_entry = toc_entries[i + 1]
            end_page = next_entry['page'] - 1
        else:
            end_page = total_pages - 1

        if start_page > end_page or start_page < 0:
            continue

        chapters.append({
            'title': entry['title'],
            'start_page': start_page,
            'end_page': end_page,
            'level': entry['level']
        })

    print(f"\nExtracting {len(chapters)} chapters...")

    for idx, chapter in enumerate(chapters):
        title = chapter['title']
        start = chapter['start_page']
        end = chapter['end_page']

        section_name = sanitize_filename(title)
        section_path = build_directory_path(chapters, idx, output_base)
        section_path.mkdir(parents=True, exist_ok=True)

        if create_pdfs:
            pdf_file = section_path / f"{section_name}.pdf"
            if pdf_file.exists():
                try:
                    pdf_file.unlink()
                except Exception:
                    pdf_file = section_path / f"{section_name}_{idx}.pdf"

            new_doc = fitz.open()
            new_doc.insert_pdf(doc, from_page=start, to_page=end)
            new_doc.save(pdf_file)
            new_doc.close()
            print(f"Created PDF: {pdf_file} (pages {start + 1}-{end + 1})")

        if create_markdown:
            text = extract_chapter_text(doc, start, end)
            md_file = section_path / f"{section_name}.md"
            create_markdown_summary(title, text, md_file)
            print(f"Created Markdown: {md_file}")

    doc.close()
    print(f"\nExtraction complete. Output directory: {output_base}")


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description='Extract chapters from PDF and create split PDFs or markdown files.'
    )
    parser.add_argument(
        'pdf_file',
        nargs='?',
        default='IgorMan.pdf',
        help='Path to PDF file (default: IgorMan.pdf)'
    )
    parser.add_argument(
        '-o', '--output',
        default='igor_sections',
        help='Output directory (default: igor_sections)'
    )
    parser.add_argument(
        '--pdfs',
        action='store_true',
        default=True,
        help='Create split PDF files (default: True)'
    )
    parser.add_argument(
        '--no-pdfs',
        dest='pdfs',
        action='store_false',
        help='Do not create split PDF files'
    )
    parser.add_argument(
        '--markdown',
        action='store_true',
        help='Create markdown text files'
    )
    parser.add_argument(
        '--keyword',
        type=str,
        help='Split PDF by searching for this keyword in text (e.g., "Chapter", "Section")'
    )

    args = parser.parse_args()

    pdf_file = Path(args.pdf_file)
    output_dir = Path(args.output)

    try:
        split_pdf_chapters(
            pdf_file,
            output_dir,
            create_pdfs=args.pdfs,
            create_markdown=args.markdown,
            keyword=args.keyword
        )
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
