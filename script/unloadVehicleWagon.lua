--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: unloadVehicleWagon.lua
 * Description:  Function to execute the given Unloading Action.
 *    1. Validate saved data.
 *    2. Find a valid unloading position near the position given.
 *    3. Attempt to create the Vehicle entity.
 *    4. If successful, restore all the saved inventory, grid, and settings to the new Vehicle.
 *       Spill any items that don't fit.  Return reference to the new Vehicle.
 *    5. If unsuccessful, return nil.
 *    1. Replace Loaded Vehicle Wagon with Vehicle Wagon.
 --]]
 
 
-------------------------
-- Unload Wagon (either manually or from mining)
function unloadVehicleWagon(action)
  -- Get data from this unloading request
  local player_index = action.player_index
  local unload_position = action.unload_position
  local loaded_wagon = action.wagon
  local player = nil
  local replace_wagon = action.replace_wagon
  if replace_wagon == nil then
    replace_wagon = true
  end
  
  -- Make sure player exists
  if player_index then
    player = game.players[player_index]
  end
  
  -- Make sure wagon exists
  local loaded_unit_number = nil
  if not(loaded_wagon and loaded_wagon.valid) then
    if player then
      player.print({"vehicle-wagon2.wagon-invalid-error"})
    else
      game.print({"vehicle-wagon2.wagon-invalid-error"})
    end
    return
  end
  loaded_unit_number = loaded_wagon.unit_number
  
  -- Make sure the data for this wagon is still valid
  local wagon_data = global.wagon_data[loaded_unit_number]
  if not wagon_data then
    if player then
      player.print({"vehicle-wagon2.data-error", loaded_unit_number})
    else
      game.print({"vehicle-wagon2.data-error", loaded_unit_number})
    end
    return
  end
  
  -- Store wagon details for replacement
  local surface = loaded_wagon.surface
  local wagon_position = loaded_wagon.position
  
  -- Ask game to verify the requested unload position
  if unload_position then
    unload_position = surface.find_non_colliding_position(wagon_data.name, unload_position, 5, 0.5)
  end
  
  -- Ask game for a valid unloading position near the wagon
  if not unload_position then
    unload_position = surface.find_non_colliding_position(wagon_data.name, wagon_position, 5, 0.5)
  end
  
  -- If we still can't find a position, give up
  if not unload_position then
    return
  end
  
  -- Assign unloaded wagon to player force, else wagon force
  local force = loaded_wagon.force
  if player then
    force = player.force
  end
  
  -- Place vehicle with same direction as the loaded wagon sprite.
  local direction = math.floor(loaded_wagon.orientation*8 + 0.5)
  if global.loadedWagonFlip[loaded_wagon.name] then
    direction = math.fmod(direction + 4, 8)
  end
  
  -- Create the vehicle
  local vehicle = surface.create_entity{
                      name = wagon_data.name, 
                      position = unload_position, 
                      force = force,
                      direction = direction
                    }
  
  -- If vehicle not created, give up
  if not vehicle then
    return
  end
  
  -- Restore vehicle parameters from global data
  vehicle.health = wagon_data.health
  if wagon_data.color then 
    vehicle.color = wagon_data.color
  end
  
  -- Restore burner
  local r1 = saveRestoreLib.restoreBurner(vehicle.burner, wagon_data.burner)
  
  -- Restore inventory filters
  if wagon_data.filters then
    saveRestoreLib.restoreFilters(vehicle.get_inventory(defines.inventory.car_ammo), wagon_data.filters.ammo)
    saveRestoreLib.restoreFilters(vehicle.get_inventory(defines.inventory.car_trunk), wagon_data.filters.trunk)
  end
  
  -- Restore equipment grid
  local r2 = saveRestoreLib.restoreGrid(vehicle.grid, wagon_data.grid, player_index)
  r1 = saveRestoreLib.mergeStackLists(r1, r2)
  
  -- Restore ammo inventory if this car has guns
  if vehicle.selected_gun_index then
    ammoInventory = vehicle.get_inventory(defines.inventory.car_ammo)
    local r2 = saveRestoreLib.insertInventoryStacks(ammoInventory, wagon_data.items.ammo)
    r1 = saveRestoreLib.mergeStackLists(r1, r2)
  else
    r1 = saveRestoreLib.mergeStackLists(r1, wagon_data.items.ammo)
  end
  
  -- Restore the cargo inventory
  trunkInventory = vehicle.get_inventory(defines.inventory.car_trunk)
  local r2 = saveRestoreLib.insertInventoryStacks(trunkInventory, wagon_data.items.trunk)
  r1 = saveRestoreLib.mergeStackLists(r1, r2)
  
  -- Try to insert remainders into trunk, spill whatever doesn't fit
  if r1 then
    local r2 = saveRestoreLib.insertInventoryStacks(trunkInventory, r1)
    saveRestoreLib.spillStacks(r2, surface, unload_position)
  end
  
  -- Raise event for scripts
  script.raise_event(defines.events.script_raised_built, {entity = vehicle, player_index = player_index})
  
  -- Play sound associated with creating the vehicle
  surface.play_sound({path = "utility/build_medium", position = unload_position, volume_modifier = 0.7})
  
  -- Finished creating vehicle, clear loaded wagon data
  global.wagon_data[loaded_wagon.unit_number] = nil
  
  -- Play sounds associated with creating the vehicle
  surface.play_sound({path = "latch-off", position = unload_position, volume_modifier = 0.7})
  
  if replace_wagon then
    -- Replace loaded wagon with unloaded wagon
    local wagon = replaceCarriage(loaded_wagon, "vehicle-wagon", false, false)
    
    -- Check that unloaded wagon was created correctly
    if not(wagon and wagon.valid) then
      if player then
        player.print({"vehicle-wagon2.empty-wagon-error"})
      else
        game.print({"vehicle-wagon2.empty-wagon-error"})
      end
    end
  end
  
  return vehicle
end
