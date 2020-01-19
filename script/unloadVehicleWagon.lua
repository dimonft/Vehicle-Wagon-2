
-------------------------
-- Unload Wagon (either manually or from mining)
function unloadVehicleWagon(action)
  -- Get data from this unloading request
  local player_index = action.player_index
  local unload_position = action.unload_position
  local loaded_wagon = action.wagon
  local player = nil
  
  -- Make sure player exists
  if player_index then
    player = game.players[player_index]
  end
  
  -- Make sure wagon exists
  local loaded_unit_number = nil
  if not(loaded_wagon and loaded_wagon.valid) then
    if player then
      player.print({"vw3-wagon-error"})
    else
      game.print({"vw3-wagon-error"})
    end
    return
  end
  loaded_unit_number = loaded_wagon.unit_number
  
  -- Make sure the data for this wagon is still valid
  local wagon_data = global.wagon_data[loaded_unit_number]
  if not wagon_data then
    if player then
      player.print({"vw3-data-error"})
    else
      game.print({"vw3-data-error"})
    end
    return
  end
  
  -- Store wagon details for replacement
  local surface = loaded_wagon.surface
  local wagon_position = loaded_wagon.position
  
  -- Ask game for a valid unloading position near the wagon
  if not unload_position then
    unload_position = surface.find_non_colliding_position(wagon_data.name, wagon_position, 5, 1)
  end
  
  -- If we still can't find a position, give up
  if not unload_position then
    if player then
      player.print({"vw3-position-error"})
    else
      game.print({"vw3-position-error"})
    end
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
    if player then
      player.print({"vw3-vehicle-error"})
    else
      game.print({"vw3-vehicle-error"})
    end
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
  if vehicle.grid and vehicle.grid.valid then
    local r2 = saveRestoreLib.restoreGrid(vehicle.grid, wagon_data.items.grid, player_index)
    r1 = saveRestoreLib.mergeStackLists(r1, r2)
  end
  
  -- Restore ammo inventory
  ammoInventory = vehicle.get_inventory(defines.inventory.car_ammo)
  if wagon_data.items.ammo then
    local r2 = saveRestoreLib.restoreInventoryStacks(ammoInventory, wagon_data.items.ammo)
    r1 = saveRestoreLib.mergeStackLists(r1, r2)
  end
  
  -- Restore the cargo inventory
  trunkInventory = vehicle.get_inventory(defines.inventory.car_trunk)
  if wagon_data.items.trunk then
    local r2 = saveRestoreLib.restoreInventoryStacks(trunkInventory, wagon_data.items.trunk)
    r1 = saveRestoreLib.mergeStackLists(r1, r2)
  end
  
  -- Try to insert remainders into trunk, spill whatever doesn't fit
  if r1 then
    local r2 = saveRestoreLib.restoreInventoryStacks(trunkInventory, r1)
    saveRestoreLib.spillStacks(r2)
  end
  
  -- Raise event for scripts
  script.raise_event(defines.events.script_raised_built, {entity = vehicle, player_index = player_index})
  
  -- Finished creating vehicle, clear loaded wagon data
  global.wagon_data[loaded_wagon.unit_number] = nil
  
  -- Play sounds associated with creating the vehicle
  surface.play_sound({path = "latch-off", position = unload_position, volume_modifier = 0.7})
  
  -- Replace loaded wagon with unloaded wagon
  local wagon = replaceCarriage(loaded_wagon, "vehicle-wagon", false, false)
  
  -- Check that unloaded wagon was created correctly
  if wagon and wagon.valid then
    -- Play sound associated with creating the unloaded wagon
    surface.play_sound({path = "utility/build_medium", position = unload_position, volume_modifier = 0.7})
  else
    if player then
      player.print({"generic-error"})
    else
      game.print({"generic-error"})
    end
  end
  
  return vehicle
end
