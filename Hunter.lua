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
	
	if not enemy then return end
	if not self then return end
	if not prty then return end
	
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
		
		
		if mobkit.is_queue_empty_low(self) and self.isonground then
			
			local p = bots.find_path_to(CheckPos(pos), CheckPos(opos))
			
			if p then
				bots.active_path_to(self, p, 1.2)
				return
			end
			
			--if GetObjectsInBotView(self, true)[1] then
			--	bots.stop_hunter[self.bot_name] = nil
			--	bots.hunting[self.bot_name] = nil
			--	bots.CancelPathTo[self.bot_name] = nil
				--bots.hunter_time[self.bot_name] = nil
			--	return true
			--else
				if dist > 3 and dist < 20 then
					bots.active_path_to(self, bots.find_path_to(pos, opos), 1.2)
				elseif dist > 5 then
					mobkit.goto_next_waypoint(self,opos)
				end
				if dist < 3 then
					mobkit.hq_attack(self,prty+1,enemy)
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












