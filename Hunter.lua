--[[
	hunter
--]]
bots.hunting = {}
bots.hunter_time = {}
bots.stop_hunter = {}
bots.hunter_timer = 0
function bots.Hunt(self, enemy)
	if not enemy then core.log("error", "Bug: No enemy to hunt, but bots.Hunt() is executed.") return end
	if not self then core.log("error", "Bug: The bot that are used to hunt is not found!.") return end
	if not bots.AbortPathMovementFor[self.bot_name] then
		if BsEntities.IsEntityAlive(enemy) then
			if not bots.hunting[self.bot_name] or (bots.hunting[self.bot_name] and not BsEntities.IsEntityAlive(bots.hunting[self.bot_name])) then
				bots.hunting[self.bot_name] = enemy
				return true
			else
				return false
			end
		end
	end
end

function bots.GetHuntFunction(self)
	if bots.hunting[self.bot_name] then
		if BsEntities.IsEntityAlive(bots.hunting[self.bot_name]) then
			local enemy = bots.hunting[self.bot_name]
			if bots.stop_hunter[self.bot_name] then
				bots.stop_hunter[self.bot_name] = nil
				bots.hunting[self.bot_name] = nil
			end
			local pos = BsEntities.GetStandPos(self)
			local opos = BsEntities.GetStandPos(enemy)
			if not opos then
				bots.stop_hunter[self.bot_name] = nil
				bots.hunting[self.bot_name] = nil
				return
			end
			local dist = vector.distance(pos, opos)
			local path = bots.find_path_to(CheckPos(pos), CheckPos(opos))
			if path then
				bots.assign_path_to(self, path, 1.4)
			end
		else
			bots.hunting[self.bot_name] = nil
		end
	end
end













