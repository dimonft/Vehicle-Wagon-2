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

--== ON_PLAYER_USED_CAPSULE ==--
-- Queues load/unload data when player clicks with the winch.
local function OnPlayerUsedCapsule(event)
  local capsule = event.item
  if capsule.name == "winch" then
    local index = event.player_index
    local player = game.players[index]
    local surface = player.surface
    local position = event.position
    local vehicle = surface.find_entities_filtered{type = "car", position = position}
    local wagon = surface.find_entities_filtered{name = "vehicle-wagon", position = position, radius = 1, force = player.force}
    local loaded_wagon = surface.find_entities_filtered{name = global.loadedWagonList, position = position, force = player.force}
    
    vehicle = vehicle[1]
    wagon = wagon[1]
    loaded_wagon = loaded_wagon[1]
    if loaded_wagon and loaded_wagon.valid then
    -- Log tutorial steps?
      global.tutorials[index] = global.tutorials[index] or {}
      global.tutorials[index][2] = global.tutorials[index][2] or 0
      
      local unit_number = loaded_wagon.unit_number
      
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
      elseif global.action_queue[unit_number] then
        -- This wagon already has a pending action
        player.print({"vehicle-wagon2.loaded-wagon-busy-error"})
      else
        -- Select vehicle as unloading source
        player.play_sound({path = "latch-on"})
        player.set_gui_arrow({type = "entity", entity = loaded_wagon})
        -- Tutorial message to select unloading 
        if global.tutorials[index][2] < 5 then
          global.tutorials[index][2] = global.tutorials[index][2] + 1
          player.print({"vehicle-wagon2.select-unload-vehicle-location"})
        end
        -- Record selection
        global.player_selection[index] = {wagon=loaded_wagon}
      end
      
    elseif vehicle and vehicle.valid then
      -- Clicked on a vehicle
      global.tutorials[index] = global.tutorials[index] or {}
      global.tutorials[index][1] = global.tutorials[index][1] or 0
      
      if get_driver_or_passenger(vehicle) then
        player.print({"vehicle-wagon2.vehicle-passenger-error"})
      elseif not global.vehicleMap[vehicle.name] then
        player.print({"vehicle-wagon2.unknown-vehicle-error"})
      else
        -- Store vehicle selection
        global.player_selection[index] = {vehicle=vehicle}
        player.set_gui_arrow({type = "entity", entity = vehicle})
        player.play_sound({path = "latch-on"})
        -- Tutorial message to select an empty wagon
        if global.tutorials[index][1] < 5 then
          global.tutorials[index][1] = global.tutorials[index][1] + 1
          player.print({"vehicle-wagon2.vehicle-selected"})
        end
      end
      
    elseif wagon and wagon.valid then
      -- Clicked on an empty wagon
      if wagon.train.speed ~= 0 then
        player.print({"vehicle-wagon2.train-in-motion-error"})  -- Can't load while train is moving
      elseif (global.player_selection[index] and 
              global.player_selection[index].vehicle) then
        -- Clicked on empty wagon after clicking on a vehicle
        local vehicle = global.player_selection[index].vehicle
        if not vehicle.valid then
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
        elseif Position.distance(Position.new(wagon.position), Position.new(vehicle.position)) > 10 then
          player.print({"vehicle-wagon2.too-far-away"})
        else
          local loaded_name = global.vehicleMap[vehicle.name]
          if not loaded_name then
            player.print({"vehicle-wagon2.unknown-vehicle-error"})
            clearSelection(index)
          else
            player.surface.play_sound({path = "winch-sound", position = player.position})
            local beam = wagon.surface.create_entity({name="laser-beam", position=wagon.position, source_position=vehicle.position, target_position=wagon.position, duration=120})
            global.action_queue[wagon.unit_number] = {player_index=index,
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
      
    elseif (global.player_selection[index] and 
            global.player_selection[index].wagon) then
      -- Clicked on the ground after clicking on a loaded wagon
      local wagon = global.player_selection[index].wagon
      local unload_position = player.surface.find_non_colliding_position(global.wagon_data[wagon.unit_number].name, position, 5, 1)
      if not unload_position then
        player.print({"vehicle-wagon2.vehicle-not-created-error", {"entity-name."..global.wagon_data[wagon.unit_number].name}})  -- Game could not find open position to unload
      elseif Position.distance(Position.new(wagon.position), Position.new(unload_position)) > 10 then
        player.print({"vehicle-wagon2.too-far-away"})  -- Player clicked too far away
      elseif global.action_queue[wagon.unit_number] then
        -- This wagon already has a pending action
        player.print({"vehicle-wagon2.loaded-wagon-busy-error"})
      else
        player.surface.play_sound({path = "winch-sound", position = player.position})
        local beam = wagon.surface.create_entity({name="laser-beam", position=wagon.position, source_position=wagon.position, target_position=unload_position, duration=120})
        global.action_queue[wagon.unit_number] = {player_index=index,
                                                  status="unload",
                                                  wagon=wagon,
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