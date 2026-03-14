extends Control

@onready var controller := $SkillTreeController
@onready var tree_canvas := $TreeViewport/TreeCanvas

func _ready():
	controller.init(tree_canvas)
