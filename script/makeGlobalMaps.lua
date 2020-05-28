
-- Go through all the available prototypes and assign them to a valid loaded wagon or "nope"
function makeGlobalMaps()

  -- Need to check max weight as we go through
  local useWeights = settings.startup["vehicle-wagon-use-custom-weights"].value
  local maxWeight = (useWeights and settings.startup["vehicle-wagon-maximum-weight"].value) or math.huge
  
  -- Some sprites show up backwards from how they ought to, so we flip the wagons relative to the vehicles.
  global.loadedWagonFlip = {}  --: loaded-wagon-name --> boolean
  
  global.vehicleMap = {}  --: vehicle-name --> loaded-wagon-name
  for k,p in pairs(game.get_filtered_entity_prototypes({{filter="type", type="car"}})) do
    
    if k and string.find(k,"nixie") ~= nil then
      global.vehicleMap[k] = nil  -- non vehicle entity
    elseif k == "uplink-station" then
      global.vehicleMap[k] = nil  -- non vehicle entity
    elseif k and (string.find(k,"heli") ~= nil or string.find(k,"rotor") ~= nil) then
      global.vehicleMap[k] = nil  -- helicopter & heli parts incompatible
    elseif k == "vwtransportercargo" then
      global.vehicleMap[k] = nil  -- non vehicle or incompatible?
    elseif k and string.find(k,"airborne") ~= nil then
      global.vehicleMap[k] = nil  -- can't load flying planes [Aircraft Realism compatibility]
    elseif p.weight > maxWeight then
      global.vehicleMap[k] = nil  -- This vehicle is too heavy
    elseif k and string.find(k,"Schall%-tank%-SH") ~= nil then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank-SH"  -- Schall's Super Heavy Tank
    elseif k and string.find(k,"cargo%-plane") ~= nil then
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
    elseif k and string.find(k,"Schall%-ht%-RA") ~= nil then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank"  -- Schall's Rocket Artillery look like tanks
    elseif k and string.find(k,"Schall%-tank%-L") ~= nil then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank-L"  -- Schall's Light Tank
    elseif k and string.find(k,"Schall%-tank%-H") ~= nil then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank-H"  -- Schall's Heavy Tank
    elseif k == "kr-advanced-tank" then
      global.vehicleMap[k] = "loaded-vehicle-wagon-kr-advanced-tank"  -- Krastorio2 Advanced Tank  
    elseif k and string.find(k,"tank") ~= nil then
      global.vehicleMap[k] = "loaded-vehicle-wagon-tank"  -- Generic tank
    elseif k and string.find(k,"car") ~= nil and string.find(k,"cargo") == nil then
      global.vehicleMap[k] = "loaded-vehicle-wagon-car"  -- Generic car (that is not cargo)
    else
      global.vehicleMap[k] = "loaded-vehicle-wagon-tarp"  -- Default for everything else
    end
  end
  
  -- Make list and map of loaded wagon entities (regardless of whether any vehicles map to them)
  global.loadedWagonMap = {}   --: loaded-wagon-name --> "vehicle-wagon"
  global.loadedWagonList = {}  --: list of loaded-wagon-name
  for k,p in pairs(game.get_filtered_entity_prototypes({{filter="type", type="cargo-wagon"}})) do
    if string.find(k,"loaded%-vehicle%-wagon%-") ~= nil then
      global.loadedWagonMap[k] = "vehicle-wagon"
      table.insert(global.loadedWagonList, k)
    end
  end
  
end


-- Initialize new global tables if they do not already exist
function makeGlobalTables()
  -- Contains data on vehicles loaded on wagons
  global.wagon_data = global.wagon_data or {}
  -- Controls sequence of messages that tell players how to use the winch
  global.tutorials = global.tutorials or {}
  for i, player in pairs(game.players) do
    global.tutorials[player.index] = global.tutorials[player.index] or {}
  end
  -- Contains load/unload actions players ordered, while they wait for the 2-second delay to expire
  global.action_queue = global.action_queue or {}
  -- Contains entity each player actively selected with a winch.
  global.player_selection = global.player_selection or {}
  
end

