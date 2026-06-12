# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A GitHub composite action (`action.yml`) that installs [mise](https://mise.jdx.dev/) on Ubuntu runners and optionally runs `mise install`. There is no build step — the action runs shell scripts directly.

## Files

- `action.yml` — declares inputs and orchestrates steps; passes all config to `run.sh` via env vars
- `run.sh` — does the actual work: resolves version, downloads tarball, verifies SHA256, installs mise, runs `mise install`, registers paths in `GITHUB_PATH`
- `mise.toml` — local dev tool pins (currently node 24.15.0); also used as the `config_file` input in CI tests
- `.github/workflows/test.yml` — integration tests that exercise the action itself (with cache, without cache, without install)

## How action.yml and run.sh interact

`action.yml` uses `actions/cache@v4` and sets the `CACHE_HIT` env var, then calls `run.sh` via `bash ${{ github.action_path }}/run.sh`. All inputs are forwarded as env vars (`INPUT_INSTALL`, `INPUT_WORKING_DIRECTORY`, `INPUT_LOG_LEVEL`, `INPUT_CONFIG_FILE`, `INPUT_GITHUB_TOKEN`, `MISE_VERSION`, `CACHE_HIT`). `run.sh` reads only env vars — never `${{ inputs.* }}` syntax.

## Cache behavior

- Cache key: `mise-<OS>-<version>-<hash of config_file>`
- A full cache hit skips **both** the binary download **and** `mise install` (tools are already restored by `actions/cache`)
- Paths always appended to `GITHUB_PATH`: `~/.local/bin` and `~/.local/share/mise/shims`

## Testing

Tests only run on GitHub Actions (the action tests itself). To test a change, push a branch and check the `Test` workflow. The three test jobs cover: normal (cached), cache disabled, and install disabled.

## Constraints

- `run.sh` is hardcoded to `linux-x64` — this action only targets Ubuntu runners
- Version string handling: `v` prefix is stripped from inputs; the `v` prefix is re-added when constructing the tarball name and tag
