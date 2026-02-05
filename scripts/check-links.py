#!/usr/bin/env python3
import argparse
import re
import sys
import unicodedata
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urldefrag, urlparse
from urllib.request import Request, urlopen


URL_PATTERN = re.compile(r"https?://[^\s)>\"]+")
MD_LINK_PATTERN = re.compile(r"!??\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
HEADING_PATTERN = re.compile(r"^#{1,6}\s+(.+?)\s*$", re.MULTILINE)

SKIP_URLS = {
    # Requires authenticated browser access; returns 403 to unauthenticated curl.
    "https://platform.openai.com/docs/guides/codex/skills",
}


def normalize_url(url: str) -> str:
    return url.rstrip(".,;:)]")


def iter_markdown_files(root: Path) -> list[Path]:
    return sorted(root.rglob("*.md"))


def find_external_urls(text: str) -> set[str]:
    return {normalize_url(match) for match in URL_PATTERN.findall(text)}


def slugify_heading(heading: str) -> str:
    lowered = unicodedata.normalize("NFKD", heading).encode("ascii", "ignore").decode("ascii").lower()
    cleaned = re.sub(r"[^a-z0-9\-\s]", "", lowered)
    return re.sub(r"\s+", "-", cleaned).strip("-")


def collect_anchors(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    return {slugify_heading(match) for match in HEADING_PATTERN.findall(text)}


def find_markdown_link_targets(text: str) -> set[str]:
    return {
        normalize_url(match)
        for match in MD_LINK_PATTERN.findall(text)
        if match and not match.startswith(("http://", "https://", "mailto:"))
    }


def check_internal_links(root: Path) -> list[tuple[Path, str, str]]:
    failures: list[tuple[Path, str, str]] = []
    anchor_cache: dict[Path, set[str]] = {}

    for source in iter_markdown_files(root):
        text = source.read_text(encoding="utf-8")
        for target in sorted(find_markdown_link_targets(text)):
            path_part, _, anchor = target.partition("#")

            if path_part == "":
                target_file = source
            else:
                parsed = urlparse(path_part)
                if parsed.scheme or parsed.netloc:
                    continue
                target_file = (source.parent / urldefrag(path_part)[0]).resolve()

            try:
                target_file.relative_to(root.resolve())
            except ValueError:
                # Keep offline checks scoped to the selected documentation root.
                continue

            if not target_file.exists():
                failures.append((source, target, f"missing file: {target_file}"))
                continue

            if anchor:
                if target_file.suffix.lower() != ".md":
                    failures.append((source, target, "anchor provided for non-Markdown target"))
                    continue

                if target_file not in anchor_cache:
                    anchor_cache[target_file] = collect_anchors(target_file)

                if anchor not in anchor_cache[target_file]:
                    failures.append((source, target, f"missing anchor: #{anchor}"))

    return failures


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
    parser.add_argument(
        "--mode",
        choices=("all", "internal", "external"),
        default="all",
        help="all=check internal + external links, internal=only local Markdown links, external=only http/https links.",
    )
    args = parser.parse_args()

    root = Path(args.root)
    if not root.exists():
        print(f"Root path not found: {root}")
        return 2

    failed = False

    if args.mode in {"all", "internal"}:
        internal_failures = check_internal_links(root)
        if internal_failures:
            failed = True
            print("Internal link check failures:")
            for source, target, reason in internal_failures:
                print(f"- {source}: {target} ({reason})")
        else:
            print("Internal links: OK")

    if args.mode in {"all", "external"}:
        urls = set()
        for path in iter_markdown_files(root):
            urls |= find_external_urls(path.read_text(encoding="utf-8"))

        failures = []
        for url in sorted(urls):
            ok, info = check_url(url)
            if not ok:
                failures.append((url, info))

        if failures:
            failed = True
            print("External link check failures:")
            for url, info in failures:
                print(f"- {url} ({info})")
        else:
            print(f"Checked {len(urls)} external URLs: OK")

    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
