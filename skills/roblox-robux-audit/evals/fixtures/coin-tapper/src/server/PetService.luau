--!strict
local DataService = require(script.Parent.DataService)

local PetService = {}

function PetService:Give(player: Player, pet: string)
	local data = DataService:Get(player)
	if data then
		table.insert(data.pets, pet)
	end
end

return PetService
