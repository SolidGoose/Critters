extends Label

var dictionary: Array[String] = [
    "nut",
    "tail",
    "tree",
    "acorn",
    "leap",
    "scamper",
    "bushy",
    "paws",
    "nest",
    "bark",
    "twig",
    "chase",
    "jump",
    "fur",
    "den"
]


func _ready() -> void:
	text = dictionary.pick_random()
