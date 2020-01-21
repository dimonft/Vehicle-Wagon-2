
-------------------------
-- Load Wagon
function loadVehicleWagon(action)
  local player_index = action.player_index
  
  local wagon = action.wagon
  local vehicle = action.vehicle
  local surface = wagon.surface
  
  -- Save parameters of empty wagon
  local position = wagon.position
  
  -- Find direction for wagon (either as-is or rotate 180)
  local flip = (math.abs(vehicle.orientation - wagon.orientation) > 0.25)
  if global.loadedWagonFlip[action.name] then
    flip = not flip
  end
  
  -- Replace the unloaded wagon with loaded one
  local loaded_wagon = replaceCarriage(wagon, action.name, false, false, flip)
  
  -- Check that loaded wagon was created correctly
  if not loaded_wagon or not loaded_wagon.valid then
    -- Unable to create the loaded wagon, don't delete vehicle
    -- replaceCarriage will drop the wagon on the ground for player to pick up
    player.print({"generic-error"})
    return
  end
  
  -- Play sound associated with creating loaded wagon
  surface.play_sound({path = "utility/build_medium", position = position, volume_modifier = 0.7})
  
  -- Store data on vehicle in global table
  local unit_number = loaded_wagon.unit_number
  local saveData = {}
  
  
  -- Store vehicle entity name (either normal or AAI)
  if remote.interfaces["aai-programmable-vehicles"] then
    -- Make sure we need the 'expensive' gsub call before bothering:
    -- AAI vehicles end up with a composite; ex. for a vehicle-miner, the actual object that gets
    -- loaded is a 'vehicle-miner-_-solid', which when unloaded doesn't work unless we record
    -- into the base object here.
    -- NOTE: Unfortunately unloaded vehicles still end up with a new unit ID, as AAI doesn't expose
    -- an interface to set/restore the vehicles unit ID.
    saveData.name = string.gsub(vehicle.name, "%-_%-.+","")
  else
    saveData.name = vehicle.name
  end
  
  -- Store vehicle parameters
  saveData.health = vehicle.health
  saveData.color = vehicle.color
  
  -- Store inventory contents
  saveData.items = {ammo = saveRestoreLib.saveInventoryStacks(vehicle.get_inventory(defines.inventory.car_ammo)),
                    trunk = saveRestoreLib.saveInventoryStacks(vehicle.get_inventory(defines.inventory.car_trunk)),
                    grid = saveRestoreLib.saveGrid(vehicle.grid) }
  
  -- Store inventory filters
  saveData.filters = {ammo = saveRestoreLib.saveFilters(vehicle.get_inventory(defines.inventory.car_ammo)),
                      trunk = saveRestoreLib.saveFilters(vehicle.get_inventory(defines.inventory.car_trunk)) }
  
  -- Store vehicle burner
  saveData.burner = saveRestoreLib.saveBurner(vehicle.burner)
  
  global.wagon_data[unit_number] = saveData
  
  -- Destroy vehicle
  vehicle.destroy()
  
end
