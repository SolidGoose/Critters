extends Label

var smallDictionary: Array[String] = [
    "sun",
    "sky",
    "mud",
    "dew",
    "fog",
    "oak",
    "bee",
    "ant",
    "ice",
    "bay",
    "sea",
    "pet",
    "bud",
    "elm",
    "ray",
    "sap",
    "pod",
    "pit",
    "lea",
    "log",
    "fly",
]
var mediunDictionary: Array[String] = [
    "tree",
    "leaf",
    "bark",
    "fern",
    "rock",
    "pond",
    "rain",
    "wind",
    "soil",
    "moss",
    "seed",
    "root",
    "hill",
    "lake",
    "star",
    "river",
    "grass",
    "cloud",
    "stone",
    "flora",
    "petal",
    "earth",
    "ocean",
    "field",
    "swamp",
    "creek",
    "plant",
    "bloom",
    "woods",
    "sprig",
    "forest",
    "branch",
    "meadow",
    "stream",
    "flower",
    "island",
    "desert",
    "valley",
    "sprout",
    "thorns",
    "canopy",
    "groves",
    "petals",
    "shrub",
    "lagoon",
]

func _ready() -> void:
    var parentName = get_parent().stats.name
    match parentName:
        "squirrel":
            text = mediunDictionary.pick_random()
        "mouse":
            text = smallDictionary.pick_random()
        _:
            text = mediunDictionary.pick_random()
