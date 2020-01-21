
--== ON_ROBOT_PRE_MINED ==--
-- When robot tries to mine a loaded wagon, try to unload the vehicle first!
-- If vehicle cannot be unloaded, send its contents away in the robot piece by piece.
local function OnRobotPreMined(event)
  local entity = event.entity
  if global.loadedWagonMap[entity.name] then
      
    -- Player or robot is mining a loaded wagon
    -- Attempt to unload the wagon nearby
    local unit_number = entity.unit_number
    local robot = event.robot
  
    local wagonData = global.wagon_data[unit_number]
    if not wagonData then
      -- Loaded wagon data or vehicle entity is invalid
      -- Replace wagon with unloaded version and delete data
      game.print("ERROR: Missing global data for unit "..unit_number)  
      deleteWagon(unit_number)
      replaceCarriage(entity, "vehicle-wagon", false, false)
    elseif not game.entity_prototypes[wagonData.name] then
      game.print("ERROR: Missing prototype \""..global.wagon_data[unit_number].name.."\" for unit "..unit_number)  
      -- Loaded wagon data or vehicle entity is invalid
      -- Replace wagon with unloaded version and delete data
      deleteWagon(unit_number)
      replaceCarriage(entity, "vehicle-wagon", false, false)
    else
      -- We can try to unload this wagon
      local vehicle = unloadVehicleWagon({status="unload",
                                          wagon=entity,
                                          replace_wagon=false})
      
      if not vehicle then
        -- Vehicle could not be unloaded
        -- First check for inventory contents
        local robotInventory = event.robot.get_inventory(defines.inventory.robot_cargo)
        local robotSize = 1 + event.robot.force.worker_robots_storage_bonus
        local robotEmpty = robotInventory.is_empty()
        
        if robotEmpty and wagonData.items.trunk then
          for index,stack in pairs(wagonData.items.trunk) do
            if not stack.count then stack.count = 1 end
            game.print("Giving robot cargo stack: "..stack.name.." : "..stack.count)
            wagonData.items.trunk[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then
              robotEmpty = false
              break
            end
          end
        end
        
        if robotEmpty and wagonData.items.ammo then
          for index,stack in pairs(wagonData.items.ammo) do
            if not stack.count then stack.count = 1 end
            game.print("Giving robot ammo stack: "..stack.name.." : "..stack.count)
            wagonData.items.ammo[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then
              robotEmpty = false
              break
            end
          end
        end
        
        if robotEmpty and wagonData.burner then
          if robotEmpty and wagonData.burner.inventory then
            for index,stack in pairs(wagonData.burner.inventory) do
              if not stack.count then stack.count = 1 end
              game.print("Giving robot burner fuel stack: "..stack.name.." : "..stack.count)
              wagonData.burner.inventory[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
              if not robotInventory.is_empty() then
                robotEmpty = false
                break
              end
            end
          end
          if robotEmpty and wagonData.burner.inventory then
            for index,stack in pairs(wagonData.burner.inventory) do
              game.print("Giving robot burner burnt stack: "..stack.name.." : "..stack.count)
              if not stack.count then stack.count = 1 end
              wagonData.burner.inventory[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
              if not robotInventory.is_empty() then
                robotEmpty = false
                break
              end
            end
          end
        end

        if robotEmpty and wagonData.items.grid and not wagonData.items.equip_stacks and not wagonData.items.fuel_stacks then
          wagonData.items.equip_stacks, wagonData.items.fuel_stacks = saveRestoreLib.saveGridStacks(wagonData.items.grid)
        end
        if robotEmpty and wagonData.items.fuel_stacks then
          for index,stack in pairs(wagonData.items.fuel_stacks) do
            if not stack.count then stack.count = 1 end
            local count = stack.count
            game.print("Giving robot equipment fuel stack: "..stack.name.." : "..stack.count)
            wagonData.items.fuel_stacks[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then
              if wagonData.items.fuel_stacks[index] then
                count = count - wagonData.items.fuel_stacks[index].count
              end
              saveRestoreLib.removeStackFromSavedGrid(wagonData.items.grid, {name=stack.name, count=count})
              robotEmpty = false
              break
            end
          end
        end
        if robotEmpty and wagonData.items.equip_stacks then
          for index,stack in pairs(wagonData.items.equip_stacks) do
            if not stack.count then stack.count = 1 end
            local count = stack.count
            game.print("Giving robot equipment stack: "..stack.name.." : "..stack.count)
            wagonData.items.equip_stacks[index] = saveRestoreLib.insertStack(robotInventory, stack, robotSize)
            if not robotInventory.is_empty() then
              if wagonData.items.equip_stacks[index] then
                count = count - wagonData.items.equip_stacks[index].count
              end
              saveRestoreLib.removeStackFromSavedGrid(wagonData.items.grid, {name=stack.name, count=count})
              robotEmpty = false
              break
            end
          end
        end
        
        if robotEmpty then
          if saveRestoreLib.insertStack(robotInventory, {name=wagonData.name,count=1}, robotSize) == nil then
            game.print("Gave robot "..wagonData.name.." : 1")
          else
            game.print("Unknown vehicle entity "..wagonData.name)
          end
          replaceCarriage(entity, "vehicle-wagon", false, false)
          -- Delete wagon data and any associated requests
          deleteWagon(unit_number)
        end
      end
      
    end
    
  elseif entity.name == "vehicle-wagon" then
    -- Delete any requests for loading this particular wagon
    clearWagon(entity.unit_number)
    
  elseif entity.name == "item-on-ground" then
    -- Change item-on-ground to unloaded wagon before robot picks it up
    if entity.stack.valid_for_read and global.loadedWagonMap[entity.stack.name] then
      entity.stack.set_stack({name="vehicle-wagon", count=entity.stack.count})
    end
  end
  
end

return OnRobotPreMined
