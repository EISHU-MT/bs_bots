--[[
	hunter
--]]
bots.hunting = {}
bots.hunter_time = {}
bots.stop_hunter = {}
bots.hunter_timer = 0
function bots.Hunt(self, enemy, prty)
	--bots.hunter_time[self.bot_name] = timedout
	if not mobkit.timer(self, 1) then
		return
	end
	
	if not enemy then core.log("error", "Bug: No enemy to hunt, but bots.Hunt() is executed.") return end
	if not self then core.log("error", "Bug: The bot that are used to hunt is not found!.") return end
	if not prty then core.log("error", "Bug: No priority found, bots.Hunt().") return end
	
	if mobkit.is_alive(enemy) then
		if not bots.hunting[self.bot_name] or (bots.hunting[self.bot_name] and not mobkit.is_alive(bots.hunting[self.bot_name])) then
			if Name(enemy) ~= Name(bots.hunting[self.bot_name]) then
				bots.hunting[self.bot_name] = enemy
				local func = function(self)
					
					if bots.stop_hunter[self.bot_name] then
						bots.stop_hunter[self.bot_name] = nil
						bots.hunting[self.bot_name] = nil
						bots.CancelPathTo[self.bot_name] = nil
						mobkit.clear_queue_high(self)
						mobkit.clear_queue_low(self)
						return true
					end
					
					local pos = mobkit.get_stand_pos(self) or self.object:get_pos()
					local opos = enemy:get_pos()
					
					if not opos then
						bots.stop_hunter[self.bot_name] = nil
						bots.hunting[self.bot_name] = nil
						bots.CancelPathTo[self.bot_name] = true
						mobkit.clear_queue_high(self)
						mobkit.clear_queue_low(self)
						return true
					end
					
					local dist = vector.distance(pos, opos)
					
					local p = bots.find_path_to(CheckPos(pos), CheckPos(opos))
					
					if p then
						bots.active_path_to(self, p, 1.5)
					end
				end
				mobkit.queue_high(self,func,prty)
			end
		end
	end
end

--						if dist < 3 then
--							mobkit.lq_jumpattack(self, 1, enemy)
--						end

local function globalstep(dtime)
	bots.hunter_timer = bots.hunter_timer + dtime
	if bots.hunter_timer >= 1 then
		if bs_match.match_is_started then
			for bot_name, data in pairs(bots.data) do
				if data.state == "alive" then
					if bots.hunting[bot_name] and mobkit.is_alive(bots.hunting[bot_name]) then
					elseif bots.hunting[bot_name] then
						--mobkit.clear_queue_high(data.object:get_luaentity())
						--mobkit.clear_queue_low(data.object:get_luaentity())
						bots.Hunt(self, bots.find_near_enemy(data.object:get_luaentity()), mobkit.get_queue_priority(self)+1)
						return true
					end
					if bs.get_player_team_css(enemy) == "" then
						bots.stop_hunter[bot_name] = nil
						bots.hunting[bot_name] = nil
						bots.CancelPathTo[bot_name] = true
						--mobkit.clear_queue_high(data.object:get_luaentity())
						--mobkit.clear_queue_low(data.object:get_luaentity())
						return true
					end
				end
			end
		end
		bots.hunter_timer = 0
	end
end

core.register_globalstep(globalstep)














