String = require('__stdlib__/stdlib/utils/string')
Position = require('__stdlib__/stdlib/area/position')


replaceCarriage = require("__Robot256Lib__/script/carriage_replacement").replaceCarriage
blueprintLib = require("__Robot256Lib__/script/blueprint_replacement")
saveRestoreLib = require("__Robot256Lib__/script/save_restore")

require("script.loadVehicleWagon")
require("script.unloadVehicleWagon")


-- Go through all the available prototypes and assign them to a valid loaded wagon or "nope"
function InitializeTypeMapping()
  
  -- Some sprites show up backwards from how they ought to, so we flip the wagons relative to the vehicles.
  global.loadedWagonFlip = {}
  
  global.vehicleMap = {}
  for k,_ in pairs(game.get_filtered_entity_prototypes({{filter="type", type="car"}})) do
    
    if String.contains(k,"nixie") then
      global.vehicleMap[k] = nil
    elseif String.contains(k,"heli") or String.contains(k,"rotor") then
      global.vehicleMap[k] = nil
    elseif k == "uplink-station" then
      global.vehicleMap[k] = nil
    elseif k == "vwtransportercargo" then
      global.vehicleMap[k] = nil
    elseif String.contains(k,"airborne") then
      global.vehicleMap[k] = nil
    elseif String.contains(k,"cargo%-plane") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-cargoplane"
      global.loadedWagonFlip["loaded-vehicle-wagon-cargoplane"] = true
    elseif k == "jet" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-jet"
      global.loadedWagonFlip["loaded-vehicle-wagon-jet"] = true
    elseif k == "gunship" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-gunship"
      global.loadedWagonFlip["loaded-vehicle-wagon-gunship"] = true
    elseif k == "dumper-truck" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-truck"
    elseif String.contains(k,"ht%-RA") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank"
    elseif String.contains(k,"tank") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank"
    elseif String.contains(k,"car") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-car"
    else
      global.vehicleMap[k] = "loaded-vehicle-wagon-tarp"
    end

  end
  
  global.loadedWagonMap = {}
  global.loadedWagonList = {}
  for _,v in pairs(global.vehicleMap) do
    if not global.loadedWagonMap[v] then
      global.loadedWagonMap[v] = "vehicle-wagon"
      table.insert(global.loadedWagonList, v)
    end
  end
  
end

function MigrateWagonData(id)
  local migrated = false
  if global.wagon_data[id].items then
    -- First migrate grid
    if global.wagon_data[id].items.grid then
      for _,v in pairs(global.wagon_data[id].items.grid) do
        if v.name then
          v.item = {name=v.name, position=v.position}
          migrated = true
        end
      end
    end
    -- Then migrate items
    -- TODO: Have Migration code figure out what inventories to use
    for k,v in pairs(global.wagon_data[id].items) do
      -- anything besides fuel, ammo, trunk, and grid are names of items
      if type(v) == "number" then
        global.wagon_data[id].items.general = global.wagon_data[id].items.general or {}
        global.wagon_data[id].items.general[k] = v
        migrated = true
      end
    end
    -- Then migrate filters
    if global.wagon_data[id].filters then
      if global.wagon_data[id].filters[2] then
        global.wagon_data[id].filters.ammo = global.wagon_data[id].filters[2]
        migrated = true
      end
      if global.wagon_data[id].filters[3] then
        global.wagon_data[id].filters.trunk = global.wagon_data[id].filters[3]
        migrated = true
      end
    end
  end
  return migrated
end


function ScrubDataTables()
-- Scrub tables to remove references to non-existent loaded wagons and non-existent players
  local all_wagons = {}
  for _,surface in pairs(game.surfaces) do
    local new_wagons = surface.find_entities_filtered{name=global.loadedWagonList}
    for _,nw in pairs(new_wagons) do
      game.print("Found loaded wagon "..nw.unit_number..": "..nw.name)
      table.insert(all_wagons, nw)
    end
  end
  for id,data in pairs(global.wagon_data) do
    local found = false
    for _,wagon in pairs(all_wagons) do
      if wagon.unit_number == id then
        found = true
        break
      end
    end
    for pid,_ in pairs(game.players) do
      if pid == id then
        found = true
        break
      end
    end
    if found == false then
      -- Purge data
      global.wagon_data[id] = nil
      game.print("Purged loaded wagon data for unit or player "..id)
    else
      -- Wagon valid, Migrate data if needed
      if MigrateWagonData(id) then
        game.print("Migrated loaded wagon data for unit or player "..id)
      end
    end
  end
  
  for id,data in pairs(global.vehicle_data) do
    local found = false
    for pid,_ in pairs(game.players) do
      if pid == id then
        found = true
        break
      end
    end
    if found == false then
      -- Purge data
      global.vehicle_data[id] = nil
      game.print("Purged vehicle data for player "..id)
    end
  end
end


--== ON_INIT EVENT ==--
-- Initialize global data tables
function On_Init()

  global.vehicle_data = nil

  global.wagon_data = global.wagon_data or {}
  global.tutorials = global.tutorials or {}
  for i, player in pairs(game.players) do
    global.tutorials[player.index] = {}
  end
  
  global.action_queue = global.action_queue or {}
  global.player_selection = global.player_selection or {}
  
  InitializeTypeMapping()
  
  --ScrubDataTables()
  
end
script.on_init(function() On_Init() end)
script.on_configuration_changed(function() On_Init() end)


--== ON_LOAD EVENT ==--
-- Enable on_tick event according to global variable state
function On_Load()
  if global.action_queue and table_size(global.action_queue) > 0 then
    script.on_event(defines.events.on_tick, process_tick)
  end
end
script.on_load(function() On_Load() end)


-- Deal with the new 0.16 driver/passenger bit
function get_driver_or_passenger(entity)
  -- Check if we have a driver:
  local driver = entity.get_driver()
  if driver then return driver end

  -- Otherwise check if we have a passenger, which will error if entity is not a car:
  local status, resp = pcall(entity.get_passenger)
  if not status then return nil end
  return resp
end



--== ON_TICK EVENT ==--
-- Executes queued load/unload actions after the correct time has elapsed.
function process_tick(event)
  local current_tick = event.tick
  
  -- Loop through players to see if any of them requested load/unload
  --   (would be better to have a separate global queue)
  for i, action in pairs(global.action_queue) do
    if action.player_index and game.players[action.player_index] and action.status then
      local player = game.players[action.player_index]
      ------- LOADING OPERATION --------
      if action.status == "load" and action.tick == current_tick then
        -- Check that the wagon and vehicle indicated by the player are a valid target for loading
        local wagon = action.wagon
        local vehicle = action.vehicle
        if not vehicle or not wagon or not vehicle.valid or not wagon.valid then
          player.print({"generic-error"})
        elseif wagon.get_driver() or get_driver_or_passenger(vehicle) then
          player.print({"passenger-error"})
        elseif wagon.train.speed ~= 0 then
          player.print({"train-in-motion-error"})
        else
          -- Execute the loading for this player if possible.
          loadVehicleWagon(action)
        end
        -- Clear from queue after completion
        global.action_queue[i] = nil
        
      ------- UNLOADING OPERATION --------
      elseif action.status == "unload" and action.tick == current_tick then
        -- Check that the wagon indicated by the player is a valid target for unloading
        local loaded_wagon = action.wagon
        if not loaded_wagon or not loaded_wagon.valid then
          player.print({"generic-error"})
        elseif loaded_wagon.get_driver() then
          player.print({"passenger-error"})
        elseif loaded_wagon.train.speed ~= 0 then
          player.print({"train-in-motion-error"})
        else
          -- Execute unloading if possible.  Vehicle object returned if successful
          unloadVehicleWagon(action)
        end
        -- Clear from queue after completion
        global.action_queue[i] = nil
      end
    else
      -- Clear from queue if entry is invalid
      global.action_queue[i] = nil
    end
  end
  
  -- Unsubscribe from on_tick if no actions remains in queue
  if table_size(global.action_queue) == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end


function clearSelection(player_index)
  global.player_selection[player_index] = nil
  if game.players[player_index] then
    game.players[player_index].clear_gui_arrow()
  end
end

function clearWagon(unit_number)
  global.wagon_data[unit_number] = nil
  global.action_queue[unit_number] = nil
  for player_index,selection in pairs(global.player_selection) do
    if selection.wagon then
      if not selection.wagon.valid or selection.wagon.unit_number == unit_number then
        clearSelection(player_index)
      end
    end
  end
end

--== ON_PLAYER_USED_CAPSULE ==--
-- Queues load/unload data when player clicks with the winch.
function OnPlayerUsedCapsule(event)
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
        player.print({"passenger-error"})  -- Can't unload while passenger in wagon
      elseif loaded_wagon.train.speed ~= 0 then
        player.print({"train-in-motion-error"})  -- Can't unload while train is moving
      elseif not global.wagon_data[unit_number] then
        -- Loaded wagon data or vehicle entity is invalid
        -- Replace wagon with unloaded version and delete data
        game.print("ERROR: Missing global data for unit "..unit_number)  
        clearWagon(unit_number)
        replaceCarriage(loaded_wagon, "vehicle-wagon", false, false)
      elseif not game.entity_prototypes[global.wagon_data[unit_number].name] then
        game.print("ERROR: Missing prototype \""..global.wagon_data[unit_number].name.."\" for unit "..unit_number)  
        -- Loaded wagon data or vehicle entity is invalid
        -- Replace wagon with unloaded version and delete data
        clearWagon(unit_number)
        replaceCarriage(loaded_wagon, "vehicle-wagon", false, false)
      else
        -- Select vehicle as unloading source
        player.play_sound({path = "latch-on"})
        player.set_gui_arrow({type = "entity", entity = loaded_wagon})
        -- Tutorial message to select unloading 
        if global.tutorials[index][2] < 5 then
          global.tutorials[index][2] = global.tutorials[index][2] + 1
          player.print({"select-unload-vehicle-location"})
        end
        -- Record selection
        global.player_selection[index] = {wagon=loaded_wagon}
      end
      
    elseif vehicle and vehicle.valid then
      -- Clicked on a vehicle
      global.tutorials[index] = global.tutorials[index] or {}
      global.tutorials[index][1] = global.tutorials[index][1] or 0
      
      if get_driver_or_passenger(vehicle) then
        player.print({"passenger-error"})
      else
        -- Store vehicle selection
        global.player_selection[index] = {vehicle=vehicle}
        player.set_gui_arrow({type = "entity", entity = vehicle})
        player.play_sound({path = "latch-on"})
        -- Tutorial message to select an empty wagon
        if global.tutorials[index][1] < 5 then
          global.tutorials[index][1] = global.tutorials[index][1] + 1
          player.print({"vehicle-selected"})
        end
      end
      
    elseif wagon and wagon.valid then
      -- Clicked on an empty wagon
      if wagon.train.speed ~= 0 then
        player.print({"train-in-motion-error"})  -- Can't load while train is moving
      elseif (global.player_selection[index] and 
              global.player_selection[index].vehicle) then
        -- Clicked on empty wagon after clicking on a vehicle
        local vehicle = global.player_selection[index].vehicle
        if not vehicle.valid then
          -- Selected vehicle no longer exists
          clearSelection(index)
          player.print({"generic-error"})
        elseif get_driver_or_passenger(vehicle) then
          -- Selected vehicle has an occupant
          clearSelection(index)
          player.print({"passenger-error"})
        elseif Position.distance(Position.new(wagon.position), Position.new(vehicle.position)) > 9 then
          player.print({"too-far-away"})
        else
          local loaded_name = global.vehicleMap[vehicle.name]
          if not loaded_name then
            player.print({"unknown-vehicle-error"})
          else
            player.surface.play_sound({path = "winch-sound", position = player.position})
            global.action_queue[wagon.unit_number] = {player_index=index,
                                                status = "load",
                                                wagon = wagon,
                                                vehicle = vehicle,
                                                name = loaded_name,
                                                tick = game.tick + 120}
            clearSelection(index)
            script.on_event(defines.events.on_tick, process_tick)
          end
        end
      else
        -- Clicked on an empty wagon without first clicking on a vehicle
        player.print({"no-vehicle-selected"})
      end
      
    elseif (global.player_selection[index] and 
            global.player_selection[index].wagon) then
      -- Clicked on the ground after clicking on a loaded wagon
      local wagon = global.player_selection[index].wagon
      local unload_position = player.surface.find_non_colliding_position(global.wagon_data[wagon.unit_number].name, position, 5, 1)
      if not unload_position then
        player.print({"position-error"})  -- Game could not find open position to unload
      elseif Position.distance(Position.new(wagon.position), Position.new(unload_position)) > 9 then
        player.print({"too-far-away"})  -- Player clicked too far away
      else
        player.surface.play_sound({path = "winch-sound", position = player.position})
        global.action_queue[wagon.unit_number] = {player_index=index,
                                                  status="unload",
                                                  wagon=wagon,
                                                  unload_position = unload_position,
                                                  tick = game.tick + 120}
        clearSelection(index)
        script.on_event(defines.events.on_tick, process_tick)
      end
    end
    player.insert{name = "winch", count = 1}
  end
end
script.on_event(defines.events.on_player_used_capsule, OnPlayerUsedCapsule)


--== ON_PLAYER_CURSOR_STACK_CHANGED EVENT ==--
-- When player stops holding winch, clear selections
function OnPlayerCursorStackChanged(event)
  local index = event.player_index
  local player = game.players[index]
  local stack = player.cursor_stack
  if not (stack and stack.valid and stack.valid_for_read and stack.name == "winch") then
    if global.player_selection[index] then
      player.play_sound({path = "latch-off"})
      clearSelection(index)
    end
  end
end
script.on_event(defines.events.on_player_cursor_stack_changed, OnPlayerCursorStackChanged)


--== ON_PRE_PLAYER_MINED_ITEM ==--
-- When player mines a loaded wagon, try to unload the vehicle first!
function OnPrePlayerMinedItem(event)
  local entity = event.entity
  if global.loadedWagonMap[entity.name] then
    -- Player is mining a loaded wagon
    -- Attempt to unload the wagon nearby
    local unit_number = entity.unit_number
    local player_index = event.player_index
    
    local player = game.players[player_index]
    local surface = player.surface
    local wagon_data = global.wagon_data[unit_number]
    if not wagon_data then
      -- No data on this loaded wagon
      player.print({"generic-error"})
    else
      -- We can try to unload this wagon
      local vehicle = unloadVehicleWagon({player_index=player_index,
                                          status="unload",
                                          wagon=entity})
      
      if not vehicle then
        -- Vehicle could not be unloaded
        -- Insert vehicle and contents into player's inventory
        player.print({"position-error"})
        local text_position = player.position
        text_position.y = text_position.y + 1
        player.insert{name = wagon_data.name, count = 1}
        surface.create_entity({name = "flying-text", position = text_position, text = {"item-inserted", 1, game.entity_prototypes[wagon_data.name].localised_name}})
        playerPosition = player.position
        playerInventory = player.get_main_inventory()
        
        -- Give player the equipment contents
        if wagon_data.items.grid then
          local equip_stacks, fuel_stacks = saveRestoreLib.saveGridStacks(wagon_data.items.grid)
          for _,stack in pairs(equip_stacks) do
            local remainder = saveRestoreLib.insertStack(playerInventory, stack)
            if remainder then
              saveRestoreLib.spillStack(remainder, surface, playerPosition)
            end
          end
          for _,stack in pairs(fuel_stacks) do
            local remainder = saveRestoreLib.insertStack(playerInventory, stack)
            if remainder then
              saveRestoreLib.spillStack(remainder, surface, playerPosition)
            end
          end
        end
        
        -- Give player the ammo inventory
        if wagon_data.items.ammo then
          for _,stack in pairs(wagon_data.items.ammo) do
            local remainder = saveRestoreLib.insertStack(playerInventory, stack)
            if remainder then
              saveRestoreLib.spillStack(remainder, surface, playerPosition)
            end
          end
        end
        
        -- Give player the cargo inventory
        if wagon_data.items.trunk then
          for _,stack in pairs(wagon_data.items.trunk) do
            local remainder = saveRestoreLib.insertStack(playerInventory, stack)
            if remainder then
              saveRestoreLib.spillStack(remainder, surface, playerPosition)
            end
          end
        end
    
      end
      
    end
    
    -- Delete the data associated with the mined wagon
    -- Delete any requests for unloading this particular wagon
    clearWagon(unit_number)
    
  elseif entity.name == "vehicle-wagon" then
    -- Delete any requests for loading this particular wagon
    clearWagon(entity.unit_number)
  end
end
script.on_event(defines.events.on_pre_player_mined_item, OnPrePlayerMinedItem)


--== ON_ROBOT_PRE_MINED ==--
-- When robot tries to mine a loaded wagon, try to unload the vehicle first!
-- If vehicle cannot be unloaded, send its contents away in the robot piece by piece.
function OnRobotPreMined(event)
  local entity = event.entity
  if global.loadedWagonMap[entity.name] then
      
    -- Player or robot is mining a loaded wagon
    -- Attempt to unload the wagon nearby
    local unit_number = entity.unit_number
    local robot = event.robot
  
    local wagon_data = global.wagon_data[unit_number]
    if not wagon_data then
      -- No data on this loaded wagon
      game.print({"generic-error"})
    else
      -- We can try to unload this wagon
      local vehicle = unloadVehicleWagon({status="unload",
                                          wagon=entity})
      
      if not vehicle then
        -- Vehicle could not be unloaded
        -- First check for inventory contents
        local robotInventory = event.robot.get_inventory(defines.inventory.robot_cargo)
        local robotSize = 1 + event.robot.force.worker_robots_storage_bonus
        if wagon_data.grid then
          wagon_data.equip_stacks, wagon_data.fuel_stacks = saveRestoreLib.saveGridStacks(wagon_data.grid)
        end
        if robotInventory.is_empty() and wagon_data.items.trunk then
          for index,stack in pairs(wagon_data.items.trunk) do
            wagon_data.items.trunk[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then break end
          end
        end
        if robotInventory.is_empty() and wagon_data.items.ammo then
          for index,stack in pairs(wagon_data.items.ammo) do
            wagon_data.items.ammo[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then break end
          end
        end
        if robotInventory.is_empty() and wagon_data.burner.inventory then
          for index,stack in pairs(wagon_data.burner.inventory) do
            wagon_data.burner.inventory[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then break end
          end
        end
        if robotInventory.is_empty() and wagon_data.items.fuel_stacks then
          for index,stack in pairs(wagon_data.items.fuel_stacks) do
            local count = stack.count
            wagon_data.items.fuel_stacks[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then
              if stack then
                count = count - stack.count
              end
              saveRestoreLib.removeFromGrid(wagon_data.items.grid, {name=stack.name, count=count})
              break
            end
          end
        end
        if robotInventory.is_empty() and wagon_data.items.equip_stacks then
          for index,stack in pairs(wagon_data.items.equip_stacks) do
            local count = stack.count
            wagon_data.items.equip_stacks[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then
              if stack then
                count = count - stack.count
              end
              saveRestoreLib.removeFromGrid(wagon_data.items.grid, {name=stack.name, count=count})
              break
            end
          end
        end
        
        if robotInventory.is_empty() then
          if saveRestoreLib.insertStack(robotInventory, {name=wagon_data.name,count=1}, robotSize) == nil then
            game.print("Gave robot "..wagon_data.name..":1")
          else
            game.print("Unknown vehicle entity "..wagon_data.name)
          end
          replaceCarriage(entity, "vehicle-wagon", false, false)
          -- Delete wagon data and any associated requests
          clearWagon(unit_number)
        end
      end
      
    end
    
  elseif entity.name == "vehicle-wagon" then
    -- Delete any requests for loading this particular wagon
    clearWagon(entity.unit_number)
  end
end
script.on_event(defines.events.on_robot_pre_mined, OnRobotPreMined)




--== ON_BUILT_ENTITY ==--
--== SCRIPT_RAISED_BUILT ==--
-- When a loaded-wagon ghost is created, replace it with unloaded wagon ghost
function OnBuiltEntity(event)
  local entity = event.created_entity or event.entity
  if entity.name == "entity-ghost" then
    if global.loadedWagonMap[entity.ghost_name] then
      local newGhost = {
          name = "entity-ghost",
          inner_name = global.loadedWagonMap[entity.ghost_name],
          position = entity.position,
          orientation = entity.orientation,
          force = entity.force,
          create_build_effect_smoke = false,
          raise_built = false,
          snap_to_train_stop = false}
      
      entity.destroy()
      surface.create_entity(newGhost)
    end
  end
end
script.on_event({defines.events.on_built_entity, defines.events.script_raised_built}, OnBuiltEntity)


--== ON_ENTITY_DIED ==--
--== SCRIPT_RAISED_DESTROY ==--
-- When a loaded wagon dies or is destroyed by a different mod, delete its vehicle data
function OnEntityDied(event)
  local entity = event.entity
  if global.loadedWagonMap[entity.name] then
    -- Loaded wagon died, its vehicle is unrecoverable
    -- Clear data for this wagon
    global.wagon_data[entity.unit_number] = nil
  end
end
script.on_event({defines.events.on_entity_died, defines.events.script_raised_destroy}, OnEntityDied)


--== ON_PLAYER_DRIVING_CHANGED_STATE EVENT ==--
-- Eject player from unloaded wagon
-- Can't ride on an empty flatcar, but you can in a loaded one
function OnPlayerDrivingChangedState(event)
  local player = game.players[event.player_index]
  if player.vehicle and player.vehicle.name == "vehicle-wagon" then
    player.driving = false
  end
end
script.on_event(defines.events.on_player_driving_changed_state, OnPlayerDrivingChangedState)


------------------------- CURSOR AND BLUEPRINT HANDLING FOR 0.17.x ---------------------------------------

--== ON_PLAYER_PIPETTE ==--
-- Fires when player presses 'Q'.  We need to sneakily grab the correct item from inventory if it exists,
--  or sneakily give the correct item in cheat mode.
script.on_event(defines.events.on_player_pipette, 
                function(event) mapPipette(event, global.loadedWagonMap) end)

--== ON_PLAYER_CONFIGURED_BLUEPRINT EVENT ==--
-- ID 70, fires when you select a blueprint to place
--== ON_PLAYER_SETUP_BLUEPRINT EVENT ==--
-- ID 68, fires when you select an area to make a blueprint or copy
-- Force Blueprints to only store empty vehicle wagons
script.on_event({defines.events.on_player_setup_blueprint, defines.events.on_player_configured_blueprint}, 
                function(event) mapBlueprint(event, global.loadedWagonMap) end)

------------------------------------------
-- Debug (print text to player console)
function debug(...)
  if global.debug then
    print_game(...)
  end
end

function print_game(...)
  text = ""
  for _, v in ipairs{...} do
    if type(v) == "table" then
      text = text..serpent.block(v)
    else
      text = text..tostring(v)
    end
  end
  game.print(text)
end

function print_file(...)
  text = ""
  for _, v in ipairs{...} do
    if type(v) == "table" then
      text = text..serpent.block(v)
    else
      text = text..tostring(v)
    end
  end
  log(text)
end  

-- Debug command
function cmd_debug(params)
  toggle = params.parameter
  if not toggle then
    if global.debug then
      toggle = "disable"
    else
      toggle = "enable"
    end
  end
  if toggle == "disable" then
    global.debug = false
    print_game("Debug mode disabled")
  elseif toggle == "enable" then
    global.debug = true
    print_game("Debug mode enabled")
  elseif toggle == "dump" then
    for v, data in pairs(global) do
      print_game(v, ": ", data)
    end
  elseif toggle == "dumplog" then
    for v, data in pairs(global) do
      print_file(v, ": ", data)
    end
    print_game("Dump written to log file")
  end
end
commands.add_command("vehicle-wagon-debug", {"command-help.vehicle-wagon-debug"}, cmd_debug)
