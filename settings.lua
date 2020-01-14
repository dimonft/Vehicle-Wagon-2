--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: settings.lua
 * Description: Setting to control Vehicle Wagon operation.
--]]

data:extend({
  {
    type = "string-setting",
    name = "vehicle-wagon-robot-deconstruction",
    order = "aa",
    setting_type = "runtime-global",
    default_value = "sometimes",
    allowed_values = {"sometimes","always","never"}
  },
  {
    type = "bool-setting",
    name = "vehicle-wagon-use-custom-weights",
    order = "aa",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "double-setting",
    name = "vehicle-wagon-vehicle-weight-factor",
    order = "ac",
    setting_type = "startup",
    default_value = 0.2,
    min_value = 0.01,
    max_value = 1.0
  },
  {
    type = "double-setting",
    name = "vehicle-wagon-empty-weight-factor",
    order = "ab",
    setting_type = "startup",
    default_value = 0.6,
    min_value = 0.1,
    max_value = 2.0
  }
})
