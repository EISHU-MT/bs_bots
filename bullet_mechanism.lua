-- OBJ
local function on_step(self, dtime, mr)
	if mr.collides ~= true and self.timer >= 2 then
		self.object:remove()
		return
	end
	if mr.collides == true then
		local collisions = mr.collisions[1]
		if not collisions then
			return
		end
		if collisions.type == "object" then
			local obj = collisions.object
			if type(self.owner) ~= "userdata" then -- avoid crash from this
				self.object:remove()
				return
			end
			if Name(obj) and Name(self.owner) and Name(obj) ~= Name(self.owner) then
				local ObjectTeam = bs.get_player_team_css(collisions.object)
				if ObjectTeam == bots.data[Name(self.owner)].team then
					collisions.object:punch(self.owner, nil, {damage_groups = self.damage}, nil)
				end
				self.object:remove()
			end
		elseif collisions.type == "node" then
			minetest.add_particle({
				pos = self.object:get_pos(),
				velocity = {x=0, y=0, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 30,
				size = math.random(10,20)/10,
				collisiondetection = false,
				vertical = false,
				texture = "rangedweapons_bullethole.png",
				glow = 0,
			})
			self.object:remove()
			return
		end
		if self.timer >= 2 then
			self.object:remove()
		end
	end
	--print(dump(mr.collisions))
	
	if not mr.collisions[1] then
		return
	end
	self.timer = self.timer + dtime
end

local def = {
	timer = 0,
	initial_properties = {
		physical = true,
		hp_max = 420,
		glow = core.LIGHT_MAX,
		visual = "sprite",
		visual_size = {x=0.4, y=0.4},
		textures = {"bullet2.png"},
		lastpos = {},
		collide_with_objects = true,
		collisionbox = {-0.0025, -0.0025, -0.0025, 0.0025, 0.0025, 0.0025},
		static_save = false,
	},
	owner = {},
	damage = 5, -- Default
	on_step = on_step
}

core.register_entity("bs_bots:bullet", def)

bots.shoot = function(projectiles, dmg, entname, shoot_sound, combined_velocity, data, obj)
	local to_pos = obj:get_pos()
	local pos = data.object:get_pos()
	local entity = data.object:get_luaentity()
	local dir = bots.calc_dir(data.object:get_rotation())
	local yaw = data.object:get_yaw()
	local direction = vector.direction(pos, to_pos)
	local tmpsvertical = data.object:get_rotation().x / (math.pi/2)
	local svertical = math.asin(direction.y) - (math.pi/2)
	if pos and dir and yaw then
		minetest.sound_play(shoot_sound, {pos = pos, gain = 0.5, max_hear_distance = 60})
		pos.y = pos.y + 1.45
		projectiles = projectiles or 1
		for i=1,projectiles do
			local spawnpos_x = pos.x
			local spawnpos_y = pos.y
			local spawnpos_z = pos.z
			local obj = minetest.add_entity({x=spawnpos_x,y=spawnpos_y,z=spawnpos_z}, entname)
			local ent = obj:get_luaentity()
			local size = 0.1
			obj:set_properties({
				textures = {"bullet2.png"},
				visual = "sprite",
				visual_size = {x=0.4, y=0.4},
				collisionbox = {-size, -size, -size, size, size, size},
				glow = proj_glow,
			})
			
			ent.owner = data.object
			ent.damage = dmg or {fleshy = bots.default_bullet_damage}
			
			obj:set_pos(pos)
			obj:set_velocity({x=direction.x * combined_velocity * 2, y=direction.y * combined_velocity * 1.5, z=direction.z * combined_velocity * 2})
			--obj:set_rotation({x=0,y=yaw / (math.pi/2),z=-direction.y})
		end
	end
end