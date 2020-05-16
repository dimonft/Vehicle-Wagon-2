--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: items.lua
 * Description:  Add item prototypes.
 *   Items added:
 *    - Vehicle Wagon (empty)
 *    - Loaded Vehicle Wagon (Car)
 *    - Loaded Vehicle Wagon (Tank)
 *    - Loaded Vehicle Wagon (Tarp)
 *    - Winch (capsule)
 *    - Loaded Vehicle Wagon (Truck)
 *    - Loaded Vehicle Wagon (Cargo Plane)
 *    - Loaded Vehicle Wagon (Gunship)
 *    - Loaded Vehicle Wagon (Jet)
--]]


-- Compatibility with Schall's Transport Group mod
local subgroup_vehrail = "transport"

if mods["SchallTransportGroup"] then
	subgroup_vehrail = "vehicles-railway"
end


data:extend({
  {
		type = "capsule",
		name = "winch",
		icon = "__VehicleWagon2__/graphics/winch-icon.png",
		icon_size = 64,
		subgroup = "transport",
		order = "a[train-system]-w[winch]",
		stack_size = 1,
    capsule_action =
		{
			type = "throw",
      uses_stack = false,
			attack_parameters =
			{
				type = "projectile",
				ammo_category = "melee",
				cooldown = 15,
				range = 9,
				ammo_type =
				{
					category = "melee",
					target_type = "entity",
					action =
					{
						type = "direct",
						action_delivery =
						{
							type = "instant",
							target_effects =
							{
								{
									type = "play-sound",
									sound =
									{
										{
											filename = "__VehicleWagon2__/sound/latchOn.ogg",
											volume = 0
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
})

data:extend({
	{
		type = "item",
		name = "vehicle-wagon",
		icon = "__VehicleWagon2__/graphics/tech-icon.png",
		icon_size = 128,
		subgroup = subgroup_vehrail,
		order = "a[train-system]-v[vehicle-wagon]",
		place_result = "vehicle-wagon",
		stack_size = 5
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-tank",
		icon = "__VehicleWagon2__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-tank",
		stack_size = 1
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-car",
		icon = "__VehicleWagon2__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-car",
		stack_size = 1
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-tarp",
		icon = "__VehicleWagon2__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-tarp",
		stack_size = 1
	}
})

if mods["bigtruck"] then
	data:extend({
		{
			type = "item",
			name = "loaded-vehicle-wagon-truck",
			icon = "__VehicleWagon2__/graphics/tech-icon.png",
			icon_size = 128,
			flags = {"hidden"},
			subgroup = "transport",
			order = "a[train-system]-z[vehicle-wagon]",
			place_result = "loaded-vehicle-wagon-truck",
			stack_size = 1
		},
	})
end

if mods["Aircraft"] then
	data:extend({
		{
			type = "item",
			name = "loaded-vehicle-wagon-cargoplane",
			icon = "__VehicleWagon2__/graphics/tech-icon.png",
			icon_size = 128,
			flags = {"hidden"},
			subgroup = "transport",
			order = "a[train-system]-z[vehicle-wagon]",
			place_result = "loaded-vehicle-wagon-cargoplane",
			stack_size = 1
		},
	})

	data:extend({
		{
			type = "item",
			name = "loaded-vehicle-wagon-jet",
      icon = "__VehicleWagon2__/graphics/tech-icon.png",
			icon_size = 128,
			flags = {"hidden"},
			subgroup = "transport",
			order = "a[train-system]-z[vehicle-wagon]",
			place_result = "loaded-vehicle-wagon-jet",
			stack_size = 1
		},
	})

	data:extend({
		{
			type = "item",
			name = "loaded-vehicle-wagon-gunship",
			icon = "__VehicleWagon2__/graphics/tech-icon.png",
			icon_size = 128,
			flags = {"hidden"},
			subgroup = "transport",
			order = "a[train-system]-z[vehicle-wagon]",
			place_result = "loaded-vehicle-wagon-gunship",
			stack_size = 1
		},
	})
end
