--[[
	Bot Brain
--]]

bbp = {}
Logic = {}
loaded_bots = {} -- Need to flush when a match starts

bots.logics = {} -- a, b, c

function bbp.WhileOnPrepareTime(self)
	local LuaEntity = self.object:get_luaentity()
	if LuaEntity and LuaEntity.bot_name and bots.data[LuaEntity.bot_name] then
		-- Check if this script is runned
		if not loaded_bots[LuaEntity.bot_name] then
			loaded_bots[LuaEntity.bot_name] = true
			-- Load All Data!
			local Money = bots.data[LuaEntity.bot_name].money
			local FavoriteWeapons = table.copy(bots.favorite_weapons[LuaEntity.bot_name])
			local BotName = LuaEntity.bot_name
			local Object = self.object
			-- We should do buy weapons
			local HardWeaponData = Shop.IdentifyWeapon(FavoriteWeapons.hard_weapon)
			local HandWeaponData = Shop.IdentifyWeapon(FavoriteWeapons.hand_weapon)
			local HardUsedWeapon = bots.data[self.bot_name].hard_weapon
			local HandUsedWeapon = bots.data[self.bot_name].hand_weapon
			if HardWeaponData and HandWeaponData then
				-- Buy Hard Weapon
				if HardWeaponData.item_name ~= HardUsedWeapon then
					if HardWeaponData.price <= Money then
						if bots.data[self.bot_name].weapons.hard_weapon ~= "" then
							local WeaponData = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hard_weapon)
							if WeaponData and WeaponData.price <= HardWeaponData.price then
								core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hard_weapon))
								bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HardWeaponData.price
								bots.data[self.bot_name].weapons.hard_weapon = HardWeaponData.item_name
								core.log("action", "Bot "..BotName.." did buy: "..HardWeaponData.item_name)
							end
						else
							bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HardWeaponData.price
							bots.data[self.bot_name].weapons.hard_weapon = HardWeaponData.item_name
							core.log("action", "Bot "..BotName.." did buy: "..HardWeaponData.item_name)
						end
					end
				end
				-- Buy Soft Weapon
				if HandWeaponData.item_name ~= HandUsedWeapon then
					if HandWeaponData.price <= Money then
						if bots.data[self.bot_name].weapons.hand_weapon ~= "" then
							local WeaponData = Shop.IdentifyWeapon(bots.data[self.bot_name].weapons.hand_weapon)
							if WeaponData and WeaponData.price <= HandWeaponData.price then
								core.add_item(CheckPos(self.object:get_pos()), ItemStack(bots.data[self.bot_name].weapons.hand_weapon))
								bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HandWeaponData.price
								bots.data[self.bot_name].weapons.hand_weapon = HandWeaponData.item_name
								core.log("action", "Bot "..BotName.." did buy: "..HandWeaponData.item_name)
							end
						else
							bots.data[LuaEntity.bot_name].money = bots.data[LuaEntity.bot_name].money - HandWeaponData.price
							bots.data[self.bot_name].weapons.hard_weapon = HandWeaponData.item_name
							core.log("action", "Bot "..BotName.." did buy: "..HandWeaponData.item_name)
						end
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
			local WieldObjectEntity = WieldObject:get_luaentity()
			WieldObjectEntity.holder = self.bot_name
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
			self.object:set_animation(bots.bots_animations[self.bot_name].stand, bots.bots_animations[self.bot_name].anispeed, 0)
		end
	else
		core.log("error", "~BS BOTS: Unknown Object Found!")
	end
end

local C = CountTable

function Logic.OldOnStep(self)
	if bs_match.match_is_started then
		if self then
			loaded_bots = {}
			-- Hunt logic
			if self.isonground then
				if C(maps.current_map.teams) > 2 then
					local team_enemies = bs.enemy_team(bots.data[self.bot_name].team)
					if C(team_enemies) >= 1 then
						local selected = team_enemies[1]
						if selected and bs.team[selected].state == "alive" then
							local enemies = bs.get_team_players(selected)
							local enemy = enemies[math.random(1, C(enemies))]
							if enemy then
								bots.Hunt(self, enemy)
							end
						end
					end
				else
					local team_enemy = bs.enemy_team(bots.data[self.bot_name].team)
					if team_enemy and team_enemy ~= "" and bs.team[team_enemy].state == "alive" then
						local enemies = bs.get_team_players(team_enemy)
						local enemy = enemies[math.random(1, C(enemies))]
						if enemy then
							bots.Hunt(self, enemy)
						end
					end
				end
			end
			-- In Bot View logic
			local detected = {}
			for _, obj in pairs(core.get_objects_inside_radius(self.object:get_pos(), self.view_range+50)) do
				if Name(obj) and Name(obj) ~= self.bot_name then
					if obj:get_luaentity() and obj:get_luaentity().bot_name ~= self.bot_name then -- Make sure that is not the scanning bot
						if --[[(vector.distance(obj:get_pos(), self.object:get_pos()) < 2 and vector.distance(obj:get_pos(), self.object:get_pos()) > 0) or--]] bots.is_in_bot_view(self, obj) then
							if obj:get_luaentity() and obj:get_luaentity().bot_name then
								if bots.data[obj:get_luaentity().bot_name] and bots.data[self.bot_name] and bots.data[obj:get_luaentity().bot_name].team ~= bots.data[self.bot_name].team then
									table.insert(detected, obj)
									--print("Added "..Name(obj))
								end
							end
						end
					elseif obj:is_player() and bs_old.get_player_team_css(obj) ~= "" then--bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team
						if --[[(vector.distance(obj:get_pos(), self.object:get_pos()) < 2 and vector.distance(obj:get_pos(), self.object:get_pos()) > 0) or--]] bots.is_in_bot_view(self, obj) then
							if bs_old.get_player_team_css(obj) ~= bots.data[self.bot_name].team then
								table.insert(detected, obj)
							end
						end
					end
				end
			end
			-- In Bot Weapons
			local to_shoot = detected--{}
			--for _, obj in pairs(detected) do
			--	local obj_pos = CheckPos(obj:get_pos())
			--	local self_pos = CheckPos(self.object:get_pos())
			--	if (core.line_of_sight(obj_pos, self_pos) == nil or core.line_of_sight(obj_pos, self_pos) == true) or (bots.line_of_sight(obj_pos, self_pos)) then
			--		table.insert(to_shoot, obj)
			--		print("inserted")
			--	end
			--	print("is detected")
			--end
			-- Gun Engine
			local name = self.bot_name
			for _, obj in pairs(to_shoot) do
				if bots.path_finder_running[self.bot_name] then
					bots.data[name].object:set_animation(bots.bots_animations[name].walk_mine, bots.bots_animations[name].anispeed, 0)
				else
					bots.data[name].object:set_animation(bots.bots_animations[name].mine, bots.bots_animations[name].anispeed, 0)
				end
				local to_use = ""
				local weapon_type = "hand_weapon"
				if bots.data[name].weapons.hard_weapon ~= "" then
					to_use = bots.data[name].weapons.hard_weapon
					weapon_type = "hard_weapon"
				elseif bots.data[name].weapons.hand_weapon ~= "" then
					to_use = bots.data[name].weapons.hand_weapon
					weapon_type = "hand_weapon"
				end
				local itemstack = ItemStack(to_use)
				if itemstack and itemstack ~= "" and itemstack:get_name() ~= "" then
					if not bots.queue_shot[name] then
						bots.in_hand_weapon[self.bot_name] = to_use
						
						local from = bots.to_2d(self.object:get_pos())
						local to = bots.to_2d(obj:get_pos())
						local offset_to = {
							x = to.x - from.x,
							y = to.y - from.y
						}
						
						local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
						
						local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage
						local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
						local cooldown = itemstack:get_definition().RW_gun_capabilities.gun_cooldown
						local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
						bots.shoot(1, damage or {fleshy=5}, "bs_bots:bullet", sound, velocity, self, obj)
						if weapon_type == "hand_weapon" then
							bots.queue_shot[name] = 0.4
						else
							bots.queue_shot[name] = cooldown or 0.1
						end
						if bots.data[name].wield_item_obj then
							bots.data[name].wield_item_obj:set_properties({
								textures = {itemstack:get_name()},
									visual_size = {x=0.25, y=0.25},
							})
						end
						self.object:set_yaw(dir)
					end
				end
			end
		end
	end
end

function Logic.OnStep(self)
	if self then
		if bs_match.match_is_started then
			if BotsLogicFunction then
				BotsLogicFunction(self)
			else
				Logic.OldOnStep(self)
			end
		else
			bbp.WhileOnPrepareTime(self)
			bots.CancelPathTo[self.bot_name] = true
			local bot_pos = self.object:get_pos()
			if vector.distance(bot_pos, maps.current_map.teams[bots.data[self.bot_name].team]) > 3 then
				self.object:set_velocity(vector.new(0,0,0))
			end
			local from = bots.to_2d(self.object:get_pos())
			local to = bots.to_2d(maps.current_map.teams[bots.data[self.bot_name].team])
			local offset_to = {
				x = to.x - from.x,
				y = to.y - from.y
			}
			local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
			self.object:set_yaw(dir)
		end
	end
end



