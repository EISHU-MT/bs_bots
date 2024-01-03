return function(self, killer)
	if PvpMode.Mode == 1 then
		bots.data[self.bot_name].state = "dead"
		local killer_team = bs.get_player_team_css(killer)
		local killer_name = Name(killer)
		local killer_weapon = ""
		local image = "hand_kill.png"
		if killer:is_player() then
			if killer_team ~= bots.data[self.bot_name].team or config.PvpEngine.FriendShoot then
				killer_weapon = killer:get_wielded_item():get_name()
				bank.player_add_value(killer, 10)
				if PlayerKills[Name(killer)] and PlayerKills[Name(killer)].kills then
					PlayerKills[Name(killer)].kills = PlayerKills[Name(killer)].kills + 1
				end
				score.add_score_to(killer, 10)
				stats.kills.add_to(Name(killer))
			end
		else
			local bot_info = killer:get_luaentity()
			if bot_info then
				local name = bot_info.bot_name
				if bots.in_hand_weapon[name] then
					killer_weapon = bots.in_hand_weapon[name]
				else
					if bots.data[name].weapons.hard_weapon ~= "" then
						killer_weapon = bots.data[name].weapons.hard_weapon
					else
						killer_weapon = bots.data[name].weapons.hand_weapon
					end
				end
				bots.data[name].money = bots.data[name].money + 10
			end
		end
		
		RunCallbacks(BotsCallbacks.RegisteredOnKillBot, self, killer)
		
		local player_look = self.object:get_yaw()
		local obj = core.add_entity(self.object:get_pos(), "bs_bots:__dead_body")
		obj:set_yaw(player_look)
		obj:set_properties({
			textures = {"character.png^player_"..bots.data[self.bot_name].team.."_overlay.png"}
		})
		obj:set_animation({x = 162, y = 166}, 15, 0)
		obj:set_acceleration(vector.new(0,-9.81,0))
		
		local hand_item = ItemStack(killer_weapon)
		local desc = hand_item:get_definition()
		if desc.RW_gun_capabilities then
				image = desc.RW_gun_capabilities.gun_icon.."^[transformFX"
		else
			if desc.inventory_image and desc.inventory_image ~= "" then
				image = desc.inventory_image
			end
		end
		
		TheEnd()
		
		if bs.get_player_team_css(killer_name) == "" then
			return
		end
		
		KillHistory.RawAdd(
			{text = killer_name, color = bs.get_team_color(bs.get_player_team_css(killer_name), "number")},
			image,
			{text = self.bot_name , color = bs.get_team_color(bots.data[self.bot_name].team, "number") or 0xFFF}
		)
		UpdateTeamHuds()
	elseif PvpMode.Mode == 2 then
		bots.data[self.bot_name].state = "alive"
		local killer_team = bs.get_player_team_css(killer)
		local killer_name = Name(killer)
		local killer_weapon = ""
		local image = "hand_kill.png"
		if killer:is_player() then
			if killer_team ~= bots.data[self.bot_name].team or config.PvpEngine.FriendShoot then
				killer_weapon = killer:get_wielded_item():get_name()
				bank.player_add_value(killer, 10)
				if PlayerKills[Name(killer)] and PlayerKills[Name(killer)].kills then
					PlayerKills[Name(killer)].kills = PlayerKills[Name(killer)].kills + 1
				end
				score.add_score_to(killer, 10)
				stats.kills.add_to(Name(killer))
			end
		else
			local bot_info = killer:get_luaentity()
			if bot_info then
				local name = bot_info.bot_name
				if bots.in_hand_weapon[name] then
					killer_weapon = bots.in_hand_weapon[name]
				else
					if bots.data[name].weapons.hard_weapon ~= "" then
						killer_weapon = bots.data[name].weapons.hard_weapon
					else
						killer_weapon = bots.data[name].weapons.hand_weapon
					end
				end
				bots.data[name].money = bots.data[name].money + 10
			end
		end
		
		RunCallbacks(BotsCallbacks.RegisteredOnKillBot, self, killer)
		
		local hand_item = ItemStack(killer_weapon)
		local desc = hand_item:get_definition()
		if desc.RW_gun_capabilities then
				image = desc.RW_gun_capabilities.gun_icon.."^[transformFX"
		else
			if desc.inventory_image and desc.inventory_image ~= "" then
				image = desc.inventory_image
			end
		end
		
		KillHistory.RawAdd(
			{text = killer_name, color = bs.get_team_color(bs.get_player_team_css(killer_name), "number")},
			image,
			{text = self.bot_name , color = bs.get_team_color(bots.data[self.bot_name].team, "number") or 0xFFF}
		)
		
		bots.data[self.bot_name].object = core.add_entity(maps.current_map.teams[bots.data[self.bot_name].team], bots.data[self.bot_name].object_name)
		SpawnPlayerAtRandomPosition(bots.data[self.bot_name].object, bots.data[self.bot_name].team)
		bots.data[self.bot_name].object:set_armor_groups({fleshy=100, immortal=0})
		bots.add_nametag(bots.data[self.bot_name].object, bots.data[self.bot_name].team, self.bot_name)
		UpdateTeamHuds()
	end
end