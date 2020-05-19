--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: entities.lua
 * Description:  Add entity prototypes.  Adjust wagon weights based on startup settings vehicle prototypes.
 *   Entities added:
 *    - Vehicle Wagon (empty)
 *    - Loaded Vehicle Wagon (Car)
 *    - Loaded Vehicle Wagon (Tank)
 *    - Loaded Vehicle Wagon (Tarp)
 *    - Loaded Vehicle Wagon (Truck)
 *    - Loaded Vehicle Wagon (Cargo Plane)
 *    - Loaded Vehicle Wagon (Gunship)
 *    - Loaded Vehicle Wagon (Jet)
--]]


local useWeights = settings.startup["vehicle-wagon-use-custom-weights"].value
local maxWeight = settings.startup["vehicle-wagon-maximum-weight"].value
local weightFactor = settings.startup["vehicle-wagon-vehicle-weight-factor"].value
local emptyWeightFactor = settings.startup["vehicle-wagon-empty-weight-factor"].value
local brakingFactor = settings.startup["vehicle-wagon-braking-factor"].value
local emptyFrictionFactor = settings.startup["vehicle-wagon-empty-friction-factor"].value
local loadedFrictionFactor = settings.startup["vehicle-wagon-loaded-friction-factor"].value

local loadedFriction = data.raw["cargo-wagon"]["cargo-wagon"].friction_force * loadedFrictionFactor

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
  vehicle_wagon.braking_force = vehicle_wagon.braking_force * brakingFactor
  vehicle_wagon.friction_force = vehicle_wagon.friction_force * emptyFrictionFactor
end

data:extend{vehicle_wagon}

-- Some prototypes will not be created if they are too heavy.
-- Compare to max vehicle weight + empty wagon weight.
maxWeight = maxWeight + vehicle_wagon.weight

local function makeDummyItem(mns)
  return {
      type = "item",
      name = mns,
      icon = "__VehicleWagon2__/graphics/tech-icon.png",
      icon_size = 128,
      flags = {"hidden"},
      subgroup = "transport",
      order = "a[train-system]-z[vehicle-wagon]",
      place_result = mns,
      stack_size = 1
    }
end



local loaded_car = util.table.deepcopy(vehicle_wagon)
loaded_car.name = "loaded-vehicle-wagon-car"
if useWeights then
  loaded_car.weight = vehicle_wagon.weight + (data.raw["car"]["car"].weight * weightFactor)
  loaded_car.friction_force = loadedFriction
end
loaded_car.pictures =
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

local loaded_tarp = util.table.deepcopy(vehicle_wagon)
loaded_tarp.name = "loaded-vehicle-wagon-tarp"
if useWeights then
  loaded_tarp.weight = loaded_car.weight  -- Use weight of Car for unknown vehicles
  loaded_tarp.friction_force = loadedFriction
end
loaded_tarp.pictures =
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


local loaded_tank = util.table.deepcopy(vehicle_wagon)
loaded_tank.name = "loaded-vehicle-wagon-tank"
if useWeights then
  loaded_tank.weight = vehicle_wagon.weight + (data.raw["car"]["tank"].weight * weightFactor)
  loaded_tank.friction_force = loadedFriction
end
loaded_tank.pictures = 
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
-- Car, Tank, and Tarp need to be loaded regardless of weight limit
data:extend{loaded_car, makeDummyItem(loaded_car.name), 
            loaded_tank, makeDummyItem(loaded_tank.name), 
            loaded_tarp, makeDummyItem(loaded_tarp.name)}


if mods["bigtruck"] then
	local loaded_truck = util.table.deepcopy(vehicle_wagon)
	loaded_truck.name = "loaded-vehicle-wagon-truck"
  if useWeights then
    loaded_truck.weight = vehicle_wagon.weight + (data.raw["car"]["dumper-truck"].weight * weightFactor)
    loaded_truck.friction_force = loadedFriction
  end
	loaded_truck.pictures =
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
  if not useWeights or loaded_truck.weight <= maxWeight then
    data:extend{loaded_truck, makeDummyItem(loaded_truck.name)}
  end
end


if mods["Aircraft"] then
	local loaded_cargo_plane = util.table.deepcopy(vehicle_wagon)
	loaded_cargo_plane.name = "loaded-vehicle-wagon-cargoplane"
  if useWeights then
    loaded_cargo_plane.weight = vehicle_wagon.weight + (data.raw["car"]["cargo-plane"].weight * weightFactor)
    loaded_cargo_plane.friction_force = loadedFriction
  end
	loaded_cargo_plane.pictures =
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

	local loaded_jet = util.table.deepcopy(vehicle_wagon)
	loaded_jet.name = "loaded-vehicle-wagon-jet"
	if useWeights then
    loaded_jet.weight = vehicle_wagon.weight + (data.raw["car"]["jet"].weight * weightFactor)
    loaded_jet.friction_force = loadedFriction
  end
	loaded_jet.pictures =
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

	local loaded_gunship = util.table.deepcopy(vehicle_wagon)
	loaded_gunship.name = "loaded-vehicle-wagon-gunship"
	if useWeights then
    loaded_gunship.weight = vehicle_wagon.weight + (data.raw["car"]["gunship"].weight * weightFactor)
    loaded_gunship.friction_force = loadedFriction
  end
	loaded_gunship.pictures =
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

	data:extend{
    loaded_cargo_plane, makeDummyItem(loaded_cargo_plane.name),
    loaded_gunship, makeDummyItem(loaded_gunship.name),
    loaded_jet, makeDummyItem(loaded_jet.name),
  }
end


if mods["SchallTankPlatoon"] then
  -- Add more Tank versions with different weights
  -- Light tanks is smaller and lighter
  local loaded_tank_L = util.table.deepcopy(loaded_tank)
  loaded_tank_L.name = "loaded-vehicle-wagon-tank-L"
  if useWeights then
    loaded_tank_L.weight = vehicle_wagon.weight + (data.raw["car"]["Schall-tank-L"].weight * weightFactor)
    loaded_tank_L.friction_force = loadedFriction
  end
  for i,layer in pairs(loaded_tank_L.pictures.layers) do
    if i > 1 then
      layer.scale = 0.95*0.8
    end
  end
  if not useWeights or loaded_tank_L.weight <= maxWeight then
    data:extend{loaded_tank_L, makeDummyItem(loaded_tank_L.name)}
  end

  
  -- Heavy tank is bigger and heavier
  local loaded_tank_H = util.table.deepcopy(loaded_tank)
  loaded_tank_H.name = "loaded-vehicle-wagon-tank-H"
  if useWeights then
    loaded_tank_H.weight = vehicle_wagon.weight + (data.raw["car"]["Schall-tank-H"].weight * weightFactor)
    loaded_tank_H.friction_force = loadedFriction
  end
  for i,layer in pairs(loaded_tank_H.pictures.layers) do
    if i > 1 then
      layer.scale = 0.95*1.5
    end
  end
  if not useWeights or loaded_tank_H.weight <= maxWeight then
    data:extend{loaded_tank_H, makeDummyItem(loaded_tank_H.name)}
  end

  
  -- Super Heavy tank is just comically big
  local loaded_tank_SH = util.table.deepcopy(loaded_tank)
  loaded_tank_SH.name = "loaded-vehicle-wagon-tank-SH"
  if useWeights then
    loaded_tank_SH.weight = vehicle_wagon.weight + (data.raw["car"]["Schall-tank-SH"].weight * weightFactor)
    loaded_tank_SH.friction_force = loadedFriction
  end
  for i,layer in pairs(loaded_tank_SH.pictures.layers) do
    if i > 1 then
      layer.scale = 0.95*2
    end
  end
  if not useWeights or loaded_tank_SH.weight <= maxWeight then
    data:extend{loaded_tank_SH, makeDummyItem(loaded_tank_SH.name)}
  end

end


if mods["Krastorio2"] then
  require("__Krastorio2__/lib/public/data-stages/paths")

  -- Advanced Tank is also comically large
  local loaded_advanced_tank = util.table.deepcopy(vehicle_wagon)
  loaded_advanced_tank.name = "loaded-vehicle-wagon-kr-advanced-tank"
  if useWeights then
    vehicle_weight = data.raw["car"]["kr-advanced-tank"].weight
    loaded_advanced_tank.weight = vehicle_wagon.weight + (vehicle_weight * weightFactor)
    loaded_advanced_tank.friction_force = loadedFriction
  end
  loaded_advanced_tank.pictures = 
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
        width = 208,
        height = 208,
        direction_count = 128,
        shift = {0, -0.5},
        scale = 0.95,
        filenames = 
        {
          kr_entities_path .. "advanced-tank/advanced-tank-base.png"
        },
        line_length = 16,
        lines_per_file = 8
			},--[[
      {
        width = 250,
        height = 250,
        direction_count = 128,
        shift = {0, -0.5},
        scale = 0.95,
        filenames = 
        {
          kr_entities_path .. "advanced-tank/advanced-tank-turret.png"
        },
        line_length = 16,
        lines_per_file = 8
			},
      {
        width = 208,
        height = 208,
        direction_count = 128,
        shift = {0, -0.5},
        line_length = 16,
        scale = 0.95,
        stripes =
        {
          {
            filename = kr_entities_path .. "advanced-tank/advanced-tank-base.png",
            width_in_frames = 16,
            height_in_frames = 8
          }
        },
      },
      {
        width = 258,
        height = 258,
        frame_count = 1,
        draw_as_shadow = true,
        direction_count = 64,
        animation_speed = 6,
        max_advance = 0.2,
        line_length = 16,
        shift = {0.75, 0.25},
        scale = 0.95,
        stripes = 
        {
          {
            filename = kr_entities_path .. "advanced-tank/advanced-tank-turret-shadow.png",
            width_in_frames = 8,
            height_in_frames = 8
          }
        },
      },
      {
        width = 250,
        height = 250,
        frame_count = 1,
        direction_count = 64,
        shift = {0, 0.25},
        scale = 0.95,
        animation_speed = 6,
        max_advance = 0.2,
        line_length = 16,
        stripes =
        {
          {
            filename = kr_entities_path .. "advanced-tank/advanced-tank-turret.png",
            width_in_frames = 8,
            height_in_frames = 8
          }
        },
      }--]]
    }
  }
  
  if not useWeights or loaded_advanced_tank.weight <= maxWeight then
    data:extend{loaded_advanced_tank, makeDummyItem(loaded_advanced_tank.name)}
  end
end
