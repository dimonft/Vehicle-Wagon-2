

--== ON_PRE_PLAYER_MINED_ITEM ==--
-- When player mines a loaded wagon, try to unload the vehicle first
-- If vehicle cannot be unloaded, give its contents to the player and spill the rest.
local function OnPrePlayerMinedItem(event)
  local entity = event.entity
  if global.loadedWagonMap[entity.name] then
    -- Player is mining a loaded wagon
    -- Attempt to unload the wagon nearby
    local unit_number = entity.unit_number
    local player_index = event.player_index
    
    local player = game.players[player_index]
    local surface = player.surface
    local wagonData = global.wagon_data[unit_number]
    if not wagonData then
      -- Loaded wagon data or vehicle entity is invalid
      -- Replace wagon with unloaded version and delete data
      game.print("ERROR: Missing global data for unit "..unit_number)  
      replaceCarriage(entity, "vehicle-wagon", false, false)
    elseif not game.entity_prototypes[wagonData.name] then
      -- Loaded wagon data or vehicle entity is invalid
      -- Replace wagon with unloaded version and delete data
      game.print("ERROR: Missing prototype \""..global.wagon_data[unit_number].name.."\" for unit "..unit_number)  
      replaceCarriage(entity, "vehicle-wagon", false, false)
    else
      -- We can try to unload this wagon
      local vehicle = unloadVehicleWagon({player_index=player_index,
                                          status="unload",
                                          wagon=entity,
                                          replace_wagon=false})
      
      if not vehicle then
        -- Vehicle could not be unloaded
        player.print({"vw3-position-error"})
    
        -- Insert vehicle and contents into player's inventory
        local text_position = player.position
        text_position.y = text_position.y + 1
        player.print({"position-error"})
        surface.create_entity({name = "flying-text", position = text_position, text = {"item-inserted", 1, game.entity_prototypes[wagonData.name].localised_name}})
        local playerPosition = player.position
        local playerInventory = player.get_main_inventory()
        
        local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, {{name = wagonData.name, count = 1}})
        saveRestoreLib.spillStacks(r2, surface, playerPosition)
        
        -- Give player the equipment contents, spill excess
        if wagonData.items.grid then
          local equip_stacks, fuel_stacks = saveRestoreLib.saveGridStacks(wagonData.items.grid)
          local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, equip_stacks)
          saveRestoreLib.spillStacks(r2, surface, playerPosition)
          local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, fuel_stacks)
          saveRestoreLib.spillStacks(r2, surface, playerPosition)
        end
        
        -- Give player the ammo inventory, spill excess
        local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, wagonData.items.ammo)
        saveRestoreLib.spillStacks(r2, surface, playerPosition)
        -- Give player the cargo inventory, spill excess
        local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, wagonData.items.trunk)
        saveRestoreLib.spillStacks(r2, surface, playerPosition)
        -- Give player the burner contents, spill excess
        if wagonData.burner then
          local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, wagonData.burner.inventory)
          saveRestoreLib.spillStacks(r2, surface, playerPosition)
          local r2 = saveRestoreLib.insertInventoryStacks(playerInventory, wagonData.burner.burnt_results_inventory)
          saveRestoreLib.spillStacks(r2, surface, playerPosition)
        end
        
      end
      
    end
    
    -- Delete the data associated with the mined wagon
    -- Delete any requests for unloading this particular wagon
    deleteWagon(unit_number)
    
  elseif entity.name == "vehicle-wagon" then
    -- Delete any requests for loading this particular wagon
    clearWagon(entity.unit_number)
    
  elseif entity.name == "item-on-ground" then
    -- Change item-on-ground to unloaded wagon before player picks it up
    if entity.stack.valid_for_read and global.loadedWagonMap[entity.stack.name] then
      entity.stack.set_stack({name="vehicle-wagon", count=entity.stack.count})
    end
  end
  
end

return OnPrePlayerMinedItem
