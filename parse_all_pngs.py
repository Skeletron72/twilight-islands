import struct
import zlib
import glob
import os

def get_bottom_pixel(filename):
    with open(filename, 'rb') as f: data = f.read()
    pos = 8
    width = height = 0
    idat_data = bytearray()
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        if chunk_type == b'IHDR':
            width, height = struct.unpack('>II', chunk_data[:8])
        elif chunk_type == b'IDAT':
            idat_data.extend(chunk_data)
        elif chunk_type == b'IEND':
            break
        pos += 8 + length + 4
    pixels = zlib.decompress(idat_data)
    stride = width * 4 + 1
    for y in range(height - 1, -1, -1):
        row_start = y * stride + 1
        row_pixels = pixels[row_start:row_start + width * 4]
        for i in range(3, len(row_pixels), 4):
            if row_pixels[i] > 0:
                return height - 1 - y
    return 0

def get_top_pixel(filename):
    with open(filename, 'rb') as f: data = f.read()
    pos = 8
    width = height = 0
    idat_data = bytearray()
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        if chunk_type == b'IHDR':
            width, height = struct.unpack('>II', chunk_data[:8])
        elif chunk_type == b'IDAT':
            idat_data.extend(chunk_data)
        elif chunk_type == b'IEND':
            break
        pos += 8 + length + 4
    pixels = zlib.decompress(idat_data)
    stride = width * 4 + 1
    for y in range(height):
        row_start = y * stride + 1
        row_pixels = pixels[row_start:row_start + width * 4]
        # Only check the second frame (full tree), which starts at x = width // 3
        frame_w = width // 3
        for x in range(frame_w, frame_w * 2):
            idx = x * 4 + 3
            if row_pixels[idx] > 0:
                return y
    return 0
    
def get_dimensions(filename):
    with open(filename, 'rb') as f: data = f.read()
    pos = 8
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        if chunk_type == b'IHDR':
            return struct.unpack('>II', chunk_data[:8])
        pos += 8 + length + 4

for filepath in glob.glob('assets/new_assets/Cute_Fantasy/Trees/*_Tree.png') + glob.glob('assets/new_assets/Cute_Fantasy/Trees/*_tree.png'):
    basename = os.path.basename(filepath)
    w, h = get_dimensions(filepath)
    b = get_bottom_pixel(filepath)
    t = get_top_pixel(filepath)
    print(f"{basename}: {w}x{h}, bottom_trans={b}, top_trans={t}")
