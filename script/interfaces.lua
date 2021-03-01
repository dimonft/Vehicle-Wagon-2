--[[ Copyright (c) 2021 robot256 (MIT License)
 * Project: Vehicle Wagon 2 rewrite
 * File: interfaces.lua
 * Description: Remote Interfaces to save and restore loaded vehicle data
--]]


-- Returns a copy of the loaded vehicle data for the wagon entity.
function get_wagon_data(wagon)
	if global.wagon_data and wagon and wagon.valid and global.wagon_data[wagon.unit_number] then
		-- Copy the table so it can be safely deleted from our global later
		local saveData = copy.deepcopy(global.wagon_data[wagon.unit_number])
		-- Delete references to actual game objects that will be deleted later
		saveData.wagon = nil
		saveData.icon = nil
		return saveData
	end
end

-- Stores the new loaded-vehicle data associated with the given wagon.
function set_wagon_data(wagon, new_data)
	if wagon.valid and new_data then
		local saveData = copy.deepcopy(new_data)
		saveData.wagon = wagon
		-- Put an icon on the wagon showing contents
		saveData.icon = renderIcon(wagon, saveData.name)
		-- Store data in global
		global.wagon_data = global.wagon_data or {}
		global.wagon_data[wagon.unit_number] = saveData
	end
end

remote.add_interface(
	"vehicle_wagon_2",
	{
		["get_wagon_data"] = get_wagon_data,
		["set_wagon_data"] = set_wagon_data
	}
)
