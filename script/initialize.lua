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



-- Go through all the available prototypes and assign them to a valid loaded wagon or "nope"
local function InitializeGlobalMaps()
  
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


local function Migrate_1_x_x()
  -- If previous version is before 1.3.0, migrate global data tables to the new format
  -- We will delete any pending load/unload commands and selections in the save file
  
  -- Old format: 
  -- global.vehicle_data[player_index] contains loaded vehicles each player clicked on.
  -- global.wagon_data[player_index] contains player actions to load and unload vehicles
  -- global.wagon_data[unit_number] contains vehicle data saved for each loaded wagon unit
  -- {
  --      name = vehicle entity name stored
  --      health = vehicle health
  --      color = vehicle color or nil
  --      burner = table of vehicle burner settings
  --      {
  --          inventory.get_contents(), 
  --          burnt_result_inventory.get_contents(), 
  --          currently_burning (Item prototype),
  --          remaining_burning_fuel,
  --          heat
  --      }
  --      filters = table of inventory filters
  --      {
  --          [defines.inventory.ammo] = table of slot filters
  --              {
  --                  <slot number> = <filter item-name>
  --              }
  --          [defines.inventory.trunk] = table of slot filters
  --              {
  --                  <slot number> = <filter item-name>
  --              }
  --      }
  --      items = table of vehicle contents
  --      {
  --           <item-name> = total count of this item in fuel, ammo, and trunk inventories
  --           <grid> = list of equipment grid contents
  --           {
  --               <#> = {name, position, energy, shield, 
  --                        burner={inventory.get_contents(), 
  --                                burnt_result_inventory.get_contents(), 
  --                                currently_burning (Item prototype),
  --                                remaining_burning_fuel,
  --                                heat}
  --                      }
  --           }
  --      }
  -- }
  
  
  -- Step 1: Clear Pending Selections and Actions
  if global.vehicle_data then
    for player_index,_ in pairs(global.vehicle_data) do
      local player = game.get_player(player_index)
      if player then
        player.clear_gui_arrow()
      end
    end
    global.vehicle_data = nil
  end
  if global.wagon_data then
    for player_index,player in pairs(game.players) do
      if global.wagon_data[player_index] then
        player.clear_gui_arrow()
        global.wagon_data[player_index] = nil
      end
    end
  end
  
  -- Step 2: Make a list of all loaded wagon entities in the game
  local loaded_wagons = {}
  for _,surface in pairs(game.surfaces) do
    local wagons = surface.find_entities_filtered{name = global.loadedWagonList}
    for _,wagon in pairs(wagons) do
      loaded_wagons[wagon.unit_number] = wagon
    end
  end
  
  -- Step 3: Copy contents of wagon_data to a new table in the new format
  local new_wagon_data = {}
  for unit_number,data in pairs(global.wagon_data) do
    -- Make sure this is a valid wagon data entry
    if not data.items then
      -- Not a valid wagon data structure
      global.wagon_data[unit_number] = nil
    else
      -- Make sure this loaded wagon still exists
      if not loaded_wagons[unit_number] or not loaded_wagons[unit_number].valid then
        game.print({"vehicle-wagon2.migrate-wagon-error", unit_number, data.name})  
        global.wagon_data[unit_number] = nil
      else
        -- Make sure this data is for a valid vehicle type
        if not data.name or not game.entity_prototypes[data.name] then
          -- Give error message
          if data.name then
            game.print({"vehicle-wagon2.migrate-prototype-error", unit_number, data.name})
          end
          -- Replace loaded wagon with empty one
          replaceCarriage(loaded_wagons[unit_number], "vehicle-wagon", false, false)
          global.wagon_data[unit_number] = nil
        else
        
          -- Migrate data
          local newData = {}
          newData.name = data.name
          newData.health = data.health
          newData.color = data.color
          
          -- Migrate Vehicle Burner
          if data.burner then
            newData.burner = {
              heat = data.burner.heat
              remaining_burning_fuel = data.burner.remaining_burning_fuel
            }
            -- Currently burning converted from LuaItemPrototype object to item-name
            if data.burner.currently_burning and data.burner.currently_burning.valid then
              newData.burner.currently_burning = data.burner.currently_burning.name
            end
            -- Convert burnt_result_inventory from name->count dictionary to stack list
            if data.burner.burnt_result_inventory then
              newData.burner.burnt_result_inventory = saveRestoreLib.itemsToStacks(data.burner.burnt_result_inventory)
            end
          end
          
          -- Migrate Equipment Grid
          if data.items.grid then
            newData.grid = {}
            for i,e in pairs(data.items.grid) then
              local newE = {  item = {name=e.name, position=e.position},
                              energy = e.energy,
                              shield = e.shield }
              if e.burner then
                local newB = {heat = e.burner.heat,
                              remaining_burning_fuel = e.burner.remaining_burning_fuel}
                -- Currently burning converted from LuaItemPrototype object to item-name
                if e.burner.currently_burning and e.burner.currently_burning.valid then
                  newB.currently_burning = e.burner.currently_burning.name
                end
                -- Convert burnt_result_inventory from name->count dictionary to stack list
                if e.burner.burnt_result_inventory then
                  newB.burnt_result_inventory = saveRestoreLib.itemsToStacks(e.burner.burnt_result_inventory)
                end
                -- Convert fuel inventory
                if e.burner.inventory then
                  newB.inventory = saveRestoreLib.itemsToStacks(e.burner.inventory)
                else
                  newB.inventory = {}
                end
                newE.burner = newB
              end
            end
            data.items.grid = nil
          end
          
          -- Migrate inventory contents.  Separate fuel and ammo items so they get inserted correctly.
          -- (Doesn't matter if there are too many or the wrong types. Remainders will be put in trunk when unloaded.)
          newData.items = {ammo={}, trunk={}}
          for item,count in (data.items) do
            if game.item_prototypes[item] and game.item_prototypes[item].fuel_category then
              -- Put fuel items in the burner fuel inventory
              table.insert(newData.burner.inventory, {name=item, count=count})
            elseif game.item_prototypes[item] and game.item_prototypes[item].get_ammo_type() then
              -- Put ammo in the ammo inventory
              table.insert(newData.items.ammo, {name=item, count=count})
            else
              -- Anything else goes in trunk
              table.insert(newData.items.trunk, {name=item, count=count})
            end
          end
          
          -- Migrate inventory filters.
          newData.filters = {ammo={}, trunk={}}
          if data.filters and data.filters[defines.inventory.car_ammo] then
            newData.filters.ammo = data.filters[defines.inventory.car_ammo]
          end
          if data.filters and data.filters[defines.inventory.car_trunk] then
            newData.filters.trunk = data.filters[defines.inventory.car_trunk]
          end
          
          game.print({"vehicle-wagon2.migrate-vehicle-success", unit_number, {"entity-name."..data.name}})
          
          -- Add data to new list for this loaded wagon
          new_wagon_data[unit_number] = newData
          -- Delete from old list
          wagon_data[unit_number] = nil
        end
      end
    end
  end
  -- Store new global data table
  global.wagon_data = nil
  global.wagon_data = new_wagon_data
  
end

-- Runs when new game starts (we also call it when mods are changed)
function OnInit()
  
  global.wagon_data = global.wagon_data or {}
  global.tutorials = global.tutorials or {}
  for i, player in pairs(game.players) do
    global.tutorials[player.index] = {}
  end
  
  global.action_queue = global.action_queue or {}
  global.player_selection = global.player_selection or {}
  
  InitializeGlobalMaps()
end


function OnConfigurationChanged(data)

  -- Migrate existing data if any
  if data and data.mod_changes["VehicleWagon2"] then
    -- format version string to "00.00.00"
    local oldVersion, newVersion = nil
    local oldVersionString = data.mod_changes["VehicleWagon2"].old_version
    if oldVersionString then
      oldVersion = format("%02d.%02d.%02d", match(oldVersionString, "(%d+).(%d+).(%d+)"))
    end
    local newVersionString = data.mod_changes["VehicleWagon2"].new_version
    if newVersionString then
      newVersion = format("%02d.%02d.%02d", match(newVersionString, "(%d+).(%d+).(%d+)"))
    end
    
    -- If there was an older version installed, migrate the global data tables
    if oldVersion and oldVersion < "02.00.00" then
      Migrate_1_x_x()
    end
  end
  
  -- Initialize new data tables and vehicle mappings
  OnInit()
  
end
