import base64
import os

# 16x16 pixel art circle for base (transparent inside, white border)
base_png_b64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAGRJREFUOE+tkFEKACAIQ+3+h65fCx1OENjP0/BqNQCgPzSA7yU10C0+mQdEq/hKHiAa2XfyADG52uYB2T8X7z9gTewR8R/g9g0x2wLcP8RtC3D/ELctcNyH1G2B4z6kbosD7gG9O16o4bK3MwAAAABJRU5ErkJggg=="

# 16x16 pixel art filled circle for knob (white)
knob_png_b64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAD5JREFUOE9jZKAQMELp/1TSSJSBMGzAhAEjDUEWxiRHYg2jgYFswGjYjIYNmUHQDZiIx2hwMBqBwWwEBgQAAItQIRBv7v3GAAAAAElFTkSuQmCC"

# 16x16 pixel art filled circle for action button (reddish)
act_png_b64 = "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAD9JREFUOE9jZKAQMELp/9SxhJEoA2HYgAkDRhqCLMxJjsQaRgMD2YDRsBkNGzKDoBswEY/R4GA0AoPZCAwIAAD+nSEQD9wH3AAAAABJRU5ErkJggg=="

os.makedirs("assets/sprites/ui", exist_ok=True)
with open("assets/sprites/ui/joy_base.png", "wb") as f:
    f.write(base64.b64decode(base_png_b64))
with open("assets/sprites/ui/joy_knob.png", "wb") as f:
    f.write(base64.b64decode(knob_png_b64))
with open("assets/sprites/ui/action_button.png", "wb") as f:
    f.write(base64.b64decode(act_png_b64))
