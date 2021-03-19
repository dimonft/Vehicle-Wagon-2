--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: items.lua
 * Description:  Add item prototypes.
 *   Items added:
 *    - Vehicle Wagon (empty)
 *    - Loaded Vehicle Wagon (Car)
 *    - Loaded Vehicle Wagon (Tank)
 *    - Loaded Vehicle Wagon (Tarp)
 *    - Winch (selection tool)
 *    - Loaded Vehicle Wagon (Truck)
 *    - Loaded Vehicle Wagon (Cargo Plane)
 *    - Loaded Vehicle Wagon (Gunship)
 *    - Loaded Vehicle Wagon (Jet)
--]]


data:extend{
  {
		type = "selection-tool",
		name = "winch",
		icon = "__VehicleWagon2__/graphics/winch-icon.png",
		icon_size = 64,
    mipmaps = 1,
		subgroup = "transport",
		order = "a[train-system]-w[winch]",
		stack_size = 1,
    
    --mouse_cursor = "selection-tool-cursor",
    selection_color = {r=0.75, g=0.75},
    alt_selection_color = {g=1},
    selection_cursor_box_type = "entity",
    alt_selection_cursor_box_type = "entity",
    selection_mode = "any-entity",
    alt_selection_mode = "any-entity",
    entity_type_filters = {"cargo-wagon","car","spider-vehicle"},
    alt_entity_type_filters = {"cargo-wagon","car","spider-vehicle"},
	}
}

data:extend{
	{
		type = "item-with-entity-data",
		name = "vehicle-wagon",
		icon = "__VehicleWagon2__/graphics/tech-icon.png",
		icon_size = 128,
    icon_mipmaps = 1,
		subgroup = "transport",
		order = "a[train-system]-v[vehicle-wagon]",
		place_result = "vehicle-wagon",
		stack_size = 5
	},
}
