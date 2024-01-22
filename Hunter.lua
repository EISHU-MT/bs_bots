--[[
	hunter
--]]
bots.hunting = {}
bots.hunter_time = {}
bots.stop_hunter = {}
bots.hunt_vel = {}
bots.hunter_timer = 0
function bots.Hunt(self, enemy, vel, force)
	if not enemy then return false end
	if not self then return false end
	if not bots.AbortPathMovementFor[self.bot_name] then
		if BsEntities.IsEntityAlive(enemy) then
			if not bots.hunting[self.bot_name] or (bots.hunting[self.bot_name] and not BsEntities.IsEntityAlive(bots.hunting[self.bot_name])) then
				bots.hunting[self.bot_name] = enemy
				if vel then
					bots.hunt_vel[self.bot_name] = vel
				end
				return true
			elseif force then
				bots.hunting[self.bot_name] = enemy
				if vel then
					bots.hunt_vel[self.bot_name] = vel
				end
				return true
			else
				return false
			end
		end
	end
end

function bots.is_enemy_alive(obj)
	if obj then
		if obj:is_player() then
			if RespawnDelay and RespawnDelay.players[Name(obj)] then
				return false
			else
				return true
			end
		else
			return obj:get_yaw() ~= nil
		end
	else
		return false
	end
end

function bots.GetHuntFunction(self)
	if bots.hunting[self.bot_name] then
		if bots.is_enemy_alive(bots.hunting[self.bot_name]) and BsEntities.IsEntityAlive(bots.hunting[self.bot_name]) then
			if bs.get_player_team_css(bots.hunting[self.bot_name]) ~= "" then
				local enemy = bots.hunting[self.bot_name]
				if bots.stop_hunter[self.bot_name] then
					bots.stop_hunter[self.bot_name] = nil
					bots.hunting[self.bot_name] = nil
					bots.hunt_vel[self.bot_name] = nil
					return
				end
				local pos = BsEntities.GetStandPos(self)
				local opos = BsEntities.GetStandPos(enemy)
				if not opos then
					bots.stop_hunter[self.bot_name] = nil
					bots.hunting[self.bot_name] = nil
					bots.hunt_vel[self.bot_name] = nil
					return
				end
				local dist = vector.distance(pos, opos)
				local path = bots.find_path_to(CheckPos(pos), CheckPos(opos))
				if path then
					bots.assign_path_to(self, path, bots.hunt_vel[self.bot_name] or 1.4)
				end
			else
				bots.hunting[self.bot_name] = nil
				bots.stop_hunter[self.bot_name] = nil
				bots.hunt_vel[self.bot_name] = nil
			end
		else
			bots.hunting[self.bot_name] = nil
			bots.hunt_vel[self.bot_name] = nil
			bots.stop_hunter[self.bot_name] = nil
		end
	end
end













