#!/usr/bin/env just --justfile

draw:
  keymap parse -c 10 -z ./config/corne.keymap > keymap.yaml
  keymap draw -j layout.json keymap.yaml > keymap.svg
