--  MOVEMENTS
bots.path_to = {}
bots.path_finder_running = {}
bots.CancelPathTo = {}
bots.AbortPathMovementFor = {}

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

function bots.assign_path_to(self, path, speed)
	--print("ASSIGNED PATH TO: "..self.bot_name)
	if vector.distance(path[1], self.object:get_pos()) > 1 and BsEntities.IsEntityAlive(bots.hunting[self.bot_name]) then
		path = bots.find_path_to(CheckPos(self.object:get_pos()), CheckPos(bots.hunting[self.bot_name]:get_pos())) -- Reset path if bot are away from last path
	elseif (not (vector.distance(path[1], self.object:get_pos()) > 1)) and bots.path_to[self.bot_name].path then
		return
	end
	bots.path_to[self.bot_name].path = path
	bots.path_to[self.bot_name].speed = speed
	bots.path_to[self.bot_name].timer = #path
end

local true_var = true

function bots.MovementFunction(self)
	if bots.path_to[self.bot_name] and bots.path_to[self.bot_name].path then
		if not bots.AbortPathMovementFor[self.bot_name] then --BsEntities.IsQueueEmpty(self) -- might fix soon
			local path = bots.path_to[self.bot_name].path
			if #path <= 1 then
				bots.path_finder_running[self.bot_name] = false
				bots.path_to[self.bot_name] = {}
				bots.CancelPathTo[self.bot_name] = nil
				BsEntities.AnimateEntity(self, "stand")
				return
			end
			if bots.CancelPathTo[self.bot_name] then
				bots.CancelPathTo[self.bot_name] = nil
				bots.path_finder_running[self.bot_name] = false
				bots.path_to[self.bot_name] = {}
				BsEntities.AnimateEntity(self, "stand")
				return
			end
			local speed = bots.path_to[self.bot_name].speed or 1
			local path_iter = bots.path_to[self.bot_name].timer
			local width = ceil(hitbox(self)[4])
			if #path >= width then
				path_iter = width
			end
			local pos = BsEntities.GetStandPos(self)
			local tpos = path[path_iter]
			local dir = vector.direction(pos, tpos)
			local total_dist = vec_dist(pos, path[#path])
			if total_dist <= width + 0.5 then
				bots.CancelPathTo[self.bot_name] = nil
				bots.path_finder_running[self.bot_name] = false
				bots.path_to[self.bot_name] = {}
				BsEntities.AnimateEntity(self, "stand")
				return
			end
			if not self.isonground then
				speed = speed * 0.5
			end
			if vec_dist(pos, tpos) <= width + 0.5 or (path[path_iter + 1] and vec_dist(pos, path[path_iter + 1]) <= width + 0.5) then
				table.remove(path, 1)
				bots.path_to[self.bot_name].timer = bots.path_to[self.bot_name].timer - 1
			end
			

			
			local turn_rate = self.turn_rate or 8
			if vector.distance(pos, tpos) < width + 2 then
				turn_rate = turn_rate + 2
			end
			bots.path_to[self.bot_name].timer = bots.path_to[self.bot_name].timer - self.dtime
			if bots.path_to[self.bot_name].timer <= 0 then
				bots.CancelPathTo[self.bot_name] = nil
				bots.path_finder_running[self.bot_name] = false
				bots.path_to[self.bot_name] = {}
				BsEntities.AnimateEntity(self, "stand")
				return
			end
			
			BsEntities.TurnToYaw(self, core.dir_to_yaw(dir), turn_rate)
			BsEntities.AdvanceHorizontal(self, self.max_speed * speed + 0.1)
			if will_jump then
				BsEntities.QueueFreeJump(self)
			end
			BsEntities.AnimateEntity(self, "walk")
			bots.path_finder_running[self.bot_name] = true
			bots.path_to[self.bot_name].path = path
			--print(path_iter)
			--print(bots.path_to[self.bot_name].timer)
		end
	else
		--core.log("action", "Waiting a path for "..self.bot_name)
	end
end