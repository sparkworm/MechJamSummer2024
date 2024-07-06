extends NavigationRegion3D
class_name NavRegion

#not sure if needed but IDE is complaining
func _ready() -> void:
	var cellHeight: float = navigation_mesh.cell_height
	var mapID: RID = get_navigation_map()
	NavigationServer3D.map_set_cell_height(mapID, cellHeight)
