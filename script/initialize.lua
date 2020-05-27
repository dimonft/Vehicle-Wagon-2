--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: initialize.lua
 * Description: Event handlers for OnLoad and OnConfigurationChanged.
 *  - When Configuration Changes (mods installed, updated, or removed):
 *    1. Migrate data if VehicleWagon2 was updated from before 1.3.0.
 *    2. Create global data tables if they don't already exist.
 *    3. Read all the vehicle prototypes in the game and map them to appropriate loaded wagons and filtering lists.
 *  - When Game Loads (new game started):
 *    1. Create global data tables if they don't already exist.
 *    2. Read all the vehicle prototypes in the game and map them to appropriate loaded wagons and filtering lists.
--]]


require("script.makeGlobalMaps")

-- Initialize new global tables if they do not already exist
local function makeGlobalTables()
  -- Contains data on vehicles loaded on wagons
  global.wagon_data = global.wagon_data or {}
  -- Controls sequence of messages that tell players how to use the winch
  global.tutorials = global.tutorials or {}
  for i, player in pairs(game.players) do
    global.tutorials[player.index] = {}
  end
  -- Contains load/unload actions players ordered, while they wait for the 2-second delay to expire
  global.action_queue = global.action_queue or {}
  -- Contains entity each player actively selected with a winch.
  global.player_selection = global.player_selection or {}
  
end

-- Runs when new game starts
function OnInit()
  -- Generate wagon-vehicle mapping tables 
  makeGlobalMaps()
  -- Create global data tables
  makeGlobalTables()
end


function OnConfigurationChanged(event)

  -- Regenerate maps before migrating
  makeGlobalMaps()

  -- Migrate existing data if any exists
  if event and event.mod_changes["VehicleWagon2"] then
    -- format version string to "00.00.00"
    local oldVersion, newVersion = nil
    local oldVersionString = event.mod_changes["VehicleWagon2"].old_version
    if oldVersionString then
      oldVersion = string.format("%02d.%02d.%02d", string.match(oldVersionString, "(%d+).(%d+).(%d+)"))
    end
    local newVersionString = event.mod_changes["VehicleWagon2"].new_version
    if newVersionString then
      newVersion = string.format("%02d.%02d.%02d", string.match(newVersionString, "(%d+).(%d+).(%d+)"))
    end
    
    -- If there was an older version installed, migrate the global data tables
    if oldVersion and oldVersion < "02.00.00" then
      Migrate_1_x_x()
    end
    
    -- Remove all player arrows, now we use drawn circles
    for _,player in pairs(game.players) do
      player.clear_gui_arrow()
    end
  end
  
  -- Run when any mod or mod setting changes:
  -- Scrub wagon_data for invalid references and convert last_user to player_index
  local loaded_wagons = {}
  for _,surface in pairs(game.surfaces) do
    local wagons = surface.find_entities_filtered{name = global.loadedWagonList}
    for _,wagon in pairs(wagons) do
      loaded_wagons[wagon.unit_number] = wagon
    end
  end
  if global.wagon_data then
    local missing_prototypes = false
    local units_to_find = {}
    local gcki_enabled = (remote.interfaces["GCKI"] and 
                          remote.interfaces["GCKI"].get_vehicle_data and 
                          settings.global["vehicle-wagon-use-GCKI-permissions"].value)
    for id,data in pairs(global.wagon_data) do
      if not loaded_wagons[id] then
        game.print({"vehicle-wagon2.migrate-prototype-error",id,data.name})
        missing_prototypes = true
        global.wagon_data[id] = nil
      else
        -- Migrate last_user to player_index
        if data.last_user and type(data.last_user) ~= "number" then
          data.last_user = data.last_user.index
        end
        -- Add alt-mode icons
        if not data.icon then
          renderIcon(loaded_wagons[id], data.name)
          data.icon = true
        end
        -- Double-check GCKI-controlled lock state. 
        -- Reset all wagons if GCKI permissions are disabled or GCKI is uninstalled.
        if gcki_enabled and data.GCKI_data and (data.GCKI_data.owner or data.GCKI_data.locker) then
          if data.wagon and data.wagon.valid then
            data.wagon.minable = false
          else
            units_to_find[id] = 2
          end
        else
          if data.wagon and data.wagon.valid then
            data.wagon.minable = true
          else
            units_to_find[id] = 1
          end
        end
      end
    end
    -- Find references to any loaded wagon entities that were missing in the data table
    -- Update their minable properties according to the values chosen above
    if table_size(units_to_find) > 0 then
      for _,surface in pairs(game.surfaces) do
        for _,entity in pairs(surface.find_entities_filtered{name=global.loadedWagonList}) do
          local id = entity.unit_number
          -- Assign wagon entity to any we come across
          if global.wagon_data[id] and not global.wagon_data[id].wagon then
            global.wagon_data[id].wagon = entity
          end
          -- Found one on the list to make minable again
          if units_to_find[id] then
            entity.minable = (units_to_find[id] == 1)
            units_to_find[id] = nil
            -- If list is empty now, stop searching
            if table_size(units_to_find) == 0 then
              break
            end
          end
        end
        if table_size(units_to_find) == 0 then
          break
        end
      end
      -- Make sure we found everything
      for id,_ in pairs(units_to_find) do
        game.print({"vehicle-wagon2.migrate-wagon-error", id, global.wagon_data[id].name})  
      end
    end
    -- Give error message for missing prototypes
    if missing_prototypes then
      game.print({"vehicle-wagon2.migrate-prototype-warning"})
    end
  end
  
  -- Initialize new-style data tables if they aren't there already
  makeGlobalTables()
  
end

function OnRuntimeModSettingChanged(event)
  if event.setting == "vehicle-wagon-use-GCKI-permissions" then
    if global.wagon_data then
      local gcki_enabled = (remote.interfaces["GCKI"] and 
                            remote.interfaces["GCKI"].get_vehicle_data and 
                            settings.global["vehicle-wagon-use-GCKI-permissions"].value)
      for id,data in pairs(global.wagon_data) do
        -- Double-check GCKI-controlled lock state. 
        -- Reset all wagons if GCKI permissions are disabled or GCKI is uninstalled.
        if data.wagon and data.wagon.valid then
          if gcki_enabled and data.GCKI_data and (data.GCKI_data.owner or data.GCKI_data.locker) then
            data.wagon.minable = false
          else
            data.wagon.minable = true
          end
        end
      end
    end
  end
end

