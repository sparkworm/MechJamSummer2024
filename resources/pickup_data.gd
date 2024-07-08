class_name PickupData
extends RenderableData

func get_pickup_type() -> PickupType:
	return PickupType.None

enum PickupType
{
	None,
	Energy,
	Health,
	Ammo,
	Powerup,
}
#PickupData can be paired with PickUp objects to be obtained in scene
