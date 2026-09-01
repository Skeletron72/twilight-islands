import struct
import zlib
import sys

def analyze(filename):
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
    
    print(f"Screenshot size: {width}x{height}")

analyze("/Users/andrey/.gemini/antigravity/brain/67e82d82-6891-49f4-ac32-ea1d0862a0c6/.user_uploaded/media_1788247327214.png")
