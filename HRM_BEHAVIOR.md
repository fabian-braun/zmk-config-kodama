# Home-Row Mod Behavior

I'm using [urob-style](https://github.com/urob/zmk-config#timeless-homerow-mods) timeless home-row mods. The goal is to
make ordinary typing rolls resolve as taps while
still allowing intentional cross-hand modifier chords.

The implementation lives in `config/corne.keymap`.

## Key Position Groups

The keymap uses the `foostan_corne_5col_layout`, so every layer has 36
bindings. The HRM behaviors split those positions into three groups:

```dts
#define KEYS_L     0 1 2 3 4 10 11 12 13 14 20 21 22 23 24
#define KEYS_R     5 6 7 8 9 15 16 17 18 19 25 26 27 28 29
#define THUMBS     30 31 32 33 34 35
```

These groups are used by positional hold-taps:

- Left-hand HRMs may turn into holds when another key from `KEYS_R` or
  `THUMBS` is involved.
- Right-hand HRMs may turn into holds when another key from `KEYS_L` or
  `THUMBS` is involved.
- Same-hand rolling is biased toward taps, which protects normal typing.

## HRM Behaviors

There are four home-row mod behaviors and one generic fast mod-tap behavior.

| Behavior | Used for                   | Prior idle?         | Why it exists                                                      |
|----------|----------------------------|---------------------|--------------------------------------------------------------------|
| `hml`    | Left-hand non-shift HRMs   | Yes, `150ms`        | Timeless HRM behavior for Ctrl/Alt/Gui-style holds.                |
| `hmr`    | Right-hand non-shift HRMs  | Yes, `150ms`        | Same as `hml`, mirrored for right-hand HRMs.                       |
| `hmls`   | Left-hand shift HRM        | No                  | Keeps fast capitalization using the existing hold-shift habit.     |
| `hmrs`   | Right-hand shift HRM       | No                  | Same as `hmls`, mirrored for right-hand Shift.                     |
| `hm`     | Thumb and non-HRM mod-taps | No positional rules | Preserves the previous fast behavior for thumbs and special cases. |

The non-shift HRMs use:

```dts
flavor = "balanced";
tapping-term-ms = <280>;
quick-tap-ms = <175>;
require-prior-idle-ms = <150>;
hold-trigger-key-positions = <opposite-hand THUMBS>;
hold-trigger-on-release;
```

The shift HRMs use the same settings except for `require-prior-idle-ms`, which
is deliberately omitted.

## Why Non-Shift HRMs Use Prior Idle

`require-prior-idle-ms = <150>` makes an HRM resolve as a tap when it is pressed
soon after another key. This is what makes the layout feel calm during fast
typing: if a home-row mod key is part of a normal word roll, it does not easily
turn into Ctrl, Alt, or Gui.

This matters most for dangerous modifiers. An accidental Ctrl, Alt, or Gui chord
can trigger app shortcuts, switch tabs, close windows, or do other surprising
things. For those modifiers, it is worth requiring a little more intentionality.

## Why Shift Is Different

Shift is used constantly inside normal text flow. With prior-idle enabled on
Shift HRMs, a sequence like this can fail:

```text
r -> hold RSHIFT/' -> v
```

When the right-hand Shift HRM is pressed while `r` is still being released, the
prior-idle rule can force the Shift key to resolve as its tap value, producing
`r'v` instead of `rV`.

For that reason, `hmls` and `hmrs` keep the positional hold-tap behavior but do
not use `require-prior-idle-ms`. This preserves the existing habit of holding a
home-row Shift key while pressing the next letter.

The tradeoff is that Shift can now misfire more easily than the other HRMs.
This is less dangerous than Ctrl/Alt/Gui misfires, but it can still produce
unexpected capitalization.

## Current Bindings

On the default layer:

- `A` uses `hmls` as `LSHIFT/A`.
- `D` uses `hml` as `LC(LS(LALT))/D`.
- `G` uses `hml` as `LC(LG(LALT))/G`.
- `J` uses `hmr` as `LC(LS(LALT))/J`.
- Quote uses `hmrs` as `RSHIFT/SQT`.

On the `WC3` layer:

- `A` uses `hmls` as `LSHIFT/A`.

Thumb keys still use `hm`, including Tab, Space, Backspace, Enter, and Delete.
This is intentional: the timeless HRM experiment is scoped to home-row mods, not
thumb behavior.

## Expected Typing Behavior

- Same-hand letter rolls should usually produce taps.
- Cross-hand HRM chords should produce holds.
- Ctrl/Alt/Gui HRMs should be protected from fast typing by prior-idle timing.
- Shift HRMs should support fast capitalization even immediately after another
  key.
- Standalone modifier use still requires holding past the tapping term.

## Known Tradeoffs

The shift HRMs are intentionally less protected than the non-shift HRMs. In
practice, this means:

- Fast capitalization such as `rV` should work better.
- Fast apostrophe-plus-left-hand sequences may accidentally become shifted
  letters.
- Same-hand protection still applies because the shift HRMs remain positional.
