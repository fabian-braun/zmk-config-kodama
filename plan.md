# Migration Plan: FalbaTech Corne Mini Wireless

## Goal

Adapt this ZMK config from the previous Keebmaker Corne setup to the new FalbaTech Corne Mini v3 Wireless without OLED. The target firmware should preserve the existing personal keymap, support more than the ZMK Studio default layer count, and build flashable left/right UF2 files through GitHub Actions.

Known target decisions:

- Controller: genuine nice!nano v2.
- Display: none.
- RGB LEDs: none.
- ZMK Studio: keep enabled.

## Current Starting Point

- Existing config builds `nice_nano` with `corne_left nice_oled` and `corne_right nice_oled`.
- `config/west.yml` imports the custom `zmk-nice-oled` module from `fabian-braun/migrate-lvgl-9`.
- `config/corne.conf` enables display and custom OLED status screen settings.
- `config/corne.conf` enables RGB underglow even though the new keyboard has no RGB LEDs.
- `config/corne.keymap` includes RGB controls in the media layer that should be removed or replaced.
- `config/corne.keymap` is padded for the old 42-position Corne matrix with outer `&none` columns, even though the physical keyboard has fewer keys.
- `layout.json`, `keymap.yaml`, and `keymap.svg` also describe the old visual layout.

## Research Findings

- FalbaTech product page says the no-OLED option ships with ZMK Studio-compatible firmware; the OLED option uses standard ZMK without Studio support.
- FalbaTech GitHub has several Corne repositories. The most relevant candidates are:
  - `https://github.com/falbatech/zmk-config-corneft`: recent FalbaTech Corne FT config with ZMK Studio enabled, but it targets a 42-key board with nice!view display.
  - `https://github.com/falbatech/zmk-config-corne-mini-ft-oled`: exact "Corne mini FT" naming, but OLED-specific and therefore not the target baseline.
  - `https://github.com/falbatech/zmk-config-corne-studio`: older no-OLED/ZMK Studio-style config named `CorneWireless`; its README says it is broken and points to `https://github.com/KeyboardHoarders/zmk-config-cornekbh`.
  - `https://github.com/falbatech/zmk-config-cornekbh`: FalbaTech copy of the KeyboardHoarders current 2026 repo. Useful as a reference for Studio setup, but it still has nice!view in its build matrix.
- Probable source lineage for the shipped no-OLED Studio firmware is `zmk-config-corne-studio` -> `KeyboardHoarders/zmk-config-cornekbh`, while FalbaTech's own current Corne FT repos are better references for their preferred `nice_nano//zmk` build style and settings.

## Action Plan

1. Create a migration branch, for example `git switch -c falbatech-corne-mini`.
2. Remove OLED/display dependencies:
   - Delete the `fabian-braun` remote and `zmk-nice-oled` project from `config/west.yml`.
   - Remove `nice_oled`, `nice_view_adapter`, and `nice_view` shields from `build.yaml`.
   - Remove `CONFIG_ZMK_DISPLAY`, `CONFIG_ZMK_DISPLAY_STATUS_SCREEN_CUSTOM`, and any OLED/widget-specific settings from `config/corne.conf`.
3. Remove RGB support:
   - Remove `CONFIG_ZMK_RGB_UNDERGLOW` and related RGB settings from `config/corne.conf`.
   - Remove `#include <dt-bindings/zmk/rgb.h>` from `config/corne.keymap` if no RGB bindings remain.
   - Replace or clear all `&rgb_ug ...` bindings in the media layer.
4. Update the build matrix:
   - Build `corne_left` and `corne_right` only.
   - Add `settings_reset`.
   - Keep `snippet: studio-rpc-usb-uart` on the central/left build because ZMK Studio stays enabled.
   - Target genuine nice!nano v2. Try the current upstream board naming first (`nice_nano_v2` or the FalbaTech style used by their current repos, depending on the selected ZMK revision), and adjust based on CI output.
5. Keep ZMK Studio enabled:
   - Add or preserve `CONFIG_ZMK_STUDIO=y` in `config/corne.conf`.
   - Ensure one reachable key binding includes `&studio_unlock`, or set locking behavior deliberately if using `CONFIG_ZMK_STUDIO_LOCKING=n`.
   - Keep all current logical layers (`DEFAULT`, `NAV`, `NAV2`, `SYM`, `NUM`, `MEDIA`, `FUNC`, `WC3`) in devicetree so Studio can expose more than five layers.
6. Fix the physical layout/keymap:
   - Remove the outer `&none` padding columns from every layer in `config/corne.keymap`.
   - Re-check combo `key-positions`; all indexes shift after removing columns.
   - Preserve the `combo_game` toggle behavior, but validate its positions on the new 36-key index map.
7. Update drawing assets:
   - Replace `layout.json` with a 36-key Corne Mini layout.
   - Run `just draw` to regenerate `keymap.yaml` and `keymap.svg`.
   - Confirm the SVG no longer shows the removed outer columns.
8. Validate locally where possible:
   - Run `just draw`.
   - Search for leftover display/RGB references with `rg 'oled|nice_oled|nice_view|DISPLAY|status_screen|RGB|rgb_ug|UNDERGLOW'`.
   - Review generated keymap diffs manually, especially combos and thumbs.
9. Validate firmware build:
   - Let GitHub Actions build left, right, and settings-reset UF2 artifacts.
   - If CI fails due to board naming or shield assumptions, compare the failure against FalbaTech `zmk-config-corneft` and `zmk-config-cornekbh`.
10. Flash safely:
   - Download the left/right UF2 artifacts and `settings_reset`.
   - Flash `settings_reset` first if the board has stored ZMK Studio changes.
   - Flash left and right halves separately via bootloader mode.
   - Re-pair Bluetooth devices after reset.

## Remaining Decision

- Choose the exact board identifier after selecting the ZMK revision: upstream configs commonly use `nice_nano_v2`, while recent FalbaTech repos use `nice_nano//zmk`.
