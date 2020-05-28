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


-- Runs when new game starts
function OnInit()
  -- Generate wagon-vehicle mapping tables 
  makeGlobalMaps()
  -- Create global data tables
  makeGlobalTables()
end


function OnConfigurationChanged(event)

  -- Migrations run before on_configuration_changed.
  -- Data structure should already be 2.x.3.

  -- Regenerate maps with any new prototypes.
  makeGlobalMaps()
  
  -- Purge data for any entities that were removed
  -- Migration should already have added "wagon" entity reference to each valid entry
  for id,data in pairs(global.wagon_data) do
    if not data.wagon or not data.wagon.valid then
      game.print({"vehicle-wagon2.migrate-prototype-error",id,data.name})
      global.wagon_data[id] = nil
    end
  end
  
  -- Run when GCKI is uninstalled:
  if event.mod_changes["GCKI"] and event.mod_changes["GCKI"].new_version == nil then
    -- Make sure all loaded wagons are minable
    for _,surface in pairs(game.surfaces) do
      for _,entity in pairs(surface.find_entities_filtered{name=global.loadedWagonList}) do
        entity.minable = true
      end
    end
  end

end

function OnRuntimeModSettingChanged(event)
  game.print("In VW mod setting changed "..event.setting)
  -- Reset minable state when GCKI setting changes
  if (event.setting == "vehicle-wagon-use-GCKI-permissions" and 
      remote.interfaces["GCKI"] and
      remote.interfaces["GCKI"].get_vehicle_data ) then
    
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

