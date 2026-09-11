for fpath in ["scripts/components/ladder_down.gd", "scripts/components/wall_ladder.gd", "scripts/components/cave_entrance.gd"]:
    with open(fpath, "r") as f:
        txt = f.read()
    if "var no_highlight: bool = true" not in txt:
        # insert after class_name or at top
        txt = txt.replace("class_name ", "var no_highlight: bool = true\n\nclass_name ")
        with open(fpath, "w") as f:
            f.write(txt)
        print("Added no_highlight to", fpath)
