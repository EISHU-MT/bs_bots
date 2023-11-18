--  MOVEMENTS
bots.path_finder = {}
bots.path_finder_running = {}
bots.CancelPathTo = {}
bots.renew_bot_path = {}

local random = math.random
local abs = math.abs
local ceil = math.ceil
local floor = math.floor
local hitbox = function(s) return s.object:get_properties().collisionbox end

local vec_dir = vector.direction
local vec_dist = vector.distance

local function dist_2d(pos1, pos2)
	local a = vector.new(pos1.x, 0, pos1.z)
	local b = vector.new(pos2.x, 0, pos2.z)
	return vec_dist(a, b)
end

function bots.CancelPath(self)
	bots.CancelPathTo[self.bot_name] = true
end

function bots.is_fordwarding(self)
	return self.object:get_velocity().x ~= 0 and self.object:get_velocity().z ~= 0 and self.object:get_velocity().y ~= 0
end

function bots.is_there_y_difference(pos1, pos2)
	return pos1.y ~= pos2.y
end

function bots.active_path_to(self, path, speed_factor) -- To object will be always a enemy.
	local anim = "walk"
	if not path then core.log("error", "Attempt of crash blocked!: Tried to request movement without paths.") return end
	local timer = #path
	-- We should clear other jobs about movements to continue
	if bots.path_finder_running[self.bot_name] then -- There should need a old-path clear to be the new-path
		if mobkit.timer(self, 3) then
			bots.renew_bot_path[self.bot_name] = path
			core.log("action", "Attempt to do add a new func in LL queue, just replaced the path and not added function.")
		end
		return
	end
	local func = function(self)
		if bots.renew_bot_path[self.bot_name] then
			path = table.copy(bots.renew_bot_path[self.bot_name])
			bots.renew_bot_path[self.bot_name] = nil
			core.log("action", "Received new path from active_path_to.")
		end
		if #path <= 1 then
			bots.path_finder_running[self.bot_name] = nil
			mobkit.animate(self, "stand")
			return true
		end
		if bots.CancelPathTo[self.bot_name] then
			bots.CancelPathTo[self.bot_name] = nil
			mobkit.animate(self, "stand")
			return true
		end
		local speed = speed_factor or 1
		local path_iter = 1
		local width = ceil(hitbox(self)[4])
		if #path >= width then
			path_iter = width
		end
		local pos = mobkit.get_stand_pos(self)
		local tpos = path[path_iter]
		local dir = vector.direction(pos, tpos)
		local total_dist = vec_dist(pos, path[#path])
		if total_dist <= width + 0.5 then
			bots.path_finder_running[self.bot_name] = nil
			mobkit.animate(self, "stand")
			return true
		end
		if not self.isonground then
			speed = speed * 0.5
		end
		if vec_dist(pos, tpos) <= width + 0.5 or (path[path_iter + 1] and vec_dist(pos, path[path_iter + 1]) <= width + 0.5) then
			table.remove(path, 1)
			timer = timer - 1
		end
		
		local will_jump = false
		if bots.is_there_y_difference(path[path_iter + 1], pos) then
			will_jump = true
		end
		
		local turn_rate = self.turn_rate or 8
		if vector.distance(pos, tpos) < width + 2 then
			turn_rate = turn_rate + 2
		end
		timer = timer - self.dtime
		if timer <= 0 then
			bots.path_finder_running[self.bot_name] = nil
			mobkit.animate(self, "stand")
			return true
		end
		
		mobkit.turn2yaw(self, minetest.dir_to_yaw(dir), turn_rate)
		mobkit.go_forward_horizontal(self, self.max_speed * speed + 0.1)
		if will_jump then
			mobkit.lq_freejump(self, 1)
		end
		mobkit.animate(self, anim)
		bots.path_finder_running[self.bot_name] = true

	end
	mobkit.queue_low(self, func)
end











