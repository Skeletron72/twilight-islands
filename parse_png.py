import struct
import zlib

def get_bottom_pixel(filename):
    with open(filename, 'rb') as f:
        data = f.read()
    
    assert data[:8] == b'\x89PNG\r\n\x1a\n'
    
    pos = 8
    width = height = 0
    idat_data = bytearray()
    
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        chunk_data = data[pos+8:pos+8+length]
        
        if chunk_type == b'IHDR':
            width, height = struct.unpack('>II', chunk_data[:8])
            bit_depth, color_type = chunk_data[8], chunk_data[9]
            assert bit_depth == 8 and color_type == 6 # RGBA
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
        # Check alpha channel
        for i in range(3, len(row_pixels), 4):
            if row_pixels[i] > 0:
                # Found non-transparent pixel
                # Return distance from bottom
                return height - 1 - y
                
    return 0

print("Big Birch:", get_bottom_pixel("assets/new_assets/Cute_Fantasy/Trees/Big_Birch_Tree.png"))
print("Big Oak:", get_bottom_pixel("assets/new_assets/Cute_Fantasy/Trees/Big_Oak_Tree.png"))
print("Small Oak:", get_bottom_pixel("assets/new_assets/Cute_Fantasy/Trees/Small_Oak_Tree.png"))
