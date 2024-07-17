class_name ArtifactData
extends PickupData

#If we want temporary Pickup PowerUps then we can use this class

func get_pickup_type() -> PickupType:
	return PickupType.Artifact
