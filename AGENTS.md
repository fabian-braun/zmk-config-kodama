# Repository Guidelines

## Project Structure & Module Organization

This repository contains a personal ZMK configuration for a wireless Corne 36 keyboard. Firmware inputs live in `config/`: `corne.keymap` defines layers, combos, and behaviors; `corne.conf` holds ZMK Kconfig options; `west.yml` pins ZMK and the nice-oled module. `build.yaml` defines the GitHub Actions matrix for left and right halves. Layout documentation is generated at the root as `keymap.yaml` and `keymap.svg` using `layout.json`. Root `.jpeg` files and `Readme.md` are documentation assets.

## Build, Test, and Development Commands

- `just draw` regenerates `keymap.yaml` and `keymap.svg` from `config/corne.keymap`.
- `keymap parse -c 10 -z ./config/corne.keymap > keymap.yaml` parses the ZMK keymap manually.
- `keymap draw -j layout.json keymap.yaml > keymap.svg` redraws the visual keymap manually.
- GitHub Actions runs `.github/workflows/build.yml`, which delegates to ZMK's user-config build workflow and uses `build.yaml` for the `nice_nano` + `corne_left/right nice_oled` targets.

Install local drawing tools with `pipx install keymap-drawer`; `just` is required for the shortcut command.

## Coding Style & Naming Conventions

Keep ZMK layer constants uppercase (`DEFAULT`, `NAV`, `MEDIA`) and layer node names lowercase with `_layer` suffixes. Preserve the aligned key grid in `config/corne.keymap`; the hardware has 36 physical keys but the matrix is padded to 42 positions with outer `&none` entries. Use short display names such as `def`, `nav2`, and `fn`. YAML files use two-space indentation.

## Testing Guidelines

There is no separate unit test suite. Validate changes by running `just draw` and reviewing both generated files for intentional diffs. Firmware correctness is checked by the GitHub Actions build on pushes and pull requests. For keymap changes, verify layer positions against `keymap.svg` before flashing.

## Commit & Pull Request Guidelines

History uses short imperative commit messages, usually sentence case, such as `Fix deprecated fields` or `Disable nice OLED`. Keep commits focused on one keymap, config, or documentation change. Pull requests should describe the keyboard behavior change, mention affected layers or shields, include regenerated `keymap.svg` when applicable, and wait for the firmware build to pass before merge.

## Security & Repository Policy

Do not commit secrets, credentials, or private tokens.
