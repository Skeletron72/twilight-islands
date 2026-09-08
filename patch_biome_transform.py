import re

with open("scripts/components/biome_zone.gd", "r") as f:
    content = f.read()

# Fix generation
old_gen = """                if not too_close:
                    var inst = scene.instantiate()
                    inst.position = pt
                    inst.set_meta("auto_generated", true)
                    add_child(inst)"""

new_gen = """                if not too_close:
                    var inst = scene.instantiate()
                    # Учитываем смещение/поворот/масштаб самого узла полигона!
                    inst.position = col_poly.transform * pt
                    inst.set_meta("auto_generated", true)
                    add_child(inst)"""

content = content.replace(old_gen, new_gen)

with open("scripts/components/biome_zone.gd", "w") as f:
    f.write(content)
print("Transform patched")
