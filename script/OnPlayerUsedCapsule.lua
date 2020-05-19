--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: OnPlayerUsedCapsule.lua
 * Description: Event handler for when a player uses a capsule.
 *  - When the player uses a Winch Capsule:
 *    1. If player clicked on a Vehicle, start the loading selection sequence.
 *    2. If player clicked on a Loaded Vehicle Wagon, start the unloading selection sequence.
 *    3. If player clicked on a Vehicle Wagon after clicking on a Vehicle, queue the Loading Action.
 *    4. If player clicked on none of the above after clicking on a Loaded Vehicle Wagon, queue the Unloading Action.
--]]

local function distance(a,b)
  return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end


--== ON_PLAYER_USED_CAPSULE ==--
-- Queues load/unload data when player clicks with the winch.
local function OnPlayerUsedCapsule(event)
  local capsule = event.item
  if capsule.name == "winch" then
    local index = event.player_index
    local player = game.players[index]
    local surface = player.surface
    local position = event.position
    local selected_entity = player.selected
    if selected_entity and not selected_entity.valid then
      selected_entity = nil
    end
    
    -- Don't check GCKI data if the mod was uninstalled or setting turned off
    local check_GCKI = remote.interfaces["GCKI"] and settings.global["vehicle-wagon-use-GCKI-permissions"].value
    
    
    ------------------------------------------------
    -- Loaded Wagon: Check if Valid to Unload
    if selected_entity and global.loadedWagonMap[selected_entity.name] then
      local loaded_wagon = selected_entity
      
      -- Clicked on a Loaded Wagon
      local unit_number = loaded_wagon.unit_number
      local vehicle_prototype = game.entity_prototypes[global.wagon_data[unit_number].name]
            
      
      if loaded_wagon.get_driver() then
        player.print({"vehicle-wagon2.wagon-passenger-error"})  -- Can't unload while passenger in wagon
        
      elseif loaded_wagon.train.speed ~= 0 then
        player.print({"vehicle-wagon2.train-in-motion-error"})  -- Can't unload while train is moving
        
      elseif not global.wagon_data[unit_number] then
        -- Loaded wagon data or vehicle entity is invalid
        -- Replace wagon with unloaded version and delete data
        game.print({"vehicle-wagon2.data-error", unit_number})  
        deleteWagon(unit_number)
        replaceCarriage(loaded_wagon, "vehicle-wagon", false, false)
        
      elseif not game.entity_prototypes[global.wagon_data[unit_number].name] then
        game.print({"vehicle-wagon2.vehicle-prototype-error", unit_number, global.wagon_data[unit_number].name})  
        -- Loaded wagon data or vehicle entity is invalid
        -- Replace wagon with unloaded version and delete data
        deleteWagon(unit_number)
        replaceCarriage(loaded_wagon, "vehicle-wagon", false, false)
        
      elseif check_GCKI and global.wagon_data[unit_number].GCKI_data and global.wagon_data[unit_number].GCKI_data.locker and 
               global.wagon_data[unit_number].GCKI_data.locker ~= player.index then
        -- Error: vehicle was locked by someone else before it was loaded 
        -- Does not matter if that player exists or claimed a different vehicle, only that player can unload this one
        local locker = game.players[global.wagon_data[unit_number].GCKI_data.locker]
        if locker and locker.valid then
          -- Player exists, display their name
          player.print({"vehicle-wagon2.unload-locked-vehicle-error", vehicle_prototype.localised_name, locker.name})
        else
          -- Player no longer exists.  Should permission still apply?
          player.print({"vehicle-wagon2.unload-locked-vehicle-error", vehicle_prototype.localised_name, "Player #"..tostring(global.wagon_data[unit_number].GCKI_data.locker)})
        end
        
      elseif check_GCKI and global.wagon_data[unit_number].GCKI_data and global.wagon_data[unit_number].GCKI_data.owner and
               global.wagon_data[unit_number].GCKI_data.owner ~= player.index and 
               remote.call("GCKI", "owned_by_player", global.wagon_data[unit_number].GCKI_data.owner) == nil then
        -- Error: Unloading player is not previous owner, and previous owner has NOT claimed another vehicle in the meantime.
        local owner = game.players[global.wagon_data[unit_number].GCKI_data.owner]
        if owner and owner.valid then
          -- Player exists, display their name
          player.print({"vehicle-wagon2.unload-owned-vehicle-error", vehicle_prototype.localised_name, owner.name})
        else
          -- Player no longer exists.  Should permission still apply?
          player.print({"vehicle-wagon2.unload-owned-vehicle-error", vehicle_prototype.localised_name, "Player #"..tostring(global.wagon_data[unit_number].GCKI_data.owner)})
        end
        
      elseif global.action_queue[unit_number] then
        -- This wagon already has a pending action
        player.print({"vehicle-wagon2.loaded-wagon-busy-error"})
        
      else
        -- Select vehicle as unloading source
        player.play_sound{path = "latch-on"}
        -- Always show tutorial message, to find out what kind of vehicle is stored here
        player.print{"vehicle-wagon2.select-unload-vehicle-location", vehicle_prototype.localised_name}
        -- Record selection and create radius circle
        global.player_selection[index] = {wagon=loaded_wagon, visuals= renderVisuals(player,loaded_wagon)}
      end
    
    
    --------------------------------
    -- Vehicle: Check if valid to load on wagon
    elseif selected_entity and selected_entity.type == "car" then
      local vehicle = selected_entity
      
      -- Clicked on a vehicle
      global.tutorials[index] = global.tutorials[index] or {}
      global.tutorials[index][1] = global.tutorials[index][1] or 0
      
      -- Compatibility with GCKI:
      local owner = nil
      local locker = nil
      if check_GCKI then
        -- Either or both of these may be set to a player
        owner = remote.call("GCKI", "vehicle_owned_by", vehicle)
        locker = remote.call("GCKI", "vehicle_locked_by", vehicle)
      end
      
      if get_driver_or_passenger(vehicle) then
        player.print({"vehicle-wagon2.vehicle-passenger-error"})
      
      elseif vehicle.speed ~= 0 then
        player.print({"vehicle-wagon2.vehicle-in-motion-error"})
      
      elseif not global.vehicleMap[vehicle.name] then
        player.print({"vehicle-wagon2.unknown-vehicle-error", vehicle.localised_name})
      
      elseif locker and locker ~= player then
        -- Can't load someone else's locked vehicle
        player.print({"vehicle-wagon2.load-locked-vehicle-error", vehicle.localised_name, locker.name})
      
      elseif owner and owner ~= player then
        -- Can't load someone else's vehicle
        player.print({"vehicle-wagon2.load-owned-vehicle-error", vehicle.localised_name, owner.name})
      
      else
        -- Store vehicle selection
        player.play_sound({path = "latch-on"})
        global.player_selection[index] = {vehicle=vehicle, visuals= renderVisuals(player,vehicle)}
        -- Tutorial message to select an empty wagon
        if global.tutorials[index][1] < 5 then
          global.tutorials[index][1] = global.tutorials[index][1] + 1
          player.print({"vehicle-wagon2.vehicle-selected", vehicle.localised_name})
        end
      end
    
    --------------------------------------
    -- Empty Wagon:  Check if valid to load with selected vehicle
    elseif selected_entity and selected_entity.name == "vehicle-wagon" then
      local wagon = selected_entity
      
      -- Clicked on an empty wagon
      if wagon.train.speed ~= 0 then
        player.print({"vehicle-wagon2.train-in-motion-error"})  -- Can't load while train is moving
      elseif (global.player_selection[index] and 
              global.player_selection[index].vehicle) then
        -- Clicked on empty wagon after clicking on a vehicle
        local vehicle = global.player_selection[index].vehicle
        if not vehicle or not vehicle.valid then
          -- Selected vehicle no longer exists
          clearSelection(index)
          player.print({"vehicle-wagon2.vehicle-invalid-error"})
        elseif get_driver_or_passenger(vehicle) then
          -- Selected vehicle has an occupant
          clearSelection(index)
          player.print({"vehicle-wagon2.vehicle-passenger-error"})
        elseif global.action_queue[wagon.unit_number] then
          -- This wagon already has a pending action
          player.print({"vehicle-wagon2.empty-wagon-busy-error"})
        elseif distance(wagon.position, vehicle.position) > LOADING_DISTANCE then
          player.print({"vehicle-wagon2.wagon-too-far-away-error", vehicle.localised_name})
        else
          local loaded_name = global.vehicleMap[vehicle.name]
          if not loaded_name then
            player.print({"vehicle-wagon2.unknown-vehicle-error", vehicle.localised_name})
            clearSelection(index)
          else
            player.surface.play_sound({path = "winch-sound", position = player.position})
            local beam = wagon.surface.create_entity({name="loading-ramp-beam", position=wagon.position, source_position=vehicle.position, target_position=wagon.position, duration=120})
            global.action_queue[wagon.unit_number] = {player_index = index,
                                                status = "load",
                                                wagon = wagon,
                                                vehicle = vehicle,
                                                name = loaded_name,
                                                tick = game.tick + 120,
                                                beam = beam}
            clearSelection(index)
            script.on_event(defines.events.on_tick, process_tick)
          end
        end
      else
        -- Clicked on an empty wagon without first clicking on a vehicle
        player.print({"vehicle-wagon2.no-vehicle-selected"})
      end

    ---------------------------------------------
    -- Someplace Else: Check if valid to unlod selected loaded wagon
    elseif (global.player_selection[index] and global.player_selection[index].wagon) then
      -- Clicked on the ground or unrelated entity after clicking on a loaded wagon
      local wagon = global.player_selection[index].wagon
      local unload_position = player.surface.find_non_colliding_position(global.wagon_data[wagon.unit_number].name, position, 5, 0.5)
      if not unload_position then
        player.print({"vehicle-wagon2.vehicle-not-created-error", {"entity-name."..global.wagon_data[wagon.unit_number].name}})  -- Game could not find open position to unload
      elseif distance(wagon.position, unload_position) > LOADING_DISTANCE then
        player.print({"vehicle-wagon2.location-too-far-away-error", wagon.localised_name})  -- Player clicked too far away
      elseif global.action_queue[wagon.unit_number] then
        -- This wagon already has a pending action
        player.print({"vehicle-wagon2.loaded-wagon-busy-error"})
      else
        player.surface.play_sound({path = "winch-sound", position = player.position})
        local beam = wagon.surface.create_entity({name="loading-ramp-beam", position=wagon.position, source_position=wagon.position, target_position=unload_position, duration=120})
        global.action_queue[wagon.unit_number] = {player_index = index,
                                                  status = "unload",
                                                  wagon = wagon,
                                                  unload_position = unload_position,
                                                  tick = game.tick + 120,
                                                  beam = beam}
        clearSelection(index)
        script.on_event(defines.events.on_tick, process_tick)
      end
    end
  end
end

return OnPlayerUsedCapsule
