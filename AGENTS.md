# Repository Guidelines

## Current Keyboard

This repository maintains ZMK firmware for a FalbaTech Corne Mini v3 Wireless keyboard. The current hardware specs are: nice!nano v2 controllers, no OLED/display, no RGB LEDs, 36 physical keys, and ZMK Studio enabled on the left/central half. The keymap selects `foostan_corne_5col_layout`; each layer must therefore have exactly 36 bindings.

## Project Structure & Module Organization

Firmware sources live in `config/`: `corne.keymap` defines layers, combos, Studio unlock, and bootloader bindings; `corne.conf` holds Kconfig options; `west.yml` imports upstream ZMK. `build.yaml` defines GitHub Actions firmware targets. `layout.json`, `keymap.yaml`, and `keymap.svg` document the 36-key layout.

## Build, Test, and Development Commands

- `just draw` regenerates `keymap.yaml` and `keymap.svg` from `config/corne.keymap`.
- `keymap parse -c 10 -z ./config/corne.keymap > keymap.yaml` parses the keymap manually.
- `keymap draw -j layout.json keymap.yaml > keymap.svg` redraws the visual keymap manually.
- GitHub Actions builds `nice_nano//zmk` targets for `corne_left` with `studio-rpc-usb-uart`, `corne_right`, and `settings_reset`.

Local tools (`just`, `python`, `uv`, `keymap-drawer`) are pinned in `mise.toml`. Run `mise install` to provision them; with mise shell activation, `just draw` and the `keymap` CLI will be on PATH automatically.

## Key Bindings To Preserve

- ZMK Studio unlock: hold `E` for `MEDIA`, then press `S`.
- Left-half bootloader: hold `E` for `MEDIA`, then press `A`.
- Right-half bootloader: hold `K` for `NUM`, hold the `Enter` thumb key for `FUNC`, then press `O`.

The physical reset button is accessible without opening the wooden case through a small hole on the back side. The bootloader bindings are still useful for firmware updates. If you move any of these bindings, regenerate `keymap.svg`.

## Coding Style & Naming Conventions

Keep layer constants uppercase and layer nodes lowercase with `_layer` suffixes. Preserve the aligned key grid in `config/corne.keymap`.

## Validation & Flashing

There is no unit test suite. Validate source changes with:

```zsh
just draw
git diff --check
rg 'oled|nice_oled|nice_view|DISPLAY|RGB|rgb_ug|UNDERGLOW|&none' build.yaml config keymap.yaml keymap.svg layout.json
```

Firmware correctness is checked by GitHub Actions. CI has passed for the no-OLED/no-RGB matrix and for the 36-key layout update.

For a clean flash or recovery from strange ZMK Studio behavior:

1. Flash `settings_reset` to both halves.
2. Flash the left and right firmware UF2 files.
3. Forget the keyboard in the host Bluetooth settings.
4. Pair again.

If ZMK Studio changes cause strange key behavior, use "Restore Stock Settings" first; if problems remain, repeat the full settings-reset plus reflash sequence. This fully resolved the migration issue where left-half keys caused Bluetooth disconnects.

## Commit & Pull Request Guidelines

Use short imperative commit messages, for example `Adjust layout` or `Remove OLED config`. Keep commits focused on one keymap, config, or documentation change. Pull requests should describe affected layers or firmware targets, include regenerated `keymap.svg` when applicable, and wait for CI to pass before merge.

## Security & Repository Policy

Do not commit secrets, credentials, or private tokens.
