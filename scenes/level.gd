extends TileMap


func build_bridge():
	for layer_id in range(self.get_layers_count()):
		var layer_name = self.get_layer_name(layer_id)
		if layer_name == "3-bridge-shadow":
			self.set_layer_enabled(layer_id, true)
		if layer_name == "12-bridge":
			self.set_layer_enabled(layer_id, true)
		if layer_name == "12-bridge-broken":
			self.set_layer_enabled(layer_id, false)
