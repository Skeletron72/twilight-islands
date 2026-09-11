for fpath in ["scripts/components/ladder_down.gd", "scripts/components/wall_ladder.gd", "scripts/components/cave_entrance.gd"]:
    with open(fpath, "r") as f:
        txt = f.read()
    # Remove any var no_highlight placed before class_name
    lines = txt.splitlines()
    new_lines = []
    has_nh = False
    for line in lines:
        if line.strip() == "var no_highlight: bool = true":
            continue
        new_lines.append(line)
        if line.startswith("class_name"):
            new_lines.append("")
            new_lines.append("var no_highlight: bool = true")
    with open(fpath, "w") as f:
        f.write("\n".join(new_lines) + "\n")
    print("Fixed order in", fpath)
