#!/usr/bin/env python3
"""
Split PDF into separate files based on bookmarks/sections.
Creates a directory structure matching the PDF's hierarchical organization.
"""

from pathlib import Path
from typing import Optional, Any
import sys

try:
    from pypdf import PdfReader, PdfWriter
except ImportError:
    print("Error: pypdf is required. Install with: uv pip install pypdf")
    sys.exit(1)


def sanitize_filename(name: str) -> str:
    """Convert bookmark name to valid filename."""
    invalid_chars = '<>:"/\\|?*'
    for char in invalid_chars:
        name = name.replace(char, '_')
    name = name.strip('. ')
    return name or 'unnamed'


def get_bookmark_title(bookmark: Any) -> str:
    """Extract title from bookmark (handles dict and object formats)."""
    if isinstance(bookmark, dict):
        return bookmark.get('/Title', 'unnamed')
    return getattr(bookmark, 'title', 'unnamed')


def get_bookmark_page(bookmark: Any, reader: PdfReader) -> Optional[int]:
    """Extract page number from bookmark."""
    try:
        page_obj = None

        if isinstance(bookmark, dict):
            dest = bookmark.get('/Dest')
            if dest:
                if isinstance(dest, list) and len(dest) > 0:
                    page_obj = dest[0]
                else:
                    page_obj = dest
        else:
            if hasattr(bookmark, 'page'):
                page_obj = bookmark.page
            elif hasattr(bookmark, 'destination'):
                dest = bookmark.destination
                if isinstance(dest, list) and len(dest) > 0:
                    page_obj = dest[0]
                else:
                    page_obj = dest

        if page_obj is None:
            return None

        if hasattr(page_obj, 'get_object'):
            page_obj = page_obj.get_object()

        if hasattr(page_obj, 'indirect_reference'):
            page_obj = page_obj.indirect_reference.get_object()

        for idx, page in enumerate(reader.pages):
            try:
                if page == page_obj:
                    return idx
                if hasattr(page, 'indirect_reference') and hasattr(page_obj, 'indirect_reference'):
                    if page.indirect_reference.idnum == page_obj.indirect_reference.idnum:
                        return idx
            except Exception:
                continue

        return None
    except Exception:
        return None


def extract_sections(
    reader: PdfReader,
    output_dir: Path,
    parent_path: Path = Path('.'),
    bookmarks: Optional[list] = None,
    current_page: int = 0
) -> int:
    """
    Recursively extract PDF sections based on bookmarks.

    Parameters
    ----------
    reader : PdfReader
        PDF reader object
    output_dir : Path
        Base output directory
    parent_path : Path
        Current directory path relative to output_dir
    bookmarks : list, optional
        List of bookmarks to process
    current_page : int
        Current page index being processed

    Returns
    -------
    int
        Last processed page index
    """
    if bookmarks is None:
        if not reader.outline:
            print("Warning: No bookmarks found in PDF. Creating single file with all pages.")
            writer = PdfWriter()
            for page in reader.pages:
                writer.add_page(page)
            output_file = output_dir / 'full_document.pdf'
            with open(output_file, 'wb') as f:
                writer.write(f)
            print(f"Created: {output_file}")
            return len(reader.pages) - 1
        bookmarks = reader.outline

    last_page = current_page

    for i, bookmark in enumerate(bookmarks):
        if isinstance(bookmark, list):
            last_page = extract_sections(
                reader, output_dir, parent_path, bookmark, last_page
            )
            continue

        page_num = get_bookmark_page(bookmark, reader)
        if page_num is None:
            page_num = last_page

        section_name = sanitize_filename(get_bookmark_title(bookmark))
        section_path = output_dir / parent_path / section_name

        next_bookmark_page = None
        if i + 1 < len(bookmarks):
            next_item = bookmarks[i + 1]
            if isinstance(next_item, list) and next_item:
                next_bookmark_page = get_bookmark_page(next_item[0], reader)
            else:
                next_bookmark_page = get_bookmark_page(next_item, reader)

        if next_bookmark_page is None:
            end_page = len(reader.pages) - 1
        else:
            end_page = next_bookmark_page - 1

        start_page = max(page_num, last_page)
        end_page = max(end_page, start_page)

        if start_page <= end_page:
            section_path.mkdir(parents=True, exist_ok=True)

            writer = PdfWriter()
            for page_idx in range(start_page, end_page + 1):
                writer.add_page(reader.pages[page_idx])

            output_file = section_path / f"{section_name}.pdf"
            with open(output_file, 'wb') as f:
                writer.write(f)

            print(f"Created: {output_file} (pages {start_page + 1}-{end_page + 1})")
            last_page = end_page + 1

        child_bookmarks = None
        if isinstance(bookmark, dict):
            if '/First' in bookmark:
                child_bookmarks = []
                child = bookmark.get('/First')
                while child:
                    child_bookmarks.append(child)
                    if isinstance(child, dict) and '/Next' in child:
                        child = child.get('/Next')
                    else:
                        break
        elif hasattr(bookmark, 'children'):
            child_bookmarks = bookmark.children

        if child_bookmarks:
            relative_section_path = parent_path / section_name
            last_page = extract_sections(
                reader,
                output_dir,
                relative_section_path,
                child_bookmarks,
                start_page
            )

    return last_page


def split_pdf_by_sections(pdf_path: Path, output_base: Path) -> None:
    """
    Split PDF into sections based on bookmarks.

    Parameters
    ----------
    pdf_path : Path
        Path to input PDF file
    output_base : Path
        Base directory for output files
    """
    if not pdf_path.exists():
        raise FileNotFoundError(f"PDF file not found: {pdf_path}")

    print(f"Reading PDF: {pdf_path}")
    reader = PdfReader(str(pdf_path))

    print(f"Total pages: {len(reader.pages)}")
    print(f"Bookmarks found: {len(reader.outline) if reader.outline else 0}")

    output_base.mkdir(parents=True, exist_ok=True)

    print("\nExtracting sections...")
    extract_sections(reader, output_base)

    print(f"\nPDF splitting complete. Output directory: {output_base}")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        pdf_file = Path('IgorMan.pdf')
    else:
        pdf_file = Path(sys.argv[1])

    if len(sys.argv) < 3:
        output_dir = Path('igor_sections')
    else:
        output_dir = Path(sys.argv[2])

    try:
        split_pdf_by_sections(pdf_file, output_dir)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
