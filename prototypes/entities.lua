

local useWeights = settings.startup["vehicle-wagon-use-custom-weights"].value
local weightFactor = settings.startup["vehicle-wagon-vehicle-weight-factor"].value
local emptyWeightFactor = settings.startup["vehicle-wagon-empty-weight-factor"].value

local vehicle_wagon = util.table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])
vehicle_wagon.name = "vehicle-wagon"
vehicle_wagon.icon = "__VehicleWagon2__/graphics/vehicle-wagon-icon.png"
vehicle_wagon.icon_size = 32
vehicle_wagon.inventory_size = 0
vehicle_wagon.minable = {mining_time = 1, result = "vehicle-wagon"}
vehicle_wagon.horizontal_doors = nil
vehicle_wagon.vertical_doors = nil
vehicle_wagon.pictures =
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png",
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		}
	}
}
if useWeights then
  vehicle_wagon.weight = vehicle_wagon.weight * emptyWeightFactor
end

local loaded_vehicle_wagon_tank = util.table.deepcopy(vehicle_wagon)
loaded_vehicle_wagon_tank.name = "loaded-vehicle-wagon-tank"
if useWeights then
  loaded_vehicle_wagon_tank.weight = vehicle_wagon.weight + (data.raw["car"]["tank"].weight * weightFactor)
end
loaded_vehicle_wagon_tank.pictures = 
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png",
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		},
		{
			width = 154,
			height = 99,
			direction_count = 128,
			shift = {0.69375, -0.571875},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/tank/base-shadow-1.png",
				"__VehicleWagon2__/graphics/tank/base-shadow-2.png",
				"__VehicleWagon2__/graphics/tank/base-shadow-3.png",
				"__VehicleWagon2__/graphics/tank/base-shadow-4.png"
			},
			line_length = 2,
			lines_per_file = 16,
		},
		{
			width = 139,
			height = 110,
			direction_count = 128,
			shift = {-0.040625, -1.18125},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/tank/base-1.png",
				"__VehicleWagon2__/graphics/tank/base-2.png",
				"__VehicleWagon2__/graphics/tank/base-3.png",
				"__VehicleWagon2__/graphics/tank/base-4.png"
			},
			line_length = 2,
			lines_per_file = 16,
		},
		{
			width = 92,
			height = 69,
			direction_count = 128,
			shift = {-0.05625, -1.97812},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/tank/turret-1.png",
				"__VehicleWagon2__/graphics/tank/turret-2.png",
				"__VehicleWagon2__/graphics/tank/turret-3.png",
				"__VehicleWagon2__/graphics/tank/turret-4.png"
			},
			line_length = 2,
			lines_per_file = 16,
		}
	}
}


local loaded_vehicle_wagon_car = util.table.deepcopy(vehicle_wagon)

loaded_vehicle_wagon_car.name = "loaded-vehicle-wagon-car"
if useWeights then
  loaded_vehicle_wagon_car.weight = vehicle_wagon.weight + (data.raw["car"]["car"].weight * weightFactor)
end
loaded_vehicle_wagon_car.pictures =
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png",
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		},
		{
			width = 114,
			height = 76,
			direction_count = 128,
			shift = {0.28125, -0.55},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/car/car-shadow-1.png",
				"__VehicleWagon2__/graphics/car/car-shadow-2.png",
				"__VehicleWagon2__/graphics/car/car-shadow-3.png"
			},
			line_length = 2,
			lines_per_file = 22,
		},
		{
			width = 102,
			height = 86,
			direction_count = 128,
			shift = {0, -0.9875},
			scale = 0.95,
			filenames =
			{
				"__base__/graphics/entity/car/car-1.png",
				"__base__/graphics/entity/car/car-2.png",
				"__base__/graphics/entity/car/car-3.png",
			},
			line_length = 2,
			lines_per_file = 22,
		},
		{
			width = 36,
			height = 29,
			direction_count = 128,
			shift = {0.03125, -1.690625},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/car/turret.png",
			},
			line_length = 2,
			lines_per_file = 64,
		}
	}
}

local loaded_vehicle_wagon_tarp = util.table.deepcopy(vehicle_wagon)

loaded_vehicle_wagon_tarp.name = "loaded-vehicle-wagon-tarp"
if useWeights then
  loaded_vehicle_wagon_tarp.weight = vehicle_wagon.weight * 2  -- arbitrary factor for unknown vehicles
end
loaded_vehicle_wagon_tarp.pictures =
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png",
				"__VehicleWagon2__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		},
		{
			width = 192,
			height = 192,
			direction_count = 128,
			shift = {0, -0.5},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/tarp/tarp-shadow-1.png",
				"__VehicleWagon2__/graphics/tarp/tarp-shadow-2.png",
				"__VehicleWagon2__/graphics/tarp/tarp-shadow-3.png",
				"__VehicleWagon2__/graphics/tarp/tarp-shadow-4.png"
			},
			line_length = 8,
			lines_per_file = 5,
		},
		{
			width = 192,
			height = 192,
			direction_count = 128,
			shift = {0, -0.5},
			scale = 0.95,
			filenames =
			{
				"__VehicleWagon2__/graphics/tarp/tarp-1.png",
				"__VehicleWagon2__/graphics/tarp/tarp-2.png",
				"__VehicleWagon2__/graphics/tarp/tarp-3.png",
				"__VehicleWagon2__/graphics/tarp/tarp-4.png"
			},
			line_length = 8,
			lines_per_file = 5,
		}
	}
}

data:extend({vehicle_wagon, loaded_vehicle_wagon_tank, loaded_vehicle_wagon_car, loaded_vehicle_wagon_tarp})

if data.raw["car"]["dumper-truck"] then
	local loaded_vehicle_wagon_truck = util.table.deepcopy(vehicle_wagon)
	loaded_vehicle_wagon_truck.name = "loaded-vehicle-wagon-truck"
  if useWeights then
    loaded_vehicle_wagon_truck.weight = vehicle_wagon.weight + (data.raw["car"]["dumper-truck"].weight * weightFactor)
  end
	loaded_vehicle_wagon_truck.pictures =
	{
		layers =
		{
			{
				priority = "very-low",
				width = 256,
				height = 256,
				direction_count = 128,
				filenames =
				{
					"__VehicleWagon2__/graphics/cargo_fb_sheet.png",
					"__VehicleWagon2__/graphics/cargo_fb_sheet.png"
				},
				line_length = 8,
				lines_per_file = 8,
				shift={0.4, -1.20}
			},
			{
				width = 192,
				height = 192,
				direction_count = 128,
				shift = {0, -0.5},
				scale = 0.95,
				filenames =
				{
					"__VehicleWagon2__/graphics/truck/truck-shadow-1.png",
					"__VehicleWagon2__/graphics/truck/truck-shadow-2.png",
					"__VehicleWagon2__/graphics/truck/truck-shadow-3.png",
					"__VehicleWagon2__/graphics/truck/truck-shadow-4.png"
				},
				line_length = 8,
				lines_per_file = 5,
			},
			{
				width = 192,
				height = 192,
				direction_count = 128,
				shift = {0, -0.5},
				scale = 0.95,
				filenames =
				{
					"__VehicleWagon2__/graphics/truck/truck-1.png",
					"__VehicleWagon2__/graphics/truck/truck-2.png",
					"__VehicleWagon2__/graphics/truck/truck-3.png",
					"__VehicleWagon2__/graphics/truck/truck-4.png"
				},
				line_length = 8,
				lines_per_file = 5,
			}
		}
	}

	data:extend({loaded_vehicle_wagon_truck})
end


if mods["Aircraft"] then
	local loaded_vehicle_wagon_cargo_plane = util.table.deepcopy(vehicle_wagon)
	loaded_vehicle_wagon_cargo_plane.name = "loaded-vehicle-wagon-cargoplane"
  if useWeights then
    loaded_vehicle_wagon_cargo_plane.weight = vehicle_wagon.weight + (data.raw["car"]["cargo-plane"].weight * weightFactor)
  end
	loaded_vehicle_wagon_cargo_plane.pictures =
	{
		layers =
		{
			{
				--priority = "very-low",
				width = 256,
				height = 256,
				direction_count = 128,
				filenames =
				{
					"__VehicleWagon2__/graphics/cargoplane/flyer3onr_sheet-0.png",
					"__VehicleWagon2__/graphics/cargoplane/flyer3onr_sheet-1.png"
				},
				line_length = 8,
				lines_per_file = 8,
				shift={0, -0.6}
			}
		}
	}

	local loaded_vehicle_wagon_jet = util.table.deepcopy(vehicle_wagon)
	loaded_vehicle_wagon_jet.name = "loaded-vehicle-wagon-jet"
	if useWeights then
    loaded_vehicle_wagon_jet.weight = vehicle_wagon.weight + (data.raw["car"]["jet"].weight * weightFactor)
  end
	loaded_vehicle_wagon_jet.pictures =
	{
		layers =
		{
			{
				--priority = "very-low",
				width = 256,
				height = 256,
				direction_count = 128,
				filenames =
				{
					"__VehicleWagon2__/graphics/jet/flyer2onr_sheet-0.png",
					"__VehicleWagon2__/graphics/jet/flyer2onr_sheet-1.png"
				},
				line_length = 8,
				lines_per_file = 8,
				shift={0, -0.6}
			}
		}
	}

	local loaded_vehicle_wagon_gunship = util.table.deepcopy(vehicle_wagon)
	loaded_vehicle_wagon_gunship.name = "loaded-vehicle-wagon-gunship"
	if useWeights then
    loaded_vehicle_wagon_gunship.weight = vehicle_wagon.weight + (data.raw["car"]["gunship"].weight * weightFactor)
  end
	loaded_vehicle_wagon_gunship.pictures =
	{
		layers =
		{
			{
				--priority = "very-low",
				width = 256,
				height = 256,
				direction_count = 128,
				filenames =
				{
					"__VehicleWagon2__/graphics/gunship/flyer1onr_sheet-0b.png",
					"__VehicleWagon2__/graphics/gunship/flyer1onr_sheet-1b.png"
				},
				line_length = 8,
				lines_per_file = 8,
				shift={0, -0.6}
			}
		}
	}

	data:extend({loaded_vehicle_wagon_cargo_plane,
               loaded_vehicle_wagon_gunship,
               loaded_vehicle_wagon_jet})
end