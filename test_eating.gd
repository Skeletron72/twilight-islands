extends SceneTree

func _init():
    var item_data = {
        "name": "Рубиновая ягода",
        "hunger_restore": 20.0
    }
    var consumed = false
    if item_data.has("hunger_restore"):
        print("has hunger restore")
        consumed = true
    if consumed:
        print("consumed")
    quit()
