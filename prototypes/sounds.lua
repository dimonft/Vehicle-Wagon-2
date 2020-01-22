--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: sounds.lua
 * Description:  Add sound prototypes.
 *   Sounds added:
 *    - Winch operating
 *    - Latch On
 *    - Latch Off
--]]


data:extend({
	{
		type = "sound",
		name = "winch-sound",
		variations =
		{
			{
				filename = "__VehicleWagon2__/sound/Winch.ogg",
				volume = 0.9
			},
			{
				filename = "__VehicleWagon2__/sound/Winch2.ogg",
				volume = 0.9
			},
		},
	},
	{
		type = "sound",
		name = "latch-on",
		variations =
		{
			{
				filename = "__VehicleWagon2__/sound/latchOn.ogg",
				volume = 0.8
			}
		},
	},
	{
		type = "sound",
		name = "latch-off",
		variations =
		{
			{
				filename = "__VehicleWagon2__/sound/latchOff.ogg",
				volume = 0.8
			}
		},
	},
})
