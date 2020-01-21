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
      global.vehicleMap[k] = nil  -- non vehicle entity
    elseif k == "uplink-station" then
      global.vehicleMap[k] = nil  -- non vehicle entity
    elseif String.contains(k,"heli") or String.contains(k,"rotor") then
      global.vehicleMap[k] = nil  -- helicopter & heli parts incompatible
    elseif k == "vwtransportercargo" then
      global.vehicleMap[k] = nil  -- non vehicle or incompatible?
    elseif String.contains(k,"airborne") then
      global.vehicleMap[k] = nil  -- can't load flying planes
    elseif String.contains(k,"Schall%-tank%-SH") then
      global.vehicleMap[k] = nil  -- Super Heavy tank doesn't fit on train
    elseif String.contains(k,"cargo%-plane") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-cargoplane"  -- Cargo plane, Better cargo plane, Even better cargo plane
      global.loadedWagonFlip["loaded-vehicle-wagon-cargoplane"] = true  -- Cargo plane wagon sprite is flipped
    elseif k == "jet" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-jet"
      global.loadedWagonFlip["loaded-vehicle-wagon-jet"] = true  -- Jet wagon sprite is flipped
    elseif k == "gunship" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-gunship"
      global.loadedWagonFlip["loaded-vehicle-wagon-gunship"] = true  -- Gunship wagon sprite is flipped
    elseif k == "dumper-truck" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-truck"  -- Specific to dump truck mod
    elseif String.contains(k,"Schall%-ht%-RA") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank"  -- Schall's Rocket Artillery look like tanks
    elseif String.contains(k,"tank") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank"  -- Generic tank
    elseif String.contains(k,"car") and not String.contains(k,"cargo") then
      global.vehicleMap[k] = "loaded-vehicle-wagon-car"  -- Generic car (that is not cargo)
    else
      global.vehicleMap[k] = "loaded-vehicle-wagon-tarp"  -- Default for everything else
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


--== ON_INIT EVENT ==--
-- Initialize global data tables
function On_Init()

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
  if global.action_queue[unit_number] and global.action_queue[unit_number].beam then
    global.action_queue[unit_number].beam.destroy()
  end
  global.action_queue[unit_number] = nil
  for player_index,selection in pairs(global.player_selection) do
    if selection.wagon then
      if not selection.wagon.valid or selection.wagon.unit_number == unit_number then
        clearSelection(player_index)
      end
    end
  end
end

function deleteWagon(unit_number)
  global.wagon_data[unit_number] = nil
  clearWagon(unit_number)
end


--== ON_PLAYER_USED_CAPSULE ==--
-- Queues load/unload data when player clicks with the winch.
script.on_event(defines.events.on_player_used_capsule, require("script.OnPlayerUsedCapsule"))


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
-- When player mines a loaded wagon, try to unload the vehicle first
-- If vehicle cannot be unloaded, give its contents to the player and spill the rest.
script.on_event(defines.events.on_pre_player_mined_item, require("script.OnPrePlayerMinedItem"))

--== ON_ROBOT_PRE_MINED ==--
-- When robot tries to mine a loaded wagon, try to unload the vehicle first!
-- If vehicle cannot be unloaded, send its contents away in the robot piece by piece.
script.on_event(defines.events.on_robot_pre_mined, require("script.OnRobotPreMined"))


--== ON_PICKED_UP_ITEM ==--
-- When player picks up an item, change loaded wagons to empty wagons.  
function OnPickedUpItem(event)
  if global.loadedWagonMap[event.item_stack.name] then
    game.players[event.player_index].remove_item(event.item_stack)
    game.players[event.player_index].insert({name="vehicle-wagon", count=event.item_stack.count})
  end
end
script.on_event(defines.events.on_picked_up_item, OnPickedUpItem)


--== ON_MARKED_FOR_DECONSTRUCTION ==--
-- When a wagon is marked for deconstruction, cancel any pending actions to load or unload
local number = 1
function OnMarkedForDeconstruction(event)
  -- Delete any player selections or load/unload actions associated with this wagon
  if event.entity.name == "vehicle-wagon" or global.loadedWagonMap[event.entity.name] then
    clearWagon(event.entity.unit_number)
  end
end
script.on_event(defines.events.on_marked_for_deconstruction, OnMarkedForDeconstruction)


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
script.on_event(defines.events.on_built_entity, OnBuiltEntity)
script.on_event(defines.events.script_raised_built, OnBuiltEntity)


--== ON_ENTITY_DIED ==--
--== SCRIPT_RAISED_DESTROY ==--
-- When a loaded wagon dies or is destroyed by a different mod, delete its vehicle data
function OnEntityDied(event)
  local entity = event.entity
  if global.loadedWagonMap[entity.name] or entity.name == "vehicle-wagon" then
    -- Loaded wagon died, its vehicle is unrecoverable
    -- Also clear selection data for this wagon
    deleteWagon(entity.unit_number)
  end
end
script.on_event(defines.events.on_entity_died, OnEntityDied)
script.on_event(defines.events.script_raised_destroy, OnEntityDied)


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
                function(event) blueprintLib.mapPipette(event, global.loadedWagonMap) end)

--== ON_PLAYER_CONFIGURED_BLUEPRINT EVENT ==--
-- ID 70, fires when you select a blueprint to place
--== ON_PLAYER_SETUP_BLUEPRINT EVENT ==--
-- ID 68, fires when you select an area to make a blueprint or copy
-- Force Blueprints to only store empty vehicle wagons
script.on_event({defines.events.on_player_setup_blueprint, defines.events.on_player_configured_blueprint}, 
                function(event) blueprintLib.mapBlueprint(event, global.loadedWagonMap) end)

------------------------------------------
-- Debug (print text to player console)
function debug(...)
  if global.debug then
    print_game(...)
  end
end

function print_game(...)
  local text = ""
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
  local text = ""
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
  local toggle = params.parameter
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
