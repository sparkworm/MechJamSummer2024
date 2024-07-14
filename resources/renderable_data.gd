class_name RenderableData
extends Resource
#Base class for most resources that can exist in data and/or be rendered in scene

@export var _name: String = ""
@export var _mesh: PackedScene = null #Useful to swap models out, not sure if this is the correct mesh resource class to use
@export var _sprite: Texture = null #Useful for interface (UI) icons, not sure if correct sprite class to use
