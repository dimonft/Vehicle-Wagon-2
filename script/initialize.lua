--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: initialize.lua
 * Description: Event handlers for OnLoad and OnConfigurationChanged.
 *  - When Configuration Changes (mods installed, updated, or removed):
 *    1. Read all the vehicle prototypes in the game and map them to appropriate loaded wagons and filtering lists.
 *    2. Remove data referencing loaded wagons that were removed during migration or mod changes.
 *    3. Update entity data based on GCKI and UnminableVehicles mod states.
 *  - When Game Loads (new game started):
 *    1. Read all the vehicle prototypes in the game and map them to appropriate loaded wagons and filtering lists.
 *    2. Create global data tables if they don't already exist.
 *  - When Mod Setting Changes:
 *    1. If VehicleWagon2 GCKI permission setting changes, update wagon and stored vehicle minable states.
 *    2. If UnminableVehicles "make unminable" setting changes, update stored vehicle minable states.
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
  
  local gcki_enabled = game.active_mods["GCKI"] and settings.global["vehicle-wagon-use-GCKI-permissions"].value
  local unminable_enabled = game.active_mods["UnminableVehicles"] and settings.global["unminable_vehicles_make_unminable"].value
  
  -- Run when GCKI is uninstalled:
  if event.mod_changes["GCKI"] and event.mod_changes["GCKI"].new_version == nil then
    -- Make sure all loaded wagons are minable
    if not unminable_enabled then
      for _,surface in pairs(game.surfaces) do
        for _,entity in pairs(surface.find_entities_filtered{name=global.loadedWagonList}) do
          entity.minable = true
        end
      end
    end
    -- Make sure all loaded vehicles are minable, clear GCKI data
    for id, data in pairs(global.wagon_data) do
      if not unminable_enabled then
        data.minable = nil
      end
      data.GCKI_data = nil
    end
  end
  
  -- Run when Unminable Vehicles is installed or uninstalled:
  if event.mod_changes["UnminableVehicles"] then
    -- Update loaded vehicle state in response to Unminable Vehicles setting
    if event.setting == "unminable_vehicles_make_unminable" then
      for id, data in pairs(global.wagon_data) do
        -- Make unminable whenever setting is checked
        -- Only make minable again if GCKI lock state is not engaged
        if unminable_enabled then
          data.minable = false
        elseif not (gcki_enabled and data.GCKI_data and (data.GCKI_data.locker or data.GCKI_data.owner)) then
          data.minable = nil
        end
      end
    end
  end

end

function OnRuntimeModSettingChanged(event)
  
  local gcki_enabled = game.active_mods["GCKI"] and settings.global["vehicle-wagon-use-GCKI-permissions"].value
  local unminable_enabled = game.active_mods["UnminableVehicles"] and settings.global["unminable_vehicles_make_unminable"].value
    
  -- Reset minable state when GCKI setting changes
  if event.setting == "vehicle-wagon-use-GCKI-permissions" then
    for id,data in pairs(global.wagon_data) do
      -- Double-check GCKI-controlled lock state. 
      -- Reset all wagons if GCKI permissions are disabled or GCKI is uninstalled.
      -- If UnminableVehicles is enabled, don't set to true
      if (gcki_enabled and data.GCKI_data and (data.GCKI_data.owner or data.GCKI_data.locker))  then
        if data.wagon and data.wagon.valid then
          data.wagon.minable = false
        end
        data.minable = false
      elseif not unminable_enabled then
        if data.wagon and data.wagon.valid then
          data.wagon.minable = true
        end
        data.minable = nil
      end
    end
  end
  
  -- Update loaded vehicle state in response to Unminable Vehicles setting
  if event.setting == "unminable_vehicles_make_unminable" then
    for id, data in pairs(global.wagon_data) do
      -- Make unminable whenever setting is checked
      -- Only make minable again if GCKI lock state is not engaged
      if unminable_enabled then
        data.minable = false
      elseif not (gcki_enabled and data.GCKI_data and (data.GCKI_data.locker or data.GCKI_data.owner)) then
        data.minable = nil
      end
    end
  end
  
end
