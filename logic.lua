--[[
	Bot Brain
--]]

bbp = {}
loaded_bots = {} -- Need to flush when a match starts

function bbp.WhileOnPrepareTime(self)
	local LuaEntity = self.object:get_luaentity()
	if LuaEntity and LuaEntity.bot_name and bots.data[LuaEntity.bot_name] then
		-- Check if this script is runned
		if not loaded_bots[LuaEntity.bot_name] then
			loaded_bots[LuaEntity.bot_name] = true
			-- Load All Data!
			local Money = bots.data[LuaEntity.bot_name].money
			local FavoriteWeapons = bots.favorite_weapons[LuaEntity.bot_name]
			local BotName = LuaEntity.bot_name
			local Object = self.object
			-- We should do buy weapons
			local HardWeaponData = Shop.IdentifyWeapon(FavoriteWeapons.hard_weapon)
			local HandWeaponData = Shop.IdentifyWeapon(FavoriteWeapons.hand_weapon)
			local HardUsedWeapon = FavoriteWeapons.hard_weapon
			local HandUsedWeapon = FavoriteWeapons.hand_weapon
			if HardWeaponData and HandWeaponData then
				-- Buy Hard Weapon
				if HardWeaponData.item_name ~= HardUsedWeapon then
					if HardWeaponData.price <= Money then
						bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HardWeaponData.price
						bots.favorite_weapons[LuaEntity.bot_name].hard_weapon = HardWeaponData.item_name
					end
				end
				-- Buy Soft Weapon
				if HandWeaponData.item_name ~= HandUsedWeapon then
					if HandWeaponData.price <= Money then
						bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HandWeaponData.price
						bots.favorite_weapons[LuaEntity.bot_name].hard_weapon = HandWeaponData.item_name
					end
				end
			else
				error("A bot was registered without weapons data!\nData:\nBotName: "..BotName)
			end
			-- Prepare any visual thing for Bot
			-- First of all, Wield Item (Uses wield3d API)
			if bots.data[BotName].wield_item_obj then
				bots.data[BotName].wield_item_obj:remove()
				bots.data[BotName].wield_item_obj = nil
			end
			local WieldObject = core.add_entity(Object:get_pos(), "bs_bots:wield_item")
			bots.data[BotName].wield_item_obj = WieldObject
			WieldObject:set_attach(Object, "Arm_Right", {x=0, y=5.5, z=3}, {x=-90, y=225, z=90})
			local to_be_seen = ""
			if bots.data[BotName].weapons[hard_weapon] ~= "" then
				to_be_seen = bots.data[BotName].weapons[hard_weapon]
			else
				to_be_seen = bots.data[BotName].weapons[hand_weapon]
			end
			WieldObject:set_properties({
				textures = {to_be_seen or "wield3d:hand"},
				visual_size = {x=0.25, y=0.25},
			})
			-- Prepare Nametag
			bots.add_nametag(Object, bots.data[BotName].team, BotName)
		end
	else
		core.log("error", "~BS BOTS: Unknown Object Found!")
	end
end

bots.in_hand_weapon = {}
bots.queue_shot = {}

bots.timer = 0
local step = function(dtime)
	--bots.timer = bots.timer + dtime
	--if bots.timer >= 0.1 then
		for name, val in pairs(bots.queue_shot) do
			--print(val)
			
			if type(val) == "number" and not (val <= 0) then
				bots.queue_shot[name] = bots.queue_shot[name] - dtime
			else
				bots.queue_shot[name] = nil
				bots.data[name].object:set_animation(bots.bots_animations[name].stand, 30, 0)
			end
		end
	--	bots.timer = 0
	--end
end

core.register_globalstep(step)

return function(self)
	if bs_match.match_is_started then
		loaded_bots = {}
		
		local enemy_table = GetObjectsNearBot(self, true, 200)
		local enemy_to_hunt = enemy_table[math.random(#enemy_table)]-- Poor enemy.
		bots.Hunt(self, enemy_to_hunt, mobkit.get_queue_priority(self))
		
		-- Now is the time for bullets!
		if not bots.queue_shot[self.bot_name] then
			for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), 60)) do
				if obj:is_player() or (obj:get_luaentity() and obj:get_luaentity().bot_name) then
					local lua_entity = obj:get_luaentity()
					if lua_entity and lua_entity.bot_name ~= self.bot_name and lua_entity.team ~= self.team then
						local pos = CheckPos(self.object:get_pos())
						local to_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
						local to_pos2 = CheckPos({x = obj:get_pos().x, y = obj:get_pos().y , z = obj:get_pos().z})
						print(bots.line_of_sight(pos, to_pos2), self.bot_name)
						if bots.line_of_sight(pos, to_pos2) then
							
							--print("USED")
							
							local to_use = ""
							if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
								to_use = bots.data[self.bot_name].weapons.hard_weapon
							elseif bots.data[self.bot_name].weapons.hand_weapon ~= "" then
								to_use = bots.data[self.bot_name].weapons.hand_weapon
							end
							if vector.distance(pos, obj:get_pos()) <= 5 then
								--mobkit.hq_attack(self,mobkit.get_queue_priority(self)+1,obj)
								bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, 30, 0)
								obj:punch(self.object, nil, {damage_groups = {fleshy = 5}}, nil)
								print("HURTING by bot")
							else
								local itemstack = ItemStack(to_use)
								if itemstack and itemstack ~= "" then
									if itemstack:get_name() == "" then
										return
									end
									
									bots.in_hand_weapon[self.bot_name] = to_use
									
									bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, 30, 0)
									
									local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage -- can be changed.
									local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
									mobkit.turn2yaw(self, minetest.dir_to_yaw(vector.direction(to_pos, to_pos2)), 1.2)
									local cooldown = itemstack:get_definition().RW_gun_capabilities.gun_cooldown
									local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
									bots.shoot(1, damage or 5, "bs_bots:bullet", sound, velocity, self, obj)
									bots.queue_shot[self.bot_name] = cooldown - (cooldown/3)
									if bots.data[self.bot_name].wield_item_obj then
										bots.data[self.bot_name].wield_item_obj:set_properties({
											textures = {itemstack:get_name()},
											visual_size = {x=0.25, y=0.25},
										})
									end
								else
									--print()
								end
							end
						else
							if vector.distance(pos, CheckPos(obj:get_pos())) <= 4 then
								--bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, 30, 0)
								--obj:punch(self.object, nil, {damage_groups = {fleshy = 5}}, nil)
								mobkit.hq_attack(self,mobkit.get_queue_priority(self)+1,obj)
								--print("HURTING")
							end
						end
					elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team and not bs.spectator[Name(obj)] then
						
						local pos = CheckPos(self.object:get_pos())
						local to_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
						local to_pos2 = CheckPos(obj:get_pos())
						if bots.line_of_sight(pos, to_pos2) then
							
							--print("USED")
							
							local to_use = ""
							if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
								to_use = bots.data[self.bot_name].weapons.hard_weapon
							elseif bots.data[self.bot_name].weapons.hand_weapon ~= "" then
								to_use = bots.data[self.bot_name].weapons.hand_weapon
							end
							if vector.distance(pos, obj:get_pos()) <= 5 then
								--mobkit.hq_attack(self,mobkit.get_queue_priority(self)+1,obj)
								bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, 30, 0)
								obj:punch(self.object, nil, {damage_groups = {fleshy = 5}}, nil)
								print("HURTING")
							else
								local itemstack = ItemStack(to_use)
								if itemstack and itemstack ~= "" then
									if itemstack:get_name() == "" then
										return
									end
									
									bots.in_hand_weapon[self.bot_name] = to_use
									
									bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, 30, 0)
									
									local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage -- can be changed.
									local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
									mobkit.turn2yaw(self, minetest.dir_to_yaw(vector.direction(to_pos, to_pos2)), 1.2)
									local cooldown = itemstack:get_definition().RW_gun_capabilities.gun_cooldown
									local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
									bots.shoot(1, damage or 5, "bs_bots:bullet", sound, velocity, self, obj)
									bots.queue_shot[self.bot_name] = cooldown - (cooldown/3)
									if bots.data[self.bot_name].wield_item_obj then
										bots.data[self.bot_name].wield_item_obj:set_properties({
											textures = {itemstack:get_name()},
											visual_size = {x=0.25, y=0.25},
										})
									end
								else
									--print()
								end
							end
						else
							if vector.distance(pos, CheckPos(obj:get_pos())) <= 4 then
								mobkit.hq_attack(self,mobkit.get_queue_priority(self)+1,obj)
								--bots.data[self.bot_name].object:set_animation(bots.bots_animations[self.bot_name].mine, 30, 0)
								--obj:punch(self.object, nil, {damage_groups = {fleshy = 5}}, nil)
								--print("HURTING")
							end
						end
					end
				end
			end
		end
	else
		bbp.WhileOnPrepareTime(self)
	end
end



