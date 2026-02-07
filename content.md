# Human Operator Guide

`content.md` is the guide for the required human operator of this repository.

Use this document when you are configuring or operating the automation stack. Do not use `README.md` as the operator runbook.

## Start Here

1. Complete repository setup and secrets in `SETUP.md`.
2. Follow lifecycle and trigger rules in `WORKFLOW_PLAYBOOK.md`.
3. For GH-AW workflow source edits, follow `.github/workflows/AGENTS.md`.

## Minimum Operator Responsibilities

1. Keep required secrets configured and valid (`COPILOT_GITHUB_TOKEN`, `GH_AW_GITHUB_TOKEN`, and any research-provider secrets).
2. Keep `.github/workflows/*.md` and `.github/workflows/*.lock.yml` in sync using `gh aw compile`.
3. Monitor issue-processing workflow runs and remediate token/permission failures.
4. Preserve least-privilege token scope and repository-only access for automation secrets.

## Optional PR Approval Automation

The standard workflow `.github/workflows/pr-gate.yml` can auto-approve low-risk PRs.

Configure this only if you want automatic approval:
1. Create a dedicated bot token and store it as `PR_APPROVER_TOKEN` in repository secrets.
2. Scope the token to this repository.
3. Grant `Pull requests: Read and write`.
4. If the same token user opens and approves the PR, branch protection may not count that as an independent review.
