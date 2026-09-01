from PIL import Image

img = Image.open("assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png")
width, height = img.size

frame_w = 64
frame_h = 64
cols = width // frame_w
rows = height // frame_h

print(f"Size: {width}x{height}, {cols} cols, {rows} rows")

for r in range(rows):
    frames = 0
    for c in range(cols):
        # crop frame
        box = (c * frame_w, r * frame_h, (c + 1) * frame_w, (r + 1) * frame_h)
        frame = img.crop(box)
        # check if empty
        extrema = frame.getextrema()
        # extrema is a tuple of (min, max) for each band (R, G, B, A)
        if extrema[3][1] > 0: # max Alpha > 0
            frames += 1
    print(f"Row {r:2d}: {frames} frames")
