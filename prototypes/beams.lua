local ramp_blend_mode = "normal"
local ramp_scale = 1
local ramp_speed = 0.25

function make_ramp_beam(sound)
  local result =
  {
    type = "beam",
    flags = {"not-on-map"},
    width = 1,
    damage_interval = 20,
    random_target_offset = false,
    action_triggered_automatically = false,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          {
            type = "damage",
            damage = { amount = 0, type = "laser"}
          }
        }
      }
    },
    head =
    {
      filename = "__VehicleWagon2__/graphics/ramp/loading-ramp.png",
      flags = beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 26,
      frame_count = 16,
      scale = ramp_scale,
      animation_speed = ramp_speed,
      blend_mode = ramp_blend_mode
    },
    tail =
    {
      filename = "__VehicleWagon2__/graphics/ramp/loading-ramp.png",
      flags = beam_non_light_flags,
      line_length = 16,
      width = 32,
      height = 26,
      frame_count = 16,
      scale = ramp_scale,
      animation_speed = ramp_speed,
      --shift = util.by_pixel(11.5, 1),
      blend_mode = ramp_blend_mode
    },
    body =
    {
      {
        filename = "__VehicleWagon2__/graphics/ramp/loading-ramp.png",
        flags = beam_non_light_flags,
        line_length = 16,
        width = 32,
        height = 26,
        frame_count = 16,
        scale = ramp_scale,
        animation_speed = ramp_speed,
        blend_mode = ramp_blend_mode
      }
    },

    --[[light_animations =
    {
      head =
      {
        filename = "__base__/graphics/entity/laser-turret/hr-laser-body-light.png",
        line_length = 8,
        width = 64,
        height = 12,
        frame_count = 8,
        scale = 0.5,
        animation_speed = 0.5,
      },
      tail =
      {
        filename = "__base__/graphics/entity/laser-turret/hr-laser-end-light.png",
        width = 110,
        height = 62,
        frame_count = 8,
        shift = util.by_pixel(11.5, 1),
        scale = 0.5,
        animation_speed = 0.5,
      },
      body =
      {
        {
          filename = "__base__/graphics/entity/laser-turret/hr-laser-body-light.png",
          line_length = 8,
          width = 64,
          height = 12,
          frame_count = 8,
          scale = 0.5,
          animation_speed = 0.5,
        }
      }
    },

    ground_light_animations =
    {
      head =
      {
        filename = "__base__/graphics/entity/laser-turret/laser-ground-light-head.png",
        line_length = 1,
        width = 256,
        height = 256,
        repeat_count = 8,
        scale = 0.5,
        shift = util.by_pixel(-32, 0),
        animation_speed = 0.5,
        tint = {0.5, 0.05, 0.05}
      },
      tail =
      {
        filename = "__base__/graphics/entity/laser-turret/laser-ground-light-tail.png",
        line_length = 1,
        width = 256,
        height = 256,
        repeat_count = 8,
        scale = 0.5,
        shift = util.by_pixel(32, 0),
        animation_speed = 0.5,
        tint = {0.5, 0.05, 0.05}
      },
      body =
      {
        filename = "__base__/graphics/entity/laser-turret/laser-ground-light-body.png",
        line_length = 1,
        width = 64,
        height = 256,
        repeat_count = 8,
        scale = 0.5,
        animation_speed = 0.5,
        tint = {0.5, 0.05, 0.05}
      }
    }--]]
  }

  if sound then
    result.working_sound =
    {
      sound =
      {
        filename = "__base__/sound/fight/electric-beam.ogg",
        volume = 1
      },
      max_sounds_per_type = 4
    }
    result.name = "loading-ramp-beam"
  else
    result.name = "loading-ramp-beam-no-sound"
  end
  return result;
end

data:extend(
{
  make_ramp_beam(true)
}
)