

--[[
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
]]--