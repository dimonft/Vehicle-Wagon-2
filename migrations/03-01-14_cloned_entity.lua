--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: 03-01-14_cloned_entity.lua
 * Description: LUA Migration from 3.1.13 to 3.1.14
--]]

-- Load global prototype data
require("__VehicleWagon2__.script.makeGlobalMaps")
makeGlobalMaps()

if global.wagon_data then

  -- Version 3.1.14 did not update global.wagon_data[unit_number].wagon = <LuaEntity>
  --   when cloning entities (during spaceship launching)
  -- Solution is to look for the new entity based on the new unit_number that was stored correctly
  
  -- Find all the wagons and sort by unit_number
  local wagons = {}
  for _,surface in pairs(game.surfaces) do
    for _,wagon in pairs(surface.find_entities_filtered{name = global.loadedWagonList}) do
      wagons[wagon.unit_number] = wagon
    end
  end
  -- Store the entity reference for the correct entity based on unit_number
  for unit_number,data in pairs(global.wagon_data) do
    data.wagon = wagons[unit_number]
  end
  
end
