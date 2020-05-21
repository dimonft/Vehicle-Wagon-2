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
 *    - Loaded Vehicle Wagon (Light Tank)
 *    - Loaded Vehicle Wagon (Heavy Tank)
 *    - Loaded Vehicle Wagon (Super Heavy Tank)
 *    - Loaded Vehicle Wagon (Advanced Tank)
--]]


local function makeDummyItem(name)
  return {
      type = "item",
      name = name,
      icon = "__VehicleWagon2__/graphics/tech-icon.png",
      icon_size = 128,
      flags = {"hidden"},
      subgroup = "transport",
      order = "a[train-system]-z[vehicle-wagon]",
      place_result = name,
      stack_size = 1
    }
end


local useWeights = settings.startup["vehicle-wagon-use-custom-weights"].value
local maxWeight = (useWeights and settings.startup["vehicle-wagon-maximum-weight"].value) or math.huge

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
data:extend{vehicle_wagon}


local loaded_car = util.table.deepcopy(vehicle_wagon)
loaded_car.name = "loaded-vehicle-wagon-car"
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
  if data.raw["car"]["dumper-truck"].weight <= maxWeight then
    local loaded_truck = util.table.deepcopy(vehicle_wagon)
    loaded_truck.name = "loaded-vehicle-wagon-truck"
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
    data:extend{loaded_truck, makeDummyItem(loaded_truck.name)}
  end
end


if mods["Aircraft"] then
  if data.raw["car"]["cargo-plane"].weight <= maxWeight then
    local loaded_cargo_plane = util.table.deepcopy(vehicle_wagon)
    loaded_cargo_plane.name = "loaded-vehicle-wagon-cargoplane"
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
    data:extend{loaded_cargo_plane, makeDummyItem(loaded_cargo_plane.name)}
  end
  
  if data.raw["car"]["jet"].weight <= maxWeight then
    local loaded_jet = util.table.deepcopy(vehicle_wagon)
    loaded_jet.name = "loaded-vehicle-wagon-jet"
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
    data:extend{loaded_jet, makeDummyItem(loaded_jet.name)}
  end

	if data.raw["car"]["gunship"].weight <= maxWeight then
    local loaded_gunship = util.table.deepcopy(vehicle_wagon)
    loaded_gunship.name = "loaded-vehicle-wagon-gunship"
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
    data:extend{loaded_gunship, makeDummyItem(loaded_gunship.name)}
  end
  
end


if mods["SchallTankPlatoon"] then
  -- Add more Tank versions with different weights
  -- Light tanks is smaller and lighter
  if data.raw["car"]["Schall-tank-L"].weight <= maxWeight then
    local loaded_tank_L = util.table.deepcopy(loaded_tank)
    loaded_tank_L.name = "loaded-vehicle-wagon-tank-L"
    for i,layer in pairs(loaded_tank_L.pictures.layers) do
      if i > 1 then
        layer.scale = 0.95*0.8
      end
    end
    data:extend{loaded_tank_L, makeDummyItem(loaded_tank_L.name)}
  end

  
  -- Heavy tank is bigger and heavier
  if data.raw["car"]["Schall-tank-H"].weight <= maxWeight then
    local loaded_tank_H = util.table.deepcopy(loaded_tank)
    loaded_tank_H.name = "loaded-vehicle-wagon-tank-H"
    for i,layer in pairs(loaded_tank_H.pictures.layers) do
      if i > 1 then
        layer.scale = 0.95*1.5
      end
    end
    data:extend{loaded_tank_H, makeDummyItem(loaded_tank_H.name)}
  end

  
  -- Super Heavy tank is just comically big
  if data.raw["car"]["Schall-tank-SH"].weight <= maxWeight then
    local loaded_tank_SH = util.table.deepcopy(loaded_tank)
    loaded_tank_SH.name = "loaded-vehicle-wagon-tank-SH"
    for i,layer in pairs(loaded_tank_SH.pictures.layers) do
      if i > 1 then
        layer.scale = 0.95*2
      end
    end
    data:extend{loaded_tank_SH, makeDummyItem(loaded_tank_SH.name)}
  end

end


if mods["Krastorio2"] then
  require("__Krastorio2__/lib/public/data-stages/paths")

  -- Advanced Tank is also comically large
  if data.raw["car"]["kr-advanced-tank"].weight <= maxWeight then
    local loaded_advanced_tank = util.table.deepcopy(vehicle_wagon)
    loaded_advanced_tank.name = "loaded-vehicle-wagon-kr-advanced-tank"
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
  
    data:extend{loaded_advanced_tank, makeDummyItem(loaded_advanced_tank.name)}
  end
end
