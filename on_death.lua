return function(self, killer)
	bots.data[self.bot_name].state = "dead"
	local killer_team = bs.get_player_team_css(killer)
	local killer_name = Name(killer)
	local killer_weapon = ""
	local image = "hand_kill.png"
	if killer:is_player() then
		killer_weapon = killer:get_wielded_item():get_name()
		bank.player_add_value(killer, 10)
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
	
	KillHistory.RawAdd(
		{text = killer_name, color = bs.get_team_color(bs.get_player_team_css(killer_name), "number")},
		image,
		{text = self.bot_name , color = bs.get_team_color(bots.data[self.bot_name].team, "number") or 0xFFF}
	)
	
end