--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: data.lua
 * Description:  Main Data Stage function.  Include all the prototype definitions.
 --]]

require("prototypes.entities-compatibility")

-- After entities are added, calculate the weights and forces based on mod settings
require("data.update_stats")


-- Compatibility with Schall's Transport Group mod
if mods["SchallTransportGroup"] then
	data.raw["item-with-entity-data"]["vehicle-wagon"].subgroup = "vehicles-railway"
end

