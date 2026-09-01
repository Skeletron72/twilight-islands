import os, struct, zlib

def get_dims(filename):
    with open(filename, 'rb') as f: data = f.read()
    pos = 8
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos+4])[0]
        chunk_type = data[pos+4:pos+8]
        if chunk_type == b'IHDR':
            return struct.unpack('>II', data[pos+8:pos+16])
        pos += 8 + length + 4
    return 0, 0

def test_logic():
    base_dir = "assets/new_assets/Cute_Fantasy/Tiles/Water"
    files = [f for f in os.listdir(base_dir) if f.endswith('.png')]
    anims = [f for f in files if "Anim" in f]
    bases = [f for f in files if "Anim" not in f]
    print("Anims:")
    for a in anims:
        wa, ha = get_dims(os.path.join(base_dir, a))
        possible_bases = [b for b in bases if a.startswith(b.replace(".png", ""))]
        if possible_bases:
            possible_bases.sort(key=len, reverse=True)
            best_base = possible_bases[0]
            wb, hb = get_dims(os.path.join(base_dir, best_base))
            frames = wa / wb
            print(f"  {a}: found base {best_base} ({wb}x{hb}). Frames = {frames}")
        else:
            print(f"  {a}: NO BASE FOUND ({wa}x{ha})")

test_logic()
