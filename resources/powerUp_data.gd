class_name PowerUpData
extends PickupData

#If we want temporary Pickup PowerUps then we can use this class

func get_pickup_type() -> PickupType:
	return PickupType.Powerup
