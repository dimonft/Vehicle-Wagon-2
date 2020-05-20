--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: renderVisuals.lua
 * Description: Render drawing functions to show loading and unloading range around selected entities.
--]]


-- function clearVisuals: Remove any rendered objects associated with this player's selection
-- p: player or player_index
function clearVisuals(p)
  local player_index = p
  if type(p) ~= "number" then
    player_index = p.index
  end
  if global.player_selection[player_index] and global.player_selection[player_index].visuals then
    for _,id in pairs(global.player_selection[player_index].visuals) do
      rendering.destroy(id)
    end
  end
end


-- function renderVehicleRange: Display the loading area around the selected vehicle
-- p: player or player_index
-- target: selected entity to track
function renderVehicleVisuals(p, target)
  -- First clear existing renders for this player
  clearVisuals(p)
  
  -- Then create circle for player
  return { 
            rendering.draw_circle{
              color=RANGE_COLOR,
              radius=LOADING_DISTANCE,
              filled=true,
              target=target,
              surface=target.surface,
              players={p},
              draw_on_ground=true
            }
         }
end

-- function renderWagonRange: Display the unloading area around the selected wagon
-- p: player or player_index
-- target: selected entity to track
function renderWagonVisuals(p, target)
  -- First clear existing renders for this player
  clearVisuals(p)
  
  -- Now create a rotated polygon with hemispheres on either end
  -- Entity is referenced in the North orientation before being rotated
  local length_front = target.prototype.collision_box.left_top.y
  local length_back  = target.prototype.collision_box.right_bottom.y
  local wagon_angle  = target.orientation*2*math.pi
  local wagon_front  = {x=-length_front*math.sin(wagon_angle), y=length_front*math.cos(wagon_angle)}
  local wagon_back   = {x=-length_back*math.sin(wagon_angle),  y=length_back*math.cos(wagon_angle)}
  local visuals = {
    rendering.draw_polygon{
      color=RANGE_COLOR,
      vertices={{target={UNLOAD_RANGE,length_back}},
                {target={-UNLOAD_RANGE,length_back}},
                {target={UNLOAD_RANGE,length_front}},
                {target={-UNLOAD_RANGE,length_front}}},
      target=target,
      orientation=target.orientation,
      surface=target.surface,
      players={p},
      draw_on_ground=true
    },
    rendering.draw_arc{
      color=RANGE_COLOR,
      max_radius=UNLOAD_RANGE,
      min_radius=0,
      start_angle=wagon_angle+math.pi,
      angle=math.pi,
      target=target,
      target_offset=wagon_front,
      surface=target.surface,
      players={p},
      draw_on_ground=true
    },
    rendering.draw_arc{
      color=RANGE_COLOR,
      max_radius=UNLOAD_RANGE,
      min_radius=0,
      start_angle=wagon_angle,
      angle=math.pi,
      target=target,
      target_offset=wagon_back,
      surface=target.surface,
      players={p},
      draw_on_ground=true
    }
  }  
  
  return visuals
end