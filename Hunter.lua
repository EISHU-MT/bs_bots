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
	
	bots.hunting[self.bot_name] = enemy

	
	if bots.hunting[self.bot_name] then -- Should deny the actual path and do a new path.
		bots.CancelPathTo[self.bot_name] = true
		--return
	end
	
	local func = function(self)
		if bots.stop_hunter[self.bot_name] then
			bots.stop_hunter[self.bot_name] = nil
			bots.hunting[self.bot_name] = nil
			bots.CancelPathTo[self.bot_name] = nil
			--bots.hunter_time[self.bot_name] = nil
			return true
		end
		
		local pos = mobkit.get_stand_pos(self) or self.object:get_pos()
		local opos = enemy:get_pos()
		if (not opos) then
			bots.stop_hunter[self.bot_name] = nil
			bots.hunting[self.bot_name] = nil
			bots.CancelPathTo[self.bot_name] = nil
			--bots.hunter_time[self.bot_name] = nil
			return true
		end
		local dist = vector.distance(pos,opos)
		
		if not mobkit.is_alive(enemy) then return true end
		
		if bs.get_player_team_css(enemy) == "" then return true end
		
		if mobkit.is_queue_empty_low(self) and self.isonground then
			
			local p = bots.find_path_to(CheckPos(pos), CheckPos(opos))
			
			if p and CountTable(p) > 0 then
				bots.active_path_to(self, p, 1.5)
				return
			else
				mobkit.goto_next_waypoint(self,opos)
			end
			
			--if GetObjectsInBotView(self, true)[1] then
			--	bots.stop_hunter[self.bot_name] = nil
			--	bots.hunting[self.bot_name] = nil
			--	bots.CancelPathTo[self.bot_name] = nil
				--bots.hunter_time[self.bot_name] = nil
			--	return true
			--else
				if dist < 4 then
					--mobkit.hq_attack(self,prty+1,enemy)
					-- Clear high queue & Attack!
					mobkit.clear_queue_high(self)
					
					local from = bots.to_2d(self.object:get_pos())
					local to = bots.to_2d(enemy:get_pos())
					local offset_to = {
						x = to.x - from.x,
						y = to.y - from.y
					}
					
					local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
					self.object:set_yaw(dir)
					self.object:set_animation(bots.bots_animations[self.bot_name].mine, bots.bots_animations[self.bot_name].anispeed, 0)
					enemy:punch(self.object, nil, {damage_groups = {fleshy=5}}, nil)
				end
			--end
		end
	end
	mobkit.queue_high(self,func,prty)
end
--[[
local function globalstep(dtime)
	bots.hunter_timer = bots.hunter_timer + dtime
	if bots.hunter_timer >= 1 then
		for bot_name, value in pairs(bots.hunter_time) do
			bots.hunter_time[bot_name] = bots.hunter_time[bot_name] - 1
			if bots.hunter_time[bot_name] <= 0 then
				bots.hunter_time[bot_name] = nil
			end
		end
		bots.hunter_timer = 0
	end
end

core.register_globalstep(globalstep)

--]]












