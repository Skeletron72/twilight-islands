import struct
import zlib

def get_bounds(filename):
    with open(filename, 'rb') as f: data = f.read()
    pos = 8
    width = height = 0
    idat_data = bytearray()
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        if chunk_type == b'IHDR': width, height = struct.unpack('>II', chunk_data[:8])
        elif chunk_type == b'IDAT': idat_data.extend(chunk_data)
        elif chunk_type == b'IEND': break
        pos += 8 + length + 4
    pixels = zlib.decompress(idat_data)
    stride = width * 4 + 1
    
    frame_h = height // 56
    frame_w = width // 9
    print(f"Total size: {width}x{height}. Frame size: {frame_w}x{frame_h}")
    
    # Check first frame
    min_x, max_x, min_y, max_y = frame_w, 0, frame_h, 0
    for y in range(frame_h):
        row_start = y * stride + 1
        row_pixels = pixels[row_start:row_start + width * 4]
        for x in range(frame_w):
            idx = x * 4 + 3
            if row_pixels[idx] > 0:
                if x < min_x: min_x = x
                if x > max_x: max_x = x
                if y < min_y: min_y = y
                if y > max_y: max_y = y
                
    print(f"Bounds: X {min_x}-{max_x}, Y {min_y}-{max_y}")
    print(f"Width: {max_x - min_x + 1}, Height: {max_y - min_y + 1}")
    print(f"Feet at relative Y = {max_y}. Center of frame is {frame_h/2.0}.")

get_bounds("assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png")
