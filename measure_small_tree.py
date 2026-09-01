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
    
    min_x, max_x, min_y, max_y = width, 0, height, 0
    frame_w = width // 3
    
    for y in range(height):
        row_start = y * stride + 1
        row_pixels = pixels[row_start:row_start + width * 4]
        for x in range(frame_w, frame_w * 2): # frame 1
            idx = x * 4 + 3
            if row_pixels[idx] > 0:
                if x < min_x: min_x = x
                if x > max_x: max_x = x
                if y < min_y: min_y = y
                if y > max_y: max_y = y
                
    print(f"Bounds: X {min_x - frame_w}-{max_x - frame_w}, Y {min_y}-{max_y}")
    print(f"Width: {max_x - min_x + 1}, Height: {max_y - min_y + 1}")

get_bounds("assets/new_assets/Cute_Fantasy/Trees/Small_Oak_Tree.png")
