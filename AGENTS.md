# Agentbook contributor notes

## Environment Setup

- To check your environment for GitHub CLI and tokens:
  - `bash scripts/check-env.sh`
  - This verifies GH_TOKEN/GITHUB_TOKEN presence and gh CLI installation

## Link Checking

- After changing files under `book/`, run the offline-safe checker:
  - `python3 scripts/check-links.py --root book --mode internal`
- When internet access is available, also run:
  - `python3 scripts/check-links.py --root book --mode external`
- In CI:
  - `.github/workflows/check-links.yml` runs internal link checks on push/PR.
  - `.github/workflows/check-external-links.yml` is for internet-enabled runs (manual/scheduled).
