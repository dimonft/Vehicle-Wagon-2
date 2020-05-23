--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: config.lua
 * Description: Hold constants for data and control phases
--]]


LOADING_DISTANCE = 10   -- Allowable distance between vehicle and wagon when Loading
CAPSULE_RANGE = 12 -- Range in Winch capsule prototype
RANGE_COLOR = {r=0.08, g=0.08, b=0, a=0.01}  -- Color of the loading/unloaidng range graphics
KEEPOUT_RANGE_COLOR = {r=0.12, g=0, b=0, a=0.01}  -- Color of the loading/unloaidng range graphics
UNLOAD_RANGE = 6  -- Allowable distance between vehicle and wagon when Unloading
LOADING_EFFECT_TIME = 120  -- duration of sound and loading ramp beam
UNLOADING_EFFECT_TIME = 120  -- duration of sound and loading ramp beam
EXTRA_RAMP_TIME = 20

BED_CENTER_OFFSET = -0.6  -- Y offset of center of flatbed used to position icons and loading ramp graphics
BED_WIDTH = 0.475  -- Half-Width of flatbed used to position loading ramp graphics
MIN_LOADING_RAMP_LENGTH = 1 -- Don't squish the belt so much when right on top of the wagon
