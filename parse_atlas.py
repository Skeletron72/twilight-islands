from PIL import Image

img = Image.open('assets/sprites/ui/inventory/Book.png')
pixels = img.load()
width, height = img.size

# Find distinct non-transparent regions using simple flood fill
visited = set()
regions = []

for y in range(height):
    for x in range(width):
        if (x, y) not in visited:
            r, g, b, a = pixels[x, y]
            if a > 0:
                # Flood fill to find the bounding box
                min_x, max_x = x, x
                min_y, max_y = y, y
                stack = [(x, y)]
                while stack:
                    cx, cy = stack.pop()
                    if (cx, cy) in visited:
                        continue
                    visited.add((cx, cy))
                    min_x = min(min_x, cx)
                    max_x = max(max_x, cx)
                    min_y = min(min_y, cy)
                    max_y = max(max_y, cy)
                    
                    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)]:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < width and 0 <= ny < height:
                            if (nx, ny) not in visited:
                                _, _, _, na = pixels[nx, ny]
                                if na > 0:
                                    stack.append((nx, ny))
                regions.append((min_x, min_y, max_x - min_x + 1, max_y - min_y + 1))
            else:
                visited.add((x, y))

# Sort regions by size (largest first)
regions.sort(key=lambda r: r[2] * r[3], reverse=True)
for i, r in enumerate(regions[:10]):
    print(f"Region {i}: x={r[0]}, y={r[1]}, w={r[2]}, h={r[3]}")
