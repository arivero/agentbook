#!/usr/bin/env python3
import argparse
import re
import sys
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


URL_PATTERN = re.compile(r"https?://[^\s)>\"]+")

SKIP_URLS = {
    # Requires authenticated browser access; returns 403 to unauthenticated curl.
    "https://platform.openai.com/docs/guides/codex/skills",
}


def normalize_url(url: str) -> str:
    return url.rstrip(".,;:)]")


def iter_markdown_files(root: Path) -> list[Path]:
    return sorted(root.rglob("*.md"))


def find_urls(text: str) -> set[str]:
    return {normalize_url(match) for match in URL_PATTERN.findall(text)}


def check_url(url: str, timeout: int = 10) -> tuple[bool, str]:
    if url in SKIP_URLS:
        return True, "skipped"
    try:
        req = Request(url, method="HEAD", headers={"User-Agent": "agentbook-link-checker"})
        with urlopen(req, timeout=timeout) as resp:
            return 200 <= resp.status < 400, f"{resp.status}"
    except HTTPError as exc:
        if exc.code in {405, 501}:
            try:
                req = Request(url, method="GET", headers={"User-Agent": "agentbook-link-checker"})
                with urlopen(req, timeout=timeout) as resp:
                    return 200 <= resp.status < 400, f"{resp.status}"
            except Exception as inner_exc:  # pragma: no cover
                return False, str(inner_exc)
        return False, str(exc.code)
    except URLError as exc:
        return False, str(exc.reason)
    except Exception as exc:  # pragma: no cover
        return False, str(exc)


def main() -> int:
    parser = argparse.ArgumentParser(description="Check Markdown links for reachability.")
    parser.add_argument("--root", default="book", help="Root directory to scan for Markdown files.")
    args = parser.parse_args()

    root = Path(args.root)
    if not root.exists():
        print(f"Root path not found: {root}")
        return 2

    urls = set()
    for path in iter_markdown_files(root):
        urls |= find_urls(path.read_text(encoding="utf-8"))

    failures = []
    for url in sorted(urls):
        ok, info = check_url(url)
        if not ok:
            failures.append((url, info))

    if failures:
        print("Link check failures:")
        for url, info in failures:
            print(f"- {url} ({info})")
        return 1

    print(f"Checked {len(urls)} URLs: OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
