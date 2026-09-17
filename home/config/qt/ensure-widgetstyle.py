#!/usr/bin/env python3
"""Ensure [KDE] widgetStyle=Breeze in ~/.config/kdeglobals (idempotent)."""
import configparser, os
p = os.path.expanduser("~/.config/kdeglobals")
cp = configparser.RawConfigParser(strict=False)
cp.optionxform = str
if os.path.exists(p):
    cp.read(p, encoding="utf-8")
if not cp.has_section("KDE"):
    cp.add_section("KDE")
if cp.get("KDE", "widgetStyle", fallback=None) != "Breeze":
    cp.set("KDE", "widgetStyle", "Breeze")
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        cp.write(f, space_around_delimiters=False)
